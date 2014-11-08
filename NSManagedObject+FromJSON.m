/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "NSManagedObject+FromJSON.h"
#import "NSString+MakeCamelCase.h"
#import "StandardKeySanitizer.h"

@implementation NSManagedObject (FromJSON)

+ (id <RemoteKeySanitizer>)keySanitizer
{
	return [StandardKeySanitizer keySanitizer];
}

+ (NSString*)entityName
{
	return NSStringFromClass([self class]);
}

+ (id)modelFromJSONData: (id)jsonData forEntityName: (NSString*)entityName inContext: (NSManagedObjectContext*)moc keySanitizer:(id <RemoteKeySanitizer>)sanitizer
{
	NSManagedObject* theObject = [NSEntityDescription insertNewObjectForEntityForName: entityName inManagedObjectContext: moc];
	
	[theObject updateFromJSONData: jsonData inContext: moc keySanitizer: sanitizer];
	
	return theObject;
}

- (void)updateFromJSONData: (id)jsonData inContext: (NSManagedObjectContext*)moc keySanitizer: (id <RemoteKeySanitizer>)sanitizer
{
    TCSTART
	NSDictionary* entityAttributes = self.entity.attributesByName;
	NSDictionary* relationships = self.entity.relationshipsByName;
	
	NSDictionary* jsonDict = (NSDictionary*)jsonData;
    for (NSString* key in jsonDict) {
		NSString* sanitizedKey = key;
		id obj = [jsonDict objectForKey:key];
		if (sanitizer) {
			sanitizedKey = [sanitizer sanitizeRemoteKey: key];
		}
		
		NSAttributeDescription* attributeDescription = [entityAttributes objectForKey: sanitizedKey];
		NSRelationshipDescription* relationshipDescription = [relationships objectForKey: sanitizedKey];
		
		//  Ignore attributes that are not present in the model's entity description.
		if (attributeDescription) {
			[self setValue: obj forKey: sanitizedKey];
		} else if(relationshipDescription) {
			if (relationshipDescription.isToMany) {
				NSArray* theArray = (NSArray*)obj;
				NSMutableSet* relationshipTargets = [NSMutableSet setWithCapacity: theArray.count];
				NSString* entityName = relationshipDescription.destinationEntity.name;
				
				[theArray enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
					NSManagedObject* target = nil;
					
					//  Handle simple string relationships as a convenience.  Anything more complicated cannot be handled at this level.
					if( [obj isKindOfClass: [NSString class]]) {
						//  A simple string type
						//  TODO: speed up this lookup.
						
						NSString* attributeName = [[relationshipDescription.destinationEntity.attributesByName allKeys] objectAtIndex: 0];
						
						//  Do not duplicate entries for one-string entity types.
						
						NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName: entityName];
						NSString* predicateString = [NSString stringWithFormat: @"%@ = \"%@\"", attributeName, obj];
						NSPredicate* predicate = [NSPredicate predicateWithFormat: predicateString];
						fetchRequest.predicate = predicate;
						
						NSError* error;
						NSArray* fetchedObjects = [moc executeFetchRequest: fetchRequest error: &error];
						if (!fetchedObjects) {
							NSLog(@"%@", error);
						} else if ([fetchedObjects count] == 0) {
							obj = @{ attributeName : obj };
						} else {
							target = fetchedObjects[0];
						}
					}
                    else if ([relationshipDescription.destinationEntity.name isEqualToString:@"Part"]) {
                        target = [NSClassFromString(relationshipDescription.destinationEntity.name) updateOrCreateFromJSONData:obj inContext:moc save:FALSE];
                    }
                    
					if (target) {
						[relationshipTargets addObject: target];
					}
				}];
				
				[self setValue: relationshipTargets forKey: sanitizedKey];
			}
		}
	}
