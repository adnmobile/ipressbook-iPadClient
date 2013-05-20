//
//  VideosViewController.m
//  IsoToner
//
//  Created by Guillaume Cerquant on 20/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VideosViewController.h"


@interface VideosViewController (PrivateMethods)

- (void)playerDidFinish;
- (void)playerDidExitFullScreen;

@end


@implementation VideosViewController


- (void)dealloc {
    [super dealloc];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)startPlayingVideoAtPath:(NSString *) pathOrURL {

    player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:pathOrURL]];

	
	if (player) {
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerDidFinish)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerDidExitFullScreen)
                                                     name:MPMoviePlayerDidExitFullscreenNotification
                                                   object:nil];

		

	}
	
	player.controlStyle = MPMovieControlStyleFullscreen;
	[[player view] setFrame:[self.view bounds]];
	[self.view addSubview:[player view]];
	[player setFullscreen:YES];
    [player shouldAutoplay]; // Something is broken is 4.2 >
	[player play];
}

- (IBAction)doneAction:(id)sender {
    [player stop];
	[self playerDidFinish];

}


- (void)playerDidExitFullScreen {
	[player stop];
	[self playerDidFinish];
}


- (void)playerDidFinish {
	[[player view] removeFromSuperview];
	[player release];
	player = nil;
	
//	[self.navigationController popViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
}


@end
