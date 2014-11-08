/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "FriendFinderViewController.h"
#import "FriendFinderCell.h"
#import "SuggestedUserCell.h"
#import "SocialFriendsViewController.h"
#import "OthersPageViewController.h"

@interface FriendFinderViewController ()
@end

@implementation FriendFinderViewController
@synthesize superVC;
@synthesize pageNumber;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad {
    TCSTART
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height - 20);
    suggestedUsersArray = [[NSMutableArray alloc] init];
    pageNumber = 1;
    searchPgNumber = 1;
    [self customizeSearchBar];
    usersSearchBar.hidden = YES;
    searchBarBg.hidden = YES;
    [self makeRequestForSuggestedUsersForFirstTime];
    
    finderTableView.backgroundColor = [UIColor whiteColor];
    finderTableView.frame = CGRectMake(finderTableView.frame.origin.x, finderTableView.frame.origin.y, finderTableView.frame.size.width, self.view.frame.size.height - ((CURRENT_DEVICE_VERSION < 7.0)?42:62));
    [finderTableView registerNib:[UINib nibWithNibName:@"FriendFinderCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"FriendFinderCellID"];
    finderTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [finderTableView registerNib:[UINib nibWithNibName:@"SuggestedUserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SuggestedUserCellID"];
    
    friendArray = [[NSArray alloc] initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"FBFinder",@"imagename",@"Facebook",@"title",@"Find your Facebook Friends",@"description", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"TWFinder",@"imagename",@"Twitter",@"title",@"Find your Twitter Friends",@"description", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"GPlusFinder",@"imagename",@"Google+",@"title",@"Find your Google+ Friends",@"description", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Contacts",@"imagename",@"Contacts",@"title",@"Find your Contacts",@"description", nil], nil];
    
    TCEND
}

- (void)makeRequestForSuggestedUsersForFirstTime {
    TCSTART
    if (pageNumber == 1) {
        [suggestedUsersArray removeAllObjects];
    }
    [appDelegate makeSuggestedUsersRequestWithUserId:appDelegate.loggedInUser.userId andCaller:self pageNum:pageNumber];
    TCEND
}

- (void)didFinishedToGetSuggestedUsers:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    if ([self isNotNull:results]) {
        [suggestedUsersArray addObjectsFromArray:[results objectForKey:@"users"]];
    }
    [finderTableView reloadData];
    TCEND
}

- (void)didFailToGetSuggestedUsersWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [finderTableView reloadData];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

- (void)setFrameForView:(CGRect)frame {
    self.view.frame = frame;
    backBtn.hidden = YES;
    bannerImgView.hidden = YES;
//    finderTableView.backgroundColor = [UIColor redColor];
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

- (IBAction)onClickOfBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark Tableview Delegate and Datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 50;
    }
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TCSTART
    if (section == 0) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        headerView.backgroundColor = [UIColor whiteColor];
        
        UILabel *labl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, 50)];
        labl.textAlignment = UITextAlignmentCenter;
        labl.font = [UIFont fontWithName:descriptionTextFontName size:18];
        labl.backgroundColor = [appDelegate colorWithHexString:@"f8f8f8"];
        labl.textColor = [UIColor blackColor];
        labl.text = @"Search Friends";
        
        [headerView addSubview:labl];
        
        return headerView;
    } else {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        headerView.backgroundColor = [UIColor whiteColor];
        
        UILabel *labl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, 40)];
        labl.textAlignment = UITextAlignmentCenter;
        labl.textColor = [UIColor blackColor];
        labl.numberOfLines = 0;
        
        if (searchSelected && suggestedUsersArray.count <= 0) {
            labl.font = [UIFont fontWithName:descriptionTextFontName size:15];
            labl.backgroundColor = [UIColor clearColor];
            labl.text = @"No search results available, Please try again with different keyword";
        } else {
            labl.font = [UIFont fontWithName:descriptionTextFontName size:16];
            labl.backgroundColor = [appDelegate colorWithHexString:@"f8f8f8"];
            labl.text = @"Suggested Users";
        }
        [headerView addSubview:labl];
        
        return headerView;
    }
    TCEND
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    TCSTART
    if (section == 0) {
        return 4;
    } else {
        if(suggestedUsersArray.count >= (searchSelected?searchPgNumber:pageNumber) * 10 && suggestedUsersArray.count > 0) {
            return suggestedUsersArray.count + 1;
        } else {
            return suggestedUsersArray.count;
        }
    }
    TCEND
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if (searchSelected && selectedUser.videos.count <= 0 && videosSearchBar.text.length > 0) {
//        return 40;
//    } else {
//        return 0;
//    }
//    
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    TCSTART
//    if (searchSelected && selectedUser.videos.count <= 0 && section == 0 && videosSearchBar.text.length > 0) {
//        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
//        UILabel *descLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
//        descLbl.font = [UIFont fontWithName:descriptionTextFontName size:15];
//        descLbl.textColor = [UIColor blackColor];
//        descLbl.backgroundColor = [UIColor clearColor];
//        descLbl.textAlignment = UITextAlignmentCenter;
//        descLbl.numberOfLines = 0;
//        descLbl.text = @"No search results available, Please try again with different keyword";
//        [headerView addSubview:descLbl];
//        return headerView;
//        //
//    }
//    
//    TCEND
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 67;
    }
	return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCSTART
    if (indexPath.section == 0) {
        static NSString * cellIdentifier = @"FriendFinderCellID";
        
        FriendFinderCell *cell = (FriendFinderCell *)[tableView_ dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil) {
            cell = [[FriendFinderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        NSDictionary *dict = [friendArray objectAtIndex:indexPath.row];
        cell.thumbImgView.image = [UIImage imageNamed:[dict objectForKey:@"imagename"]];
        cell.titleLbl.text = [dict objectForKey:@"title"];
        cell.descLbl.text = [dict objectForKey:@"description"];
        
        cell.titleLbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
        cell.dividerLbl.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
        if (indexPath.row == 3) {
            cell.dividerLbl.hidden = YES;
        } else {
            cell.dividerLbl.hidden = NO;
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        if(indexPath.row == suggestedUsersArray.count && suggestedUsersArray.count > 0) {
            UITableViewCell *indicatorCell;
            static NSString *loadMoreCellIdentifier = @"loadMoreCellIdentifier";
            UIActivityIndicatorView *activityIndicator_view = nil;
            indicatorCell = [tableView_ dequeueReusableCellWithIdentifier:loadMoreCellIdentifier];
            if(indicatorCell == nil){
                indicatorCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadMoreCellIdentifier];
                
                activityIndicator_view = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                activityIndicator_view.frame = CGRectMake((320 - 20)/2, 20, 20, 20);
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
        SuggestedUserCell *cell = (SuggestedUserCell *)[tableView_ dequeueReusableCellWithIdentifier:cellIdentifier];
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
        
//        cell.backgroundColor = [UIColor redColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.inviteBtn.hidden = YES;
        
        return cell;
        }
    }
    TCEND
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if (indexPath.section == 0) {
        NSString *reqType;
        if (indexPath.row == 0) {
            reqType = @"facebook";
        } else if (indexPath.row == 1) {
            reqType = @"twitter";
        } else if (indexPath.row == 2) {
            reqType = @"googleplus";
        } else {
            reqType = @"PhoneContacts";
        }
        
        SocialFriendsViewController *friendsVC = [[SocialFriendsViewController alloc] initWithNibName:@"SocialFriendsViewController" bundle:nil andViewType:reqType];
        if ([self isNotNull:superVC]) {
            [superVC.navigationController pushViewController:friendsVC animated:YES];
        } else {
            [self.navigationController pushViewController:friendsVC animated:YES];
        }
    } else if (indexPath.row < suggestedUsersArray.count) {
        UserModal *suggestedUser = [suggestedUsersArray objectAtIndex:indexPath.row];
        if (appDelegate.loggedInUser.userId.intValue != suggestedUser.userId.intValue) {
            OthersPageViewController *otherPageVC = [[OthersPageViewController alloc] initWithNibName:@"OthersPageViewController" bundle:Nil andUser:suggestedUser.userId];
            if ([self isNotNull:superVC]) {
                [superVC.navigationController pushViewController:otherPageVC animated:YES];
            } else {
                [self.navigationController pushViewController:otherPageVC animated:YES];
            }
        }
    }
    
    TCEND
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        if (indexPath.row == suggestedUsersArray.count && indexPath.section == 1) {
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
    if (searchSelected) {
        searchPgNumber = searchPgNumber + 1;
        [self makeSearchRequestWithSearchString:usersSearchBar.text andPageNumber:searchPgNumber requestForPagination:YES];
    } else {
        pageNumber = pageNumber + 1;
        [self makeRequestForSuggestedUsersForFirstTime];
    }
}

- (void)clickedOnFollowBtn:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:finderTableView];
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
    
    SuggestedUserCell *cell = (SuggestedUserCell *)[finderTableView cellForRowAtIndexPath:indexpath];
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
    
    
    NSInteger totalFollowings = [appDelegate.loggedInUser.totalNoOfFollowings integerValue];
    totalFollowings = totalFollowings + 1;
    appDelegate.loggedInUser.totalNoOfFollowings = [NSNumber numberWithInt:totalFollowings];
    
    SuggestedUserCell *cell = (SuggestedUserCell *)[finderTableView cellForRowAtIndexPath:indexpath];
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


#pragma mark Search
- (IBAction)onClickOfSearchBtn:(id)sender {
    TCSTART
    UIButton *searchBtn = (UIButton *)sender;
    CGFloat searchBarHeight = usersSearchBar.frame.size.height;
    searchPgNumber = 1;
    if (searchBtn.tag == 1) {
        usersArray = [suggestedUsersArray copy];
        [suggestedUsersArray removeAllObjects];
        searchBtn.tag = 123;
        searchSelected = YES;
        //Search
        [usersSearchBar becomeFirstResponder];
        searchBtn.frame = CGRectMake(250, searchBtn.frame.origin.y, 65, searchBtn.frame.size.height);
        [searchBtn setBackgroundImage:[UIImage imageNamed:@"SearchCancel"] forState:UIControlStateNormal];
        [searchBtn setBackgroundImage:[UIImage imageNamed:@"SearchCancel_f"] forState:UIControlStateHighlighted];
        [searchBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        usersSearchBar.hidden = NO;
        searchBarBg.hidden = NO;
        finderTableView.frame = CGRectMake(finderTableView.frame.origin.x, finderTableView.frame.origin.y + searchBarHeight, finderTableView.frame.size.width, finderTableView.frame.size.height - searchBarHeight);
        [finderTableView reloadData];
    } else {
        [usersSearchBar resignFirstResponder];
        searchBtn.tag = 1;
        //cancel
        searchSelected = NO;
        [suggestedUsersArray removeAllObjects];
        [suggestedUsersArray addObjectsFromArray:usersArray];
        usersSearchBar.hidden = YES;
        searchBarBg.hidden = YES;
        //        [searchDict removeAllObjects];
        usersSearchBar.text = @"";
        searchBtn.frame = CGRectMake(285, searchBtn.frame.origin.y, 30, searchBtn.frame.size.height);
        [searchBtn setBackgroundImage:[UIImage imageNamed:@"HomeSearch"] forState:UIControlStateNormal];
        [searchBtn setBackgroundImage:[UIImage imageNamed:@"HomeSearch"] forState:UIControlStateHighlighted];
        [searchBtn setTitle:@"" forState:UIControlStateNormal];
        finderTableView.frame = CGRectMake(finderTableView.frame.origin.x, finderTableView.frame.origin.y - searchBarHeight, finderTableView.frame.size.width, finderTableView.frame.size.height + searchBarHeight);
        [finderTableView reloadData];
    }
    //    [self refreshTableViewWithSelectedBrowseTypePage:(searchSelected?[NSString stringWithFormat:@"%@SearchPgNum",browseType]:[NSString stringWithFormat:@"%@BrowsePgNum",browseType])];
    TCEND
}

- (void)customizeSearchBar {
    @try {
        usersSearchBar.placeholder = @"Search";
        usersSearchBar.keyboardType = UIKeyboardTypeDefault;
        usersSearchBar.barStyle = UIBarStyleDefault;
        usersSearchBar.delegate = self;
        
        [self setBackgroundForSearchBar:usersSearchBar withImagePath:@"SearchBarBg"];
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)setBackgroundForSearchBar:(UISearchBar *)searchbar withImagePath:(NSString *)imgPath {
    
    @try {
        //set the searchbar textfield to image view.
        UITextField *searchField;
        NSArray *searchSubViews;
        if (CURRENT_DEVICE_VERSION < 7.0) {
            searchSubViews = searchbar.subviews;
        } else {
            searchSubViews = [[searchbar.subviews objectAtIndex:0] subviews];
        }
        for(int i = 0; i < searchSubViews.count; i++) {
            if([[searchSubViews objectAtIndex:i] isKindOfClass:[UITextField class]]) { //conform?
                searchField = [searchSubViews objectAtIndex:i];
                searchField.returnKeyType = UIReturnKeySearch;
            }
        }
        if(!(searchField == nil)) {
            searchField.textColor = [UIColor blackColor];
            [searchField setBackground: [UIImage imageNamed:imgPath]];
            
            [searchField setBorderStyle:UITextBorderStyleNone];
            searchField.enablesReturnKeyAutomatically = YES;
        }
        //remove the search bar background view.
        for (int i = 0; i < searchSubViews.count; i++) {
            if ([[searchSubViews objectAtIndex:i] isKindOfClass:NSClassFromString
                 (@"UISearchBarBackground")]) {
                [[searchSubViews objectAtIndex:i]removeFromSuperview];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

#pragma mark
#pragma searchBarDelegate Methods
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    @try {
        //        if (searchBar.tag == -10) {
        //            categorySearchPhrase = searchText;
        //        } else if (searchBar.tag == 10) {
        //            locationSearchPhrase = searchText;
        //        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    @try {
        [self makeSearchRequestWithSearchString:searchBar.text andPageNumber:1 requestForPagination:NO];
        [searchBar resignFirstResponder];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

#pragma mark
#pragma mark Search
- (void)makeSearchRequestWithSearchString:(NSString *)searchString  andPageNumber:(NSInteger)pageNumber_ requestForPagination:(BOOL)requestForPagination {
    TCSTART
    if (searchString.length > 0) {
        searchString = [appDelegate removingLastSpecialCharecter:searchString];
    }
    if (searchString.length > 0) {
        [appDelegate makeRequestForBrowseSearchWithString:searchString ofBrowseType:@"people" pageNumber:pageNumber_ perPage:10 andCaller:self];
        if (!requestForPagination) {
            [suggestedUsersArray removeAllObjects];
            [appDelegate showActivityIndicatorInView:self.view andText:@""];
        }
        [appDelegate showNetworkIndicator];
    } else {
        [ShowAlert showWarning:@"Please enter search keyword"];
    }
    
    TCEND
}

- (void)didFinishedToGetSearchDetails:(NSDictionary *)results {
    TCSTART
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"results"]]) {
        if ([[results objectForKey:@"browseType"] caseInsensitiveCompare:@"people"] == NSOrderedSame) {
            NSMutableArray *array = [[NSMutableArray alloc] initWithArray:suggestedUsersArray];
            [array addObjectsFromArray:[results objectForKey:@"results"]];
            suggestedUsersArray = array;
        }
    }
    [finderTableView reloadData];
    [appDelegate removeNetworkIndicatorInView:self.view];
    [appDelegate hideNetworkIndicator];
    [finderTableView reloadData];
    TCEND
}

- (void)didFailToGetSearchDetailsWithError:(NSDictionary *)errorDict {
    TCSTART
     searchPgNumber = searchPgNumber - 1;
    [finderTableView reloadData];
    [appDelegate removeNetworkIndicatorInView:self.view];
    [appDelegate hideNetworkIndicator];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
