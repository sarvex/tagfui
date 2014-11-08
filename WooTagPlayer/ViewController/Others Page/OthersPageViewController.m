/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "OthersPageViewController.h"
#import "MyPageVideoCell.h"
#import "BrowseViewController.h"
#import "ShareViewController.h"
#import "ReportVideoViewController.h"

@interface OthersPageViewController () {
    CustomMoviePlayerViewController *customMoviePlayerVC;
}

@end

@implementation OthersPageViewController
@synthesize selectedIndexPath;
@synthesize caller;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUser:(NSString *)selectedUserId
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        userId = selectedUserId;
    }
    return self;
}

- (void)viewDidLoad {
    TCSTART
    [super viewDidLoad];
    [self customizeSearchBar];
    
    searchPgNumber = 1;
    pageNumber = 1;
    
    [videosTableView registerNib:[UINib nibWithNibName:@"MyPageVideoCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MyPageVideoCellID"];
    videosTableView.tableHeaderView = bannerView;
    videosTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    videosTableView.separatorColor = [appDelegate colorWithHexString:@"11a3e7"];
    
    if ([videosTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [videosTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    searchBarBg.hidden = YES;
    videosSearchBar.hidden = YES;
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height - 20);
    [self reloadUserData];
    [self requestForOtherUserPageRequestForPagination:NO andRequestForRefresh:NO];
    
    refreshView = [[RefreshView alloc] initWithFrame:
                   CGRectMake(videosTableView.frame.origin.x,- videosTableView.bounds.size.height,
                              videosTableView.frame.size.width, videosTableView.bounds.size.height)];
    [videosTableView addSubview:refreshView];

    TCEND
}


//For status bar in ios7
- (void) viewDidLayoutSubviews {
    if (CURRENT_DEVICE_VERSION >= 7.0  && self.view.frame.size.height == appDelegate.window.frame.size.height) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.size.height = viewBounds.size.height - topBarOffset;
        self.view.frame = CGRectMake(viewBounds.origin.x, topBarOffset, viewBounds.size.width, viewBounds.size.height);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)goBack:(id)sender {
    TCSTART
    //    [appDelegate deleteUserManagedObject:user];
    if ([caller isKindOfClass:[CustomMoviePlayerViewController class]]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        if ([caller isKindOfClass:[VideoFeedAndMoreVideosViewController class]]) {
            [caller setBoolValueForControllerVariable];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    TCEND
}

- (void)viewWillAppear:(BOOL)animated {
    TCSTART
    [super viewWillAppear:YES];
    TCEND
}

- (void)reloadUserData {
    TCSTART
    [self checkForPageControl];
    [self setValuesToAllObjectsInBannerView];
    [self moveLoggedInUserToFirstIndexOfVideoList];
    TCEND
}

- (void)checkForPageControl {
    TCSTART
    if ([self isNotNull:selectedUser.bio]) {
        [pageControl setNumberOfPages:2];
        [headerScrollView setContentSize:CGSizeMake(640, headerScrollView.frame.size.height)];
        pageControl.hidden = NO;
    } else {
        [headerScrollView setContentSize:CGSizeMake(321, headerScrollView.frame.size.height)];
        [pageControl setNumberOfPages:1];
        pageControl.hidden = YES;
    }
    TCEND
}

- (IBAction)onClickOfUserPicButton {
    TCSTART
    fullProfilePicVC = [[FullProfilePicViewController alloc] initWithNibName:@"FullProfilePicViewController" bundle:nil withImageUrlStr:[appDelegate getUserFullImageURLbyPhotoPath:selectedUser.photoPath] andCaller:self];
    fullProfilePicVC.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height - 20);
    [appDelegate.window addSubview:fullProfilePicVC.view];
    TCEND
}
- (void)removeFullProfilePicVC {
    if ([self isNotNull:fullProfilePicVC]) {
        [fullProfilePicVC.view removeFromSuperview];
        fullProfilePicVC = nil;
    }
}

#pragma mark Request for Mypage
- (void)requestForOtherUserPageRequestForPagination:(BOOL)isPagination andRequestForRefresh:(BOOL)refresh {
    TCSTART
    if ([self isNotNull:userId]) {
        [appDelegate makeOtherUserRequestWithOtherUserId:userId pageNumber:pageNumber andCaller:self];
        [appDelegate showNetworkIndicator];
        if (!isPagination && !refresh) {
            [appDelegate showActivityIndicatorInView:videosTableView andText:@""];
        }
    }
    TCEND
}

- (void)didFinishedToGetMypageDetails:(NSDictionary *)results {
    TCSTART
    [appDelegate removeNetworkIndicatorInView:videosTableView];
    [appDelegate hideNetworkIndicator];
    [self dataSourceDidFinishLoadingNewData];
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"isResponseNull"]] && ![[results objectForKey:@"isResponseNull"] boolValue]) {
        if (pageNumber > 1 && [self isNotNull:[results objectForKey:@"videos"]]) {
            NSMutableArray *array = [selectedUser.videos mutableCopy];
            [array addObjectsFromArray:[results objectForKey:@"videos"]];
            selectedUser.videos = array;
            [self moveLoggedInUserToFirstIndexOfVideoList];
        } else {
            selectedUser = [results objectForKey:@"user"];
            [self reloadUserData];
        }
        
    } else {
        [videosTableView reloadData];
    }
    TCEND
}

- (void)moveLoggedInUserToFirstIndexOfVideoList {
    TCSTART
    for (VideoModal *videoModal in selectedUser.videos) {
        [appDelegate moveLoggedInUserToTopInLikesListOfVideoModal:videoModal];
    }
    [videosTableView reloadData];
    TCEND
}
- (void)didFailToGetMypageDetailsWithError:(NSDictionary *)errorDict {
    TCSTART
    [self dataSourceDidFinishLoadingNewData];
    pageNumber = pageNumber - 1;
    [videosTableView reloadData];
    [appDelegate removeNetworkIndicatorInView:videosTableView];
    [appDelegate hideNetworkIndicator];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

- (void)setValuesToAllObjectsInBannerView {
    TCSTART
    titleLbl.text = selectedUser.userName?:@"";
    [userBannerImgView setImageWithURL:[NSURL URLWithString:selectedUser.bannerPath] placeholderImage:[UIImage imageNamed:@"DefaultCoverPic"]];
    
    bannerView.backgroundColor = [appDelegate colorWithHexString:@"fafafa"];
    
    //User Profile image
    [profileImgView setImageWithURL:[NSURL URLWithString:selectedUser.photoPath] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached];
    profileImgView.layer.cornerRadius = 30.0f;
    profileImgView.layer.borderWidth = 1.5f;
    profileImgView.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
    profileImgView.layer.masksToBounds = YES;
    
    // Username
    dividerLabel.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
    
    userName.text = selectedUser.userName;
    if ([self isNotNull:selectedUser.website]) {
        websiteLbl.text = selectedUser.website;
        websiteBtn.hidden = NO;
    } else {
        websiteLbl.text = @"";
        websiteBtn.hidden = YES;
    }
    bioLabl.text = selectedUser.bio?:@"";
    if ([self isNotNull:selectedUser.lastUpdate]) {
        updatedLabel.text = [NSString stringWithFormat:@"Last Update: %@",[appDelegate relativeDateString:selectedUser.lastUpdate]];
    } else {
        updatedLabel.text = @"Last Update:";
    }
    
    //    updatedLabel.textColor = [appDelegate colorWithHexString:@"11a3e7"];
    
    followersTextlbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
    followersCountLbl.text = [selectedUser.totalNoOfFollowers stringValue];
    
    followingsTextlbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
    followingsCountLbl.text = [selectedUser.totalNoOfFollowings stringValue];
    
    privateCountLbl.text = [selectedUser.totalNoOfPrivateUsers stringValue];
    
    numberOfTagsLbl.text = [NSString stringWithFormat:@"%@ Tag%@",[appDelegate getUserStatisticsFormatedString:[selectedUser.totalNoOfTags longLongValue]],[appDelegate returningPluralFormWithCount:[selectedUser.totalNoOfTags integerValue]]];
    numberOfvideosLbl.text = [NSString stringWithFormat:@"%@ Video%@",[appDelegate getUserStatisticsFormatedString:[selectedUser.totalNoOfVideos longLongValue]],[appDelegate returningPluralFormWithCount:[selectedUser.totalNoOfVideos integerValue]]];
    
    if ([appDelegate.loggedInUser.userId intValue] != [userId intValue]) {
        if (!selectedUser.youFollowing) {
            [followBtn setBackgroundColor:[appDelegate colorWithHexString:@"11a3e7"]];
            [followBtn setTitle:@"FOLLOW" forState:UIControlStateNormal];
        } else {
            [followBtn setBackgroundColor:[appDelegate colorWithHexString:@"3c8731"]];
            [followBtn setTitle:@"FOLLOWING" forState:UIControlStateNormal];
        }
    } else {
        followBtn.hidden = YES;
    }
    
    if ([appDelegate.loggedInUser.userId intValue] != [userId intValue]) {
        if (selectedUser.youPrivate) {
            privateTextlbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
            [privateBtn setBackgroundColor:[appDelegate colorWithHexString:@"3c8731"]];
            [privateBtn setTitle:@"ADDED TO PRIVATE" forState:UIControlStateNormal];
        } else {
            privateTextlbl.textColor = [UIColor lightGrayColor];
            [privateBtn setBackgroundColor:[appDelegate colorWithHexString:@"11a3e7"]];
            if (selectedUser.privateReqSent) {
                [privateBtn setTitle:@"PRIVATE REQUEST SENT" forState:UIControlStateNormal];
            } else if (selectedUser.respondToPvtReq) {
                [privateBtn setTitle:@"ACCEPT PRIVATE" forState:UIControlStateNormal];
            } else {
                [privateBtn setTitle:@"ADD TO PRIVATE" forState:UIControlStateNormal];
            }
        }
    } else {
        privateBtn.hidden = YES;
    }
    TCEND
}

#pragma mark Website link button
- (IBAction)onClickOfWebsiteBtn {
    TCSTART
    if ([self isNotNull:selectedUser.website]) {
        NSString *url;
        if (![selectedUser.website hasPrefix:@"http://"]) {
            url = [NSString stringWithFormat:@"http://%@",selectedUser.website];
        } else {
            url = selectedUser.website;
        }
        if ([appDelegate validateUrl:url andcheckingTypes:NSTextCheckingTypeLink]) {
            [appDelegate openWebviewWithURL:url];
        } else {
            [ShowAlert showError:@"Not a valid url"];
        }
    }
    TCEND
}

#pragma mark FollowersRequest Delegate Methods
- (IBAction)clickedOnFollowersBtn:(id)sender {
    TCSTART
    [self gotoAllCommentsScreenWithVideo:nil andSelectedIndexPath:nil andType:@"Follower"];
    TCEND
}

#pragma mark Followings Request Delegate Method
- (IBAction)clickedOnFollowingsBtn:(id)sender {
    TCSTART
    [self gotoAllCommentsScreenWithVideo:nil andSelectedIndexPath:nil andType:@"Following"];
    TCEND
}

#pragma mark Private Users
- (IBAction)onClickOfPrivateUsersBtn:(id)sender {
    //    [ShowAlert showAlert:@"In development"];
    if (selectedUser.youPrivate) {
        [self gotoAllCommentsScreenWithVideo:nil andSelectedIndexPath:nil andType:@"Private connections"];
    }
}

#pragma mark
- (IBAction)clickedOnFollowBtn:(id)sender {
    TCSTART
    if (selectedUser.youFollowing) {
        [appDelegate makeUnFollowUserWithUserId:appDelegate.loggedInUser.userId followerId:userId andCaller:self andIndexPath:nil];
    } else {
        [appDelegate makeFollowUserWithUserId:appDelegate.loggedInUser.userId followerId:userId andCaller:self andIndexPath:nil];
    }
    TCEND
}

- (void)didFinishedToUnFollowUser:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
//    [ShowAlert showAlert:@"Unfollowed successfully"];
    
    selectedUser.youFollowing = NO;
    NSInteger totalFollowings = [appDelegate.loggedInUser.totalNoOfFollowings integerValue];
    totalFollowings = totalFollowings - 1;
    appDelegate.loggedInUser.totalNoOfFollowings = [NSNumber numberWithInt:totalFollowings];
    
    NSInteger totalFollowers = [selectedUser.totalNoOfFollowers integerValue];
    totalFollowers = totalFollowers - 1;
    selectedUser.totalNoOfFollowers = [NSNumber numberWithInt:totalFollowers];
    [self setValuesToAllObjectsInBannerView];
    
    //    [followBtn setBackgroundColor:[appDelegate colorWithHexString:@"11a3e7"]];
    //    [followBtn setTitle:@"FOLLOW" forState:UIControlStateNormal];
    
    if ([self isNotNull:caller] && (([caller isKindOfClass:[BrowseViewController class]] || [caller isKindOfClass:[AllCommentsViewController class]]) && [caller respondsToSelector:@selector(unFollowedUserFromOtherPageViewControllerWithSelectedIndex:andUserId:)])) {
        [caller unFollowedUserFromOtherPageViewControllerWithSelectedIndex:selectedIndexPath andUserId:userId];
    }
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
    
    selectedUser.youFollowing = YES;
    NSInteger totalFollowings = [appDelegate.loggedInUser.totalNoOfFollowings integerValue];
    totalFollowings = totalFollowings + 1;
    appDelegate.loggedInUser.totalNoOfFollowings = [NSNumber numberWithInt:totalFollowings];
    
    NSInteger totalFollowers = [selectedUser.totalNoOfFollowers integerValue];
    totalFollowers = totalFollowers + 1;
    selectedUser.totalNoOfFollowers = [NSNumber numberWithInt:totalFollowers];
    [self setValuesToAllObjectsInBannerView];
    
    //    [followBtn setBackgroundColor:[appDelegate colorWithHexString:@"3c8731"]];
    //    [followBtn setTitle:@"FOLLOWING" forState:UIControlStateNormal];
    
    if ([self isNotNull:caller] && [caller isKindOfClass:[BrowseViewController class]] && [caller respondsToSelector:@selector(followedUserFromOtherPageViewControllerWithSelectedIndex:andUserId:)]) {
        [caller followedUserFromOtherPageViewControllerWithSelectedIndex:selectedIndexPath andUserId:userId];
    }
    TCEND
}

- (void)didFailToFollowUserWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

- (IBAction)clickedOnPrivateBtn:(id)sender {
    TCSTART
    //    [ShowAlert showAlert:@"In development"];
    if (selectedUser.youPrivate || selectedUser.privateReqSent) {
        [appDelegate makeUnPrivateUserWithUserId:appDelegate.loggedInUser.userId privateUserId:userId andCaller:self andIndexPath:nil];
    } else {
        if (selectedUser.respondToPvtReq) {
            [appDelegate makeAcceptPrivateUserWithUserId:appDelegate.loggedInUser.userId privateUserId:userId andCaller:self andIndexPath:nil];
//            [appDelegate showActivityIndicatorInView:videosTableView andText:@"Accepting private request"];
            [appDelegate showNetworkIndicator];
        } else {
            [appDelegate makePrivateUserWithUserId:appDelegate.loggedInUser.userId privateUserId:userId andCaller:self andIndexPath:nil];
        }
    }
    TCEND
}

- (void)didFinishedToUnPrivateUser:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    
    selectedUser.youPrivate = NO;
    selectedUser.privateReqSent = NO;
    selectedUser.respondToPvtReq = NO;
    NSInteger totalPrivateUsers = [appDelegate.loggedInUser.totalNoOfPrivateUsers integerValue];
    if (totalPrivateUsers > 0) {
        totalPrivateUsers = totalPrivateUsers - 1;
    }
    appDelegate.loggedInUser.totalNoOfPrivateUsers = [NSNumber numberWithInt:totalPrivateUsers];
    
    [self setValuesToAllObjectsInBannerView];
    TCEND
}

- (void)didFailToUnPrivateUserWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

- (void)didFinishedToPrivateUser:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    
    selectedUser.privateReqSent = YES;
    [self setValuesToAllObjectsInBannerView];
    
    TCEND
}

- (void)didFailToPrivateUserWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}


#pragma mark Accept Private group request

- (void)didFinishedToAcceptPrivateUser:(NSDictionary *)results {
    TCSTART
    [appDelegate removeNetworkIndicatorInView:self.view];
    [appDelegate hideNetworkIndicator];
    selectedUser.youPrivate = YES;
    selectedUser.respondToPvtReq = NO;
    NSInteger totalPrivateUsers = [appDelegate.loggedInUser.totalNoOfPrivateUsers integerValue];
    totalPrivateUsers = totalPrivateUsers + 1;
    appDelegate.loggedInUser.totalNoOfPrivateUsers = [NSNumber numberWithInt:totalPrivateUsers];
    
    NSInteger PrivateUsers = [selectedUser.totalNoOfPrivateUsers integerValue];
    PrivateUsers = PrivateUsers + 1;
    selectedUser.totalNoOfPrivateUsers = [NSNumber numberWithInt:PrivateUsers];
    
    [self setValuesToAllObjectsInBannerView];
    TCEND
}
- (void)didFailToAcceptPrivateUserWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate removeNetworkIndicatorInView:self.view];
    [appDelegate hideNetworkIndicator];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

