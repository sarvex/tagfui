/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"
#import "SuggestedUsersViewController.h"
#import "UserService.h"

@interface SuggestedUsersTable : UITableView<UITableViewDataSource, UITableViewDelegate,UserServiceDelegate> {
    WooTagPlayerAppDelegate *appDelegate;
    NSInteger pageNumber;
    NSMutableArray *suggestedUsersArray;
}
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain)SuggestedUsersViewController *caller;
- (void)displaySuggestedUsersInView;
@end
