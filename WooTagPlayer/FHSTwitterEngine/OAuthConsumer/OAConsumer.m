/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "OAConsumer.h"

@implementation OAConsumer

+ (OAConsumer *)consumerWithKey:(NSString *)aKey secret:(NSString *)aSecret {
    return [[[[self class]alloc]initWithKey:aKey secret:aSecret]autorelease];
}

- (id)initWithKey:(NSString *)aKey secret:(NSString *)aSecret {
	if (self = [super init]) {
		self.key = aKey;
		self.secret = aSecret;
	}
	return self;
}

- (void)dealloc {
    [self setKey:nil];
    [self setSecret:nil];
	[super dealloc];
}

@end
