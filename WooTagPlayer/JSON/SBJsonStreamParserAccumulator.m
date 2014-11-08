/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "SBJsonStreamParserAccumulator.h"

@implementation SBJsonStreamParserAccumulator

@synthesize value;


#pragma mark SBJsonStreamParserAdapterDelegate

- (void)parser:(SBJsonStreamParser*)parser foundArray:(NSArray *)array {
	value = array;
}

- (void)parser:(SBJsonStreamParser*)parser foundObject:(NSDictionary *)dict {
	value = dict;
}

@end
