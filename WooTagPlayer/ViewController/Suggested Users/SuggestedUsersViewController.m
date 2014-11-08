/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "SuggestedUsersViewController.h"
#import "SuggestedUserCell.h"
#import "SuggestedUsersTable.h"

@interface SuggestedUsersViewController ()

@end

@implementation SuggestedUsersViewController
@synthesize caller;
@synthesize followedUser;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUserId:(NSString *)userId_ andTitle:(NSString *)title
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        userId = userId_;
        viewTitle = title;
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad {
    TCSTART
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height - 20);
    if ([viewTitle rangeOfString:@"SUGGESTED" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        viewtitleLbl.text = @"Suggested users";
    } else {
        viewtitleLbl.text = @"More people";
    }
    titleLbl.text = viewTitle;
    titleLbl.backgroundColor = [appDelegate colorWithHexString:@"fafafa"];
    SuggestedUsersTable *usersTableView = [[SuggestedUsersTable alloc] initWithFrame:CGRectMake(0, 90, self.view.frame.size.width, self.view.frame.size.height - 140)];
    usersTableView.caller = self;
    usersTableView.userId = userId;
    [self.view addSubview:usersTableView];
    [usersTableView displaySuggestedUsersInView];
    TCEND
}

- (void) viewDidLayoutSubviews {
    if (CURRENT_DEVICE_VERSION >= 7.0  && self.view.frame.size.height == appDelegate.window.frame.size.height) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.size.height = viewBounds.size.height - topBarOffset;
        self.view.frame = CGRectMake(viewBounds.origin.x, topBarOffset, viewBounds.size.width, viewBounds.size.height);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (IBAction)goBack:(id)sender {
    if (followedUser) {
        [caller refreshMyPageVideos];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
