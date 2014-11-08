/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>

@interface NetworkConnection : NSObject {
    
    int currentStatusCode;
    NSData *lastResponse;
    int networkStatusCode;
}

- (NSData *)createNetworkConnection:(NSString *)url WithBody:(NSString *)body WithHTTPMethod:(NSString *) httpMethod timeOutInterVal:(NSInteger)timeInterval;

-(NSString *) returnError:(id)caller withObject: (NSDictionary*)responseDict;
-(NSString *) returnError:(id)caller withObject: (NSDictionary*)responseMap withUrl:(NSString *)urlString ;

@end
