//
//  MD5Utility.h
//  iPressbook
//
//  Created by Guillaume Cerquant on 07/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MD5Utility : NSObject {
    
}

- (NSString *)md5OfFileAtPath:(NSString *) filePath;
    
@end
