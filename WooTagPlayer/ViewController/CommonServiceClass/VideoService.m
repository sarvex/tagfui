/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "VideoService.h"
#import "Video.h"
#import "NetworkConnection.h"

@implementation VideoService

@synthesize requestURL;
@synthesize pageSize;
@synthesize pageNumber;
@synthesize isRequestForStartingPage;
@synthesize indexPath;

-(id)initWithCaller:(id)caller {
    if (self = [super init]) {
        caller_ = caller;
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return  self;
}

#pragma mark GetAllComments
- (void)getAllCommentsOfVideoWithVideoId:(NSString *)videoId {
    TCSTART
    NSDictionary *allcmntsRequest = [[NSDictionary alloc] initWithObjectsAndKeys: videoId,@"videoId",[NSNumber numberWithInt:pageNumber],@"pagenumber",requestURL,@"url",@"allcomments",@"requestfor", nil];
    videoId_ = videoId;
    [self networkCall:allcmntsRequest];
    
    TCEND
}

- (void)didFinishedToGetAllCommentsOfVideo:(NSDictionary *)results {
    TCSTART
    BOOL isResponseNull = YES;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if ([self isNotNull:results] && (([self isNotNull:[results objectForKey:@"coments"]] && [[results objectForKey:@"coments"] isKindOfClass:[NSArray class]]) || ([self isNotNull:[results objectForKey:@"comments"]]  && [[results objectForKey:@"comments"] isKindOfClass:[NSArray class]]))) {
        isResponseNull = NO;
        if ([self isNotNull:[results objectForKey:@"coments"]]) {
            [dict setObject:[results objectForKey:@"coments"] forKey:@"comments"];
        } else if ([self isNotNull:[results objectForKey:@"comments"]]) {
            [dict setObject:[results objectForKey:@"comments"] forKey:@"comments"];
        }
    }
    if (caller_ && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToGetAllCommentsOfVideo:)]) {
        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:isResponseNull],@"isResponseNull",indexPath?:@"",@"indexPath",videoId_,@"VideoId", nil]];
        [caller_ didFinishedToGetAllCommentsOfVideo:dict];
    }
    TCEND
}
- (void)didFailToGetAllCommentsOfVideoWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetAllCommentsOfVideoWithError:)]) {
        [caller_ didFailToGetAllCommentsOfVideoWithError:errorDict];
    }
    TCEND
}

#pragma mark GetAll Likes
- (void)getAllLikesOfVideoWithVideoId:(NSString *)videoId {
    TCSTART
    NSDictionary *allcmntsRequest = [[NSDictionary alloc] initWithObjectsAndKeys: videoId,@"videoId",[NSNumber numberWithInt:pageNumber],@"pagenumber",requestURL,@"url",@"alllikes",@"requestfor", nil];
    videoId_ = videoId;
    [self networkCall:allcmntsRequest];
    TCEND
}

- (void)didFinishedToGetAllLikesOfVideo:(NSDictionary *)results {
    TCSTART
    BOOL isResponseNull = YES;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if ([self isNotNull:results] && ([self isNotNull:[results objectForKey:@"likelist"]] && [[results objectForKey:@"likelist"] isKindOfClass:[NSArray class]])) {
        isResponseNull = NO;
        [dict setObject:[results objectForKey:@"likelist"] forKey:@"likelist"];
    }
    if (caller_ && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToGetAllLikesOfVideo:)]) {
        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:isResponseNull],@"isResponseNull",indexPath?:@"",@"indexPath",videoId_,@"VideoId", nil]];
        [caller_ didFinishedToGetAllLikesOfVideo:dict];
    }
    TCEND
}
- (void)didFailToGetAllLikesOfVideoWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetAllLikesOfVideoWithError:)]) {
        [caller_ didFailToGetAllLikesOfVideoWithError:errorDict];
    }
    TCEND
}

