//
//  LoginOrSignUpViewController.m
//  iPressbook
//
//  Created by Guillaume Cerquant on 05/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>


#import "LambdaAlert.h"
#import "IsoTonerAppDelegate.h"
#import "CreateAccountWebViewWrapper.h"
#import "WebService.h"
#import "LoginOrSignUpViewController.h"


@interface LoginOrSignUpViewController ()

    - (void) loginFailed;

@end


@implementation LoginOrSignUpViewController

@synthesize connectingSpinningWheel;
@synthesize demoExplicationView;
@synthesize passwordTextField;
@synthesize invalidPasswordImageView;
@synthesize invalidLoginImageView;
@synthesize loginDemoOrNewAccountView;
@synthesize demoPopupView;
@synthesize demoPopupWebView;
@synthesize logInButton;
@synthesize signUpButton;
@synthesize loginTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [loginTextField release];
    [passwordTextField release];
    [invalidPasswordImageView release];
    [invalidLoginImageView release];
    [connectingSpinningWheel release];
    [loginDemoOrNewAccountView release];
    [logInButton release];
    [signUpButton release];
    [demoExplicationView release];
    [demoPopupView release];
    [demoPopupWebView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) animateByPoppingItOutLoginDemoOrNewAccountView {
    CGRect frameOfLoginOrNewView = self.loginDemoOrNewAccountView.frame;
    
    
    self.loginDemoOrNewAccountView.frame = (CGRect) {75, 67, self.loginDemoOrNewAccountView.frame.size};
    
//    [self performSelector:@selector(animateByPoppingItOutLoginDemoOrNewAccountView) withObject:nil afterDelay:0.3];

    
    [UIView animateWithDuration:0.5
            delay:0.3 options:0
                     animations:^{self.loginDemoOrNewAccountView.frame = frameOfLoginOrNewView; }
                     completion:nil]; // ^(BOOL finished){ [view removeFromSuperview]; }]


}

- (void)viewDidLoad
{
    [super viewDidLoad];

 
    [self.logInButton setBackgroundImage:[[UIImage imageNamed:@"button-black.png"] stretchableImageWithLeftCapWidth:25 topCapHeight:0] forState:UIControlStateNormal];
    [self.signUpButton setBackgroundImage:[[UIImage imageNamed:@"button-black.png"] stretchableImageWithLeftCapWidth:25 topCapHeight:0] forState:UIControlStateNormal];    
    [self animateByPoppingItOutLoginDemoOrNewAccountView];
    
    self.loginTextField.text = [[(IsoTonerAppDelegate *)([UIApplication sharedApplication].delegate) myWebService] userName];

}

- (void)viewDidUnload
{
    
    [self setLoginTextField:nil];
    [self setPasswordTextField:nil];
    [self setInvalidPasswordImageView:nil];
    [self setInvalidLoginImageView:nil];
    [self setConnectingSpinningWheel:nil];
    

    [self setLoginDemoOrNewAccountView:nil];
    [self setLogInButton:nil];
    [self setSignUpButton:nil];
    [self setDemoExplicationView:nil];
    [self setDemoPopupView:nil];
    [self setDemoPopupWebView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


- (void) resetLoginUIItems {
    [invalidLoginImageView setHidden:YES];
    [invalidPasswordImageView setHidden:YES];
    [connectingSpinningWheel stopAnimating];

}


- (void) verifyLoginAndPassword {
    
//    [self performSelector:@selector(didLoginWithError) withObject:nil afterDelay:2.0];
  
    if ([self.loginTextField.text isEqualToString:@""]
        || [self.passwordTextField.text isEqualToString:@""]) {
        [self loginFailed];
    }
    
    [[(IsoTonerAppDelegate *)([UIApplication sharedApplication].delegate) myWebService] loginWithUsername:[self.loginTextField text] andPassword:[self.passwordTextField text]];
    
}

- (IBAction)loginAction {
    [self resetLoginUIItems];
    
    [connectingSpinningWheel startAnimating];
    
    [self verifyLoginAndPassword];
}


- (void) loginSucceeded {
    
    [[self view] removeFromSuperview];
    
//    if (isDemoAccount) {
//        // Show video tab bar
//        [[(IsoTonerAppDelegate *)([[UIApplication sharedApplication] delegate]) tabBarController] setSelectedIndex:1]; 
//    }
    


}

- (void) loginFailed {
    
    [invalidLoginImageView setHidden:NO];
    [invalidPasswordImageView setHidden:NO];
    
    [connectingSpinningWheel stopAnimating];
}

- (IBAction)createAnAccount:(id) sender {
        if ([accountCreationPopoverController isPopoverVisible]) {
            [accountCreationPopoverController dismissPopoverAnimated:YES];
        } else {
            UINavigationController *navController;
            
            navController = [[[UINavigationController alloc] initWithRootViewController:[[[CreateAccountWebViewWrapper alloc] init] autorelease]] autorelease];
            
            accountCreationPopoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
            
            [accountCreationPopoverController setPopoverContentSize:CGSizeMake(385, 654)];

            [accountCreationPopoverController presentPopoverFromRect:CGRectMake(800, 80, 0, 0)inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];

        }
}

- (IBAction)showDemoExplicationView {
    /*
    self.demoExplicationView.hidden = NO;
    return;
    */
    
    
//    LambdaAlert *alert = [[LambdaAlert alloc]
//                          initWithTitle:nil
//                          message:@"This iPressbook demo account allows you to discover the application.\nTo get your own media, logout (settings icon) and create an account."];
//    [alert addButtonWithTitle:@"Ok" block:^{ [self takeADemoTour]; }];
//    [alert show];
//    [alert release];


    [self.demoPopupWebView loadHTMLString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"demo_explanation" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil] baseURL:nil];
    
    self.demoPopupView.layer.cornerRadius = 10;
//        self.demoPopupWebView.layer.cornerRadius = 10;
    
    [UIView animateWithDuration:0.5
                     animations:^{ self.demoPopupView.alpha = 1.0; }
                     completion:nil];    
}



- (IBAction)takeADemoTour {
    isDemoAccount = YES;
    [[(IsoTonerAppDelegate *)([UIApplication sharedApplication].delegate) myWebService] loginWithUsername:kDemoLogin andPassword:kDemoPassword];
    
}


#pragma mark TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.loginTextField) {
        [passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self loginAction];
    }
    return YES;
}


@end
