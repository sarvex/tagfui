//
//  FollowersViewController.h
//  WooTagPlayer
//
//  Created by Aruna on 26/09/13.
//  Copyright (c) 2013 Ayansys Solutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "WooTagPlayerAppDelegate.h"
#import "UserService.h"

@interface FollowersViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UserServiceDelegate> {
    IBOutlet UITableView *followersTableView;
    User *user;
    WooTagPlayerAppDelegate *appDelegate;
    NSString *type;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUser:(User *)selectedUser andSelectedType:(NSString *)selectedType;

- (IBAction)goBack:(id)sender;
@end
