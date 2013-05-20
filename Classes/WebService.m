//
//  WebService.m
//  iPressbook
//
//  Created by Guillaume Cerquant on 05/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


// Presence of many mock-up methods (fakeFilesList...) is here because many server side API and content were not available while writing this code.

#import "MD5Utility.h"
#import "FilesListingViewController.h"
#import "IsoTonerAppDelegate.h"
#import "CJSONDeserializer.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "iPressBookFile.h"

#import "WebService.h"

NSString * const kFileListDidRefresh = @"fileListDidRefresh";



//NSString * const WEB_SERVICE_HOSTNAME   = @"http://ipressbook.iressources.com"; // Test server
NSString * const WEB_SERVICE_HOSTNAME   = @"http://ipressbook.com";              // Production server


NSString * const LOGIN_PAGE            = @"/login?email=%@&password=%@";
NSString * const LOGOUT_PAGE            = @"/logout";


NSString * const GET_FILES_PAGE            = @"/getFiles?tokenId=%@&categoryId=%d";

NSString * const MANAGE_ACCOUNT_PAGE        = @"/user/account_info";
NSString * const CREATE_ACCOUNT_PAGE        = @"/register";


// Credentials for demo account
/*
NSString * const kDemoLogin             = @"demo";
NSString * const kDemoPassword          = @"ipressbook";
*/
NSString * const kDemoLogin             = @"john@example.com";
NSString * const kDemoPassword          = @"1234";

// Preferences key (NSUserDefaults)

NSString * const kUserNamePref          = @"userName";
NSString * const kPrefTokenID          = @"tokenID";


@interface WebService ()

- (NSArray *) fakeFilesList;

- (void) setUserName:(NSString *) userName;


- (NSString *) pathOfSavedListOfFilesForCategory:(int) categoryIndex;
- (void) getListOfFiles;
- (void) getListOfFilesForCategoryWithIndex:(NSUInteger) indexOfCategory;
- (void) startDownloadOfFilesOutOfDateFromArray:(NSArray *) filesArray;

- (NSString *) webServiceTokenID;

- (void) loginDone:(ASIHTTPRequest *)request;
- (void) loginFailed:(ASIHTTPRequest *)request;

- (void) downloadListOfFileDone:(ASIHTTPRequest *) request;
- (void) downloadListOfFileFailed:(ASIHTTPRequest *) request;

- (void)requestForDownloadOfFileFinished:(ASIHTTPRequest *)request;
- (void)requestForDownloadOfFileFailed:(ASIHTTPRequest *)request;

@property (assign, readwrite) BOOL isConnected;
@property (retain) NSString *webServiceTokenID;


@property (retain, readwrite) ASINetworkQueue *filesToDownloadQueue;


@end

@implementation WebService


//@synthesize isConnected; // TODO: Update isConnected state
@synthesize filesToDownloadQueue;


- (BOOL) isConnected {
    return nil != [self webServiceTokenID];
}

- (void) postNotificationFileRefresh {
//    NSLog(@"posting a notification");
    [[NSNotificationCenter defaultCenter] postNotificationName:kFileListDidRefresh object:self];
}

- (void) loginWithUsername:(NSString *) username andPassword:(NSString *) password {
    
    [self setUserName:username];
    
    // Force a successful login
//    if (NO) {
//        NSLog(@"FORCING successful login");
//        [self.delegate loginSucceeded];
//        return;
//    }
    
//    NSLog(@"login request: %@", [WEB_SERVICE_HOSTNAME stringByAppendingString:[NSString stringWithFormat:LOGIN_PAGE, username, password]]);
    
    ASIHTTPRequest *theASIRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[WEB_SERVICE_HOSTNAME stringByAppendingString:[NSString stringWithFormat:LOGIN_PAGE, username, password]]]];
    
    [theASIRequest setDelegate:self];
    [theASIRequest setDidFinishSelector:@selector(loginDone:)];
    [theASIRequest setDidFailSelector:@selector(loginFailed:)];
    
    [theASIRequest startAsynchronous];
}