#pragma mark Delete Video
- (void)deleteVideoWithVideoId:(NSString *)videoId ofUserId:(NSString *)userId {
    TCSTART
    NSDictionary *deleteRequest = [[NSDictionary alloc] initWithObjectsAndKeys: userId,@"userId",videoId,@"videoId",requestURL,@"url",@"deletevideo",@"requestfor", nil];
    videoId_ = videoId;
    userId_ = userId;

    [self networkCall:deleteRequest];
    TCEND
}
- (void)didFinishedDeleteVideo:(NSDictionary *)results {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedDeleteVideo:)]) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:indexPath,@"indexpath", nil];
        [caller_ didFinishedDeleteVideo:dict];
    }
    TCEND
}
- (void)didFailedDeleteVideoWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailedDeleteVideoWithError:)]) {
        [caller_ didFailedDeleteVideoWithError:errorDict];
    }
    TCEND
}

#pragma mark Report Video
- (void)reportVideoWithVideoId:(NSString *)videoId ofUserId:(NSString *)userId andReason:(NSString *)reason andDeviceId:(NSString *)deviceID {
    TCSTART
    NSDictionary *reportRequest = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:userId,@"login_id",videoId,@"video_id",reason,@"report_text",deviceID,@"device_id", nil],@"user",requestURL,@"url",@"reportvideo",@"requestfor", nil];
    [self networkCall:reportRequest];
    TCEND
}
- (void)didFinishedReportVideo:(NSDictionary *)results {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedReportVideo:)]) {
        [caller_ didFinishedReportVideo:results];
    }
    TCEND
}
- (void)didFailedReportVideoWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailedReportVideoWithError:)]) {
        [caller_ didFailedReportVideoWithError:errorDict];
    }
    TCEND
}


#pragma mark Video access permission
- (void)changeVideoAccessPermission:(NSString *)videoId permission:(int)permission {
    TCSTART
    NSDictionary *permissionRequest = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:videoId,@"video_id",[NSNumber numberWithInt:permission],@"public", nil],@"permissions",requestURL,@"url",@"accesspermission",@"requestfor", nil];
    [self networkCall:permissionRequest];
    TCEND
}
- (void)didFinishedChangeVideoAccessPermission:(NSDictionary *)results {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedChangeVideoAccessPermission:)]) {
        [caller_ didFinishedChangeVideoAccessPermission:results];
    }
    TCEND
}
- (void)didFailedToChangeVideoAccessPermissionWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailedToChangeVideoAccessPermissionWithError:)]) {
        [caller_ didFailedToChangeVideoAccessPermissionWithError:errorDict];
    }
    TCEND
}

#pragma mark Like video
- (void)likeVideoWithVideoId:(NSString *)videoId ofUserId:(NSString *)userId {
    TCSTART
    NSDictionary *deleteRequest = [[NSDictionary alloc] initWithObjectsAndKeys: userId,@"userId",videoId,@"videoId",requestURL,@"url",@"likevideo",@"requestfor", nil];
    videoId_ = videoId;
    userId_ = userId;
    [self networkCall:deleteRequest];
    TCEND
}
- (void)didFinishedLikeVideo:(NSDictionary *)results {
    TCSTART
    BOOL isResponseNull = YES;
    if ([self isNotNull:results]) {
        isResponseNull = NO;
    }
    if (caller_ && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedLikeVideo:)]) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:isResponseNull],@"isResponseNull",indexPath?:@"",@"indexpath", nil];
        [caller_ didFinishedLikeVideo:dict];
    }
    TCEND
}
- (void)didFailedLikeVideoWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailedLikeVideoWithError:)]) {
        [caller_ didFailedLikeVideoWithError:errorDict];
    }
    TCEND
}

#pragma mark Like video
- (void)unlikeVideoWithVideoId:(NSString *)videoId ofUserId:(NSString *)userId {
    TCSTART
    NSDictionary *deleteRequest = [[NSDictionary alloc] initWithObjectsAndKeys: userId,@"userId",videoId,@"videoId",requestURL,@"url",@"unlikevideo",@"requestfor", nil];
    videoId_ = videoId;
    userId_ = userId;
    [self networkCall:deleteRequest];
    TCEND
}
- (void)didFinishedUnLikeVideo:(NSDictionary *)results {
    TCSTART
    BOOL isResponseNull = YES;
    if ([self isNotNull:results]) {
        isResponseNull = NO;
    }
    if (caller_ && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedUnLikeVideo:)]) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:isResponseNull],@"isResponseNull",indexPath?:@"",@"indexpath", nil];
        [caller_ didFinishedUnLikeVideo:dict];
    }
    TCEND
}
- (void)didFailedUnLikeVideoWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailedUnLikeVideoWithError:)]) {
        [caller_ didFailedUnLikeVideoWithError:errorDict];
    }
    TCEND
}

