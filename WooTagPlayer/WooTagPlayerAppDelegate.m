/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "WooTagPlayerAppDelegate.h"
#import "NSObject+PE.h"
#import "OAToken.h"
#import "NSDate+Helper.h"
#import "Reachability.h"
#import <CoreText/CoreText.h>
#import "NSData+MD5.h"

#import "CustomMoviePlayerViewController.h"
#import "OpenUDID.h"

#import "MainViewController.h"
#import "MenuViewController.h"
#import "ShareViewController.h"
#import "AccountSettingsviewController.h"

#import "TagService.h"
#import "UserService.h"
#import "VideoService.h"
#import "BrowseService.h"
#import "NotificationService.h"

#import "VideoModal.h"
#import "UserModal.h"

#import "SBJson.h"

#import "NetworkConnection.h"

#import <GoogleOpenSource/GoogleOpenSource.h>

#import <AddressBook/AddressBook.h>

#import <Crashlytics/Crashlytics.h>

//http://api.tagmoments.com/mobile.php/wings
#define VIDEO_UPLOAD [NSString stringWithFormat:@"%@/uploadvideo",APP_URL]

#define MULTIPART_VIDEO_UPLOAD [NSString stringWithFormat:@"%@/upload_video_parts",APP_URL]
#define VIDEOUPLOAD [NSString stringWithFormat:@"%@/upload_video",APP_URL]
#define FILEUPLOAD [NSString stringWithFormat:@"%@/fileupload",APP_URL]

@interface WooTagPlayerAppDelegate () <FBLoginViewDelegate,FHSTwitterEngineAccessTokenDelegate,GPPSignInDelegate> {
    CustomMoviePlayerViewController *customMoviePlayerVC;
}

@end
@implementation WooTagPlayerAppDelegate
@synthesize twitterEngine = _twitterEngine;

//@synthesize tags;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize isUploading;
@synthesize loggedInUser;
@synthesize videoFeedVC;
@synthesize isVideoFeedVCDisplays;
@synthesize isVideoExporting;
@synthesize isRecordingScreenDisplays;
@synthesize pendingVideosVC;
@synthesize caller_;
@synthesize facebookReadPermissions;
@synthesize ftue;
@synthesize isVideoRecording;
@synthesize revealController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    TCSTART
    [self removeClientVideoIdFromDefaultsToSupportForVersion1Updation];
    socialContactsDictionary = [[NSMutableDictionary alloc] init];
    [[UIActivityIndicatorView appearance] setColor:[self colorWithHexString:@"11a3e7"]];
    [self checkAndCreateUDID];
    [Base64Converter initialize];
    
    //    isLoadingViewHiddenForParticularVideo = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification object:nil];
    
    // Set up Reachability
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    [self createFirstTimeUserExprienceEntityInDBifNotExists];
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    
    [self createDirectoryInDocumentsFolderWithName:@"HQVideos"];
    
    [[UploadManager sharedUploadManager] addDelegate:self];
    
    loggedInUser = [self getLoggedInUser];
    NSLog(@"%d",[[NSUserDefaults standardUserDefaults] boolForKey:@"IntroZonesDisplayed"]);
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"IntroZonesDisplayed"]) {
        [self createIntroZonesViewControllerToWindow];
    } else {
        if ([self isNull:loggedInUser]) {
            [self createAndSetLogingViewControllerToWindow];
        } else {
            [self didFinishedToGetMypageDetails:nil];
        }
    }
    
    [self loginViewForFB];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    //    [Crashlytics startWithAPIKey:@"d770244383304eed30038e2d88c835799de900db"];
    [Crashlytics startWithAPIKey:@"d770244383304eed30038e2d88c835799de900db"];
    [self.window makeKeyAndVisible];
    //    [self googlePlusWithVideoModal:nil];
    return YES;
    TCEND
}

- (void)removeClientVideoIdFromDefaultsToSupportForVersion1Updation {
    TCSTART
    NSLog(@"value :%d",[[NSUserDefaults standardUserDefaults] boolForKey:@"versionupdated"]);
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"versionupdated"]) {
        
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"versionupdated"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"clientVideoid"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"partNumber"];
    }
    TCEND
}

/** Reachability checking
 */
- (void)reachabilityChanged:(NSNotification*)notification {
    reachability = notification.object;
    if(reachability.currentReachabilityStatus == NotReachable)
        NSLog(@"Internet off");
    else {
        NSLog(@"Internet on");
        if ([self isNotNull:loggedInUser] && [self isNotNull:loggedInUser.userId]) {
            [self uploadVideo];
            [self makeAddTagsRequestWithCaller:self ofUserWithUserId:loggedInUser.userId];
        }
    }
}

- (void)createFirstTimeUserExprienceEntityInDBifNotExists {
    ftue = [[DataManager sharedDataManager] createFirstTimeUserExprience];
}

#pragma mark APNS (Remote Notifications) Delegate Methods.===============================================
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToke {
    @try {
        NSString *deviceTkn = [NSString stringWithFormat:@"Device Token=%@",deviceToke];
        NSString *newTkn = [deviceTkn substringWithRange:NSMakeRange(14,71)];
        NSLog(@"My token from delegate class is: %@ new token is %@", deviceTkn,newTkn);
        if([self isNotNull:newTkn]){
            deviceToken = newTkn;
            NSLog(@"Device Token:%@",deviceTkn);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    NSLog(@"Failed to get token from delegate, error: %@", error);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    TCSTART
    NSLog(@"didReceiveRemoteNotification %@",userInfo);
    if ([self isNotNull:[userInfo objectForKey:@"notification_id"]]) {
        if ([[userInfo objectForKey:@"notification_id"] intValue] == 7) {
            mainVC.videofeedIndicatorLbl.hidden = NO;
            [mainVC refreshVideofeed:YES NotificationsScreen:NO];
        } else {
            mainVC.notificationsIndicatorLbl.hidden = NO;
            [mainVC refreshVideofeed:NO NotificationsScreen:YES];
        }
    }
    TCEND
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"didReceiveLocalNotification %@",notification);
}

- (void)checkAndCreateUDID {//hardcoded code and mobile number
    TCSTART
	NSString * UDID = [[NSUserDefaults standardUserDefaults]objectForKey:@"UDID"];
	if([self isNull:UDID]) {
		UDID = [OpenUDID value];
		[[NSUserDefaults standardUserDefaults] setObject:UDID forKey:@"UDID"];
	}
    TCEND
}

- (void)createIntroZonesViewControllerToWindow {
    TCSTART
    introzonesVC = [[IntroZonesViewController alloc] initWithNibName:@"IntroZonesViewController" bundle:nil];
    if ([self.window respondsToSelector:@selector(setRootViewController:)]) { // >= ios4.0
        [self.window setRootViewController:introzonesVC];
    } else { // < ios4.0
        [self.window addSubview:introzonesVC.view];
    }
    
    TCEND
}
- (void)createAndSetLogingViewControllerToWindow {
    @try {
        if ([self isNotNull:introzonesVC]) {
            [introzonesVC removeFromParentViewController];
            [introzonesVC.view removeFromSuperview];
            introzonesVC = nil;
        }
        
        loginViewController = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        
        UINavigationController *loginNavigationController = [[UINavigationController alloc]initWithRootViewController:loginViewController];
        loginNavigationController.navigationBar.hidden = YES;
        
        if ([self.window respondsToSelector:@selector(setRootViewController:)]) { // >= ios4.0
            [self.window setRootViewController:loginNavigationController];
        } else { // < ios4.0
            [self.window addSubview:loginNavigationController.view];
        }
        loginNavigationController = nil;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)pushToRegistrationViewController {
    TCSTART
    [self createAndSetLogingViewControllerToWindow];
    [loginViewController signUpViewControllerNeedToHideCancelButton:YES];
    TCEND
}
- (void)setAndUpdateAllClientVideoIdTagsToVideoId:(NSArray *)tagsArray videoId:(NSString *)videoId {
    TCSTART
    for (Tag *tag in tagsArray) {
        tag.videoId = videoId;
        BuyerInfo *buyer = [[DataManager sharedDataManager] getBuyerInfoByTagIdOrClientTagId:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",tag.clientTagId.intValue],@"clientTagId", nil]];
        buyer.videoId = videoId;
    }
    [[DataManager sharedDataManager] saveChanges];
    [self makeAddTagsRequestWithCaller:self ofUserWithUserId:loggedInUser.userId];
    TCEND
}

- (void)makeAddTagsRequestWithCaller:(id)caller ofUserWithUserId:(NSString *)userId {
    TCSTART
    if ([self isNotNull:userId] && [userId integerValue] != 0) {
        NSArray *tagsArray = [[DataManager sharedDataManager] getAddedTagsArrayAndWaitingForPostWithUserId:userId];
        NSMutableArray *tagsMArray = [[NSMutableArray alloc] init];
        for (Tag *tag1 in tagsArray) {
            if (tag1.videoId.integerValue > 0) {
                [tagsMArray addObject:[[DataManager sharedDataManager] tagToDictionary:tag1]];
            }
        }
        NSLog(@"Tags M Arrray :%@",tagsMArray);
        [self AddTagsRequestWithCallBackObject:caller andTagsArray:tagsMArray ofUserWithUserId:userId];
    }
    TCEND
}

#pragma mark Parsing
- (VideoModal *)returnVideoModalObjectByParsing:(NSDictionary *)videoFields {
    TCSTART
    VideoModal *video = [[VideoModal alloc] init];
    if([self isNotNull:[videoFields objectForKey:@"video_id"]] && [[videoFields objectForKey:@"video_id"] length] > 0) {
        video.videoId = [videoFields objectForKey:@"video_id"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"path"]]) {
        video.path = [videoFields objectForKey:@"path"];
    } else if ([self isNotNull:[videoFields objectForKey:@"video_url"]]) {
        video.path = [videoFields objectForKey:@"video_url"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"share_url"]]) {
        video.shareUrl = [videoFields objectForKey:@"share_url"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"fb_share_url"]]) {
        video.fbShareUrl = [videoFields objectForKey:@"fb_share_url"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"upload_date"]]) {
        //        video.creationTime = [self relativeDateString:[videoFields objectForKey:@"upload_date"]];
        video.creationTime = [videoFields objectForKey:@"upload_date"];
    }
    
    //    createdime
    if ([self isNotNull:[videoFields objectForKey:@"title"]]) {
        video.title = [videoFields objectForKey:@"title"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"description"]]) {
        video.info = [videoFields objectForKey:@"description"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"no_of_likes"]]) {
        video.numberOfLikes = [NSNumber numberWithInt:[[videoFields objectForKey:@"no_of_likes"] intValue]];
    } else {
        video.numberOfLikes = [NSNumber numberWithInt:0];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"video_thumb_path"]]) {
        video.videoThumbPath = [videoFields objectForKey:@"video_thumb_path"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"no_of_views"]]) {
        video.numberOfViews = [NSNumber numberWithInt:[[videoFields objectForKey:@"no_of_views"] intValue]];
    } else {
        video.numberOfViews = [NSNumber numberWithInt:0];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"no_of_comments"]]) {
        video.numberOfCmnts = [NSNumber numberWithInt:[[videoFields objectForKey:@"no_of_comments"] intValue]];
    } else {
        video.numberOfCmnts = [NSNumber numberWithInt:0];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"no_of_tags"]]) {
        video.numberOfTags = [NSNumber numberWithInt:[[videoFields objectForKey:@"no_of_tags"] intValue]];
    } else {
        video.numberOfTags = [NSNumber numberWithInt:0];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"tag_count"]]) {
        video.numberOfVideosOfHashTag = [NSNumber numberWithInt:[[videoFields objectForKey:@"tag_count"] intValue]];
    } else {
        video.numberOfVideosOfHashTag = [NSNumber numberWithInt:0];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"recent_comments"]]) {
        video.comments = [videoFields objectForKey:@"recent_comments"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"public"]]) {
        video.public = [NSNumber numberWithInt:[[videoFields objectForKey:@"public"] intValue]];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"hasliked"]]) {
        video.hasLovedVideo = [[videoFields objectForKey:@"hasliked"] boolValue];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"hascommented"]]) {
        video.hasCommentedOnVideo = [[videoFields objectForKey:@"hascommented"] boolValue];
    }
    
    
    if ([self isNotNull:[videoFields objectForKey:@"tags"]]) {
        video.tags = [videoFields objectForKey:@"tags"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"user_id"]]) {
        video.userId = [videoFields objectForKey:@"user_id"];
    } else if ([self isNotNull:[videoFields objectForKey:@"uid"]]) {
        video.userId = [videoFields objectForKey:@"uid"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"user_name"]]) {
        video.userName = [videoFields objectForKey:@"user_name"];
    } if ([self isNotNull:[videoFields objectForKey:@"username"]]) {
        video.userName = [videoFields objectForKey:@"username"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"photo_path"]]) {
        video.userPhoto = [videoFields objectForKey:@"photo_path"];
    } else if ([self isNotNull:[videoFields objectForKey:@"user_photo"]]) {
        video.userPhoto = [videoFields objectForKey:@"user_photo"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"country"]]) {
        video.userCountry = [videoFields objectForKey:@"country"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"profession"]]) {
        video.userProfession = [videoFields objectForKey:@"profession"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"website"]]) {
        video.userWebsite = [videoFields objectForKey:@"website"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"latest_tag_expression"]] ) {
        video.latestTagExpression = [videoFields objectForKey:@"latest_tag_expression"];
    } else if ([self isNotNull:[videoFields objectForKey:@"tag_name"]]) {
        video.latestTagExpression = [videoFields objectForKey:@"tag_name"];
    }
    if ([self isNotNull:[videoFields objectForKey:@"browseType"]]) {
        video.browseType = [videoFields objectForKey:@"browseType"];
    }
    
    //    [videoFields setObject:[self likes] forKey:@"likes"];
    if ([self isNotNull:[videoFields objectForKey:@"recent_liked_by"]]) {
        video.likesList = [videoFields objectForKey:@"recent_liked_by"];
    }
    
    if ([self isNotNull:[videoFields objectForKey:@"myotherstuff"]]) {
        video.myotherStuff = [videoFields objectForKey:@"myotherstuff"];
    }
    return video;
    TCEND
}

#pragma parse User Object
- (UserModal *)returnUserModalObjectByParsing:(NSDictionary *)userFields isLogdedInUser:(BOOL)loggedUser {
    TCSTART
    UserModal *user;
    if (loggedUser) {
        user = loggedInUser;
    } else {
        user = [[UserModal alloc] init];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"name"]]) {
        user.userName = [userFields objectForKey:@"name"];
    } else if ([self isNotNull:[userFields objectForKey:@"user_name"]]) {
        user.userName = [userFields objectForKey:@"user_name"];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"email"]]) {
        user.emailAddress = [userFields objectForKey:@"email"];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"user_id"]]) {
        user.userId = [userFields objectForKey:@"user_id"];
    } else if ([self isNotNull:[userFields objectForKey:@"id"]]) {
        user.userId = [userFields objectForKey:@"id"];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"photo_path"]]) {
        user.photoPath = [userFields objectForKey:@"photo_path"];
    } else if ([self isNotNull:[userFields objectForKey:@"user_photo"]]) {
        user.photoPath = [userFields objectForKey:@"user_photo"];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"country"]]) {
        user.country = [userFields objectForKey:@"country"];
    } else {
        user.country = @"";
    }
    
    if ([self isNotNull:[userFields objectForKey:@"profession"]]) {
        user.profession = [userFields objectForKey:@"profession"];
    } else {
        user.profession = @"";
    }
    
    if ([self isNotNull:[userFields objectForKey:@"website"]]) {
        user.website = [userFields objectForKey:@"website"];
    } else {
        user.website = @"";
    }
    
    if ([self isNotNull:[userFields objectForKey:@"bio"]]) {
        user.bio = [userFields objectForKey:@"bio"];
    } else {
        user.bio = @"";
    }
    
    if ([self isNotNull:user.profession]) {
        user.userDesc = user.profession;
    } else {
        user.userDesc = @"";
    }
    
    if ([self isNotNull:user.country]) {
        if ([self isNotNull:user.userDesc] && user.userDesc.length > 0) {
            user.userDesc = [NSString stringWithFormat:@"%@ | %@",user.userDesc,user.country];
        } else {
            user.userDesc = user.country;
        }
    }
    
    if ([self isNotNull:user.website]) {
        if ([self isNotNull:user.userDesc] && user.userDesc.length > 0) {
            user.userDesc = [NSString stringWithFormat:@"%@ | %@",user.userDesc,user.website];
        } else {
            user.userDesc = user.website;
        }
    }
    
    
    if ([self isNotNull:[userFields objectForKey:@"banner_path"]]) {
        user.bannerPath = [userFields objectForKey:@"banner_path"];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"last_update"]]) {
        //        user.lastUpdate = [NSString stringWithFormat:@"%d",[[userFields objectForKey:@"last_update"] intValue]];
        user.lastUpdate = [userFields objectForKey:@"last_update"];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"total_no_of_likes"]]) {
        user.totalNoOfLikes = [NSNumber numberWithInt:[[userFields objectForKey:@"total_no_of_likes"] intValue]];
    } else {
        user.totalNoOfLikes = [NSNumber numberWithInt:0];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"total_no_of_tags"]]) {
        user.totalNoOfTags = [NSNumber numberWithInt:[[userFields objectForKey:@"total_no_of_tags"] intValue]];
    } else {
        user.totalNoOfTags = [NSNumber numberWithInt:0];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"total_no_of_videos"]]) {
        user.totalNoOfVideos = [NSNumber numberWithInt:[[userFields objectForKey:@"total_no_of_videos"] intValue]];
    } else {
        user.totalNoOfVideos = [NSNumber numberWithInt:0];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"total_no_of_following"]]) {
        user.totalNoOfFollowings = [NSNumber numberWithInt:[[userFields objectForKey:@"total_no_of_following"] intValue]];
    } else if ([self isNotNull:[userFields objectForKey:@"total_no_of_followings"]]) {
        user.totalNoOfFollowings = [NSNumber numberWithInt:[[userFields objectForKey:@"total_no_of_followings"] intValue]];
    } else {
        user.totalNoOfFollowings = [NSNumber numberWithInt:0];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"total_no_of_followers"]]) {
        user.totalNoOfFollowers = [NSNumber numberWithInt:[[userFields objectForKey:@"total_no_of_followers"] intValue]];
    } else {
        user.totalNoOfFollowers = [NSNumber numberWithInt:0];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"total_no_of_pvtgroup"]]) {
        user.totalNoOfPrivateUsers = [NSNumber numberWithInt:[[userFields objectForKey:@"total_no_of_pvtgroup"] intValue]];
    } else {
        user.totalNoOfPrivateUsers = [NSNumber numberWithInt:0];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"total_no_of_pendingpvtgroup"]]) {
        user.totalNoOfPeningPrivateUsers = [NSNumber numberWithInt:[[userFields objectForKey:@"total_no_of_pendingpvtgroup"] intValue]];
    } else {
        user.totalNoOfPeningPrivateUsers = [NSNumber numberWithInt:0];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"followings"]]) {
        user.followings = [userFields objectForKey:@"followings"];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"followers"]]) {
        user.followers = [userFields objectForKey:@"followers"];
    }
    
    NSMutableArray *videosArray = [[NSMutableArray alloc] init];
    if ([self isNotNull:[userFields objectForKey:@"videos"]] && [[userFields objectForKey:@"videos"] isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in [userFields objectForKey:@"videos"]) {
            VideoModal *modal = [self returnVideoModalObjectByParsing:dict];
            [videosArray addObject:modal];
        }
    }
    
    user.videos = videosArray;
    
    NSMutableArray *users = [[NSMutableArray alloc] init];
    if ([self isNotNull:[userFields objectForKey:@"suggested_users"]]) {
        for (NSDictionary *dict in [userFields objectForKey:@"suggested_users"]) {
            UserModal *usermodal = [self returnUserModalObjectByParsing:dict isLogdedInUser:NO];
            [users addObject:usermodal];
        }
    }
    user.suggestedUsers = users;
    
    
    NSMutableArray *moreVideos = [[NSMutableArray alloc] init];
    if ([self isNotNull:[userFields objectForKey:@"more_videos"]]) {
        [moreVideos addObjectsFromArray:[userFields objectForKey:@"more_videos"]];
    }
    user.moreVideos = moreVideos;
    
    if ([self isNotNull:[userFields objectForKey:@"following"]] && [[userFields objectForKey:@"following"] isKindOfClass:[NSString class]]) {
        user.youFollowing = [[userFields objectForKey:@"following"] boolValue];
    } else if ([self isNotNull:[userFields objectForKey:@"follwoing"]] && [[userFields objectForKey:@"follwoing"] isKindOfClass:[NSString class]]) {
        user.youFollowing = [[userFields objectForKey:@"follwoing"] boolValue];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"pvtgroup"]] && [[userFields objectForKey:@"pvtgroup"] isKindOfClass:[NSString class]]) {
        user.youPrivate = [[userFields objectForKey:@"pvtgroup"] boolValue];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"privatereqSent"]] && [[userFields objectForKey:@"privatereqSent"] isKindOfClass:[NSString class]]) {
        user.privateReqSent = [[userFields objectForKey:@"privatereqSent"] boolValue];
    }
    
    if ([self isNotNull:[userFields objectForKey:@"respondpvtreq"]] && [[userFields objectForKey:@"respondpvtreq"] isKindOfClass:[NSString class]]) {
        user.respondToPvtReq = [[userFields objectForKey:@"respondpvtreq"] boolValue];
    }
    
    return user;
    
    TCEND
}

