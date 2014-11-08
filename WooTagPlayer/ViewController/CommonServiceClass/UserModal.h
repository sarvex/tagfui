/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>

@interface UserModal : NSObject <NSCoding>
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSNumber * totalNoOfFollowings;
@property (nonatomic, retain) NSNumber * totalNoOfFollowers;
@property (nonatomic, retain) NSNumber * totalNoOfPrivateUsers;
@property (nonatomic, retain) NSNumber * totalNoOfPeningPrivateUsers;
@property (nonatomic, retain) NSString * photoPath;
@property (nonatomic, retain) NSString * bannerPath;
@property (nonatomic, retain) NSString * lastUpdate;
@property (nonatomic, retain) NSNumber * totalNoOfLikes;
@property (nonatomic, retain) NSNumber * totalNoOfVideos;
@property (nonatomic, retain) NSNumber * totalNoOfTags;
@property (nonatomic, retain) NSArray  * videos;
@property (nonatomic, retain) NSArray  * followers;
@property (nonatomic, retain) NSArray  * followings;
@property (nonatomic, retain) NSArray  * privateUsers;
@property (nonatomic, readwrite) BOOL      youFollowing;
@property (nonatomic, readwrite) BOOL      youPrivate;
@property (nonatomic, readwrite) BOOL      privateReqSent;
@property (nonatomic, readwrite) BOOL      respondToPvtReq;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * profession;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSString * userDesc;
@property (nonatomic, retain) NSArray * moreVideos;
@property (nonatomic, retain) NSArray * suggestedUsers;

@property (nonatomic, retain) NSArray * videoFeed;
@property (nonatomic, retain) NSArray * privateFeed;

@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * bio;
//Need to show authenticated emailaddress/username in multiple screens
@property (nonatomic, retain) NSMutableDictionary *socialContactsDictionary;

/** Product buying details
 */
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *mobileNumber;
@end
