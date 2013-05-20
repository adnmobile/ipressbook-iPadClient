//
//  FilesListingViewController.m
//  iPressbook
//
//  Created by Guillaume Cerquant on 04/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "WebService.h"
#import "PictureViewController.h"
#import "VideosViewController.h"
#import "GenericFileThumbnailView.h"
#import "CJSONDeserializer.h"
#import "SettingsPopoverViewController.h"
#import "UIImageView+WebCache.h"
#import "IsoTonerAppDelegate.h"
#import "iPressBookFile.h"
#import "DownloadListTableViewController.h"

#import "FilesListingViewController.h"


// Specs and usage for this part evolved way  too much. This class *BADLY* needs some heavy refactoring.


#define kTagOffset 75


@interface FilesListingViewController ()

@property (retain, nonatomic) IBOutlet UIBarButtonItem *downloadingButton;
@property (retain, nonatomic) IBOutlet UIToolbar *myToolbar;

- (void) dismissDownloadsPopover;
- (void) fileListDidRefresh;

@end

@implementation FilesListingViewController
@synthesize downloadingButton;
@synthesize myToolbar;

@synthesize loadingLabel;




@synthesize tempTextView;
@synthesize multiPageScrollView;
@synthesize pageControl;
@synthesize noFileImageView;
@synthesize titleBarButtonItem;
@synthesize thumbnailFileViewFromNib;
@synthesize listOfFiles;




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
    [tempTextView release];
    [titleBarButtonItem release];
    [noFileImageView release];
    [multiPageScrollView release];
    [pageControl release];
    [loadingLabel release];
    
    [openFileButton release];
    [downloadingButton release];
    [myToolbar release];
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
        
    
    titleBarButtonItem.title = self.tabBarItem.title;    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector: @selector(fileListDidRefresh)
                                                 name:kFileListDidRefresh 
                                               object:nil]; 
}

- (void) updateVisibilityOfDownloadingButton {
    
    // Let's always remove it, then add it back at the right index if we are downloading
    NSMutableArray *toolbarItemsMutableArray = [self.myToolbar.items mutableCopy];
    [toolbarItemsMutableArray removeObject:self.downloadingButton];
    
    if ([(NSArray *)([[[[(IsoTonerAppDelegate *)([[UIApplication sharedApplication] delegate]) myWebService] filesToDownloadQueue] operations] valueForKeyPath:@"userInfo"]) count]) {
        
        [toolbarItemsMutableArray insertObject:self.downloadingButton atIndex:5];
    } else {
        // Dismiss the popover, just in case
        [self dismissDownloadsPopover];
    }
    
    [self.myToolbar setItems:toolbarItemsMutableArray animated:YES];
    
    [toolbarItemsMutableArray release];
}


- (void) fileListDidRefresh {
    [self refresh];
}


- (NSInteger) categoryIndex {
    
    return [[self tabBarItem] tag];
}



- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.noFileImageView.hidden = YES;
    
    [self refresh];
}


