/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "UserService.h"
#import "User.h"
#import "NetworkConnection.h"

@implementation UserService
@synthesize requestURL;
@synthesize pageNumber;
@synthesize indexPath;

- (id)initWithCaller:(id)caller {
    if (self = [super init]) {
        caller_ = caller;
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return  self;
}

#pragma mark Mypage Request and  Delegate methods
- (void)getMyPageDetailsOfUserWithUserId:(NSString *)userId {
    TCSTART
    NSDictionary *myPageRequest = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:userId,@"userid",@"iPhone",@"device", nil],@"user",requestURL,@"url",@"mypage",@"requestfor", nil];
    userId_ = userId;
    requestforMypage = YES;
    [self networkCall:myPageRequest];
    
    TCEND
}

#pragma mark Other user page Request and Response Delegate Methods
- (void)getOtherUserPageDetailsOfUserWithUserId:(NSString *)userId andLoggedInUserID:(NSString *)loggedInUserId {
    TCSTART
    NSDictionary *otherPageRequest = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:userId,@"userid",loggedInUserId,@"login_id",@"iPhone",@"device",[NSNumber numberWithInt:pageNumber],@"page_no", nil],@"user",requestURL,@"url",@"otherpage",@"requestfor", nil];
    userId_ = userId;
    requestforMypage = NO;
    [self networkCall:otherPageRequest];
    TCEND
}
- (void)didFinishedToGetMypageDetails:(NSDictionary *)results {
    TCSTART
    UserModal *user = nil;
    BOOL isResponseNull = YES;
    NSMutableDictionary *resultsDict = [[NSMutableDictionary alloc] init];
    if ([self isNotNull:results] && [results objectForKey:@"user"]) {
        isResponseNull = NO;
        NSMutableDictionary *userDict = [results objectForKey:@"user"];
        [userDict setObject:userId_ forKey:@"user_id"];
        if (!requestforMypage && pageNumber > 1) {
            if ([self isNotNull:[[results objectForKey:@"user"] objectForKey:@"videos"]] && [[[results objectForKey:@"user"] objectForKey:@"videos"] isKindOfClass:[NSArray class]]) {
                NSMutableArray *videosArray = [[NSMutableArray alloc] init];
                for (NSDictionary *dict in [[results objectForKey:@"user"] objectForKey:@"videos"]) {
                    VideoModal *modal = [appDelegate returnVideoModalObjectByParsing:dict];
                    [videosArray addObject:modal];
                }
                [resultsDict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:isResponseNull],@"isResponseNull",videosArray,@"videos", nil]];
            }
        } else {
             user = [appDelegate returnUserModalObjectByParsing:userDict isLogdedInUser:requestforMypage];
        }
    }
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToGetMypageDetails:)]) {
        [resultsDict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:isResponseNull],@"isResponseNull",user,@"user", nil]];
        [caller_ didFinishedToGetMypageDetails:resultsDict];
    }
    TCEND
}

- (void)didFailToGetMypageDetailsWithError:(NSDictionary *)errorDict {
    TCSTART
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetMypageDetailsWithError:)]) {
        [caller_ didFailToGetMypageDetailsWithError:errorDict];
    }
    TCEND
}

#pragma mark Follow request and delegate methods
- (void)followRequestWithUserId:(NSString *)userId andFollowerId:(NSString *)followerId {
    TCSTART
    NSDictionary *myPageRequest = [[NSDictionary alloc] initWithObjectsAndKeys: userId,@"userId",followerId,@"followerId",requestURL,@"url",@"follow",@"requestfor", nil];
    userId_ = userId;
    followerId_ = followerId;
    [self networkCall:myPageRequest];

    TCEND
}
- (void)didFinishedToFollowUser:(NSDictionary *)results {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToFollowUser:)]) {
        NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:indexPath,@"indexpath", nil];
        [caller_ didFinishedToFollowUser:resultDict];
    }
    TCEND
}
- (void)didFailToFollowUserWithError:(NSDictionary *)errorDict {
    TCSTART
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToFollowUserWithError:)]) {
        [caller_ didFailToFollowUserWithError:errorDict];
    }
    TCEND
}