#pragma mark Tableview Delegate and Datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(selectedUser.videos.count >= (searchSelected?searchPgNumber:pageNumber) * 10 && selectedUser.videos.count > 0) {
        return selectedUser.videos.count + 1;
    } else {
        return selectedUser.videos.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == selectedUser.videos.count) {
        return 40;
    }
    return [self getHeightOfRowInSection:indexPath];
}

- (CGFloat)getHeightOfRowInSection:(NSIndexPath *)indexPath {
    TCSTART
    if (indexPath.section == 0) {
        VideoModal *video = [selectedUser.videos objectAtIndex:indexPath.row];
        CGFloat height;
        if ([self isNotNull:video]) {
            if (video.numberOfCmnts.integerValue <= 0 && video.numberOfLikes.integerValue <= 0 && video.numberOfTags.integerValue <= 0) {
                return 186 + 20 + 3; // 20 for gap between options tab and line
            }
            height = 186 + 30 + 20 + 3; // 20 for gap between options tab and line
        }
        if ([video.numberOfLikes integerValue] <= 0 && [video.numberOfCmnts integerValue] <= 0) {
            return height;
        } else {
            height =  height + (([video.numberOfLikes integerValue] > 0)?25:0);
            if ([video.numberOfCmnts integerValue] > 0) {
                height = height + [self getCommentViewHeightForVideoModal:video];
            }
            return height;
        }
    }
    TCEND
}

