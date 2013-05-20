//
//  GenericFileThumbnailView.h
//  iPressbook
//
//  Created by Guillaume Cerquant on 05/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GenericFileThumbnailView : UIView {
    
    UIImageView *thumbnailimageView;
    UILabel *titleLabel;
    UIProgressView *progressIndicatorView;
    UIButton *openFileButton;
}
@property (nonatomic, retain) IBOutlet UIImageView *thumbnailimageView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;


@property (nonatomic, retain) IBOutlet UIProgressView *progressIndicatorView;
@property (nonatomic, retain) IBOutlet UIButton *openFileButton;

@end
