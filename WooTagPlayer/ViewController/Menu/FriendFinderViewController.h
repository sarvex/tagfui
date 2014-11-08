/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"
#import "VideoFeedAndMoreVideosViewController.h"
#import "UserService.h"
#import "BrowseService.h"

@interface FriendFinderViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UserServiceDelegate,UISearchBarDelegate, BrowseServiceDelegate> {
    NSArray *friendArray;
    WooTagPlayerAppDelegate *appDelegate;
    IBOutlet UITableView *finderTableView;
    
    IBOutlet UIButton *backBtn;
    IBOutlet UIImageView *bannerImgView;
    NSMutableArray *suggestedUsersArray;
    
    NSInteger pageNumber;
    NSInteger searchPgNumber;
    BOOL  searchSelected;
    
    IBOutlet UISearchBar *usersSearchBar;
    IBOutlet UILabel *searchBarBg;
    NSArray *usersArray;
  
}
- (void)setFrameForView:(CGRect)frame;
@property (nonatomic, retain) VideoFeedAndMoreVideosViewController *superVC;
@property (nonatomic, readwrite) NSInteger pageNumber;
- (IBAction)onClickOfBackButton:(id)sender;
- (void)makeRequestForSuggestedUsersForFirstTime;
- (IBAction)onClickOfSearchBtn:(id)sender;
@end
