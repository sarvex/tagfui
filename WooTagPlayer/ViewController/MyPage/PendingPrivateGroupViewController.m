/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "PendingPrivateGroupViewController.h"
#import "CommentUserCell.h"

@interface PendingPrivateGroupViewController ()

@end

@implementation PendingPrivateGroupViewController
@synthesize allCmntsVC;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(UserModal *)selectedUser_
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        selectedUser = selectedUser_;
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad
{
    TCSTART
    [super viewDidLoad];
    [friendsTableView registerNib:[UINib nibWithNibName:@"CommentUserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CommentUserCellID"];
    pageNumber = 1;
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height - 20);
    titleLabel.backgroundColor = [appDelegate colorWithHexString:@"fafafa"];
    
    friendsArray = [[NSMutableArray alloc] init];
    count = [selectedUser.totalNoOfPeningPrivateUsers integerValue];
    titleLabel.text = [NSString stringWithFormat:@"%d Friend Request%@",count,[appDelegate returningPluralFormWithCount:count]];
    
    [self makeRequestForListOfPendingPrivateUsers:NO];
    friendsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)onClickOfBackButton:(id)sender {
    TCSTART
    [allCmntsVC refreshScreen];
    [self.navigationController popViewControllerAnimated:YES];
    TCEND
}

- (void)makeRequestForListOfPendingPrivateUsers:(BOOL)pagination {
    TCSTART
    if ([self isNotNull:selectedUser.userId]) {
        [appDelegate showNetworkIndicator];
        if (!pagination) {
    
        }
        [appDelegate makeRequestForPendingPrivateUsersWithUserId:selectedUser.userId pageNumber:pageNumber andCaller:self];
    }
    TCEND
}
- (void)didFinishedToGetPrivateUsers:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"isResponseNull"]] && ![[results objectForKey:@"isResponseNull"] boolValue]) {
        if (pageNumber == 1) {
            friendsArray = [results objectForKey:@"pvtgroup"];
        } else {
            [friendsArray addObjectsFromArray:[results objectForKey:@"pvtgroup"]];
        }
        if (count < friendsArray.count) {
            count = friendsArray.count;
            titleLabel.text = [NSString stringWithFormat:@"%d Friend Request%@",count,[appDelegate returningPluralFormWithCount:count]];
            selectedUser.totalNoOfPeningPrivateUsers = [NSNumber numberWithInt:count];
        }
    }
    [friendsTableView reloadData];
    TCEND
}
- (void)didFailToGetPrivateUsersWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    [friendsTableView reloadData];
    TCEND
}

