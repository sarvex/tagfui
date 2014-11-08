/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "Upload.h"
#import "UploadManager.h"
#import "ForgotPasswordViewController.h"
#import "LoginViewController.h"
#import "CustomMoviePlayerViewController.h"
#import "FHSTwitterEngine.h"
#import "TagService.h"
#import "UserModal.h"
#import "VideoModal.h"
#import "ProfileService.h"
#import "SWRevealViewController.h"
#import "VideoFeedAndMoreVideosViewController.h"
#import "PendingVideosViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UserService.h"
#import "IntroZonesViewController.h"
#import "Reachability.h"

@class UploadManager;
@class GTLServicePlus;

/** Enum for notification types
 */
typedef enum _NotificationType {
    Follow,
    Comment,
    UserTag,
    PrivateGroup,
    Like,
    AcceptPrivateGroup
} NotificationType;

/** enum for Analytics types
 */
typedef enum _AyanticsTagClicksOrShareId {
    VideoViewsOrFBShare,
    FacebookClicksorTwitterShare,
    GoogleClicksorGoogleShare,
    TwitterClicksorMailShare,
    ContactsShare,
    TagUrlClick
} AyanticsTagClicksOrShareId;

typedef enum _AyanticsInteractionsOrSocialPlatform {
    FB,
    GPlusorWriteOnWall,
    TWorFollow,
    AddFriend
} AyanticsInteractionsOrSocialPlatform;

//typedef void (^RequestVideoUploadWithCompletionHandler)(BOOL success, NSDictionary *response, NSError *error);

@protocol VideoUploadServiceDelegate <NSObject>

- (void)didFinishedToUploadVideoInfo:(NSDictionary *)resposneDict;
- (void)didFailToUploadVideoInfoWithError:(NSDictionary *)errorDict;


- (void)didFinishedToFileUploadVideoInfo:(NSDictionary *)resposneDict;
- (void)didFailToFileUploadVideoInfoWithError:(NSDictionary *)errorDict;

@end

@interface WooTagPlayerAppDelegate : UIResponder <UIApplicationDelegate,UploadManagerDelegate, TagServiceDelegate,ProfileServiceDelegate,SWRevealViewControllerDelegate,UserServiceDelegate,UIWebViewDelegate,VideoUploadServiceDelegate> {

    /** check for Persistent store coordinator is compatible with existing PSC, if not compatible then migration was happened and make a sync request with null.
     */
    BOOL pscCompatibile;
    
    /** IntrozonesViewcontroller is for to display first time app opens.
     */
    IntroZonesViewController *introzonesVC;
    
    /** LoginViewcontroller is for to display and login user
     */
    LoginViewController *loginViewController;
    
    /** After login MainScreen will be displayed with Home, Browse, Record, Notifications and Mypage tabs. Instead of UITabbarcontroller im using Viewcontroller because we need to present actionsheet instead view for record. This is totally for customization
     */
    MainViewController *mainVC;
    
    /** To display menu options
     */
    SWRevealViewController *revealController;
    
    id caller_;
    
    /** Maintaining loggedInUser info globally.
     */
    UserModal *loggedInUser;
    
    /** Send device token in Login, signup etc APIs if user allowed pushnotifications
     */
    NSString *deviceToken;
    
    /** To display progressview while exporting video when user click on upload button
     */
    NSTimer *exportProgressBarTimer;
    
    /** Maintaing uploadedVideoinfo to publish tags, Share to social network etc. after video uplaoded.
     */
    VideoModal *uploadedVideoModal;
    Upload *uploadedVideoInfo;
    
    /** If VideoFeedVC displaying then no need of showing alert with options (tag, share, cancel.)
     */
    BOOL isVideoFeedVCDisplays;
    
    /** Video export session
     */
    AVAssetExportSession *exportSessionRef;
    
    /** PendingVideosViewController showing all uploading, failed, waiting to uplaod videos.
     */
    PendingVideosViewController *pendingVideosVC;
    
    /** For opening website url of user In Mypage, OtherPage
     */
    UIView *websiteView;
    UIWebView *websiteWebView;
    BOOL isNetworkIndicator;
    
    /** FirstTimeUserExperience is for to disply toasts
     */
    FirstTimeUserExperience *ftue;
    
