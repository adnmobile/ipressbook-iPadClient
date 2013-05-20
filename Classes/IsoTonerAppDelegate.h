//
//  IsoTonerAppDelegate.h
//  IsoToner
//
//  Created by Guillaume Cerquant on 21/09/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//


#import "Reachability2_1.h"

#import <UIKit/UIKit.h>

#import "WebService.h"

@class UIAppUtilities;
@class LoginOrSignUpViewController;

@interface IsoTonerAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	
	LoginOrSignUpViewController *theLoginViewController;
    
    UIAppUtilities *myAppUtilities;
    
    Reachability2_1* hostReach;
    Reachability2_1* internetReach;

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (retain) WebService *myWebService;


- (void) showLoginScreen;
- (void) didLogin;

@end
