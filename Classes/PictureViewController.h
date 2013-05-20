//
//  PictureViewController.h
//  iPressbook
//
//  Created by Guillaume Cerquant on 06/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PictureViewController : UIViewController {
    
    UIImageView *fileImageView;
}

@property (nonatomic, retain) IBOutlet UIImageView *fileImageView;


- (IBAction)dismissMe;

@end
