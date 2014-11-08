/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>

@interface URLConnection : NSURLConnection 
{
	NSString *tagInfo;
	NSHTTPURLResponse* response;
	NSMutableData* responseData;
	NSMutableDictionary * userInfo;
}
@property (nonatomic,strong) NSString *tagInfo;
@property (nonatomic,strong) NSMutableDictionary * userInfo;
@property (nonatomic,strong) NSHTTPURLResponse* response;
@property (nonatomic,strong) NSMutableData* responseData;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate andtag:(NSString*) tag;
@end