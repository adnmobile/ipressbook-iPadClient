//
//  MMURLConnection.h
//  DirectStar
//
//  Created by Guillaume Cerquant on 11/08/10.
//  MacMation - http://www.macmation.com
//


#import <Foundation/Foundation.h>

// NSURLConnection that takes care of the data appending variable declaration for you


@interface MMURLConnection : NSURLConnection
{
@private
	NSMutableData *_responseData;
	id _userInfo;
}

@property (readonly) NSMutableData *responseData;
@property (readonly) id userInfo;

- initWithRequest:(NSURLRequest *)request
		 delegate:(id)delegate
		 userInfo:(id)userInfo;

@end
