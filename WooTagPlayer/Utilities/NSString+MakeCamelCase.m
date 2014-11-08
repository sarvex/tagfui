/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "NSString+MakeCamelCase.h"

@implementation NSString (MakeCamelCase)

- (NSString*)camelCased
{
	NSArray* components = [self componentsSeparatedByString: @"_"];
	NSString* __block camelCasedOutput = [components objectAtIndex: 0];
	[components enumerateObjectsUsingBlock: ^(NSString* obj, NSUInteger idx, BOOL *stop) {
		if (idx != 0) {
			NSString* capitalizedString = [obj stringByReplacingCharactersInRange: NSMakeRange(0,1) withString: [[obj substringToIndex:1] uppercaseString]];
			camelCasedOutput = [camelCasedOutput stringByAppendingString: capitalizedString];
		}
	}];
	
	return camelCasedOutput;
}

- (NSString*)camelBackedFromBumpyCase
{
    NSString* lowerCasedFirstCharacter = [[self substringToIndex: 1] lowercaseString];
    return [self stringByReplacingCharactersInRange: NSMakeRange(0, 1) withString: lowerCasedFirstCharacter];
}

@end