#pragma mark post comment
- (void)postCommentWithCommmentText:(NSString *)commentText videoId:(NSString *)videoId andUserId:(NSString *)userId {
    TCSTART
    NSDictionary *commentReq = [[NSDictionary alloc] initWithObjectsAndKeys: [NSDictionary dictionaryWithObjectsAndKeys:userId,@"userid",videoId,@"video_id",commentText,@"comment_text", nil],@"user",requestURL,@"url",@"comment",@"requestfor", nil];
    videoId_ = videoId;
    userId_ = userId;
    [self networkCall:commentReq];
    TCEND
}

- (void)didFinishedCommentingVideo:(NSDictionary *)results {
    TCSTART
    BOOL isResponseNull = YES;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if ([self isNotNull:results]) {
         isResponseNull = NO;
        NSMutableDictionary *commentDict = [[NSMutableDictionary alloc] init];
        
        if ([self isNotNull:[results objectForKey:@"id"]]) {
            [commentDict setObject:[results objectForKey:@"id"] forKey:@"user_id"];
        }
        if ([self isNotNull:[results objectForKey:@"comment_id"]]) {
            [commentDict setObject:[results objectForKey:@"comment_id"] forKey:@"comment_id"];
        }
        if ([self isNotNull:[results objectForKey:@"name"]]) {
            [commentDict setObject:[results objectForKey:@"name"] forKey:@"user_name"];
        }
        
        if ([self isNotNull:[results objectForKey:@"photo_path"]]) {
            [commentDict setObject:[results objectForKey:@"photo_path"] forKey:@"user_photo"];
        }
        
        if ([self isNotNull:[results objectForKey:@"comment_text"]]) {
            [commentDict setObject:[results objectForKey:@"comment_text"] forKey:@"comment_text"];
        }
        [dict setObject:commentDict forKey:@"comments"];
    }
    if (caller_ && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedCommentingVideo:)]) {
        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:isResponseNull],@"isResponseNull",indexPath?:@"",@"indexPath", nil]];
        [caller_ didFinishedCommentingVideo:dict];
    }
    TCEND
}
- (void)didFailToCommentVideoWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToCommentVideoWithError:)]) {
        [caller_ didFailToCommentVideoWithError:errorDict];
    }
    TCEND
}

#pragma mark Delete comment
- (void)deleteCommentOfVideoWithCommentId:(NSString *)cmntId andUserId:(NSString *)userId {
    TCSTART
    NSDictionary *commentReq = [[NSDictionary alloc] initWithObjectsAndKeys: userId,@"userid",cmntId,@"cmnt_id",requestURL,@"url",@"deletecomment",@"requestfor", nil];
    userId_ = userId;
    [self networkCall:commentReq];
    TCEND
}

- (void)didFinishedDeleteCommentVideo:(NSDictionary *)results {
    TCSTART
    BOOL isResponseNull = YES;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if ([self isNotNull:results]) {
        isResponseNull = NO;
    }
    if (caller_ && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedDeleteCommentVideo:)]) {
        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:isResponseNull],@"isResponseNull",indexPath?:@"",@"indexPath", nil]];
        [caller_ didFinishedDeleteCommentVideo:dict];
    }
    TCEND
}
- (void)didFailToDeleteCommentVideoWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToDeleteCommentVideoWithError:)]) {
        [caller_ didFailToDeleteCommentVideoWithError:errorDict];
    }
    TCEND
}

