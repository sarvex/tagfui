/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>
#import "WooTagPlayerAppDelegate.h"
#import <UIKit/UIKit.h>
#import "CoreDataModelHeader.h"

@interface DataManager : NSObject
{
	NSManagedObjectContext *managedObjectContext;
	NSManagedObjectModel   *managedObjectModel;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	NSDate                       *lastSyncTime;
}
@property (readwrite, strong, nonatomic) NSDate *lastSyncTime;
@property (readwrite, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readwrite, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readwrite, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+(DataManager*)sharedDataManager;

-(void)saveChanges;

/* saving and retrieving Tags*/
-(void)addTag:(NSMutableDictionary*)tagDict;
-(Tag *)getTagByVideoIdAndTagId:(NSMutableDictionary*)data;
-(NSArray *)getAllTagsByVideoIdAndClientVideoId:(NSDictionary *)data;

- (Tag *)getTagByTagId:(NSNumber *)tagId;
- (void)deleteTag:(Tag *)tag;
- (Tag *)getTagByTagIdORClientTagId:(NSDictionary *)data;
- (NSArray *)getAllTags;
- (void)deleteAllTagsWhereClientVideoId:(NSNumber *)clientVideoId;

/** saving and retrieving Videos */
- (void)addVideo:(NSMutableDictionary *)videoFields;
- (Video *)getVideoByVideoIdOrVideoClientId:(NSMutableDictionary *)data;
- (NSArray *)getAllVideosOfUserWithUserId:(NSString *)userId;
- (NSArray *)getAllUploadedVideosOfUserId:(NSString *)userId;
- (NSArray *)getAllUploadingVideos;
- (NSArray *)getAllVideos;
- (void)deleteVideo:(Video *)video;

/** Saving , Retrieving and deleting Notifications
 */
- (void)addNotification:(NSMutableDictionary *)notificationDict;
- (void)deleteNotificationModal:(NotificationModal *)notification;
- (NSArray *)getAllNotificationsByUserId:(NSString *)userId;
- (void)removeAllNotificationsOfUserId:(NSString *)userId;
- (NotificationModal *)getNotificationByNotificationId:(NSMutableDictionary *)notificationFields;
- (void)removeAllNotificationsWhichAreCreated7DaysAgo;

/*json body for some data*/
- (NSArray*)getAddedTagsArrayAndWaitingForPostWithUserId:(NSString *)userId;
- (NSArray *)getUpdatedTagsArrayAndWaitingForPost;

- (NSMutableDictionary *)tagToDictionary:(Tag *)tag;


/** Saving and Retrieving User
 */
- (void)addUser:(NSMutableDictionary *)userFields;
- (User *)getUserByUserId:(NSMutableDictionary *)data;
- (void)deleteUser:(User *)user;

/** Saving get first time user exp
 */
- (FirstTimeUserExperience *)createFirstTimeUserExprience;

/** Save and retrieving BuyerInfo
 */
- (void)addBuyerInfo:(NSMutableDictionary *)params;
- (BuyerInfo *)getBuyerInfoByTagIdOrClientTagId:(NSDictionary *)data;
- (NSDictionary *)buyerInfoToDictionary:(BuyerInfo *)buyerInfo;
- (BuyerInfo *)getBuyerInfoByUserId:(NSString *)userId;
@end
