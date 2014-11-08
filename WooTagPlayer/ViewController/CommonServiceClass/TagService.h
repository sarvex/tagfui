/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>
@protocol TagServiceDelegate <NSObject>

@optional
//AddTags
-(void)didFinishedAddingTags:(NSDictionary *)results;
-(void)didFailToAddTagsWithError:(NSDictionary *)errorDict;

//Update Tags
-(void)didFinishedUpdatingTags:(NSDictionary *)results;
-(void)didFailToUpdateTagsWithError:(NSDictionary *)errorDict;

//Delete Tag
-(void)didFinishedDeleteTag:(NSDictionary *)results;
-(void)didFailToDeleteTagWithError:(NSDictionary *)errorDict;

//playback related
-(void)didFinishedPlayBackRequest:(NSDictionary *)results;
-(void)didFailedPlayBackRequestWithError:(NSDictionary *)errorDict;

// Analytics related
- (void)didFinishedSendAnalyticsInfo:(NSDictionary *)result;
- (void)didFailedToSendAnalyticsWithError:(NSDictionary *)errorDict;

@end
@interface TagService : NSObject<TagServiceDelegate>
{
    id caller_;
    NSString *requestURL;       //set the host URL
    NSString *user_id; 
    NSString *deviceId;
    NSString *deleteReqtagId;
    NSArray *afterUpdateTagsArray;
    
    NSIndexPath *indexPath;
    BOOL requestForRefresh;
}
@property (nonatomic, retain) NSString *requestURL;
@property (nonatomic, retain) NSString *user_id;
@property (nonatomic, retain) NSString *deviceId;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, readwrite) BOOL requestForRefresh;
- (id)initWithCaller:(id)caller;

- (void)addTags:(NSArray *)tagsArray;
- (void)updateTags:(NSArray *)tagsArray;
- (void)deleteTagWithTagId:(NSString *)tagId;
- (void)playBackRequestWithVideoId:(NSString *)videoId;

-(void)networkCall:(NSDictionary *)requestParams;

@end
