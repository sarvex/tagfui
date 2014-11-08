/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>

@interface OAToken : NSObject

@property (nonatomic, retain) NSString *verifier;
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *secret;

- (NSString *)pin;
- (void)setPin:(NSString *)aPin;

- (id)initWithKey:(NSString *)aKey secret:(NSString *)aSecret;
- (id)initWithUserDefaultsUsingServiceProviderName:(NSString *)provider prefix:(NSString *)prefix;
- (id)initWithHTTPResponseBody:(NSString *)body;

+ (OAToken *)token;
+ (OAToken *)tokenWithKey:(NSString *)aKey secret:(NSString *)aSecret;
+ (OAToken *)tokenWithHTTPResponseBody:(NSString *)body;
+ (OAToken *)tokenWithUserDefaultsUsingServiceProviderName:(NSString *)provider prefix:(NSString *)prefix;

- (void)storeInUserDefaultsWithServiceProviderName:(NSString *)provider prefix:(NSString *)prefix;

@end
