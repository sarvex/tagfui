/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>

#import "WooTagPlayerAppDelegate.h"
@protocol NotificationServiceDelegate <NSObject>

@optional

//Notifications
- (void)didFinishedToGetUserNotifications:(NSDictionary *)results;
- (void)didFailToGetUserNotificationsWithError:(NSDictionary *)errorDict;

//Remove notifications
- (void)didFinishedToRemoveUserNotification:(NSDictionary *)results;
- (void)didFailToRemoveUserNotificationWithError:(NSDictionary *)errorDict;

//Video Details
- (void)didFinishedToGetVideoDetails:(NSDictionary *)results;
- (void)didFailToGetVideoDetailsWithError:(NSDictionary *)errorDict;

// Notification details
- (void)didFinishedToGetNotificationSettings:(NSDictionary *)results;
- (void)didFailToGetNotificationSettingsWithError:(NSDictionary *)errorDict;

// Update notifications
- (void)didFinishedToUpdateNotificationsSettings:(NSDictionary *)results;
- (void)didFailToUpdateNotificationsSettingsWithError:(NSDictionary *)errorDict;

// Notification search
- (void)didFinishedToGetUserNotificationsSearch:(NSDictionary *)results;
- (void)didFailToGetUserNotificationsSearchWithError:(NSDictionary *)errorDict;

@end

@interface NotificationService : NSObject <NotificationServiceDelegate> {
    id caller_;
    NSString *requestURL;
    NSString *loginUserId;
    NSString *otherUserId;
    NSString *videoId;
    NSInteger pageNumber;
    NSIndexPath *indexPath;
}
@property (nonatomic, retain) NSString *requestURL;
@property (nonatomic, retain) NSString *loginUserId;
@property (nonatomic, retain) NSString *otherUserId;
@property (nonatomic, retain) NSString *videoId;
@property (nonatomic, readwrite) NSInteger pageNumber;
@property (nonatomic, retain) NSIndexPath *indexPath;

- (id)initWithCaller:(id)caller;
- (void)makeNetworkConnectionForUserNotifications;
- (void)makeNetworkConnectionToRemoveNotificationWithNotificationId:(NSString *)notificationId;
- (void)makeNetworkConnectionForVideoDetailsOfNotificationsWithNotificationType:(NSInteger) notificaitonType;
- (void)makeNetworkConnectionToGetNotificationSettings:(NSString *)userId;
- (void)makeNetworkConnectionToUpdateNotificationsSettingsWithDictionary:(NSDictionary *)notificationsDict;
- (void)makeNotificationsSearchRequestWithSearchKeyword:(NSString *)searchKeyword;
@end