#pragma mark MypageVideos
- (void)requestForMyPageVideosOfUserWithUserId:(NSString *)userId {
    TCSTART
//    [NSNumber numberWithInt:pageSize],@"videos_per_page",
    NSDictionary *videosReq = [[NSDictionary alloc] initWithObjectsAndKeys: [NSDictionary dictionaryWithObjectsAndKeys:userId,@"userid",[NSNumber numberWithInt:pageNumber],@"page_no",@"iPhone",@"device", nil],@"user",requestURL,@"url",@"mypagevideos",@"requestfor", nil];
    [self networkCall:videosReq];
    TCEND
}
- (void)didFinishedGetMypageVideos:(NSDictionary *)results {
    TCSTART
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedGetMypageVideos:)]) {
        NSDictionary *resultsDict = nil;
        NSMutableArray *videosArray = [[NSMutableArray alloc] init];
        if ([self isNotNull:[results objectForKey:@"videos"]] && [[results objectForKey:@"videos"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in [results objectForKey:@"videos"]) {
                VideoModal *modal = [appDelegate returnVideoModalObjectByParsing:dict];
                [videosArray addObject:modal];
            }
        }
        resultsDict = [NSDictionary dictionaryWithObjectsAndKeys:videosArray,@"videos",[NSNumber numberWithInt:pageNumber],@"pagenumber", nil];
        [caller_ didFinishedGetMypageVideos:resultsDict];
    }
    TCEND
}

- (void)didFailToGetMypageVideosWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetMypageVideosWithError:)]) {
        [caller_ didFailToGetMypageVideosWithError:errorDict];
    }
    TCEND
}

#pragma mark Videofeed
- (void)requestForVideoFeedOfUserWithUserId:(NSString *)userId {
    TCSTART
    NSDictionary *videosReq = [[NSDictionary alloc] initWithObjectsAndKeys: [NSDictionary dictionaryWithObjectsAndKeys:userId,@"userid",[NSNumber numberWithInt:pageNumber],@"page_no",[NSNumber numberWithInt:pageSize],@"videos_per_page",@"iPhone",@"device", nil],@"user",requestURL,@"url",@"videofeed",@"requestfor", nil];
    [self networkCall:videosReq];
    TCEND
}
- (void)didFinishedToGetVideoFeed:(NSDictionary *)results {
    TCSTART
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToGetVideoFeed:)]) {
        NSDictionary *resultsDict = nil;
        NSMutableArray *videosArray = [[NSMutableArray alloc] init];
        if ([self isNotNull:[results objectForKey:@"videos"]] && [[results objectForKey:@"videos"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in [results objectForKey:@"videos"]) {
                VideoModal *modal = [appDelegate returnVideoModalObjectByParsing:dict];
                [videosArray addObject:modal];
            }
        }
        resultsDict = [NSDictionary dictionaryWithObjectsAndKeys:videosArray,@"videos",[NSNumber numberWithInt:pageNumber],@"pagenumber", nil];
        [caller_ didFinishedToGetVideoFeed:resultsDict];
    }
    TCEND
}

- (void)didFailToGetVideoFeedWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetVideoFeedWithError:)]) {
        [caller_ didFailToGetVideoFeedWithError:errorDict];
    }
    TCEND
}

#pragma mark Private feed
- (void)requestForPrivateFeedOfUserWithUserId:(NSString *)userId {
    TCSTART
    NSDictionary *videosReq = [[NSDictionary alloc] initWithObjectsAndKeys: [NSDictionary dictionaryWithObjectsAndKeys:userId,@"userid",[NSNumber numberWithInt:pageNumber],@"page_no",[NSNumber numberWithInt:pageSize],@"videos_per_page",@"iPhone",@"device", nil],@"user",requestURL,@"url",@"privatefeed",@"requestfor", nil];
    [self networkCall:videosReq];
    TCEND
}
- (void)didFinishedToGetPrivateFeed:(NSDictionary *)results {
    TCSTART
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToGetPrivateFeed:)]) {
        NSDictionary *resultsDict = nil;
        NSMutableArray *videosArray = [[NSMutableArray alloc] init];
        if ([self isNotNull:[results objectForKey:@"videos"]] && [[results objectForKey:@"videos"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in [results objectForKey:@"videos"]) {
                VideoModal *modal = [appDelegate returnVideoModalObjectByParsing:dict];
                [videosArray addObject:modal];
            }
        }
        resultsDict = [NSDictionary dictionaryWithObjectsAndKeys:videosArray,@"videos",[NSNumber numberWithInt:pageNumber],@"pagenumber", nil];
        [caller_ didFinishedToGetPrivateFeed:resultsDict];
    }
    TCEND
}

- (void)didFailToGetPrivateFeedWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetPrivateFeedWithError:)]) {
        [caller_ didFailToGetPrivateFeedWithError:errorDict];
    }
    TCEND
}

