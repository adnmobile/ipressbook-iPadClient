//
//  SettingsPopoverViewController.h
//  iPressbook
//
//  Created by Guillaume Cerquant on 05/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsPopoverViewController : UIViewController <UITableViewDelegate, UITableViewDelegate> {
    
    UILabel *versionNumberLabel;
    UITableView *theTableView;
    UIButton *logOutAction;
    
}



@property (nonatomic, retain) IBOutlet UILabel *versionNumberLabel;
@property (nonatomic, retain) IBOutlet UITableView *theTableView;
- (IBAction)logOutAction;

@end
