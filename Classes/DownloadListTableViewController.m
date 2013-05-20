//
//  DownloadListTableViewController.m
//  iPressbook
//
//  Created by Guillaume Cerquant on 30/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "iPressBookFile.h"
#import "DownloadListTableViewController.h"

#import "IsoTonerAppDelegate.h"

@interface DownloadListTableViewController ()

@property (retain) NSArray *fileBeingDownloadedUserInfos;

- (void) saveLocalArray;

- (void) fileListDidRefresh;

@end

@implementation DownloadListTableViewController

@synthesize progressView;
@synthesize fileNameLabel;
@synthesize tableView;
@synthesize downloadFileCell;
@synthesize fileBeingDownloadedUserInfos;
@synthesize imageThumbnail;



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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [self saveLocalArray];
    
    self.tableView.rowHeight = 52.0f;
 
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector: @selector(fileListDidRefresh)
                                                 name:kFileListDidRefresh 
                                               object:nil]; 
    
    self.tableView.hidden = (0 == self.fileBeingDownloadedUserInfos.count);
    [self.tableView reloadData];
}


- (void) saveLocalArray {
    self.fileBeingDownloadedUserInfos = [[[[(IsoTonerAppDelegate *)([[UIApplication sharedApplication] delegate]) myWebService] filesToDownloadQueue] operations] valueForKeyPath:@"userInfo"];
}

- (void) fileListDidRefresh {
    [self saveLocalArray];
    
    
    self.tableView.hidden = (0 == self.fileBeingDownloadedUserInfos.count);
    
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFileListDidRefresh object:nil];

    [self setTableView:nil];

    self.imageThumbnail = nil;
    self.progressView = nil;
    self.fileNameLabel = nil;
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fileBeingDownloadedUserInfos count];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"fileDownloadCell";
    
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"FileDownloadTableViewCell" owner:self options:nil];
        cell = downloadFileCell;
        self.downloadFileCell = nil;
    }
    
    NSDictionary *userInfo = [self.fileBeingDownloadedUserInfos objectAtIndex:indexPath.row];
    
    if ((id)userInfo != [NSNull null]) {
        iPressBookFile *aniPressBookFile = [userInfo valueForKey:@"iPressBookFile"];

        [(UILabel *)[cell viewWithTag:11] setText:aniPressBookFile.fileName];
        
        
        [[cell viewWithTag:12] removeFromSuperview];
        UIProgressView *theProgressView = [userInfo valueForKey:@"progressView"];
        if (theProgressView) {
            theProgressView.tag = 12;
            [cell.contentView addSubview:theProgressView];
        } 
        
        UIImageView *imageThumbnailView = (UIImageView *)[cell viewWithTag:14];
        imageThumbnailView.image = [UIImage imageNamed:@"Icon.png"];
        
        NSString *defaultImageName = [aniPressBookFile defaultThumbnailImageName];
        
        if (nil != [aniPressBookFile urlOfThumbnail]) {
            NSURL *thumbnailURL = [NSURL URLWithString:[aniPressBookFile urlOfThumbnail]];
            
            if (nil != thumbnailURL) {
                [imageThumbnailView setImageWithURL:thumbnailURL placeholderImage:[UIImage imageNamed:defaultImageName]];
            }
        }  else {
            [imageThumbnailView setImage:[UIImage imageNamed:defaultImageName]];
        }
    
    }
    
    return cell;
}


- (void)dealloc {
    [tableView release];
    [super dealloc];
}
@end
