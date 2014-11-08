/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "CommentTextView.h"
#import "UserModal.h"
#import "UserService.h"
#import "VideoService.h"
#import "AllCommentsViewController.h"
#import "FullProfilePicViewController.h"

@interface OthersPageViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UserServiceDelegate, VideoServiceDelegate,UISearchBarDelegate,UIActionSheetDelegate,UIScrollViewDelegate> {
    //Banner
    
    IBOutlet UITableView *videosTableView;
    IBOutlet UIImageView *userBannerImgView;
    IBOutlet UIView *bannerView;
    IBOutlet UIImageView *profileImgView;
    
    IBOutlet UIButton *followBtn;
    IBOutlet UIButton *privateBtn;
    
    IBOutlet UILabel *dividerLabel;
    
    IBOutlet UILabel *numberOfvideosLbl;
    IBOutlet UILabel *numberOfTagsLbl;;
    
    IBOutlet UILabel *userName;
    IBOutlet UILabel *updatedLabel;
    IBOutlet UILabel *websiteLbl;
    IBOutlet UIButton *websiteBtn;
    IBOutlet UILabel *bioLabl;
    
    IBOutlet UILabel *followersCountLbl;
    IBOutlet UILabel *followingsCountLbl;
    IBOutlet UILabel *privateCountLbl;
    IBOutlet UILabel *followersTextlbl;
    IBOutlet UILabel *followingsTextlbl;
    IBOutlet UILabel *privateTextlbl;
    
    IBOutlet UISearchBar *videosSearchBar;
    IBOutlet UILabel *searchBarBg;
    NSArray *myPageVideos;
    BOOL searchSelected;
    WooTagPlayerAppDelegate *appDelegate;
    
    NSString *userId;
    UserModal *selectedUser;
    AllCommentsViewController *allCmntsVC;
    
    NSInteger pageNumber;
    NSInteger searchPgNumber;
    
    NSIndexPath *selectedIndexPath;
    IBOutlet UILabel *titleLbl;
    
    FullProfilePicViewController *fullProfilePicVC;
    
    IBOutlet UIScrollView *headerScrollView;
    IBOutlet UIPageControl *pageControl;
    
    BOOL checkForRefresh;
	BOOL reloading;
    RefreshView *refreshView;
    
}
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@property (nonatomic, retain) id caller;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUser:(NSString *)selectedUserId;

- (IBAction)goBack:(id)sender;
- (IBAction)clickedOnFollowersBtn:(id)sender;
- (IBAction)clickedOnFollowingsBtn:(id)sender;
- (IBAction)clickedOnFollowBtn:(id)sender;

- (IBAction)onClickOfPrivateUsersBtn:(id)sender;
- (IBAction)clickedOnPrivateBtn:(id)sender;

- (IBAction)onClickOfSearchBtn:(id)sender;

- (void)allCommentsScreenDismissCalledSelectedIndexPath:(NSIndexPath *)indexPath andViewType:(NSString *)viewType;

- (void)playBackResponse:(NSDictionary *)results;
- (IBAction)onClickOfUserPicButton;
- (void)removeFullProfilePicVC;
- (IBAction)changePage;
- (IBAction)onClickOfWebsiteBtn;
@end
