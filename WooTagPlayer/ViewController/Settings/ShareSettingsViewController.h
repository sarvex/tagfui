/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"
#import "NotificationService.h"

@interface ShareSettingsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,GPPSignInDelegate,FHSTwitterEngineAccessTokenDelegate,NotificationServiceDelegate> {
    IBOutlet UILabel *titleLabel;
    NSString *type;
    WooTagPlayerAppDelegate *appDelegate;
    UITableView *settingsTableView;
    NSArray *rowsArray;
    NSMutableDictionary *pushNotificationsDictionary;
    NSArray *pushNotificationsArray;
}
- (IBAction)onClickOfBackBtn:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil viewType:(NSString *)viewType;

@end