    /** Facebook readpermissions array
     */
    NSArray *facebookReadPermissions;
    
    /** Network reachability
      */
    Reachability* reachability;
    
    //Before userdata modal initilises saving social login authentication details
    NSMutableDictionary *socialContactsDictionary;
    
    /** Share and Playback Dictionary: when app coming from browser/TW/FB/G+ store userid and videoid and perform required actions (means play video or not)
     */
    NSMutableDictionary *shareNPlaybackDct;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) VideoFeedAndMoreVideosViewController *videoFeedVC;

/** PendingVideosViewController showing all uploading, failed, waiting to uplaod videos.
 */
@property (nonatomic, strong) PendingVideosViewController *pendingVideosVC;

/** FirstTimeUserExperience is for to disply toasts
 */
@property (nonatomic, retain) FirstTimeUserExperience *ftue;

/** To display menu options
 */
@property (nonatomic, retain) SWRevealViewController *revealController;

/** Facebook readpermissions array
 */
@property (nonatomic, retain) NSArray *facebookReadPermissions;

@property (nonatomic, retain) id caller_;

/** instance of FHSTwitterEngine class, contains the accesstoken & secret key and also contains the methods required to authenicate user and to check whther autheriztion required or not.
 */
@property (nonatomic, retain) FHSTwitterEngine *twitterEngine;

//@property (strong, nonatomic) NSMutableArray *tags;

/** Coredata related context, objectmodel and persistentstore coordinator
 */
