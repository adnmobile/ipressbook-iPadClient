//
//  LoginOrSignUpViewController.h
//  iPressbook
//
//  Created by Guillaume Cerquant on 05/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "WebService.h"

@interface LoginOrSignUpViewController : UIViewController {
    
    UITextField *loginTextField;
    UITextField *passwordTextField;
    UIImageView *invalidPasswordImageView;
    UIImageView *invalidLoginImageView;
    UIView *loginDemoOrNewAccountView;
    UIView *demoPopupView;
    UIWebView *demoPopupWebView;
    UIActivityIndicatorView *connectingSpinningWheel;
    UIView *demoExplicationView;
    
    UIButton *logInButton;
    UIButton *signUpButton;
    
    BOOL isDemoAccount;
    
    UIPopoverController *accountCreationPopoverController;
}


@property (nonatomic, retain) IBOutlet UIButton *logInButton;
@property (nonatomic, retain) IBOutlet UIButton *signUpButton;
@property (nonatomic, retain) IBOutlet UITextField *loginTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;

@property (nonatomic, retain) IBOutlet UIImageView *invalidPasswordImageView;

@property (nonatomic, retain) IBOutlet UIImageView *invalidLoginImageView;
@property (nonatomic, retain) IBOutlet UIView *loginDemoOrNewAccountView;

@property (nonatomic, retain) IBOutlet UIView *demoPopupView;
@property (nonatomic, retain) IBOutlet UIWebView *demoPopupWebView;

- (void) loginFailed;

- (IBAction)loginAction;

- (IBAction)createAnAccount:(id) sender;

- (IBAction)showDemoExplicationView;

- (IBAction)takeADemoTour;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *connectingSpinningWheel;

@property (nonatomic, retain) IBOutlet UIView *demoExplicationView;
@end