#pragma mark tableview datasource and Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(friendsArray.count >= pageNumber * 10 && friendsArray.count > 0) {
        return friendsArray.count + 1;
    } else {
        return friendsArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCSTART
    if (indexPath.row == friendsArray.count) {
        return 40;
    } else {
        return 50;
    }
    TCEND
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        if(indexPath.row == friendsArray.count) {
            UITableViewCell *indicatorCell;
            static NSString *loadMoreCellIdentifier = @"loadMoreCellIdentifier";
            UIActivityIndicatorView *activityIndicator_view = nil;
            indicatorCell = [tableView dequeueReusableCellWithIdentifier:loadMoreCellIdentifier];
            if(indicatorCell == nil){
                indicatorCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadMoreCellIdentifier];
                
                activityIndicator_view = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                activityIndicator_view.frame = CGRectMake(300/2, 10, 20, 20);
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
            
            //static NSString *user_messageCell = @"messageCell";
            static NSString *CellIndentifier = @"CommentUserCellID";
            
            CGFloat rowHeight = 50;
            
            CommentUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
            //initialize cell and its subviews instances once and use them when table scrolling through their instances retrieved based on "Tag" value
            if (cell == nil) {
                cell = [[CommentUserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIndentifier];
            }
            cell.commentTextLbl.hidden = YES;
            cell.userPicImgView.layer.cornerRadius = 20.0f;
            cell.userPicImgView.layer.borderWidth = 1.5f;
            cell.userPicImgView.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
            cell.userPicImgView.layer.masksToBounds = YES;
            
            cell.userNameLbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
            
            cell.cellDividerLbl.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
            
            cell.commentTextLbl.textColor = [UIColor darkGrayColor];
            
            NSDictionary *userDict = [friendsArray objectAtIndex:indexPath.row];
            
            
            if ([self isNotNull:[userDict objectForKey:@"user_id"]] && [[userDict objectForKey:@"user_id"] intValue] != selectedUser.userId.intValue) {
                cell.userNameLbl.frame = CGRectMake(50, 4, 194, rowHeight - 8);
                cell.addUserBtn.hidden = NO;
                [cell.addUserBtn addTarget:self action:@selector(acceptPrivateUserRequest: withEvent:) forControlEvents:UIControlEventTouchUpInside];
                [cell.deleteUserBtn addTarget:self action:@selector(makeUnPrivateRequest: withEvent:) forControlEvents:UIControlEventTouchUpInside];
            } else {
                cell.addUserBtn.hidden = YES;
                cell.userNameLbl.frame = CGRectMake(50, 4, 265, rowHeight - 8);
            }
            
            //check if Like data for a row is not null
            if ([self isNotNull:userDict]) {
//                user_name
                
                if ([self isNotNull:[userDict objectForKey:@"user_photo"]]) {
                    [cell.userPicImgView setImageWithURL:[NSURL URLWithString:[userDict objectForKey:@"user_photo"]] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached];
                }  else {
                    cell.userPicImgView.image = [UIImage imageNamed:@"OwnerPic"];
                }
                
                //Display the name of user
                if ([self isNotNull:[userDict objectForKey:@"user_name"]]) {
                    cell.userNameLbl.text = [userDict objectForKey:@"user_name"];
                } else {
                    cell.userNameLbl.text = @"";
                }
            
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
            return cell;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        if (indexPath.row == friendsArray.count) {
            [self performSelector:@selector(loadMoreRequest) withObject:nil afterDelay:0.001];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
//    if (indexPath.row < friendsArray.count) {
//        NSDictionary *commentDict = [fr objectAtIndex:indexPath.row];
//        if ([self isNotNull:[commentDict objectForKey:@"user_id"]] && [[commentDict objectForKey:@"user_id"] intValue] != [appDelegate.loggedInUser.userId intValue]) {
//            OthersPageViewController *otherPageVC = [[OthersPageViewController alloc] initWithNibName:@"OthersPageViewController" bundle:Nil andUser:[NSString stringWithFormat:@"%d",[[commentDict objectForKey:@"user_id"] intValue]]];
//            [self.navigationController pushViewController:otherPageVC animated:YES];
//            otherPageVC.caller = self;
//            otherPageVC.selectedIndexPath = indexPath;
//        }
//    }
    TCEND
}
- (void)loadMoreRequest {
    pageNumber = pageNumber + 1;
    [self makeRequestForListOfPendingPrivateUsers:YES];
}
#pragma mark Accept Private group request
- (void)acceptPrivateUserRequest:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:friendsTableView];
   NSDictionary *userDict = [friendsArray objectAtIndex:indexPath.row];
    if ([self isNotNull:[userDict objectForKey:@"user_id"]]) {
        [appDelegate makeAcceptPrivateUserWithUserId:selectedUser.userId privateUserId:[userDict objectForKey:@"user_id"] andCaller:self andIndexPath:indexPath];
        [appDelegate showActivityIndicatorInView:friendsTableView andText:@"Accepting"];
        [appDelegate showNetworkIndicator];
    }
    TCEND
}
- (void)didFinishedToAcceptPrivateUser:(NSDictionary *)results {
    TCSTART
    [appDelegate removeNetworkIndicatorInView:friendsTableView];
    [appDelegate hideNetworkIndicator];
    NSIndexPath *indexPath = [results objectForKey:@"indexpath"];
    [friendsArray removeObjectAtIndex:indexPath.row];
    [friendsTableView reloadData];
    [self calculatePendingPrivateUserList];
    TCEND
}
- (void)didFailToAcceptPrivateUserWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate removeNetworkIndicatorInView:friendsTableView];
    [appDelegate hideNetworkIndicator];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

#pragma mark unprivate
- (void)makeUnPrivateRequest:(id)sender withEvent:(UIEvent *)event {
    TCSTART
     NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:friendsTableView];
    NSDictionary *userDict = [friendsArray objectAtIndex:indexPath.row];
    if ([self isNotNull:[userDict objectForKey:@"user_id"]]) {
        [appDelegate showActivityIndicatorInView:friendsTableView andText:@"Reject"];
        [appDelegate makeUnPrivateUserWithUserId:appDelegate.loggedInUser.userId privateUserId:[userDict objectForKey:@"user_id"] andCaller:self andIndexPath:indexPath];
    }
    TCEND
}

- (void)didFinishedToUnPrivateUser:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:friendsTableView];

    NSIndexPath *indexPath = [results objectForKey:@"indexpath"];
    [friendsArray removeObjectAtIndex:indexPath.row];
    [friendsTableView reloadData];
    
    [self calculatePendingPrivateUserList];
    TCEND
}

- (void)didFailToUnPrivateUserWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:friendsTableView];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

- (void)calculatePendingPrivateUserList {
    TCSTART
    NSInteger totalPendingPrivateUsers = [selectedUser.totalNoOfPeningPrivateUsers integerValue];

    if (totalPendingPrivateUsers > 0) {
        totalPendingPrivateUsers = totalPendingPrivateUsers - 1;
    }
    selectedUser.totalNoOfPeningPrivateUsers = [NSNumber numberWithInt:totalPendingPrivateUsers];
    if (count > 0) {
        count = count - 1;
    }
   titleLabel.text = [NSString stringWithFormat:@"%d Friend Request%@",count,[appDelegate returningPluralFormWithCount:count]];
    TCEND
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
