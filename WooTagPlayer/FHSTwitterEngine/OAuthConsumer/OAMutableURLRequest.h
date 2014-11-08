/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>
#import "OAConsumer.h"
#import "OAToken.h"
#import "OAHMAC_SHA1SignatureProvider.h"

@class OAServiceTicket;

@interface OAMutableURLRequest : NSMutableURLRequest

@property (nonatomic, assign) NSString *signature;
@property (nonatomic, assign) NSString *nonce;
@property (nonatomic, assign) NSString *timestamp;

+ (void)fetchDataForRequest:(OAMutableURLRequest *)request withCompletionHandler:(void(^)(OAServiceTicket *, NSData *, NSError *))block;

+ (OAMutableURLRequest *)requestWithURL:(NSURL *)aUrl consumer:(OAConsumer *)aConsumer token:(OAToken *)aToken realm:(NSString *)aRealm signatureProvider:(id<OASignatureProviding, NSObject>)aProvider;

+ (OAMutableURLRequest *)requestWithURL:(NSURL *)aUrl consumer:(OAConsumer *)aConsumer token:(OAToken *)aToken;

- (id)initWithURL:(NSURL *)aUrl consumer:(OAConsumer *)aConsumer token:(OAToken *)aToken realm:(NSString *)aRealm signatureProvider:(id<OASignatureProviding, NSObject>)aProvider;

- (id)initWithURL:(NSURL *)aUrl consumer:(OAConsumer *)aConsumer token:(OAToken *)aToken realm:(NSString *)aRealm signatureProvider:(id<OASignatureProviding, NSObject>)aProvider nonce:(NSString *)aNonce timestamp:(NSString *)aTimestamp;

- (void)prepare;
- (void)setOAuthParameterName:(NSString*)parameterName withValue:(NSString*)parameterValue;
- (NSArray *)parameters;
- (void)setParameters:(NSArray *)parameters;

@end
