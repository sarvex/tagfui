/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "SBJsonStreamWriter.h"

@interface SBJsonStreamWriterAccumulator : NSObject <SBJsonStreamWriterDelegate>

@property (readonly, copy) NSMutableData* data;

@end
