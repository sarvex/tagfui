/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "NSManagedObject+FromJSON.h"
#import <Foundation/Foundation.h>

@interface StandardKeySanitizer : NSObject <RemoteKeySanitizer>

+ (StandardKeySanitizer*)keySanitizer;

@end
