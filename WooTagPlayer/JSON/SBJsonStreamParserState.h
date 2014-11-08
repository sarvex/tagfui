/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>

#import "SBJsonTokeniser.h"
#import "SBJsonStreamParser.h"

@interface SBJsonStreamParserState : NSObject
+ (id)sharedInstance;

- (BOOL)parser:(SBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token;
- (SBJsonStreamParserStatus)parserShouldReturn:(SBJsonStreamParser*)parser;
- (void)parser:(SBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok;
- (BOOL)needKey;
- (BOOL)isError;

- (NSString*)name;

@end

@interface SBJsonStreamParserStateStart : SBJsonStreamParserState
@end

@interface SBJsonStreamParserStateComplete : SBJsonStreamParserState
@end

@interface SBJsonStreamParserStateError : SBJsonStreamParserState
@end


@interface SBJsonStreamParserStateObjectStart : SBJsonStreamParserState
@end

@interface SBJsonStreamParserStateObjectGotKey : SBJsonStreamParserState
@end

@interface SBJsonStreamParserStateObjectSeparator : SBJsonStreamParserState
@end

@interface SBJsonStreamParserStateObjectGotValue : SBJsonStreamParserState
@end

@interface SBJsonStreamParserStateObjectNeedKey : SBJsonStreamParserState
@end

@interface SBJsonStreamParserStateArrayStart : SBJsonStreamParserState
@end

@interface SBJsonStreamParserStateArrayGotValue : SBJsonStreamParserState
@end

@interface SBJsonStreamParserStateArrayNeedValue : SBJsonStreamParserState
@end