#pragma mark Unfollow request and Delegate methods
- (void)unFollowUserRequestWithUserId:(NSString *)userId andFollowerId:(NSString *)followerId {
    TCSTART
    NSDictionary *myPageRequest = [[NSDictionary alloc] initWithObjectsAndKeys: userId,@"userId",followerId,@"followerId",requestURL,@"url",@"unfollow",@"requestfor", nil];
    userId_ = userId;
    followerId_ = followerId;
    [self networkCall:myPageRequest];

    TCEND
}
- (void)didFinishedToUnFollowUser:(NSDictionary *)results {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToUnFollowUser:)]) {
         NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:indexPath,@"indexpath", nil];
        [caller_ didFinishedToUnFollowUser:resultDict];
    }
    TCEND
}
- (void)didFailToUnFollowUserWithError:(NSDictionary *)errorDict {
    TCSTART
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToUnFollowUserWithError:)]) {
        [caller_ didFailToUnFollowUserWithError:errorDict];
    }
    TCEND
}

#pragma mark Unfollow request and Delegate methods
- (void)unPrivateUserRequestWithUserId:(NSString *)userId andPrivateUserId:(NSString *)privateUserId {
    TCSTART
    NSDictionary *myPageRequest = [[NSDictionary alloc] initWithObjectsAndKeys: userId,@"userId",privateUserId,@"privateUserId",requestURL,@"url",@"unprivate",@"requestfor", nil];
    [self networkCall:myPageRequest];
    
    TCEND
}
- (void)didFinishedToUnPrivateUser:(NSDictionary *)results {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToUnPrivateUser:)]) {
        NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:indexPath,@"indexpath", nil];
        [caller_ didFinishedToUnPrivateUser:resultDict];
    }
    TCEND
}
- (void)didFailToUnPrivateUserWithError:(NSDictionary *)errorDict {
    TCSTART
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToUnPrivateUserWithError:)]) {
        [caller_ didFailToUnPrivateUserWithError:errorDict];
    }
    TCEND
}

#pragma mark Follow request and delegate methods
- (void)privateRequestWithUserId:(NSString *)userId andPrivateUserId:(NSString *)privateUserId {
    TCSTART
    NSDictionary *myPageRequest = [[NSDictionary alloc] initWithObjectsAndKeys: userId,@"userId",privateUserId,@"privateUserId",requestURL,@"url",@"private",@"requestfor", nil];
   
    [self networkCall:myPageRequest];
    
    TCEND
}
- (void)didFinishedToPrivateUser:(NSDictionary *)results {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToPrivateUser:)]) {
        NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:indexPath,@"indexpath", nil];
        [caller_ didFinishedToPrivateUser:resultDict];
    }
    TCEND
}
- (void)didFailToPrivateUserWithError:(NSDictionary *)errorDict {
    TCSTART
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToPrivateUserWithError:)]) {
        [caller_ didFailToPrivateUserWithError:errorDict];
    }
    TCEND
}

#pragma mark Follow request and delegate methods
- (void)acceptPrivateGroupRequestWithUserId:(NSString *)userId andPrivateOtherUserId:(NSString *)otherUserId {
    TCSTART
    NSDictionary *myPageRequest = [[NSDictionary alloc] initWithObjectsAndKeys: userId,@"userId",otherUserId,@"privateUserId",requestURL,@"url",@"acceptprivate",@"requestfor", nil];
    
    [self networkCall:myPageRequest];
    
    TCEND
}
- (void)didFinishedToAcceptPrivateUser:(NSDictionary *)results {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToAcceptPrivateUser:)]) {
        NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:indexPath,@"indexpath", nil];
        [caller_ didFinishedToAcceptPrivateUser:resultDict];
    }
    TCEND
}

- (void)didFailToAcceptPrivateUserWithError:(NSDictionary *)errorDict {
    TCSTART
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToAcceptPrivateUserWithError:)]) {
        [caller_ didFailToAcceptPrivateUserWithError:errorDict];
    }
    TCEND
}

#pragma mark list of Private users
- (void)getPrivateUsersOfUserWithUserId:(NSString *)userId {
    TCSTART
    NSDictionary *myPageRequest = [[NSDictionary alloc] initWithObjectsAndKeys: userId,@"userId",[NSNumber numberWithInt:pageNumber],@"pagenumber",[NSString stringWithFormat:@"%@/pvtgrouplist",requestURL],@"url",@"privateusers",@"requestfor", nil];
    userId_ = userId;
    [self networkCall:myPageRequest];
    
    TCEND
}

- (void)getPendingPrivateUsersOfUserWithUserId:(NSString *)userId {
    TCSTART
    NSDictionary *myPageRequest = [[NSDictionary alloc] initWithObjectsAndKeys: userId,@"userId",[NSNumber numberWithInt:pageNumber],@"pagenumber",[NSString stringWithFormat:@"%@/pending_pvtgrouplist",requestURL],@"url",@"privateusers",@"requestfor", nil];
    userId_ = userId;
    [self networkCall:myPageRequest];
    
    TCEND
}