#pragma mark AddTags Request
- (void)AddTagsRequestWithCallBackObject:(id)caller andTagsArray:(NSArray *)tagsArray ofUserWithUserId:(NSString *)userId {
    TCSTART
    if ([self isNotNull:tagsArray] && tagsArray.count > 0) {
        caller_ = caller;
        TagService *tagService = [[TagService alloc] initWithCaller:self];
        tagService.user_id = userId;
        tagService.requestURL = APP_URL;
        tagService.deviceId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UDID"];
        [tagService addTags:tagsArray];
        [self showNetworkIndicator];
        //        [self showActivityIndicatorWithText:@"Publishing"];
    }
    TCEND
}
- (void)didFinishedAddingTags:(NSDictionary *)results {
    TCSTART
    [self hideNetworkIndicator];
    [self removeActivityIndicator];
    
    if ([self isNotNull:caller_] && [caller_ respondsToSelector:@selector(addTagsResponseForVideoCompleted: andResults:)]) {
        [caller_ addTagsResponseForVideoCompleted:YES andResults:results];
    } else {
        if ([self isNotNull:[results objectForKey:@"tags"]]) {
            [self shareVideoInformationToSocialSites:uploadedVideoModal andTag:[results objectForKey:@"tags"]];
        }
    }
    if ([self isNotNull:[results objectForKey:@"tags"]]) {
        NSArray *tagsArray = [results objectForKey:@"tags"];
        for (Tag *tag in tagsArray) {
            BuyerInfo *buyer = [[DataManager sharedDataManager] getBuyerInfoByTagIdOrClientTagId:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",tag.clientTagId.intValue],@"clientTagId", nil]];
            if ([self isNotNull:buyer]) {
                buyer.tagId = [NSString stringWithFormat:@"%d",tag.tagId.intValue];
                [[DataManager sharedDataManager] saveChanges];
                [self productBuyRequestWithParameters:buyer withCaller:self];
            }
        }
    }
    TCEND
}
- (void)didFailToAddTagsWithError:(NSDictionary *)errorDict {
    TCSTART
    [self hideNetworkIndicator];
    [self removeActivityIndicator];
    if ([self isNotNull:[errorDict objectForKey:@"error_code"]] && [[errorDict objectForKey:@"error_code"] intValue] == 1) {
        if ([self isNotNull:caller_] && [caller_ respondsToSelector:@selector(didFailAddingTags)]) {
            [caller_ didFailAddingTags];
        }
    }
    //    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

#pragma mark playBack request
- (void)requestForPlayBackWithVideoId:(NSString *)videoId andcaller:(id)caller andIndexPath:(NSIndexPath *)indexPath refresh:(BOOL) requstForRefresh {
    TCSTART
    if ([self isNotNull:videoId]) {
        caller_ = caller;
        TagService *tagService = [[TagService alloc] initWithCaller:self];
        tagService.requestURL = APP_URL;
        tagService.indexPath = indexPath;
        tagService.requestForRefresh = requstForRefresh;
        [tagService playBackRequestWithVideoId:videoId];
        [self showNetworkIndicator];
        [self showActivityIndicatorWithText:@"Loading"];
    }
    TCEND
}

- (void)didFinishedPlayBackRequest:(NSDictionary *)results {
    TCSTART
    [self hideNetworkIndicator];
    [self removeActivityIndicator];
    if ([caller_ respondsToSelector:@selector(playBackResponse:)]) {
        [caller_ playBackResponse:results];
    }
    if ([self isNotNull:results] && [self isNotNull:[[results objectForKey:@"results"] objectForKey:@"video_id"]]) {
        NSString *videoID = [[results objectForKey:@"results"] objectForKey:@"video_id"];
        //        [self makeRequestForAnalyticsOfVideo:videoID ana];
        [self makeRequestForAnalyticsOfVideo:videoID analyticsTagClicksOrShareId:VideoViewsOrFBShare analyticsTagInteractions:FB socialPlatform:FB isForShare:NO isReqForInteractions:NO shareCount:0];
    }
    TCEND
}

- (void)didFailedPlayBackRequestWithError:(NSDictionary *)errorDict {
    TCSTART
    [self hideNetworkIndicator];
    [self removeActivityIndicator];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

#pragma mark Product Buy request
- (void)productBuyRequestWithParameters:(BuyerInfo *)buyerInfo withCaller:(id)caller {
    TCSTART
    NetworkConnection *networkConn = [[NetworkConnection alloc] init];
    NSString *url = APP_URL;
    
    NSDictionary *paramsDict = [[DataManager sharedDataManager] buyerInfoToDictionary:buyerInfo];
    
    if ([self isNotNull:paramsDict] && paramsDict.count > 0) {
        [NSThread detachNewThreadSelector:@selector(requestForBuyProduct:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:url, @"url",paramsDict,@"parameters", nil],@"params",caller, @"caller",nil]];
    }
    TCEND
}

#pragma mark Analytics Request
- (void)makeRequestForAnalyticsOfVideo:(NSString *)videoId analyticsTagClicksOrShareId:(AyanticsTagClicksOrShareId)ayanticsClicksShareId analyticsTagInteractions:(AyanticsInteractionsOrSocialPlatform)interactionsId socialPlatform:(AyanticsInteractionsOrSocialPlatform)socialPlatform isForShare:(BOOL)isForShare isReqForInteractions:(BOOL)isForInteraction shareCount:(int)shareCount {
    TCSTART
    NetworkConnection *networkConn = [[NetworkConnection alloc] init];
    NSString *url = AYANLYTICS_URL;
    if (isForShare) {
        url = [NSString stringWithFormat:@"%@/video/share_views/%@/%@/%@/%@",url,videoId?:@"",[NSNumber numberWithInt:ayanticsClicksShareId],[NSNumber numberWithInt:shareCount],loggedInUser.userId?:@""];
    } else if (isForInteraction) {
        url = [NSString stringWithFormat:@"%@/video/tag_interactions/%@/%@/%@/%@",url,videoId?:@"",[NSNumber numberWithInt:socialPlatform],[NSNumber numberWithInt:interactionsId],loggedInUser.userId?:@""];
    } else {
        //        url = [NSString stringWithFormat:@"%@/video/individual_views_live/%@/4/%@/%@",url,videoId?:@"",[NSNumber numberWithInt:ayanticsClicksShareId],loggedInUser.userId?:@""];
        url = [NSString stringWithFormat:@"%@/video/individual_views/%@/4/%@/%@",url,videoId?:@"",[NSNumber numberWithInt:ayanticsClicksShareId],loggedInUser.userId?:@""];
    }
    [NSThread detachNewThreadSelector:@selector(analyticsRequestWithParameters:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:url, @"url", nil],@"params",self, @"caller",nil]];
    TCEND
}

- (void)didFinishedSendAnalyticsInfo:(NSDictionary *)result {
    TCSTART
    TCEND
}
- (void)didFailedToSendAnalyticsWithError:(NSDictionary *)errorDict {
    TCSTART
    TCEND
}

#pragma mark Update Tags
- (void)makeUpdateTagsRequestCaller:(id)caller {
    TCSTART
    NSLog(@"Get All updated Tags :%@",[[DataManager sharedDataManager] getUpdatedTagsArrayAndWaitingForPost]);
    NSArray *tagsArray = [[DataManager sharedDataManager] getUpdatedTagsArrayAndWaitingForPost];
    NSMutableArray *tagsMArray = [[NSMutableArray alloc] init];
    for (Tag *tag1 in tagsArray) {
        if (tag1.tagId.intValue <= 0) {
            [[DataManager sharedDataManager] deleteTag:tag1];
        } else {
            if (tag1.videoId.integerValue > 0) {
                [tagsMArray addObject:[[DataManager sharedDataManager] tagToDictionary:tag1]];
            }
        }
    }
    NSLog(@"Tags M Arrray :%@",tagsMArray);
    [self updateTagsWithCaller:caller andTagsArray:tagsMArray];
    TCEND
}
- (void)updateTagsWithCaller:(id)caller andTagsArray:(NSArray *)tagsArray {
    TCSTART
    if ([self isNotNull:tagsArray] && tagsArray.count > 0) {
        caller_ = caller;
        TagService *tagService = [[TagService alloc] initWithCaller:self];
        tagService.requestURL = APP_URL;
        [tagService updateTags:tagsArray];
        [self showNetworkIndicator];
        //        [self showActivityIndicatorWithText:@"Updating"];
    }
    TCEND
}
- (void)didFinishedUpdatingTags:(NSDictionary *)results {
    TCSTART
    [self hideNetworkIndicator];
    [self removeActivityIndicator];
    if ([self isNotNull:caller_] && [caller_ respondsToSelector:@selector(addTagsResponseForVideoCompleted: andResults:)]) {
        [caller_ addTagsResponseForVideoCompleted:NO andResults:results];
    } else {
        if ([self isNotNull:[results objectForKey:@"tags"]] && [self isNotNull:[results objectForKey:@"tags"]]) {
            [self shareVideoInformationToSocialSites:uploadedVideoModal andTag:[results objectForKey:@"tags"]];
        }
    }
    TCEND
}

- (void)didFailToUpdateTagsWithError:(NSDictionary *)errorDict {
    TCSTART
    [self hideNetworkIndicator];
    [self removeActivityIndicator];
    //    [ShowAlert showAlert:[errorDict objectForKey:@"msg"]];
    [self makeUpdateTagsRequestCaller:self];
    TCEND
}

- (void)shareVideoInformationToSocialSites:(VideoModal *)videoModal andTag:(NSArray *)tagsArray {
    TCSTART
    NSMutableArray *googlePlusUserIds = [[NSMutableArray alloc] init];
    NSMutableArray *facebookUserIds = [[NSMutableArray alloc] init];
    for (Tag *tag in tagsArray) {
        if ([self isNotNull:tag.fbId] && tag.fbId.intValue > 0) {
            videoModal.latestTagExpression = tag.name;
            [facebookUserIds addObject:tag.fbId];
            if (facebookUserIds.count < 2 && FBSession.activeSession.isOpen) {
                [self performPublishAction:^{[self postToFacebookUserWallWithOutDialog:videoModal andToId:tag.fbId];}];
            } else {
                [self postToFacebookUserWallWithOutDialog:videoModal andToId:tag.fbId];
            }
        }
        
        if ([self isNotNull:tag.twId] && tag.twId.intValue > 0) {
            videoModal.latestTagExpression = tag.name;
            [self postToTwitterWithImaegData:videoModal andUserId:tag.twId];
        }
        
        if ([self isNotNull:tag.gPlusId] && tag.gPlusId.intValue > 0) {
            [googlePlusUserIds addObject:tag.gPlusId];
        }
    }
    if (googlePlusUserIds.count > 0) {
        [self shareToGooglePlusUserWithUserId:googlePlusUserIds andVideo:videoModal];
    }
    
    TCEND
}

- (void)googlePlusWithVideoModal:(VideoModal *)videoModal {
    TCSTART
    GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGoogleUserID = YES;
    plusService.retryEnabled = YES;
    [plusService setAuthorizer:signIn.authentication];
    
    GTLPlusMoment *moment = [[GTLPlusMoment alloc] init];
    
    // You can replace AddActivity with another valid Google+ app activity type.
    // See: https://developers.google.com/+/mobile/ios/api/moment-types
    moment.type = @"http://schemas.google.com/AddActivity";
    
    GTLPlusItemScope *target = [[GTLPlusItemScope alloc] init];
    target.url = @"https://www.google.co.in/";
    target.thumbnailUrl = @"http://54.254.215.146/timthumb.php?src=/profile_pictures/13.jpg&h=70&w=70&zc=1";
    target.text = @"Test";
    
    //    GTLPlusItemScope *result = [[GTLPlusItemScope alloc] init];
    //    target.url = videoModal.path;
    //    target.thumbnailUrl = videoModal.videoThumbPath;
    //    target.text = videoModal.title;
    //    result.url = @"https://example.com";
    
    moment.target = target;
    
    GTLQueryPlus *query =
    [GTLQueryPlus queryForMomentsInsertWithObject:moment
                                           userId:@"me"
                                       collection:kGTLPlusCollectionPublic];
    
    [plusService executeQuery:query
            completionHandler:^(GTLServiceTicket *ticket,
                                id object,
                                NSError *error) {
                if (error) {
                    GTMLoggerError(@"Got bad response from "
                                   @"plus.moments.insert: %@",
                                   error);
                    
                } else {
                    NSLog(@"Sent");
                }
            }];
    
    //    moment.result = result;
    TCEND
}

#pragma mark DeleteTag
- (void)makeDeleteTagRequestWithTagId:(NSString *)tagId andCaller:(id)caller {
    TCSTART
    if ([self isNotNull:tagId]) {
        caller_ = caller;
        TagService *tagService = [[TagService alloc] initWithCaller:self];
        tagService.requestURL = APP_URL;
        [tagService deleteTagWithTagId:tagId];
        [self showNetworkIndicator];
        //        [self showActivityIndicatorWithText:@"Deleting"];
    }
    TCEND
}

- (void)didFinishedDeleteTag:(NSDictionary *)results {
    TCSTART
    [self hideNetworkIndicator];
    [self removeActivityIndicator];
    [ShowAlert showAlert:[[results objectForKey:@"results"] objectForKey:@"msg"]];
    if ([self isNotNull:caller_] && [caller_ respondsToSelector:@selector(deleteTagsResponseWithTagId:)]) {
        [caller_ deleteTagsResponseWithTagId:[results objectForKey:@"tagid"]];
    }
    TCEND
}
-(void)didFailToDeleteTagWithError:(NSDictionary *)errorDict {
    TCSTART
    [self hideNetworkIndicator];
    [self removeActivityIndicator];
    [ShowAlert showAlert:[errorDict objectForKey:@"msg"]];
    TCEND
}


#pragma mark MyPage Request
- (void)makeMypageRequestWithUserId:(NSString *)userId andCaller:(id)caller {
    TCSTART
    if ([self isNotNull:userId]) {
        UserService *userService = [[UserService alloc] initWithCaller:caller];
        userService.requestURL = APP_URL;
        [userService getMyPageDetailsOfUserWithUserId:userId];
    } else {
        [ShowAlert showWarning:@"UserId should not be null"];
    }
    TCEND
}

#pragma mark mypage delegate methods
- (void)didFinishedToGetMypageDetails:(NSDictionary *)results {
    TCSTART
    [self hideNetworkIndicator];
    [self removeActivityIndicator];
    [self saveLoggedUserData:loggedInUser];
    [self createMainViewControllerAndAddToWindow];
    [self performSelector:@selector(uploadVideo) withObject:nil afterDelay:0.2];
    [self makeAddTagsRequestWithCaller:self ofUserWithUserId:loggedInUser.userId];
    if ([self isNotNull:shareNPlaybackDct]) {
        [self checkToLaunchPlayerWhenComeFromBrowser];
    }
    TCEND
}

- (void)didFailToGetMypageDetailsWithError:(NSDictionary *)errorDict {
    TCSTART
    [self hideNetworkIndicator];
    [self removeActivityIndicator];
    TCEND
}

#pragma mark REset Badge count
- (void)makeRequestForResetBadgeCount {
    TCSTART
    if ([self isNotNull:loggedInUser.userId]) {
        NetworkConnection *networkConn = [[NetworkConnection alloc] init];
        NSString *url = [NSString stringWithFormat:@"%@/reset_badge/%@",APP_URL,loggedInUser.userId];
        [NSThread detachNewThreadSelector:@selector(requestForResetBadge:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:url, @"url",self, @"caller",nil]];
    }
    TCEND
}

- (void)didFinishedResetBadgeCount {
    TCSTART
    TCEND
}
#pragma mark Other user page Request
- (void)makeOtherUserRequestWithOtherUserId:(NSString *)userId pageNumber:(NSInteger)pageNum andCaller:(id)caller {
    TCSTART
    if ([self isNotNull:userId]) {
        UserService *userService = [[UserService alloc] initWithCaller:caller];
        userService.requestURL = APP_URL;
        userService.pageNumber = pageNum;
        [userService getOtherUserPageDetailsOfUserWithUserId:userId andLoggedInUserID:loggedInUser.userId];
    } else {
        [ShowAlert showWarning:@"UserId should not be null"];
    }
    TCEND
}

#pragma mark Tag user comments
- (void)makeRequestForTagUserCommentsWithData:(NSDictionary *)reqData andCaller:(id)caller {
    TCSTART
    if ([self isNotNull:reqData]) {
        UserService *userService = [[UserService alloc] initWithCaller:caller];
        userService.requestURL = APP_URL;
        [userService getTagCommentUsersWithInputData:reqData];
    }
    TCEND
}

#pragma mark Private users Request
- (void)makeRequestForPrivateUsersWithUserId:(NSString *)userId pageNumber:(NSInteger)pagenumber andCaller:(id)caller {
    TCSTART
    if ([self isNotNull:userId]) {
        UserService *userService = [[UserService alloc] initWithCaller:caller];
        userService.requestURL = APP_URL;
        userService.pageNumber = pagenumber;
        [userService getPrivateUsersOfUserWithUserId:userId];
    } else {
        [ShowAlert showWarning:@"UserId should not be null"];
    }
    TCEND
}

#pragma mark Pending Private users Request
- (void)makeRequestForPendingPrivateUsersWithUserId:(NSString *)userId pageNumber:(NSInteger)pagenumber andCaller:(id)caller {
    TCSTART
    if ([self isNotNull:userId]) {
        UserService *userService = [[UserService alloc] initWithCaller:caller];
        userService.requestURL = APP_URL;
        userService.pageNumber = pagenumber;
        [userService getPendingPrivateUsersOfUserWithUserId:userId];
    } else {
        [ShowAlert showWarning:@"UserId should not be null"];
    }
    TCEND
}

#pragma mark User Followings Request
- (void)makeRequestForUserFollowingsWithUserId:(NSString *)userId pageNumber:(NSInteger)pagenumber andCaller:(id)caller {
    TCSTART
    if ([self isNotNull:userId]) {
        UserService *userService = [[UserService alloc] initWithCaller:caller];
        userService.requestURL = APP_URL;
        userService.pageNumber = pagenumber;
        [userService getFollowingsOfUserWithUserId:userId];
    } else {
        [ShowAlert showWarning:@"UserId should not be null"];
    }
    TCEND
}

#pragma mark User WooTag Request
- (void)makeRequestForWooTagFreindsWithUserId:(NSString *)userId pageNumber:(NSInteger)pagenumber andCaller:(id)caller {
    TCSTART
    if ([self isNotNull:userId]) {
        UserService *userService = [[UserService alloc] initWithCaller:caller];
        userService.requestURL = APP_URL;
        userService.pageNumber = pagenumber;
        [userService getWootagFreindsWithUserId:userId];
    } else {
        [ShowAlert showWarning:@"UserId should not be null"];
    }
    TCEND
}

#pragma mark User Followers Request
- (void)makeRequestForUserFollowersWithUserId:(NSString *)userId  pageNumber:(NSInteger)pagenumber andCaller:(id)caller {
    TCSTART
    if ([self isNotNull:userId]) {
        UserService *userService = [[UserService alloc] initWithCaller:caller];
        userService.requestURL = APP_URL;
        userService.pageNumber = pagenumber;
        [userService getFollowersOfUserWithUserId:userId];
    } else {
        [ShowAlert showWarning:@"UserId should not be null"];
    }
    TCEND
}

#pragma mark User follow
- (void)makeFollowUserWithUserId:(NSString *)userId followerId:(NSString *)followerId andCaller:(id)caller andIndexPath: (NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:userId] && [self isNotNull:followerId]) {
        UserService *userService = [[UserService alloc] initWithCaller:caller];
        userService.requestURL = APP_URL;
        userService.indexPath = indexPath;
        [userService followRequestWithUserId:userId andFollowerId:followerId];
        [self showNetworkIndicator];
        //        [self showActivityIndicatorWithText:@"Following"];
    } else {
        [ShowAlert showWarning:@"UserId or FollowerId should not be null"];
    }
    TCEND
}

#pragma mark User Unfollow
- (void)makeUnFollowUserWithUserId:(NSString *)userId followerId:(NSString *)followerId andCaller:(id)caller andIndexPath: (NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:userId] && [self isNotNull:followerId]) {
        UserService *userService = [[UserService alloc] initWithCaller:caller];
        userService.requestURL = APP_URL;
        userService.indexPath = indexPath;
        [userService unFollowUserRequestWithUserId:userId andFollowerId:followerId];
        [self showNetworkIndicator];
        //        [self showActivityIndicatorWithText:@"Unfollowing"];
    } else {
        [ShowAlert showWarning:@"UserId or FollowerId should not be null"];
    }
    TCEND
}

#pragma mark User private
- (void)makePrivateUserWithUserId:(NSString *)userId privateUserId:(NSString *)privateUserId andCaller:(id)caller andIndexPath: (NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:userId] && [self isNotNull:privateUserId]) {
        UserService *userService = [[UserService alloc] initWithCaller:caller];
        userService.requestURL = APP_URL;
        userService.indexPath = indexPath;
        [userService privateRequestWithUserId:userId andPrivateUserId:privateUserId];
        [self showNetworkIndicator];
        //        [self showActivityIndicatorWithText:@"Add to private"];
    } else {
        [ShowAlert showWarning:@"UserId or PrivateUserId should not be null"];
    }
    TCEND
}

#pragma mark Accept private user request
- (void)makeAcceptPrivateUserWithUserId:(NSString *)userId privateUserId:(NSString *)privateUserId andCaller:(id)caller andIndexPath: (NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:userId] && [self isNotNull:privateUserId]) {
        UserService *userService = [[UserService alloc] initWithCaller:caller];
        userService.requestURL = APP_URL;
        userService.indexPath = indexPath;
        [userService acceptPrivateGroupRequestWithUserId:userId andPrivateOtherUserId:privateUserId];
    } else {
        [ShowAlert showWarning:@"UserId or PrivateUserId should not be null"];
    }
    TCEND
}

