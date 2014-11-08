/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "NSString+MakeCamelCase.h"
#import "StandardKeySanitizer.h"

@implementation StandardKeySanitizer 

+ (StandardKeySanitizer*)keySanitizer
{
	return [[self alloc] init];
}

- (NSString*)sanitizeRemoteKey: (NSString*)remoteKey
{
	static NSDictionary* sanitizeKeys = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sanitizeKeys = @{ @"_id" : @"remoteId" };
	});
	
	NSString* sanitizedKey = [sanitizeKeys objectForKey: remoteKey];
	if (!sanitizedKey) {
		sanitizedKey = [remoteKey camelCased];
	}
	
	return sanitizedKey;
}

- (NSDictionary*)sanitizeRemoteKeys: (NSDictionary*)remoteKeys
{
	NSMutableDictionary* __block sanitizedData = [[NSMutableDictionary alloc] initWithCapacity: [remoteKeys count]];
	
	[remoteKeys enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
		[sanitizedData setObject: obj forKey: [self sanitizeRemoteKey: key]];
	}];
	
	return sanitizedData;
}

@end
