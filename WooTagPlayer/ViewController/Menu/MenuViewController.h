/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"

@interface MenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *menuTableView;
    WooTagPlayerAppDelegate *appDelegate;
    NSArray *rowsArray;
    IBOutlet UIView *footerView;
    IBOutlet UIButton *logoutBtn;
    
    IBOutlet UIView *notificationView;
    IBOutlet UIView *logoutView;
    
    IBOutlet UILabel *pendingVideosLbl;
    
    IBOutlet UILabel *dividerLbl1;
    IBOutlet UILabel *dividerLbl2;
    IBOutlet UILabel *dividerLbl3;
    
}

- (IBAction)onClickOfPendingVideosBtn;
@end