#pragma mark User UnPrivate
- (void)makeUnPrivateUserWithUserId:(NSString *)userId privateUserId:(NSString *)privateUserId andCaller:(id)caller andIndexPath: (NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:userId] && [self isNotNull:privateUserId]) {
        UserService *userService = [[UserService alloc] initWithCaller:caller];
        userService.requestURL = APP_URL;
        userService.indexPath = indexPath;
        [userService unPrivateUserRequestWithUserId:userId andPrivateUserId:privateUserId];
        [self showNetworkIndicator];
        //        [self showActivityIndicatorWithText:@"Unprivating"];
    } else {
        [ShowAlert showWarning:@"UserId or PrivateUserId should not be null"];
    }
    TCEND
}

#pragma mark Suggested users
- (void)makeSuggestedUsersRequestWithUserId:(NSString *)userId  andCaller:(id)caller pageNum:(NSInteger) pageNumber {
    TCSTART
    if ([self isNotNull:userId]) {
        UserService *userService = [[UserService alloc] initWithCaller:caller];
        userService.requestURL = APP_URL;
        userService.pageNumber = pageNumber;
        [userService getSuggesdtedUsersForUserWithUserId:userId];
    } else {
        [ShowAlert showWarning:@"UserId should not be null"];
    }
    TCEND
}

#pragma mark Social friends information
- (void)makeSocialFriendsInfoRequestWithUserId:(NSString *)userId  andCaller:(id)caller friendsList:(NSArray *)list {
    TCSTART
    if ([self isNotNull:userId]) {
        UserService *userService = [[UserService alloc] initWithCaller:caller];
        userService.requestURL = APP_URL;
        [userService getSocialNetworkFriendInformation:list userId:userId];
    } else {
        [ShowAlert showWarning:@"UserId should not be null"];
    }
    TCEND
}

#pragma mark Delete Video
- (void)makeRequestForDeleteVideoWithVideoId:(NSString *)videoId andUserId:(NSString *)userId andCaller:(id)caller atIndexpath:(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:userId] && [self isNotNull:videoId]) {
        VideoService *videoService = [[VideoService alloc] initWithCaller:caller];
        videoService.requestURL = APP_URL;
        videoService.indexPath = indexPath;
        [videoService deleteVideoWithVideoId:videoId ofUserId:userId];
    } else {
        [ShowAlert showWarning:@"UserId or VideoId should not be null"];
    }
    TCEND
}

#pragma mark Report Video
- (void)makeRequestForReportVideoWithVideoId:(NSString *)videoId andCaller:(id)caller andReason:(NSString *)reason {
    TCSTART
    if ([self isNotNull:videoId] && [self isNotNull:reason]) {
        VideoService *videoService = [[VideoService alloc] initWithCaller:caller];
        videoService.requestURL = APP_URL;
        [videoService reportVideoWithVideoId:videoId ofUserId:loggedInUser.userId andReason:reason andDeviceId:[[NSUserDefaults standardUserDefaults] objectForKey:@"UDID"]];
        [self showNetworkIndicator];
    }
    TCEND
}

#pragma mark Feedback
- (void)makeRequestToSendFeedBack:(NSString *)feedbackText andCaller:(id)caller {
    TCSTART
    if ([self isNotNull:feedbackText]) {
        UserService *userService = [[UserService alloc] initWithCaller:caller];
        userService.requestURL = APP_URL;
        [userService sendFeedbackWithText:feedbackText andUserId:loggedInUser.userId andDeviceId:[[NSUserDefaults standardUserDefaults] objectForKey:@"UDID"]];
        [self showNetworkIndicator];
    }
    TCEND
}

#pragma mark Change Video Permission
- (void)makeRequestVideoPermissionsChangeVideoId:(NSString *)videoId permission:(int)permission andCaller:(id)caller {
    TCSTART
    if ([self isNotNull:videoId]) {
        VideoService *videoService = [[VideoService alloc] initWithCaller:caller];
        videoService.requestURL = APP_URL;
        [videoService changeVideoAccessPermission:videoId permission:permission];
        
    } else {
        [ShowAlert showWarning:@"VideoId should not be null"];
    }
    TCEND
}

#pragma mark Like Video
- (void)makeRequestForLikeVideoWithVideoId:(NSString *)videoId andCaller:(id)caller andIndexPaht:(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:loggedInUser.userId] && [self isNotNull:videoId]) {
        VideoService *videoService = [[VideoService alloc] initWithCaller:caller];
        videoService.requestURL = APP_URL;
        videoService.indexPath = indexPath;
        [videoService likeVideoWithVideoId:videoId ofUserId:loggedInUser.userId];
        [self showNetworkIndicator];
    } else {
        [ShowAlert showWarning:@"UserId or VideoId should not be null"];
    }
    TCEND
}

#pragma mark UnLike Video
- (void)makeRequestForUnLikeVideoWithVideoId:(NSString *)videoId andCaller:(id)caller andIndexPaht:(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:loggedInUser.userId] && [self isNotNull:videoId]) {
        VideoService *videoService = [[VideoService alloc] initWithCaller:caller];
        videoService.requestURL = APP_URL;
        videoService.indexPath = indexPath;
        [videoService unlikeVideoWithVideoId:videoId ofUserId:loggedInUser.userId];
        [self showNetworkIndicator];
    } else {
        [ShowAlert showWarning:@"UserId or VideoId should not be null"];
    }
    TCEND
}

#pragma mark Get All Comments of Video
- (void)getAllCommentsOfVideoWithVideoId:(NSString *)videoId andCaller:(id)caller andIndexPath:(NSIndexPath *)indexPAth pageNumber:(NSInteger) pageNumber {
    TCSTART
    if ([self isNotNull:videoId]) {
        VideoService *videoService = [[VideoService alloc] initWithCaller:caller];
        videoService.requestURL = APP_URL;
        videoService.indexPath = indexPAth;
        videoService.pageNumber = pageNumber;
        [videoService getAllCommentsOfVideoWithVideoId:videoId];
    } else {
        [ShowAlert showWarning:@"VideoId should not be null"];
    }
    TCEND
    
}

#pragma mark Get All Likes of Video
- (void)getAllLikesListOfVideoWithVideoId:(NSString *)videoId andCaller:(id)caller andIndexPath:(NSIndexPath *)indexPath andPageNumber:(NSInteger)pageNumber {
    if ([self isNotNull:videoId]) {
        VideoService *videoService = [[VideoService alloc] initWithCaller:caller];
        videoService.requestURL = APP_URL;
        videoService.indexPath = indexPath;
        videoService.pageNumber = pageNumber;
        [videoService getAllLikesOfVideoWithVideoId:videoId];
    } else {
        [ShowAlert showWarning:@"VideoId should not be null"];
    }
}
#pragma mark Post comment Request
- (void)makePostCommentRequestForVideo:(NSString *)videoId withCommentText:(NSString *)commentText andCaller:(id)caller andIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:loggedInUser.userId] && [self isNotNull:videoId] && [self isNotNull:commentText]) {
        VideoService *videoService = [[VideoService alloc] initWithCaller:caller];
        videoService.requestURL = APP_URL;
        videoService.indexPath = indexPath;
        [videoService postCommentWithCommmentText:commentText videoId:videoId andUserId:loggedInUser.userId];
    } else {
        [ShowAlert showWarning:@"UserId or VideoId should not be null"];
    }
    TCEND
}

#pragma mark Delete comment Request
- (void)makeDeleteCommentRequestForVideoWithcmntId:(NSString *)cmntId andCaller:(id)caller andIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:loggedInUser.userId] && [self isNotNull:cmntId]) {
        VideoService *videoService = [[VideoService alloc] initWithCaller:caller];
        videoService.requestURL = APP_URL;
        videoService.indexPath = indexPath;
        [videoService deleteCommentOfVideoWithCommentId:cmntId andUserId:loggedInUser.userId];
    } else {
        [ShowAlert showWarning:@"UserId or VideoId should not be null"];
    }
    TCEND
}

#pragma mark Request for Mypage video
- (void)makeRequestForMypageVideosPageNumber:(NSInteger)pageNumber perPage:(NSInteger) perPage andCaller:(id)caller {
    TCSTART
    if ([self isNotNull:loggedInUser.userId] ) {
        VideoService *videoService = [[VideoService alloc] initWithCaller:caller];
        videoService.requestURL = APP_URL;
        videoService.pageNumber = pageNumber;
        videoService.pageSize = perPage;
        [videoService requestForMyPageVideosOfUserWithUserId:loggedInUser.userId];
    } else {
        [ShowAlert showWarning:@"UserId should not be null"];
    }
    TCEND
}

#pragma mark Videofeed
- (void)makeVideoFeedRequestWithPageNumber:(NSInteger)pageNumber pageSize:(NSInteger)pageSize andCaller:(id)caller {
    TCSTART
    if ([self isNotNull:loggedInUser.userId]) {
        VideoService *videoService = [[VideoService alloc] initWithCaller:caller];
        videoService.requestURL = APP_URL;
        videoService.pageNumber = pageNumber;
        videoService.pageSize = pageSize;
        [videoService requestForVideoFeedOfUserWithUserId:loggedInUser.userId];
    } else {
        [ShowAlert showWarning:@"UserId should not be null"];
    }
    TCEND
}

#pragma mark Privatefeed
- (void)makePrivateFeedRequestWithPageNumber:(NSInteger)pageNumber pageSize:(NSInteger)pageSize andCaller:(id)caller {
    TCSTART
    if ([self isNotNull:loggedInUser.userId]) {
        VideoService *videoService = [[VideoService alloc] initWithCaller:caller];
        videoService.requestURL = APP_URL;
        videoService.pageNumber = pageNumber;
        videoService.pageSize = pageSize;
        [videoService requestForPrivateFeedOfUserWithUserId:loggedInUser.userId];
    } else {
        [ShowAlert showWarning:@"UserId should not be null"];
    }
    TCEND
}

#pragma mark Request for Browse Request
- (void)makeRequestForBrowseOfType:(NSString *)browseType pageNumber:(NSInteger)pageNumber perPage:(NSInteger) perPage andCaller:(id)caller {
    TCSTART
    if ([self isNotNull:browseType] ) {
        BrowseService *browseService = [[BrowseService alloc] initWithCaller:caller];
        browseService.requestURL = APP_URL;
        browseService.pageNumber = pageNumber;
        browseService.browseType = browseType;
        browseService.userId_ = loggedInUser.userId;
        [browseService requestForBrowse];
    } else {
        [ShowAlert showWarning:@"Browse type should not be null"];
    }
    TCEND
}


#pragma mark Request for Trends Request
- (void)makeRequestForTrendsPageNumber:(NSInteger)pageNumber andCaller:(id)caller {
    TCSTART
    BrowseService *browseService = [[BrowseService alloc] initWithCaller:caller];
    browseService.requestURL = APP_URL;
    browseService.pageNumber = pageNumber;
    browseService.userId_ = loggedInUser.userId;
    [browseService requestForTrends];
    TCEND
}


#pragma mark Request for Trends details
- (void)makeRequestForTrendsDetailsWithPageNumber:(NSInteger)pageNumber andTagName:(NSString *)tagName andCaller:(id)caller {
    TCSTART
    BrowseService *browseService = [[BrowseService alloc] initWithCaller:caller];
    browseService.requestURL = APP_URL;
    browseService.pageNumber = pageNumber;
    browseService.browseType = @"trends";
    browseService.trendsTagName = tagName;
    browseService.userId_ = loggedInUser.userId;
    [browseService requestForTrendsDetails];
    TCEND
}


#pragma mark Request for Browse Detail Request
- (void)makeRequestForBrowseDetailOfVideo:(NSString *)videoId andUserId:(NSString *)userId pageNumber:(NSInteger)pageNumber andCaller:(id)caller {
    TCSTART
    if ([self isNotNull:videoId] ) {
        BrowseService *browseService = [[BrowseService alloc] initWithCaller:caller];
        browseService.requestURL = APP_URL;
        browseService.pageNumber = pageNumber;
        browseService.userId_ = userId;
        [browseService requestForBrowseDetailsWithVideoId:videoId];
    } else {
        [ShowAlert showWarning:@"Videoid should not be null"];
    }
    TCEND
}

#pragma mark Request for Browse Myotherstuff Request
- (void)makeRequestForOtherStuffOfUserId:(NSString *)userId pageNumber:(NSInteger)pageNumber andCaller:(id)caller {
    TCSTART
    if ([self isNotNull:userId] ) {
        BrowseService *browseService = [[BrowseService alloc] initWithCaller:caller];
        browseService.requestURL = APP_URL;
        browseService.pageNumber = pageNumber;
        browseService.userId_ = userId;
        [browseService requestForMyotherStuff];
    } else {
        [ShowAlert showWarning:@"Userid should not be null"];
    }
    TCEND
}

#pragma mark Request for Browse search Request
- (void)makeRequestForBrowseSearchWithString:(NSString *)searchString ofBrowseType:(NSString *)browseType pageNumber:(NSInteger)pageNumber perPage:(NSInteger) perPage andCaller:(id)caller {
    TCSTART
    if ([self isNotNull:searchString] && [self isNotNull:browseType]) {
        BrowseService *browseService = [[BrowseService alloc] initWithCaller:caller];
        browseService.requestURL = APP_URL;
        browseService.pageNumber = pageNumber;
        browseService.browseType = browseType;
        browseService.userId_ = loggedInUser.userId;
        [browseService requestForSearchWithSearchString:searchString];
    } else {
        [ShowAlert showWarning:@"Search string or browse should not be null"];
    }
    TCEND
}

#pragma mark Request For Search request
- (void)makeRequestForSearchWithString:(NSString *)searchString ofSearchType:(NSString *)searchType pageNumber:(NSInteger)pageNumber anduserId:(NSString *)userId andCaller:(id)caller {
    TCSTART
    if ([self isNotNull:searchString] && [self isNotNull:searchType] && [self isNotNull:userId]) {
        VideoService *videoService = [[VideoService alloc] initWithCaller:caller];
        videoService.requestURL = APP_URL;
        videoService.pageNumber = pageNumber;
        [videoService requestForSearchWithSearchString:searchString andRequestType:searchType andUserID:userId];
    } else {
        [ShowAlert showWarning:@"Search string or userid or browse should not be null"];
    }
    TCEND
}

#pragma mark Notifications Related
#pragma mark get user notifications
- (void)getLoggedInUserNotificationsWithCaller:(id)caller {
    TCSTART
    if ([self isNotNull:loggedInUser.userId]) {
        NotificationService *notificationService = [[NotificationService alloc] initWithCaller:caller];
        
        notificationService.requestURL = APP_URL;
        notificationService.loginUserId = loggedInUser.userId;
        [notificationService makeNetworkConnectionForUserNotifications];
    }
    TCEND
}


#pragma mark remove notifications
- (void)removeLoggedInUserNotificationWithNotificationId:(NSString *)notificationId andCaller:(id)caller {
    TCSTART
    if ([self isNotNull:loggedInUser.userId]) {
        NotificationService *notificationService = [[NotificationService alloc] initWithCaller:caller];
        notificationService.requestURL = APP_URL;
        [notificationService makeNetworkConnectionToRemoveNotificationWithNotificationId:notificationId];
    }
    TCEND
}

#pragma mark video details
- (void)getVideoDetailsOfVideoId:(NSString *)videoId notificationType:(NotificationType)notificationType indexPath:(NSIndexPath *)indexPath andCaller:(id)caller {
    TCSTART
    if ([self isNotNull:videoId]) {
        NotificationService *notificationService = [[NotificationService alloc] initWithCaller:caller];
        notificationService.requestURL = APP_URL;
        notificationService.videoId = videoId;
        notificationService.indexPath = indexPath;
        [notificationService makeNetworkConnectionForVideoDetailsOfNotificationsWithNotificationType:(notificationType + 1)];
    } else {
        [ShowAlert showError:@"Video Id should not be null"];
    }
    TCEND
}


#pragma mark Get notifications settings
- (void)getNotificationsSettingsCaller:(id)caller {
    TCSTART
    if ([self isNotNull:loggedInUser.userId]) {
        NotificationService *notificationService = [[NotificationService alloc] initWithCaller:caller];
        notificationService.requestURL = APP_URL;
        [notificationService makeNetworkConnectionToGetNotificationSettings:loggedInUser.userId];
    }
    TCEND
}


#pragma mark update notification settings
- (void)updateNotificationsSettingsWithParameters:(NSDictionary *)dict andCaller:(id)caller {
    TCSTART
    if ([self isNotNull:loggedInUser.userId]) {
        NotificationService *notificationService = [[NotificationService alloc] initWithCaller:caller];
        notificationService.requestURL = APP_URL;
        [notificationService makeNetworkConnectionToUpdateNotificationsSettingsWithDictionary:dict];
    }
    TCEND
}

#pragma mark notiifcaiton search
- (void)makeNotificaitonsSearchRequestWithSearchKeyword:(NSString *)searchKeyword andCaller:(id)caller {
    TCSTART
    if ([self isNotNull:loggedInUser.userId] && [self isNotNull:searchKeyword]) {
        NotificationService *notificationService = [[NotificationService alloc] initWithCaller:caller];
        notificationService.requestURL = APP_URL;
        notificationService.loginUserId = loggedInUser.userId;
        [notificationService makeNotificationsSearchRequestWithSearchKeyword:searchKeyword];
    }
    TCEND
}

#pragma mark
#pragma mark UploadVideo
- (void)showVideoFeedScreenWithUploadProgressBar {
    TCSTART
    [mainVC disPlayVideoFeed:nil];
    [videoFeedVC.navigationController popToRootViewControllerAnimated:NO];
    TCEND
}

- (void)uploadVideo {
    TCSTART
    if ([self isNotNull:loggedInUser]) {
        if (isUploading || isVideoRecording) {
            return;
        } else {
            Video *video = nil;
            /** Getting all pending videos to upload video parts
             */
            NSArray *pendingPublishVideos = [self.managedObjectContext fetchObjectsForEntityName:@"Video" withPredicate:[NSPredicate predicateWithFormat:@"waitingToUpload == %d && fileUploadCompleted == %d && userId == %@ && hitCount <= 3",TRUE,TRUE,loggedInUser.userId]];
            
            if (pendingPublishVideos.count > 0) {
                video = [pendingPublishVideos firstObject];
                video.uploadPercent = [NSNumber numberWithInt:100];
                [[DataManager sharedDataManager] saveChanges];
                
                uploadedVideoInfo = [[Upload alloc] initWithMediaId:video.clientId WithUserInfo:video];
                uploadedVideoInfo.percentageComplete = 2.0;
                if (!video.loadingViewHidden.boolValue) {
                    [videoFeedVC setVisibilityForVideouploadingView:YES andPublishing:YES];
                }
                
                [self setProgressToUploadingViewInVideoFeedVC:2.0 andVideoClientId:video.clientId Completed:NO];
                [self requestVideoUpload:uploadedVideoInfo];
            } else {
                
                /** Getting all pending videos that already uploaded video parts
                 */
                NSArray *pendingUploads;
                NSArray *pendingUploadsFromV1 = [self.managedObjectContext fetchObjectsForEntityName:@"Video" withPredicate:[NSPredicate predicateWithFormat:@"waitingToUpload == %d && fileUploadCompleted == %d && userId == %@",TRUE,FALSE,loggedInUser.userId]];
                if (pendingUploadsFromV1.count > 0) {
                    Video *pendingvideo = [pendingUploadsFromV1 firstObject];
                    if ([self isNotNull:pendingvideo.checkSumFailed]) {
                        pendingUploads = [self.managedObjectContext fetchObjectsForEntityName:@"Video" withPredicate:[NSPredicate predicateWithFormat:@"waitingToUpload == %d && fileUploadCompleted == %d && userId == %@ && checkSumFailed == %d",TRUE,FALSE,loggedInUser.userId,FALSE]];
                    } else {
                        pendingUploads = [self.managedObjectContext fetchObjectsForEntityName:@"Video" withPredicate:[NSPredicate predicateWithFormat:@"waitingToUpload == %d && fileUploadCompleted == %d && userId == %@",TRUE,FALSE,loggedInUser.userId]];
                    }
                }
                
                NSInteger partNumber = 0;
                
                if (pendingUploads.count > 0) {
                    NSString *clientVideoId = [[NSUserDefaults standardUserDefaults]objectForKey:@"clientVideoid"];
                    if (clientVideoId.integerValue > 0) {
                        //check if any part is pending to upload.
                        partNumber = [[[NSUserDefaults standardUserDefaults]objectForKey:@"partNumber"]integerValue];
                        //first get the video object which matches above clientVideoId from pendinguploads array
                        video = [[DataManager sharedDataManager] getVideoByVideoIdOrVideoClientId:[NSMutableDictionary dictionaryWithObjectsAndKeys:clientVideoId,@"clientId", nil]];
                        if ([self isNull:video]) {
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"clientVideoid"];
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"partNumber"];
                            [self uploadVideo];
                        }
                    } else {
                        video = [pendingUploads firstObject];
                        partNumber = 1;
                        clientVideoId = video.clientId;
                    }
                    
                    if ([self isNotNull:video]) {
                        [self performSelector:@selector(removeVideoFeedVCLoadingViewFromVCAndShowAlert) withObject:nil afterDelay:60];
                        
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,(unsigned long)NULL), ^(void) {
                            [self uploadVideoWithThread:[NSDictionary dictionaryWithObjectsAndKeys:video,@"video",clientVideoId?:@"",@"clientVideoId",[NSNumber numberWithInteger:partNumber],@"partNumber", nil]];
                        });
                    }
                }
            }
        }
    }
    TCEND
}