- (CGFloat)getCommentViewHeightForVideoModal:(VideoModal *)video {
    TCSTART
    int count = 0;
    CGFloat totalHeight = 0;
    if (video.comments.count > 1) {
        count = 2;
    } else {
        count = 1;
    }
    for (int i = 0; i < count; i ++) {
        NSDictionary *dict;
        if (i < [video.comments count]) {
            dict = [video.comments objectAtIndex:i];
        }
        NSString *name;
        if ([self isNotNull:[dict objectForKey:@"user_id"]] && [[dict objectForKey:@"user_id"] intValue] == appDelegate.loggedInUser.userId.intValue) {
            name = @"You:";
        } else {
            name = [NSString stringWithFormat:@"%@:",[dict objectForKey:@"user_name"]];
        }
        
        CGSize btnSize = [name sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:13.0] constrainedToSize:CGSizeMake(270, 25) lineBreakMode:NSLineBreakByTruncatingMiddle];
        
        
        NSString *cmnt = [Base64Converter decodedString:[dict objectForKey:@"comment_text"]];
        CGSize cmntSize = [cmnt sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:13.0] constrainedToSize:CGSizeMake((285-btnSize.width), 38)];
        
        totalHeight = totalHeight + ((cmntSize.height < 25)?25:38);
    }
    return totalHeight;
    TCEND
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (searchSelected && selectedUser.videos.count <= 0 && videosSearchBar.text.length > 0) {
        return 40;
    } else {
        return 0;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TCSTART
    if (searchSelected && selectedUser.videos.count <= 0 && section == 0 && videosSearchBar.text.length > 0) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        UILabel *descLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        descLbl.font = [UIFont fontWithName:descriptionTextFontName size:15];
        descLbl.textColor = [UIColor blackColor];
        descLbl.backgroundColor = [UIColor clearColor];
        descLbl.textAlignment = UITextAlignmentCenter;
        descLbl.numberOfLines = 0;
        descLbl.text = @"No search results available, Please try again with different keyword";
        [headerView addSubview:descLbl];
        return headerView;
        //
    }
    
    TCEND
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if(indexPath.row == selectedUser.videos.count) {
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
        
        static NSString *cellIdentifier = @"MyPageVideoCellID";
        
        MyPageVideoCell *cell = (MyPageVideoCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil) {
            cell = [[MyPageVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell.userNameLbel.hidden = YES;
        cell.userProfileImgView.hidden = YES;
        cell.latestTagLbl.hidden = YES;
        cell.userInfoBgImgView.hidden = YES;
        cell.userPicBtn.hidden = YES;
        //    if ([appDelegate.loggedInUser.userId intValue] != [userId intValue]) {
        //         cell.deleteBtn.hidden = YES;
        //    } else {
        //         cell.deleteBtn.hidden = NO;
        //    }
        
        VideoModal *video = [selectedUser.videos objectAtIndex:indexPath.row];
        
        cell.tagsViewBgLbl.backgroundColor = [appDelegate colorWithHexString:@"fafafa"];
        
        //    [cell.deleteBtn addTarget:self action:@selector(deleteVideo: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        [cell.videoPlayBtn addTarget:self action:@selector(playVideo: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        //Likes
        [cell.likesBtn addTarget:self action:@selector(onClickOfGetAllVideoUsersLoved: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        cell.numberOfLikesLbl.text =  [NSString stringWithFormat:@"%@ Like%@",[appDelegate getUserStatisticsFormatedString:[video.numberOfLikes longLongValue]],[appDelegate returningPluralFormWithCountForLikes:[video.numberOfLikes integerValue]]];
        
        //Comments
        [cell.commentsBtn addTarget:self action:@selector(seeAllCommentsOfVideo: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        cell.numberofCmntsLbl.text = [NSString stringWithFormat:@"%@ Comment%@",[appDelegate getUserStatisticsFormatedString:[video.numberOfCmnts longLongValue]],[appDelegate returningPluralFormWithCount:[video.numberOfCmnts integerValue]]];
        
        //Tags
        cell.numberOfTagsLbl.text = [NSString stringWithFormat:@"%@ Tag%@",[appDelegate getUserStatisticsFormatedString:[video.numberOfTags longLongValue]],[appDelegate returningPluralFormWithCount:[video.numberOfTags integerValue]]];
        
        //Created Time
        cell.videoTitleLbl.text = [NSString stringWithFormat:@"%@ | ",video.title];
        
        //Video display time
        if ([self isNotNull:video.creationTime]) {
            cell.videoDisplayTimeLbl.text = [appDelegate relativeDateString:video.creationTime];
        } else {
            cell.videoDisplayTimeLbl.text = @"";
        }
        
        cell.videoFeedDisplayTimeLbl.hidden = YES;
        cell.videoFeedCreatedLbl.hidden = YES;
        
        // Numberof views
        cell.videosViewsLbl.text = [NSString stringWithFormat:@"%@",[appDelegate getUserStatisticsFormatedString:[video.numberOfViews longLongValue]]];
        
        // Video thumb
        [cell.videoBgImgView setImageWithURL:[NSURL URLWithString:video.videoThumbPath] placeholderImage:[UIImage imageNamed:@"DefaultVideoThumb"]];
        
        cell.dividerLbl.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
        
        [self setVisibilityForTagsCommentsAndLovedForCell:cell atVideo:video];
        [self addLovedPersonsViewWithIndexPath:indexPath toCell:cell];
        
        [self addCommentViewToTheCell:cell andIndexPath:indexPath];
        
        if (video.hasLovedVideo) {
            [cell.likeBtn setImage:[UIImage imageNamed:@"OptionLoved"] forState:UIControlStateNormal];
        } else {
            [cell.likeBtn setImage:[UIImage imageNamed:@"OptionUnLoved"] forState:UIControlStateNormal];
        }
        
        if (video.hasCommentedOnVideo) {
            [cell.commentBtn setImage:[UIImage imageNamed:@"OptionCmnt"] forState:UIControlStateNormal];
        } else {
            [cell.commentBtn setImage:[UIImage imageNamed:@"OptionUnCmnt"] forState:UIControlStateNormal];
        }
        
        //Options view
        CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
        //    NSLog(@"Row height:%f",cellRect.size.height);
        cell.optionsView.frame = CGRectMake(cell.optionsView.frame.origin.x, cellRect.size.height - 48, cell.optionsView.frame.size.width, cell.optionsView.frame.size.height);
        [cell.commentBtn addTarget:self action:@selector(seeAllCommentsOfVideo: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        [cell.likeBtn addTarget:self action:@selector(onClickOfLikeBtn: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        [cell.optionsBtn setTitleColor:[appDelegate colorWithHexString:@"11a3e7"] forState:UIControlStateNormal];
        [cell.optionsBtn addTarget:self action:@selector(onClickOfOptionsBtn: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    TCEND
}

- (void)setVisibilityForTagsCommentsAndLovedForCell:(MyPageVideoCell *)cell atVideo:(VideoModal *)video {
    TCSTART
    cell.tagsViewsBg.hidden = NO;
    cell.tagsViewBgLbl.hidden = NO;
    cell.tagsView.hidden = NO;
    cell.likesView.hidden = NO;
    cell.commentsView.hidden = NO;
    cell.tagsView.frame = CGRectMake(0, 0, 65, 30);
    cell.likesView.frame = CGRectMake(65, 0, 75, 30);
    cell.commentsView.frame = CGRectMake(140, 0, 100, 30);
    if (video.numberOfTags.integerValue <= 0 && video.numberOfCmnts.integerValue <= 0  && video.numberOfLikes.integerValue <= 0) {
        cell.tagsViewsBg.hidden = YES;
        cell.tagsViewBgLbl.hidden = YES;
    } else {
        CGFloat tagsViewBgWidth = cell.tagsView.frame.size.width + cell.likesView.frame.size.width + cell.commentsView.frame.size.width;
        if (video.numberOfTags.integerValue <= 0) {
            tagsViewBgWidth = tagsViewBgWidth - cell.tagsView.frame.size.width;
            cell.tagsView.hidden = YES;
            cell.tagsView.frame = CGRectMake(0, 0, 0, 30);
        }
        
        if (video.numberOfLikes.integerValue <= 0) {
            tagsViewBgWidth = tagsViewBgWidth - cell.likesView.frame.size.width;
            cell.likesView.hidden = YES;
            cell.likesView.frame = CGRectMake(cell.tagsView.frame.origin.x + cell.tagsView.frame.size.width, 0, 0, 30);
        } else {
            cell.likesView.frame = CGRectMake(cell.tagsView.frame.origin.x + cell.tagsView.frame.size.width, 0, 75, 30);
        }
        
        if (video.numberOfCmnts.integerValue <= 0) {
            tagsViewBgWidth = tagsViewBgWidth - cell.commentsView.frame.size.width;
            cell.commentsView.hidden = YES;
            //            cell.commentsView.frame = CGRectMake(127, 0, 85, 30);
            cell.commentsView.frame = CGRectMake(cell.likesView.frame.origin.x + cell.likesView.frame.size.width, 0, 0, 30);
        } else {
            cell.commentsView.frame = CGRectMake(cell.likesView.frame.origin.x + cell.likesView.frame.size.width, 0, 100, 30);
        }
        
        cell.tagsViewsBg.frame = CGRectMake((320-tagsViewBgWidth)/2, 160, tagsViewBgWidth, 30);
    }
    TCEND
}
- (void)addLovedPersonsViewWithIndexPath:(NSIndexPath *)indexPath toCell:(MyPageVideoCell *)cell {
    TCSTART
    VideoModal *video = [selectedUser.videos objectAtIndex:indexPath.row];
    cell.lovedPersonsView.backgroundColor = [UIColor clearColor];
    cell.lovedPersonsView.hidden = NO;
    cell.lovedPerson2.hidden = NO;
    cell.seeAllLovedBtn.hidden = NO;
    CGFloat totalWidth = 30.0;
    CGFloat buttonWidth;
    if ([self isNotNull:video.likesList] && video.likesList.count > 0 && [video.numberOfLikes integerValue] > 0) {
        for (int i = 0 ; i < 2; i++) {
            NSDictionary *dict;
            UIButton *lovedPersonBtn = nil;
            if (i < [video.likesList count]) {
                dict = [video.likesList objectAtIndex:i];
            }
            NSString *name;
            if (i == 0  && [self isNotNull:[dict objectForKey:@"user_id"]] &&[[dict objectForKey:@"user_id"] intValue] == appDelegate.loggedInUser.userId.intValue) {
                name = @"You";
            } else {
                name = [dict objectForKey:@"user_name"];
            }
            
            if (i == 0 && [video.likesList count] > 1) {
                name = [NSString stringWithFormat:@"%@, ",name];
            }
            
            if (i == 0) {
                lovedPersonBtn = (UIButton *)cell.lovedPerson1;
            } else {
                lovedPersonBtn = (UIButton *)cell.lovedPerson2;
            }
            
            if (i == 0 && [video.likesList count] == 1) {
                cell.lovedPerson2.hidden = YES;
                buttonWidth = 300;
                //                lovedPersonBtn.frame = CGRectMake(totalWidth, 0, 300, 25);
                //                totalWidth = 320;
            } else {
                if ([video.numberOfLikes integerValue] == 2) {
                    buttonWidth = 150;
                } else {
                    buttonWidth = 85;
                }
            }
            
            CGSize btnSize = [name sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:13.0] constrainedToSize:CGSizeMake(buttonWidth, 25) lineBreakMode:NSLineBreakByTruncatingMiddle];
            lovedPersonBtn.frame = CGRectMake(totalWidth, 0, btnSize.width, 25);
            totalWidth = totalWidth + btnSize.width;
            
            lovedPersonBtn.tag = [[dict objectForKey:@"user_id"] integerValue];
            
            [lovedPersonBtn addTarget:self action:@selector(onClickOfUserNameBtn:) forControlEvents:UIControlEventTouchUpInside];
            
            [lovedPersonBtn setTitle:name forState:UIControlStateNormal];
            [lovedPersonBtn setTitleColor:[appDelegate colorWithHexString:@"11a3e7"] forState:UIControlStateNormal];
        }
        
        if ([video.numberOfLikes integerValue] > 2) {
            [cell.seeAllLovedBtn setTitleColor:[appDelegate colorWithHexString:@"11a3e7"] forState:UIControlStateNormal];
            NSString *name = [NSString stringWithFormat:@" and %@ Other%@ Liked",[appDelegate getUserStatisticsFormatedString:([video.numberOfLikes longLongValue] - 2)],[appDelegate returningPluralFormWithCount:([video.numberOfLikes integerValue] - 2)]];
            CGSize nameSize = [name sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:13.0] constrainedToSize:CGSizeMake(120, 25)];
            [cell.seeAllLovedBtn setTitle:name forState:UIControlStateNormal];
            [cell.seeAllLovedBtn addTarget:self action:@selector(onClickOfGetAllVideoUsersLoved: withEvent:) forControlEvents:UIControlEventTouchUpInside];
            cell.seeAllLovedBtn.frame = CGRectMake(totalWidth, 0, nameSize.width, 25);
            totalWidth = totalWidth + nameSize.width;
        } else {
            cell.seeAllLovedBtn.hidden = YES;
        }
        cell.lovedPersonsView.frame = CGRectMake(0, 190, totalWidth, 25);
    } else {
        cell.lovedPersonsView.frame = CGRectMake(0, 0, 0, 0);
        cell.lovedPersonsView.hidden = YES;
    }
    
    TCEND
}

- (void) addCommentViewToTheCell:(MyPageVideoCell *)cell andIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    VideoModal *video = [selectedUser.videos objectAtIndex:indexPath.row];
    cell.allCommentsView.backgroundColor = [UIColor clearColor];
    cell.allCommentsView.hidden = NO;
    cell.commentor2View.hidden = NO;
    //    cell.seeAllComments.hidden = NO;
    
    CGFloat totalHeight = 0.0;
    if ([self isNotNull:video.comments] && video.comments.count > 0 && video.numberOfCmnts.integerValue > 0 ) {
        for (int i = 0 ; i < 2; i++) {
            
            CGFloat totalWidth = 0.0;
            NSDictionary *dict;
            UIButton *commentorBtn = nil;
            UILabel *commentText = nil;
            UIView *commentorView = nil;
            
            if (i < [video.comments count]) {
                dict = [video.comments objectAtIndex:i];
            }
            
            if (i == 0) {
                commentorBtn = (UIButton *)cell.commentor1;
                commentText = (UILabel *)cell.commentText1;
                commentorView = (UIView *)cell.commentor1View;
            } else {
                commentorBtn = (UIButton *)cell.commentor2;
                commentText = (UILabel *)cell.commentText2;
                commentorView = (UIView *)cell.commentor2View;
            }
            
            if (i == 0 && [video.comments count] == 1) {
                cell.commentor2View.hidden = YES;
            }
            
            commentorBtn.tag = [[dict objectForKey:@"user_id"] integerValue];
            [commentorBtn addTarget:self action:@selector(onClickOfUserNameBtn:) forControlEvents:UIControlEventTouchUpInside];
            
            NSString *name;
            if ([self isNotNull:[dict objectForKey:@"user_id"]] && [[dict objectForKey:@"user_id"] intValue] == appDelegate.loggedInUser.userId.intValue) {
                name = @"You:";
            } else {
                name = [NSString stringWithFormat:@"%@:",[dict objectForKey:@"user_name"]];
            }
            
            CGSize btnSize = [name sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:13.0] constrainedToSize:CGSizeMake(270, 25) lineBreakMode:NSLineBreakByTruncatingMiddle];
            commentorBtn.frame = CGRectMake(0, 0, btnSize.width, 25);
            [commentorBtn setTitle:name forState:UIControlStateNormal];
            [commentorBtn setTitleColor:[appDelegate colorWithHexString:@"11a3e7"] forState:UIControlStateNormal];
            
            totalWidth = totalWidth + btnSize.width;
            
            commentText.textColor = [UIColor darkGrayColor];
            NSString *cmnt = [Base64Converter decodedString:[dict objectForKey:@"comment_text"]];
            
            CGSize cmntSize = [cmnt sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:13.0] constrainedToSize:CGSizeMake((285-btnSize.width), 38)];
            commentText.text = cmnt;
            commentText.frame = CGRectMake(totalWidth + 3, 0, cmntSize.width, (cmntSize.height < 25)?25:38);
            
            totalWidth = totalWidth + cmntSize.width;
            commentorView.frame = CGRectMake(30, totalHeight, totalWidth, (cmntSize.height < 25)?25:38);
            totalHeight = totalHeight + ((cmntSize.height < 25)?25:38);
        }
        cell.allCommentsView.frame = CGRectMake(0, ([video.likesList count] > 0)?215:190, 320, totalHeight);
    } else {
        cell.allCommentsView.frame = CGRectMake(0, 0, 0, 0);
        cell.allCommentsView.hidden = YES;
    }
    TCEND
}

- (void) onClickOfUserNameBtn:(id)sender {
    TCSTART
    UIButton *userNameBtn = (UIButton *)sender;
    if (userNameBtn.tag != [selectedUser.userId integerValue] && userNameBtn.tag != [appDelegate.loggedInUser.userId integerValue]) {
        OthersPageViewController *otherPageVC = [[OthersPageViewController alloc] initWithNibName:@"OthersPageViewController" bundle:Nil andUser:[NSString stringWithFormat:@"%d",userNameBtn.tag]];
        [self.navigationController pushViewController:otherPageVC animated:YES];
    }
    TCEND
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    //    MyPageVideoDetailsViewController *detailsVC = [[MyPageVideoDetailsViewController alloc] initWithNibName:@"MyPageVideoDetailsViewController" bundle:Nil];
    //    [mainVC.navigationController pushViewController:detailsVC animated:YES];
    TCEND
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        if (indexPath.row == selectedUser.videos.count) {
            [self performSelector:@selector(loadMoreVideos) withObject:nil afterDelay:0.001];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)loadMoreVideos {
    if (searchSelected) {
        searchPgNumber = searchPgNumber + 1;
        [self makeSearchRequestWithSearchString:videosSearchBar.text andPageNumber:searchPgNumber requestForPagination:YES];
    } else {
        pageNumber = pageNumber + 1;
        [self requestForOtherUserPageRequestForPagination:YES andRequestForRefresh:NO];
    }
}

#pragma mark optionsView
-(void)onClickOfOptionsBtn:(id)sender  withEvent:(UIEvent *)event {
    TCSTART
    //    [ShowAlert showAlert:@"In Development"];
    selectedIndexPath = [appDelegate getIndexPathForEvent:event ofTableView:videosTableView];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Report Inappropriate",@"Share Video",@"Copy Share URL", nil];
    actionSheet.backgroundColor = [UIColor whiteColor];
    [actionSheet showInView:appDelegate.window];
    TCEND
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	TCSTART
	NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([buttonTitle caseInsensitiveCompare:@"Report Inappropriate"] == NSOrderedSame) {
        [self reportVideoAtIndexPath:selectedIndexPath];
    } else if([buttonTitle caseInsensitiveCompare:@"Share Video"] == NSOrderedSame) {
        [self shareVideoAtIndexPath:selectedIndexPath];
    } else if([buttonTitle caseInsensitiveCompare:@"Copy Share URL"] == NSOrderedSame) {
        VideoModal *video = [selectedUser.videos objectAtIndex:selectedIndexPath.row];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = video.shareUrl;
    }
	TCEND
}

#pragma mark Goto Shareviewcontroller
- (void)shareVideoAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [selectedUser.videos objectAtIndex:indexPath.row];
        if ([self isNotNull:video]) {
            ShareViewController *shareVC = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil withSelectedVideo:video andCaller:self];
            [self.navigationController pushViewController:shareVC animated:YES];
        }
    }
    TCEND
}

#pragma mark Report Video Delegate methods
- (void)reportVideoAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [selectedUser.videos objectAtIndex:indexPath.row];
        if ([self isNotNull:video]) {
            ReportVideoViewController *reportVC = [[ReportVideoViewController alloc] initWithNibName:@"ReportVideoViewController" bundle:nil forVideo:video.videoId];
            [self presentViewController:reportVC animated:YES completion:nil];
        }
    }
    TCEND
}

#pragma mark Get All Likes Delegate Methods
- (void)onClickOfGetAllVideoUsersLoved:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:videosTableView];
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [selectedUser.videos objectAtIndex:indexPath.row];
        if ([self isNotNull:video]) {
            [self gotoAllCommentsScreenWithVideo:video andSelectedIndexPath:indexPath andType:@"Like"];
        }
    }
    TCEND
}

#pragma mark
#pragma mark Like Video Delegate Methods
-(IBAction)onClickOfLikeBtn:(id)sender  withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:videosTableView];
    UIButton *likeBtn = (UIButton *)sender;
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [selectedUser.videos objectAtIndex:indexPath.row];
        if (likeBtn.currentImage == [UIImage imageNamed:@"OptionUnLoved"]) {
            NSLog(@"unlovedImage");
            [appDelegate makeRequestForLikeVideoWithVideoId:video.videoId andCaller:self andIndexPaht:indexPath];
        } else {
            NSLog(@"loved image");
            [appDelegate makeRequestForUnLikeVideoWithVideoId:video.videoId andCaller:self andIndexPaht:indexPath];
        }
    }
    TCEND
}

