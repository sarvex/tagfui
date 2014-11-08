/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"
#import "ProfileService.h"

@interface ChangePassWordViewController : UIViewController <UITextFieldDelegate, ProfileServiceDelegate,UITableViewDelegate,UITableViewDataSource> {
    WooTagPlayerAppDelegate *appDelegate;
    UITableView *changePasswordTableView;
    NSMutableDictionary *passwordsDict;
}

@end
