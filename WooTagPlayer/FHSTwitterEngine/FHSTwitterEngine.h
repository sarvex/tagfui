/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <Foundation/Foundation.h>

// These are for the dispatch_async() calls that you use to get around the synchronous-ness
#define GCDBackgroundThread dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define GCDMainThread dispatch_get_main_queue()

// Image sizes
typedef enum {
    FHSTwitterEngineImageSizeMini, // 24px by 24px
    FHSTwitterEngineImageSizeNormal, // 48x48
    FHSTwitterEngineImageSizeBigger, // 73x73
    FHSTwitterEngineImageSizeOriginal // original size of image
} FHSTwitterEngineImageSize;

typedef enum {
    FHSTwitterEngineResultTypeMixed,
    FHSTwitterEngineResultTypeRecent,
    FHSTwitterEngineResultTypePopular
} FHSTwitterEngineResultType;

// Remove NSNulls from NSDictionary and NSArray
// Credit for this function goes to Conrad Kramer
id removeNull(id rootObject);

extern NSString * const FHSProfileBackgroundColorKey;
extern NSString * const FHSProfileLinkColorKey;
extern NSString * const FHSProfileSidebarBorderColorKey;
extern NSString * const FHSProfileSidebarFillColorKey;
extern NSString * const FHSProfileTextColorKey;

extern NSString * const FHSProfileNameKey;
extern NSString * const FHSProfileURLKey;
extern NSString * const FHSProfileLocationKey;
extern NSString * const FHSProfileDescriptionKey;

extern NSString * const FHSErrorDomain;

@interface FHSToken : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *secret;
@property (nonatomic, strong) NSString *verifier;

+ (FHSToken *)tokenWithHTTPResponseBody:(NSString *)body;

@end

@protocol FHSTwitterEngineAccessTokenDelegate <NSObject>

- (NSString *)loadAccessToken;
- (void)storeAccessToken:(NSString *)accessToken;
@optional
- (void)cancelTwitterAuthentication;
@end

@interface FHSTwitterEngine : NSObject

//
// REST API
//

// statuses/update
- (NSError *)postTweet:(NSString *)tweetString;
- (NSError *)postTweet:(NSString *)tweetString inReplyTo:(NSString *)inReplyToString;

// statuses/home_timeline
- (id)getHomeTimelineSinceID:(NSString *)sinceID count:(int)count;

// help/test
- (id)testService;

// blocks/create
- (NSError *)block:(NSString *)username;

// blocks/destroy
- (NSError *)unblock:(NSString *)username;

// users/lookup
- (id)lookupUsers:(NSArray *)users areIDs:(BOOL)areIDs;

// users/search
- (id)searchUsersWithQuery:(NSString *)q andCount:(int)count;

// account/update_profile_image
- (NSError *)setProfileImageWithImageAtPath:(NSString *)file;
- (NSError *)setProfileImageWithImageData:(NSData *)data;

// account/settings GET and POST
// See FHSTwitterEngine.m For details
- (id)getUserSettings;
- (NSError *)updateSettingsWithDictionary:(NSDictionary *)settings;

// account/update_profile
// See FHSTwitterEngine.m for details
- (NSError *)updateUserProfileWithDictionary:(NSDictionary *)settings;

// account/update_profile_background_image
- (NSError *)setProfileBackgroundImageWithImageData:(NSData *)data tiled:(BOOL)isTiled;
- (NSError *)setProfileBackgroundImageWithImageAtPath:(NSString *)file tiled:(BOOL)isTiled;
- (NSError *)setUseProfileBackgroundImage:(BOOL)shouldUseProfileBackgroundImage;

// account/update_profile_colors
// See FHSTwitterEngine.m for details
// If the dictionary is nil, FHSTwitterEngine resets the values
- (NSError *)updateProfileColorsWithDictionary:(NSDictionary *)dictionary;

// application/rate_limit_status
- (id)getRateLimitStatus;

// favorites/create, favorites/destroy
- (NSError *)markTweet:(NSString *)tweetID asFavorite:(BOOL)flag;