- (void)didFinishedToGetPrivateUsers:(NSDictionary *)results {
    TCSTART
    BOOL isResponseNull = YES;
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"pvtgroup"]] && [[results objectForKey:@"pvtgroup"] isKindOfClass:[NSArray class]]) {
        isResponseNull = NO;
    }
    if (caller_ && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToGetPrivateUsers:)]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:isResponseNull],@"isResponseNull", nil];
        if ([self isNotNull:[results objectForKey:@"total_no_of_pendingpvtgroup"]]) {
            [dict setObject:[results objectForKey:@"total_no_of_pendingpvtgroup"] forKey:@"total_no_of_pendingpvtgroup"];
        } else {
            [dict setObject:[NSNumber numberWithInt:0] forKey:@"total_no_of_pendingpvtgroup"];
        }
        if (!isResponseNull) {
            [dict setObject:[results objectForKey:@"pvtgroup"] forKey:@"pvtgroup"];
           
        }
        [caller_ didFinishedToGetPrivateUsers:dict];
    }
    TCEND
}

- (void)didFailToGetPrivateUsersWithError:(NSDictionary *)errorDict {
    TCSTART
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetPrivateUsersWithError:)]) {
        [caller_ didFailToGetPrivateUsersWithError:errorDict];
    }
    TCEND
}

#pragma mark Followers Request and Delegate methods
- (void)getFollowersOfUserWithUserId:(NSString *)userId {
    TCSTART
    NSDictionary *myPageRequest = [[NSDictionary alloc] initWithObjectsAndKeys: userId,@"userId",[NSNumber numberWithInt:pageNumber],@"pagenumber",requestURL,@"url",appDelegate.loggedInUser.userId,@"loggedIn",@"followers",@"requestfor", nil];
    userId_ = userId;
    [self networkCall:myPageRequest];

    TCEND
}

- (void)didFinishedToGetUserFollowers:(NSDictionary *)results {
    TCSTART
    BOOL isResponseNull = YES;
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"followers"]] && [[results objectForKey:@"followers"] isKindOfClass:[NSArray class]]) {
        isResponseNull = NO;
    }
    if (caller_ && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToGetUserFollowers:)]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:isResponseNull],@"isResponseNull", nil];
        if (!isResponseNull) {
            [dict setObject:[results objectForKey:@"followers"] forKey:@"followers"];
        }
        [caller_ didFinishedToGetUserFollowers:dict];
    }
    TCEND
}
- (void)didFailToGetUserFollowersWithError:(NSDictionary *)errorDict {
    TCSTART
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetUserFollowersWithError:)]) {
        [caller_ didFailToGetUserFollowersWithError:errorDict];
    }
    TCEND
}

#pragma amrk Followings request and Delegate methods
- (void)getFollowingsOfUserWithUserId:(NSString *)userId {
    TCSTART
    NSDictionary *myPageRequest = [[NSDictionary alloc] initWithObjectsAndKeys: userId,@"userId",[NSNumber numberWithInt:pageNumber],@"pagenumber",requestURL,@"url",appDelegate.loggedInUser.userId,@"loggedIn",@"followings",@"requestfor", nil];
    userId_ = userId;
    [self networkCall:myPageRequest];

    TCEND
}
- (void)didFinishedToGetUserFollowings:(NSDictionary *)results {
    TCSTART
    BOOL isResponseNull = YES;
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"followings"]] && [[results objectForKey:@"followings"] isKindOfClass:[NSArray class]]) {
        isResponseNull = NO;
    }
    
    if (caller_ && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToGetUserFollowings:)]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:isResponseNull],@"isResponseNull", nil];
        if (!isResponseNull) {
            [dict setObject:[results objectForKey:@"followings"] forKey:@"followings"];
        }
        [caller_ didFinishedToGetUserFollowings:dict];
    }
    TCEND
}
- (void)didFailToGetUserFollowingsWithError:(NSDictionary *)errorDict {
    TCSTART
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetUserFollowingsWithError:)]) {
        [caller_ didFailToGetUserFollowingsWithError:errorDict];
    }
    TCEND
}

