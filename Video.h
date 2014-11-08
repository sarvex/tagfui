/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Video : NSManagedObject  <NSCoding>

@property (nonatomic, retain) NSString * clientId;
@property (nonatomic, retain) id comments;
@property (nonatomic, retain) NSString * creationTime;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) NSNumber * isUploaded;
@property (nonatomic, retain) NSNumber * isUploading;
@property (nonatomic, retain) NSNumber * numberOfCmnts;
@property (nonatomic, retain) NSNumber * numberOfLikes;
@property (nonatomic, retain) NSNumber * numberOfTags;
@property (nonatomic, retain) NSNumber * numberOfViews;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * compressedVideoPath;
@property (nonatomic, retain) NSNumber * public;
@property (nonatomic, retain) id tags;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * uploadedTime;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * userPhoto;
@property (nonatomic, retain) NSString * videoId;
@property (nonatomic, retain) NSString * videoThumbPath;
@property (nonatomic, retain) NSNumber * waitingToUpload;
@property (nonatomic, retain) NSString * videoDurationTime;
@property (nonatomic, retain) id likesList;
@property (nonatomic, retain) NSString * browseType;
@property (nonatomic, retain) NSNumber * shareToFB;
@property (nonatomic, retain) NSNumber * shareToGPlus;
@property (nonatomic, retain) NSNumber * shareToTw;
@property (nonatomic, retain) NSNumber * uploadPercent;
@property (nonatomic, retain) NSNumber * hitCount;
@property (nonatomic, retain) NSNumber * totalVideoParts;
@property (nonatomic, retain) NSString * checksum;
@property (nonatomic, retain) NSNumber * fileUploadCompleted;
@property (nonatomic, retain) NSNumber * checkSumFailed;
@property (nonatomic, retain) NSNumber * videoPublishingFailed;
@property (nonatomic, retain) NSNumber * loadingViewHidden;
@property (nonatomic, readwrite) float  coverFrameValue;
@property (nonatomic, retain) NSNumber * filterNumber;
@property (nonatomic, retain) NSNumber * isLibraryVideo;
@end
