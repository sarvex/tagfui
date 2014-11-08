/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>

@interface NotificationModal : NSManagedObject  <NSCoding>

@property (nonatomic, retain) NSString *otherUserId;
@property (nonatomic, retain) NSString *otherUserName;
@property (nonatomic, retain) NSString *otherUserProfileImgUrl;
@property (nonatomic, retain) NSString *videoImgUrl;
@property (nonatomic, retain) NSString *videoId;
@property (nonatomic, retain) NSString *messageText;
@property (nonatomic, retain) NSString *descriptionText;
@property (nonatomic, retain) NSNumber *notificationType;
@property (nonatomic, retain) NSString *createdTime;
@property (nonatomic, retain) NSString *notificationId;
@property (nonatomic, retain) NSString *loggedInUserId;
@end
