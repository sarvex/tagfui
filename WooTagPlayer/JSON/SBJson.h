/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

/**
 @page json2objc JSON to Objective-C
 
 JSON is mapped to Objective-C types in the following way:
 
 @li null    -> NSNull
 @li string  -> NSString
 @li array   -> NSMutableArray
 @li object  -> NSMutableDictionary
 @li true    -> NSNumber's -numberWithBool:YES
 @li false   -> NSNumber's -numberWithBool:NO
 @li integer up to 19 digits -> NSNumber's -numberWithLongLong:
 @li all other numbers       -> NSDecimalNumber
 
 Since Objective-C doesn't have a dedicated class for boolean values,
 these turns into NSNumber instances. However, since these are
 initialised with the -initWithBool: method they round-trip back to JSON
 properly. In other words, they won't silently suddenly become 0 or 1;
 they'll be represented as 'true' and 'false' again.
 
 As an optimisation integers up to 19 digits in length (the max length
 for signed long long integers) turn into NSNumber instances, while
 complex ones turn into NSDecimalNumber instances. We can thus avoid any
 loss of precision as JSON allows ridiculously large numbers.

 @page objc2json Objective-C to JSON
 
 Objective-C types are mapped to JSON types in the following way:
 
 @li NSNull        -> null
 @li NSString      -> string
 @li NSArray       -> array
 @li NSDictionary  -> object
 @li NSNumber's -initWithBool:YES -> true
 @li NSNumber's -initWithBool:NO  -> false
 @li NSNumber      -> number
 
 @note In JSON the keys of an object must be strings. NSDictionary
 keys need not be, but attempting to convert an NSDictionary with
 non-string keys into JSON will throw an exception.
 
 NSNumber instances created with the -numberWithBool: method are
 converted into the JSON boolean "true" and "false" values, and vice
 versa. Any other NSNumber instances are converted to a JSON number the
 way you would expect.

 */

#import "SBJsonParser.h"
#import "SBJsonWriter.h"
#import "SBJsonStreamParser.h"
#import "SBJsonStreamParserAdapter.h"
#import "SBJsonStreamWriter.h"
#import "SBJson.h"


