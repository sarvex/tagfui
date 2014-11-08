/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>
#import "WooTagPlayerAppDelegate.h"

@protocol VideoServiceDelegate <NSObject>

@optional

//Mypage videos
- (void)didFinishedGetMypageVideos:(NSDictionary *)results;
- (void)didFailToGetMypageVideosWithError:(NSDictionary *)errorDict;

//Comment
- (void)didFinishedCommentingVideo:(NSDictionary *)results;
- (void)didFailToCommentVideoWithError:(NSDictionary *)errorDict;

//GetAllComments
- (void)didFinishedToGetAllCommentsOfVideo:(NSDictionary *)results;
- (void)didFailToGetAllCommentsOfVideoWithError:(NSDictionary *)errorDict;

//Like
- (void)didFinishedLikeVideo:(NSDictionary *)results;
- (void)didFailedLikeVideoWithError:(NSDictionary *)errorDict;

//Dis Like video
- (void)didFinishedUnLikeVideo:(NSDictionary *)results;
- (void)didFailedUnLikeVideoWithError:(NSDictionary *)errorDict;

//GetAllLikes
- (void)didFinishedToGetAllLikesOfVideo:(NSDictionary *)results;
- (void)didFailToGetAllLikesOfVideoWithError:(NSDictionary *)errorDict;

//Delete
- (void)didFinishedDeleteVideo:(NSDictionary *)results;
- (void)didFailedDeleteVideoWithError:(NSDictionary *)errorDict;

//Report video
- (void)didFinishedReportVideo:(NSDictionary *)results;
- (void)didFailedReportVideoWithError:(NSDictionary *)errorDict;

//video feed
- (void)didFinishedToGetVideoFeed:(NSDictionary *)results;
- (void)didFailToGetVideoFeedWithError:(NSDictionary *)errorDict;

//Search
- (void)didFinishedToGetSearchReqDetails:(NSDictionary *)results;
- (void)didFailToGetSearchReqDetailsWithError:(NSDictionary *)errorDict;

//Private feed of user
- (void)didFinishedToGetPrivateFeed:(NSDictionary *)results;
- (void)didFailToGetPrivateFeedWithError:(NSDictionary *)errorDict;

//Delete Comment
- (void)didFinishedDeleteCommentVideo:(NSDictionary *)results;
- (void)didFailToDeleteCommentVideoWithError:(NSDictionary *)errorDict;

//Change Access permission
- (void)didFinishedChangeVideoAccessPermission:(NSDictionary *)results;
- (void)didFailedToChangeVideoAccessPermissionWithError:(NSDictionary *)errorDict ;
@end

@interface VideoService : NSObject<VideoServiceDelegate> {
    id caller_;
    NSString *requestURL;
    NSString *videoId_;
    NSString *userId_;
    
    //Mypage videos
    NSInteger pageNumber;
    NSInteger pageSize;
    BOOL isRequestForStartingPage;
    
    NSString *searchRequestType;
    NSIndexPath *indexPath;
    
    WooTagPlayerAppDelegate *appDelegate;
}
@property (nonatomic, retain) NSString *requestURL;
@property (nonatomic, readwrite) NSInteger pageNumber;
@property (nonatomic, readwrite) NSInteger pageSize;
@property (nonatomic, readwrite) BOOL isRequestForStartingPage;
@property (nonatomic, retain) NSIndexPath *indexPath;

- (id)initWithCaller:(id)caller;

- (void)getAllCommentsOfVideoWithVideoId:(NSString *)videoId;
- (void)getAllLikesOfVideoWithVideoId:(NSString *)videoId;

- (void)deleteVideoWithVideoId:(NSString *)videoId ofUserId:(NSString *)userId;
- (void)reportVideoWithVideoId:(NSString *)videoId ofUserId:(NSString *)userId andReason:(NSString *)reason andDeviceId:(NSString *)deviceID;

- (void)likeVideoWithVideoId:(NSString *)videoId ofUserId:(NSString *)userId;
- (void)unlikeVideoWithVideoId:(NSString *)videoId ofUserId:(NSString *)userId;

- (void)postCommentWithCommmentText:(NSString *)commentText videoId:(NSString *)videoId andUserId:(NSString *)userId;
- (void)requestForMyPageVideosOfUserWithUserId:(NSString *)userId;
- (void)requestForVideoFeedOfUserWithUserId:(NSString *)userId;
- (void)requestForPrivateFeedOfUserWithUserId:(NSString *)userId;

- (void)requestForSearchWithSearchString:(NSString *)searchString andRequestType:(NSString *)requestType andUserID:(NSString *)userId;

- (void)deleteCommentOfVideoWithCommentId:(NSString *)cmntId andUserId:(NSString *)userId;
- (void)changeVideoAccessPermission:(NSString *)videoId permission:(int)permission;
@end