// favorites/list
- (id)getFavoritesForUser:(NSString *)user isID:(BOOL)isID andCount:(int)count;
- (id)getFavoritesForUser:(NSString *)user isID:(BOOL)isID andCount:(int)count sinceID:(NSString *)sinceID maxID:(NSString *)maxID;

// account/verify_credentials
- (id)verifyCredentials;

// friendships/create
- (NSError *)followUser:(NSString *)user isID:(BOOL)isID;

// friendships/destroy
- (NSError *)unfollowUser:(NSString *)user isID:(BOOL)isID;

// friendships/lookup
- (id)lookupFriendshipStatusForUsers:(NSArray *)users areIDs:(BOOL)areIDs;

// friendships/incoming
- (id)getPendingIncomingFollowers;

// friendships/outgoing
- (id)getPendingOutgoingFollowers;

// friendships/update
- (NSError *)enableRetweets:(BOOL)enableRTs andDeviceNotifs:(BOOL)devNotifs forUser:(NSString *)user isID:(BOOL)isID;

// friendships/no_retweet_ids
- (id)getNoRetweetIDs;

// help/tos
- (id)getTermsOfService;

// help/privacy
- (id)getPrivacyPolicy;

// direct_messages
- (id)getDirectMessages:(int)count;

// direct_messages/destroy
- (NSError *)deleteDirectMessage:(NSString *)messageID;

// direct_messages/sent
- (id)getSentDirectMessages:(int)count;

// direct_messages/new
- (NSError *)sendDirectMessage:(NSString *)body toUser:(NSString *)user isID:(BOOL)isID;

// direct_messages/show
- (id)showDirectMessage:(NSString *)messageID;

// users/report_spam
- (NSError *)reportUserAsSpam:(NSString *)user isID:(BOOL)isID;

// help/configuration
- (id)getConfiguration;

// help/languages
- (id)getLanguages;

// blocks/blocking/ids
- (id)listBlockedIDs;

// blocks/blocking
- (id)listBlockedUsers;

// blocks/exists
- (id)authenticatedUserIsBlocking:(NSString *)user isID:(BOOL)isID;

// users/profile_image
- (id)getProfileImageForUsername:(NSString *)username andSize:(FHSTwitterEngineImageSize)size;

// get user profiel by userId
- (id)getUserProfileForUserId:(NSString *)userId;

// statuses/user_timeline
- (id)getTimelineForUser:(NSString *)user isID:(BOOL)isID count:(int)count;
- (id)getTimelineForUser:(NSString *)user isID:(BOOL)isID count:(int)count sinceID:(NSString *)sinceID maxID:(NSString *)maxID;

// statuses/retweet
- (NSError *)retweet:(NSString *)identifier;

// statuses/show
- (id)getDetailsForTweet:(NSString *)identifier;

// statuses/destroy
- (NSError *)destroyTweet:(NSString *)identifier;

// statuses/update_with_media
- (NSError *)postTweet:(NSString *)tweetString withImageData:(NSData *)theData;
- (NSError *)postTweet:(NSString *)tweetString withImageData:(NSData *)theData inReplyTo:(NSString *)irt;

// statuses/mentions_timeline
- (id)getMentionsTimelineWithCount:(int)count;
- (id)getMentionsTimelineWithCount:(int)count sinceID:(NSString *)sinceID maxID:(NSString *)maxID;

// statuses/retweets_of_me
- (id)getRetweetedTimelineWithCount:(int)count;
- (id)getRetweetedTimelineWithCount:(int)count sinceID:(NSString *)sinceID maxID:(NSString *)maxID;

// statuses/retweets
- (id)getRetweetsForTweet:(NSString *)identifier count:(int)count;

// lists/list
- (id)getListsForUser:(NSString *)user isID:(BOOL)isID;

