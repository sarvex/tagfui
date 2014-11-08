/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "Video.h"
#import "WooTagPlayerAppDelegate.h"

@implementation Video

@dynamic clientId;
@dynamic comments;
@dynamic creationTime;
@dynamic info;
@dynamic isUploaded;
@dynamic isUploading;
@dynamic numberOfCmnts;
@dynamic numberOfLikes;
@dynamic numberOfTags;
@dynamic numberOfViews;
@dynamic path;
@dynamic public;
@dynamic tags;
@dynamic title;
@dynamic uploadedTime;
@dynamic userId;
@dynamic videoId;
@dynamic userName;
@dynamic userPhoto;
@dynamic videoThumbPath;
@dynamic waitingToUpload;
@dynamic videoDurationTime;
@dynamic likesList;
@dynamic browseType;
@dynamic shareToFB;
@dynamic shareToGPlus;
@dynamic shareToTw;
@dynamic uploadPercent;
@dynamic fileUploadCompleted;
@dynamic checksum;
@dynamic totalVideoParts;
@dynamic hitCount;
@dynamic coverFrameValue;
@dynamic checkSumFailed;
@dynamic videoPublishingFailed;
@dynamic compressedVideoPath;
@dynamic loadingViewHidden;
@dynamic isLibraryVideo;
@dynamic filterNumber;

- (id)initWithCoder:(NSCoder *)decoder {
    WooTagPlayerAppDelegate *appDelegate = (WooTagPlayerAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSPersistentStoreCoordinator *psc = [appDelegate persistentStoreCoordinator];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    self = (Video *)[context objectWithID:[psc managedObjectIDForURIRepresentation:(NSURL *)[decoder decodeObjectForKey:@"VideoEncode"]]];
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:[[self objectID] URIRepresentation] forKey:@"VideoEncode"];
}

@end
