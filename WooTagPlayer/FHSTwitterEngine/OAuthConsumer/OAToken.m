/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "OAToken.h"

@implementation OAToken

+ (OAToken *)token {
    return [[[[self class]alloc]init]autorelease];
}

+ (OAToken *)tokenWithKey:(NSString *)aKey secret:(NSString *)aSecret {
    return [[[[self class]alloc]initWithKey:aKey secret:aSecret]autorelease];
}

+ (OAToken *)tokenWithHTTPResponseBody:(NSString *)body {
    return [[[[self class]alloc]initWithHTTPResponseBody:body]autorelease];
}

+ (OAToken *)tokenWithUserDefaultsUsingServiceProviderName:(NSString *)provider prefix:(NSString *)prefix {
    return [[[[self class]alloc]initWithUserDefaultsUsingServiceProviderName:provider prefix:prefix]autorelease];
}

- (NSString *)pin {
    return self.verifier;
}

- (void)setPin:(NSString *)aPin {
    [self setVerifier:aPin];
}

- (id)init {
	if (self = [super init]) {
		self.key = @"";
		self.secret = @"";
		self.verifier = @"";
	}
    return self;
}

- (id)initWithKey:(NSString *)aKey secret:(NSString *)aSecret  {
	if (self = [super init]) {
		self.key = aKey;
		self.secret = aSecret;
        self.verifier = @"";
	}
	return self;
}

- (id)initWithHTTPResponseBody:(NSString *)body {
	if (self = [super init]) {
        
        if (body == nil) {
            body = @"";
        }
    
		NSArray *pairs = [body componentsSeparatedByString:@"&"];
		
		for (NSString *pair in pairs) {
			NSArray *elements = [pair componentsSeparatedByString:@"="];
			if ([[elements objectAtIndex:0] isEqualToString:@"oauth_token"]) {
				self.key = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			} else if ([[elements objectAtIndex:0] isEqualToString:@"oauth_token_secret"]) {
				self.secret = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			}
		}
        self.verifier = @"";
	}
    
    return self;
}

- (id)initWithUserDefaultsUsingServiceProviderName:(NSString *)provider prefix:(NSString *)prefix {
    self = [super init];
	if (self) {
		NSString *theKey = [[NSUserDefaults standardUserDefaults]stringForKey:[NSString stringWithFormat:@"OAUTH_%@_%@_KEY", prefix, provider]];
		NSString *theSecret = [[NSUserDefaults standardUserDefaults]stringForKey:[NSString stringWithFormat:@"OAUTH_%@_%@_SECRET", prefix, provider]];
        
        BOOL nokey = (theKey.length == 0);
        BOOL nosecret = (theSecret.length == 0);
        
        if ((nokey && nosecret) || (nokey || nosecret)) {
            return nil;
        }
        
		self.key = theKey;
		self.secret = theSecret;
        self.verifier = @"";
	}
	return self;
}

- (void)dealloc {
    [self setVerifier:nil];
    [self setKey:nil];
    [self setSecret:nil];
	[super dealloc];
}

- (void)storeInUserDefaultsWithServiceProviderName:(NSString *)provider prefix:(NSString *)prefix {
	[[NSUserDefaults standardUserDefaults]setObject:self.key forKey:[NSString stringWithFormat:@"OAUTH_%@_%@_KEY", prefix, provider]];
	[[NSUserDefaults standardUserDefaults]setObject:self.secret forKey:[NSString stringWithFormat:@"OAUTH_%@_%@_SECRET", prefix, provider]];
	[[NSUserDefaults standardUserDefaults]synchronize];
}

@end
