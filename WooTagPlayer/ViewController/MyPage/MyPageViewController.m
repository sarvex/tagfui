/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "MyPageViewController.h"
#import "MyPageVideoCell.h"
#import "SuggestedUserCell.h"
#import "OthersPageViewController.h"
#import "SuggestedUsersViewController.h"
#import "VideoFeedAndMoreVideosViewController.h"
#import "ShareViewController.h"
#import "AccountSettingsviewController.h"
#import "AccessPermissionsViewController.h"

@interface MyPageViewController () {
    CustomMoviePlayerViewController *customMoviePlayerVC;
}

@end

@implementation MyPageViewController
@synthesize mainVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andFrame:(CGRect)frame
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.view.frame = frame;
    }
    return self;
}

- (void)viewDidLoad {
    TCSTART
    [super viewDidLoad];
    
    [self customizeSearchBar];

    videosSearchBar.hidden = YES;
    searchBarBg.hidden = YES;
    
    [videosTableView registerNib:[UINib nibWithNibName:@"MyPageVideoCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MyPageVideoCellID"];
    [videosTableView registerNib:[UINib nibWithNibName:@"SuggestedUserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SuggestedUserCellID"];
    
    videosTableView.tableHeaderView = userBannerView;
    videosTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    refreshView = [[RefreshView alloc] initWithFrame:
                   CGRectMake(videosTableView.frame.origin.x,- videosTableView.bounds.size.height,
                              videosTableView.frame.size.width, videosTableView.bounds.size.height)];
    [videosTableView addSubview:refreshView];
    
    if ([videosTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [videosTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    [self reloadUserData];
    [self requestForMyPage];
    
    TCEND
}

- (IBAction)onClickOfSettingsBtn:(id)sender {
    TCSTART
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user];
    AccountSettingsviewController *accountSettingsVC = [[AccountSettingsviewController alloc] initWithNibName:@"AccountSettingsviewController" bundle:nil];
    accountSettingsVC.userDataModal = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self.navigationController pushViewController:accountSettingsVC animated:YES];
    accountSettingsVC.mainVC = mainVC;
    TCEND
}

- (IBAction)onClickOfQuickLinksBtn:(id)sender {
    if ([self isNotNull:mainVC] && [mainVC respondsToSelector:@selector(onClickOfMenuButton)]) {
        [mainVC onClickOfMenuButton];
    }
}

- (IBAction)onClickOfUserPicButton {
    TCSTART
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"View profile photo",@"Edit profile", nil];
    [actionSheet showInView:appDelegate.window];
    actionSheet.backgroundColor = [UIColor whiteColor];
    TCEND
}

- (void)removeFullProfilePicVC {
    if ([self isNotNull:fullProfilePicVC]) {
        [fullProfilePicVC.view removeFromSuperview];
        fullProfilePicVC = nil;
    }
}

#pragma mark Website link button
- (IBAction)onClickOfWebsiteBtn {
    TCSTART
    if ([self isNotNull:user.website]) {
        NSString *url;
        if (![user.website hasPrefix:@"http://"]) {
            url = [NSString stringWithFormat:@"http://%@",user.website];
        } else {
            url = user.website;
        }
        if ([appDelegate validateUrl:url andcheckingTypes:NSTextCheckingTypeLink]) {
            [appDelegate openWebviewWithURL:url];
        } else {
            [ShowAlert showError:@"Not a valid url"];
        }
    }
    TCEND
}

- (IBAction)onClickOfSearchBtn:(id)sender {
    TCSTART
    UIButton *searchBtn = (UIButton *)sender;
    CGFloat searchBarHeight = videosSearchBar.frame.size.height;
    if (searchBtn.tag == 1) {
        refreshView.hidden = YES;
        mypageVideos = [user.videos copy];
        searchBtn.tag = 123;
        searchSelected = YES;
        [videosSearchBar becomeFirstResponder];
        //Search
        searchBtn.frame = CGRectMake(250, searchBtn.frame.origin.y, 65, searchBtn.frame.size.height);
        [searchBtn setBackgroundImage:[UIImage imageNamed:@"SearchCancel"] forState:UIControlStateNormal];
        [searchBtn setBackgroundImage:[UIImage imageNamed:@"SearchCancel_f"] forState:UIControlStateHighlighted];
        [searchBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        videosSearchBar.hidden = NO;
        searchBarBg.hidden = NO;
        videosTableView.frame = CGRectMake(videosTableView.frame.origin.x, videosTableView.frame.origin.y + searchBarHeight, videosTableView.frame.size.width, videosTableView.frame.size.height - searchBarHeight);
    } else {
        refreshView.hidden = NO;
        [videosSearchBar resignFirstResponder];
        searchBtn.tag = 1;
        //cancel
        searchSelected = NO;
        user.videos = mypageVideos;
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

- (void)reloadUserData {
    TCSTART
    user = appDelegate.loggedInUser;
    
    [userBannerImgView setImageWithURL:[NSURL URLWithString:user.bannerPath] placeholderImage:[UIImage imageNamed:@"DefaultCoverPic"] options:SDWebImageRefreshCached];
    
    [profileImgView setImageWithURL:[NSURL URLWithString:user.photoPath] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached];
    
    [self checkForPageControl];
    [self setValuesToAllObjectsInBannerView];
    [self moveLoggedInUserToFirstIndexOfVideoList];
    TCEND
}

- (void)setImageDataUntilImageCached {
    TCSTART
//    [SDImageCache removeObjec]
    NSData *bannerData = [NSData dataWithContentsOfURL:[NSURL URLWithString:user.bannerPath]];
    if ([self isNotNull:bannerData] && bannerData.length > 0) {
        userBannerImgView.image = [UIImage imageWithData:bannerData];
    }
    NSData *photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:user.photoPath]];
    if ([self isNotNull:photoData] && photoData.length > 0) {
        profileImgView.image = [UIImage imageWithData:photoData];
    }
    TCEND
}

- (void)checkForPageControl {
    TCSTART
    if ([self isNotNull:user.bio]) {
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

- (void)afterUpdateProfileFromAccountSettings {
    TCSTART
    user.country = appDelegate.loggedInUser.country;
    user.profession = appDelegate.loggedInUser.profession;
    user.website = appDelegate.loggedInUser.website;
    user.userDesc = appDelegate.loggedInUser.userDesc;
    user.photoPath = appDelegate.loggedInUser.photoPath;
    user.bannerPath = appDelegate.loggedInUser.bannerPath;
    user.phoneNumber = appDelegate.loggedInUser.phoneNumber;
    user.gender = appDelegate.loggedInUser.gender;
    user.bio = appDelegate.loggedInUser.bio;
    
    [userBannerImgView setImageWithURL:[NSURL URLWithString:user.bannerPath] placeholderImage:[UIImage imageNamed:@"DefaultCoverPic"] options:SDWebImageRefreshCached];
    
    [profileImgView setImageWithURL:[NSURL URLWithString:user.photoPath] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached];
    [self setImageDataUntilImageCached];
    [self checkForPageControl];
    [self setValuesToAllObjectsInBannerView];
    TCEND
}

- (void)moveLoggedInUserToFirstIndexOfVideoList {
    TCSTART
    for (VideoModal *videoModal in user.videos) {
        [appDelegate moveLoggedInUserToTopInLikesListOfVideoModal:videoModal];
    }
    [videosTableView reloadData];
    TCEND
}

- (void)viewWillAppear:(BOOL)animated {
    TCSTART
    [super viewWillAppear:YES];
    TCEND
}

#pragma mark Request for Mypage
- (void)requestForMyPage {
    if ([self isNotNull:user.userId]) {
        [appDelegate showNetworkIndicator];
        //        [appDelegate showActivityIndicatorInView:self.view andText:@"Loading"];
        [appDelegate makeMypageRequestWithUserId:user.userId andCaller:self];
    }
}

- (void)didFinishedToGetMypageDetails:(NSDictionary *)results {
    TCSTART
    //    [appDelegate removeNetworkIndicatorInView:self.view];
    mainVC.isMypageEnterBg = NO;
    [appDelegate hideNetworkIndicator];
    [self dataSourceDidFinishLoadingNewData];
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"isResponseNull"]] && ![[results objectForKey:@"isResponseNull"] boolValue]) {
        appDelegate.loggedInUser = [results objectForKey:@"user"];
        [appDelegate saveLoggedUserData:appDelegate.loggedInUser];
        [self reloadUserData];
        [self performSelector:@selector(setImageDataUntilImageCached) withObject:nil afterDelay:0.2];
    }
    TCEND
}
- (void)didFailToGetMypageDetailsWithError:(NSDictionary *)errorDict {
    TCSTART
    [self dataSourceDidFinishLoadingNewData];
    //    [appDelegate removeNetworkIndicatorInView:self.view];
    [appDelegate hideNetworkIndicator];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    [videosTableView reloadData];
    TCEND
}

- (void)setValuesToAllObjectsInBannerView {
    TCSTART
    userBannerView.backgroundColor = [appDelegate colorWithHexString:@"fafafa"];
    
    profileImgView.layer.cornerRadius = 30.0f;
    profileImgView.layer.borderWidth = 1.5f;
    profileImgView.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
    profileImgView.layer.masksToBounds = YES;
    
    // Username
    dividerLabel.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
    
    userName.text = user.userName;
    
    
    if ([self isNotNull:user.website]) {
       websiteLbl.text = user.website;
        websiteBtn.hidden = NO;
    } else {
        websiteLbl.text = @"";
        websiteBtn.hidden = YES;
    }
    bioLabl.text = user.bio?:@"";
    if ([self isNotNull:user.lastUpdate]) {
        updatedLabel.text = [NSString stringWithFormat:@"Last Update: %@",[appDelegate relativeDateString:user.lastUpdate]];
    } else {
        updatedLabel.text = @"Last Update:";
    }
    
    //    updatedLabel.textColor = [appDelegate colorWithHexString:@"11a3e7"];
    
    followersTextlbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
    followersCountLbl.text = [user.totalNoOfFollowers stringValue];
    
    followingsTextlbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
    followingsCountLbl.text = [user.totalNoOfFollowings stringValue];
    
    privateTextlbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
    privateCountLbl.text = [user.totalNoOfPrivateUsers stringValue];
    
    //    [NSString stringWithFormat:@"%@ Tag%@",[appDelegate getUserStatisticsFormatedString:[video.numberOfTags longLongValue]],];
    
    numberOfTagsLbl.text = [NSString stringWithFormat:@"%@ Tag%@",[appDelegate getUserStatisticsFormatedString:[user.totalNoOfTags longLongValue]],[appDelegate returningPluralFormWithCount:[user.totalNoOfTags integerValue]]];
    numberOfvideosLbl.text = [NSString stringWithFormat:@"%@ Video%@",[appDelegate getUserStatisticsFormatedString:[user.totalNoOfVideos longLongValue]],[appDelegate returningPluralFormWithCount:[user.totalNoOfVideos integerValue]]];
    
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
            searchField.backgroundColor = [UIColor clearColor];
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
    TCSTART
    TCEND
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
    TCSTART
    [self makeSearchRequestWithSearchString:searchBar.text andPageNumber:1 requestForPagination:NO];
    [searchBar resignFirstResponder];
    TCEND
}

#pragma mark Search
- (void)makeSearchRequestWithSearchString:(NSString *)searchString andPageNumber:(NSInteger)pgnum requestForPagination:(BOOL)pagination {
    TCSTART
    if (searchString.length > 0) {
        searchString = [appDelegate removingLastSpecialCharecter:searchString];
    }
    if (searchString.length > 0) {
        [appDelegate makeRequestForSearchWithString:searchString ofSearchType:@"mypagesearch" pageNumber:pgnum anduserId:user.userId andCaller:self];
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
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:self.view];
    if ([self isNotNull:[results objectForKey:@"videos"]]) {
        user.videos = [results objectForKey:@"videos"];
        [self moveLoggedInUserToFirstIndexOfVideoList];
    } else {
        [videosTableView reloadData];
    }
}

- (void)didFailToGetSearchReqDetailsWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:self.view];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    [videosTableView reloadData];
    TCEND
}