- (void)uploadVideoWithThread:(NSDictionary *)paramsDict {
    TCSTART
    //    @autoreleasepool {
    Video *video;
    if ([self isNotNull:[paramsDict objectForKey:@"video"]]) {
        video = [paramsDict objectForKey:@"video"];
    }
    
    NSString *clientVideoId;
    if ([self isNotNull:[paramsDict objectForKey:@"clientVideoId"]]) {
        clientVideoId = [paramsDict objectForKey:@"clientVideoId"];
    }
    
    NSInteger partNumber;
    if ([self isNotNull:[paramsDict objectForKey:@"partNumber"]]) {
        partNumber = [[paramsDict objectForKey:@"partNumber"] integerValue];
    }
    //////////Compress to medium quality//////////////////
    
    NSString *documentsPath = [self getApplicationDocumentsDirectoryAsString];
    
    documentsPath = [NSString stringWithFormat:@"%@/mediumQualityVideo%@.mov",documentsPath,clientVideoId];
    
    [self showNetworkIndicator];
    isUploading = YES;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:documentsPath]) {
        exportSessionRef = nil;
        isVideoExporting = NO;
        NSData *sampleVideoData = [[NSData alloc]initWithContentsOfFile:documentsPath];
        NSLog(@"Compressed data lenght:%d",sampleVideoData.length);
        NSLog(@"Compressed to medium quality Video file size is %d MB",sampleVideoData.length/(1024 * 1024));
        Upload * upload_ = [[Upload alloc] initWithUrl:[NSURL URLWithString:MULTIPART_VIDEO_UPLOAD] WithFileName:video.title WithfileType:@"mov" WithfilePath:documentsPath withMediaId:clientVideoId WithUserInfo:video withUploadPartNumber:partNumber];
        
        [[UploadManager sharedUploadManager]queueUpload:upload_];
        
    } else {
        NSURL *outputURL = [NSURL fileURLWithPath:documentsPath];
        NSURL *videoURL = [NSURL fileURLWithPath:video.path];
        if ([self isNotNull:videoFeedVC] && videoFeedVC.progressView.isHidden && !video.loadingViewHidden.boolValue) {
            [videoFeedVC setVisibilityForVideouploadingView:YES andPublishing:NO];
        }
        [self setProgressToUploadingViewInVideoFeedVC:0.0 andVideoClientId:video.clientId Completed:NO];
        
        [self convertVideoToMediumQuailtyWithInputURL:videoURL outputURL:outputURL andVideoClientId:clientVideoId handler:^(AVAssetExportSession *exportSession) {
            exportSessionRef = nil;
            isVideoExporting = NO;
            
            //                [self hideNetworkIndicator];
            if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                
                NSData *sampleVideoData = [[NSData alloc]initWithContentsOfFile:documentsPath];
                NSLog(@"Compressed data lenght:%d",sampleVideoData.length);
                NSLog(@"Compressed to medium quality Video file size is %d MB",sampleVideoData.length/(1024 * 1024));
                Upload * upload_ = [[Upload alloc] initWithUrl:[NSURL URLWithString:MULTIPART_VIDEO_UPLOAD] WithFileName:video.title WithfileType:@"mov" WithfilePath:documentsPath withMediaId:clientVideoId WithUserInfo:video withUploadPartNumber:partNumber];
                
                [[UploadManager sharedUploadManager]queueUpload:upload_];
            } else {
                printf("Export error\n");
                NSLog(@"error :%@",exportSession.error);
                //                    isLoadingViewHiddenForParticularVideo = NO;
                [videoFeedVC hideVideoUplaodingView];
                isUploading = NO;
                if (exportSession.status == AVAssetExportSessionStatusFailed) {
                    NSLog(@"export failure");
                    if ([[NSFileManager defaultManager] fileExistsAtPath:documentsPath]) {
                        [[NSFileManager defaultManager] removeItemAtPath:documentsPath error:Nil];
                    }
                    NSDictionary *paramsDict;
                    if ([[NSFileManager defaultManager] fileExistsAtPath:video.path]) {
                        paramsDict = [[NSDictionary alloc] initWithObjectsAndKeys:video,@"video",[NSNumber numberWithBool:NO],@"deleteVideo", nil];
                    } else {
                        paramsDict = [[NSDictionary alloc] initWithObjectsAndKeys:video,@"video",[NSNumber numberWithBool:YES],@"deleteVideo", nil];
                    }
                    [self performSelectorOnMainThread:@selector(exportFailedForVideo:) withObject:paramsDict waitUntilDone:NO];
                }
            }
        }];
    }
    TCEND
}

- (void)exportFailedForVideo:(NSDictionary *)dict {
    TCSTART
    Video *video = [dict objectForKey:@"video"];
    if ([[dict objectForKey:@"deleteVideo"] boolValue]) {
        [[DataManager sharedDataManager] deleteVideo:video];
    }
    if (pendingVideosVC) {
        [pendingVideosVC refreshScreenByFetchingPendingVideos];
    }
    [self uploadVideo];
    TCEND
}

/** Video compression
 */
- (void)convertVideoToMediumQuailtyWithInputURL:(NSURL *)inputURL
                                      outputURL:(NSURL *)outputURL andVideoClientId:(NSString *)clientId
                                        handler:(void (^)(AVAssetExportSession *))handler {
    TCSTART
    [self setProgressToUploadingViewInVideoFeedVC:0.0 andVideoClientId:clientId Completed:NO];
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputURL;
    //    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportProgressBarTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(updateExportDisplay:) userInfo:[NSDictionary dictionaryWithObjectsAndKeys:exportSession,@"session",clientId,@"clientVideoId", nil] repeats:YES];
    NSLog(@"\n\n\n\n\n\n\n\n\nExporting................file path:%@\n\n\n\n\n\n\n\n",inputURL);
    exportSessionRef = exportSession;
    isVideoExporting = YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
        [exportProgressBarTimer invalidate];
        exportProgressBarTimer = nil;
        handler(exportSession);
    }];
    TCEND
}

- (void)cancelExport {
    TCSTART
    if ([self isNotNull:exportSessionRef]) {
        [exportSessionRef cancelExport];
        isUploading = NO;
        [exportProgressBarTimer invalidate];
        exportProgressBarTimer = nil;
        [self hideNetworkIndicator];
    }
    TCEND
}

- (void) updateExportDisplay:(NSTimer *)timer {
    TCSTART
    //    NSLog(@"Timer called");
    NSDictionary *dict = timer.userInfo;
    AVAssetExportSession *exportSession;
    if ([self isNotNull:[dict objectForKey:@"session"]]) {
        exportSession = [dict objectForKey:@"session"];
    }
    [videoFeedVC setVisibilityForVideouploadingView:YES andPublishing:NO];
    [self setProgressToUploadingViewInVideoFeedVC:exportSession.progress andVideoClientId:[dict objectForKey:@"clientVideoId"]?:@"" Completed:NO];
    TCEND
}

- (void)showActivityIndicatorWithText:(NSString*)text {
	TCSTART
	[self removeActivityIndicator];
	
	MBProgressHUD* hud   = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
	hud.labelText        = text;
    hud.color            = [UIColor blackColor];
    hud.alpha            = 0.7;
	hud.detailsLabelText = NSLocalizedString(@"", @"");
	TCEND
}

- (void)removeActivityIndicator {
	[MBProgressHUD hideHUDForView:self.window animated:YES];
}

#pragma mark UploadManager Delegate Methods.
- (void) uploadManager: (UploadManager*) uploadManager didQueueUpload: (Upload*) upload {
	
}

- (void) uploadManager: (UploadManager*) uploadManager didCancelUpload: (Upload*) upload {
    TCSTART
    /** Errorcode 1009 indicates network failure for all remaining errors giving retry option in Pendingvideos
     */
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeVideoFeedVCLoadingViewFromVCAndShowAlert) object:nil];
    Video *video = upload.userInfo;
    
    if (upload.error.code == -1009 && !video.loadingViewHidden.boolValue) {
        video.loadingViewHidden = [NSNumber numberWithBool:YES];
        [[DataManager sharedDataManager] saveChanges];
        [videoFeedVC hideVideoUplaodingView];
        [ShowAlert showWarning:@"Hey! You don’t have internet access. Don’t worry your captured video is safe In pending videos. Will upload automatically when u have internet access."];
    } else {
        NSLog(@"Error :%@",upload.error);
        [ShowAlert showAlert:@"Failed to upload video, Access the retry option in pending videos under quick link to upload again"];
        video.checkSumFailed = [NSNumber numberWithBool:YES];
        if (!video.loadingViewHidden.boolValue) {
            video.loadingViewHidden = [NSNumber numberWithBool:YES];
            [videoFeedVC hideVideoUplaodingView];
        }
        [[DataManager sharedDataManager] saveChanges];
        if ([self isNotNull:pendingVideosVC]) {
            [pendingVideosVC refreshScreenByFetchingPendingVideos];
        }
    }
    
    isUploading = NO;
    if ([self statusForNetworkConnectionWithOutMessage]) {
        [self uploadVideo];
    }
    
    TCEND
}

- (void) uploadManager: (UploadManager*) uploadManager didStartUpload: (Upload*) upload {
    TCSTART
    Video *video = upload.userInfo;
    if (!video.loadingViewHidden.boolValue) {
        [videoFeedVC setVisibilityForVideouploadingView:YES andPublishing:NO];
    }
    TCEND
}

- (void) uploadManager: (UploadManager*) uploadManager didUpdateUpload: (Upload*) upload {
    TCSTART
    Video *video = upload.userInfo;
    //    NSLog(@"PertageCompleted :%f",upload.percentageComplete);
    if ([self isNotNull:videoFeedVC] && videoFeedVC.progressView.isHidden && !video.loadingViewHidden.boolValue) {
        [videoFeedVC setVisibilityForVideouploadingView:YES andPublishing:NO];
    }
    
    video.uploadPercent = [NSNumber numberWithInt:(upload.percentageComplete - 0.1 + 1.0f)/2.0 * 100];
    [[DataManager sharedDataManager] saveChanges];
    [self setProgressToUploadingViewInVideoFeedVC:(upload.percentageComplete - 0.1 + 1.0f) andVideoClientId:upload.mediaId Completed:NO];
    TCEND
}

- (void)setProgressToUploadingViewInVideoFeedVC:(CGFloat)progressValue andVideoClientId:(NSString *)clientVideoId Completed:(BOOL)completed {
    TCSTART
    
    if ([self isNotNull:videoFeedVC]/** && [videoFeedVC respondsToSelector:@selector(setUploadedBufferToLoadingView:)]*/) {
        //        [videoFeedVC setUploadedBufferToLoadingView:upload.percentageComplete];
        videoFeedVC.progressView.progressValue = progressValue/2.0;
        [videoFeedVC.progressView setNeedsDisplay];
    }
    if ([self isNotNull:pendingVideosVC]) {
        [pendingVideosVC uploadPercentage:progressValue/2.0 * 100 ofVideo:clientVideoId completed:completed];
    }
    //    [self updateVideoObjectWithPercentOfclientId:clientVideoId progressValue:progressValue completed:completed];
    
    TCEND
}

/** After upload parts completed making request for file uplaod menas checksum validaiton
 */
- (void) uploadManager: (UploadManager*) uploadManager didFinishUpload: (Upload*) upload withData: (NSData*) data {
    TCSTART
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"clientVideoid"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"partNumber"];
    uploadedVideoInfo = upload;
    Video *video = upload.userInfo;
    video.uploadPercent = [NSNumber numberWithInt:(upload.percentageComplete + 1.0f - 0.1)/2.0 * 100];
    [[DataManager sharedDataManager] saveChanges];
    
    [self setProgressToUploadingViewInVideoFeedVC:(uploadedVideoInfo.percentageComplete + 1.0f - 0.1) andVideoClientId:uploadedVideoInfo.mediaId Completed:NO];
    [self requestFileUpload:upload];
    TCEND
}

#pragma mark file upload request for checksum validation
- (void)requestFileUpload:(Upload *)upload {
    TCSTART
    if ([self statusForNetworkConnectionWithOutMessage]) {
        isUploading = YES;
        Video *video = (Video *)upload.userInfo;
        
        NSString *checksum = [[NSData dataWithContentsOfFile:upload.filePath]MD5];
        NSString *body = [NSString stringWithFormat:@"{\"video\":{\"clientvideoId\":\"%@\",\"Uid\":\"%@\",\"Title\":\"%@\",\"Public\":%d,\"File_name\":\"video0.mov\",\"Upload_date\":\"%@\",\"Description\":\"%@\",\"Extension\":\"mov\",\"Uploaded_device\":\"%@\",\"checksum\":\"%@\",\"Totalcount\":\"%d\"}}",video.clientId,video.userId,video.title,video.public.integerValue,video.creationTime,video.info,[[UIDevice currentDevice]localizedModel],checksum,upload.totalParts];
        
        NetworkConnection *networkConn = [[NetworkConnection alloc] init];
        [NSThread detachNewThreadSelector:@selector(videoFileUploadRequestWithParameters:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:body, @"body",FILEUPLOAD,@"url",self, @"caller",nil]];
        [self showNetworkIndicator];
        
    } else {
        isUploading = NO;
        [self removeVideoFeedVCLoadingViewFromVCAndShowAlert];
        if ([self statusForNetworkConnectionWithOutMessage]) {
            [self requestFileUpload:uploadedVideoInfo];
        }
    }
    TCEND
}


- (void)didFinishedToFileUploadVideoInfo:(NSDictionary *)resposneDict {
    TCSTART
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeVideoFeedVCLoadingViewFromVCAndShowAlert) object:nil];
    [self hideNetworkIndicator];
    if ([self isNotNull:resposneDict] && [self isNotNull:[resposneDict objectForKey:@"error_code"]]) {
        
        Video *compressedVideo = (Video *)uploadedVideoInfo.userInfo;
        if (!compressedVideo.loadingViewHidden.boolValue) {
            [videoFeedVC setVisibilityForVideouploadingView:YES andPublishing:YES];
        }
        [self setProgressToUploadingViewInVideoFeedVC:2.0 andVideoClientId:compressedVideo.clientId Completed:NO];
        compressedVideo.uploadPercent = [NSNumber numberWithInt:100];
        compressedVideo.totalVideoParts = [NSNumber numberWithInt:uploadedVideoInfo.totalParts];
        compressedVideo.fileUploadCompleted = [NSNumber numberWithBool:YES];
        
        NSString *checksum = [[NSData dataWithContentsOfFile:uploadedVideoInfo.filePath]MD5];
        compressedVideo.checksum = [NSString stringWithFormat:@"%@",checksum];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:uploadedVideoInfo.filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:uploadedVideoInfo.filePath error:Nil];
        }
        
        [[DataManager sharedDataManager] saveChanges];
        /** After checksum validation completed making request for video publish
         */
        [self requestVideoUpload:uploadedVideoInfo];
    }
    TCEND
}

/** If checksum vlaidation failed then giving retry option for failed video in pending videos viewcontroller
 */
- (void)didFailToFileUploadVideoInfoWithError:(NSDictionary *)errorDict {
    TCSTART
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeVideoFeedVCLoadingViewFromVCAndShowAlert) object:nil];
    isUploading = NO;
    [self hideNetworkIndicator];
    if ([self isNotNull:[errorDict objectForKey:@"networkstatuscode"]] && [[errorDict objectForKey:@"networkstatuscode"] intValue] != -1009) {
        [ShowAlert showAlert:@"Failed to upload video, Access the retry option in pending videos under quick link to upload again"];
        Video *compressedVideo = (Video *)uploadedVideoInfo.userInfo;
        compressedVideo.checkSumFailed = [NSNumber numberWithBool:YES];
        if (!compressedVideo.loadingViewHidden.boolValue) {
            compressedVideo.loadingViewHidden = [NSNumber numberWithBool:YES];
            [videoFeedVC hideVideoUplaodingView];
        }
        [[DataManager sharedDataManager] saveChanges];
        if ([self isNotNull:pendingVideosVC]) {
            [pendingVideosVC refreshScreenByFetchingPendingVideos];
        }
    } else {
        [self removeVideoFeedVCLoadingViewFromVCAndShowAlert];
    }
    [self uploadVideo];
    TCEND
}

- (void)removeVideoFeedVCLoadingViewFromVCAndShowAlert {
    TCSTART
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeVideoFeedVCLoadingViewFromVCAndShowAlert) object:nil];
    Video *video = uploadedVideoInfo.userInfo;
    if ([self isNotNull:videoFeedVC] && !video.loadingViewHidden.boolValue && !videoFeedVC.videoLoadingView.hidden && ![video.fileUploadCompleted boolValue]) {
        video.loadingViewHidden = [NSNumber numberWithBool:YES];
        [[DataManager sharedDataManager] saveChanges];
        [videoFeedVC hideVideoUplaodingView];
        [ShowAlert showAlert:@"We are having trouble with your internet access to upload, Don’t worry your video is safe in pending videos. Will upload automatically when u have internet access"];
    }
    TCEND
}

#pragma mark video upload request for publishing video
- (void)requestVideoUpload:(Upload *)upload {
    TCSTART
    Video *video = (Video *)upload.userInfo;
    if ([self statusForNetworkConnectionWithOutMessage]) {
        isUploading = YES;
        int count = [video.hitCount intValue];
        NSString *body = [NSString stringWithFormat:@"{\"video\":{\"clientvideoId\":\"%@\",\"Uid\":\"%@\",\"Title\":\"%@\",\"Public\":%d,\"File_name\":\"video0.mov\",\"Upload_date\":\"%@\",\"Description\":\"%@\",\"Extension\":\"mov\",\"Uploaded_device\":\"%@\",\"checksum\":\"%@\",\"Totalcount\":\"%d\",\"hit_count\":\"%d\",\"frame_time\":\"%.2f\"}}",video.clientId,video.userId,video.title,video.public.integerValue,video.creationTime,video.info,[[UIDevice currentDevice]localizedModel],video.checksum,[video.totalVideoParts intValue],count,video.coverFrameValue];
        //        NSString *body = [NSString stringWithFormat:@"{\"video\":{\"clientvideoId\":\"%@\",\"Uid\":\"%@\",\"Title\":\"%@\",\"Public\":%d,\"File_name\":\"video0.mov\",\"Upload_date\":\"%@\",\"Description\":\"%@\",\"Extension\":\"mov\",\"Uploaded_device\":\"%@\",\"checksum\":\"%@\",\"Totalcount\":\"%d\",\"hit_count\":\"%d\"}}",video.clientId,video.userId,video.title,video.public.integerValue,video.creationTime,video.info,[[UIDevice currentDevice]localizedModel],video.checksum,[video.totalVideoParts intValue],count];
        video.hitCount = [NSNumber numberWithInt:(count + 1)];
        [[DataManager sharedDataManager] saveChanges];
        
        NetworkConnection *networkConn = [[NetworkConnection alloc] init];
        [NSThread detachNewThreadSelector:@selector(videoUploadRequestWithParameters:) toTarget:networkConn withObject:[NSDictionary dictionaryWithObjectsAndKeys:body, @"body",VIDEOUPLOAD,@"url",self, @"caller",nil]];
        [self showNetworkIndicator];
        
    } else {
        isUploading = NO;
        [self removeVideoFeedVCLoadingViewAndShowAlertForPublishAPI:video];
        if ([self statusForNetworkConnectionWithOutMessage]) {
            [self requestVideoUpload:uploadedVideoInfo];
        }
    }
    TCEND
}

- (void)removeVideoFeedVCLoadingViewAndShowAlertForPublishAPI:(Video *)video {
    TCSTART
    
    if (!video.loadingViewHidden.boolValue) {
        video.loadingViewHidden = [NSNumber numberWithBool:YES];
        [[DataManager sharedDataManager] saveChanges];
        [videoFeedVC hideVideoUplaodingView];
        [ShowAlert showWarning:@"Your video is successfully uploaded, we have some trouble to publish the video. We are on it and will notify soon.."];
    }
    TCEND
}
- (void)didFinishedToUploadVideoInfo:(NSDictionary *)response {
    TCSTART
    
    isUploading = NO;
    [self hideNetworkIndicator];
    if ([self isNotNull:response] && [self isNotNull:[response objectForKey:@"error_code"]]) {
        if ([[response objectForKey:@"error_code"] integerValue] == 0 && [self isNotNull:[response objectForKey:@"video_id"]]) {
            [self setProgressToUploadingViewInVideoFeedVC:2.0 andVideoClientId:uploadedVideoInfo.mediaId Completed:YES];
            Video *compressedVideo = (Video *)uploadedVideoInfo.userInfo;
            
            // Remove file at path from filemanager
            if ([[NSFileManager defaultManager] fileExistsAtPath:compressedVideo.path]) {
                [[NSFileManager defaultManager] removeItemAtPath:compressedVideo.path error:Nil];
            }
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:uploadedVideoInfo.filePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:uploadedVideoInfo.filePath error:Nil];
            }
            
            //Checking for video shraring FB,TW and G+
            Video *video = [[DataManager sharedDataManager] getVideoByVideoIdOrVideoClientId:[NSMutableDictionary dictionaryWithObjectsAndKeys:uploadedVideoInfo.mediaId,@"clientId", nil]];
            
            VideoModal *videoModal = [self returnVideoModalObjectByParsing:response];
            uploadedVideoModal = videoModal;
            
            //Checking for tags
            NSArray *tagsArray = [[DataManager sharedDataManager] getAllTagsByVideoIdAndClientVideoId:[NSDictionary dictionaryWithObjectsAndKeys:uploadedVideoInfo.mediaId,@"clientVideoId", nil]];
            
            [self setAndUpdateAllClientVideoIdTagsToVideoId:tagsArray videoId:[response objectForKey:@"video_id"]];
            
            if (video.shareToFB.boolValue) {
                if (FBSession.activeSession.isOpen) {
                    [self performPublishAction:^ { [self postToFacebookUserWallWithOutDialog:videoModal andToId:@"me"];}];
                } else {
                    [self postToFacebookUserWallWithOutDialog:videoModal andToId:@"me"];
                }
            }
            
            if (video.shareToTw.boolValue) {
                NSString *string = [NSString stringWithFormat:@"%@\n%@\n%@",videoModal.title,videoModal.shareUrl,videoModal.info?:@""];
                [self PostToTwitterWithMsg:string toUser:@"me" withImageUrl:videoModal.videoThumbPath andVideoId:videoModal.videoId];
            }
            
            if (video.shareToGPlus.boolValue) {
                [self shareToGooglePlusUserWithUserId:nil andVideo:videoModal];
            }
            
            // Delete the video from DB which completed uploading
            [[DataManager sharedDataManager] deleteVideo:video];
            
            //Showing alert when user in is other than video feed screen
            [self showVideoUploadedAlertIfUserIsNotInVideoFeedScreenWithVideoModal:videoModal hasTags:(tagsArray.count > 0)?YES:NO];
            //            isLoadingViewHiddenForParticularVideo = NO;
            //upload request for pending videos
            [self uploadVideo];
            
        } else {
            //            isLoadingViewHiddenForParticularVideo = NO;
            [self uploadVideo];
        }
    }
    
    TCEND
}

