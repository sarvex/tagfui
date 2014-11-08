/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"
#import "UserService.h"
#import <MessageUI/MessageUI.h>

@interface SocialFriendsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UserServiceDelegate, GPPSignInDelegate, FHSTwitterEngineAccessTokenDelegate, UISearchBarDelegate,MFMessageComposeViewControllerDelegate> {
    WooTagPlayerAppDelegate *appDelegate;
    NSString *reqType;
    IBOutlet UITableView *friendsTable;
    IBOutlet UILabel *titleLabl;
    NSMutableArray *friendsList;

    BOOL isLoadingFriends;
    BOOL isTWFriendsLoaded;
    IBOutlet UISearchBar *friendsSearchBar;
    IBOutlet UIImageView *searchBarBackgroundImg;
    NSMutableArray *filteredFriendsList;
    
    NSMutableArray *selectedFreindsList;
    
    IBOutlet UIButton *inviteBtn;
    BOOL isSearching;
    NSString *next_cursor;//per page 20 results will be loaded.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andViewType:(NSString *)viewType;
- (IBAction)onClickOfBackButton:(id)sender;
- (void)cancelTwitterAuthentication;
- (IBAction)onClickOfInviteButton;

@end
