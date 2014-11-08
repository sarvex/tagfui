/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>

@interface OAConsumer : NSObject

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *secret;

- (id)initWithKey:(NSString *)aKey secret:(NSString *)aSecret;

+ (OAConsumer *)consumerWithKey:(NSString *)aKey secret:(NSString *)aSecret;

@end