#pragma amrk Wootag friends request and Delegate methods
- (void)getWootagFreindsWithUserId:(NSString *)userId {
    TCSTART
    NSDictionary *myPageRequest = [[NSDictionary alloc] initWithObjectsAndKeys: userId,@"userId",[NSNumber numberWithInt:pageNumber],@"pagenumber",requestURL,@"url",@"Wootagfriends",@"requestfor", nil];
    [self networkCall:myPageRequest];
    
    TCEND
}
- (void)didFinishedToGetWooTagFreinds:(NSDictionary *)results {
    TCSTART
    BOOL isResponseNull = YES;
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"wootagfriends"]] && [[results objectForKey:@"wootagfriends"] isKindOfClass:[NSArray class]]) {
        isResponseNull = NO;
    }
    
    if (caller_ && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToGetWooTagFreinds:)]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:isResponseNull],@"isResponseNull", nil];
        if (!isResponseNull) {
            [dict setObject:[results objectForKey:@"wootagfriends"] forKey:@"friends"];
        }
        [caller_ didFinishedToGetWooTagFreinds:dict];
    }
    TCEND
}
- (void)didFailToGetWooTagFreindsWithError:(NSDictionary *)errorDict {
    TCSTART
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetWooTagFreindsWithError:)]) {
        [caller_ didFailToGetWooTagFreindsWithError:errorDict];
    }
    TCEND
}


#pragma mark TagComment Users
- (void)getTagCommentUsersWithInputData:(NSDictionary *)userData {
    TCSTART
    NSDictionary *myPageRequest = [[NSDictionary alloc] initWithObjectsAndKeys: userData,@"comments",requestURL,@"url",@"tagusercomments",@"requestfor", nil];
   
    [self networkCall:myPageRequest];
    TCEND
}

- (void)didFinishedToGetTagCommentUsersInfo:(NSDictionary *)results {
    TCSTART
    BOOL isResponseNull = YES;
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"tag_user_comment"]] && [[results objectForKey:@"tag_user_comment"] isKindOfClass:[NSArray class]]) {
        isResponseNull = NO;
    }
    
    if (caller_ && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToGetTagCommentUsersInfo:)]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:isResponseNull],@"isResponseNull", nil];
        if (!isResponseNull) {
            [dict setObject:[results objectForKey:@"tag_user_comment"] forKey:@"tag_user_comment"];
        }
        [caller_ didFinishedToGetTagCommentUsersInfo:dict];
    }
    TCEND
}
- (void)didFailToGetTagCommentUsersInfoWithError:(NSDictionary *)errorDict {
    TCSTART
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetTagCommentUsersInfoWithError:)]) {
        [caller_ didFailToGetTagCommentUsersInfoWithError:errorDict];
    }
    TCEND
}

#pragma mark Suggested users
- (void)getSuggesdtedUsersForUserWithUserId:(NSString *)userId {
    TCSTART
    NSDictionary *sugReq = [[NSDictionary alloc] initWithObjectsAndKeys: userId,@"userId",requestURL,@"url",@"suggestedusers",@"requestfor",[NSNumber numberWithInt:pageNumber],@"pagenumber", nil];
    [self networkCall:sugReq];
    
    TCEND
}
- (void)didFinishedToGetSuggestedUsers:(NSDictionary *)results {
    TCSTART
    BOOL isResponseNull = YES;
    NSMutableArray *usersArray = [[NSMutableArray alloc] init];
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"suggested_users"]] && [[results objectForKey:@"suggested_users"] isKindOfClass:[NSArray class]]) {
        for (NSDictionary *userdict in [results objectForKey:@"suggested_users"]) {
            UserModal *user = [appDelegate returnUserModalObjectByParsing:userdict isLogdedInUser:NO];
            [usersArray addObject:user];
        }
        isResponseNull = NO;
    }
    
    if (caller_ && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToGetSuggestedUsers:)]) {
        NSDictionary *dict = nil;
        if (!isResponseNull) {
            dict = [NSDictionary dictionaryWithObjectsAndKeys:usersArray,@"users", nil];
        }
        [caller_ didFinishedToGetSuggestedUsers:dict];
    }
    TCEND
}
- (void)didFailToGetSuggestedUsersWithError:(NSDictionary *)errorDict {
    TCSTART
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetSuggestedUsersWithError:)]) {
        [caller_ didFailToGetSuggestedUsersWithError:errorDict];
    }
    TCEND
}

#pragma mark Social Network friends information
- (void)getSocialNetworkFriendInformation:(NSArray *)friendsArray userId:(NSString *)userId {
    TCSTART
    NSDictionary *socialReq = [[NSDictionary alloc] initWithObjectsAndKeys: userId,@"userId",requestURL,@"url",friendsArray,@"friends",@"socialusers",@"requestfor", nil];
    [self networkCall:socialReq];
    TCEND
}

