//
//  iPressBookFile.h
//  iPressbook
//
//  Created by Guillaume Cerquant on 30/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iPressBookFile : NSObject {
    @private
    
}

@property (retain) NSString     *url;
@property (retain) NSString     *urlOfThumbnail;
@property (retain, readonly) NSString   *fileName;
- (NSString *)localFilePath;


+ (NSString *) localFilePathForURL:(NSString *) theURLString;

- (id) initWithDictionary:(NSDictionary *) theDictionary;

- (BOOL) isLocalVersionUpToDate;
//- (NSString *) thumbnailImageURL;
- (NSString *) defaultThumbnailImageName;

- (BOOL) hasBeenDownloaded;

- (void) calculateVerifyAndSaveMD5ToCache;

@end
