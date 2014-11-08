/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "OARequestParameter.h"


@implementation OARequestParameter

+ (id)requestParameterWithName:(NSString *)aName value:(NSString *)aValue {
	return [[[[self class]alloc]initWithName:aName value:aValue]autorelease];
}

- (id)initWithName:(NSString *)aName value:(NSString *)aValue {
    if (self = [super init]) {
		self.name = aName;
		self.value = aValue;
	}
    return self;
}

- (NSString *)URLEncodedName {
	return [self.name URLEncodedString];
}

- (NSString *)URLEncodedValue {
    return [self.value URLEncodedString];
}

- (NSString *)URLEncodedNameValuePair {
    return [NSString stringWithFormat:@"%@=%@", [self URLEncodedName], [self URLEncodedValue]];
}

- (void)dealloc {
    [self setName:nil];
    [self setValue:nil];
	[super dealloc];
}

@end
