//
//  WebService.h
//  iPressbook
//
//  Created by Guillaume Cerquant on 05/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

extern NSString * const kDemoLogin;
extern NSString * const kDemoPassword;

extern NSString * const WEB_SERVICE_HOSTNAME;


extern NSString * const kFileListDidRefresh;



@interface WebService : NSObject <ASIHTTPRequestDelegate> {
    
    ASINetworkQueue *filesToDownloadQueue;

}


@property (retain, readonly) ASINetworkQueue *filesToDownloadQueue;
@property (assign, readonly) BOOL isConnected;


- (void) loginWithUsername:(NSString *) username andPassword:(NSString *) password;
- (void) logMeOut;

- (NSString *) userName;


- (NSURL *) URLOfCreateAccountWebView;
- (NSURL *) URLOfManageAccountWebView;


- (void) startSyncing;
- (BOOL) isSyncing;

- (NSArray *) listOfFilesForCategory:(int) categoryIndex;


@end

