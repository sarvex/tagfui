/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>

@protocol RemoteKeySanitizer <NSObject>

- (NSString*)sanitizeRemoteKey: (NSString*)key;
- (NSDictionary*)sanitizeRemoteKeys: (NSDictionary*)remoteKeys;

@end

@interface NSManagedObject (FromJSON)

+ (id)modelFromJSONData: (id)jsonData forEntityName: (NSString*)entityName inContext: (NSManagedObjectContext*)moc keySanitizer: (id <RemoteKeySanitizer>)sanitizer;
- (void)updateFromJSONData: (id)jsonData inContext: (NSManagedObjectContext*)moc keySanitizer: (id <RemoteKeySanitizer>)sanitizer;
+ (NSManagedObject*)updateOrCreateFromJSONData: (NSDictionary*)jsonData inContext: (NSManagedObjectContext*)moc;

//  Subclasses that use this category MUST override entityName.
+ (NSString*)entityName;
+ (NSManagedObject*)fetchByClientVideoId: (NSString*)clientVideoId context: (NSManagedObjectContext*)moc;
+ (NSManagedObject *)fetchTagByTagId: (NSNumber *)tagId context: (NSManagedObjectContext *)moc;
+ (id <RemoteKeySanitizer>)keySanitizer;

@end
