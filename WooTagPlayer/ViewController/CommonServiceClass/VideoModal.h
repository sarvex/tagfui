/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>

@interface VideoModal : NSObject <NSCoding>

@property (nonatomic, retain) NSString * clientId;
@property (nonatomic, retain) NSArray  * comments;
@property (nonatomic, retain) NSString * creationTime;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) NSNumber * numberOfCmnts;
@property (nonatomic, retain) NSNumber * numberOfLikes;
@property (nonatomic, retain) NSNumber * numberOfTags;
@property (nonatomic, retain) NSNumber * numberOfViews;
@property (nonatomic, retain) NSNumber * numberOfVideosOfHashTag;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSNumber * public;
@property (nonatomic, retain) NSArray  * tags;
@property (nonatomic, retain) NSString * title;

@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * userPhoto;
@property (nonatomic, retain) NSString * userCountry;
@property (nonatomic, retain) NSString * userProfession;
@property (nonatomic, retain) NSString * userWebsite;
@property (nonatomic, retain) NSString * userDesc;

@property (nonatomic, retain) NSString * latestTagExpression;
@property (nonatomic, retain) NSString * videoId;
@property (nonatomic, retain) NSString * videoThumbPath;
@property (nonatomic, retain) NSString * videoDurationTime;
@property (nonatomic, retain) NSArray  * likesList;
@property (nonatomic, retain) NSString * browseType;
@property (nonatomic, retain) NSArray * myotherStuff;

@property (nonatomic, retain) NSString *shareUrl;
@property (nonatomic, retain) NSString *fbShareUrl;
@property (nonatomic, readwrite) BOOL hasLovedVideo;
@property (nonatomic, readwrite) BOOL hasCommentedOnVideo;

@end