@property (readwrite, strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (readwrite, strong, nonatomic) NSManagedObjectModel   * managedObjectModel;
@property (readwrite, strong, nonatomic) NSPersistentStoreCoordinator * persistentStoreCoordinator;


@property (readwrite, nonatomic) BOOL isUploading;
@property (readwrite, nonatomic) BOOL isVideoFeedVCDisplays;
@property (readwrite, nonatomic) BOOL isRecordingScreenDisplays;
@property (readwrite, nonatomic) BOOL isVideoExporting;
@property (readwrite, nonatomic) BOOL isVideoRecording;

/** Maintaining loggedInUser info globally.
 */
@property (nonatomic, retain) UserModal *loggedInUser;

- (NSString *)getUDID;
- (int)generateUniqueId;
- (NSString *)generateUniqueVideoId;
- (NSMutableString *)formattedGMTDateInString;
- (NSString *)getApplicationDocumentsDirectoryAsString;

/** To know network is off or on
 */
- (BOOL)statusForNetworkConnectionWithOutMessage;

/** Create and set RootViewToController to window when user not loggedin
 */
- (void)createAndSetLogingViewControllerToWindow;

/** For signup
 */
- (void)pushToRegistrationViewController;
//-(void)requestVideoUpload:(Upload *)upload withCompletionHandler:(RequestVideoUploadWithCompletionHandler)completionHandler;

- (void)setLeftPaddingforTextField:(UITextField *)textfield;

/** Login through Social networking sites
 */
- (void)loginThroughFacebookFromCaller:(id)callerVC;
- (void)loginThroughTwitterFromViewController:(UIViewController *)VC;
- (void)loginThroughGooglePlus;

/** signUp User inititalizes profile controller class and makes a network call to signup the user by passing required fields.
 */
-(void)signUpUser:(NSString *)userFullName withEmail:(NSString *)email withPassword:(NSString *)password;

-(void)loginUser:(NSString *)userName password:(NSString *)password;

-(void)loginUserThroughSocialNetworkingSitesWithUserName:(NSDictionary *)userinfo;
/** makes a request to server to send a newpassword to the specified mail id.
 */
-(void)sendNewPasswordToEmail:(NSString *)emailAddress fromViewController:(ForgotPasswordViewController *)forgotPasswordVC;

/** Makes a request to server to change password
 */
-(void)changePassword:(NSString *)currentPassword changedPassword:(NSString *)changedPWD andCaller:(id)caller;

/** Video upload
 */
- (void)uploadVideo;

/** Color Converter
 */
-(UIColor*)colorWithHexString:(NSString*)hex;
- (NSString *)colorNameWithHexString:(NSString *)hexString;
- (NSString *)HexStringFromColorName:(NSString *)colorName;
- (NSString *)stringFromColorLabelTag:(int )tag;
- (int)getColorLblTag:(NSString *)colorName;

- (void)setRoundedCornersToButton:(UIButton *)btn;
-(void) setMaskTo:(UIView*)view byRoundingCorners:(UIRectCorner)corners withRadii:(CGSize)Radii;

//shows the network indicator which will be shown on status bar.
-(void)showNetworkIndicator;
//hide the network indicator
-(void)hideNetworkIndicator;

/** shows an acitvity indicator in the provided view, it blocks the screen actions.Tabbar and naviagation bar actions are not blocked.View object shouldn't be nil or NULL.
 */
-(void)showActivityIndicatorInView:(UIView *)view andText:(NSString *)text;

/*hides the activity indicator from the provide view.View object shouldn't be nil or NULL.*/
-(void)removeNetworkIndicatorInView:(UIView *)view;

- (void)initializeTwitterEngineWithDelegate:(id)delegate;
- (void)authenticateTwitterAccountWithDelegate:(id)viewController andPresentFromVC:(CustomMoviePlayerViewController *)VC;


/** AddTags Request
 */
- (void)makeAddTagsRequestWithCaller:(id)caller ofUserWithUserId:(NSString *)userId;
- (void)AddTagsRequestWithCallBackObject:(id)caller andTagsArray:(NSArray *)tagsArray ofUserWithUserId:(NSString *)userId;

/** Update Tags
 */
- (void)makeUpdateTagsRequestCaller:(id)caller;

/** Delete Tag Request
 */
- (void)makeDeleteTagRequestWithTagId:(NSString *)tagId andCaller:(id)caller;

/*** Playback request
 */
- (void)requestForPlayBackWithVideoId:(NSString *)videoId andcaller:(id)caller andIndexPath:(NSIndexPath *)indexPath refresh:(BOOL) requstForRefresh;

/** MyPage Request of User with UserId
 */
- (void)makeMypageRequestWithUserId:(NSString *)userId andCaller:(id)caller;

/** Other user page Request of user with other userid
 */
- (void)makeOtherUserRequestWithOtherUserId:(NSString *)userId pageNumber:(NSInteger)pageNum andCaller:(id)caller;

/** User Followings Request for user specified in the argument
 */
- (void)makeRequestForUserFollowingsWithUserId:(NSString *)userId pageNumber:(NSInteger)pagenumber andCaller:(id)caller;

/** User Followers Request for user specified in the argument
 */
- (void)makeRequestForUserFollowersWithUserId:(NSString *)userId  pageNumber:(NSInteger)pagenumber andCaller:(id)caller;

/** Wootag friends list to tag in player screen.list contains Private group users and followings
 */
- (void)makeRequestForWooTagFreindsWithUserId:(NSString *)userId pageNumber:(NSInteger)pagenumber andCaller:(id)caller;

/** User follow request with userId: Currently logged in user and followerId:UserId of user whom you want to follow
 */
- (void)makeFollowUserWithUserId:(NSString *)userId followerId:(NSString *)followerId andCaller:(id)caller  andIndexPath: (NSIndexPath *)indexPath;

/** User unfollow request with userId: Currently logged in user and followerId:UserId of user whom you want to unfollow
 */
- (void)makeUnFollowUserWithUserId:(NSString *)userId followerId:(NSString *)followerId andCaller:(id)caller andIndexPath: (NSIndexPath *)indexPath;

/** Delete Request for user video with specified videoId and  userId
 */
- (void)makeRequestForDeleteVideoWithVideoId:(NSString *)videoId andUserId:(NSString *)userId andCaller:(id)caller atIndexpath:(NSIndexPath *)indexPath;

/** Report video request for user uploade video with specified videoId and UserId
 */
- (void)makeRequestForReportVideoWithVideoId:(NSString *)videoId andCaller:(id)caller andReason:(NSString *)reason;

/** Make request to send feedback
 */
- (void)makeRequestToSendFeedBack:(NSString *)feedbackText andCaller:(id)caller;

/** Like Request for user video with specified videoId and  userId
 */
- (void)makeRequestForLikeVideoWithVideoId:(NSString *)videoId andCaller:(id)caller andIndexPaht:(NSIndexPath *)indexPath;

/** UnLike Request for user video with specified videoId and  userId
 */
- (void)makeRequestForUnLikeVideoWithVideoId:(NSString *)videoId andCaller:(id)caller andIndexPaht:(NSIndexPath *)indexPath;

/** Make Request For All Comments of Video with specified videoId in the argument
 */
- (void)getAllCommentsOfVideoWithVideoId:(NSString *)videoId andCaller:(id)caller andIndexPath:(NSIndexPath *)indexPAth pageNumber:(NSInteger) pageNumber;

/** Post comment to video of specifed videoid with comment text
 */
- (void)makePostCommentRequestForVideo:(NSString *)videoId withCommentText:(NSString *)commentText andCaller:(id)caller andIndexPath:(NSIndexPath *)indexPath;

/** Delete comment of video with specified commentId
 */
- (void)makeDeleteCommentRequestForVideoWithcmntId:(NSString *)cmntId andCaller:(id)caller andIndexPath:(NSIndexPath *)indexPath;

/** Make request for load more videos of user of userId by specifiying pagenumber and page size
 */
- (void)makeRequestForMypageVideosPageNumber:(NSInteger)pageNumber perPage:(NSInteger) perPage andCaller:(id)caller;

- (NSString *)removingLastSpecialCharecter:(NSString *)str;

- (NSIndexPath *)getIndexPathForEvent:(UIEvent *)event ofTableView:(UITableView *)tableView;

- (BOOL)validateEmailWithString:(NSString*)email WithIdentifier:(NSString*)identifier;

- (UserModal *)getLoggedInUser;

/** Request for logout.Clear all User data
 */
- (void)logoutRequestFromApp;

/** Add circle to imageView
 */
- (void)addCircleToTheImageView:(UIImageView *)imageView ;

/** Make browse request with selected type
 */
- (void)makeRequestForBrowseOfType:(NSString *)browseType pageNumber:(NSInteger)pageNumber perPage:(NSInteger) perPage andCaller:(id)caller;

/** Make request for browse trends
 */
- (void)makeRequestForTrendsPageNumber:(NSInteger)pageNumber andCaller:(id)caller;

/** Make request for trends detials
 */
- (void)makeRequestForTrendsDetailsWithPageNumber:(NSInteger)pageNumber andTagName:(NSString *)tagName andCaller:(id)caller;

/** Make search with search string of browse type
 */
- (void)makeRequestForBrowseSearchWithString:(NSString *)searchString ofBrowseType:(NSString *)browseType pageNumber:(NSInteger)pageNumber perPage:(NSInteger) perPage andCaller:(id)caller;

/** Make request to get video details to show browse detailpage.
 */
- (void)makeRequestForBrowseDetailOfVideo:(NSString *)videoId andUserId:(NSString *)userId pageNumber:(NSInteger)pageNumber andCaller:(id)caller;

/** Make request to otherstuff of user by userid
 */
- (void)makeRequestForOtherStuffOfUserId:(NSString *)userId pageNumber:(NSInteger)pageNumber andCaller:(id)caller;

/** Make search request in screens except browse
 */
- (void)makeRequestForSearchWithString:(NSString *)searchString ofSearchType:(NSString *)searchType pageNumber:(NSInteger)pageNumber anduserId:(NSString *)userId andCaller:(id)caller;

- (void)deleteUserManagedObject:(User *)user;

/** Video Permission change request
 */
- (void)makeRequestVideoPermissionsChangeVideoId:(NSString *)videoId permission:(int)permission andCaller:(id)caller;

/** Make All Likes Request
 */
- (void)getAllLikesListOfVideoWithVideoId:(NSString *)videoId andCaller:(id)caller andIndexPath:(NSIndexPath *)indexPath andPageNumber:(NSInteger)pageNumber;

/** Make suggested users request
 */
- (void)makeSuggestedUsersRequestWithUserId:(NSString *)userId  andCaller:(id)caller pageNum:(NSInteger) pageNumber;

/** Make Videofeed request
 */
- (void)makeVideoFeedRequestWithPageNumber:(NSInteger)pageNumber pageSize:(NSInteger)pageSize andCaller:(id)caller;

/** Make Private feed request
 */
- (void)makePrivateFeedRequestWithPageNumber:(NSInteger)pageNumber pageSize:(NSInteger)pageSize andCaller:(id)caller;

/** Video Sharing
 */
// Facebook sharing
//- (void)shareVideoToFaceBookFriendWithVideoInfo:(VideoModal *)video andFriendFBId:(NSString *)fbId;

//Twitter Sharing
- (void)PostToTwitterWithMsg:(NSString *)msg toUser:(NSString *)userid withImageUrl:(NSString *)imageURL andVideoId:(NSString *)videoId;

/** Invitaiton to Wootag
 */
- (void)sendInvitationtoFaceBookFriendWithParams:(NSMutableDictionary *)params;

- (NSString *)returningPluralFormWithCount:(NSInteger)count;
- (NSString *)getUserStatisticsFormatedString:(unsigned long long)userStatisticsCount;

/** Parsing
 */
- (VideoModal *)returnVideoModalObjectByParsing:(NSDictionary *)videoFields;
- (UserModal *)returnUserModalObjectByParsing:(NSDictionary *)userFields isLogdedInUser:(BOOL)loggedUser;

/** Private the specified user with PrivateUserId
 */
- (void)makePrivateUserWithUserId:(NSString *)userId privateUserId:(NSString *)privateUserId andCaller:(id)caller andIndexPath: (NSIndexPath *)indexPath;

/** Unprivate the specified user with PrivateUserId
 */
- (void)makeUnPrivateUserWithUserId:(NSString *)userId privateUserId:(NSString *)privateUserId andCaller:(id)caller andIndexPath: (NSIndexPath *)indexPath;

/** Make request for private users
 */
- (void)makeRequestForPrivateUsersWithUserId:(NSString *)userId pageNumber:(NSInteger)pagenumber andCaller:(id)caller;

/** Make request for pending private users
 */
- (void)makeRequestForPendingPrivateUsersWithUserId:(NSString *)userId pageNumber:(NSInteger)pagenumber andCaller:(id)caller;

/** Moving Loggedin user object to First index
 */
- (void)moveLoggedInUserToTopInLikesListOfVideoModal:(VideoModal *)videoModal;

/** cancel export when simultaneous occurance of saving recorded video and compression
 */
- (void)cancelExport;

/** Getting infomation about social network friends (means he is already using wootag or not.)
 */
- (void)makeSocialFriendsInfoRequestWithUserId:(NSString *)userId  andCaller:(id)caller friendsList:(NSArray *)list;

- (NSString *)relativeDateString:(NSString *)serverDateStr;

/** Get User Notiifcations
 */
- (void)getLoggedInUserNotificationsWithCaller:(id)caller;

/** Remove Logged in userid notification given by other user
 */
- (void)removeLoggedInUserNotificationWithNotificationId:(NSString *)notificationId andCaller:(id)caller;

/** Video details
 */
- (void)getVideoDetailsOfVideoId:(NSString *)videoId notificationType:(NotificationType)notificationType indexPath:(NSIndexPath *)indexPath andCaller:(id)caller;

/** Accepting private user request
 */
- (void)makeAcceptPrivateUserWithUserId:(NSString *)userId privateUserId:(NSString *)privateUserId andCaller:(id)caller andIndexPath: (NSIndexPath *)indexPath;

/** Deciding text (like/likes) based on number of likes of videos throught out app
 */
- (NSString *)returningPluralFormWithCountForLikes:(NSInteger)count;

/** To send B'day wishes to tagged user in tag interaction
 */
- (BOOL)isFacebookBirthDateMathesToday:(NSString *)birthDayString;
- (BOOL)isGooglePlusBirthDateMathesToday:(NSString *)birthDayString;

/** To display last update time of tagged user in tag interactions
 */
- (NSString *)facebookLastUpdateDateStringFromMillisecondsTime:(NSString *)string;
- (NSString *)twitterLastUpdateDateString:(NSString *)string;

/** To save loggedin user in defaults to avoid login every time app opens until unless user loggedout
 */
- (void)saveLoggedUserData:(UserModal *)userModal;

/** To crop image to specified rect
 */
- (UIImage*)getImageByCroppingImage:(UIImage *)imageToCrop toRect:(CGRect)rect;

/** Facebook logout
 */
- (void)facebookLogout;

/** Make request to get loggedinuser detials (account settings)
 */
- (void)getAccountDetialsOfLoggedInUserWithCaller:(id)caller;

/** Make request to update user profile
 */
- (void)updateProfileOfLoggedInUserWithCaller:(id)caller withUserInfo:(NSDictionary *)dict;

/** Make request to get tag usercomments
 */
- (void)makeRequestForTagUserCommentsWithData:(NSDictionary *)reqData andCaller:(id)caller;

/** To display full profile pic of user in Mypage and otherPage
 */
- (NSString *)getUserFullImageURLbyPhotoPath:(NSString *)profilePicUrl;

/** To
 */
- (void)openWebviewWithURL :(NSString *)websiteURL;
- (BOOL) validateUrl: (NSString *) url;
- (BOOL)validateUrl:(NSString *)url andcheckingTypes:(NSTextCheckingTypes)type;

/** Attributed string format for notificaitons text
 */
- (NSMutableAttributedString *)getAttributedStringForString:(NSString *)text withBoldRanges:(NSArray *)boldRangesArray WithBoldFontName:(NSString *)boldfontName withNormalFontName:(NSString *)normalFontName italicRangesArray:(NSArray *)italicRangesArray;
- (CGSize)getFrameSizeForAttributedString:(NSAttributedString *)attributedString withWidth:(NSInteger)width;
- (NSMutableDictionary *)getTextLayerTextAnimationStopProperties;

/** Not adding notification which are created before 7 days.
 */
- (BOOL)isNotificationCreatedTimeIsLessThanOrEqual7Days:(NSString *)serverDateStr;

/** First time user experience Toasts
 */
- (UIView *)getToastViewWithMessageText:(NSString *)message andFrame:(CGRect)frame;

- (NSString *)relativeVideoCreatedDateString:(NSString *)serverDateStr;
- (void)showVideoFeedScreenWithUploadProgressBar;

/** Notifications
 */
- (void)getNotificationsSettingsCaller:(id)caller;
- (void)updateNotificationsSettingsWithParameters:(NSDictionary *)dict andCaller:(id)caller;

/** Make search request for notificaitons
 */
- (void)makeNotificaitonsSearchRequestWithSearchKeyword:(NSString *)searchKeyword andCaller:(id)caller;

/** Notify to tagged social contact user after tag published
 */
- (void)shareVideoInformationToSocialSites:(VideoModal *)videoModal andTag:(NSArray *)tagsArray;
- (void)postToFacebookUserWallWithOutDialog:(VideoModal *)videoModal andToId:(NSString *)userId;
- (void)shareToGooglePlusUserWithUserId:(NSArray *)friendsIdsArray andVideo:(VideoModal *)selectedVideo;
- (void) performPublishAction:(void (^)(void)) action;

- (void)writeLog:(NSString *)logString;

/** Getting Phone contacts
 */
- (BOOL)getAccessPermission;
- (NSMutableArray *)getAddressBookContacts;

/** Make Ayantics request : same method for tag clicks and share so need to pass isForShare:no when req make for tagclicks
 */
- (void)makeRequestForAnalyticsOfVideo:(NSString *)videoId analyticsTagClicksOrShareId:(AyanticsTagClicksOrShareId)ayanticsClicksShareId analyticsTagInteractions:(AyanticsInteractionsOrSocialPlatform)interactionsId socialPlatform:(AyanticsInteractionsOrSocialPlatform)socialPlatform isForShare:(BOOL)isForShare isReqForInteractions:(BOOL)isForInteraction shareCount:(int)shareCount;

- (void) performManageAction:(void (^)(void)) action;
- (void)openPhoneApp:(NSString *)phoneNumber;

/** Product buy request
 */
- (void)productBuyRequestWithParameters:(BuyerInfo *)buyerInfo withCaller:(id)caller;

/** Getting list products of loggedin user
 */
- (void)getListOfProductsWithCaller:(id)caller;

/** Get list of purchase request of particular product by mentioning productid of loggedin user
 */
- (void)getPurchaseRequestsOfProductWithProductId:(NSString *)productId andCaller:(id)caller;

#define NOTIFY_UPDATED_TAG_COLOR @"TagColorUpdated"
#define NOTIFY_TAG_PUBLISH @"PublishTag"
#define NOTIFY_TAGTOOL_CANCEL @"TagToolCanceled"
#define NOTIFY_TAG_EDIT @"TagEdit"

@end
