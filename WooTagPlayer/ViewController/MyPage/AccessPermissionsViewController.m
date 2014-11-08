/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "AccessPermissionsViewController.h"

@interface AccessPermissionsViewController ()

@end

@implementation AccessPermissionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withSelectedVideo:(VideoModal *)video andCaller:(id)caller_
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        selectedVideo = video;
        caller = caller_;
    }
    return self;
}

- (void)viewDidLoad {
    TCSTART
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height - 20);
    
    accessDetailsArray = [[NSMutableArray alloc] initWithObjects:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Public",@"title",@"everywhere",@"description",[NSNumber numberWithBool:YES],@"selectionType", nil],[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Only Followers",@"title",@"followers video feeds",@"description",[NSNumber numberWithBool:YES],@"selectionType", nil],[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Only Private Group",@"title",@"private feeds",@"description",[NSNumber numberWithBool:NO],@"selectionType", nil], nil];
    sharingType = [selectedVideo.public integerValue];
    
    [self changeValuesInAccessArrayWithSharingType:[selectedVideo.public intValue]];
    if ([accessTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        //        shareTableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
        [accessTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    accessTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, accessTableView.bounds.size.width, 0.01f)];
    accessTableView.separatorColor = [appDelegate colorWithHexString:@"11a3e7"];
    accessTableView.backgroundColor = [UIColor clearColor];
    [videoThumbImgView setImageWithURL:[NSURL URLWithString:selectedVideo.videoThumbPath] placeholderImage:[UIImage imageNamed:@"DefaultVideoThumb"]];
    
    UIView *tablefooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake((320-80)/2, 5, 80, 35);
    [doneButton setBackgroundImage:[UIImage imageNamed:@"SocialNameBtn"] forState:UIControlStateNormal];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    doneButton.titleLabel.font = [UIFont fontWithName:titleFontName size:12];
    [tablefooterView addSubview:doneButton];
    [doneButton addTarget:self action:@selector(changePermissions) forControlEvents:UIControlEventTouchUpInside];
    accessTableView.tableFooterView = tablefooterView;
    
    TCEND
}

- (void)changePermissions {
    TCSTART
    if (sharingType != [selectedVideo.public integerValue] && [self isNotNull:selectedVideo.videoId]) {
        [appDelegate showNetworkIndicator];
        [appDelegate showActivityIndicatorInView:accessTableView andText:@"Changing"];
        [appDelegate makeRequestVideoPermissionsChangeVideoId:selectedVideo.videoId permission:sharingType andCaller:self];
    }
    TCEND
}

- (void)didFinishedChangeVideoAccessPermission:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:accessTableView];
    selectedVideo.public = [NSNumber numberWithInt:sharingType];
    TCEND
}

- (void)didFailedToChangeVideoAccessPermissionWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:accessTableView];
    sharingType = [selectedVideo.public intValue];
    [self changeValuesInAccessArrayWithSharingType:sharingType];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

