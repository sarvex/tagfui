/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */
#import <Foundation/Foundation.h>

@interface Base64Converter : NSObject {

}

+ (void) initialize;
+ (NSString*) encodeString:(NSString *) plainText;
+ (NSString*) encode:(const uint8_t*) input length:(NSInteger) length;
+ (NSString*) encode:(NSData*) rawBytes;

+ (NSString*) decodedString:(NSString *) base64String;
+ (NSData*) decode:(const char*) string length:(NSInteger) inputLength;
+ (NSData*) decode:(NSString*) string;
@end