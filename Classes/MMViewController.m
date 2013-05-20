//
//  MMViewController.h
//  MacMation
//
//  Created by Guillaume Cerquant.
//  Copyright 2010 MacMation - guillaume@macmation.com. All rights reserved.
//


#import "MMViewController.h"

@interface MMViewController (PrivateMethods)
- (void)addLogoImageInNavigationBar;

@end


@implementation MMViewController

+ (NSString *)nibName { return nil; }

+ (MMViewController *)controller {
	return [[[self alloc] initWithNibName:[self nibName] bundle:nil] autorelease];
}

#pragma mark -
#pragma mark View lifecycle
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
	
	if (self = [super initWithNibName:nibName bundle:nibBundle])
	{
		
	}
	
	return self;
}


- (void)viewDidLoad
{	
	[super viewDidLoad];
	
	
	// self.view.backgroundColor = [UIColor colorWithRed:0.125 green:0.125 blue:0.125 alpha:1]; 
	// self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	// [self addLogoImageInNavigationBar];
	self.navigationItem.hidesBackButton=YES;
	
	
	
}


#pragma mark -
- (void) parse{}

#pragma mark -
#pragma mark Mail form
// - (void)showMailFormForProgram:(DBProgram *)program
// {
// 	MFMailComposeViewController * picker = [[MFMailComposeViewController alloc] init];
// 	picker.navigationBar.tintColor = [UIColor blackColor]; 
// 	picker.mailComposeDelegate = self;
// 	
// 	Configuration *confimessage = [[Configuration alloc] init];
// 	[picker setSubject: [NSString 
// 						 localizedStringWithFormat: [confimessage textForSubjectOfShareEmail],
// 						 program.intitule]];
// 	[picker setMessageBody: [NSString
// 							 stringWithFormat:@"\n\n%@\n\n%@\n\n%@",
// 							 program.intitule,
// 							 program.resume,
// 							 [confimessage textForBodyOfShareEmail]
// 							 ] isHTML:NO];
// 	
// 	if (nil != picker) {
// 		[self presentModalViewController:picker animated:YES];		
// 	}
// 	
// 	[confimessage release];
// 	[picker release];
// }



#pragma mark -
#pragma mark NavBar custo

- (IBAction) showVersionInformations:(id) sender
{
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSDictionary *infoDict = [mainBundle infoDictionary];
					
	[[[[UIAlertView alloc] initWithTitle:[infoDict valueForKey:@"CFBundleDisplayName"]
								 message:[NSString stringWithFormat:
										  @"Version %@\nDate: %s\n%@ (iOS %@)\n\nADN Mobile ©\n\n\n(Tous droits réservés MacMation - Guillaume Cerquant)", 
										  [infoDict valueForKey:@"CFBundleVersion"], 
										  __DATE__, 
										  [[UIDevice currentDevice] localizedModel], 
										  [[UIDevice currentDevice] systemVersion]]
								delegate:nil
					   cancelButtonTitle:@"OK"
					   otherButtonTitles:nil] autorelease] show];
}


- (void)addLogoImageInNavigationBar 
{
	// UIView *viewContainingLogoImage;
	UIImageView *logoImageView;
	NSString *logoImageName;
	
#if DEVELOPMENT_MODE // defined in class Configuration
	logoImageName = @"Logo_DirectStar_dev_mode.png";
#else
	logoImageName = @"Logo_DirectStar.png";
#endif
	
	[[[self navigationController] navigationBar] setClipsToBounds:NO];
	
	UIImage *image = [UIImage imageNamed:logoImageName];
	logoImageView = [[[UIImageView alloc] initWithImage:image] autorelease];
	[logoImageView  setContentMode:UIViewContentModeBottom];
	[logoImageView setFrame:CGRectMake(0, 0, logoImageView.frame.size.width, logoImageView.frame.size.height + 11)];
	
	
	self.navigationItem.titleView = logoImageView;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationLandscapeLeft
			|| interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}



#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning{
	// TRACE; 
	[super didReceiveMemoryWarning];	
	// Release any cached data, images, etc that aren't in use.
}

- (void) dealloc 
{
	[super dealloc];
	
}

- (IBAction)backButtonAction:(UIButton *) senderButton {
	[[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)menuAction:(UIButton *) senderButton {
	[[self navigationController] popViewControllerAnimated:YES];
}

@end
