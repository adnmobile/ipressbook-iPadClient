//
//  PDFClientsViewController.h
//  IsoToner
//
//  Created by Guillaume Cerquant on 20/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

#import "MBProgressHUD.h"

#import "MMURLConnection.h"
#import "MMViewController.h"

typedef enum {
    fiche_clients = 0,
    etat_rupture = 1
} pdf_view_controllers;

// extern NSString * const kURLOfPlistFileWithSyncData;

@interface PDFClientsViewController : MMViewController <UIDocumentInteractionControllerDelegate> {
	NSString *onlineMd5Checksum;
	
	IBOutlet UILabel *updateInfoLabel;
	IBOutlet UIBarButtonItem *updateButton;
	
	IBOutlet UIWebView *webViewForPDFFile;
	
	IBOutlet UIProgressView *fileDownloadProgressView;
	
	ASINetworkQueue *networkQueue;
	BOOL failed;
	
	IBOutlet UIView *subViewOfHUD;
	MBProgressHUD * theHUD;
	BOOL updateRequestIsManual;
	
	MMURLConnection * theConnection;

	UIDocumentInteractionController *docController;
	
	NSString *timestamp1;
}


- (pdf_view_controllers) typeOfInstanceOfPDFViewController;


@property (retain)	NSString *onlineMd5Checksum;

- (IBAction)updateFileAction:(id)sender;
- (IBAction)goToFullScreenMode:(id)sender;

- (IBAction)stopDownloadOfFileInProgress:(id)sender;

- (void)tabBarWasClicked:(id)sender;

@end
