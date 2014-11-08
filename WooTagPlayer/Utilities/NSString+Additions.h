/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */
@interface NSString (Acani)

- (NSString*) stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet;
- (NSString*) stringByTrimmingLeadingWhitespaceAndNewlineCharacters;
- (NSString*) stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet;
- (NSString*) stringByTrimmingTrailingWhitespaceAndNewlineCharacters;

- (NSString*) stringFromMD5;
- (NSString*) encodedString;
- (NSString*) decodedString;
- (NSString *) substituteEmoticons;
- (NSString*) decodedStringUTF8 ;
@end
