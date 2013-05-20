//
//  VideosViewController.h
//  IsoToner
//
//  Created by Guillaume Cerquant on 20/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MMViewController.h"

#import <MediaPlayer/MediaPlayer.h>


@interface VideosViewController : MMViewController {
	MPMoviePlayerController *player;
	
}

- (IBAction)startPlayingVideoAtPath:(NSString *) pathOrURL;

- (IBAction)doneAction:(id)sender;
@end
