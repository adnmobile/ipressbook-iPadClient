//
//  iPressBookFile.m
//  iPressbook
//
//  Created by Guillaume Cerquant on 30/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MD5Utility.h"

#import "iPressBookFile.h"

NSString * const kURLThumbnailKey   =  @"urlThumbnail";
NSString * const kURLKey            =  @"url";
NSString * const kFileNameKey       = @"fileName";
NSString * const kMD5Key            = @"MD5";


@interface iPressBookFile ()

@property (retain, readwrite) NSString   *fileName;
@property (retain) NSString *remoteMD5;




- (NSString *) cachedMD5;
- (NSString *) defaultImageNameForFileName:(NSString *) fileName;



@end

@implementation iPressBookFile


@synthesize url;
@synthesize urlOfThumbnail;
@synthesize fileName;
@synthesize remoteMD5;


+ (NSString *) localFilePathForURL:(NSString *) theURLString {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[theURLString lastPathComponent]];
}

- (id) initWithDictionary:(NSDictionary *) theDictionary
{
    self = [super init];
    if (self) {
        self.urlOfThumbnail = [theDictionary valueForKey:kURLThumbnailKey];
        self.url = [theDictionary valueForKey:kURLKey];
        self.fileName = [theDictionary valueForKey:kFileNameKey];
        self.remoteMD5 = [theDictionary valueForKey:kMD5Key];
    }
    
    return self;
}

- (NSString *) cachedMD5 {
    return [[NSUserDefaults standardUserDefaults] valueForKey:self.url];
}

- (BOOL) isLocalVersionUpToDate {
    return ([self.remoteMD5 isEqualToString:[self cachedMD5]]);
}


- (NSString *) defaultThumbnailImageName {
    return [self defaultImageNameForFileName:self.fileName];
}


- (NSString *) defaultImageNameForFileName:(NSString *) theFileName {
    
    NSString *formattedName = @"default-%@.png";
    
    
    NSString *extension = [[theFileName pathExtension] lowercaseString];
    
    if ([[NSArray arrayWithObjects:@"png", @"jpg", @"jpeg", nil] containsObject:extension]) {
        return [NSString stringWithFormat:formattedName, @"image"];
    }
    
    
    if ([[NSArray arrayWithObjects:@"m4v", @"mov", nil] containsObject:extension]) {
        return [NSString stringWithFormat:formattedName, @"video"];
    }
    
    if ([[NSArray arrayWithObjects:@"xls", @"xlsx", nil] containsObject:extension]) {
        return [NSString stringWithFormat:formattedName, @"excel"];
    }
    
    if ([[NSArray arrayWithObjects:@"doc", @"docx", nil] containsObject:extension]) {
        return [NSString stringWithFormat:formattedName, @"word"];
    }
    
    if ([[NSArray arrayWithObjects:@"ppt", @"pptx", nil] containsObject:extension]) {
        return [NSString stringWithFormat:formattedName, @"powerpoint"];
    }
    
    if ([[NSArray arrayWithObjects:@"keynote", nil] containsObject:extension]) {
        return [NSString stringWithFormat:formattedName, @"keynote"];
    }
    
    if ([[NSArray arrayWithObjects:@"numbers", nil] containsObject:extension]) {
        return [NSString stringWithFormat:formattedName, @"numbers"];
    }
    
    if ([[NSArray arrayWithObjects:@"pages", nil] containsObject:extension]) {
        return [NSString stringWithFormat:formattedName, @"pages"];
    }
    
    if ([[NSArray arrayWithObjects:@"pdf", nil] containsObject:extension]) {
        return [NSString stringWithFormat:formattedName, @"pdf"];
    }
    return @"default-unknown.png";
}

- (NSString *)localFilePath {
    return [iPressBookFile localFilePathForURL:self.url];
}

- (BOOL) hasBeenDownloaded {
//    NSLog(@"does exists at path: %@ => %d", [self localFilePath], [[NSFileManager defaultManager] fileExistsAtPath:[self localFilePath]]);
    
    return [[NSFileManager defaultManager] fileExistsAtPath:[self localFilePath]]
            && nil != [[NSUserDefaults standardUserDefaults] valueForKey:self.url] ;;
}

- (void) calculateVerifyAndSaveMD5ToCache {
    NSString *md5OfDownloadedFile = [[[[MD5Utility alloc] init] autorelease] md5OfFileAtPath:[iPressBookFile localFilePathForURL:self.url]];
    
    
    if ([md5OfDownloadedFile isEqualToString:[self remoteMD5]]) {
        [[NSUserDefaults standardUserDefaults] setValue:md5OfDownloadedFile forKey:self.url];
    } else {
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:self.url];

        NSLog(@"File %@: Md5 received is invalid\n%@", self.fileName, self.url);
        
        NSLog(@"calculated md5: %@", md5OfDownloadedFile);
        NSLog(@"sent       md5: %@", [self remoteMD5]);

    }

}

@end