- (void) loginDone:(ASIHTTPRequest *)request {
    NSArray *resultArray = [[CJSONDeserializer deserializer] deserialize:[request responseData] error:nil];
    
    if ([resultArray count] > 0 && [[resultArray objectAtIndex:0] isKindOfClass:[NSString class]]) {
        
        [self setWebServiceTokenID:[resultArray objectAtIndex:0]];
        
        NSLog(@"token id: %@", [self webServiceTokenID]);
  
            [(IsoTonerAppDelegate *)([[UIApplication sharedApplication] delegate]) didLogin];
    } else {
        
        [self setWebServiceTokenID:nil];
        NSLog(@"Got a token that does not appear to be a valid token: %@", resultArray);
        [(IsoTonerAppDelegate *)([[UIApplication sharedApplication] delegate]) showLoginScreen];
    }
    
}

- (void) loginFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    NSLog(@"The error: %@", error);
    NSLog(@"Login failed - Will show login screen");
    [(IsoTonerAppDelegate *)([[UIApplication sharedApplication] delegate]) showLoginScreen];
}

- (void) startSyncing {
    [self getListOfFiles];
}


- (BOOL) isSyncing {
    NSLog(@"always syncing");
    
    return YES;
}

- (NSString *) userName {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kUserNamePref];
}

- (void) setUserName:(NSString *) userName {
    [[NSUserDefaults standardUserDefaults] setValue:userName forKey:kUserNamePref];
}


- (void) setWebServiceTokenID:(NSString *) tokenID {
//    NSLog(@"set to %@", tokenID);
    
    [[NSUserDefaults standardUserDefaults] setValue:tokenID forKey:kPrefTokenID];
}

- (NSString *) webServiceTokenID {
    
//    NSLog(@"returning %@", [[NSUserDefaults standardUserDefaults] stringForKey:kPrefTokenID]);
    return [[NSUserDefaults standardUserDefaults] stringForKey:kPrefTokenID];
}


- (void) getListOfFiles {
    for (int i = 1; i < 7; i++) {
        [self getListOfFilesForCategoryWithIndex:i];
    }
    
}

- (void) getListOfFilesForCategoryWithIndex:(NSUInteger) indexOfCategory {
    
//    NSLog(@"get files url request: %@", [WEB_SERVICE_HOSTNAME stringByAppendingString:[NSString stringWithFormat:GET_FILES_PAGE, [self webServiceTokenID], indexOfCategory]]);
    
    ASIHTTPRequest *theASIRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[WEB_SERVICE_HOSTNAME stringByAppendingString:[NSString stringWithFormat:GET_FILES_PAGE, [self webServiceTokenID], indexOfCategory]]]];


    [theASIRequest setDelegate:self];
    [theASIRequest setDidFinishSelector:@selector(downloadListOfFileDone:)];
    [theASIRequest setDidFailSelector:@selector(downloadListOfFileFailed:)];
    [theASIRequest setUserInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:indexOfCategory] forKey:@"categoryIndex"]];

    
    [theASIRequest startAsynchronous];
}

- (void) downloadListOfFileDone:(ASIHTTPRequest *) request {
    // TODO: Verify user status
    
    
    if ([request responseStatusCode] == 403) {
        NSLog(@"Got response status code 403 - logging out");
        [(IsoTonerAppDelegate *)([[UIApplication sharedApplication] delegate]) showLoginScreen];
        [self setWebServiceTokenID:nil];

        return;
    }
    
    NSArray *filesToDownloadArray = [[CJSONDeserializer deserializer] deserialize:[request responseData] error:nil];

    
    NSString *savedFilePath = [self pathOfSavedListOfFilesForCategory:[[[request userInfo] valueForKey:@"categoryIndex"] intValue]];
    if (nil != savedFilePath) {
        [NSKeyedArchiver archiveRootObject:filesToDownloadArray toFile:savedFilePath];
    }
    
    
    [self startDownloadOfFilesOutOfDateFromArray:filesToDownloadArray];
    
    [self postNotificationFileRefresh];
}





