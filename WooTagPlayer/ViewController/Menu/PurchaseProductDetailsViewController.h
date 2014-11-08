/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
@interface PurchaseProductDetailsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate,ProfileServiceDelegate> {
    IBOutlet UITableView *buyersListTableView;
    IBOutlet UILabel *productNameLbl;
    NSMutableArray *buyersListArray;
    WooTagPlayerAppDelegate *appDelegate;
    NSString *productName;
    NSString *productId;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withProductInfo:(NSDictionary *)productInfo;
- (IBAction)onClickOfBackButton:(id)sender;
@end
