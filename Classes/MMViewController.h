//
//  MMViewController.h
//  MacMation
//
//  Created by Guillaume Cerquant.
//  Copyright 2010 MacMation - guillaume@macmation.com. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface MMViewController : UIViewController {

}


+ (NSString *)nibName;
+ (MMViewController *)controller;


- (IBAction)backButtonAction:(UIButton *) senderButton;

- (IBAction) showVersionInformations:(id) sender;



@end
