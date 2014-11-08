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
#import "FullProfilePicViewController.h"

@class MainViewController;

@interface MyPageViewController : UIViewController<UISearchBarDelegate,UITableViewDataSource, UITableViewDelegate,/**UITextViewDelegate,*/UserServiceDelegate,VideoServiceDelegate,UIActionSheetDelegate,UIScrollViewDelegate> {
    //Banner
    
    IBOutlet UIView *userBannerView;
    
    IBOutlet UIImageView *userBannerImgView;
    IBOutlet UIImageView *profileImgView;
    IBOutlet UILabel *userName;
    IBOutlet UILabel *updatedLabel;
    IBOutlet UILabel *websiteLbl;
    IBOutlet UIButton *websiteBtn;
    IBOutlet UILabel *bioLabl;
    
    IBOutlet UILabel *followersCountLbl;
    IBOutlet UILabel *followersTextlbl;
    IBOutlet UILabel *followingsCountLbl;
    IBOutlet UILabel *followingsTextlbl;
    IBOutlet UILabel *privateCountLbl;
    IBOutlet UILabel *privateTextlbl;
    
    IBOutlet UILabel *dividerLabel;
    IBOutlet UILabel *numberOfvideosLbl;
    IBOutlet UILabel *numberOfTagsLbl;
    
    IBOutlet UIButton *accountSettingsBtn;
    
    IBOutlet UITableView *videosTableView;
    
    IBOutlet UISearchBar *videosSearchBar;
    IBOutlet UILabel *searchBarBg;
    BOOL searchSelected;
    WooTagPlayerAppDelegate *appDelegate;
    
    MainViewController *mainVC;
    
    NSArray *mypageVideos;
//    CommentTextView *commentTextViewRef;
    
    AllCommentsViewController *allCmntsVC;
    
    UserModal *user;
    
    BOOL checkForRefresh;
	BOOL reloading;
    RefreshView *refreshView;
    NSIndexPath *selectedIndexPath;
    
    FullProfilePicViewController *fullProfilePicVC;
    
    IBOutlet UIScrollView *headerScrollView;
    IBOutlet UIPageControl *pageControl;
}
@property (nonatomic, retain) MainViewController *mainVC;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andFrame:(CGRect)frame;

- (void)allCommentsScreenDismissCalledSelectedIndexPath:(NSIndexPath *)indexPath andViewType:(NSString *)viewType;

- (IBAction)onClickOfFollowersBtn;
- (IBAction)onClickOfFollowingsBtn;
- (IBAction)onClickOfPrivateUsersBtn:(id)sender;
- (void)playBackResponse:(NSDictionary *)results;

- (IBAction)onClickOfSearchBtn:(id)sender;
- (IBAction)onClickOfQuickLinksBtn:(id)sender;
- (void)afterUpdateProfileFromAccountSettings;

- (IBAction)onClickOfSettingsBtn:(id)sender;
- (IBAction)onClickOfUserPicButton;
- (void)removeFullProfilePicVC;
- (IBAction)changePage;
- (IBAction)onClickOfWebsiteBtn;

- (void)refreshMyPageVideos;
@end
