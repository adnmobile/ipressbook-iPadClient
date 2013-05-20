//
//  CreateAccountWebViewWrapper.m
//  iPressbook
//
//  Created by Guillaume Cerquant on 08/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WebService.h"
#import "CreateAccountWebViewWrapper.h"


@implementation CreateAccountWebViewWrapper
@synthesize createAccountWebView;

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
    [createAccountWebView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self navigationItem].title = @"Create an Account";
    
    [self.createAccountWebView loadRequest:[[[NSURLRequest alloc] initWithURL:[[[[WebService alloc] init] autorelease] URLOfCreateAccountWebView]] autorelease]];

}

- (void)viewDidUnload
{
    [self setCreateAccountWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