- (void)didFinishedLikeVideo:(NSDictionary *)results {
    TCSTART
    
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    if ([self isNotNull:[results objectForKey:@"indexpath"]]) {
        NSIndexPath *indexpath = [results objectForKey:@"indexpath"];
        VideoModal *video = [selectedUser.videos objectAtIndex:indexpath.row];
        NSInteger likesCount = [video.numberOfLikes integerValue];
        likesCount = likesCount + 1;
        video.numberOfLikes = [NSNumber numberWithInteger:likesCount];
        
        NSMutableArray *likeList = [[NSMutableArray alloc] initWithArray:video.likesList];
        [likeList insertObject:[NSDictionary dictionaryWithObjectsAndKeys:appDelegate.loggedInUser.userId,@"user_id",appDelegate.loggedInUser.userName?:@"",@"user_name", nil] atIndex:0];
        video.likesList = likeList;
        video.hasLovedVideo = YES;
        
        [videosTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexpath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    TCEND
}
- (void)didFailedLikeVideoWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

//unliked
- (void)didFinishedUnLikeVideo:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    if ([self isNotNull:[results objectForKey:@"indexpath"]]) {
        NSIndexPath *indexpath = [results objectForKey:@"indexpath"];
        VideoModal *video = [selectedUser.videos objectAtIndex:indexpath.row];
        NSInteger likesCount = [video.numberOfLikes integerValue];
        likesCount = likesCount - 1;
        video.numberOfLikes = [NSNumber numberWithInteger:likesCount];
        
        NSMutableArray *likeList = [[NSMutableArray alloc] initWithArray:video.likesList];
        for (NSDictionary *userDict in likeList) {
            if ([self isNotNull:[userDict objectForKey:@"user_id"]] && [[userDict objectForKey:@"user_id"] intValue] == appDelegate.loggedInUser.userId.intValue) {
                [likeList removeObject:userDict];
                break;
            }
        }
        //        [likeList insertObject:[NSDictionary dictionaryWithObjectsAndKeys:appDelegate.loggedInUser.userId,@"user_id",appDelegate.loggedInUser.userName?:@"",@"user_name", nil] atIndex:0];
        video.likesList = likeList;
        video.hasLovedVideo = NO;
        
        [videosTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexpath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    TCEND
}
- (void)didFailedUnLikeVideoWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

#pragma mark Get All Comments Delegate methods
- (void)seeAllCommentsOfVideo:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:videosTableView];
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [selectedUser.videos objectAtIndex:indexPath.row];
        if ([self isNotNull:video]) {
            [self gotoAllCommentsScreenWithVideo:video andSelectedIndexPath:indexPath andType:@"Comment"];
        }
    }
    TCEND
}

