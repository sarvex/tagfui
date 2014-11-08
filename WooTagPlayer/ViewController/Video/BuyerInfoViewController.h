/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"
#import "WootagInfoViewController.h"

@interface BuyerInfoViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate> {
    IBOutlet UITableView *buyerDetailsTableView;
    WooTagPlayerAppDelegate *appDelegate;
    NSMutableDictionary *buyerDetailsDict;
    NSArray *headersList;
    BuyerInfo *buyerInfo;
}

@property (nonatomic, retain) WootagInfoViewController *wootagInfoVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withBuyerInfo:(BuyerInfo *)info;

- (IBAction)onClickOfCancelBtn:(id)sender;
- (IBAction)onclickOfDoneBtn:(id)sender;
- (void)reloadTable;

@end