#pragma mark Tableview Delegate and Datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int sections = 2;
    if (user.moreVideos.count > 0) {
        sections = sections + 1;
    }
    if (user.suggestedUsers.count > 0) {
        sections = sections + 1;
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [user.videos count];
    } else if (section == 1) {
        if (user.moreVideos.count > 0) {
            return 1;
        } else if (user.suggestedUsers.count > 0){
            return [user.suggestedUsers count];
        } else {
            return 0;
        }
    } else if (section == 2) {
        if (user.suggestedUsers.count > 0 && user.moreVideos.count > 0){
            return [user.suggestedUsers count];
        } else {
            return 0;
        }
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [self getHeightOfRowInSection:indexPath];
    } else if (indexPath.section == 1) {
        if (user.moreVideos.count > 0) {
            return 70;
        } else if (user.suggestedUsers.count > 0){
            return 60;
        } else {
            return 0;
        }
    } else if (indexPath.section == 2) {
        if (user.suggestedUsers.count > 0 && user.moreVideos.count > 0){
            return 60;
        } else {
            return 0;
        }
    } else {
        return 0;
    }
}

- (CGFloat)getHeightOfRowInSection:(NSIndexPath *)indexPath {
    TCSTART
    if (indexPath.section == 0) {
        VideoModal *video = [user.videos objectAtIndex:indexPath.row];
        CGFloat height;
        if ([self isNotNull:video]) {
            if (video.numberOfCmnts.integerValue <= 0 && video.numberOfLikes.integerValue <= 0 && video.numberOfTags.integerValue <= 0) {
                return 186 + 20 + 3; // 20 for gap between options tab and line
            }
            height = 186 + 30 + 20 + 3; // 20 for gap between options tab and line
        }
        if ([video.likesList count] <= 0 && [video.comments count] <= 0) {
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
    if (searchSelected && user.videos.count <= 0 && videosSearchBar.text.length > 0) {
        return 40;
    } else {
        if (section == 0) {
            if (appDelegate.loggedInUser.totalNoOfVideos.intValue <= 0) {
                if (![appDelegate statusForNetworkConnectionWithOutMessage]) {
                    return 60;
                }
                return 170;
            }
            return 0;
        } else {
            return 60;
        }
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TCSTART
    if (searchSelected && user.videos.count <= 0 && section == 0 && videosSearchBar.text.length > 0) {
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
    } else {
        if (section == 0 && appDelegate.loggedInUser.totalNoOfVideos.intValue <= 0) {
            if ([appDelegate statusForNetworkConnectionWithOutMessage]) {
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 170)];
                UIImageView *noVideosImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Novideosuploaded"]];
                noVideosImgView.frame = CGRectMake((320 - 50)/2, 7, 50, 90);
                [headerView addSubview:noVideosImgView];
                
                UILabel *descLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 93, 320, 50)];
                descLbl.font = [UIFont fontWithName:descriptionTextFontName size:15];
                descLbl.textColor = [UIColor blackColor];
                descLbl.backgroundColor = [UIColor clearColor];
                descLbl.textAlignment = UITextAlignmentCenter;
                descLbl.numberOfLines = 0;
                descLbl.text = @"You haven't uploaded any video yet \n Click the red button to start your first video";
                [headerView addSubview:descLbl];
                
                return headerView;
            } else {
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];

                UILabel *notificationTextLbl = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, videosTableView.frame.size.width-10, 50)];
                notificationTextLbl.numberOfLines = 0;
                notificationTextLbl.backgroundColor = [UIColor clearColor];
                notificationTextLbl.font = [UIFont fontWithName:descriptionTextFontName size:14];
                notificationTextLbl.textAlignment = UITextAlignmentCenter;
                notificationTextLbl.text = @"Video feeds not available at this moment, We are facing trouble with your internet access, Try again";
                [headerView addSubview:notificationTextLbl];
                
                return headerView;
            }
            
        } else {
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
            headerView.backgroundColor = [UIColor whiteColor];
            UIButton *headerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            headerBtn.frame = CGRectMake(0, 5, headerView.frame.size.width, 50);
            [headerBtn addTarget:self action:@selector(onClickOfHeaderButton:) forControlEvents:UIControlEventTouchUpInside];
            UILabel *labl = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, headerView.frame.size.width, 50)];
            labl.textAlignment = UITextAlignmentCenter;
            labl.font = [UIFont fontWithName:descriptionTextFontName size:18];
            labl.backgroundColor = [appDelegate colorWithHexString:@"fafafa"];
            labl.textColor = [UIColor blackColor];
            
            if (section == 1) {
                if (user.moreVideos.count > 0) {
                    headerBtn.tag = 1;
                    labl.text = @"More Videos";
                } else if (user.suggestedUsers.count > 0) {
                    headerBtn.tag = 2;
                    labl.text = @"Suggested Users";
                } else {
                    headerBtn.tag = 3;
                    labl.text = @"Discover More People";
//                    labl.font = [UIFont fontWithName:descriptionTextFontName size:12];
                }
            } else if (section == 2) {
                if (user.suggestedUsers.count > 0 && user.moreVideos.count > 0) {
                    headerBtn.tag = 2;
                    labl.text = @"Suggested Users";
                } else {
                    headerBtn.tag = 3;
                    labl.text = @"Discover More People";
//                    labl.font = [UIFont fontWithName:descriptionTextFontName size:12];
                }
            } else {
                headerBtn.tag = 3;
                labl.text = @"Discover More People";
//                labl.font = [UIFont fontWithName:descriptionTextFontName size:12];
            }
            [headerView addSubview:labl];
            [headerView addSubview:headerBtn];
            return headerView;
        }
    }
    
    TCEND
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0 || section == ([tableView numberOfSections] - 1)) {
        return 5;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if (indexPath.section == 0) {
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
        VideoModal *video = [user.videos objectAtIndex:indexPath.row];
        
        cell.tagsViewBgLbl.backgroundColor = [appDelegate colorWithHexString:@"fafafa"];
        
        //        [cell.deleteBtn addTarget:self action:@selector(deleteVideo: withEvent:) forControlEvents:UIControlEventTouchUpInside];
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
        
        //options view
        CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
        cell.optionsView.frame = CGRectMake(cell.optionsView.frame.origin.x, cellRect.size.height - 48, cell.optionsView.frame.size.width, cell.optionsView.frame.size.height);
        
        [cell.commentBtn addTarget:self action:@selector(seeAllCommentsOfVideo: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        if (video.hasCommentedOnVideo) {
            [cell.commentBtn setImage:[UIImage imageNamed:@"OptionCmnt"] forState:UIControlStateNormal];
        } else {
            [cell.commentBtn setImage:[UIImage imageNamed:@"OptionUnCmnt"] forState:UIControlStateNormal];
        }
        
        [cell.likeBtn addTarget:self action:@selector(onClickOfLikeBtn: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        if (video.hasLovedVideo) {
            [cell.likeBtn setImage:[UIImage imageNamed:@"OptionLoved"] forState:UIControlStateNormal];
        } else {
            [cell.likeBtn setImage:[UIImage imageNamed:@"OptionUnLoved"] forState:UIControlStateNormal];
        }
        
        [cell.optionsBtn setTitleColor:[appDelegate colorWithHexString:@"11a3e7"] forState:UIControlStateNormal];
        [cell.optionsBtn addTarget:self action:@selector(onClickOfOptionsBtn: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
    } else if (indexPath.section == 1 && user.moreVideos.count > 0) {
        static NSString *cellIdentifier = @"MoreVideosCellID";
        UIView *videosView = nil;
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            videosView = [[UIView alloc] init];
            videosView.tag = 1;
            videosView.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:videosView];
        }
        
        if (!videosView) {
            videosView = (UIView *)[cell.contentView viewWithTag:1];
        }
        [self removeAllSubviewOfVideosView:videosView];
        
        CGFloat totalButtonWidth = 0.0f;
        int count;
        if (user.moreVideos.count > 5) {
            count = 5;
        } else {
            count = user.moreVideos.count;
        }
        for(int i = 0; i < count; i++) {
            UIView *videoView = [[UIView alloc] init];
            videoView.backgroundColor = [UIColor clearColor];
            videoView.frame = CGRectMake(totalButtonWidth, 0, 60, 70);
            
            NSDictionary *videoDict = [user.moreVideos objectAtIndex:i];
            
            UIImageView *videoImageView = [[UIImageView alloc] init];
            if ([self isNotNull:[videoDict objectForKey:@"video_thumb_path"]]) {
                [videoImageView setImageWithURL:[NSURL URLWithString:[videoDict objectForKey:@"video_thumb_path"]] placeholderImage:[UIImage imageNamed:@"DefaultVideoThumb"]];
            } else {
                videoImageView.image = [UIImage imageNamed:@"DefaultVideoThumb"];
            }
            
            [videoImageView setFrame:CGRectMake(0, 5, 60, 60)];
            [videoView addSubview:videoImageView];
            
            UIButton *videoPlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            videoPlayBtn.tag = [[videoDict objectForKey:@"video_id"] intValue];
            [videoPlayBtn addTarget:self action:@selector(playVideoFromMoreVideos:) forControlEvents:UIControlEventTouchUpInside];
            videoPlayBtn.frame = CGRectMake(20, 25, 20, 20);
            [videoPlayBtn setBackgroundImage:[UIImage imageNamed:@"DetailsVideoPlayBtn"] forState:UIControlStateNormal];
            [videoView addSubview:videoPlayBtn];
            
            [videosView addSubview:videoView];
            totalButtonWidth += videoView.frame.size.width + ((i == (count - 1))?0:2);
        }
        
        videosView.frame = CGRectMake((310.0f - totalButtonWidth)/2.0f + 5, 0, totalButtonWidth, 70);
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    } else if ((indexPath.section == 1 && user.moreVideos.count <= 0) || (indexPath.section == 2 && user.suggestedUsers.count > 0)) {
        static NSString *cellIdentifier = @"SuggestedUserCellID";
        SuggestedUserCell *cell = (SuggestedUserCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil) {
            cell = [[SuggestedUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        UserModal *suggestedUser = [user.suggestedUsers objectAtIndex:indexPath.row];
        if ([self isNotNull:suggestedUser.photoPath]) {
            [cell.userProfileImgView setImageWithURL:[NSURL URLWithString:suggestedUser.photoPath] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached];
        } else {
            [cell.userProfileImgView setImage:[UIImage imageNamed:@"OwnerPic"]];
        }
        cell.userProfileImgView.layer.cornerRadius = 22.5f;
        cell.userProfileImgView.layer.borderWidth = 1.5f;
        cell.userProfileImgView.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
        cell.userProfileImgView.layer.masksToBounds = YES;
        
        if ([self isNotNull:suggestedUser.userName]) {
            cell.userNameLbl.text = suggestedUser.userName;
        } else {
            cell.userNameLbl.text = @"";
        }
        cell.userNameLbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
        
        if ([self isNotNull:suggestedUser.userDesc]) {
            cell.descLbl.text = suggestedUser.userDesc;
            cell.userNameLbl.frame = CGRectMake(70, 9, 200, 21);
        } else {
            cell.descLbl.text = @"";
            cell.userNameLbl.frame = CGRectMake(70, 10, 200, 40);
        }
        
        if (!suggestedUser.youFollowing) {
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

- (void)removeAllSubviewOfVideosView:(UIView *)videosView {
    TCSTART
    for (UIView *subView in videosView.subviews) {
        if ([subView isKindOfClass:[UIView class]]) {
            [subView removeFromSuperview];
        }
    }
    TCEND
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if (user.suggestedUsers.count > 0) {
        if ((user.moreVideos.count > 0 && indexPath.section == 2) || (indexPath.section == 1 && user.moreVideos.count <= 0)) {
            if (user.suggestedUsers.count > indexPath.row) {
                UserModal *suggestedUser = [user.suggestedUsers objectAtIndex:indexPath.row];
                if (suggestedUser.userId.intValue != user.userId.intValue) {
                    OthersPageViewController *otherPageVC = [[OthersPageViewController alloc] initWithNibName:@"OthersPageViewController" bundle:Nil andUser:suggestedUser.userId];
                    [self.navigationController pushViewController:otherPageVC animated:YES];
                } else {
    
                }
            }
        }
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
    VideoModal *video = [user.videos objectAtIndex:indexPath.row];
    cell.lovedPersonsView.backgroundColor = [UIColor clearColor];
    cell.lovedPersonsView.hidden = NO;
    cell.lovedPerson2.hidden = NO;
    cell.seeAllLovedBtn.hidden = NO;
    CGFloat totalWidth = 30.0;
    CGFloat buttonWidth;
    if ([self isNotNull:video.likesList] && [video.likesList count] > 0 && [video.numberOfLikes integerValue] > 0) {
        for (int i = 0 ; i < 2; i++) {
            NSDictionary *dict;
            UIButton *lovedPersonBtn = nil;
            if (i < [video.likesList count]) {
                dict = [video.likesList objectAtIndex:i];
            }
            NSString *name;
            if (i == 0 && [self isNotNull:[dict objectForKey:@"user_id"]] &&[[dict objectForKey:@"user_id"] intValue] == appDelegate.loggedInUser.userId.intValue) {
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
    VideoModal *video = [user.videos objectAtIndex:indexPath.row];
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
    if (userNameBtn.tag != [user.userId integerValue]) {
        OthersPageViewController *otherPageVC = [[OthersPageViewController alloc] initWithNibName:@"OthersPageViewController" bundle:Nil andUser:[NSString stringWithFormat:@"%d",userNameBtn.tag]];
        [self.navigationController pushViewController:otherPageVC animated:YES];
    }
    TCEND
}

- (void)onClickOfHeaderButton:(id)sender {
    TCSTART
    UIButton *headerBtn = (UIButton *)sender;
    if (headerBtn.tag == 1) {
        VideoFeedAndMoreVideosViewController *videoFeedVC = [[VideoFeedAndMoreVideosViewController alloc] initWithNibName:@"VideoFeedAndMoreVideosViewController" bundle:Nil andFrame:CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height) andViewType:@"mypagevideos"];
        [self.navigationController pushViewController:videoFeedVC animated:YES];
        videoFeedVC.mainVC = mainVC;
    } else {
        NSString *title;
        if (headerBtn.tag == 2) {
            title = @"Suggested Users";
        } else {
            title = @"Discover More People";
        }
        SuggestedUsersViewController *suggestedUserVC = [[SuggestedUsersViewController alloc] initWithNibName:@"SuggestedUsersViewController" bundle:nil andUserId:user.userId andTitle:title];
        [self.navigationController pushViewController:suggestedUserVC animated:YES];
        suggestedUserVC.caller = self;
    }
    TCEND
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
                                  otherButtonTitles:@"Delete",@"Access Permission",@"Share Video",@"Copy Share URL",@"Tag", nil];
    actionSheet.backgroundColor = [UIColor whiteColor];
    [actionSheet showInView:appDelegate.window];
    TCEND
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	TCSTART
	NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([buttonTitle caseInsensitiveCompare:@"Delete"] == NSOrderedSame) {
        [self deleteVideoAtIndexPAth:selectedIndexPath];
    }  else if([buttonTitle caseInsensitiveCompare:@"Access Permission"] == NSOrderedSame) {
        [self accessPermissionOfVideoAtIndexPath:selectedIndexPath];
    } else if([buttonTitle caseInsensitiveCompare:@"Share Video"] == NSOrderedSame) {
        [self shareVideoAtIndexPath:selectedIndexPath];
    } else if([buttonTitle caseInsensitiveCompare:@"Copy Share URL"] == NSOrderedSame) {
        VideoModal *video = [user.videos objectAtIndex:selectedIndexPath.row];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = video.shareUrl;
    } else if([buttonTitle caseInsensitiveCompare:@"Tag"] == NSOrderedSame) {
        [self gotoPlayerScreenWithIndexPath:selectedIndexPath];
    } else if ([buttonTitle caseInsensitiveCompare:@"View profile photo"] == NSOrderedSame) {
        fullProfilePicVC = [[FullProfilePicViewController alloc] initWithNibName:@"FullProfilePicViewController" bundle:nil withImageUrlStr:[appDelegate getUserFullImageURLbyPhotoPath:user.photoPath] andCaller:self];
        fullProfilePicVC.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height - 20);
        [appDelegate.window addSubview:fullProfilePicVC.view];
        
    } else if ([buttonTitle caseInsensitiveCompare:@"Edit profile"] == NSOrderedSame) {
        [self onClickOfSettingsBtn:accountSettingsBtn];
    }
	TCEND
}

#pragma mark FollowersRequest Delegate Methods
- (IBAction)onClickOfFollowersBtn {
    [self gotoAllCommentsScreenWithVideo:nil andSelectedIndexPath:nil andType:@"Follower"];
}

#pragma mark Followings Request Delegate Method
- (IBAction)onClickOfFollowingsBtn {
    [self gotoAllCommentsScreenWithVideo:nil andSelectedIndexPath:nil andType:@"Following"];
}

- (IBAction)onClickOfPrivateUsersBtn:(id)sender {
    //    [ShowAlert showAlert:@"In development"];
    [self gotoAllCommentsScreenWithVideo:nil andSelectedIndexPath:nil andType:@"Private connections"];
}

#pragma mark
#pragma mark Like Video Delegate Methods
- (void)onClickOfLikeBtn:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    UIButton *likeBtn = (UIButton *)sender;
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:videosTableView];
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [user.videos objectAtIndex:indexPath.row];
        if ([self isNotNull:video]) {
            if (likeBtn.currentImage == [UIImage imageNamed:@"OptionUnLoved"]) {
                NSLog(@"unlovedImage");
                [appDelegate makeRequestForLikeVideoWithVideoId:video.videoId andCaller:self andIndexPaht:indexPath];
            } else {
                NSLog(@"loved image");
                [appDelegate makeRequestForUnLikeVideoWithVideoId:video.videoId andCaller:self andIndexPaht:indexPath];
            }
        }
    }
    TCEND
}

// liked
- (void)didFinishedLikeVideo:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    if ([self isNotNull:[results objectForKey:@"indexpath"]]) {
        NSIndexPath *indexpath = [results objectForKey:@"indexpath"];
        VideoModal *video = [user.videos objectAtIndex:indexpath.row];
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
        VideoModal *video = [user.videos objectAtIndex:indexpath.row];
        NSInteger likesCount = [video.numberOfLikes integerValue];
        likesCount = likesCount - 1;
        video.numberOfLikes = [NSNumber numberWithInteger:likesCount];
        
        NSMutableArray *likeList = [[NSMutableArray alloc] initWithArray:video.likesList];
        for (NSDictionary *userDict in likeList) {
            if ([self isNotNull:[userDict objectForKey:@"user_id"]] &&[[userDict objectForKey:@"user_id"] intValue] == appDelegate.loggedInUser.userId.intValue) {
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

#pragma mark Delete Video Delegate methods
//- (void)deleteVideo:(id)sender withEvent:(UIEvent *)event {
//    TCSTART
//    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:videosTableView];
//    if ([self isNotNull:indexPath]) {
//        VideoModal *video = [user.videos objectAtIndex:indexPath.row];
//        if ([self isNotNull:video]) {
//            [appDelegate showActivityIndicatorInView:self.view andText:@"Deleting"];
//            [appDelegate showNetworkIndicator];
//            [appDelegate makeRequestForDeleteVideoWithVideoId:video.videoId andUserId:user.userId andCaller:self atIndexpath:indexPath];
//        }
//    }
//    TCEND
//}
- (void)deleteVideoAtIndexPAth:(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [user.videos objectAtIndex:indexPath.row];
        if ([self isNotNull:video]) {
            [appDelegate showActivityIndicatorInView:self.view andText:@"Deleting"];
            [appDelegate showNetworkIndicator];
            [appDelegate makeRequestForDeleteVideoWithVideoId:video.videoId andUserId:user.userId andCaller:self atIndexpath:indexPath];
        }
    }
    TCEND
}
- (void)didFinishedDeleteVideo:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:self.view];
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"indexpath"]]) {
        
        NSIndexPath *indexPath = [results objectForKey:@"indexpath"];
        NSMutableArray *videoArray = [[NSMutableArray alloc] init];
        [videoArray addObjectsFromArray:user.videos];
        [videoArray removeObjectAtIndex:indexPath.row];
        user.videos = videoArray;
        
        NSInteger numberOfVideos = [appDelegate.loggedInUser.totalNoOfVideos intValue];
        numberOfVideos = numberOfVideos - 1;
        user.totalNoOfVideos = [NSNumber numberWithInt:numberOfVideos];
        appDelegate.loggedInUser.totalNoOfVideos = [NSNumber numberWithInt:numberOfVideos];
        
        numberOfvideosLbl.text = [NSString stringWithFormat:@"%@ Video%@",[appDelegate getUserStatisticsFormatedString:[user.totalNoOfVideos longLongValue]],[appDelegate returningPluralFormWithCount:[user.totalNoOfVideos integerValue]]];
        if (user.videos.count <= 0 && user.totalNoOfVideos.intValue > 0) {
            [self refreshMyPageVideos];
        }
        [videosTableView reloadData];
    }
    TCEND
}
- (void)didFailedDeleteVideoWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:self.view];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

#pragma mark Goto Shareviewcontroller
- (void)accessPermissionOfVideoAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [user.videos objectAtIndex:indexPath.row];
        if ([self isNotNull:video]) {
            AccessPermissionsViewController *permissionsVC = [[AccessPermissionsViewController alloc] initWithNibName:@"AccessPermissionsViewController" bundle:nil withSelectedVideo:video andCaller:self];
            [self.navigationController pushViewController:permissionsVC animated:YES];
        }
    }
    TCEND
}

#pragma mark Goto Shareviewcontroller
- (void)shareVideoAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [user.videos objectAtIndex:indexPath.row];
        if ([self isNotNull:video]) {
            ShareViewController *shareVC = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil withSelectedVideo:video andCaller:self];
            [self.navigationController pushViewController:shareVC animated:YES];
        }
    }
    TCEND
}