- (void)gotoAllCommentsScreenWithVideo:(VideoModal *)video andSelectedIndexPath:(NSIndexPath *)indexPath andType:(NSString *)type {
    TCSTART
    NSInteger count;
    if ([type caseInsensitiveCompare:@"Comment"] == NSOrderedSame) {
        count = [video.numberOfCmnts integerValue];
        appDelegate.videoFeedVC.mainVC.customTabView.hidden = YES;
    } else if ([type caseInsensitiveCompare:@"Follower"] == NSOrderedSame) {
        count = [selectedUser.totalNoOfFollowers integerValue];
    } else if ([type caseInsensitiveCompare:@"Following"] == NSOrderedSame) {
        count = [selectedUser.totalNoOfFollowings integerValue];
    } else if ([type caseInsensitiveCompare:@"Private connections"] == NSOrderedSame) {
        count = [selectedUser.totalNoOfPrivateUsers integerValue];
    } else {
        count = [video.numberOfLikes integerValue];
    }
    
    allCmntsVC = [[AllCommentsViewController alloc] initWithNibName:@"AllCommentsViewController" bundle:nil withVideoModal:video user:selectedUser viewType:type andSelectedIndexPath:indexPath andTotalCount:count andCaller:self];
    if ([type caseInsensitiveCompare:@"Comment"] == NSOrderedSame) {
        [appDelegate.videoFeedVC.mainVC.navigationController pushViewController:allCmntsVC animated:YES];
    } else {
        [self.navigationController pushViewController:allCmntsVC animated:YES];
    }
    TCEND
}