//	[jsonDict enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
//		NSString* sanitizedKey = key;
//		
//		if (sanitizer) {
//			sanitizedKey = [sanitizer sanitizeRemoteKey: key];
//		}
//		
//		NSAttributeDescription* attributeDescription = [entityAttributes objectForKey: sanitizedKey];
//		NSRelationshipDescription* relationshipDescription = [relationships objectForKey: sanitizedKey];
//		
//		//  Ignore attributes that are not present in the model's entity description.
//		if (attributeDescription) {
//			[self setValue: obj forKey: sanitizedKey];
//		} else if(relationshipDescription) {
//			if (relationshipDescription.isToMany) {
//				NSArray* theArray = (NSArray*)obj;
//				NSMutableSet* relationshipTargets = [NSMutableSet setWithCapacity: theArray.count];
//				NSString* entityName = relationshipDescription.destinationEntity.name;
//				
//				[theArray enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
//					NSManagedObject* target = nil;
//					
//					//  Handle simple string relationships as a convenience.  Anything more complicated cannot be handled at this level.
//					if( [obj isKindOfClass: [NSString class]]) {
//						//  A simple string type
//						//  TODO: speed up this lookup.
//						
//						NSString* attributeName = [[relationshipDescription.destinationEntity.attributesByName allKeys] objectAtIndex: 0];
//						
//						//  Do not duplicate entries for one-string entity types.
//						
//						NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName: entityName];
//						NSString* predicateString = [NSString stringWithFormat: @"%@ = \"%@\"", attributeName, obj];
//						NSPredicate* predicate = [NSPredicate predicateWithFormat: predicateString];
//						fetchRequest.predicate = predicate;
//						
//						NSError* error;
//						NSArray* fetchedObjects = [moc executeFetchRequest: fetchRequest error: &error];
//						if (!fetchedObjects) {
//							NSLog(@"%@", error);
//						} else if ([fetchedObjects count] == 0) {
//							obj = @{ attributeName : obj };
//						} else {
//							target = fetchedObjects[0];
//						}
//					}
//                    else if ([relationshipDescription.destinationEntity.name isEqualToString:@"Part"]) {
//                        target = [NSClassFromString(relationshipDescription.destinationEntity.name) updateOrCreateFromJSONData:obj inContext:moc save:FALSE];
//                    }
//										
//					if (target) {
//						[relationshipTargets addObject: target];
//					}
//				}];
//				
//				[self setValue: relationshipTargets forKey: sanitizedKey];
//			}
//		}
//	}];
    TCEND
}

+ (NSManagedObject*)updateOrCreateFromJSONData: (NSDictionary*)jsonData inContext: (NSManagedObjectContext*)moc
{
    return [self updateOrCreateFromJSONData:jsonData inContext:moc save:TRUE];
}

+ (NSManagedObject*)updateOrCreateFromJSONData: (NSDictionary*)jsonData inContext: (NSManagedObjectContext*)moc save:(BOOL)save
{
    TCSTART
	NSDictionary* sanitizedData = [[self keySanitizer] sanitizeRemoteKeys: jsonData];
	NSString* videoId = [sanitizedData objectForKey: @"videoId"];
    NSString* clientVideoId = [sanitizedData objectForKey: @"clientId"];
	NSString* entityName = [self entityName];
	
	//  TODO: perhaps refactor and query in batches for efficiency.
	NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName: entityName];
	fetchRequest.returnsObjectsAsFaults = NO;
    if (clientVideoId) {
      fetchRequest.predicate = [NSPredicate predicateWithFormat: @"clientId == %@", clientVideoId];  
    } else {
        fetchRequest.predicate = [NSPredicate predicateWithFormat: @"videoId == %@",videoId];
    }
	
	NSLog(@"EntityName:%@",entityName);
    NSManagedObject *obj = nil;
	NSError* error = nil;
	NSArray* fetchedItems = [moc executeFetchRequest: fetchRequest error: &error];
	if (!fetchedItems) {
		NSLog(@"Error fetching entity of type %@, error = %@", entityName, error);
		return nil;
	} else {
		if ([fetchedItems count] == 0) {
			obj = [self modelFromJSONData: jsonData forEntityName: entityName inContext: moc keySanitizer: [self keySanitizer]];
			[moc insertObject: obj];
		}
		else {
			//  Assume unique remoteIds
			obj = [fetchedItems objectAtIndex: 0];
			[obj updateFromJSONData: jsonData inContext: moc keySanitizer: [self keySanitizer]];
		}
	}
	
    if (save) {
        BOOL didSave = [moc save: &error];
        if (!didSave) {
            NSLog(@"Error saving entity of type %@, error = %@", entityName, error);
            return nil;
        }
    }
    return obj;
    TCEND
}

+ (NSManagedObject*)fetchByClientVideoId: (NSString*)clientVideoId context: (NSManagedObjectContext*)moc
{
    TCSTART
	NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName: [self entityName]];
	fetchRequest.predicate = [NSPredicate predicateWithFormat: @"clientVideoId == %@", clientVideoId];
	
	NSError* error;
	NSArray* objects = [moc executeFetchRequest: fetchRequest error: &error];
	if (!objects) {
		NSLog(@"%@", error);
		return nil;
	} else {
		return objects.count ? objects[0] : nil;
	}
    TCEND
}

+ (NSManagedObject *)fetchTagByTagId: (NSNumber *)tagId context: (NSManagedObjectContext *)moc {
    TCSTART
	NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName: @"Tag"];
	fetchRequest.predicate = [NSPredicate predicateWithFormat: @"tagId == %@", tagId];
	
	NSError* error;
	NSArray* objects = [moc executeFetchRequest: fetchRequest error: &error];
	if (!objects) {
		NSLog(@"%@", error);
		return nil;
	} else {
		return objects.count ? objects[0] : nil;
	}
    TCEND
}
@end

