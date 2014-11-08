/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"
#import "TagToolViewController.h"

@interface ProductInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate> {
    IBOutlet UITableView *productDetailsTableView;
    WooTagPlayerAppDelegate *appDelegate;
    BOOL categoryListExpanded;
    BOOL currencyListExpanded;
    NSMutableDictionary *tagDetailsDict;
    NSArray *categoriesArray;
    NSArray *currencyListArray;
}
@property (nonatomic, retain) NSMutableDictionary *tagDetailsDict;
@property (nonatomic, retain) TagToolViewController *tagToolVC;
- (IBAction)onClickOfCancelBtn:(id)sender;
- (IBAction)onclickOfDoneBtn:(id)sender;
- (void)reloadTable;

@end
