/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>


@interface SBJsonUTF8Stream : NSObject {
@private
    const char *_bytes;
    NSMutableData *_data;
    NSUInteger _length;
}

@property (assign) NSUInteger index;

- (void)appendData:(NSData*)data_;

- (BOOL)haveRemainingCharacters:(NSUInteger)chars;

- (void)skip;
- (void)skipWhitespace;
- (BOOL)skipCharacters:(const char *)chars length:(NSUInteger)len;

- (BOOL)getUnichar:(unichar*)ch;
- (BOOL)getNextUnichar:(unichar*)ch;
- (BOOL)getStringFragment:(NSString**)string;

- (NSString*)stringWithRange:(NSRange)range;

@end
