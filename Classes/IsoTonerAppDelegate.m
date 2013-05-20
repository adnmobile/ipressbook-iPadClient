//
//  IsoTonerAppDelegate.m
//  IsoToner
//
//  Created by Guillaume Cerquant on 21/09/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "LoginOrSignUpViewController.h"
#import "UIAppUtilities.h"
#import "MemoryStressTest.h"

#import "IsoTonerAppDelegate.h"

@interface IsoTonerAppDelegate ()

- (void) registerForReachabilitNotifications;


@end


@implementation IsoTonerAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize myWebService;

#pragma mark -
#pragma mark Application lifecycle

- (void)selectViewBeingDevelopped {
	[tabBarController setSelectedIndex:1];
	
}

- (void) showLoginScreen {

    if (! theLoginViewController) {
        theLoginViewController = [[LoginOrSignUpViewController alloc] init];
        [tabBarController.view addSubview:[theLoginViewController view]]; 
    } else {
        [theLoginViewController loginFailed];
    }

}

- (void) didLogin {
    [theLoginViewController.view removeFromSuperview];
    
    
    [theLoginViewController release];
    theLoginViewController = nil;

    [[[(IsoTonerAppDelegate *)([[UIApplication sharedApplication] delegate]) tabBarController] selectedViewController] viewDidAppear:NO]; 

    
    [self.myWebService startSyncing];
    
    
//    if ([[[self.tabBarController tabBarController] selectedViewController] respondsToSelector:@selector(refresh)]) {
//        [[[self.tabBarController tabBarController] selectedViewController] performSelector:@selector(refresh)];
//    } else {
//        NSLog(@"did not respond to refresh %@", 
//        NSStringFromClass([[[self.tabBarController tabBarController] selectedViewController] class]));
//
//    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

    [window addSubview:tabBarController.view];


    self.myWebService = [[[WebService alloc] init] autorelease];
    
    
    
    if ( ! self.myWebService.isConnected) {
        [self showLoginScreen];
    }

    [window makeKeyAndVisible];
    
    [self registerForReachabilitNotifications];
    
//#pragma mark warning Remove demo expiration for AppStore upload
//    myAppUtilities = [[UIAppUtilities alloc] init];
//    [myAppUtilities quitIfDemoPeriodExpired];

    // Use it for memory stress test
    //    [[[MemoryStressTest alloc] init] launchStressTests];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     */
}


#pragma mark -
#pragma mark UITabBarControllerDelegate methods

/*
 // Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
 */

/*
 // Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
 */

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}


#pragma mark TabBarDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
//	if ([viewController isKindOfClass:[PDFClientsViewController class]]) {
//		[(PDFClientsViewController *)viewController tabBarWasClicked:self];
//	}
}


#pragma mark Reachability stuff

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability2_1* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability2_1 class]]);

    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    
    if (netStatus == NotReachable) {
    
            [[[[UIAlertView alloc] initWithTitle:@"No internet connection" message:@"No internet connection has been found. Please check your settings and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
    }
}


- (void) registerForReachabilitNotifications {
    
    // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
    // method "reachabilityChanged" will be called. 
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    

//    internetReach = [[Reachability2_1 reachabilityForInternetConnection] retain];
//	[internetReach startNotifier];

    hostReach = [[Reachability2_1 reachabilityWithHostName:@"www.apple.com"] retain];
	[hostReach startNotifier];
	
}


@end

