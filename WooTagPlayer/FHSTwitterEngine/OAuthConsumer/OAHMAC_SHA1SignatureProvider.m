/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "OAHMAC_SHA1SignatureProvider.h"
#import <CommonCrypto/CommonHMAC.h>
#include "Base64TranscoderFHS.h"

@implementation OAHMAC_SHA1SignatureProvider

+ (OAHMAC_SHA1SignatureProvider *)OAHMAC_SHA1SignatureProvider {
    return [[[[self class]alloc]init]autorelease];
}

- (NSString *)name {
    return @"HMAC-SHA1";
}

- (NSString *)signClearText:(NSString *)text withSecret:(NSString *)secret {
    
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[20];
	CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], result);
    
    // Base64 Encoding
    
    char base64Result[32];
    size_t theResultLength = 32;
    Base64EncodeDataFHS(result, 20, base64Result, &theResultLength);
    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
    
    NSString *base64EncodedResult = [[NSString alloc]initWithData:theData encoding:NSUTF8StringEncoding];
    
    return [base64EncodedResult autorelease];
}

@end
