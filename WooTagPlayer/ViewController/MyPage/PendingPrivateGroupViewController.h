/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"
#import "UserService.h"
#import "AllCommentsViewController.h"

/** This is for displaying pending privategroup requests
 */

@interface PendingPrivateGroupViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,UserServiceDelegate> {
    IBOutlet UITableView *friendsTableView;
    IBOutlet UILabel *titleLabel;
    WooTagPlayerAppDelegate *appDelegate;
    NSInteger count;
    NSMutableArray *friendsArray;
    NSInteger pageNumber;
    UserModal *selectedUser;
}

@property (nonatomic, retain)AllCommentsViewController *allCmntsVC;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(UserModal *)selectedUser_;
- (IBAction)onClickOfBackButton:(id)sender;
@end
