/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/NSString.h>


@interface Base64 : NSObject {
    
}

+ (NSString *) encodeBase64WithData:(NSData *)data;
+ (NSData *)decodeBase64WithString:(NSString *)strBase64;
@end
