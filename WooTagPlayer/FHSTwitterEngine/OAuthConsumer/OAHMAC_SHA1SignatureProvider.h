/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>

@protocol OASignatureProviding <NSObject>
- (NSString *)name;
- (NSString *)signClearText:(NSString *)text withSecret:(NSString *)secret;
@end

@interface OAHMAC_SHA1SignatureProvider : NSObject <OASignatureProviding>

+ (OAHMAC_SHA1SignatureProvider *)OAHMAC_SHA1SignatureProvider;

@end
