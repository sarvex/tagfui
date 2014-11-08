/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Video;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSNumber * clientTagId;
@property (nonatomic, retain) NSString * clientVideoId;
@property (nonatomic, retain) NSString * displayTime;
@property (nonatomic, retain) NSString * fbId;
@property (nonatomic, retain) NSString * gPlusId;
@property (nonatomic, retain) NSString * imageName;
@property (nonatomic, retain) NSNumber * isAdded;
@property (nonatomic, retain) NSNumber * isdeleted;
@property (nonatomic, retain) NSNumber * isModified;
@property (nonatomic, retain) NSNumber * isWaitingForUpload;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * screenHeight;
@property (nonatomic, retain) NSNumber * screenWidth;
@property (nonatomic, retain) NSNumber * screenX;
@property (nonatomic, retain) NSNumber * screenY;
@property (nonatomic, retain) NSString * tagColorName;
@property (nonatomic, retain) NSNumber * tagId;
@property (nonatomic, retain) NSString * tagX;
@property (nonatomic, retain) NSString * tagY;
@property (nonatomic, retain) NSString * twId;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSNumber * videoHeight;
@property (nonatomic, retain) NSString * videoId;
@property (nonatomic, retain) NSString * videoPlaybackTime;
@property (nonatomic, retain) NSNumber * videoWidth;
@property (nonatomic, retain) NSNumber * videoX;
@property (nonatomic, retain) NSNumber * videoY;
@property (nonatomic, retain) NSString * wtId;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSString * productLink;
@property (nonatomic, retain) NSString * productCategory;
@property (nonatomic, retain) NSString * productDescription;
@property (nonatomic, retain) NSString * productPrice;
@property (nonatomic, retain) NSNumber * isPurchased;
@property (nonatomic, retain) NSString * productCurrencyType;
@property (nonatomic, retain) Video *tagToVideo;

@end
