/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"
#import "UserService.h"

/** This is for tagging users in video comments (@username)
 */
@interface ConnectionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,UserServiceDelegate> {
    IBOutlet UITableView *connectionTableview;
    IBOutlet UILabel *bgLabel;
    WooTagPlayerAppDelegate *appDelegate;
    NSMutableArray *connectionsArray;
    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andFrame:(CGRect)frame;
@property (nonatomic, retain) id caller;
- (void)makeRequestForTagCommentUsersWithText:(NSString *)enteredText;
@end