//For status bar in ios7
- (void) viewDidLayoutSubviews {
    if (CURRENT_DEVICE_VERSION >= 7.0 && self.view.frame.size.height == appDelegate.window.frame.size.height) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.size.height = viewBounds.size.height - topBarOffset;
        self.view.frame = CGRectMake(viewBounds.origin.x, topBarOffset, viewBounds.size.width, viewBounds.size.height);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (IBAction)goBack:(id)sender {
    TCSTART
    [self.navigationController popViewControllerAnimated:YES];
    TCEND
}


#pragma mark Tableview Delegate and Datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return accessDetailsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25; //25
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIImageView *headerBannerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    headerBannerImgView.image = [UIImage imageNamed:@"ShareTitleBanner"];
    
    //    UILabel *backgorundLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
    //    backgorundLabel.backgroundColor = [appDelegate colorWithHexString:@"01739b"];
    
    UILabel *shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 25)];
    shareLabel.backgroundColor = [UIColor clearColor];
    shareLabel.textColor = [UIColor whiteColor];
    shareLabel.font = [UIFont fontWithName:descriptionTextFontName size:13];
    shareLabel.text = @"Video viewed by";
    [headerView addSubview:headerBannerImgView];
    [headerView addSubview:shareLabel];
    
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"shareCellId";

    UILabel *titleLabel = nil;
    UILabel *descLbl = nil;
    UICustomSwitch *connectSwitch = nil;
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 150, 40)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [appDelegate colorWithHexString:@"11a3e7"];
        titleLabel.tag = 1;
        titleLabel.font = [UIFont fontWithName:titleFontName size:14];
        [cell addSubview:titleLabel];
        
        descLbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 45, 150, 10)];
        descLbl.backgroundColor = [UIColor clearColor];
        descLbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
        descLbl.font = [UIFont fontWithName:titleFontName size:11];
        descLbl.tag = 2;
        [cell addSubview:descLbl];
        
        CGRect connectSwitchRect = CGRectMake(200, 16, 52, 33);
        connectSwitch = [UICustomSwitch switchWithLeftText:@"" andRight:@""];
        connectSwitch.frame = connectSwitchRect;
        [connectSwitch setThumbImage:[UIImage imageNamed:@"ToggleThumb" ] forState:UIControlStateNormal];
        [connectSwitch setMinimumTrackImage:[[UIImage imageNamed:@"ToggleOn"]resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)] forState:UIControlStateNormal];
        [connectSwitch setMaximumTrackImage:[[UIImage imageNamed:@"ToggleOff"]resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)] forState:UIControlStateNormal];
        connectSwitch.tag = 3;
        [connectSwitch addTarget:self action:@selector(videoAccessPermissionByChangingSwitches: withEvent:) forControlEvents:UIControlEventValueChanged];
        [cell addSubview:connectSwitch];
        
    }
    
    if ([self isNull:titleLabel]) {
        titleLabel = (UILabel *)[cell viewWithTag:1];
    }
    
    if ([self isNull:descLbl]) {
        descLbl = (UILabel *)[cell viewWithTag:2];
    }
    
    if ([self isNull:connectSwitch]) {
        connectSwitch = (UICustomSwitch *)[cell viewWithTag:3];
    }
    
    NSDictionary *dict = [accessDetailsArray objectAtIndex:indexPath.row];
    titleLabel.text = [dict objectForKey:@"title"];
    descLbl.text = [dict objectForKey:@"description"];
    if ([[dict objectForKey:@"selectionType"] boolValue]) {
        connectSwitch.on = YES;
    } else {
        connectSwitch.on = NO;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    
    TCEND
}


- (void)videoAccessPermissionByChangingSwitches:(id)sender withEvent:(UIEvent *)event {
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:accessTableView];
    UICustomSwitch *customSwt = (UICustomSwitch *)sender;
    if (indexPath.row == 0) {
        //Public
        if (customSwt.on) {
            [self changeValuesInAccessArrayWithSharingType:1];
        } else {
            [self changeValuesInAccessArrayWithSharingType:0];
        }
        
    } else if (indexPath.row == 1) {
        //Follower
        if (customSwt.on) {
            [self changeValuesInAccessArrayWithSharingType:2];
        } else {
            [self changeValuesInAccessArrayWithSharingType:0];
        }
    } else {
        //Private
        if (customSwt.on) {
            [self changeValuesInAccessArrayWithSharingType:0];
        } else {
            [self changeValuesInAccessArrayWithSharingType:1];
        }
    }
}

- (void)changeValuesInAccessArrayWithSharingType:(int)type {
    TCSTART
    sharingType = type;
    if (type == 0) {
        //Private
        for (int i = 0; i < accessDetailsArray.count; i ++) {
            NSMutableDictionary *dict = [accessDetailsArray objectAtIndex:i];
            if (i == 0 || i == 1) {
                // public && // follower
                [dict setObject:[NSNumber numberWithBool:NO] forKey:@"selectionType"];
            } else {
                //private
                [dict setObject:[NSNumber numberWithBool:YES] forKey:@"selectionType"];
            }
        }
    } else if (type == 1) {
        // public
        for (int i = 0; i < accessDetailsArray.count; i ++) {
            NSMutableDictionary *dict = [accessDetailsArray objectAtIndex:i];
            if (i == 0 || i == 1) {
                // public && // follower
                [dict setObject:[NSNumber numberWithBool:YES] forKey:@"selectionType"];
            } else {
                //private
                [dict setObject:[NSNumber numberWithBool:NO] forKey:@"selectionType"];
            }
        }
    } else {
        //follower
        for (int i = 0; i < accessDetailsArray.count; i ++) {
            NSMutableDictionary *dict = [accessDetailsArray objectAtIndex:i];
            if (i == 0 || i == 2) {
                // public && // Private
                [dict setObject:[NSNumber numberWithBool:NO] forKey:@"selectionType"];
            } else {
                //follower
                [dict setObject:[NSNumber numberWithBool:YES] forKey:@"selectionType"];
            }
        }
    }
    [accessTableView reloadData];
    TCEND
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark for ios 6 orientation support
- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
    
}

@end