- (void) refresh {
    NSArray *files = [[(IsoTonerAppDelegate *)([[UIApplication sharedApplication] delegate]) myWebService] listOfFilesForCategory:[self categoryIndex]];
    
    
//    NSLog(@"files: %@", files);
   
    loadingLabel.hidden = YES;

    
    self.listOfFiles = files;
    
    
    if (0 == [self.listOfFiles count]) {
        self.noFileImageView.hidden = NO;
    } else {
        self.noFileImageView.hidden = YES;
    }
    
    
    
    NSInteger numberOfCurrentPage = 0;
    NSInteger numberOfCurrentColumnOfThumbnail = 0;
    NSInteger numberOfCurrentLineOfThumbnail = 0;
    NSUInteger indexForTag = 0;
    
    
    [self.multiPageScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    


    
    
    for (NSDictionary *aFileInfo in self.listOfFiles) {
        iPressBookFile *aniPressBookFile = [[iPressBookFile alloc] initWithDictionary:aFileInfo];
        
        if (! [aniPressBookFile hasBeenDownloaded]) {
            [aniPressBookFile release];
            break;
        }
        
        if (numberOfCurrentColumnOfThumbnail > 3) {
            numberOfCurrentLineOfThumbnail++;
            numberOfCurrentColumnOfThumbnail = 0;
        }
        
        if (numberOfCurrentLineOfThumbnail > 2) {
            numberOfCurrentPage++;
            numberOfCurrentLineOfThumbnail = 0;
        }
        
        
        [[NSBundle mainBundle] loadNibNamed:@"GenericFileThumbnailView" owner:self options:nil];
        [self.thumbnailFileViewFromNib setFrame:(CGRect) {self.multiPageScrollView.frame.size.width * numberOfCurrentPage + self.thumbnailFileViewFromNib.frame.size.width * numberOfCurrentColumnOfThumbnail, self.thumbnailFileViewFromNib.frame.size.height * numberOfCurrentLineOfThumbnail, self.thumbnailFileViewFromNib.frame.size}];
        
        self.thumbnailFileViewFromNib.tag = indexForTag + kTagOffset;
        self.thumbnailFileViewFromNib.titleLabel.text = [aniPressBookFile fileName];
        [self.thumbnailFileViewFromNib.openFileButton setTitle:(NSString *)aniPressBookFile forState:UIControlStateApplication];
        
        
        NSString *defaultImageName = [aniPressBookFile defaultThumbnailImageName];
        
        if (nil != [aniPressBookFile urlOfThumbnail]) {
            NSURL *thumbnailURL = [NSURL URLWithString:[aniPressBookFile urlOfThumbnail]];
            
            if (nil != thumbnailURL) {
                [self.thumbnailFileViewFromNib.thumbnailimageView setImageWithURL:thumbnailURL placeholderImage:[UIImage imageNamed:defaultImageName]];
            }
        }  else {
            [self.thumbnailFileViewFromNib.thumbnailimageView setImage:[UIImage imageNamed:defaultImageName]];
        }
        
        [self.multiPageScrollView addSubview:self.thumbnailFileViewFromNib];
        
    
        numberOfCurrentColumnOfThumbnail++;
        
        
        indexForTag++;
        [aniPressBookFile release];
    }

    
    
    if (0 == indexForTag) {
        self.noFileImageView.hidden = NO;
    }
    
    
    self.pageControl.hidden = ! numberOfCurrentPage > 0;

    self.pageControl.numberOfPages = numberOfCurrentPage + 1;  
    
    [self.multiPageScrollView setContentSize:CGSizeMake(self.pageControl.numberOfPages * self.multiPageScrollView.frame.size.width, self.multiPageScrollView.frame.size.height)];

    
    [self updateVisibilityOfDownloadingButton];
}

- (void) dismissDownloadsPopover {
    [theDownloadsPopoverController dismissPopoverAnimated:YES];
}


- (IBAction)seeDownloadPopover:(id)barButtonItem {
    [self dismissSettingsPopover];
    
    if ([theDownloadsPopoverController isPopoverVisible]) {
        [theDownloadsPopoverController dismissPopoverAnimated:YES];
    } else {
        theDownloadsPopoverController = [[UIPopoverController alloc] initWithContentViewController:[[[DownloadListTableViewController alloc] init] autorelease]];
        [theDownloadsPopoverController presentPopoverFromBarButtonItem:barButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }

}





- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFileListDidRefresh object:nil];

    
    [self setTempTextView:nil];
    
    
    [self setTitleBarButtonItem:nil];
    [self setNoFileImageView:nil];
    [self setMultiPageScrollView:nil];
    [self setPageControl:nil];
    [self setLoadingLabel:nil];
    [self setDownloadingButton:nil];
    [self setMyToolbar:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void) dismissSettingsPopover {
    [theSettingsPopoverController dismissPopoverAnimated:YES];
}

- (IBAction)showSettings:(UIBarButtonItem *) barButtonItem {
    [self dismissDownloadsPopover];
    
    if ([theSettingsPopoverController isPopoverVisible]) {
        [theSettingsPopoverController dismissPopoverAnimated:YES];
    } else {
        UINavigationController *navController;
        
        navController = [[[UINavigationController alloc] initWithRootViewController:[[[SettingsPopoverViewController alloc] init] autorelease]] autorelease];
        
        theSettingsPopoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
        [theSettingsPopoverController presentPopoverFromBarButtonItem:barButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}


- (void)openWithExternalApplicationFileAtPath:(NSString *) filePath withMenuAtFrame:(CGRect) theFrame {
    NSURL *url;
	
	if (nil == filePath) {
		NSLog(@"nil filePath");
		return;
	}
	
	url = [NSURL fileURLWithPath:filePath];
    
	NSLog(@"TRying to open URL : %@", url);
	if (nil == url) {
		NSLog(@"nil url: %@", url);
		return;
	}
	
    if (! docController) {
        [docController release];
    }
    
	docController = [UIDocumentInteractionController interactionControllerWithURL:url];
    
    docController.delegate = nil; //self;
	
 	[docController retain]; //TODO: Properly handle this
	
    
	if (! [docController  presentOpenInMenuFromRect:theFrame
                                            inView:self.parentViewController.view
                                          animated:YES]) {
		[[[[UIAlertView alloc] initWithTitle:nil message:@"To view this document, you need to install a viewer or an appropriate Apple application (ie : Keynote, Numbers, Pages)." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];

		
    }
}





- (IBAction)selectedFile:(UIButton *)senderButton {

    iPressBookFile *aniPressBookFile = (iPressBookFile *)[senderButton titleForState:UIControlStateApplication];
    
    NSString *localFilePath = [aniPressBookFile localFilePath];

    if (nil == localFilePath) {
        NSLog(@"Nil local file path");
        return;
    }
    
    NSURL *localFilePathURL = [NSURL fileURLWithPath:localFilePath];

    
    NSLog(@"local file path: %@", localFilePath);
    
    NSString *fileExtension = [[[aniPressBookFile fileName] pathExtension] lowercaseString];
    
    NSLog(@"file extension : %@", fileExtension);
    
    
    // Picture
    if ([[NSArray arrayWithObjects:@"png", @"jpg", @"gif", @"jpeg", nil] containsObject:fileExtension]) {
        PictureViewController *pictureViewController = [[PictureViewController alloc] init];
        
        
        
        [self presentModalViewController:pictureViewController animated:YES];
        [pictureViewController.fileImageView setImageWithURL:localFilePathURL placeholderImage:[UIImage imageNamed:@"default-picture.png"]];
        [pictureViewController release];
        
        return;
    }
    
    // Movie
    if ([[NSArray arrayWithObjects:@"mov", @"m4v", @"mpv", @"3gp", @"mp4", @"mpv",
          nil] containsObject:fileExtension]) {
        NSLog(@"Opening a movie : %@", localFilePath);
        VideosViewController *videosViewController = [[VideosViewController alloc] init];
        
        [self presentModalViewController:videosViewController animated:YES];       
        [videosViewController startPlayingVideoAtPath:localFilePath];
        
        [videosViewController release];
        
        return;
    }
    

    
    // Document that can be read full screen inside app
    if ([[NSArray arrayWithObjects:@"pdf", @"html", @"txt", nil] containsObject:fileExtension]) {
        docController = [UIDocumentInteractionController interactionControllerWithURL:localFilePathURL];
		
        docController.delegate = self;
        
        [docController retain];
        
        BOOL result = [docController presentPreviewAnimated:YES];
        
        if (NO == result) {
            NSLog(@"Failed to open document %@.", localFilePath);
        }
        
        return;
    }


    // Document with external app required
    
    [self openWithExternalApplicationFileAtPath:localFilePath withMenuAtFrame:[[senderButton superview] frame]];
}

- (IBAction)syncAction:(id)sender {
    [[(IsoTonerAppDelegate *)([UIApplication sharedApplication].delegate) myWebService] startSyncing];
}


- (void) loginFailed {
    // Needed to avoid crash
}


#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
}

#pragma mark -
#pragma mark UIDocumentInteractionControllerDelegate methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
	return self;
//	return self.parentViewController;
}


- (void) removeAllElements {
    
    self.noFileImageView.hidden = YES;
    [self.multiPageScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
}

@end
