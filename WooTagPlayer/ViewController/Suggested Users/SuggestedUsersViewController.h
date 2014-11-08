/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"
#import "UserService.h"
#import "MyPageViewController.h"

/** Common view for suggested users and more people from MypageViewController
 */
@interface SuggestedUsersViewController : UIViewController {
    NSString *userId;
    NSString *viewTitle;
    IBOutlet UILabel *titleLbl;
    IBOutlet UILabel *viewtitleLbl;
    WooTagPlayerAppDelegate *appDelegate;
    BOOL followedUser;
}

@property (nonatomic, strong) MyPageViewController *caller;
@property (nonatomic, readwrite) BOOL followedUser;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUserId:(NSString *)userId_ andTitle:(NSString *)title;
- (IBAction)goBack:(id)sender;
@end
