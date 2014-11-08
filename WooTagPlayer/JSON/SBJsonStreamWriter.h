/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>

/// Enable JSON writing for non-native objects
@interface NSObject (SBProxyForJson)

/**
 @brief Allows generation of JSON for otherwise unsupported classes.
 
 If you have a custom class that you want to create a JSON representation
 for you can implement this method in your class. It should return a
 representation of your object defined in terms of objects that can be
 translated into JSON. For example, a Person object might implement it like this:
 
 @code
 - (id)proxyForJson {
	return [NSDictionary dictionaryWithObjectsAndKeys:
	name, @"name",
	phone, @"phone",
	email, @"email",
	nil];
 }
 @endcode
 
 */
- (id)proxyForJson;

@end

@class SBJsonStreamWriter;

@protocol SBJsonStreamWriterDelegate

- (void)writer:(SBJsonStreamWriter*)writer appendBytes:(const void *)bytes length:(NSUInteger)length;

@end

@class SBJsonStreamWriterState;

/**
 @brief The Stream Writer class.
 
 Accepts a stream of messages and writes JSON of these to its delegate object.
 
 This class provides a range of high-, mid- and low-level methods. You can mix
 and match calls to these. For example, you may want to call -writeArrayOpen
 to start an array and then repeatedly call -writeObject: with various objects
 before finishing off with a -writeArrayClose call.
  
 @see @ref json2objc

 */

@interface SBJsonStreamWriter : NSObject {
    NSMutableDictionary *cache;
}

@property (nonatomic, unsafe_unretained) SBJsonStreamWriterState *state; // Internal
@property (nonatomic, readonly, strong) NSMutableArray *stateStack; // Internal 

/**
 @brief delegate to receive JSON output
 Delegate that will receive messages with output.
 */
@property (unsafe_unretained) id<SBJsonStreamWriterDelegate> delegate;

/**
 @brief The maximum recursing depth.
 
 Defaults to 512. If the input is nested deeper than this the input will be deemed to be
 malicious and the parser returns nil, signalling an error. ("Nested too deep".) You can
 turn off this security feature by setting the maxDepth value to 0.
 */
@property NSUInteger maxDepth;

/**
 @brief Whether we are generating human-readable (multiline) JSON.
 
 Set whether or not to generate human-readable JSON. The default is NO, which produces
 JSON without any whitespace between tokens. If set to YES, generates human-readable
 JSON with linebreaks after each array value and dictionary key/value pair, indented two
 spaces per nesting level.
 */
@property BOOL humanReadable;

/**
 @brief Whether or not to sort the dictionary keys in the output.
 
 If this is set to YES, the dictionary keys in the JSON output will be in sorted order.
 (This is useful if you need to compare two structures, for example.) The default is NO.
 */
@property BOOL sortKeys;

/// Contains the error description after an error has occured.
@property (copy) NSString *error;

/** 
 Write an NSDictionary to the JSON stream.
 @return YES if successful, or NO on failure
 */
- (BOOL)writeObject:(NSDictionary*)dict;

/**
 Write an NSArray to the JSON stream.
 @return YES if successful, or NO on failure
 */
- (BOOL)writeArray:(NSArray *)array;

/** 
 Start writing an Object to the stream
 @return YES if successful, or NO on failure
*/
- (BOOL)writeObjectOpen;

/**
 Close the current object being written
 @return YES if successful, or NO on failure
*/
- (BOOL)writeObjectClose;

/** Start writing an Array to the stream
 @return YES if successful, or NO on failure
*/
- (BOOL)writeArrayOpen;

/** Close the current Array being written
 @return YES if successful, or NO on failure
*/
- (BOOL)writeArrayClose;

/** Write a null to the stream
 @return YES if successful, or NO on failure
*/
- (BOOL)writeNull;

/** Write a boolean to the stream
 @return YES if successful, or NO on failure
*/
- (BOOL)writeBool:(BOOL)x;

/** Write a Number to the stream
 @return YES if successful, or NO on failure
*/
- (BOOL)writeNumber:(NSNumber*)n;

/** Write a String to the stream
 @return YES if successful, or NO on failure
*/
- (BOOL)writeString:(NSString*)s;

@end

@interface SBJsonStreamWriter (Private)
- (BOOL)writeValue:(id)v;
- (void)appendBytes:(const void *)bytes length:(NSUInteger)length;
@end

