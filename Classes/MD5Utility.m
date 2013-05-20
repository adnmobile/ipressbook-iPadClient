//
//  MD5Utility.m
//  iPressbook
//
//  Created by Guillaume Cerquant on 07/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MD5Utility.h"


#include <CommonCrypto/CommonDigest.h>

@implementation MD5Utility

#pragma mark MD5_CHECKSUM

#define CC_MD5_DIGEST_LENGTH 16
#define MD5_DIGEST_LENGTH 16
- (NSString *)md5OfFileAtPath:(NSString *) filePath {
	NSData *fileData;
	NSString *computedMD5Checksum = nil;
	NSMutableData *digest;
    
 	fileData = [[NSData alloc] initWithContentsOfFile:filePath];
	if (nil == fileData) {
		NSLog(@"File data should not be nil");
		return nil;
	}
	
	
	digest = [NSMutableData dataWithLength:MD5_DIGEST_LENGTH];
	if (digest && CC_MD5([fileData bytes], [fileData length], [digest mutableBytes])) {
		computedMD5Checksum = [[[digest description] stringByReplacingOccurrencesOfString:@" " withString:@""] 
                               stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	} else {
		NSLog(@"Couldn't compute MD5 of downloaded database");
	}
	
	[fileData release];
	
	return computedMD5Checksum;
}

// NOT YET USED

//- (BOOL)isChecksumOfFileDownloadedAtPathOk:(NSString *) tempFilePath {
//	NSString *computedMD5Checksum;
//	BOOL res;
//	
//	computedMD5Checksum = [self md5OfFileAtPath:tempFilePath];
//	
//	if (nil == computedMD5Checksum) {
//		return NO;
//	}
//	
//	
//	res = [computedMD5Checksum isEqualToString:[self onlineMd5Checksum]];
//	// [self setOnlineMd5Checksum:nil];
//	
//	return res;
//}

@end
