//
//  FilesListingViewController.h
//  iPressbook
//
//  Created by Guillaume Cerquant on 04/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericFileThumbnailView.h"
#import "WebService.h"
#import "MMViewController.h"

extern NSString * const kFileNameKey;

@interface FilesListingViewController : MMViewController <UIScrollViewDelegate, UIDocumentInteractionControllerDelegate> {
    WebService *webService;
    UITextView *tempTextView;
    UIScrollView *multiPageScrollView;
    UIPageControl *pageControl;
    UIPopoverController *theSettingsPopoverController;
    UIPopoverController *theDownloadsPopoverController;

    
    UIBarButtonItem *titleBarButtonItem;
    UIImageView *noFileImageView;
    UILabel *loadingLabel;
    UIButton *openFileButton;
    
    UIDocumentInteractionController *docController;
}



@property (nonatomic, retain) NSArray *listOfFiles;

@property (nonatomic, retain) IBOutlet UIImageView *noFileImageView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *titleBarButtonItem;

@property (nonatomic, retain) IBOutlet GenericFileThumbnailView *thumbnailFileViewFromNib;

@property (nonatomic, retain) IBOutlet UITextView *tempTextView;

@property (nonatomic, retain) IBOutlet UIScrollView *multiPageScrollView;

@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;



- (IBAction)showSettings:(UIBarButtonItem *) barButtonItem;
- (void) dismissSettingsPopover;

- (IBAction)selectedFile:(id)sender;

- (IBAction)syncAction:(id)sender;

@property (nonatomic, retain) IBOutlet UILabel *loadingLabel;


- (void) removeAllElements;


- (void) refresh;
- (IBAction)seeDownloadPopover:(id)sender;


@end