- (void) downloadListOfFileFailed:(ASIHTTPRequest *) request {
    NSLog(@"download list of file failed");
}

- (NSArray *) listOfFilesForCategory:(int) categoryIndex {
    NSString *savedFilePath = [self pathOfSavedListOfFilesForCategory:categoryIndex];
    
    if (nil != savedFilePath) {
        return [NSKeyedUnarchiver unarchiveObjectWithFile:savedFilePath];

    }

    return nil;
}


- (NSArray *) fakeFilesList {
    NSMutableArray *fakeFilesListArray = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < 75; i++) {
        NSDictionary *fakeFile = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:((! i % 3) ? @"Multi-line long name Fake File %d" : @"Fake File %d"), i], kFileNameKey, nil];
        
        [fakeFilesListArray addObject:fakeFile];
    }
    
    return fakeFilesListArray;
}



- (NSURL *) URLOfCreateAccountWebView {
    return [NSURL URLWithString:[WEB_SERVICE_HOSTNAME stringByAppendingString:CREATE_ACCOUNT_PAGE]];
}

- (NSURL *) URLOfManageAccountWebView {

    
    return [NSURL URLWithString:[WEB_SERVICE_HOSTNAME stringByAppendingString:MANAGE_ACCOUNT_PAGE]];
}


- (void) logMeOut {
    ASIHTTPRequest *theASIRequest = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:LOGOUT_PAGE]] autorelease];
    
    [theASIRequest startAsynchronous];
    
    [self setWebServiceTokenID:nil];
    
    NSLog(@"Logging out");
    
    [(IsoTonerAppDelegate *)([[UIApplication sharedApplication] delegate]) showLoginScreen];
}




- (NSString *) pathOfSavedListOfFilesForCategory:(int) categoryIndex {
    NSString *userName = [[[[WebService alloc] init] autorelease] userName];
    
    if (nil == userName || [userName isEqualToString:@""]) {
        return nil;
    }
    
    
    NSString *savedFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_category%d.plist", userName, categoryIndex]];
    
//        NSLog(@"saved file path: %@", savedFilePath);
    
    return savedFilePath;
}



- (void) startDownloadOfFilesOutOfDateFromArray:(NSArray *) filesArray {
    
    for (NSDictionary *fileInfo in filesArray) {
        iPressBookFile *aniPressBookFile = [[iPressBookFile alloc] initWithDictionary:fileInfo];
        
        
//        NSLog(@"will download file %@", aniPressBookFile.url);
        
        if (! aniPressBookFile.url) {
            NSLog(@"Empty url");
            [aniPressBookFile release];
            return;
        }
        
        NSURL *theURL = [NSURL URLWithString:aniPressBookFile.url];
        
        if (! theURL) {
            NSLog(@"invalid url");
            [aniPressBookFile release];
            return;
        }
        
        
        if (! [aniPressBookFile isLocalVersionUpToDate]) {
        
        
            ASIHTTPRequest *downloadAFileRequest = [ASIHTTPRequest requestWithURL:theURL];
            
            // careful with the path - space are not allowed ; currently forbidden at upload
            // Careful if more than 9 categories
            [downloadAFileRequest setDownloadDestinationPath:[aniPressBookFile localFilePath]];
            
            
            UIProgressView *theProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(82.0f, 34.0f, 218.0f, 9.0f)];
            
            [downloadAFileRequest setDownloadProgressDelegate:theProgressView];
            [downloadAFileRequest setDelegate:self];


            [downloadAFileRequest setUserInfo:
                [NSDictionary dictionaryWithObjectsAndKeys:aniPressBookFile, @"iPressBookFile",
                                                            theProgressView, @"progressView", nil]];
            [theProgressView release];

            [downloadAFileRequest setDidFinishSelector:@selector(requestForDownloadOfFileFinished:)];
            [downloadAFileRequest setDidFailSelector:@selector(requestForDownloadOfFileFailed:)];
            [downloadAFileRequest setShowAccurateProgress:YES];
            downloadAFileRequest.shouldContinueWhenAppEntersBackground = YES;


            
            if (![self filesToDownloadQueue]) {
                // Setting up the queue if needed
                [self setFilesToDownloadQueue:[[[/* NSOperationQueue */ ASINetworkQueue alloc] init] autorelease]];
                
                [self filesToDownloadQueue].delegate = self;
                [[self filesToDownloadQueue] setMaxConcurrentOperationCount:2];
                [[self filesToDownloadQueue] setShouldCancelAllRequestsOnFailure:NO]; 
                [[self filesToDownloadQueue] setShowAccurateProgress:YES]; 
                
            }
            
            [[self filesToDownloadQueue] addOperation:downloadAFileRequest]; //queue is an NSOperationQueue

        }        

        
        
        [aniPressBookFile release];
    }
    [[self filesToDownloadQueue] go];
}



