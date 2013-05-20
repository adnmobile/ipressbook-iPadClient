//
//  UIAppUtilities.h
//  iConnect
//
//  Created by Guillaume Cerquant on 31/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//#import <Cocoa/Cocoa.h>


@interface UIAppUtilities : NSObject {

	IBOutlet UIImageView *theDefaultImageView;
}

- (void)quitIfDemoPeriodExpired;

- (IBAction) showVersionInformations:(id) sender;

@end