- (void)didFailToUploadVideoInfoWithError:(NSDictionary *)errorDict {
    TCSTART
    
    isUploading = NO;
    [self hideNetworkIndicator];
    Video *video = [[DataManager sharedDataManager] getVideoByVideoIdOrVideoClientId:[NSMutableDictionary dictionaryWithObjectsAndKeys:uploadedVideoInfo.mediaId,@"clientId", nil]];
    
    if ([self isNotNull:[errorDict objectForKey:@"networkstatuscode"]] && [[errorDict objectForKey:@"networkstatuscode"] intValue] != -1009 && video.hitCount.intValue > 3) {
        [ShowAlert showAlert:@"We are experiencing trouble to publish your video. Access pending videos from quick link to retry or Delete and Save a copy of your video"];
        video.videoPublishingFailed = [NSNumber numberWithBool:YES];
        
        if (!video.loadingViewHidden.boolValue) {
            video.loadingViewHidden = [NSNumber numberWithBool:YES];
            [videoFeedVC hideVideoUplaodingView];
        }
        [[DataManager sharedDataManager] saveChanges];
        if ([self isNotNull:pendingVideosVC]) {
            [pendingVideosVC refreshScreenByFetchingPendingVideos];
        }
    } else {
        if (!video.loadingViewHidden.boolValue) {
            video.loadingViewHidden = [NSNumber numberWithBool:YES];
            [videoFeedVC hideVideoUplaodingView];
            [ShowAlert showWarning:@"Your video is successfully uploaded, we have some trouble to publish the video. We are on it and will notify soon.."];
        }
        isUploading = YES;
        //        video.hitCount = [NSNumber numberWithInt:1];
        //        [[DataManager sharedDataManager] saveChanges];
        if ([self isNotNull:pendingVideosVC]) {
            [pendingVideosVC refreshScreenByFetchingPendingVideos];
        }
        [self requestVideoUpload:uploadedVideoInfo];
    }
    
    [self uploadVideo];
    TCEND
}

/** If present viewcontroller is not the videofeedvc means home then we need to display alert by specifying vidoe uplaoded successfully
 */
- (void)showVideoUploadedAlertIfUserIsNotInVideoFeedScreenWithVideoModal:(VideoModal *)videoModal hasTags:(BOOL)hasTags {
    TCSTART
    NSLog(@"RootViewController :%@", self.window.rootViewController.presentedViewController);
    //    if (!isLoadingViewHiddenForParticularVideo) {
    [videoFeedVC setVisibilityForVideouploadingView:NO andPublishing:NO];
    //    }
    if ([self isNotNull:mainVC]) {
        [mainVC performSelector:@selector(refreshAllScreens) withObject:nil afterDelay:0.7];
    }
    if (([self isNull:videoFeedVC] || !isVideoFeedVCDisplays) && !isRecordingScreenDisplays && [self isNotNull:loggedInUser]) {
        uploadedVideoModal = videoModal;
        UIAlertView *videoAlert = [[UIAlertView alloc] initWithTitle:@"WooTag" message:@"Video Uploaded Successfully" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Share", nil];
        if (!hasTags) {
            [videoAlert addButtonWithTitle:@"Tag"];
        }
        [videoAlert show];
    }
    TCEND
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    TCSTART
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle caseInsensitiveCompare:@"Share"] == NSOrderedSame) {
        [self presentShareViewController];
    } else if ([buttonTitle caseInsensitiveCompare:@"Tag"] == NSOrderedSame) {
        [self presentVideoPlayerScreenForTagging];
    }
    TCEND
}

- (void)presentShareViewController {
    TCSTART
    ShareViewController *shareVC = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil withSelectedVideo:uploadedVideoModal andCaller:self];
    shareVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.window.rootViewController presentViewController:shareVC animated:YES completion:nil];
    TCEND
}

#pragma mark present Custommoviewplayer
- (void)presentVideoPlayerScreenForTagging {
    TCSTART
    customMoviePlayerVC = [[CustomMoviePlayerViewController alloc]initWithNibName:@"CustomMoviePlayerViewController" bundle:nil video:uploadedVideoModal videoFilePath:nil andClientVideoId:uploadedVideoModal.videoId showInstrcutnScreen:NO];
    customMoviePlayerVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.window.rootViewController presentViewController:customMoviePlayerVC animated:YES completion:nil];
    customMoviePlayerVC.caller = self;
    TCEND
}

- (void)playerScreenDismissed {
    TCSTART
    customMoviePlayerVC = nil;
    TCEND
}

- (NSString *)getUDID {
	NSString * UDID = [[NSUserDefaults standardUserDefaults]objectForKey:@"UDID"];
	if([self isNull:UDID]) {
		UDID = [OpenUDID value];
		[[NSUserDefaults standardUserDefaults] setObject:UDID forKey:@"UDID"];
	}
    return UDID;
}

- (int)generateUniqueId {
	NSNumber * uniqueId = [[NSUserDefaults standardUserDefaults] objectForKey:@"uniqueId"];
	
	if(uniqueId == nil) {
		uniqueId = [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
	}
    
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(uniqueId.intValue + 1)] forKey:@"uniqueId"];
	
	return (uniqueId.intValue + 1);
}

