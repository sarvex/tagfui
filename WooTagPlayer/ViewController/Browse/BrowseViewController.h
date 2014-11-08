/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"
#import "MainViewController.h"
#import "UserService.h"
#import "BrowseService.h"
#import "RefreshView.h"
#import "AllCommentsViewController.h"

/** This ViewController is for displaying browse videos, browse tags, #tags
 */

@class MainViewController;
@interface BrowseViewController : UIViewController<UITableViewDataSource, UITableViewDelegate , UserServiceDelegate, UISearchBarDelegate, BrowseServiceDelegate,UIActionSheetDelegate, VideoServiceDelegate> {
    
    /** For displaying videos
     */
    IBOutlet UITableView *browseTableView;
    WooTagPlayerAppDelegate *appDelegate;
    
    /** Reference for super viewcontroller
     */
    MainViewController *superVC;
    
    /** in each dictionary maintaining pagenumber, viewtype and videos
     */
    NSMutableDictionary *browseDict;
    NSMutableDictionary *searchDict;
   
    /** Videos array
     */
    NSMutableArray *displayVideosArray;
    NSInteger pageNum;
    
    NSIndexPath *selectedIndexPath;
    
    /**  tabs
     */
    IBOutlet UIImageView *tabsImgView;
    IBOutlet UIButton *videosButton;
    IBOutlet UIButton *peopleButton;
    IBOutlet UIButton *tagsButton;
    IBOutlet UIButton *trendsButton;
    
    /** Videos search bar . Label is displaying white background to search bar
     */
    IBOutlet UISearchBar *videosSearchBar;
    IBOutlet UILabel *searchBarBg;
    
    NSString *browseType;
    BOOL searchSelected;
    BOOL reqMadeForSearch;
    
    /** Pull to refresh view
     */
    BOOL checkForRefresh;
	BOOL reloading;
    RefreshView *refreshView;
    
    AllCommentsViewController *allCmntsVC;
}

/** Reference for super viewcontroller
 */
@property (nonatomic, retain) MainViewController *superVC;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil viewFrame:(CGRect)frame;

/** Clicked actions for SearchButton, quicklinks, back, browse videos, browse tags and trends
 */
- (IBAction)onClickOfSearchBtn:(id)sender;
- (IBAction)onClickOfQuickLinksBtn:(id)sender;

- (IBAction)onClickOfVideosTab:(id)sender;
- (IBAction)onClickOfPeopleTab:(id)sender;
- (IBAction)onClickOfTagsTab:(id)sender;
- (IBAction)onClickOfTrendsTab:(id)sender;

- (void)followedUserFromOtherPageViewControllerWithSelectedIndex:(NSIndexPath *)indexPath andUserId:(NSString *)userId;
- (void)unFollowedUserFromOtherPageViewControllerWithSelectedIndex:(NSIndexPath *)indexPath andUserId:(NSString *)userId;

- (void)applicationDidEnterForegroundNotificationFromMainVC;


- (void)allCommentsScreenDismissCalledSelectedIndexPath:(NSIndexPath *)indexPath andViewType:(NSString *)viewType;

- (void)playBackResponse:(NSDictionary *)results;

@end