// lists/statuses
- (id)getTimelineForListWithID:(NSString *)listID count:(int)count;
- (id)getTimelineForListWithID:(NSString *)listID count:(int)count sinceID:(NSString *)sinceID maxID:(NSString *)maxID;
- (id)getTimelineForListWithID:(NSString *)listID count:(int)count excludeRetweets:(BOOL)excludeRetweets excludeReplies:(BOOL)excludeReplies;
- (id)getTimelineForListWithID:(NSString *)listID count:(int)count sinceID:(NSString *)sinceID maxID:(NSString *)maxID excludeRetweets:(BOOL)excludeRetweets excludeReplies:(BOOL)excludeReplies;

// lists/members/create_all
- (NSError *)addUsersToListWithID:(NSString *)listID users:(NSArray *)users;

// lists/members/destroy_all
- (NSError *)removeUsersFromListWithID:(NSString *)listID users:(NSArray *)users;

// lists/members
- (id)listUsersInListWithID:(NSString *)listID;

// lists/update
- (NSError *)updateListWithID:(NSString *)listID name:(NSString *)name;
- (NSError *)updateListWithID:(NSString *)listID description:(NSString *)description;
- (NSError *)updateListWithID:(NSString *)listID mode:(BOOL)isPrivate;
- (NSError *)updateListWithID:(NSString *)listID name:(NSString *)name description:(NSString *)description mode:(BOOL)isPrivate;

// lists/show
- (id)getListWithID:(NSString *)listID;

// lists/create
- (NSError *)createListWithName:(NSString *)name isPrivate:(BOOL)isPrivate description:(NSString *)description;

// tweets/search
- (id)searchTweetsWithQuery:(NSString *)q count:(int)count resultType:(FHSTwitterEngineResultType)resultType unil:(NSDate *)untilDate sinceID:(NSString *)sinceID maxID:(NSString *)maxID;

// followers/ids
- (id)getFollowersIDs;

// followers/list
- (id)listFollowersForUser:(NSString *)user isID:(BOOL)isID withCursor:(NSString *)cursor;

// friends/ids
- (id)getFriendsIDs;

// friends/list
- (id)listFriendsForUser:(NSString *)user isID:(BOOL)isID withCursor:(NSString *)cursor;

//
// Login and Auth
//

// XAuth login
- (NSError *)getXAuthAccessTokenForUsername:(NSString *)username password:(NSString *)password;

// OAuth login
- (void)showOAuthLoginControllerFromViewController:(UIViewController *)sender;
- (void)showOAuthLoginControllerFromViewController:(UIViewController *)sender withCompletion:(void(^)(BOOL success))completionBlock;

// Access Token Mangement
- (void)clearAccessToken;
- (void)loadAccessToken;
- (BOOL)isAuthorized;

// API Key management
- (void)clearConsumer;
- (void)temporarilySetConsumerKey:(NSString *)consumerKey andSecret:(NSString *)consumerSecret; // key pair is used for one request
- (void)permanentlySetConsumerKey:(NSString *)consumerKey andSecret:(NSString *)consumerSecret; // key pair is used indefinitely

// id/username concatenator - returns an array of concatenated id/username lists
// 100 ids/usernames per concatenated string
- (NSArray *)generateRequestStringsFromArray:(NSArray *)array;

// never call -[FHSTwitterEngine init] directly
+ (FHSTwitterEngine *)sharedEngine; 

+ (BOOL)isConnectedToInternet;

@property (nonatomic, assign) BOOL includeEntities;
@property (nonatomic, strong) NSString *loggedInUsername;
@property (nonatomic, strong) NSString *loggedInID;
@property (nonatomic, strong) FHSToken *accessToken;

// called to retrieve or save access tokens
@property (nonatomic, weak) id<FHSTwitterEngineAccessTokenDelegate> delegate;

@end

@interface NSData (Base64)
- (NSString *)base64Encode;
@end

@interface NSString (FHSTwitterEngine)
- (NSString *)fhs_trimForTwitter;
- (NSString *)fhs_stringWithRange:(NSRange)range;
+ (NSString *)fhs_UUID;
- (BOOL)fhs_isNumeric;
@end

@interface NSError (FHSTwitterEngine)

+ (NSError *)badRequestError;
+ (NSError *)noDataError;
+ (NSError *)imageTooLargeError;

@end
