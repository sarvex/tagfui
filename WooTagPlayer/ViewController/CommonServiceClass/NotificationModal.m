/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "NotificationModal.h"

@implementation NotificationModal

@synthesize otherUserId;
@synthesize otherUserName;
@synthesize otherUserProfileImgUrl;
@synthesize videoId;
@synthesize videoImgUrl;
@synthesize messageText;
@synthesize notificationType;
@synthesize createdTime;
@synthesize descriptionText;
@synthesize notificationId;
@synthesize loggedInUserId;

- (id)initWithCoder:(NSCoder *)decoder {
    WooTagPlayerAppDelegate *appDelegate = (WooTagPlayerAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSPersistentStoreCoordinator *psc = [appDelegate persistentStoreCoordinator];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    self = (NotificationModal *)[context objectWithID:[psc managedObjectIDForURIRepresentation:(NSURL *)[decoder decodeObjectForKey:@"NotificationEncode"]]];
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:[[self objectID] URIRepresentation] forKey:@"NotificationEncode"];
}

@end
