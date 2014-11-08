/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "UserService.h"
#import "VideoService.h"
#import "WooTagPlayerAppDelegate.h"
#import "AllCommentsViewController.h"
#import "RefreshView.h"
#import "UploadingProgressView.h"
#import "FriendFinderViewController.h"

@interface VideoFeedAndMoreVideosViewController : UIViewController<UISearchBarDelegate,UITableViewDataSource, UITableViewDelegate,UserServiceDelegate,VideoServiceDelegate,UIActionSheetDelegate> {
    
    /** Videos tableview
     */
    IBOutlet UITableView *videosTableView;
    
    /** Videos search bar . Label is displaying white background to search bar
     */
    IBOutlet UISearchBar *videosSearchBar;
    IBOutlet UILabel *searchBarBg;
    BOOL searchSelected;
    BOOL reqMadeForSearch;
    
    /** Quicklinks button ref of MainViewController
     */
    IBOutlet UIButton *quickLinksBtn;
    IBOutlet UIButton *backButton;
    WooTagPlayerAppDelegate *appDelegate;
    
    /** Reference of super viewcontroller
     */
    MainViewController *mainVC;
    
    /** Common Viewcontroller for likes, comments, followers, followings and privategroup
     */
    AllCommentsViewController *allCmntsVC;
    
    /** Indicates which is for videofeed or privatefeed or mypagemorevideos. Similar design in all screens
     */
    NSString *viewType;
    NSString *selectedType;
    
    /** Videos array
     */
    NSMutableArray *displayVideosArray;
    NSInteger pageNumber;
    NSInteger searchPgNumber;
    
    /** in each dictionary maintaining pagenumber, viewtype and videos
     */
    NSMutableDictionary *browseDict;
    NSMutableDictionary *searchDict;
    
    /** Pull to refresh view
     */
    BOOL checkForRefresh;
	BOOL reloading;
    RefreshView *refreshView;
    
    /** Two tabs in home page
     */
    IBOutlet UIButton *followingFeedBtn;
    IBOutlet UIButton *privateFeedBtn;
    IBOutlet UIImageView *feedBgImgView;
    
    
    NSIndexPath *selectedIndexPath;
    
    /** Video uplaoding progress view
     */
    IBOutlet UIView *videoLoadingView;
    IBOutlet UploadingProgressView *progressView;
    IBOutlet UILabel *loadingLbl;
    IBOutlet UILabel *progressviewBg;
    
    /** When no following videos or private videos then displaying friend finder screen
     */
    FriendFinderViewController *friendFinderVC;
   
    //Showing friendfinder design after getting empty resposne for videofeed request or showing privatefeed placeholder text after getting empty response for privatefeed request from server
    BOOL requestedForVideoFeed;
    
    
    IBOutlet UILabel *titleLabl;
    
}

/** Reference of super viewcontroller
 */
@property (nonatomic, retain) MainViewController *mainVC;

/** Video uplaoding progress view
 */
@property (nonatomic, retain) UploadingProgressView *progressView;
@property (nonatomic, retain) IBOutlet UIView *videoLoadingView;

/** Initializing viewcontroller with viewtype
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andFrame:(CGRect)frame andViewType:(NSString *)type;

/** Callback from AllComentsViewController when screen dismissed to update corresponding video likes/comments
 */
- (void)allCommentsScreenDismissCalledSelectedIndexPath:(NSIndexPath *)indexPath andViewType:(NSString *)viewType;

/** Video playback response
 */
- (void)playBackResponse:(NSDictionary *)results;

/** Clicked actions for SearchButton, quicklinks, back, videofeeds, privatefeeds buttons
 */
- (IBAction)onClickOfSearchBtn:(id)sender;
- (IBAction)onClickOfQuickLinksBtn:(id)sender;
- (IBAction)goBack:(id)sender;

- (IBAction)onClickOfFollowingFeedBtn:(id)sender;
- (IBAction)onClickOfPrivateFeedBtn:(id)sender;

/** Set visibility and progress value for video uplaod progress view
 */
- (void)setVisibilityForVideouploadingView:(BOOL)visible andPublishing:(BOOL)publishing;
- (void)setBoolValueForControllerVariable;
- (void)hideVideoUplaodingView;
- (void)applicationDidEnterForegroundNotificationFromMainVC;
- (void)removeObservers;
@end