//- (void) downloadFileAtURL:(NSString *) theURLString ifDifferentFromMD5:(NSString *) md5 {
//    
//    
//    //    NSLog(@"md5 SERVER: %@", md5);
//    //    NSLog(@"md5 local: %@", [[[[MD5Utility alloc] init] autorelease] md5OfFileAtPath:[self localFilePathForURL:theURLString]]);
//    //    NSLog(@"local: %@", [self localFilePathForURL:theURLString]);
//    
//    NSLog(@"will compare md5:\n%@\nvs\n%@", md5, [[NSUserDefaults standardUserDefaults] valueForKey:theURLString]);
//    
//    //    if ([md5 isEqualToString:[[[[MD5Utility alloc] init] autorelease] md5OfFileAtPath:[self localFilePathForURL:theURLString]]]) {
//    if ([md5 isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:theURLString]]) {
//        [thumbnailView.progressIndicatorView setHidden:YES];
//        
//        [thumbnailView.openFileButton setUserInteractionEnabled:YES];
//        
//        return;
//    } 
//    
//    //    else {
//    //        [thumbnailView.progressIndicatorView setHidden:NO];
//    //        thumbnailView.progressIndicatorView.progress = 0.0f;
//    //
//    //        return;
//    //    }
//    
//    
//    NSLog(@"did compare md5");
//    
//    
//    //    NSLog(@"FINISHED");
//    
//    //    [request startAsynchronous];
//    
//}





#pragma mark ASIHTTPREquest delegate

- (void)requestForDownloadOfFileFinished:(ASIHTTPRequest *)request {
//    [[request downloadProgressDelegate] setHidden:YES];
//    
//    GenericFileThumbnailView *thumbnailView = [[request userInfo] valueForKey:@"myThumbnailView"];
//    
//    NSAssert([thumbnailView isKindOfClass:[GenericFileThumbnailView class]], @"unexpected userInfo class");
//    
//    [[thumbnailView openFileButton] setUserInteractionEnabled:YES];
//    thumbnailView.titleLabel.textColor = [UIColor whiteColor];

    iPressBookFile *myIPressBookFile = [[request userInfo] valueForKey:@"iPressBookFile"];
    
    NSAssert([myIPressBookFile isKindOfClass:[iPressBookFile class]], @"Unexpected class");
    
    [myIPressBookFile calculateVerifyAndSaveMD5ToCache];

    
    [self postNotificationFileRefresh];
    
//    NSLog(@"url of dl: %@", [request.url absoluteString]);
    
}

- (void)requestForDownloadOfFileFailed:(ASIHTTPRequest *)request
{
    [self postNotificationFileRefresh];
    
    NSLog(@"Download file request failed: %@", [request error]);
}




@end
