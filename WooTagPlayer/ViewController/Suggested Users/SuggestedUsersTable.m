/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "SuggestedUsersTable.h"
#import "SuggestedUserCell.h"
#import "OthersPageViewController.h"

@implementation SuggestedUsersTable
@synthesize caller;
@synthesize userId;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        [self registerNib:[UINib nibWithNibName:@"SuggestedUserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SuggestedUserCellID"];
        self.separatorColor = [appDelegate colorWithHexString:@"11a3e7"];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}

- (void)displaySuggestedUsersInView {
    suggestedUsersArray = [[NSMutableArray alloc] init];
    pageNumber = 1;
    [self makeRequestForSuggestedUsers:NO];
}

- (void)makeRequestForSuggestedUsers:(BOOL)pagination {
    TCSTART
    if ([self isNotNull:userId]) {
        [appDelegate makeSuggestedUsersRequestWithUserId:userId andCaller:self pageNum:pageNumber];
        if (!pagination) {
            [appDelegate showActivityIndicatorInView:self andText:@""];
        }
        [appDelegate showNetworkIndicator];
    }
    TCEND
}

- (void)didFinishedToGetSuggestedUsers:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:self];
    if ([self isNotNull:results]) {
        [suggestedUsersArray addObjectsFromArray:[results objectForKey:@"users"]];
        
    }
    [self reloadData];
    TCEND
}
- (void)didFailToGetSuggestedUsersWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:self];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    [self reloadData];
    TCEND
}