#pragma mark Get All Likes Delegate Methods
- (void)onClickOfGetAllVideoUsersLoved:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:videosTableView];
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [user.videos objectAtIndex:indexPath.row];
        if ([self isNotNull:video]) {
            [self gotoAllCommentsScreenWithVideo:video andSelectedIndexPath:indexPath andType:@"Like"];
        }
    }
    TCEND
}

#pragma mark Get All Comments Delegate methods
- (void)seeAllCommentsOfVideo:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:videosTableView];
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [user.videos objectAtIndex:indexPath.row];
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
        mainVC.customTabView.hidden = YES;
    } else if ([type caseInsensitiveCompare:@"Follower"] == NSOrderedSame) {
        count = [user.totalNoOfFollowers integerValue];
    } else if ([type caseInsensitiveCompare:@"Following"] == NSOrderedSame) {
        count = [user.totalNoOfFollowings integerValue];
    } else if ([type caseInsensitiveCompare:@"Private connections"] == NSOrderedSame) {
        count = [user.totalNoOfPrivateUsers integerValue];
    } else {
        count = [video.numberOfLikes integerValue];
    }
    
    allCmntsVC = [[AllCommentsViewController alloc] initWithNibName:@"AllCommentsViewController" bundle:nil withVideoModal:video user:user viewType:type andSelectedIndexPath:indexPath andTotalCount:count andCaller:self];
    if ([type caseInsensitiveCompare:@"Comment"] == NSOrderedSame) {
        [mainVC.navigationController pushViewController:allCmntsVC animated:YES];
    } else {
        [self.navigationController pushViewController:allCmntsVC animated:YES];
    }
    
    TCEND
}

