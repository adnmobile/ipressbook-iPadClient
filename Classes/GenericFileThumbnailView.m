//
//  GenericFileThumbnailView.m
//  iPressbook
//
//  Created by Guillaume Cerquant on 05/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GenericFileThumbnailView.h"


@implementation GenericFileThumbnailView
@synthesize thumbnailimageView;
@synthesize titleLabel;
@synthesize progressIndicatorView;
@synthesize openFileButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [thumbnailimageView release];
    [titleLabel release];
    [progressIndicatorView release];
    [openFileButton release];
    [super dealloc];
}

@end
