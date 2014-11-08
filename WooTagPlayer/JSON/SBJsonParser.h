/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>

/**
 @brief Parse JSON Strings and NSData objects

 This uses SBJsonStreamParser internally.

 @see @ref objc2json

 */

@interface SBJsonParser : NSObject

/**
 @brief The maximum recursing depth.

 Defaults to 32. If the input is nested deeper than this the input will be deemed to be
 malicious and the parser returns nil, signalling an error. ("Nested too deep".) You can
 turn off this security feature by setting the maxDepth value to 0.
 */
@property NSUInteger maxDepth;

/**
 @brief Description of parse error

 This method returns the trace of the last method that failed.
 You need to check the return value of the call you're making to figure out
 if the call actually failed, before you know call this method.

 @return A string describing the error encountered, or nil if no error occured.

 */
@property(nonatomic,strong) NSString *error;

/**
 @brief Return the object represented by the given NSData object.

 The data *must* be UTF8 encoded.
 
 @param data An NSData containing UTF8 encoded data to parse.
 @return The NSArray or NSDictionary represented by the object, or nil if an error occured.

 */
- (id)objectWithData:(NSData*)data;

/**
 @brief Return the object represented by the given string

 This method converts its input to an NSData object containing UTF8 and calls -objectWithData: with it.

 @return The NSArray or NSDictionary represented by the object, or nil if an error occured.
 */
- (id)objectWithString:(NSString *)repr;

/**
 @brief Return the object represented by the given string

 This method calls objectWithString: internally. If an error occurs, and if @p error
 is not nil, it creates an NSError object and returns this through its second argument.

 @param jsonText the json string to parse
 @param error pointer to an NSError object to populate on error

 @return The NSArray or NSDictionary represented by the object, or nil if an error occured.
 */

- (id)objectWithString:(NSString*)jsonText
                 error:(NSError**)error;

@end


