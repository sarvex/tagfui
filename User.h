/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSNumber * totalNoOfFollowings;
@property (nonatomic, retain) NSNumber * totalNoOfFollowers;
@property (nonatomic, retain) NSString * photoPath;
@property (nonatomic, retain) NSString * bannerPath;
@property (nonatomic, retain) NSString * lastUpdate;
@property (nonatomic, retain) NSNumber * totalNoOfLikes;
@property (nonatomic, retain) NSNumber * totalNoOfVideos;
@property (nonatomic, retain) NSNumber * totalNoOfTags;
@property (nonatomic, retain) id videos;
@property (nonatomic, retain) id followers;
@property (nonatomic, retain) id followings;
@property (nonatomic, retain) NSNumber * youFollowing;
@end
