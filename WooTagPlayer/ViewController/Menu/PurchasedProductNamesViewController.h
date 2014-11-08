/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>

@interface PurchasedProductNamesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ProfileServiceDelegate> {
    IBOutlet UITableView *productsListTableView;
    NSMutableArray *productListArray;
    WooTagPlayerAppDelegate *appDelegate;
}
- (IBAction)onClickOfBackButton:(id)sender;
@end
