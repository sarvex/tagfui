/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "TagToolViewController.h"
#import "ShareViewController.h"

@class ShareContactsViewController;

@interface FriendsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UserServiceDelegate> {
   
    IBOutlet UITableView *friendsTable;
    IBOutlet UISearchBar *friendsSearchBar;
    
    IBOutlet UIImageView *searchBarBackgroundImg;
    
    NSMutableArray *friendsList;
    NSMutableArray *filteredFriendsList;
    
    
    BOOL isSearching;
    NSString *next_cursor;//per page 20 results will be loaded.
    ShareContactsViewController *shareVC;
    
    //Share video to multiple users 
    NSMutableArray *selectedArray;
    
    NSDictionary *selectedUserDict;
    NSInteger pageNumber;
}

@property (nonatomic, retain) NSMutableArray *friendsList;
@property (nonatomic, retain) NSMutableArray *pagesArray;
@property (nonatomic, retain) NSMutableArray *loggedInUserDictArray;

@property (nonatomic,readwrite)BOOL isLoadingFriends;
@property (nonatomic,readwrite)BOOL isGPlusFriendsLoaded;
@property (nonatomic,readwrite)BOOL isTWFriendsLoaded;
@property (nonatomic,readwrite)BOOL isWTFriendsLoaded;
@property (nonatomic, readwrite)BOOL isFBFriendsLoaded;
@property (nonatomic, readwrite) BOOL isContactsLoaded;
@property (nonatomic, retain) NSDictionary *selectedUserDict;
@property (nonatomic, strong)TagToolViewController *caller;
@property (nonatomic, strong)ShareContactsViewController *shareVC;

- (void)reloadData;
- (void)formatTWDataAndReloadFriendsTable:(id)twData loggedInUserInfo:(NSDictionary *)userDict andRequestForLoadMore:(BOOL)loadmore;
- (void)setImageForSearchBgPlaceholder;
- (void)setAllBoolVariablesToNo;
//- (void)makeRequestForListOfFollowings:(BOOL)pagination andPageNum:(NSInteger)pagNum;
- (void)makeRequestForListOfWooTagFreinds:(BOOL)pagination andPageNum:(NSInteger)pagNum;
@end
