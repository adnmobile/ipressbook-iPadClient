//
//  MMURLConnection.h
//  DirectStar
//
//  Created by Guillaume Cerquant on 11/08/10.
//  MacMation - http://www.macmation.com
//


#import "MMURLConnection.h"


@implementation MMURLConnection

- initWithRequest:(NSURLRequest *)request
		 delegate:(id)delegate
		 userInfo:(id)userInfo
{
	if (self = [super initWithRequest:request delegate:delegate])
	{
		_responseData = [[NSMutableData alloc] init];
		_userInfo = [userInfo retain];
	}
	return self;
}

- (void)dealloc
{
	[_userInfo release];
	[_responseData release];
	[super dealloc];
}

- (NSMutableData *)responseData { return _responseData; }

- (id)userInfo { return _userInfo; }


@end
