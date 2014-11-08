/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "URLConnection.h"

@implementation URLConnection

@synthesize tagInfo,response,responseData,userInfo;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate andtag:(NSString*) tag  
{
	NSAssert(self != nil, @"self is nil!");
	// Initialize the ivars before initializing with the request
    // because the connection is asynchronous and may start
    // calling the delegates before we even return from this
    // function.
	self.response = nil;
	self.responseData = nil;
	self.tagInfo = tag;
	self = [super initWithRequest:request delegate:delegate];
	
	
	//NSLog(@"REQUEST URL IS : %@",request.URL);
	
	return self;
}
@end