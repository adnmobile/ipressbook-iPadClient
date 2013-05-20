//
//  SettingsPopoverViewController.m
//  iPressbook
//
//  Created by Guillaume Cerquant on 05/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilesListingViewController.h"
#import "IsoTonerAppDelegate.h"
#import "WebService.h"
#import "ManageAccountWebViewWrapper.h"
#import "SettingsPopoverViewController.h"


@implementation SettingsPopoverViewController
@synthesize versionNumberLabel;
@synthesize theTableView;

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
    [versionNumberLabel release];
    [theTableView release];
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
    
    [self navigationItem].title = @"Settings";

    [self.versionNumberLabel setText:[NSString stringWithFormat:@"Version %@", [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"]]];
    
    [theTableView setBackgroundView:nil];
    [theTableView setBackgroundColor:[UIColor clearColor]];
    [theTableView setOpaque:NO];
}

- (void)viewDidUnload
{
    [self setVersionNumberLabel:nil];
    [self setTheTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.theTableView deselectRowAtIndexPath:[self.theTableView indexPathForSelectedRow] animated:NO];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
        
    switch ([indexPath section]) {
        case 0:
            cell.textLabel.text = @"Account";
            cell.detailTextLabel.text = [[[[WebService alloc] init] autorelease] userName];

            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
     ManageAccountWebViewWrapper *manageAccountViewController = [[[ManageAccountWebViewWrapper alloc] init] autorelease];
    
     [self.navigationController pushViewController:manageAccountViewController animated:YES];
}


- (IBAction)logOutAction {
    
    UIViewController *theViewController;
    
    theViewController = [[(IsoTonerAppDelegate *)([[UIApplication sharedApplication] delegate]) tabBarController] selectedViewController];
    
    if ([theViewController isKindOfClass:[FilesListingViewController class]]) {
        [(FilesListingViewController *)theViewController dismissSettingsPopover];
    }

    for (FilesListingViewController *aViewController in [[(IsoTonerAppDelegate *)([[UIApplication sharedApplication] delegate]) tabBarController] viewControllers]) {
        if ([aViewController isKindOfClass:[FilesListingViewController class]]) {
            [aViewController removeAllElements];
        }
    }
    
     
    [[[[WebService alloc] init] autorelease] logMeOut];
}


@end
