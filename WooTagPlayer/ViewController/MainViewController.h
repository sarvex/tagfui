/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"

#import "MyPageViewController.h"
#import "BrowseViewController.h"
#import "VideoFeedAndMoreVideosViewController.h"

@class UploadedVideosViewController;
@class MyPageViewController;
@class BrowseViewController;
@class VideoFeedAndMoreVideosViewController;
@class NotificationsViewController;

/** This is MainviewController by giving Home, Browse, Record, Notifications and Mypage tabs. Instead of UITabbarcontroller im using Viewcontroller because we need to present actionsheet instead view for record. This is totally for customization
 */

@interface MainViewController : UIViewController<UIActionSheetDelegate> {
   
    WooTagPlayerAppDelegate *appDelegate;
    
    /** Taking all tabs as buttons by customize
     */
    IBOutlet UIButton *browse_Btn;
    IBOutlet UIButton *videoFeed_Btn;
    IBOutlet UIButton *videoAction_Btn;
    IBOutlet UIButton *notifications_Btn;
    IBOutlet UIButton *myPagebutton;
    IBOutlet UIImageView *customTab_ImgView;
    IBOutlet UIView *customTabView;

    /** when any Pushnotifications comes when app in foreground need to show indicator on notificatiosn tab and home tab
     */
    IBOutlet UILabel *notificationsIndicatorLbl;
    IBOutlet UILabel *videofeedIndicatorLbl;
    
    /** ViewControllers
     */
    UINavigationController *notificationsNavVC;
    UINavigationController *myPageNavVC;
    MyPageViewController *myPageVC;
    UINavigationController *browseNavVC;
    UINavigationController *videoFeedNavVC;

}
/** Custom tabview
 */
@property (nonatomic, retain) UIView *customTabView;

/** when any Pushnotifications comes when app in foreground need to show indicator on notificatiosn tab and home tab
 */
@property (nonatomic, retain) IBOutlet UILabel *notificationsIndicatorLbl;
@property (nonatomic, retain) IBOutlet UILabel *videofeedIndicatorLbl;

/** Need to make all request to refresh screen when app coming from background to foreground
 */
@property (nonatomic, readwrite) BOOL isVideoFeedEnterBg;
@property (nonatomic, readwrite) BOOL isPrivateFeedEnterBg;
@property (nonatomic, readwrite) BOOL isBrowseVideosEnterBg;
@property (nonatomic, readwrite) BOOL isBrowsePeopleEnterBg;
@property (nonatomic, readwrite) BOOL isBrowseTagsEnterBg;
@property (nonatomic, readwrite) BOOL isBrowseTrendsEnterBg;
@property (nonatomic, readwrite) BOOL isNotificationsEnterBg;
@property (nonatomic, readwrite) BOOL isMypageEnterBg;

/** Action methods for custom tab clicks
 */
- (IBAction)displayBrowseView:(id)sender;
- (IBAction)disPlayVideoFeed:(id)sender;
- (IBAction)displayVideoAction:(id)sender;
- (IBAction)displayMyNotifications:(id)sender;
- (IBAction)displayMyPage :(id)sender;

- (IBAction)onClickOfMenuButton;
- (void)bringAllFooterIconsToFront;

- (void)updateMypageDetails;

- (void)refreshAllScreens;
- (void)refreshVideofeed:(BOOL)videofeed NotificationsScreen:(BOOL)notification;

/** Share N playback option. when redirecting to application from outside when click on video url. it maybe from mail, fb, g+, tw etc..
 */
- (void)checkVideoShouldPlayWhenCameFromBrowser:(NSString *)videoId;
- (void)playBackResponse:(NSDictionary *)results;

- (void)removeAllTabsFromVC;
@end
