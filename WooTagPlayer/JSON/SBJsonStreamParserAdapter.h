/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>
#import "SBJsonStreamParser.h"

typedef enum {
	SBJsonStreamParserAdapterNone,
	SBJsonStreamParserAdapterArray,
	SBJsonStreamParserAdapterObject,
} SBJsonStreamParserAdapterType;

/**
 @brief Delegate for getting objects & arrays from the stream parser adapter
 
 @see The TweetStream example project.
 */
@protocol SBJsonStreamParserAdapterDelegate

/**
 @brief Called if a JSON array is found
 
 This method is called if a JSON array is found.
 
 */
- (void)parser:(SBJsonStreamParser*)parser foundArray:(NSArray*)array;

/**
 @brief Called when a JSON object is found

 This method is called if a JSON object is found.
 */
- (void)parser:(SBJsonStreamParser*)parser foundObject:(NSDictionary*)dict;

@end

/**
 @brief SBJsonStreamParserDelegate protocol adapter
 
 Rather than implementing the SBJsonStreamParserDelegate protocol yourself you will
 most likely find it much more convenient to use an instance of this class and
 implement the SBJsonStreamParserAdapterDelegate protocol instead.
 
 The default behaviour is that the delegate only receives one call from
 either the -parser:foundArray: or -parser:foundObject: method when the
 document is fully parsed. However, if your inputs contains multiple JSON
 documents and you set the parser's -supportMultipleDocuments property to YES
 you will get one call for each full method.
 
 @code
 SBJsonStreamParserAdapter *adapter = [[[SBJsonStreamParserAdapter alloc] init] autorelease];
 adapter.delegate = self;
 
 SBJsonStreamParser *parser = [[[SBJsonStreamParser alloc] init] autorelease];
 parser.delegate = adapter;
 parser.supportMultipleDocuments = YES;

 // Note that this input contains multiple top-level JSON documents
 NSData *json = [@"[]{}[]{}" dataWithEncoding:NSUTF8StringEncoding]; 
 [parser parse:data];
 @endcode
 
 In the above example @p self will have the following sequence of methods called on it:
 
 @li -parser:foundArray:
 @li -parser:foundObject:
 @li -parser:foundArray:
 @li -parser:foundObject:

 Often you won't have control over the input you're parsing, so can't make use of
 this feature. But, all is not lost: this class will let you get the same effect by 
 allowing you to skip one or more of the outer enclosing objects. Thus, the next
 example results in the same sequence of -parser:foundArray: / -parser:foundObject:
 being called on your delegate.
 
 @code
 SBJsonStreamParserAdapter *adapter = [[[SBJsonStreamParserAdapter alloc] init] autorelease];
 adapter.delegate = self;
 adapter.levelsToSkip = 1;
 
 SBJsonStreamParser *parser = [[[SBJsonStreamParser alloc] init] autorelease];
 parser.delegate = adapter;
 
 // Note that this input contains A SINGLE top-level document
 NSData *json = [@"[[],{},[],{}]" dataWithEncoding:NSUTF8StringEncoding]; 
 [parser parse:data];
 @endcode
 
*/
@interface SBJsonStreamParserAdapter : NSObject <SBJsonStreamParserDelegate> {
@private
	NSUInteger depth;
    NSMutableArray *array;
	NSMutableDictionary *dict;
	NSMutableArray *keyStack;
	NSMutableArray *stack;
	
	SBJsonStreamParserAdapterType currentType;
}

/**
 @brief How many levels to skip
 
 This is useful for parsing huge JSON documents, or documents coming in over a very slow link.
 
 If you set this to N it will skip the outer N levels and call the -parser:foundArray:
 or -parser:foundObject: methods for each of the inner objects, as appropriate.
 
 @see The StreamParserIntegrationTest.m file for examples
*/
@property NSUInteger levelsToSkip;

/**
 @brief Your delegate object
 Set this to the object you want to receive the SBJsonStreamParserAdapterDelegate messages.
 */
@property (unsafe_unretained) id<SBJsonStreamParserAdapterDelegate> delegate;

@end