- (void)allCommentsScreenDismissCalledSelectedIndexPath:(NSIndexPath *)indexPath andViewType:(NSString *)viewType {
    TCSTART
    if ([self isNotNull:indexPath]) {
        if ([viewType caseInsensitiveCompare:@"Like"] == NSOrderedSame) {
            VideoModal *video = [selectedUser.videos objectAtIndex:indexPath.row];
            [appDelegate moveLoggedInUserToTopInLikesListOfVideoModal:video];
        }
        [videosTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    if ([viewType caseInsensitiveCompare:@"Follower"] == NSOrderedSame || [viewType caseInsensitiveCompare:@"Private connections"] == NSOrderedSame || [viewType caseInsensitiveCompare:@"Following"] == NSOrderedSame) {
        [self setValuesToAllObjectsInBannerView];
    }
    appDelegate.videoFeedVC.mainVC.customTabView.hidden = NO;
    allCmntsVC = nil;
    customMoviePlayerVC = nil;
    TCEND
}

#pragma mark Video Play
- (void)playVideo:(id)sender withEvent:(UIEvent *)event  {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:videosTableView];
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [selectedUser.videos objectAtIndex:indexPath.row];
        [appDelegate requestForPlayBackWithVideoId:video.videoId andcaller:self andIndexPath:indexPath refresh:NO];
    }
    TCEND
}

- (void)playBackResponse:(NSDictionary *)results {
    TCSTART
    if ([self isNotNull:results] && ![[results objectForKey:@"isResponseNull"] boolValue]) {
        VideoModal *video;
        NSIndexPath *indexPath = [results objectForKey:@"indexpath"];
        if ([self isNotNull:[results objectForKey:@"refresh"]] && ![[results objectForKey:@"refresh"] boolValue]) {
            video = [selectedUser.videos objectAtIndex:indexPath.row];
            if ([self isNotNull:[[results objectForKey:@"results"] objectForKey:@"uid"]]) {
                video.userId = [[results objectForKey:@"results"] objectForKey:@"uid"];
            }
            if ([self isNotNull:[[results objectForKey:@"results"] objectForKey:@"video_url"]]) {
                video.path = [[results objectForKey:@"results"] objectForKey:@"video_url"];
            }
            if ([self isNotNull:[[results objectForKey:@"results"] objectForKey:@"username"]]) {
                video.userName = [[results objectForKey:@"results"] objectForKey:@"username"];
            }
            if ([self isNotNull:[[results objectForKey:@"results"] objectForKey:@"user_photo"]]) {
                video.userPhoto = [[results objectForKey:@"results"] objectForKey:@"user_photo"];
            }
        } else {
            if ([self isNotNull:[results objectForKey:@"video"]]) {
                video = [results objectForKey:@"video"];
            }
        }
        customMoviePlayerVC = [[CustomMoviePlayerViewController alloc]initWithNibName:@"CustomMoviePlayerViewController" bundle:nil video:video videoFilePath:nil andClientVideoId:video.videoId showInstrcutnScreen:NO];
        [self presentViewController:customMoviePlayerVC animated:YES completion:nil];
        customMoviePlayerVC.caller = self;
        customMoviePlayerVC.selectedIndexPath = indexPath;
    }
    TCEND
}


