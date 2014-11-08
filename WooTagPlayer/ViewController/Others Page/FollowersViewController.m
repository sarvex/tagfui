//
//  FollowersViewController.m
//  WooTagPlayer
//
//  Created by Aruna on 26/09/13.
//  Copyright (c) 2013 Ayansys Solutions Pvt. Ltd. All rights reserved.
//

#import "FollowersViewController.h"
#import "OthersPageViewController.h"
@interface FollowersViewController ()

@end

@implementation FollowersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUser:(User *)selectedUser andSelectedType:(NSString *)selectedType
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        user = selectedUser;
        type = selectedType;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([followersTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [followersTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    followersTableView.separatorColor = [appDelegate colorWithHexString:@"c7edf8"];
    // Do any additional setup after loading the view from its nib.
}

//For status bar in ios7
- (void) viewDidLayoutSubviews {
    if (CURRENT_DEVICE_VERSION >= 7.0) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.size.height = viewBounds.size.height - topBarOffset;
        self.view.frame = CGRectMake(viewBounds.origin.x, topBarOffset, viewBounds.size.width, viewBounds.size.height);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([type caseInsensitiveCompare:@"Followers"] == NSOrderedSame) {
        return [user.followers count];
    } else {
        return [user.followings count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == NULL) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.imageView.layer.cornerRadius = 5.0f;
        cell.imageView.layer.masksToBounds = YES;
    }
    NSDictionary *friend;
    if ([type caseInsensitiveCompare:@"Followers"] == NSOrderedSame) {
        friend = [user.followers objectAtIndex:indexPath.section];
    } else {
        friend = [user.followings objectAtIndex:indexPath.section];
    }
    
    if ([self isNotNull:[friend objectForKey:@"user_photo"]]) {
        [cell.imageView setImageWithURL:[NSURL URLWithString:[friend objectForKey:@"user_photo"]] placeholderImage:[UIImage imageNamed:@"OwnerPic"]]; //profile image
    } else {
        cell.imageView.image = [UIImage imageNamed:@"OwnerPic"];
    }
    
    cell.textLabel.text = [friend objectForKey:@"user_name"];//display name
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
//    NSDictionary *friend;
//    if ([type caseInsensitiveCompare:@"Followers"] == NSOrderedSame) {
//        friend = [user.followers objectAtIndex:indexPath.section];
//    } else {
//        friend = [user.followings objectAtIndex:indexPath.section];
//    }
//    [self requestForFriendsPage:[friend objectForKey:@"user_id"]];

    TCEND
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
