/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>
#import "OAMutableURLRequest.h"


@interface OAServiceTicket : NSObject

@property (nonatomic, retain) OAMutableURLRequest *request;
@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic, assign) BOOL didSucceed;

- (id)initWithRequest:(OAMutableURLRequest *)aRequest response:(NSURLResponse *)aResponse didSucceed:(BOOL)success;

@end
