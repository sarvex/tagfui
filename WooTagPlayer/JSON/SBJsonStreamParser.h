/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>

@class SBJsonTokeniser;
@class SBJsonStreamParser;
@class SBJsonStreamParserState;

typedef enum {
	SBJsonStreamParserComplete,
	SBJsonStreamParserWaitingForData,
	SBJsonStreamParserError,
} SBJsonStreamParserStatus;


/**
 @brief Delegate for interacting directly with the stream parser
 
 You will most likely find it much more convenient to implement the
 SBJsonStreamParserAdapterDelegate protocol instead.
 */
@protocol SBJsonStreamParserDelegate

/// Called when object start is found
- (void)parserFoundObjectStart:(SBJsonStreamParser*)parser;

/// Called when object key is found
- (void)parser:(SBJsonStreamParser*)parser foundObjectKey:(NSString*)key;

/// Called when object end is found
- (void)parserFoundObjectEnd:(SBJsonStreamParser*)parser;

/// Called when array start is found
- (void)parserFoundArrayStart:(SBJsonStreamParser*)parser;

/// Called when array end is found
- (void)parserFoundArrayEnd:(SBJsonStreamParser*)parser;

/// Called when a boolean value is found
- (void)parser:(SBJsonStreamParser*)parser foundBoolean:(BOOL)x;

/// Called when a null value is found
- (void)parserFoundNull:(SBJsonStreamParser*)parser;

/// Called when a number is found
- (void)parser:(SBJsonStreamParser*)parser foundNumber:(NSNumber*)num;

/// Called when a string is found
- (void)parser:(SBJsonStreamParser*)parser foundString:(NSString*)string;

@end


/**
 @brief Parse a stream of JSON data.
 
 Using this class directly you can reduce the apparent latency for each
 download/parse cycle of documents over a slow connection. You can start
 parsing *and return chunks of the parsed document* before the entire
 document is downloaded.
 
 Using this class is also useful to parse huge documents on disk
 bit by bit so you don't have to keep them all in memory. 
 
 @see SBJsonStreamParserAdapter for more information.
 
 @see @ref objc2json
 
 */
@interface SBJsonStreamParser : NSObject {
@private
	SBJsonTokeniser *tokeniser;
    NSString *error_;
}

@property (nonatomic, unsafe_unretained) SBJsonStreamParserState *state; // Private
@property (nonatomic, readonly, strong) NSMutableArray *stateStack; // Private

/**
 @brief Expect multiple documents separated by whitespace

 Normally the @p -parse: method returns SBJsonStreamParserComplete when it's found a complete JSON document.
 Attempting to parse any more data at that point is considered an error. ("Garbage after JSON".)
 
 If you set this property to true the parser will never return SBJsonStreamParserComplete. Rather,
 once an object is completed it will expect another object to immediately follow, separated
 only by (optional) whitespace.

 @see The TweetStream app in the Examples
 */
@property BOOL supportMultipleDocuments;

/**
 @brief Delegate to receive messages

 The object set here receives a series of messages as the parser breaks down the JSON stream
 into valid tokens.

 @note
 Usually this should be an instance of SBJsonStreamParserAdapter, but you can
 substitute your own implementation of the SBJsonStreamParserDelegate protocol if you need to. 
 */
@property (unsafe_unretained) id<SBJsonStreamParserDelegate> delegate;

/**
 @brief The max parse depth
 
 If the input is nested deeper than this the parser will halt parsing and return an error.

 Defaults to 32. 
 */
@property NSUInteger maxDepth;

/// Holds the error after SBJsonStreamParserError was returned
@property (nonatomic,strong) NSString *error;

/**
 @brief Parse some JSON
 
 The JSON is assumed to be UTF8 encoded. This can be a full JSON document, or a part of one.

 @param data An NSData object containing the next chunk of JSON

 @return 
 @li SBJsonStreamParserComplete if a full document was found
 @li SBJsonStreamParserWaitingForData if a partial document was found and more data is required to complete it
 @li SBJsonStreamParserError if an error occured. (See the error property for details in this case.)
 
 */
- (SBJsonStreamParserStatus)parse:(NSData*)data;

@end