- (NSString *)generateUniqueVideoId {
	NSNumber * uniqueId = [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
	
	int random = arc4random() % 9;
	return [NSString stringWithFormat:@"%d%d",random,[uniqueId intValue]];
	
}

-(NSMutableString *)formattedGMTDateInString {
	return [NSMutableString stringWithFormat:@"%@Z",[NSDate stringFromDate:[self GMTDate]withFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"]];
}

-(NSDate *) GMTDate {
    return [[NSDate date] dateByAddingTimeInterval:-[[NSTimeZone systemTimeZone] secondsFromGMTForDate:[NSDate date]]];
}

- (void)createDirectoryInDocumentsFolderWithName:(NSString *)dirName {
    
    NSString *documentsDirectory = [self getApplicationDocumentsDirectoryAsString];
    NSString *yourDirPath = [documentsDirectory stringByAppendingPathComponent:dirName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    BOOL isDirExists = [fileManager fileExistsAtPath:yourDirPath isDirectory:&isDir];
    if (!isDirExists) [fileManager createDirectoryAtPath:yourDirPath withIntermediateDirectories:YES attributes:nil error:nil];
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark Attributed string related
- (NSMutableAttributedString *)getAttributedStringForString:(NSString *)text withBoldRanges:(NSArray *)boldRangesArray WithBoldFontName:(NSString *)boldfontName withNormalFontName:(NSString *)normalFontName italicRangesArray:(NSArray *)italicRangesArray {
    
    @try {
        if ([self isNotNull:text]) {
            
            NSMutableAttributedString *mAttrbtdString = [[NSMutableAttributedString alloc]initWithString:text];
            CFStringRef _boldFontName = (__bridge_retained CFStringRef) boldfontName;
            CFStringRef _normalFontName = (__bridge_retained CFStringRef) normalFontName;
            CFStringRef _itlaicFontName = (__bridge_retained CFStringRef) dateFontName;
            
            CTFontRef HeliveticaBold = CTFontCreateWithName(_boldFontName, 14, NULL);
            CTFontRef HeliveticaRegular = CTFontCreateWithName(_normalFontName, 14, NULL);
            CTFontRef HeliveticaOblique = CTFontCreateWithName(_itlaicFontName, 11, NULL);
            CGColorRef boldTextColor = [self colorWithHexString:@"11a3e7"].CGColor;
            
            [mAttrbtdString addAttribute:(id)kCTFontAttributeName
                                   value:(__bridge id)HeliveticaRegular
                                   range:[text rangeOfString:text]];
            
            for (NSValue *value in boldRangesArray) {
                
                NSRange boldRange = [value rangeValue];
                
                if ([self isNotNull:mAttrbtdString] && boldRange.location != NSNotFound && boldRange.length > 0) {
                    
                    [mAttrbtdString addAttribute:(id)kCTFontAttributeName
                                           value:(__bridge id)HeliveticaBold
                                           range:boldRange];
                    [mAttrbtdString addAttribute:(id)kCTForegroundColorAttributeName
                                           value:(__bridge id)boldTextColor
                                           range:boldRange];
                }
            }
            
            for (NSValue *value in italicRangesArray) {
                
                NSRange italicRange = [value rangeValue];
                
                if ([self isNotNull:mAttrbtdString] && italicRange.location != NSNotFound && italicRange.length > 0) {
                    
                    [mAttrbtdString addAttribute:(id)kCTFontAttributeName
                                           value:(__bridge id)HeliveticaOblique
                                           range:italicRange];
                }
            }
            
            CFRelease(HeliveticaBold);
            CFRelease(HeliveticaRegular);
            CFRelease(HeliveticaOblique);
            
            return mAttrbtdString;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
        
    }
}

#pragma mark LeftPadding for UItextfield
- (void)setLeftPaddingforTextField:(UITextField *)textfield {
    TCSTART
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    textfield.leftView = paddingView;
    textfield.leftViewMode = UITextFieldViewModeAlways;
    TCEND
}

- (CGSize)getFrameSizeForAttributedString:(NSAttributedString *)attributedString withWidth:(NSInteger)width {
    
    @try {
        CFIndex offset = 0, length;
        CGFloat y = 0;
        NSInteger numberOfLines = 0;
        do {
            CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
            length = CTTypesetterSuggestLineBreak(typesetter, offset, width);
            CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(offset, length));
            numberOfLines++;
            if(typesetter){
                CFRelease(typesetter);
                typesetter = nil;
            }
            
            CGFloat ascent, descent, leading;
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            
            if(line){
                CFRelease(line);
                line = nil;
            }
            
            offset += length;
            y += ascent + descent + leading;
        } while (offset < [attributedString length]);
        
        return CGSizeMake(width, ceil(y));
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
        
    }
}

/** Developer log to fix any issues
 */
- (void)writeLog:(NSString *)logString {
    TCSTART
    BOOL result = YES;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:@"DeveloperLog.txt"];
    
    NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:path];
    if ( !fh ) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        fh = [NSFileHandle fileHandleForWritingAtPath:path];
    }
    if ( !fh ) return;
    @try {
        [fh seekToEndOfFile];
        logString = [NSString stringWithFormat:@"%@:   %@",[NSDate date],logString];
        [fh writeData:[logString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    @catch (NSException * e) {
        result = NO;
    }
    [fh closeFile];
    TCEND
}

// FBSample logic
// In the login workflow, the Facebook native application, or Safari will transition back to
// this applicaiton via a url following the scheme fb[app id]://; the call to handleOpenURL
// below captures the token, in the case of success, on behalf of the FBSession object

- (void)loginViewForFB {
    TCSTART
    // Create Login View so that the app will be granted permission.
    //    publish_actions
    facebookReadPermissions = [[NSArray alloc] initWithObjects:@"basic_info",@"email",@"user_hometown",@"friends_hometown",@"user_location",@"friends_location",@"user_relationships",@"friends_relationships",@"user_education_history",@"user_work_history",@"friends_education_history",@"friends_work_history",@"friends_online_presence",@"user_online_presence",@"friends_status",@"user_status",@"user_birthday",@"friends_birthday",@"user_likes", nil];
    FBLoginView *loginview = [[FBLoginView alloc] init];
    loginview.readPermissions = facebookReadPermissions;
    loginview.frame = CGRectOffset(loginview.frame, 5, 5);
    loginview.delegate = self;
    [self.window addSubview:loginview];
    loginview.hidden = YES;
    [loginview sizeToFit];
    TCEND
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    TCSTART
    
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:[[url absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if ([urlString rangeOfString:@"videoid" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        [urlString replaceCharactersInRange:[urlString rangeOfString:@"videoid"] withString:@"videos"];
    }
    
    NSArray *tagetsUrl = [urlString componentsSeparatedByString:@"/videos/"];
    if (tagetsUrl.count >= 2) {
        shareNPlaybackDct = [[NSMutableDictionary alloc] init];
        [shareNPlaybackDct setObject:[tagetsUrl objectAtIndex:1] forKey:@"video_id"];
        [self checkToLaunchPlayerWhenComeFromBrowser];
        return YES;
    } else {
        BOOL openFBURL;
        BOOL openGPlusURL;
        openFBURL = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
        openGPlusURL = [GPPURLHandler handleURL:url
                              sourceApplication:sourceApplication
                                     annotation:annotation];
        if (openFBURL) {
            return openFBURL;
        } else if (openGPlusURL) {
            return openGPlusURL;
        } else {
            return YES;
        }
    }
    
    TCEND
}

- (void)checkToLaunchPlayerWhenComeFromBrowser {
    TCSTART
    if ([self isNotNull:loggedInUser] && [self isNotNull:mainVC] && [self isNotNull:[shareNPlaybackDct objectForKey:@"video_id"]]) {
        [mainVC checkVideoShouldPlayWhenCameFromBrowser:[shareNPlaybackDct objectForKey:@"video_id"]];
        shareNPlaybackDct = Nil;
    }
    TCEND
}

- (BOOL)statusForNetworkConnectionWithOutMessage {
	
	if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
	{
		return NO;
	}
    
	return YES;
}


#pragma mark Twitter & it's delegate methods.
- (void)initializeTwitterEngineWithDelegate:(id)delegate {
    
    @try {
        // Twitter Initialization / Login Code Goes Here
        if(!_twitterEngine) {
            _twitterEngine = [FHSTwitterEngine sharedEngine];
            NSLog(@"Twitter engine:%@",_twitterEngine);
            [_twitterEngine permanentlySetConsumerKey:kOAuthTwitterConsumerKey andSecret:kOAuthTwitterConsumerSecret];
            _twitterEngine.delegate = delegate;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}


- (void)authenticateTwitterAccountWithDelegate:(id)viewController andPresentFromVC:(CustomMoviePlayerViewController *)VC {
    
    @try {
        if([self isNotNull:_twitterEngine]) {
            [_twitterEngine loadAccessToken];
            _twitterEngine.delegate = viewController;
            
            if ([viewController isKindOfClass:[TagToolViewController class]]) {
                [[FHSTwitterEngine sharedEngine]showOAuthLoginControllerFromViewController:VC withCompletion:^(BOOL success) {
                    [self hideNetworkIndicator];
                    if (!success) {
                        [ShowAlert showError:@"Authentication failed, please try again"];
                    }
                }];
            }
            else if ([viewController isKindOfClass:[CustomMoviePlayerViewController class]]) {
                [[FHSTwitterEngine sharedEngine]showOAuthLoginControllerFromViewController:VC withCompletion:^(BOOL success) {
                    if (!success) {
                        [ShowAlert showError:@"Authentication failed, please try again"];
                    }
                }];
            }
            [self hideNetworkIndicator];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

#pragma mark SA_OAuthTwitterEngineDelegate
- (void)storeAccessToken:(NSString *)accessToken {
    
    @try {
        NSUserDefaults	*defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:accessToken forKey: @"SavedAccessHTTPBody"];
        [defaults synchronize];
        if ([self isNull:loggedInUser.socialContactsDictionary]) {
            loggedInUser.socialContactsDictionary = [[NSMutableDictionary alloc] init];
        }
        [loggedInUser.socialContactsDictionary setObject:self.twitterEngine.loggedInUsername?:@"" forKey:@"TW"];
        
        if ([self isNotNull:loginViewController]) {
            [self getTwitterLoggedInUserProfile];
        }
        
        if ([self isNotNull:caller_] && [caller_ isKindOfClass:[AccountSettingsviewController class]]) {
            [caller_ getTwitterLoggedInUserEmailAddress];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (NSString *)loadAccessToken {
    @try {
        return [[NSUserDefaults standardUserDefaults] objectForKey: @"SavedAccessHTTPBody"];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

#pragma mark Tag color
- (NSString *)stringFromColorLabelTag:(int )tag {
    TCSTART
    if (tag == 1) {
        return @"FF0000";
    } else if (tag == 2) {
        return @"00BFFF";
    } else if (tag == 3) {
        return @"00D300";
    } else if (tag == 4) {
        return @"FFA900";
    } else if (tag == 5) {
        return @"FFFFFF";
    } else if (tag == 6) {
        return @"000000";
    } else {
        return @"6362BC";
    }
    TCEND
}

- (NSString *)colorNameWithHexString:(NSString *)hexString {
    TCSTART
    if ([hexString isEqualToString:@"FF0000"]) {
        return @"red";
    } else if ([hexString isEqualToString:@"00BFFF"]) {
        return @"skyblue";
    } else if ([hexString isEqualToString:@"00D300"]) {
        return @"green";
    } else if ([hexString isEqualToString:@"FFA900"]) {
        return @"yellow";
    } else if ([hexString isEqualToString:@"FFFFFF"]) {
        return @"white";
    } else if ([hexString isEqualToString:@"000000"]) {
        return @"black";
    } else {
        return @"levender";
    }
    TCEND
}

- (NSString *)HexStringFromColorName:(NSString *)colorName {
    TCSTART
    if ([colorName caseInsensitiveCompare:@"red"] == NSOrderedSame) {
        return @"FF0000";
    } else if ([colorName caseInsensitiveCompare:@"skyblue"] == NSOrderedSame) {
        return @"00BFFF";
    } else if ([colorName caseInsensitiveCompare:@"green"] == NSOrderedSame) {
        return @"00D300";
    } else if ([colorName caseInsensitiveCompare:@"yellow"] == NSOrderedSame) {
        return @"FFA900";
    } else if ([colorName caseInsensitiveCompare:@"white"] == NSOrderedSame) {
        return @"FFFFFF";
    } else if ([colorName caseInsensitiveCompare:@"black"] == NSOrderedSame) {
        return @"000000";
    } else {
        return @"6362BC";
    }
    TCEND
}
- (int)getColorLblTag:(NSString *)colorName {
    TCSTART
    if ([colorName caseInsensitiveCompare:@"red"] == NSOrderedSame) {
        return 1;
    } else if ([colorName caseInsensitiveCompare:@"skyblue"] == NSOrderedSame) {
        return 2;
    } else if ([colorName caseInsensitiveCompare:@"green"] == NSOrderedSame) {
        return 3;
    } else if ([colorName caseInsensitiveCompare:@"yellow"] == NSOrderedSame) {
        return 4;
    } else if ([colorName caseInsensitiveCompare:@"white"] == NSOrderedSame) {
        return 5;
    } else if ([colorName caseInsensitiveCompare:@"black"] == NSOrderedSame) {
        return 6;
    } else {
        return 7;
    }
    TCEND
}

#pragma mark Color converter
-(UIColor*)colorWithHexString:(NSString*)hex {
    @try {
        NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
        
        // String should be 6 or 8 characters
        if ([cString length] < 6) return [UIColor grayColor];
        
        // strip 0X if it appears
        if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
        
        if ([cString length] != 6) return  [UIColor grayColor];
        
        // Separate into r, g, b substrings
        NSRange range;
        range.location = 0;
        range.length = 2;
        NSString *rString = [cString substringWithRange:range];
        
        range.location = 2;
        NSString *gString = [cString substringWithRange:range];
        
        range.location = 4;
        NSString *bString = [cString substringWithRange:range];
        
        // Scan values
        unsigned int r, g, b;
        [[NSScanner scannerWithString:rString] scanHexInt:&r];
        [[NSScanner scannerWithString:gString] scanHexInt:&g];
        [[NSScanner scannerWithString:bString] scanHexInt:&b];
        
        return [UIColor colorWithRed:((float) r / 255.0f)
                               green:((float) g / 255.0f)
                                blue:((float) b / 255.0f)
                               alpha:1.0f];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)moveLoggedInUserToTopInLikesListOfVideoModal:(VideoModal *)videoModal {
    TCSTART
    if ([self isNotNull:videoModal.likesList] && videoModal.likesList.count > 0) {
        NSMutableArray *videoLikesArray = [videoModal.likesList mutableCopy];
        for (int i = 0; i < videoModal.likesList.count; i++) {
            NSDictionary *dict = [videoModal.likesList objectAtIndex:i];
            //            videoModal.hasLovedVideo = NO;
            if ([[dict objectForKey:@"user_id"] intValue] == loggedInUser.userId.intValue) {
                [videoLikesArray moveObjectAtIndex:i toIndex:0];
                videoModal.likesList = videoLikesArray;
                //                videoModal.hasLovedVideo = YES;
                break;
            }
        }
    }
    TCEND
}

- (void)setRoundedCornersToButton:(UIButton *)btn {
    TCSTART
    btn.layer.cornerRadius = 5.0f;
    btn.layer.masksToBounds = YES;
    TCEND
}
- (NSMutableDictionary *)getTextLayerTextAnimationStopProperties {
    return [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"onOrderIn",[NSNull null], @"onOrderOut",[NSNull null], @"sublayers",[NSNull null], @"contents",
            [NSNull null], @"bounds",[NSNull null],@"position",[NSNull null],@"hidden", nil];
}

- (NSString *)removingLastSpecialCharecter:(NSString *)str {
    @try {
        int length = [str length] - 1;
        //        NSMutableCharacterSet *symbols = [NSMutableCharacterSet characterSetWithCharactersInString:@",.:;"];
        if(/*[symbols characterIsMember:[str characterAtIndex:length]] ||*/ [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[str characterAtIndex:length]] || [[NSCharacterSet newlineCharacterSet] characterIsMember:[str characterAtIndex:length]]) {
            str = [str substringToIndex:length];
            str =  [self removingLastSpecialCharecter:str];
        } else {
            //            NSLog(@"At %@",str);
            return str;
        }
        return str;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

#pragma mark openPhoneApp
-(void)openPhoneApp:(NSString *)phoneNumber {
    TCSTART
    if ([self isNotNull:phoneNumber]) {
        
        NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
        NSString *escapedPhoneNumber = [cleanedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *phoneUrlString = [NSString stringWithFormat:@"tel://%@", escapedPhoneNumber];
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:phoneUrlString]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneUrlString]];
        } else {
            NSLog(@"device doesn't support phone");
            [ShowAlert showAlert:@"Device doesn't support phone"];
        }
    }
    TCEND
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"WooTagModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self getApplicationDocumentsDirectoryAsURL] URLByAppendingPathComponent:@"WooTagModel"];
    
    NSError *error = nil;
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    // Determine if a migration is needed
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeURL error:&error];
    NSManagedObjectModel *destinationModel = [_persistentStoreCoordinator managedObjectModel];
    
    //check for Persistent store coordinator is compatible with existing PSC, if not compatible then migration was happened and make a sync request with null.
    pscCompatibile = [destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata];
    
    //    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options: options error:&error]) {
    //		//NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    //        abort();
    //    }
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options: options error:&error]) {
        
        // Delete file
        if ([[NSFileManager defaultManager] fileExistsAtPath:storeURL.path]) {
            if (![[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        
		if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
        {
            // Handle the error.
            NSLog(@"Error: %@",error);
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
            
        }
    }
    return _persistentStoreCoordinator;
}

- (NSString *)getApplicationDocumentsDirectoryAsString {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
    
}

// Returns the URL to the application's Documents directory.
- (NSURL *)getApplicationDocumentsDirectoryAsURL {
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
}


- (void)deleteDatabaseAtFilePath:(NSString *)databaseFilePath {
    
    @try {
        // if we make changes to your model and a database already exist in the app
        // we'll get a NSInternalInconsistencyException exception. When the model i updated
        // the databasefile must be removed before opening the app or closing the app.
        NSError *error = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:databaseFilePath]) {
            [fileManager removeItemAtPath:databaseFilePath error:&error];
            if (error) {
                NSLog(@"error: %@, while deleting database at path %@",error,databaseFilePath);
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}


- (NSString *)deviceType {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return @"iPad";
    } else {
        return @"iPhone";
    }
}

#pragma mark LoginUser
- (void)loginUser:(NSString *)userName password:(NSString *)password {
    @try {
        
        ProfileService *userProfileContr = [[ProfileService alloc]initWithCaller:self];
        userProfileContr.requestURL      = APP_URL;
        userProfileContr.email           = userName;
        userProfileContr.password        = password;
        userProfileContr.deviceToken     = deviceToken?:@"";
        userProfileContr.device          = [self deviceType];
        userProfileContr.loginType       = @"normal";
        [self showNetworkIndicator];
        [self showActivityIndicatorInView:self.window andText:@"Logging in.."];
        
        [userProfileContr login];
        userProfileContr = nil;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

#pragma mark LoginUser
- (void)loginUserThroughSocialNetworkingSitesWithUserName:(NSDictionary *)userinfo {
    TCSTART
    ProfileService *userProfileContr = [[ProfileService alloc]initWithCaller:self];
    userProfileContr.requestURL      = APP_URL;
    userProfileContr.loginType = @"Social";
    if ([self isNotNull:[userinfo objectForKey:@"email"]]) {
        userProfileContr.email = [userinfo objectForKey:@"email"];
    }
    [self showNetworkIndicator];
    [self showActivityIndicatorInView:self.window andText:@"Logging in.."];
    
    [userProfileContr loginThroughSocialSitesWithUserInfo:userinfo];
    userProfileContr = nil;
    TCEND
}

- (void)didFinishGetLoggedInUserProfileResponse:(NSDictionary *)results {
    TCSTART
    NSLog(@"Login response:%@",results);
    if ([self isNotNull:results]) {
        int responseCode = [[results objectForKey:@"error_code"] intValue];
        if (responseCode == 0 && [results objectForKey:@"user_id"]) {
            [[NSUserDefaults standardUserDefaults] setValue:[results objectForKey:@"user_id"] forKey:@"userId"];
            loggedInUser = [self getLoggedInUser];
            if ([self isNull:loggedInUser]) {
                loggedInUser = [self returnUserModalObjectByParsing:results isLogdedInUser:NO];
            } else {
                if ([self isNotNull:[results objectForKey:@"user_photo"]]) {
                    loggedInUser.photoPath = [results objectForKey:@"user_photo"];
                }
            }
            if ([self isNotNull:[results objectForKey:@"email"]]) {
                loggedInUser.emailAddress = [results objectForKey:@"email"];
            }
            if ([self isNotNull:socialContactsDictionary] && socialContactsDictionary.count > 0) {
                loggedInUser.socialContactsDictionary = [socialContactsDictionary mutableCopy];
            }
            [self saveLoggedUserData:loggedInUser];
            [self makeMypageRequestWithUserId:loggedInUser.userId andCaller:self];
        } else {
            [ShowAlert showAlert:[results objectForKey:@"msg"]];
            [self hideNetworkIndicator];
            [self removeActivityIndicator];
        }
    }
    TCEND
}

- (void)didFailToGetLoggedInUserProfileResponseWithError:(NSDictionary *)errorDict {
    TCSTART
    [self hideNetworkIndicator];
    [self removeActivityIndicator];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

- (void)saveLoggedUserData:(UserModal *)userModal {
    @try {
        NSLog(@"save userdata:%d",userModal.userId.intValue);
        NSUserDefaults *pref = [self getUserDefaultPreferences];
        if ([self isNotNull:userModal]) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userModal];
            [pref setValue:data forKey:userModal.userId];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (UserModal *)getLoggedInUser {
    @try {
        NSUserDefaults *pref = [self getUserDefaultPreferences];
        if ([self isNotNull:loggedInUser]) {
            return loggedInUser;
        } else {
            NSString *userIdStr = [pref objectForKey:@"userId"];
            if ([self isNotNull:userIdStr]) {
                NSData *userData = [pref objectForKey:userIdStr];
                if ([self isNotNull:userData]) {
                    loggedInUser = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
                    return loggedInUser;
                }
            }
            return nil;
        }
        return nil;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (NSUserDefaults *)getUserDefaultPreferences {
    return [NSUserDefaults standardUserDefaults];
}

#pragma mark Change password
-(void)changePassword:(NSString *)currentPassword changedPassword:(NSString *)changedPWD andCaller:(id)caller {
    
    @try {
        
        ProfileService *userProfileContr = [[ProfileService alloc]initWithCaller:caller];
        userProfileContr.requestURL      = APP_URL;
        userProfileContr.password        = currentPassword;
        
        [userProfileContr changePasswordWithChangedPassword:changedPWD andUserId:loggedInUser.userId];
        userProfileContr = nil;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

#pragma mark get Account details
- (void)getAccountDetialsOfLoggedInUserWithCaller:(id)caller {
    TCSTART
    //        [self createMainViewControllerAndAddToWindow];
    ProfileService *userProfileContr = [[ProfileService alloc]initWithCaller:caller];
    userProfileContr.requestURL      = APP_URL;
    [userProfileContr getAccountDetailsOfLoggedInUser:loggedInUser.userId];
    userProfileContr = nil;
    TCEND
}

#pragma mark update userprofile
- (void)updateProfileOfLoggedInUserWithCaller:(id)caller withUserInfo:(NSDictionary *)dict {
    TCSTART
    //        [self createMainViewControllerAndAddToWindow];
    ProfileService *userProfileContr = [[ProfileService alloc]initWithCaller:caller];
    userProfileContr.requestURL      = APP_URL;
    [userProfileContr updateUserProfileOfLoggedInUserWithInfo:dict];
    userProfileContr = nil;
    TCEND
}

#pragma mark Getting list products of loggedin user
- (void)getListOfProductsWithCaller:(id)caller {
    TCSTART
    ProfileService *userProfileContr = [[ProfileService alloc] initWithCaller:caller];
    userProfileContr.requestURL      = APP_URL;
    [userProfileContr getProductsListOfUserWithUserId:loggedInUser.userId];
    userProfileContr = nil;
    TCEND
}

#pragma mark Get list of purchase request of particular product by mentioning productid of loggedin user
- (void)getPurchaseRequestsOfProductWithProductId:(NSString *)productId andCaller:(id)caller {
    TCSTART
    ProfileService *userProfileContr = [[ProfileService alloc] initWithCaller:caller];
    userProfileContr.requestURL      = APP_URL;
    [userProfileContr getPurchaseRequestsOfProductId:productId ofUserId:loggedInUser.userId];
    userProfileContr = nil;
    TCEND
}

#pragma mark Logout
- (void)deleteUserManagedObject:(User *)user {
    TCSTART
    for (Video *userVideo in user.videos) {
        for (Tag *videoTag in userVideo.tags) {
            [[DataManager sharedDataManager] deleteTag:videoTag];
        }
        [[DataManager sharedDataManager] deleteVideo:userVideo];
    }
    [[DataManager sharedDataManager] deleteUser:user];
    TCEND
}

- (void)logoutRequestFromApp {
    TCSTART
    //    [[DataManager sharedDataManager] deleteUser:loggedInUser];
    [self hideNetworkIndicator];
    socialContactsDictionary = Nil;
    [loggedInUser.socialContactsDictionary removeAllObjects];
    [self saveLoggedUserData:loggedInUser];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userId"];
    
    loggedInUser = nil;
    [self cancelExport];
    [[UploadManager sharedUploadManager] stopAllUploads];
    NSString *databaseFilePath = [[self getApplicationDocumentsDirectoryAsString] stringByAppendingPathComponent: @"WooTagModel.sqlite"];
    
    [self deleteDatabaseAtFilePath:databaseFilePath];
    
    //Facebook Logout
    [self facebookLogout];
    
    //Twitter Logout
    self.twitterEngine.delegate = self;
    [self.twitterEngine clearAccessToken];
    self.twitterEngine.delegate = nil;
    self.twitterEngine = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SavedAccessHTTPBody"];
    
    //Google+ logout
    [[GPPSignIn sharedInstance] signOut];
    [[GPPSignIn sharedInstance] disconnect];
    
    [mainVC removeAllTabsFromVC];
    
    if ([self isNotNull:revealController]) {
        [revealController removeFromParentViewController];
        
        [revealController.view removeFromSuperview];
        revealController = nil;
    }
    
    videoFeedVC = nil;
    if ([self isNotNull:mainVC]) {
        [mainVC removeFromParentViewController];
        mainVC = nil;
    }
    [self createAndSetLogingViewControllerToWindow];
    TCEND
}

#pragma mark Login Via Social Networks
#pragma mark
#pragma mark Facebook
- (void)loginThroughFacebookFromCaller:(id)callerVC {
    if (!FBSession.activeSession.isOpen) {
        [FBSession openActiveSessionWithReadPermissions:facebookReadPermissions allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
            if (error) {
                [ShowAlert showError:@"Authentication failed, please try again"];
            } else if (session.isOpen) {
                if ([self isNotNull:callerVC] && ([callerVC isKindOfClass:[ShareViewController class]] || [callerVC isKindOfClass:[AccountSettingsviewController class]])) {
                    [FBRequestConnection startForMeWithCompletionHandler:
                     ^(FBRequestConnection *connection, id result, NSError *error) {
                         if ([self isNotNull:loggedInUser]) {
                             if ([self isNull:loggedInUser.socialContactsDictionary]) {
                                 loggedInUser.socialContactsDictionary = [[NSMutableDictionary alloc] init];
                             }
                             [loggedInUser.socialContactsDictionary setObject:[result objectForKey:@"name"]?:@"" forKey:@"FB"];
                         }
                         [callerVC FBLoginSuccessful];
                     }];
                } else {
                    [self getFBUserInfoWithUserId:@"me"];
                }
            }
        }];
        return;
    } else {
        if ([self isNotNull:callerVC] && ([callerVC isKindOfClass:[ShareViewController class]] || [callerVC isKindOfClass:[AccountSettingsviewController class]])) {
            [callerVC FBLoginSuccessful];
        } else {
            [self getFBUserInfoWithUserId:@"me"];
        }
    }
}

#pragma mark facebook logout
- (void)facebookLogout {
    @try {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"FBAccessTokenKey"]) {
            [defaults removeObjectForKey:@"FBAccessTokenKey"];
            [defaults removeObjectForKey:@"FBExpirationDateKey"];
            [defaults synchronize];
        }
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
        
    }
}

- (void) fbDidLogout {
    @try {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"FBAccessTokenKey"]) {
            [defaults removeObjectForKey:@"FBAccessTokenKey"];
            [defaults removeObjectForKey:@"FBExpirationDateKey"];
            [defaults synchronize];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)getFBUserInfoWithUserId:(NSString *)userId {
    TCSTART
    [self showActivityIndicatorWithText:@"Loading"];
    [self showNetworkIndicator];
    
    NSMutableDictionary *userInfoDict = [[NSMutableDictionary alloc] init];
    [userInfoDict setObject:@"facebook" forKey:@"login_type"];
    [userInfoDict setObject:@"iPhone" forKey:@"device"];
    [userInfoDict setObject:deviceToken?:@"" forKey:@"device_token"];
    
    [FBRequestConnection startWithGraphPath:@"me" parameters:[NSDictionary dictionaryWithObject:@"picture,username,email,name,cover" forKey:@"fields"] HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            [self hideNetworkIndicator];
            [self removeActivityIndicator];
            [ShowAlert showError:[error localizedDescription]];
        } else {
            NSLog(@"result:%@",result);
            [userInfoDict setObject:[result objectForKey:@"email"]?:@"" forKey:@"email"];
            [userInfoDict setObject:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=640&height=640",[result objectForKey:@"id"]]?:@"" forKey:@"profile_picture"];
            if ([self isNull:[result objectForKey:@"name"]]) {
                [userInfoDict setObject:[result objectForKey:@"email"]?:@"" forKey:@"username"];
            } else {
                [userInfoDict setObject:[result objectForKey:@"name"]?:@"" forKey:@"username"];
            }
            
            if ([self isNotNull:loggedInUser]) {
                if ([self isNull:loggedInUser.socialContactsDictionary]) {
                    loggedInUser.socialContactsDictionary = [[NSMutableDictionary alloc] init];
                }
                [loggedInUser.socialContactsDictionary setObject:[result objectForKey:@"name"]?:@"" forKey:@"FB"];
            } else {
                [socialContactsDictionary setObject:[result objectForKey:@"name"]?:@"" forKey:@"FB"];
            }
            [userInfoDict setObject:[result objectForKey:@"id"] forKey:@"social_id"];
            [FBRequestConnection startWithGraphPath:@"me/friends" completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
                [self hideNetworkIndicator];
                [self removeActivityIndicator];
                if (error) {
                    GTMLoggerError(@"error:%@",error);
                } else {
                    NSMutableArray *friends = [[NSMutableArray alloc]init];
                    for(NSDictionary *userDict in [result objectForKey:@"data"]) {
                        //                        NSDictionary *friend = [[NSDictionary alloc]initWithObjectsAndKeys:[userDict objectForKey:@"name"]?:@"",@"name",[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",[userDict objectForKey:@"id"]]?:@"",@"photo_path",[userDict objectForKey:@"id"]?:@"",@"id", nil];
                        //                        NSDictionary *friend = [[NSDictionary alloc]initWithObjectsAndKeys:[userDict objectForKey:@"id"]?:@"",@"id", nil];
                        
                        [friends addObject:[userDict objectForKey:@"id"]?:@""];
                    }
                    [userInfoDict setObject:friends forKey:@"friends"];
                    [self loginUserThroughSocialNetworkingSitesWithUserName:userInfoDict];
                }
            }];
        }
    }];
    TCEND
}

#pragma mark FaceBook Share
- (void)sendInvitationtoFaceBookFriendWithParams:(NSMutableDictionary *)params {
    TCSTART
    [self performPublishAction:^{
        
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:
         ^(FBWebDialogResult result, NSURL *resultURL, NSError *error)
         {
             if (error) {
                 //                 [ShowAlert showAlert:@"Something went wrong, please send again"];
             } else {
                 if (result == FBWebDialogResultDialogCompleted) {
                     // Handle the send request callback
                     NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                     if (![urlParams valueForKey:@"post_id"]) {
                         NSLog(@"User canceled request.");
                     } else {
                         //                         [ShowAlert showAlert:@"Successfully shared"];
                     }
                 }
             }
         }
         ];
    }];
    
    TCEND
}

//- (void)shareVideoToFaceBookFriendWithVideoInfo:(VideoModal *)video andFriendFBId:(NSString *)fbId {
//    TCSTART
//    [self performPublishAction:^{
//        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:[[NSString stringWithFormat:@"%@",video.latestTagExpression?:video.title] UTF8String]],@"name",video.fbShareUrl?:video.shareUrl,@"link",video.videoThumbPath,@"picture",nil];
//
////        {
//            [FBRequestConnection startWithGraphPath:@"me" parameters:[NSDictionary dictionaryWithObject:@"name" forKey:@"fields"] HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                if (error) {
//                    GTMLoggerError(@"error:%@",error);
//                } else {
//                    if ([[result objectForKey:@"id"] isEqualToString:fbId]) {
//                        [FBRequestConnection startWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
//                            if (error) {
//                                NSLog(@"Error:%@",error.localizedDescription);
//                            }
//                        }];
//                    } else  {
//                        [params setObject:fbId forKey:@"to"];
//                        if ([self isNotNull:video.fbShareUrl]) {
//                            [params setObject:video.fbShareUrl forKey:@"source"];
//                            [params setObject:@"video" forKey:@"type"];
//                        }
//                        [FBWebDialogs presentFeedDialogModallyWithSession:nil
//                                                               parameters:params
//                                                                  handler:
//                         ^(FBWebDialogResult result, NSURL *resultURL, NSError *error)
//                         {
//                             if (error) {
//                                 [ShowAlert showAlert:@"Something went wrong, please share again"];
//                             } else {
//                                 if (result == FBWebDialogResultDialogCompleted) {
//                                     // Handle the send request callback
//                                     NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
//                                     if (![urlParams valueForKey:@"post_id"]) {
//                                         NSLog(@"User canceled request.");
//                                     } else {
//
//                                     }
//                                 }
//                             }
//                         }
//                         ];
//                    }
//                }
//            }];
////        }
//    }];
//
//    TCEND
//}

- (void) performPublishAction:(void (^)(void)) action {
    TCSTART
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        
        [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                if (!error) {
                                                    action();
                                                } else if (error.fberrorCategory != FBErrorCategoryUserCancelled){
                                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission denied" message:@"Unable to get permission to post" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                    [alertView show];
                                                }
                                            }];
    } else {
        action();
    }
    TCEND
}

- (void) performManageAction:(void (^)(void)) action {
    TCSTART
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"manage_pages"] == NSNotFound) {
        
        [FBSession.activeSession requestNewPublishPermissions:@[@"manage_pages"]
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                if (!error) {
                                                    action();
                                                } else {
                                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission denied" message:@"Unable to get permission to manage pages" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                    [alertView show];
                                                }
                                            }];
    } else {
        action();
    }
    TCEND
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    TCSTART
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [[kv objectAtIndex:1]
         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
    TCEND
}

- (void)postToFacebookUserWallWithOutDialog:(VideoModal *)videoModal andToId:(NSString *)userId {
    TCSTART
    
    if (!FBSession.activeSession.isOpen) {
        [FBSession openActiveSessionWithReadPermissions:facebookReadPermissions
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState state,
                                                          NSError *error) {
                                          if (error) {
                                              [ShowAlert showError:@"Authentication failed, please try again"];
                                          } else if (session.isOpen) {
                                              [self performPublishAction:^{[self postToFacebookUserWallWithOutDialog:videoModal andToId:userId];}];
                                              
                                          }
                                      }];
        return;
    } else {
        //        [self performPublishAction:^{
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:[[NSString stringWithFormat:@"%@",videoModal.latestTagExpression?:videoModal.title] UTF8String]],@"name",videoModal.videoThumbPath,@"picture",videoModal.fbShareUrl?:videoModal.shareUrl,@"link",nil];
        if ([userId caseInsensitiveCompare:@"me"] == NSOrderedSame) {
            [FBRequestConnection startWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (error) {
                    NSLog(@"Error:%@",error.localizedDescription);
                } else {
                    [self makeRequestForAnalyticsOfVideo:videoModal.videoId analyticsTagClicksOrShareId:VideoViewsOrFBShare analyticsTagInteractions:FB socialPlatform:FB isForShare:YES isReqForInteractions:NO shareCount:1];
                }
            }];
        } else {
            [FBRequestConnection startWithGraphPath:@"me" parameters:[NSDictionary dictionaryWithObject:@"name" forKey:@"fields"] HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (error) {
                    GTMLoggerError(@"error:%@",error);
                } else {
                    if ([[result objectForKey:@"id"] isEqualToString:userId]) {
                        [FBRequestConnection startWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                            if (error) {
                                NSLog(@"Error:%@",error.localizedDescription);
                            } else {
                                [self makeRequestForAnalyticsOfVideo:videoModal.videoId analyticsTagClicksOrShareId:VideoViewsOrFBShare analyticsTagInteractions:FB socialPlatform:FB isForShare:YES isReqForInteractions:NO shareCount:1];
                            }
                        }];
                    } else {
                        if ([FBSession.activeSession.permissions indexOfObject:@"manage_pages"] == NSNotFound) {
                            
                            [FBSession.activeSession requestNewPublishPermissions:@[@"manage_pages"]
                                                                  defaultAudience:FBSessionDefaultAudienceFriends
                                                                completionHandler:^(FBSession *session, NSError *error) {
                                                                    if (!error) {
                                                                        [self checkForIsShareReqMadeForPagesWithParams:params userId:userId andVideoShareLink:videoModal];
                                                                    } else {
                                                                        [ShowAlert showAlert:@"Unable to get permission to manage pages"];
                                                                        [params setObject:userId forKey:@"to"];
                                                                        [params setObject:videoModal.shareUrl?:@"" forKey:@"link"];
                                                                        [self shareToFriendsFacebookWall:params andVideoId:videoModal.videoId];
                                                                    }
                                                                }];
                        } else {
                            [self checkForIsShareReqMadeForPagesWithParams:params userId:userId andVideoShareLink:videoModal];
                        }
                    }
                }
            }];
        }
        //        }];
    }
    
    TCEND
}

- (void)checkForIsShareReqMadeForPagesWithParams:(NSMutableDictionary *)params userId:(NSString *)userId andVideoShareLink:(VideoModal *)videoModel {
    TCSTART
    [FBRequestConnection startWithGraphPath:@"me/accounts" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            GTMLoggerError(@"error:%@",error);
            [params setObject:userId forKey:@"to"];
            [params setObject:videoModel.shareUrl?:@"" forKey:@"link"];
            [self shareToFriendsFacebookWall:params andVideoId:videoModel.videoId];
        } else {
            NSLog(@"pages Result:%@",result);
            for(NSDictionary *userDict in [result objectForKey:@"data"]) {
                if ([[userDict objectForKey:@"id"] isEqualToString:userId]) {
                    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/feed",userId] parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        if (error) {
                            NSLog(@"Error:%@",error.localizedDescription);
                        } else {
                            NSLog(@"result :%@",result);
                            [self makeRequestForAnalyticsOfVideo:videoModel.videoId?:@"" analyticsTagClicksOrShareId:VideoViewsOrFBShare analyticsTagInteractions:FB socialPlatform:FB isForShare:YES isReqForInteractions:NO shareCount:1];
                        }
                    }];
                    return;
                    break;
                }
            }
            [params setObject:userId forKey:@"to"];
            [params setObject:videoModel.shareUrl?:@"" forKey:@"link"];
            [self shareToFriendsFacebookWall:params andVideoId:videoModel.videoId];
        }
    }];
    
    TCEND
}
- (void)shareToFriendsFacebookWall:(NSMutableDictionary *)params andVideoId:(NSString *)videoId {
    TCSTART
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:params
                                              handler:
     ^(FBWebDialogResult result, NSURL *resultURL, NSError *error)
     {
         if (error) {
             
         } else {
             if (result == FBWebDialogResultDialogCompleted) {
                 // Handle the send request callback
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"post_id"]) {
                     NSLog(@"User canceled request.");
                 } else {
                     [self makeRequestForAnalyticsOfVideo:videoId analyticsTagClicksOrShareId:VideoViewsOrFBShare analyticsTagInteractions:FB socialPlatform:FB isForShare:YES isReqForInteractions:NO shareCount:1];
                 }
             }
         }
     }];
    TCEND
}
#pragma mark
#pragma mark Phone contacts list and message sending
- (BOOL)getAccessPermission {
    TCSTART
    __block BOOL accessGranted = NO;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }
    else
    { // we're on iOS 5 or older
        accessGranted = YES;
    }
    return accessGranted;
    TCEND
}

- (NSMutableArray *)getAddressBookContacts {
    TCSTART
    NSMutableArray *friendsList = [[NSMutableArray alloc] init];
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex numberOfPeople = CFArrayGetCount(people);
    for (int i = 0 ; i < numberOfPeople; ++i) {
        ABRecordRef ref = CFArrayGetValueAtIndex(people, i);
        ABMultiValueRef phones = (__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
        int phoneNumbersCount = ABMultiValueGetCount(phones);
        if (phoneNumbersCount > 0) {
            // save this contact, it has phone number
            NSString *phoneNumber;
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            
            //phone number
            NSArray *phoneArray = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phones);
            for (int i=0; i < [phoneArray count]; i++) {
                if ([self isNotNull:[phoneArray objectAtIndex:i]]) {
                    phoneNumber = [phoneArray objectAtIndex:i];
                    [dictionary setObject:phoneNumber?:@"" forKey:@"phonenumber"];
                    break;
                }
            }
            
            //username
            NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonFirstNameProperty));
            NSString *middleName = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonMiddleNameProperty));
            NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonLastNameProperty));
            NSString *userNameStr;
            if (firstName.length > 0) {
                userNameStr = firstName;
            }
            if (middleName.length > 0) {
                userNameStr = [NSString stringWithFormat:@"%@ %@",userNameStr,middleName];
            }
            if (lastName.length > 0) {
                userNameStr = [NSString stringWithFormat:@"%@ %@",userNameStr,lastName];
            }
            
            if ([self isNotNull:userNameStr] && userNameStr.length > 0) {
                [dictionary setObject:userNameStr forKey:@"user_name"];
            } else {
                [dictionary setObject:phoneNumber?:@"" forKey:@"user_name"];
            }
            [dictionary setObject:[dictionary objectForKey:@"user_name"]?:@"" forKey:@"displayname"];
            
            //image data
            NSData  *imgData = [self getContactPicture:ref];
            if ([self isNotNull:imgData]) {
                [dictionary setObject:imgData forKey:@"image_data"];
            }
            
            [dictionary setObject:phoneNumber?:@"" forKey:@"description"];
            [friendsList addObject:dictionary];
            
        }
    }
    return friendsList;
    TCEND
}