#pragma mark Table ScrollView Methods
#pragma mark Scrolling Overrides
#pragma mark TableScrollView Delegate Methods Refreshing Table

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    @try {
        //        if([self isNotNull:commentTextViewRef]) {
        //            [commentTextViewRef resignFirstResponder];
        //        }
        [videosSearchBar resignFirstResponder];
        
        // NSLog(@"scrollViewWillBeginDragging");
        if (!reloading && !searchSelected) {
            checkForRefresh = YES;  //  only check offset when dragging
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    @try {
        // NSLog(@"scrollViewDidScroll with offset %f",scrollView.contentOffset.y);
        if (reloading && !searchSelected) return;
        
        if (checkForRefresh && !searchSelected) {
            if (refreshView.isFlipped && scrollView.contentOffset.y > -45.0f && scrollView.contentOffset.y < 0.0f && !reloading) {
                [refreshView flipImageAnimated:YES];
                [refreshView setStatus:kPullToReloadStatus];
                
            } else if (!refreshView.isFlipped && scrollView.contentOffset.y < -45.0f) {
                [refreshView flipImageAnimated:YES];
                [refreshView setStatus:kReleaseToReloadStatus];
            }
        }
        
        if (scrollView.tag == -524) {
            // Update the page when more than 50% of the previous/next page is visible
            CGFloat pageWidth = headerScrollView.frame.size.width;
            int page = floor((headerScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
            pageControl.currentPage = page;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    @try {
        if (reloading && !searchSelected) return;
        if (scrollView.contentOffset.y <= -45.0f && !searchSelected) {
            [self showReloadAnimationAnimated:YES];
            [self refreshPage];
        }
        if (!searchSelected) {
            checkForRefresh = NO;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}

- (IBAction)changePage {
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = headerScrollView.frame.size.width * pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = headerScrollView.frame.size;
    [headerScrollView scrollRectToVisible:frame animated:YES];
}

- (void) showReloadAnimationAnimated:(BOOL)animated
{
    @try {
        if (!searchSelected) {
            reloading = YES;
            [refreshView toggleActivityView:YES];
            
        }
        
        if (animated && !searchSelected) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.2];
            videosTableView.contentInset = UIEdgeInsetsMake(40.0f, 0.0f, 0.0f, 0.0f);
            [UIView commitAnimations];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
        
    }
}

- (void)dataSourceDidFinishLoadingNewData {
    @try {
        reloading = NO;
        [refreshView flipImageAnimated:NO];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.3];
        [videosTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        [refreshView setStatus:kPullToReloadStatus];
        [refreshView toggleActivityView:NO];
        [UIView commitAnimations];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)refreshPage {
    if (!searchSelected) {
        pageNumber = 1;
        [self requestForOtherUserPageRequestForPagination:NO andRequestForRefresh:YES];
    }
}


#pragma mark Search
- (IBAction)onClickOfSearchBtn:(id)sender {
    TCSTART
    UIButton *searchBtn = (UIButton *)sender;
    CGFloat searchBarHeight = videosSearchBar.frame.size.height;
    searchPgNumber = 1;
    if (searchBtn.tag == 1) {
        refreshView.hidden = YES;
        myPageVideos = [selectedUser.videos copy];
        selectedUser.videos = nil;
        searchBtn.tag = 123;
        searchSelected = YES;
        //Search
        [videosSearchBar becomeFirstResponder];
        searchBtn.frame = CGRectMake(250, searchBtn.frame.origin.y, 65, searchBtn.frame.size.height);
        [searchBtn setBackgroundImage:[UIImage imageNamed:@"SearchCancel"] forState:UIControlStateNormal];
        [searchBtn setBackgroundImage:[UIImage imageNamed:@"SearchCancel_f"] forState:UIControlStateHighlighted];
        [searchBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        videosSearchBar.hidden = NO;
        searchBarBg.hidden = NO;
        videosTableView.frame = CGRectMake(videosTableView.frame.origin.x, videosTableView.frame.origin.y + searchBarHeight, videosTableView.frame.size.width, videosTableView.frame.size.height - searchBarHeight);
        [videosTableView reloadData];
    } else {
        refreshView.hidden = NO;
        [videosSearchBar resignFirstResponder];
        searchBtn.tag = 1;
        //cancel
        searchSelected = NO;
        selectedUser.videos = myPageVideos;
        videosSearchBar.hidden = YES;
        searchBarBg.hidden = YES;
        //        [searchDict removeAllObjects];
        videosSearchBar.text = @"";
        searchBtn.frame = CGRectMake(285, searchBtn.frame.origin.y, 30, searchBtn.frame.size.height);
        [searchBtn setBackgroundImage:[UIImage imageNamed:@"HomeSearch"] forState:UIControlStateNormal];
        [searchBtn setBackgroundImage:[UIImage imageNamed:@"HomeSearch"] forState:UIControlStateHighlighted];
        [searchBtn setTitle:@"" forState:UIControlStateNormal];
        videosTableView.frame = CGRectMake(videosTableView.frame.origin.x, videosTableView.frame.origin.y - searchBarHeight, videosTableView.frame.size.width, videosTableView.frame.size.height + searchBarHeight);
        [videosTableView reloadData];
    }
    //    [self refreshTableViewWithSelectedBrowseTypePage:(searchSelected?[NSString stringWithFormat:@"%@SearchPgNum",browseType]:[NSString stringWithFormat:@"%@BrowsePgNum",browseType])];
    TCEND
}

- (void)customizeSearchBar {
    @try {
        videosSearchBar.placeholder = @"Search";
        videosSearchBar.keyboardType = UIKeyboardTypeDefault;
        videosSearchBar.barStyle = UIBarStyleDefault;
        videosSearchBar.delegate = self;
        
        [self setBackgroundForSearchBar:videosSearchBar withImagePath:@"SearchBarBg"];
        
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

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
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

#pragma mark Search
- (void)makeSearchRequestWithSearchString:(NSString *)searchString andPageNumber:(NSInteger)pgnum requestForPagination:(BOOL)pagination {
    TCSTART
    if (searchString.length > 0) {
        searchString = [appDelegate removingLastSpecialCharecter:searchString];
    }
    if (searchString.length > 0) {
        [appDelegate makeRequestForSearchWithString:searchString ofSearchType:@"otherpagesearch" pageNumber:pgnum anduserId:userId andCaller:self];
        if (!pagination) {
            [appDelegate showActivityIndicatorInView:self.view andText:@"Loading"];
        }
        [appDelegate showNetworkIndicator];
    } else {
        [ShowAlert showWarning:@"Please enter search keyword"];
    }
    TCEND
}
- (void)didFinishedToGetSearchReqDetails:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:self.view];
    if ([self isNotNull:[results objectForKey:@"videos"]]) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:selectedUser.videos];
        [array addObjectsFromArray:[results objectForKey:@"videos"]];
        selectedUser.videos = array;
        [self moveLoggedInUserToFirstIndexOfVideoList];
    } else {
        [videosTableView reloadData];
    }
    TCEND
}

- (void)didFailToGetSearchReqDetailsWithError:(NSDictionary *)errorDict {
    TCSTART
    searchPgNumber = searchPgNumber - 1;
    [videosTableView reloadData];
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:self.view];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
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
    return YES;
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