#pragma mark Search request
- (void)requestForSearchWithSearchString:(NSString *)searchString andRequestType:(NSString *)requestType andUserID:(NSString *)userId {
    TCSTART
    NSDictionary *searchRequest;
    searchRequestType = requestType;
    if ([requestType caseInsensitiveCompare:@"otherpagesearch"] == NSOrderedSame) {
        searchRequest = [[NSDictionary alloc] initWithObjectsAndKeys: [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:pageNumber],@"page_no",searchString,@"name",@"iPhone",@"device",userId,@"userid",appDelegate.loggedInUser.userId,@"login_id", nil],@"user", nil],@"user",requestType,@"type",requestURL,@"url",@"search",@"requestfor", nil];
    } else {
        searchRequest = [[NSDictionary alloc] initWithObjectsAndKeys: [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:pageNumber],@"page_no",searchString,@"name",@"iPhone",@"device",userId,@"userid", nil],@"user", nil],@"user",requestType,@"type",requestURL,@"url",@"search",@"requestfor", nil];
    }
    
    [self networkCall:searchRequest];
    TCEND
}

- (void)didFinishedToGetSearchReqDetails:(NSDictionary *)results {
    TCSTART
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToGetSearchReqDetails:)]) {
        NSDictionary *resultsDict;
        NSMutableArray *array = [[NSMutableArray alloc] init];
        if ([self isNotNull:[results objectForKey:@"videos"]] && [[results objectForKey:@"videos"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in [results objectForKey:@"videos"]) {
                VideoModal *modal = [appDelegate returnVideoModalObjectByParsing:dict];
                [array addObject:modal];
            }
        }
        resultsDict = [NSDictionary dictionaryWithObjectsAndKeys:array,@"videos",searchRequestType?:@"",@"searchRequestType",[NSNumber numberWithInt:pageNumber],@"pagenumber", nil];
        [caller_ didFinishedToGetSearchReqDetails:resultsDict];
    }
    
    TCEND
}

- (void)didFailToGetSearchReqDetailsWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(VideoServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetSearchReqDetailsWithError:)]) {
        [caller_ didFailToGetSearchReqDetailsWithError:errorDict];
    }
    TCEND
}

#pragma mark NetWork Call
- (void)networkCall:(NSDictionary *)requestParams {
    
    @try {
        // Create a network request
        NetworkConnection *networkConn = [[NetworkConnection alloc] init];
        
        if([[requestParams objectForKey:@"requestfor"] isEqualToString:@"allcomments"]) {
            // thread call for mypage
            [NSThread detachNewThreadSelector:@selector(requestForGetAllComments:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if([[requestParams objectForKey:@"requestfor"] isEqualToString:@"alllikes"]) {
            // thread call for mypage
            [NSThread detachNewThreadSelector:@selector(requestForGetAllLikes:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"deletevideo"]){
            
            //thread call for follow.
            [NSThread detachNewThreadSelector:@selector(requestForDeleteVideo:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"reportvideo"]){
            //thread call for follow.
            
            [NSThread detachNewThreadSelector:@selector(requestForReportVideo:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"accesspermission"]){
            //thread call for follow.
            
            [NSThread detachNewThreadSelector:@selector(requestForChangeAccessPermissions:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        }  else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"likevideo"]){
            
            //thread call for unfollow.
            [NSThread detachNewThreadSelector:@selector(requestForLikeVideo:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"unlikevideo"]){
            
            //thread call for unfollow.
            [NSThread detachNewThreadSelector:@selector(requestForUnLikeVideo:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"comment"]){
            
            //thread call for followers.
            [NSThread detachNewThreadSelector:@selector(postComment:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"deletecomment"]){
            
            //thread call for followers.
            [NSThread detachNewThreadSelector:@selector(deleteComment:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"mypagevideos"]){
            
            //thread call for followings.
            [NSThread detachNewThreadSelector:@selector(requestForMyPageVideos:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"videofeed"]){
            
            //thread call for followings.
            [NSThread detachNewThreadSelector:@selector(requestForVideoFeed:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"privatefeed"]){
            
            //thread call for followings.
            [NSThread detachNewThreadSelector:@selector(requestForPrivateFeed:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"search"]){
            
            //thread call for followings.
            [NSThread detachNewThreadSelector:@selector(requestForSearch:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        }
        
        networkConn = nil;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}
@end