#pragma mark Tableview Delegate and Datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(suggestedUsersArray.count >= pageNumber * 10 && suggestedUsersArray.count > 0) {
        return suggestedUsersArray.count + 1;
    } else {
        return suggestedUsersArray.count;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == suggestedUsersArray.count) {
        return 40;
    }
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if(indexPath.row == suggestedUsersArray.count) {
        UITableViewCell *indicatorCell;
        static NSString *loadMoreCellIdentifier = @"loadMoreCellIdentifier";
        UIActivityIndicatorView *activityIndicator_view = nil;
        indicatorCell = [tableView dequeueReusableCellWithIdentifier:loadMoreCellIdentifier];
        if(indicatorCell == nil){
            indicatorCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadMoreCellIdentifier];
            
            activityIndicator_view = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityIndicator_view.frame = CGRectMake((320 - 20)/2, 10, 20, 20);
            [indicatorCell.contentView addSubview:activityIndicator_view];
            activityIndicator_view.tag = -7000;
            
        }
        if (!activityIndicator_view) {
            activityIndicator_view = (UIActivityIndicatorView *)[indicatorCell.contentView viewWithTag:-7000];
        }
        [activityIndicator_view startAnimating];
        indicatorCell.backgroundColor = [UIColor clearColor];
        return indicatorCell;
    } else {
        static NSString *cellIdentifier = @"SuggestedUserCellID";
        SuggestedUserCell *cell = (SuggestedUserCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil) {
            cell = [[SuggestedUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        UserModal *user = [suggestedUsersArray objectAtIndex:indexPath.row];
        if ([self isNotNull:user.photoPath]) {
            [cell.userProfileImgView setImageWithURL:[NSURL URLWithString:user.photoPath] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached];
        } else {
            [cell.userProfileImgView setImage:[UIImage imageNamed:@"OwnerPic"]];
        }
        cell.userProfileImgView.layer.cornerRadius = 22.5f;
        cell.userProfileImgView.layer.borderWidth = 1.5f;
        cell.userProfileImgView.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
        cell.userProfileImgView.layer.masksToBounds = YES;
        
        if ([self isNotNull:user.userName]) {
            cell.userNameLbl.text = user.userName;
        } else {
            cell.userNameLbl.text = @"";
        }
        cell.userNameLbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
        
        if ([self isNotNull:user.userDesc]) {
            cell.descLbl.text = user.userDesc;
            cell.userNameLbl.frame = CGRectMake(70, 9, 200, 21);
        } else {
            cell.descLbl.text = @"";
            cell.userNameLbl.frame = CGRectMake(70, 10, 200, 40);
        }
        
        if (!user.youFollowing) {
            [cell.addBtn setBackgroundImage:[UIImage imageNamed:@"AddSuggestedUser"] forState:UIControlStateNormal];
            [cell.addBtn setBackgroundColor:[UIColor clearColor]];
            //            cell.addBtn.hidden = NO;
        } else {
            //            cell.addBtn.hidden = YES;
            [cell.addBtn setBackgroundImage:[UIImage imageNamed:@"UnfollowSuggestedUser"] forState:UIControlStateNormal];
            
        }
        [cell.addBtn addTarget:self action:@selector(clickedOnFollowBtn:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.inviteBtn.hidden = YES;
        
        return cell;
    }
    
    TCEND
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        if (indexPath.row == suggestedUsersArray.count) {
            [self performSelector:@selector(loadMoreSuggestedUsers) withObject:nil afterDelay:0.001];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)loadMoreSuggestedUsers {
    pageNumber = pageNumber + 1;
    [self makeRequestForSuggestedUsers:YES];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if (suggestedUsersArray.count > indexPath.row) {
        UserModal *user = [suggestedUsersArray objectAtIndex:indexPath.row];
    
        OthersPageViewController *otherPageVC = [[OthersPageViewController alloc] initWithNibName:@"OthersPageViewController" bundle:Nil andUser:user.userId];
        [caller.navigationController pushViewController:otherPageVC animated:YES];
        otherPageVC.caller = self;
    }
    
    TCEND
}

- (void)clickedOnFollowBtn:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:self];
    UserModal *selectedUser = [suggestedUsersArray objectAtIndex:indexPath.row];
    if (selectedUser.youFollowing) {
        [appDelegate makeUnFollowUserWithUserId:appDelegate.loggedInUser.userId followerId:selectedUser.userId andCaller:self andIndexPath:indexPath];
    } else {
        [appDelegate makeFollowUserWithUserId:appDelegate.loggedInUser.userId followerId:selectedUser.userId andCaller:self andIndexPath:indexPath];
    }
    TCEND
}

- (void)didFinishedToUnFollowUser:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
//    [ShowAlert showAlert:@"Unfollowed successfully"];
    NSIndexPath *indexpath = [results objectForKey:@"indexpath"];
    UserModal *selectedUser = [suggestedUsersArray objectAtIndex:indexpath.row];
    selectedUser.youFollowing = NO;
    
    NSInteger totalFollowings = [appDelegate.loggedInUser.totalNoOfFollowings integerValue];
    totalFollowings = totalFollowings - 1;
    appDelegate.loggedInUser.totalNoOfFollowings = [NSNumber numberWithInt:totalFollowings];
    
    SuggestedUserCell *cell = (SuggestedUserCell *)[self cellForRowAtIndexPath:indexpath];
    [cell.addBtn setBackgroundImage:[UIImage imageNamed:@"AddSuggestedUser"] forState:UIControlStateNormal];
    TCEND
}

- (void)didFailToUnFollowUserWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

- (void)didFinishedToFollowUser:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
//    [ShowAlert showAlert:@"Followed successfully"];
    
    NSIndexPath *indexpath = [results objectForKey:@"indexpath"];
    UserModal *selectedUser = [suggestedUsersArray objectAtIndex:indexpath.row];
    selectedUser.youFollowing = YES;
    
    if (indexpath.row < 3) {
        caller.followedUser = YES;
    }
    
    NSInteger totalFollowings = [appDelegate.loggedInUser.totalNoOfFollowings integerValue];
    totalFollowings = totalFollowings + 1;
    appDelegate.loggedInUser.totalNoOfFollowings = [NSNumber numberWithInt:totalFollowings];
    
    SuggestedUserCell *cell = (SuggestedUserCell *)[self cellForRowAtIndexPath:indexpath];
    [cell.addBtn setBackgroundImage:[UIImage imageNamed:@"UnfollowSuggestedUser"] forState:UIControlStateNormal];
    
    TCEND
}
- (void)didFailToFollowUserWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

@end
