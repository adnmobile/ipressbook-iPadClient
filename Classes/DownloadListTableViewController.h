//
//  DownloadListTableViewController.h
//  iPressbook
//
//  Created by Guillaume Cerquant on 30/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadListTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableViewCell *downloadFileCell;
    
    UITableView *tableView;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;


@property (nonatomic, assign) IBOutlet UITableViewCell *downloadFileCell;

@property (retain) IBOutlet UIProgressView *progressView;
@property (retain) IBOutlet UILabel *fileNameLabel;
@property (retain) IBOutlet UIImageView *imageThumbnail;

@end
