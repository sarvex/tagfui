/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>
#import "WooTagPlayerAppDelegate.h"
@protocol UserServiceDelegate <NSObject>

@optional

//Mypage
- (void)didFinishedToGetMypageDetails:(NSDictionary *)results;
- (void)didFailToGetMypageDetailsWithError:(NSDictionary *)errorDict;

//Followings
- (void)didFinishedToGetUserFollowings:(NSDictionary *)results;
- (void)didFailToGetUserFollowingsWithError:(NSDictionary *)errorDict;

//Followers
- (void)didFinishedToGetUserFollowers:(NSDictionary *)results;
- (void)didFailToGetUserFollowersWithError:(NSDictionary *)errorDict;

//Follow
- (void)didFinishedToFollowUser:(NSDictionary *)results;
- (void)didFailToFollowUserWithError:(NSDictionary *)errorDict;

//Unfollow
- (void)didFinishedToUnFollowUser:(NSDictionary *)results;
- (void)didFailToUnFollowUserWithError:(NSDictionary *)errorDict;

//Suggested users
- (void)didFinishedToGetSuggestedUsers:(NSDictionary *)results;
- (void)didFailToGetSuggestedUsersWithError:(NSDictionary *)errorDict;

//Unprivate user
- (void)didFinishedToUnPrivateUser:(NSDictionary *)results;
- (void)didFailToUnPrivateUserWithError:(NSDictionary *)errorDict;

//Private user
- (void)didFinishedToPrivateUser:(NSDictionary *)results;
- (void)didFailToPrivateUserWithError:(NSDictionary *)errorDict;

//Accept Private Group
- (void)didFinishedToAcceptPrivateUser:(NSDictionary *)results;
- (void)didFailToAcceptPrivateUserWithError:(NSDictionary *)errorDict;

//List of private users
- (void)didFinishedToGetPrivateUsers:(NSDictionary *)results;
- (void)didFailToGetPrivateUsersWithError:(NSDictionary *)errorDict;

//Get social network friend information (means whether he is wootag or not)
- (void)didFinishedToGetSocialNetWorkFriendsInfo:(NSDictionary *)results;
- (void)didFailToGetSocialNetWorkFriendsInfoWithError:(NSDictionary *)errorDict;

//Get tagcomment users
- (void)didFinishedToGetTagCommentUsersInfo:(NSDictionary *)results;
- (void)didFailToGetTagCommentUsersInfoWithError:(NSDictionary *)errorDict;

// Sent Feedback
- (void)didFinishedToSendFeedback:(NSDictionary *)results;
- (void)didFailedToSendFeedbackWithError:(NSDictionary *)errorDict;

@end

@interface UserService : NSObject <UserServiceDelegate> {
    id caller_;
    NSString *requestURL;       //set the host URL
    NSString *userId_;
    NSString *followerId_;
    NSInteger pageNumber;
    WooTagPlayerAppDelegate *appDelegate;
    NSIndexPath *indexPath;
    BOOL requestforMypage;
}
@property (nonatomic, retain) NSString *requestURL;
@property (nonatomic, readwrite) NSInteger pageNumber;
@property (nonatomic, retain) NSIndexPath *indexPath;
- (id)initWithCaller:(id)caller;

- (void)getSuggesdtedUsersForUserWithUserId:(NSString *)userId;
- (void)getMyPageDetailsOfUserWithUserId:(NSString *)userId;
- (void)getOtherUserPageDetailsOfUserWithUserId:(NSString *)userId andLoggedInUserID:(NSString *)loggedInUserId;

- (void)followRequestWithUserId:(NSString *)userId andFollowerId:(NSString *)followerId;
- (void)unFollowUserRequestWithUserId:(NSString *)userId andFollowerId:(NSString *)followerId;

- (void)unPrivateUserRequestWithUserId:(NSString *)userId andPrivateUserId:(NSString *)privateUserId;
- (void)privateRequestWithUserId:(NSString *)userId andPrivateUserId:(NSString *)privateUserId;

- (void)getFollowersOfUserWithUserId:(NSString *)userId;
- (void)getFollowingsOfUserWithUserId:(NSString *)userId;
- (void)getPrivateUsersOfUserWithUserId:(NSString *)userId;
- (void)getPendingPrivateUsersOfUserWithUserId:(NSString *)userId;

- (void)getSocialNetworkFriendInformation:(NSArray *)friendsArray userId:(NSString *)userId;

- (void)acceptPrivateGroupRequestWithUserId:(NSString *)userId andPrivateOtherUserId:(NSString *)otherUserId;
- (void)getTagCommentUsersWithInputData:(NSDictionary *)userData;
- (void)getWootagFreindsWithUserId:(NSString *)userId;

- (void)sendFeedbackWithText:(NSString *)feedbackText andUserId:(NSString *)userId andDeviceId:(NSString *)deviceId;
@end