- (void)allCommentsScreenDismissCalledSelectedIndexPath:(NSIndexPath *)indexPath andViewType:(NSString *)viewType {
    TCSTART
    
    if ([self isNotNull:indexPath]) {
        if ([viewType caseInsensitiveCompare:@"Like"] == NSOrderedSame) {
            VideoModal *video = [user.videos objectAtIndex:indexPath.row];
            [appDelegate moveLoggedInUserToTopInLikesListOfVideoModal:video];
        }
        [videosTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    if ([viewType caseInsensitiveCompare:@"Follower"] == NSOrderedSame || [viewType caseInsensitiveCompare:@"Private connections"] == NSOrderedSame || [viewType caseInsensitiveCompare:@"Following"] == NSOrderedSame) {
        [self setValuesToAllObjectsInBannerView];
    }
    mainVC.customTabView.hidden = NO;
    allCmntsVC = nil;
    customMoviePlayerVC = nil;
    TCEND
}

#pragma mark Video Play
- (void)playVideoFromMoreVideos:(id)sender {
    TCSTART
    UIButton *btn = (UIButton *)sender;
    NSString *videoId = [NSString stringWithFormat:@"%d",btn.tag];
    if ([self isNotNull:videoId]) {
        [appDelegate requestForPlayBackWithVideoId:videoId andcaller:self andIndexPath:Nil refresh:YES];
    }
    TCEND
}
- (void)playVideo:(id)sender withEvent:(UIEvent *)event  {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:videosTableView];
    [self gotoPlayerScreenWithIndexPath:indexPath];
    TCEND
}

- (void)gotoPlayerScreenWithIndexPath :(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [user.videos objectAtIndex:indexPath.row];
        [appDelegate requestForPlayBackWithVideoId:video.videoId andcaller:self andIndexPath:indexPath refresh:NO];
    }
    TCEND
}
- (void)playBackResponse:(NSDictionary *)results {
    TCSTART
    if ([self isNotNull:results] && ![[results objectForKey:@"isResponseNull"] boolValue] ) {
        VideoModal *video;
        NSIndexPath *indexPath = [results objectForKey:@"indexpath"];
        if ([self isNotNull:[results objectForKey:@"refresh"]] && ![[results objectForKey:@"refresh"] boolValue]) {
            video = [user.videos objectAtIndex:indexPath.row];
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
        customMoviePlayerVC = [[CustomMoviePlayerViewController alloc]initWithNibName:@"CustomMoviePlayerViewController" bundle:nil video:video videoFilePath:nil andClientVideoId:nil showInstrcutnScreen:NO];
        [mainVC presentViewController:customMoviePlayerVC animated:YES completion:nil];
        customMoviePlayerVC.caller = self;
        customMoviePlayerVC.selectedIndexPath = indexPath;
    }
    TCEND
}

#pragma mark Follow & Unfollow
- (void)clickedOnFollowBtn:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:videosTableView];
    UserModal *selectedUser = [user.suggestedUsers objectAtIndex:indexPath.row];
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
    UserModal *selectedUser = [user.suggestedUsers objectAtIndex:indexpath.row];
    selectedUser.youFollowing = NO;
    
    NSInteger totalFollowings = [user.totalNoOfFollowings integerValue];
    totalFollowings = totalFollowings - 1;
    user.totalNoOfFollowings = [NSNumber numberWithInt:totalFollowings];
    [self setValuesToAllObjectsInBannerView];
    
    SuggestedUserCell *cell = (SuggestedUserCell *)[videosTableView cellForRowAtIndexPath:indexpath];
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
    UserModal *selectedUser = [user.suggestedUsers objectAtIndex:indexpath.row];
    NSMutableArray *array = [user.suggestedUsers mutableCopy];
    [array removeObject:selectedUser];
    user.suggestedUsers = array;
    [videosTableView reloadData];
    
    NSInteger totalFollowings = [user.totalNoOfFollowings integerValue];
    totalFollowings = totalFollowings + 1;
    user.totalNoOfFollowings = [NSNumber numberWithInt:totalFollowings];
    [self setValuesToAllObjectsInBannerView];
    
    TCEND
}
- (void)didFailToFollowUserWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}


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
            [self refreshMyPageVideos];
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

- (void)refreshMyPageVideos {
    if (!searchSelected) {
        mainVC.isMypageEnterBg = NO;
        [self requestForMyPage];
    }
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
