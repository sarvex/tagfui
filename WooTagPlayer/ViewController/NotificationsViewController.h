/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"
#import "NotificationService.h"
#import "RefreshView.h"
#import "UserService.h"

@interface NotificationsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, NotificationServiceDelegate,UserServiceDelegate,UIGestureRecognizerDelegate, UISearchBarDelegate> {
    IBOutlet UITableView *notificationsTableView;
    NSMutableArray *notificationsArray;
    WooTagPlayerAppDelegate *appDelegate;
    
    BOOL checkForRefresh;
	BOOL reloading;
    RefreshView *refreshView;
    
    IBOutlet UISearchBar *notificationsSearchBar;
    IBOutlet UILabel *searchBarBg;
    IBOutlet UIButton *searchBt;
    
    BOOL searchSelected;
    
    BOOL requestedForNotifications;
    
}
@property (nonatomic, retain) MainViewController *mainVC;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andFrame:(CGRect)frame;

- (IBAction)onClickOfQuickLinksBtn:(id)sender;
- (IBAction)onClickOfSearchBtn:(id)sender;
- (void)refreshNotificationsScreen;
- (IBAction)editingTableView:(id)sender;
@end
