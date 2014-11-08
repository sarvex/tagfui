/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "NSObject+PE.h"


@implementation NSObject (PE)

- (BOOL) isNull:(NSObject*) object {
    if (!object)
        return YES;
    else if (object == [NSNull null])
        return YES;
    else if ([object isKindOfClass: [NSString class]]) {
        return ([((NSString*)object) isEqualToString:@""]
                || [((NSString*)object) isEqualToString:@"null"]
                || [((NSString*)object) isEqualToString:@"<null>"]);
    }
    return NO;
}

- (BOOL) isNotNull:(NSObject*) object {
    return ![self isNull:object];
}

- (NSString*)stringByTruncatingStringWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(UILineBreakMode)lineBreakMode {
    NSMutableString *resultString = [self mutableCopy];
    NSRange range = {resultString.length-1, 1};
    
    while ([resultString sizeWithFont:font forWidth:FLT_MAX lineBreakMode:lineBreakMode].width > width || range.location == 0) {
        // delete the last character
        [resultString deleteCharactersInRange:range];
        
        if (range.location > 0)
            range.location--;
        
    }
    
    if (resultString.length < ((NSString*)self).length)
    {
        NSRange newRange = {resultString.length-3, 3};
        [resultString replaceCharactersInRange:newRange withString:@"..."];
    }
    
    return resultString;
}



@end
