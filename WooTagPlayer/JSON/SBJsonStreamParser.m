/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "SBJsonStreamParser.h"
#import "SBJsonTokeniser.h"
#import "SBJsonStreamParserState.h"
#import <limits.h>

@implementation SBJsonStreamParser

@synthesize supportMultipleDocuments;
@synthesize error = error_;
@synthesize delegate;
@synthesize maxDepth;
@synthesize state;
@synthesize stateStack;

#pragma mark Housekeeping

- (id)init {
	self = [super init];
	if (self) {
		maxDepth = 32u;
        stateStack = [[NSMutableArray alloc] initWithCapacity:maxDepth];
        state = [SBJsonStreamParserStateStart sharedInstance];
		tokeniser = [[SBJsonTokeniser alloc] init];
	}
	return self;
}

- (void)dealloc {
    self.state = nil;
}

#pragma mark Methods

- (NSString*)tokenName:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_array_start:
			return @"start of array";
			break;

		case sbjson_token_array_end:
			return @"end of array";
			break;

		case sbjson_token_number:
			return @"number";
			break;

		case sbjson_token_string:
			return @"string";
			break;

		case sbjson_token_true:
		case sbjson_token_false:
			return @"boolean";
			break;

		case sbjson_token_null:
			return @"null";
			break;

		case sbjson_token_keyval_separator:
			return @"key-value separator";
			break;

		case sbjson_token_separator:
			return @"value separator";
			break;

		case sbjson_token_object_start:
			return @"start of object";
			break;

		case sbjson_token_object_end:
			return @"end of object";
			break;

		case sbjson_token_eof:
		case sbjson_token_error:
			break;
	}
	NSAssert(NO, @"Should not get here");
	return @"<aaiiie!>";
}

- (void)maxDepthError {
    error_ = [NSString stringWithFormat:@"Input depth exceeds max depth of %lu", (unsigned long)maxDepth];
    self.state = [SBJsonStreamParserStateError sharedInstance];
}

- (void)handleObjectStart {
	if (stateStack.count >= maxDepth) {
        [self maxDepthError];
        return;
	}

    [delegate parserFoundObjectStart:self];
    [stateStack addObject:state];
    self.state = [SBJsonStreamParserStateObjectStart sharedInstance];
}

- (void)handleObjectEnd: (sbjson_token_t) tok  {
    self.state = [stateStack lastObject];
    [stateStack removeLastObject];
    [state parser:self shouldTransitionTo:tok];
    [delegate parserFoundObjectEnd:self];
}

- (void)handleArrayStart {
	if (stateStack.count >= maxDepth) {
        [self maxDepthError];
        return;
    }
	
	[delegate parserFoundArrayStart:self];
    [stateStack addObject:state];
    self.state = [SBJsonStreamParserStateArrayStart sharedInstance];
}

- (void)handleArrayEnd: (sbjson_token_t) tok  {
    self.state = [stateStack lastObject];
    [stateStack removeLastObject];
    [state parser:self shouldTransitionTo:tok];
    [delegate parserFoundArrayEnd:self];
}

- (void) handleTokenNotExpectedHere: (sbjson_token_t) tok  {
    NSString *tokenName = [self tokenName:tok];
    NSString *stateName = [state name];

    error_ = [NSString stringWithFormat:@"Token '%@' not expected %@", tokenName, stateName];
    self.state = [SBJsonStreamParserStateError sharedInstance];
}

- (SBJsonStreamParserStatus)parse:(NSData *)data_ {
    @autoreleasepool {
        [tokeniser appendData:data_];
        
        for (;;) {
            
            if ([state isError]){
                NSLog(@"parse error");
                return SBJsonStreamParserError;
            }
                
            
            NSObject *token;
            sbjson_token_t tok = [tokeniser getToken:&token];
            switch (tok) {
                case sbjson_token_eof:
                    return [state parserShouldReturn:self];
                    break;
                    
                case sbjson_token_error:
                    self.state = [SBJsonStreamParserStateError sharedInstance];
                    //self.error = tokeniser.error;
                    error_ = [[NSString alloc]initWithString:tokeniser.error];
                    return SBJsonStreamParserError;
                    break;
                    
                default:
                    
                    if (![state parser:self shouldAcceptToken:tok]) {
                        [self handleTokenNotExpectedHere: tok];
                        return SBJsonStreamParserError;
                    }
                    
                    switch (tok) {
                        case sbjson_token_object_start:
                            [self handleObjectStart];
                            break;
                            
                        case sbjson_token_object_end:
                            [self handleObjectEnd: tok];
                            break;
                            
                        case sbjson_token_array_start:
                            [self handleArrayStart];
                            break;
                            
                        case sbjson_token_array_end:
                            [self handleArrayEnd: tok];
                            break;
                            
                        case sbjson_token_separator:
                        case sbjson_token_keyval_separator:
                            [state parser:self shouldTransitionTo:tok];
                            break;
                            
                        case sbjson_token_true:
                            [delegate parser:self foundBoolean:YES];
                            [state parser:self shouldTransitionTo:tok];
                            break;
                            
                        case sbjson_token_false:
                            [delegate parser:self foundBoolean:NO];
                            [state parser:self shouldTransitionTo:tok];
                            break;
                            
                        case sbjson_token_null:
                            [delegate parserFoundNull:self];
                            [state parser:self shouldTransitionTo:tok];
                            break;
                            
                        case sbjson_token_number:
                            [delegate parser:self foundNumber:(NSNumber*)token];
                            [state parser:self shouldTransitionTo:tok];
                            break;
                            
                        case sbjson_token_string:
                            if ([state needKey])
                                [delegate parser:self foundObjectKey:(NSString*)token];
                            else
                                [delegate parser:self foundString:(NSString*)token];
                            [state parser:self shouldTransitionTo:tok];
                            break;
                            
                        default:
                            break;
                    }
                    break;
            }
        }
        NSLog(@"parsing completed withour any errors");
        return SBJsonStreamParserComplete;
    }
}

@end
