/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Utils)

- (NSArray *)fetchObjectsForEntityName:(NSString *)name withPredicate:(id)stringOrPredicate, ...;

@end
