//
//  UIAppUtilities.m
//  iConnect
//
//  Created by Guillaume Cerquant on 31/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "LambdaAlert.h"
#import "UIAppUtilities.h"


@implementation UIAppUtilities


#pragma mark - Demo expiration

- (void)quitIfDemoPeriodExpired {
	
#define EXPIRE_AFTER_DAYS                   15
#define WARN_ABOUT_EXPIRATION_AFTER_DAYS    10

	NSString* compileDateString = [NSString stringWithUTF8String:__DATE__];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
	[dateFormatter setDateFormat:@"MMM dd yyyy"];
	NSDate *compileDate = [dateFormatter dateFromString:compileDateString];
	[dateFormatter release];
	NSDate *expireDate = [compileDate dateByAddingTimeInterval:(60 * 60 * 24 * EXPIRE_AFTER_DAYS)];
	if ([expireDate earlierDate:[NSDate date]] == expireDate)
	{
#define kCFBundleVersionKey @"CFBundleVersion"
#define kCFBundleDisplayName @"CFBundleDisplayName"
		NSBundle *mainBundle = [NSBundle mainBundle];
		NSDictionary *infoDict = [mainBundle infoDictionary];
		
        
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:[NSString stringWithFormat:@"%@: Demo expired", [infoDict valueForKey:kCFBundleDisplayName]]
                              message:[NSString stringWithFormat:@"Please upgrade.\n\nVersion %@\nCompiled: %s, at %s\n\n%@ (%@: %@)", [infoDict valueForKey:kCFBundleVersionKey], __DATE__, __TIME__,
                                       [[UIDevice currentDevice] localizedModel], [[UIDevice currentDevice] systemName],  [[UIDevice currentDevice] systemVersion]]]
        ;
        [alert addButtonWithTitle:@"Quit" block:^{ NSLog(@"Demo expired. Will quit. Bye!");
            exit(0);
        }];
        [alert show];
        [alert release];

		
	} else {
		// Warn about expiration
		NSDate *startWarningAboutExpirationDate = [compileDate dateByAddingTimeInterval:(60 * 60) * 24 * WARN_ABOUT_EXPIRATION_AFTER_DAYS];
		// NSLog(@"compil: %@", compileDate);
		// NSLog(@"startW: %@", startWarningAboutExpirationDate);
		// NSLog(@"now   : %@", [NSDate date]);
		
		if (NSOrderedAscending == [startWarningAboutExpirationDate compare:[NSDate date]]) {
			[[[[UIAlertView alloc] initWithTitle:@"Demo expiration"
										 message:[NSString stringWithFormat:@"This application is a demo version.\nIt will expire on %@", [compileDate dateByAddingTimeInterval:(60 * 60) * 24 * EXPIRE_AFTER_DAYS]]
										delegate:self
							   cancelButtonTitle:@"Ok"
							   otherButtonTitles:nil] autorelease] show];
		
		}
	}
}

#pragma mark Splashscreen fading

- (void)addDefaultScreenAndFadeItOut {	
//	theDefaultImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
//	
//	[window addSubview:theDefaultImageView];
//
//    [UIView beginAnimations:@"fadeOutDefaultSplash" context:nil];
//    [UIView setAnimationDuration:2.0];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(fadeOut:finished:context:)];
//    theDefaultImageView.alpha = 0.0;
//    [UIView commitAnimations];
}

-(void)fadeOut:(NSString*)animationID finished:(BOOL)finished context:(void*)context  {
	[theDefaultImageView removeFromSuperview];
	[theDefaultImageView release];
	
//	[[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
}


#pragma mark - Info - Credits

- (IBAction) showVersionInformations:(id) sender {
	
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSDictionary *infoDict = [mainBundle infoDictionary];
					
	[[[[UIAlertView alloc] initWithTitle:[infoDict valueForKey:@"CFBundleDisplayName"]
								 message:[NSString stringWithFormat:
										  @"Version %@\nCompiled: %s, at %s\n\n%@ (%@: %@)", 
										  [infoDict valueForKey:@"CFBundleVersion"], 
										  __DATE__, 
										  __TIME__,
										  [[UIDevice currentDevice] localizedModel], 
										  [[UIDevice currentDevice] systemName],
										  [[UIDevice currentDevice] systemVersion]]
								delegate:nil
					   cancelButtonTitle:@"OK"
					   otherButtonTitles:nil] autorelease] show];
}



@end
