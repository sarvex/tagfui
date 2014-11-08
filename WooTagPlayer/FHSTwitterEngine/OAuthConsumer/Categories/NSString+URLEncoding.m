/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */


#import "NSString+URLEncoding.h"

@implementation NSString (OAURLEncodingAdditions)

- (NSString *)URLEncodedString {
    CFStringRef url = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8); // for some reason, releasing this is disasterous
    NSString *result = (NSString *)url;
    [result autorelease];
	return result;
}

- (NSString *)URLDecodedString {
    CFStringRef url = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8);
	NSString *result = (NSString *)url;
	[result autorelease];
    return result;
}

@end