- (NSData *) getContactPicture:(ABRecordRef)person {
    TCSTART
    if (&ABAddressBookCreateWithOptions != NULL) {
        // iOS6
        if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) {
            return nil;
        }
    }
    
    NSData *data;
    
    // Check for contact picture
    if (person != nil && ABPersonHasImageData(person)) {
        data = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
        
        if ([self isNotNull:data]) {
            return data;
        }
    }
    return nil;
    
    TCEND
}


#pragma mark
#pragma mark Login through Twitter
- (void)loginThroughTwitterFromViewController:(UIViewController *)VC {
    TCSTART
    self.twitterEngine.delegate = (id)self;
    if(!self.twitterEngine) {
        [self initializeTwitterEngineWithDelegate:self];
    }
    [self.twitterEngine loadAccessToken];
    if(![self.twitterEngine isAuthorized]) {
        [[FHSTwitterEngine sharedEngine] showOAuthLoginControllerFromViewController:VC withCompletion:^(BOOL success) {
            if (!success) {
                [ShowAlert showError:@"Authentication failed, please try again"];
            } else {
                [self getTwitterLoggedInUserProfile];
            }
        }];
    } else {
        [self getTwitterLoggedInUserProfile];
    }
    TCEND
}
- (void) getTwitterLoggedInUserProfile {
    TCSTART
    [self showActivityIndicatorWithText:@"Loading"];
    [self showNetworkIndicator];
    
    NSMutableDictionary *userInfoDict = [[NSMutableDictionary alloc] init];
    [userInfoDict setObject:@"twitter" forKey:@"login_type"];
    [userInfoDict setObject:@"iPhone" forKey:@"device"];
    [userInfoDict setObject:deviceToken?:@"" forKey:@"device_token"];
    
    NSDictionary *dict = [self.twitterEngine getUserProfileForUserId:self.twitterEngine.loggedInID];
    [userInfoDict setObject:[NSString stringWithFormat:@"%@@twitter.com",[dict objectForKey:@"screen_name"]]?:@"" forKey:@"email"];
    [userInfoDict setObject:[dict objectForKey:@"profile_image_url_https"]?:@"" forKey:@"profile_picture"];
    [userInfoDict setObject:[dict objectForKey:@"screen_name"]?:@"" forKey:@"username"];
    [userInfoDict setObject:[NSNumber numberWithLong:[[dict objectForKey:@"id"] longValue]] forKey:@"social_id"];
    if ([self isNotNull:loggedInUser]) {
        if ([self isNull:loggedInUser.socialContactsDictionary]) {
            loggedInUser.socialContactsDictionary = [[NSMutableDictionary alloc] init];
        }
        [loggedInUser.socialContactsDictionary setObject:[dict objectForKey:@"screen_name"]?:@"" forKey:@"TW"];
    } else {
        [socialContactsDictionary setObject:[dict objectForKey:@"screen_name"]?:@"" forKey:@"TW"];
    }
    
    id twitterData = [self.twitterEngine listFriendsForUser:self.twitterEngine.loggedInUsername isID:NO withCursor:nil];
    if (twitterData != nil && [twitterData isKindOfClass:[NSDictionary class]]) {
        if ([self isNotNull:[twitterData objectForKey:@"users"]]) {
            NSMutableArray *friends = [[NSMutableArray alloc]init];
            NSArray *users = [twitterData objectForKey:@"users"];
            NSLog(@"UsersCount :%d",users.count);
            for (NSDictionary *user in users) {
                //                NSDictionary *friend = [[NSDictionary alloc]initWithObjectsAndKeys:[user objectForKey:@"screen_name"]?:@"",@"name",[user objectForKey:@"profile_image_url_https"]?:@"",@"photo_path",[NSNumber numberWithLong:[[user objectForKey:@"id"] longValue]],@"id", nil];
                
                [friends addObject:[user objectForKey:@"id"]];
            }
            [userInfoDict setObject:friends forKey:@"friends"];
        }
    }
    NSLog(@"UserDict:%@",userInfoDict);
    [self loginUserThroughSocialNetworkingSitesWithUserName:userInfoDict];
    [self removeActivityIndicator];
    [self hideNetworkIndicator];
    TCEND
}

#pragma mark Twitter Video Sharing
- (void)PostToTwitterWithMsg:(NSString *)msg toUser:(NSString *)userid withImageUrl:(NSString *)imageURL andVideoId:(NSString *)videoId {
    TCSTART
    dispatch_async(GCDBackgroundThread, ^{
        @autoreleasepool {
            //            [self showActivityIndicatorWithText:@"Sharing"];
            [self showNetworkIndicator];
            NSError *returnCode;
            if ([self isNotNull:imageURL]) {
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
                returnCode = [self.twitterEngine postTweet:[NSString stringWithFormat:@"@%@ %@",userid,msg] withImageData:UIImageJPEGRepresentation((image), 0)];
            } else {
                returnCode = [self.twitterEngine postTweet:[NSString stringWithFormat:@"@%@ %@",userid,msg]];
            }
            
            //            returnCode = [self.twitterEngine postTweet:[NSString stringWithFormat:@"@%@ %@",userid,msg]];
            
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    [self hideNetworkIndicator];
                    [self removeActivityIndicator];
                    
                    if (!returnCode) {
                        if ([self isNotNull:videoId]) {
                            [self makeRequestForAnalyticsOfVideo:videoId analyticsTagClicksOrShareId:FacebookClicksorTwitterShare analyticsTagInteractions:FB socialPlatform:FB isForShare:YES isReqForInteractions:NO shareCount:1];
                        }
                    } else {
                        [ShowAlert showAlert:@"Something went wrong, please share again"];
                    }
                }
            });
        }
    });
    TCEND
}

#pragma mark post to twitter with ImageData
- (void)postToTwitterWithImaegData:(VideoModal *)videoModal andUserId:(NSString *)userId {
    TCSTART
    if(!self.twitterEngine) {
        [self initializeTwitterEngineWithDelegate:self];
        [self.twitterEngine loadAccessToken];
        if([self.twitterEngine isAuthorized]) {
            [self postToTwitterWithImaegData:videoModal andUserId:userId];
        }
    } else {
        dispatch_async(GCDBackgroundThread, ^{
            @autoreleasepool {
                if ([self isNotNull:userId]) {
                    NSDictionary *dict = [self.twitterEngine getUserProfileForUserId:userId];
                    
                    if ([self isNotNull:dict] && [self isNotNull:[dict objectForKey:@"screen_name"]]) {
                        NSString *string = [NSString stringWithFormat:@"%@\n%@\n%@",videoModal.latestTagExpression?:videoModal.title,videoModal.shareUrl,videoModal.info?:@""];
                        //                        NSError *returnCode = [self.twitterEngine postTweet:[NSString stringWithFormat:@"@%@ %@",[dict objectForKey:@"screen_name"],string]];
                        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:videoModal.videoThumbPath]]];
                        NSError *returnCode = [self.twitterEngine postTweet:[NSString stringWithFormat:@"@%@ %@",[dict objectForKey:@"screen_name"],string] withImageData:UIImageJPEGRepresentation(image,0)];
                        
                        dispatch_sync(GCDMainThread, ^{
                            @autoreleasepool {
                                if (!returnCode) {
                                    NSLog (@"Posted to twitter");
                                    [self makeRequestForAnalyticsOfVideo:videoModal.videoId analyticsTagClicksOrShareId:FacebookClicksorTwitterShare analyticsTagInteractions:FB socialPlatform:FB isForShare:YES isReqForInteractions:NO shareCount:1];
                                } else {
                                    NSLog(@"Failed to post to twitter");
                                }
                            }
                        });
                    }
                }
            }
        });
    }
    
    TCEND
}

#pragma mark
#pragma mark Login through Google+
- (void)loginThroughGooglePlus {
    TCSTART
    if ([[GPPSignIn sharedInstance] authentication]) {
        [self getGPlusUserInfoWithUserId:@"me"];
    } else {
        GPPSignIn *signIn = [GPPSignIn sharedInstance];
        signIn.clientID = kGooglePlusClientId;
        signIn.shouldFetchGoogleUserEmail = YES;
        signIn.shouldFetchGoogleUserID = YES;
        [signIn setScopes:[NSArray arrayWithObjects: @"https://www.googleapis.com/auth/plus.login", @"https://www.googleapis.com/auth/userinfo.email", @"https://www.googleapis.com/auth/plus.me", nil]];
        
        signIn.delegate = self;
        [signIn authenticate];
    }
    TCEND
}

#pragma mark GooglePlus Delegate method
- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    if (error) {
        [ShowAlert showError:@"Authentication failed, please try again"];
    } else {
        NSLog(@"GPlus SignIn Success");
        [self getGPlusUserInfoWithUserId:@"me"];
    }
}

- (void)getGPlusUserInfoWithUserId:(NSString *)userId {
    TCSTART
    [self showActivityIndicatorWithText:@"Loading"];
    [self showNetworkIndicator];
    GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGoogleUserEmail = YES;
    plusService.retryEnabled = YES;
    [plusService setAuthorizer:signIn.authentication];
    
    NSMutableDictionary *userInfoDict = [[NSMutableDictionary alloc] init];
    [userInfoDict setObject:@"google" forKey:@"login_type"];
    [userInfoDict setObject:signIn.authentication.userEmail?:@"" forKey:@"email"];
    [userInfoDict setObject:@"iPhone" forKey:@"device"];
    [userInfoDict setObject:deviceToken?:@"" forKey:@"device_token"];
    
    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:userId];
    [plusService executeQuery:query
            completionHandler:^(GTLServiceTicket *ticket,
                                GTLPlusPerson *person,
                                NSError *error) {
                if (error) {
                    [self hideNetworkIndicator];
                    [self removeActivityIndicator];
                    GTMLoggerError(@"Error: %@", error);
                } else {
                    NSLog(@"UserINFO :%@\n",person.JSON);
                    NSMutableString *string = [[NSMutableString alloc] initWithString:person.image.url];
                    if (string.length > 0) {
                        [string replaceOccurrencesOfString:@"sz=50" withString:@"sz=640" options:NSCaseInsensitiveSearch range:[string rangeOfString:@"sz=50"]];
                    }
                    
                    [userInfoDict setObject:string?:@"" forKey:@"profile_picture"];
                    if ([self isNull:person.displayName]) {
                        [userInfoDict setObject:signIn.authentication.userEmail?:@"" forKey:@"username"];
                    } else {
                        [userInfoDict setObject:person.displayName forKey:@"username"];
                    }
                    
                    if ([self isNotNull:loggedInUser]) {
                        if ([self isNull:loggedInUser.socialContactsDictionary]) {
                            loggedInUser.socialContactsDictionary = [[NSMutableDictionary alloc] init];
                        }
                        [loggedInUser.socialContactsDictionary setObject:person.displayName?:@"" forKey:@"GPLUS"];
                    } else {
                        [socialContactsDictionary setObject:person.displayName?:@"" forKey:@"GPLUS"];
                    }
                    
                    [userInfoDict setObject:person.identifier forKey:@"social_id"];
                    GTLQueryPlus *query1 = [GTLQueryPlus queryForPeopleListWithUserId:@"me" collection:kGTLPlusCollectionVisible];
                    
                    [plusService executeQuery:query1
                            completionHandler:^(GTLServiceTicket *ticket,
                                                GTLPlusPeopleFeed *peopleFeed,
                                                NSError *error) {
                                [self hideNetworkIndicator];
                                [self removeActivityIndicator];
                                if (error) {
                                    GTMLoggerError(@"Error: %@", error);
                                } else {
                                    NSArray* peopleList = peopleFeed.items;
                                    NSMutableArray *friends = [[NSMutableArray alloc]init];
                                    for(GTLPlusPerson *gPlusPersion in peopleList) {
                                        //                                        NSDictionary *friend = [[NSDictionary alloc]initWithObjectsAndKeys:gPlusPersion.displayName?:@"",@"name",gPlusPersion.image.url?:@"",@"photo_path",gPlusPersion.identifier?:@"",@"id", nil];
                                        
                                        [friends addObject:gPlusPersion.identifier?:@""];
                                    }
                                    [userInfoDict setObject:friends forKey:@"friends"];
                                    [self loginUserThroughSocialNetworkingSitesWithUserName:userInfoDict];
                                }
                            }];
                }
            }];
    
    TCEND
}

- (void)shareToGooglePlusUserWithUserId:(NSArray *)friendsIdsArray andVideo:(VideoModal *)selectedVideo {
    TCSTART
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    
    [shareBuilder setPrefillText:[NSString stringWithFormat:@"%@\n%@",[NSString stringWithUTF8String:[[NSString stringWithFormat:@"%@",selectedVideo.latestTagExpression?:selectedVideo.title] UTF8String]],selectedVideo.shareUrl]];
    [shareBuilder attachImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:selectedVideo.videoThumbPath]]];
    ////    [shareBuilder attachVideoURL:[NSURL URLWithString:selectedVideo.shareUrl]];
    //    if ([self isNotNull:selectedVideo.shareUrl]) {
    //        [shareBuilder setURLToShare:[NSURL URLWithString:selectedVideo.shareUrl]];
    //    }
    if (friendsIdsArray.count > 0) {
        [shareBuilder setPreselectedPeopleIDs:friendsIdsArray];
    }
    [shareBuilder open];
    [self makeRequestForAnalyticsOfVideo:selectedVideo.videoId analyticsTagClicksOrShareId:GoogleClicksorGoogleShare analyticsTagInteractions:FB socialPlatform:FB isForShare:YES isReqForInteractions:NO shareCount:friendsIdsArray.count];
    TCEND
}

#pragma mark Create mainview controller
- (void)createMainViewControllerAndAddToWindow {
    TCSTART
    if([self isNotNull:loginViewController]) {
        [loginViewController removeFromParentViewController];
        [loginViewController.view removeFromSuperview];
        loginViewController = nil;
    }
    mainVC = [[MainViewController alloc]initWithNibName:@"MainViewController" bundle:nil];
    MenuViewController *menuVC = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:Nil];
    
    UINavigationController *menuNavigationCnt = [[UINavigationController alloc] initWithRootViewController:menuVC];
    menuNavigationCnt.navigationBar.hidden = YES;
    
    UINavigationController *mainViewNavigationController = [[UINavigationController alloc]initWithRootViewController:mainVC];
    mainViewNavigationController.navigationBar.hidden = YES;
    
    revealController = [[SWRevealViewController alloc] initWithRearViewController:menuNavigationCnt frontViewController:mainViewNavigationController];
    revealController.delegate = self;
    
    if ([self.window respondsToSelector:@selector(setRootViewController:)]) { // >= ios4.0
        [self.window setRootViewController:revealController];
    } else { // < ios4.0
        [self.window addSubview:revealController.view];
    }
    mainViewNavigationController = nil;
    menuNavigationCnt = nil;
    
    TCEND
}

- (NSString *)getUserFullImageURLbyPhotoPath:(NSString *)profilePicUrl {
    TCSTART
    NSMutableString *url = [[NSMutableString alloc] initWithString:profilePicUrl];
    [url replaceOccurrencesOfString:@"h=120" withString:@"h=640" options:NSCaseInsensitiveSearch range:[url rangeOfString:@"h=120"]];
    [url replaceOccurrencesOfString:@"w=120" withString:@"w=640" options:NSCaseInsensitiveSearch range:[url rangeOfString:@"w=120"]];
    return url;
    TCEND
}