- (void)didFinishedToGetSocialNetWorkFriendsInfo:(NSDictionary *)results {
    TCSTART
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToGetSocialNetWorkFriendsInfo:)]) {
        [caller_ didFinishedToGetSocialNetWorkFriendsInfo:results];
    }
    TCEND
}
- (void)didFailToGetSocialNetWorkFriendsInfoWithError:(NSDictionary *)errorDict {
    TCSTART
    if ([self isNotNull:caller_] && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailToGetSocialNetWorkFriendsInfoWithError:)]) {
        [caller_ didFailToGetSocialNetWorkFriendsInfoWithError:errorDict];
    }
    TCEND
}

#pragma mark 
#pragma mark Feedback
- (void)sendFeedbackWithText:(NSString *)feedbackText andUserId:(NSString *)userId andDeviceId:(NSString *)deviceId {
    TCSTART
    NSDictionary *reportRequest = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:userId,@"login_id",feedbackText,@"feedback",deviceId,@"device_id", nil],@"user",requestURL,@"url",@"feedback",@"requestfor", nil];
    [self networkCall:reportRequest];
    TCEND
}

- (void)didFinishedToSendFeedback:(NSDictionary *)results {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFinishedToSendFeedback:)]) {
        [caller_ didFinishedToSendFeedback:results];
    }
    
    TCEND
}
- (void)didFailedToSendFeedbackWithError:(NSDictionary *)errorDict {
    TCSTART
    if (caller_ && [caller_ conformsToProtocol:@protocol(UserServiceDelegate)] && [caller_ respondsToSelector:@selector(didFailedToSendFeedbackWithError:)]) {
        [caller_ didFailedToSendFeedbackWithError:errorDict];
    }
    TCEND
}

#pragma mark NetWork Call
- (void)networkCall:(NSDictionary *)requestParams {
    
    @try {
        // Create a network request
        NetworkConnection *networkConn = [[NetworkConnection alloc] init];
        
        if([[requestParams objectForKey:@"requestfor"] isEqualToString:@"mypage"]) {
            // thread call for mypage
            [NSThread detachNewThreadSelector:@selector(requestForMyPage:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if([[requestParams objectForKey:@"requestfor"] isEqualToString:@"otherpage"]) {
            // thread call for mypage
            [NSThread detachNewThreadSelector:@selector(requestForMyPage:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        }
        else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"follow"]){
           
            //thread call for follow.
            [NSThread detachNewThreadSelector:@selector(requestForUserFollow:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"unfollow"]){
            
            //thread call for unfollow.
            [NSThread detachNewThreadSelector:@selector(requestForUserUnfollow:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"unprivate"]){
            
            //thread call for unfollow.
            [NSThread detachNewThreadSelector:@selector(requestForUserUnPrivate:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"private"]){
            
            //thread call for unfollow.
            [NSThread detachNewThreadSelector:@selector(requestForUserPrivate:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"acceptprivate"]){
            
            //thread call for unfollow.
            [NSThread detachNewThreadSelector:@selector(requestForAcceptPrivateGroup:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"privateusers"]){
            
            //thread call for private users.
            [NSThread detachNewThreadSelector:@selector(requestForPrivateUsers:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"socialusers"]){
            //thread call for social users information.
            [NSThread detachNewThreadSelector:@selector(requestForSocialUsersInformation:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"followers"]){
            
            //thread call for followers.
            [NSThread detachNewThreadSelector:@selector(requestForUserFollowers:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        }  else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"followings"]){
            
            //thread call for followings.
            [NSThread detachNewThreadSelector:@selector(requestForUserFollowings:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        }  else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"suggestedusers"]){
            
            //thread call for followings.
            [NSThread detachNewThreadSelector:@selector(requestForSuggestedUsers:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"Wootagfriends"]){
            
            //thread call for private users.
            [NSThread detachNewThreadSelector:@selector(requestForWooTagFriends:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"tagusercomments"]){

            //thread call for followings.
            [NSThread detachNewThreadSelector:@selector(requestForTagCommentUsers:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
        } else if ([[requestParams objectForKey:@"requestfor"] isEqualToString:@"feedback"]){
            
            //thread call for followings.
            [NSThread detachNewThreadSelector:@selector(requestToSendFeedback:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:requestParams, @"params",self, @"caller",nil]];
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
