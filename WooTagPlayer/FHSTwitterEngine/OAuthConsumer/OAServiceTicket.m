/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "OAServiceTicket.h"


@implementation OAServiceTicket

- (id)initWithRequest:(OAMutableURLRequest *)aRequest response:(NSURLResponse *)aResponse didSucceed:(BOOL)success {
    if (self = [super init]) {
		self.request = aRequest;
		self.response = aResponse;
		self.didSucceed = success;
	}
    return self;
}

- (void)dealloc {
    [self setRequest:nil];
    [self setResponse:nil];
	[super dealloc];
}

@end
