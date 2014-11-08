/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"
#import <MessageUI/MessageUI.h>

@interface SettingsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate> {
    WooTagPlayerAppDelegate *appDelegate;
    UITableView *settingsTableView;
    NSArray *sectionsArray;
}

- (IBAction)onClickOfBackBtn:(id)sender;
@property (nonatomic, retain) MainViewController *mainVC;
@end