#pragma mark load website url in webview
- (void)openWebviewWithURL :(NSString *)websiteURL {
    TCSTART
    if ([self isNull:websiteView]) {
        websiteView = [[UIView alloc] init];
        websiteView.frame = CGRectMake(0, 20, self.window.frame.size.width, self.window.frame.size.height - 20);
        websiteView.backgroundColor = [UIColor whiteColor];
        websiteWebView = [[UIWebView alloc] initWithFrame:CGRectMake(5, 5, websiteView.frame.size.width - 10, websiteView.frame.size.height - 10)];
        [websiteView addSubview:websiteWebView];
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(websiteView.frame.size.width - 30, 0, 30, 30);
        [cancelBtn setBackgroundImage:[UIImage imageNamed:@"CloseBtn"] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(closeWebview:) forControlEvents:UIControlEventTouchUpInside];
        [websiteView addSubview:cancelBtn];
    }
    [websiteWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[websiteURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    websiteWebView.delegate = self;
    [self.window addSubview:websiteView];
    
    TCEND
}

- (void)closeWebview:(id)sender {
    TCSTART
    [websiteWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
    [websiteWebView stopLoading];
    [websiteWebView removeFromSuperview];
    websiteWebView.delegate = nil;
    isNetworkIndicator = NO;
    [websiteView removeFromSuperview];
    websiteView = nil;
    TCEND
}

#pragma mark WebView Delegate Methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView_ {
    @try {
        if (!isNetworkIndicator) {
            isNetworkIndicator = YES;
            [self showNetworkIndicator];
            [self showActivityIndicatorInView:webView_ andText:@"Loading"];
        }
    }
    @catch (NSException *exception) {
        //NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

-(void)webViewDidFinishLoad:(UIWebView *)webView_ {
    
    @try {
        isNetworkIndicator = NO;
        [self hideNetworkIndicator];
        [self removeNetworkIndicatorInView:webView_];
    }
    @catch (NSException *exception) {
        //NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

-(void)webView:(UIWebView *)webView_ didFailLoadWithError:(NSError *)error {
    
    @try {
        isNetworkIndicator = NO;
        [self hideNetworkIndicator];
        [self removeNetworkIndicatorInView:webView_];
        [ShowAlert showError:[error localizedDescription]];
    }
    @catch (NSException *exception) {
        //NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}


#pragma mark Round the corners of UIView
- (void) setMaskTo:(UIView*)view byRoundingCorners:(UIRectCorner)corners withRadii:(CGSize)Radii {
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:Radii];
    
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    view.layer.mask = shape;
}

- (void)addCircleToTheImageView:(UIImageView *)imageView {
    TCSTART
    imageView.backgroundColor = [UIColor clearColor];
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    // Give the layer the same bounds as your image view
    [circleLayer setBounds:CGRectMake(0.0f, 0.0f, [imageView bounds].size.width,
                                      [imageView bounds].size.height)];
    // Position the circle anywhere you like, but this will center it
    // In the parent layer, which will be your image view's root layer
    [circleLayer setPosition:CGPointMake([imageView bounds].size.width/2.0f,
                                         [imageView bounds].size.height/2.0f)];
    // Create a circle path.
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:
                          CGRectMake(0.0f, 0.0f, imageView.frame.size.width , imageView.frame.size.height)];
    // Set the path on the layer
    [circleLayer setPath:[path CGPath]];
    // Set the stroke color
    [circleLayer setStrokeColor:[self colorWithHexString:@"11a3e7"].CGColor];
    // Set the stroke line width
    [circleLayer setLineWidth:2.0f];
    
    // Add the sublayer to the image view's layer tree
    [[imageView layer] addSublayer:circleLayer];
    TCEND
}

#pragma mark SignUp
#pragma mark SignUP User
- (void)signUpUser:(NSString *)userFullName withEmail:(NSString *)email withPassword:(NSString *)password {
    
    @try {
        ProfileService *userProfileContr = [[ProfileService alloc]initWithCaller:self];
        userProfileContr.requestURL      = APP_URL;
        userProfileContr.user_name       = userFullName;
        userProfileContr.email           = email;
        userProfileContr.password        = password;
        userProfileContr.deviceToken     = deviceToken ?: @"";
        userProfileContr.device          = [self deviceType];
        
        [self showNetworkIndicator];
        [self showActivityIndicatorInView:self.window andText:@"Signing up.."];
        
        [userProfileContr signup];
        userProfileContr = nil;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

#pragma mark ForgotPassword Request & Response Methods
-(void)sendNewPasswordToEmail:(NSString *)emailAddress fromViewController:(ForgotPasswordViewController *)forgotPasswordVC {
    
    @try {
        ProfileService *userProfileContr = [[ProfileService alloc]initWithCaller:forgotPasswordVC];
        userProfileContr.requestURL     = APP_URL;
        userProfileContr.email          = emailAddress;
        //        userProfileContr.deviceToken    = deviceToken ?: @"";
        //        userProfileContr.device         = [self deviceType];
        
        [self showNetworkIndicator];
        [self showActivityIndicatorInView:self.window andText:@"Requesting.."];
        
        [userProfileContr emailNewPassword];
        userProfileContr = nil;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (BOOL)validateEmailWithString:(NSString*)email WithIdentifier:(NSString*)identifier
{
	TCSTART
	
	if(email == nil)
    {
		[ShowAlert showError:[NSMutableString stringWithFormat:@"Please enter %@",identifier]];
		return FALSE;
    }
	
	if(email.length == 0)
    {
		[ShowAlert showError:[NSMutableString stringWithFormat:@"Please enter %@",identifier]];
		return FALSE;
    }
	
	
	NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	
	if(![emailTest evaluateWithObject:email])
    {
		[ShowAlert showError:[NSMutableString stringWithFormat:@"Please enter a valid %@",identifier]];
		return FALSE;
    }
	else
		return TRUE;
	
	TCEND
}

- (BOOL) validateUrl: (NSString *) url {
    NSString *urlRegEx =
    @"http(s)?://([\\w-]+\\.)+[\\w-]+(/[\\w- ./?%&amp;=]*)?";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:url];
}

- (BOOL)validateUrl:(NSString *)url andcheckingTypes:(NSTextCheckingTypes)type {
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    return [NSURLConnection canHandleRequest:req];
    
    NSUInteger length = [url length];
    // Empty strings should return NO
    if (length > 0) {
        NSError *error = nil;
        //        NSTextCheckingTypePhoneNumber
        //        NSTextCheckingTypeLink
        NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:type error:&error];
        if (dataDetector && !error) {
            NSRange range = NSMakeRange(0, length);
            NSRange notFoundRange = (NSRange){NSNotFound, 0};
            NSRange linkRange = [dataDetector rangeOfFirstMatchInString:url options:0 range:range];
            if (!NSEqualRanges(notFoundRange, linkRange) && NSEqualRanges(range, linkRange)) {
                return YES;
            }
        }
        else {
            NSLog(@"Could not create link data detector: %@ %@", [error localizedDescription], [error userInfo]);
        }
    }
    return NO;
}

#pragma mark Indexpath from uievent
- (NSIndexPath *)getIndexPathForEvent:(UIEvent *)event ofTableView:(UITableView *)tableView {
    NSIndexPath *indexPath = nil;
    @try {
        NSSet *allTouches = [event allTouches];
        CGPoint likeLocationPoint = [[allTouches anyObject]locationInView:tableView];
        indexPath = [tableView indexPathForRowAtPoint:likeLocationPoint];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
        
    }
    return indexPath;
}

#pragma mark Counts
- (NSString *)returningPluralFormWithCount:(NSInteger)count {
    if (count != 1) {
        return @"s";
    } else {
        return @"";
    }
}

- (NSString *)returningPluralFormWithCountForLikes:(NSInteger)count {
    if (count != 1) {
        return @"s";
    } else {
        return @"d";
    }
}

- (NSString *)getUserStatisticsFormatedString:(unsigned long long)userStatisticsCount {
    
    @try {
        NSString *userStatisticsString = nil;
        if (userStatisticsCount > 1000) {
            float statisticsValue = (float) (userStatisticsCount / 1000);
            
            userStatisticsString = [[@""stringByAppendingFormat:@"%.1f", statisticsValue] stringByAppendingString:@"K"];
        } else {
            userStatisticsString = [NSString stringWithFormat:@"%lld",userStatisticsCount];
        }
        return userStatisticsString;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

//#pragma mark get #tag from tag expression
//- (NSArray *) getHashTagRangesFromTagExpression: (NSString *) tagExp {
//    NSError *error;
//    NSString *pattern =
//    @"#.*$ ?";
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
//    if (!error) {
//        NSArray *matches = [regex matchesInString:tagExp
//                                          options:0
//                                            range:NSMakeRange(0, [tagExp length])];
//        return matches;
//    } else {
//        NSLog(@"getHashTagRangesFromTagExpression %@",[error localizedDescription]);
//        return nil;
//    }
//}

- (NSString *)relativeDateString:(NSString *)serverDateStr {
    @try {
        const int SECOND = 1;
        const int MINUTE = 60 * SECOND;
        const int HOUR = 60 * MINUTE;
        const int DAY = 24 * HOUR;
        const int MONTH = 30 * DAY;
        
        serverDateStr = [NSString stringWithFormat:@"%@ +0000",serverDateStr];
        NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
        [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH':'mm':'ssZZZ"];
        NSDate *serverDate = [dateFormatter1 dateFromString:serverDateStr];
        
        //timezone only for client time
        NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
        [dateFormatter2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
        [timeZone secondsFromGMTForDate:[NSDate date]];
        [dateFormatter2 setTimeZone:timeZone];
        NSDate *now = [dateFormatter2 dateFromString:[dateFormatter2 stringFromDate:[NSDate date]]];
        
        
        NSTimeInterval delta = [serverDate timeIntervalSinceDate:now] * -1.0;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger units = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit);
        NSDateComponents *components = [calendar components:units fromDate:serverDate toDate:now options:0];
        
        NSString *relativeString;
        
        if (delta < 0) {
            relativeString = @"now";
            
        } else if (delta < 1 * MINUTE) {
            relativeString = (components.second == 1) ? @"1 second ago" : [NSString stringWithFormat:@"%d seconds ago",components.second];
            
        } else if (delta < 2 * MINUTE) {
            relativeString =  @"1 minute ago";
            
        } else if (delta < 45 * MINUTE) {
            relativeString = (components.minute == 1) ? @"1 minute ago" : [NSString stringWithFormat:@"%d minutes ago",components.minute];
            //relativeString = [NSString stringWithFormat:@"%d minutes ago",components.minute];
            
        } else if (delta < 90 * MINUTE) {
            relativeString = @"1 hour ago";
            
        } else if (delta < 24 * HOUR) {
            relativeString = (components.hour == 1) ? @"1 hour ago" : [NSString stringWithFormat:@"%d hours ago",components.hour];
            //relativeString = [NSString stringWithFormat:@"%d hours ago",components.hour];
            
        } else if (delta < 48 * HOUR) {
            relativeString = @"yesterday";
            
        } else if (delta < 30 * DAY) {
            relativeString = (components.day == 1) ? @"1 day ago" : [NSString stringWithFormat:@"%d days ago",components.day];
            //relativeString = [NSString stringWithFormat:@"%d days ago",components.day];
            
        } else if (delta < 12 * MONTH) {
            relativeString = (components.month <= 1) ? @"1 month ago" : [NSString stringWithFormat:@"%d months ago",components.month];
            
        } else {
            relativeString = (components.year <= 1) ? @"1 year ago" : [NSString stringWithFormat:@"%d years ago",components.year];
            
        }
        return relativeString;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (NSString *)relativeVideoCreatedDateString:(NSString *)serverDateStr {
    @try {
        const int SECOND = 1;
        const int MINUTE = 60 * SECOND;
        const int HOUR = 60 * MINUTE;
        const int DAY = 24 * HOUR;
        const int MONTH = 30 * DAY;
        
        NSMutableString *serverMStr = [[NSMutableString alloc] initWithString:serverDateStr];
        [serverMStr replaceCharactersInRange:NSMakeRange(serverDateStr.length - 1, 1) withString:@" +0000"];
        NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
        [dateFormatter1 setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"];
        NSDate *serverDate = [dateFormatter1 dateFromString:serverMStr];
        
        //timezone only for client time
        NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
        [dateFormatter2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
        [timeZone secondsFromGMTForDate:[NSDate date]];
        [dateFormatter2 setTimeZone:timeZone];
        
        NSDate *now = [dateFormatter2 dateFromString:[dateFormatter2 stringFromDate:[NSDate date]]];
        
        NSTimeInterval delta = [serverDate timeIntervalSinceDate:now] * -1.0;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger units = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit);
        NSDateComponents *components = [calendar components:units fromDate:serverDate toDate:now options:0];
        
        NSString *relativeString;
        
        if (delta < 0) {
            relativeString = @"now";
            
        } else if (delta < 1 * MINUTE) {
            relativeString = (components.second == 1) ? @"1 second ago" : [NSString stringWithFormat:@"%d seconds ago",components.second];
            
        } else if (delta < 2 * MINUTE) {
            relativeString =  @"1 minute ago";
            
        } else if (delta < 45 * MINUTE) {
            relativeString = (components.minute == 1) ? @"1 minute ago" : [NSString stringWithFormat:@"%d minutes ago",components.minute];
            //relativeString = [NSString stringWithFormat:@"%d minutes ago",components.minute];
            
        } else if (delta < 90 * MINUTE) {
            relativeString = @"1 hour ago";
            
        } else if (delta < 24 * HOUR) {
            relativeString = (components.hour == 1) ? @"1 hour ago" : [NSString stringWithFormat:@"%d hours ago",components.hour];
            //relativeString = [NSString stringWithFormat:@"%d hours ago",components.hour];
            
        } else if (delta < 48 * HOUR) {
            relativeString = @"yesterday";
            
        } else if (delta < 30 * DAY) {
            relativeString = (components.day == 1) ? @"1 day ago" : [NSString stringWithFormat:@"%d days ago",components.day];
            //relativeString = [NSString stringWithFormat:@"%d days ago",components.day];
            
        } else if (delta < 12 * MONTH) {
            relativeString = (components.month <= 1) ? @"1 month ago" : [NSString stringWithFormat:@"%d months ago",components.month];
            
        } else {
            relativeString = (components.year <= 1) ? @"1 year ago" : [NSString stringWithFormat:@"%d years ago",components.year];
            
        }
        return relativeString;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
        
    }
}

- (BOOL)isNotificationCreatedTimeIsLessThanOrEqual7Days:(NSString *)serverDateStr {
    @try {
        const int SECOND = 1;
        const int MINUTE = 60 * SECOND;
        const int HOUR = 60 * MINUTE;
        const int DAY = 24 * HOUR;
        
        serverDateStr = [NSString stringWithFormat:@"%@ +0000",serverDateStr];
        NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
        [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH':'mm':'ssZZZ"];
        NSDate *serverDate = [dateFormatter1 dateFromString:serverDateStr];
        
        //timezone only for client time
        NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
        [dateFormatter2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
        [timeZone secondsFromGMTForDate:[NSDate date]];
        [dateFormatter2 setTimeZone:timeZone];
        NSDate *now = [dateFormatter2 dateFromString:[dateFormatter2 stringFromDate:[NSDate date]]];
        
        
        NSTimeInterval delta = [serverDate timeIntervalSinceDate:now] * -1.0;
        if (delta <= 7 * DAY) {
            return YES;
            
        } else {
            return NO;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (BOOL)isFacebookBirthDateMathesToday:(NSString *)birthDayString {
    TCSTART
    NSLog(@"BirthDay :%@",birthDayString);
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    if ([birthDayString rangeOfString:@", " options:NSCaseInsensitiveSearch].location != NSNotFound) {
        [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    } else {
        [dateFormatter setDateFormat:@"MMMM dd"];
    }
    
    NSDate* birthDate = [dateFormatter dateFromString:birthDayString];
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"MM-dd"];
    
    NSDate *now = [dateFormatter2 dateFromString:[dateFormatter2 stringFromDate:[NSDate date]]];
    
    birthDate = [dateFormatter2 dateFromString:[dateFormatter2 stringFromDate:birthDate]];
    
    
    switch ([birthDate compare:now]) {
        case NSOrderedAscending:
            return NO;
            break;
        case NSOrderedSame:
            return YES;
            break;
        case NSOrderedDescending:
            return NO;
            break;
    }
    
    TCEND
}

- (UIView *)getToastViewWithMessageText:(NSString *)message andFrame:(CGRect)frame {
    TCSTART
    
    UIView *toastView = [[UIView alloc] initWithFrame:frame];
    toastView.backgroundColor = [UIColor clearColor];
    
    CGSize textSize = [message sizeWithFont:[UIFont fontWithName:titleFontName size:12] forWidth:(frame.size.width - 40) lineBreakMode:UILineBreakModeWordWrap];
    UILabel *toastlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, frame.size.width - 20, textSize.height + 40)];
    toastlabel.numberOfLines = 0;
    toastlabel.backgroundColor = [UIColor blackColor];
    toastlabel.alpha = 0.8;
    toastlabel.textColor = [UIColor whiteColor];
    toastlabel.layer.borderColor = [UIColor whiteColor].CGColor;
    toastlabel.layer.borderWidth = 1.0;
    toastlabel.layer.cornerRadius = 4.0f;
    toastlabel.layer.masksToBounds = YES;
    toastlabel.textAlignment = UITextAlignmentCenter;
    toastlabel.font = [UIFont fontWithName:titleFontName size:12];
    toastlabel.text = message;
    
    [toastView addSubview:toastlabel];
    return toastView;
    TCEND
}

- (BOOL)isGooglePlusBirthDateMathesToday:(NSString *)birthDayString {
    TCSTART
    NSLog(@"BirthDay :%@",birthDayString);
    // Removing Year
    NSMutableString *birthStr = [[NSMutableString alloc] initWithString:birthDayString];
    NSRange strinRange = NSMakeRange(0, 5);
    [birthStr replaceCharactersInRange:strinRange withString:@""];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd"];
    NSDate* birthDate = [dateFormatter dateFromString:birthStr];
    
    //    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    //    [dateFormatter2 setDateFormat:@"MM-dd"];
    
    NSDate *now = [dateFormatter dateFromString:[dateFormatter stringFromDate:[NSDate date]]];
    
    switch ([birthDate compare:now]) {
        case NSOrderedAscending:
            return NO;
            break;
        case NSOrderedSame:
            return YES;
            break;
        case NSOrderedDescending:
            return NO;
            break;
    }
    
    TCEND
}

- (NSString *)facebookLastUpdateDateStringFromMillisecondsTime:(NSString *)string {
    TCSTART
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSDate *afterConvertTime = [NSDate dateWithTimeIntervalSince1970:[string longLongValue]];
    
    return [dateFormatter stringFromDate:afterConvertTime];
    TCEND
}

- (NSString *)twitterLastUpdateDateString:(NSString *)string {
    TCSTART
    //    2014-01-09 06:53:19
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE MMMM dd HH':'mm':'ssZZZ yyyy"];
    NSDate* afterconvert = [dateFormatter dateFromString:string];
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *formattedDate = [dateFormatter2 stringFromDate:afterconvert];
    NSLog(@"Date :%@",formattedDate);
    return formattedDate;
    
    TCEND
}


#pragma mark Network Activity Related=====================================================
- (void)showNetworkIndicator{
    
    @try {
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)hideNetworkIndicator {
    
    @try {
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = NO;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)showActivityIndicatorInView:(UIView *)view andText:(NSString *)text {
    @try {
        // Show an activity spinner that blocks the whole screen
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.color = [UIColor blackColor];
        hud.alpha = 0.7;
        hud.labelText = NSLocalizedString(text, @"");
        hud.detailsLabelText = NSLocalizedString(@"", @"");
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)removeNetworkIndicatorInView:(UIView *)view {
    
    @try {
        [MBProgressHUD hideHUDForView:view animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

#pragma mark
#pragma Image Cropping Method
- (UIImage*)getImageByCroppingImage:(UIImage *)imageToCrop toRect:(CGRect)rect {
    TCSTART
    //create a context to do our clipping in
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    //create a rect with the size we want to crop the image to
    //the X and Y here are zero so we start at the beginning of our
    //newly created context
    
    //    CGFloat X = (imageToCrop.size.width - rect.size.width)/2;
    //    CGFloat Y = (imageToCrop.size.height - rect.size.height)/2;
    
    
    //    CGRect clippedRect = CGRectMake(X, Y, rect.size.width, rect.size.height);
    //CGContextClipToRect( currentContext, clippedRect);
    
    
    
    //create a rect equivalent to the full size of the image
    //offset the rect by the X and Y we want to start the crop
    //from in order to cut off anything before them
    CGRect drawRect = CGRectMake(0,
                                 0,
                                 imageToCrop.size.width,
                                 imageToCrop.size.height);
    
    CGContextTranslateCTM(currentContext, 0.0, drawRect.size.height);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    //draw the image to our clipped context using our offset rect
    //CGContextDrawImage(currentContext, drawRect, imageToCrop.CGImage);
    
    
    CGImageRef tmp = CGImageCreateWithImageInRect(imageToCrop.CGImage, rect);
    
    //pull the image from our cropped context
    UIImage *cropped = [UIImage imageWithCGImage:tmp];//UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(tmp);
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    //Note: this is autoreleased*/
    return cropped;
    TCEND
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [exportProgressBarTimer invalidate];
    exportProgressBarTimer = nil;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if ([self isNotNull:loggedInUser]) {
        [self saveLoggedUserData:loggedInUser];
    }
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if ([[UIApplication sharedApplication] applicationIconBadgeNumber] != 0) {
        [self makeRequestForResetBadgeCount];
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    if ([self statusForNetworkConnectionWithOutMessage]) {
        [self uploadVideo];
    }
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
