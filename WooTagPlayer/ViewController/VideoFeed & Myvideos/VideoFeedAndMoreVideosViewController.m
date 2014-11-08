/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "VideoFeedAndMoreVideosViewController.h"
#import "MyPageVideoCell.h"
#import "OthersPageViewController.h"
#import "ShareViewController.h"
#import "FriendFinderViewController.h"
#import "AccessPermissionsViewController.h"
#import "ReportVideoViewController.h"

@interface VideoFeedAndMoreVideosViewController () {
    CustomMoviePlayerViewController *customMoviePlayerVC;
}

@end

@implementation VideoFeedAndMoreVideosViewController
@synthesize mainVC;
@synthesize progressView;
@synthesize videoLoadingView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andFrame:(CGRect)frame andViewType:(NSString *)type {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        viewType = type;
        if ([viewType caseInsensitiveCompare:@"VideoFeed"] == NSOrderedSame) {
            self.view.frame = frame;
        } else {
            self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height - 20);
        }
        
        if(&UIApplicationDidEnterBackgroundNotification != nil)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        }
    }
    return self;
}

/** When app goes to background saving first 10 videos
 */
- (void)applicationDidEnterBackground:(UIApplication *)application {
    TCSTART
    if ([self isNotNull:appDelegate.loggedInUser]) {
        if ([self isNotNull:[browseDict objectForKey:@"following"]]  && [[browseDict objectForKey:@"followingpgnum"] intValue] > 0) {
            NSArray *videoFeedArray;
            if ([[browseDict objectForKey:@"following"] count] >= 10) {
                videoFeedArray = [[browseDict objectForKey:@"following"] subarrayWithRange:NSMakeRange(0, 10)];
            } else {
                videoFeedArray = [browseDict objectForKey:@"following"];
            }
            appDelegate.loggedInUser.videoFeed = videoFeedArray;
        }
        
        if ([self isNotNull:[browseDict objectForKey:@"private"]] && [[browseDict objectForKey:@"privatepgnum"] intValue] > 0) {
            NSArray *privateFeedArray;
            if ([[browseDict objectForKey:@"private"] count] >= 10) {
                privateFeedArray = [[browseDict objectForKey:@"private"] subarrayWithRange:NSMakeRange(0, 10)];
            } else {
                privateFeedArray = [browseDict objectForKey:@"private"];
            }
            appDelegate.loggedInUser.privateFeed = privateFeedArray;
        }
        [appDelegate saveLoggedUserData:appDelegate.loggedInUser];
        NSLog(@"VideoFeedAndMoreVideosViewController enter background");
    }
    TCEND
}

- (void)viewDidLoad {
    TCSTART
    [super viewDidLoad];
    videosTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [videosTableView registerNib:[UINib nibWithNibName:@"MyPageVideoCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MyPageVideoCellID"];
    videosTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if ([viewType caseInsensitiveCompare:@"VideoFeed"] == NSOrderedSame) {
        selectedType = @"videofeed";
        titleLabl.text = @"Home";
    } else {
        selectedType = @"myvideos";
        titleLabl.text = @"More videos";
        followingFeedBtn.hidden = YES;
        followingFeedBtn.hidden = YES;
        feedBgImgView.hidden = YES;
        videosTableView.frame = CGRectMake(videosTableView.frame.origin.x, 41, videosTableView.frame.size.width, videosTableView.frame.size.height + 39);
    }
    
    searchPgNumber = 1;
    videosSearchBar.hidden = YES;
    searchBarBg.hidden = YES;
    videoLoadingView.hidden = YES;
    
    browseDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:0],@"followingpgnum",[NSNumber numberWithInt:0],@"privatepgnum",[NSNumber numberWithInt:2],@"myvideospgnum", nil];
    searchDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:1],@"followingpgnum",[NSNumber numberWithInt:1],@"privatepgnum",[NSNumber numberWithInt:1],@"myvideospgnum", nil];
    displayVideosArray = [[NSMutableArray alloc] init];
    
    [self customizeSearchBar];
    
    if ([viewType caseInsensitiveCompare:@"VideoFeed"] == NSOrderedSame) {
        [self onClickOfFollowingFeedBtn:nil];
    } else {
        pageNumber = [[browseDict objectForKey:[NSString stringWithFormat:@"%@pgnum",selectedType]] integerValue];
        [self makeVideoFeedOrMyVideosRequest:NO andRequestForRefresh:NO];
    }
    
    if ([viewType caseInsensitiveCompare:@"VideoFeed"] == NSOrderedSame) {
        backButton.hidden = YES;
    } else {
        quickLinksBtn.hidden = YES;
    }
    refreshView = [[RefreshView alloc] initWithFrame:
                   CGRectMake(videosTableView.frame.origin.x,- videosTableView.bounds.size.height,
                              videosTableView.frame.size.width, videosTableView.bounds.size.height)];
    [videosTableView addSubview:refreshView];
    
    progressView.bufferValue = 1.0f;
    progressView.layer.cornerRadius = 5.0f;
    progressView.layer.masksToBounds = YES;
    loadingLbl.text = @"Uploading...";
    loadingLbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
    progressView.backgroundColor = [appDelegate colorWithHexString:@"d2c8bf"];
    
    requestedForVideoFeed = NO;
    TCEND
}

/** When application come to foreground from background need to make refresh req for feeds in bakcground without stoping user interaction with screens
 */
- (void)applicationDidEnterForegroundNotificationFromMainVC {
    TCSTART
    if (([selectedType caseInsensitiveCompare:@"following"] == NSOrderedSame && mainVC.isVideoFeedEnterBg) || ([selectedType caseInsensitiveCompare:@"private"] == NSOrderedSame && mainVC.isPrivateFeedEnterBg)) {
        [self refreshTheScreen];
    }
    TCEND
}
- (void)setBoolValueForControllerVariable {
    if ([viewType caseInsensitiveCompare:@"VideoFeed"] == NSOrderedSame) {
        appDelegate.isVideoFeedVCDisplays = YES;
    } else {
        appDelegate.isVideoFeedVCDisplays = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self setBoolValueForControllerVariable];
}

/** Video uploading progress view status message and progess value
 */
- (void)setVisibilityForVideouploadingView:(BOOL)visible andPublishing:(BOOL)publishing {
    TCSTART
    if (visible) {
        if (!publishing) {
           loadingLbl.text = @"Uploading...";
        } else {
            loadingLbl.text = @"Uploaded, waiting to publish!";
        }
        
        if (videoLoadingView.isHidden) {
            progressView.progressValue = 0.0f;
            [videoLoadingView setNeedsDisplay];
            videoLoadingView.hidden = NO;
            if (!videosSearchBar.hidden) {
                videosSearchBar.frame = CGRectMake(videosSearchBar.frame.origin.x, 92, videosSearchBar.frame.size.width, videosSearchBar.frame.size.height);
            }
            [self adjustAllButtonsInScreenWithOriginY:videoLoadingView.frame.size.height];
        }
    } else {
        if (!visible && !appDelegate.isUploading && !videoLoadingView.isHidden) {
            loadingLbl.text = @"Finished!";
        }
    }
    TCEND
}

/** Hidding video progress view when uplaod finishes
 */
- (void)completedVideoUploading {
    TCSTART
    //loadingLbl.text = @"Finished!";
    if (!appDelegate.isUploading && !videoLoadingView.isHidden) {
        progressView.progressValue = 0.0f;
        [videoLoadingView setNeedsDisplay];
        [self hideVideoUplaodingView];
    }
    TCEND
}

- (void)hideVideoUplaodingView {
   TCSTART
    if (!videoLoadingView.hidden) {
        videoLoadingView.hidden = YES;
        if (!videosSearchBar.hidden) {
            videosSearchBar.frame = CGRectMake(videosSearchBar.frame.origin.x, 42, videosSearchBar.frame.size.width, videosSearchBar.frame.size.height);
        }
        [self adjustAllButtonsInScreenWithOriginY:-videoLoadingView.frame.size.height];
        
    }
    TCEND
}


- (IBAction)onClickOfFollowingFeedBtn:(id)sender {
    TCSTART
    if ([selectedType caseInsensitiveCompare:@"following"] == NSOrderedSame) {
        
    } else {
        selectedType = @"following";
        feedBgImgView.image = [UIImage imageNamed:@"VideofeedHighlighted"];
        if (mainVC.isVideoFeedEnterBg) {
            [self applicationDidEnterForegroundNotificationFromMainVC];
        }
        if (searchSelected) {
            reqMadeForSearch = YES;
        }
        [self addVideosToTheVideoDisplayArray];
    }
    TCEND
}

- (IBAction)onClickOfPrivateFeedBtn:(id)sender {
    TCSTART
    if ([selectedType caseInsensitiveCompare:@"private"] == NSOrderedSame) {
        
    } else {
        selectedType = @"private";
        feedBgImgView.image = [UIImage imageNamed:@"PrivateFeedHighlighted"];
        if (mainVC.isPrivateFeedEnterBg) {
            [self applicationDidEnterForegroundNotificationFromMainVC];
        }
        if (searchSelected) {
            reqMadeForSearch = YES;
        }
        [self addVideosToTheVideoDisplayArray];
    }
    
    TCEND
}

/** Checking for search videos or normal videos
 */
- (void)addVideosToTheVideoDisplayArray {
    TCSTART
    if (searchSelected && reqMadeForSearch) {
        if ([self isNotNull:[searchDict objectForKey:selectedType]]) {
            displayVideosArray = [searchDict objectForKey:selectedType];
        } else {
            displayVideosArray = [NSMutableArray arrayWithObjects:nil];
        }
        searchPgNumber = [[searchDict objectForKey:[NSString stringWithFormat:@"%@pgnum",selectedType]] integerValue];
        if ([self isNotNull:[searchDict objectForKey:[NSString stringWithFormat:@"%@SearchString",selectedType]]]) {
            videosSearchBar.text = [searchDict objectForKey:[NSString stringWithFormat:@"%@SearchString",selectedType]];
        } else {
            videosSearchBar.text = @"";
            reqMadeForSearch = NO;
            [self addVideosToTheVideoDisplayArray];
        }
    } else {
        if ([self isNotNull:[browseDict objectForKey:selectedType]]) {
            displayVideosArray = [browseDict objectForKey:selectedType];
        } else {
            displayVideosArray = [NSMutableArray arrayWithObjects:nil];
        }
        pageNumber = [[browseDict objectForKey:[NSString stringWithFormat:@"%@pgnum",selectedType]] integerValue];
        if (pageNumber < 1) {
            pageNumber = 1;
            [self makeVideoFeedOrMyVideosRequest:NO andRequestForRefresh:NO];
        }
    }
    [videosTableView reloadData];
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

- (void)removeAllObjectsDisplayVideosArrayAndAddObjects:(NSDictionary *)results inDictionary:(NSMutableDictionary *)dictionary selctType:(NSString *)selectdType {
    TCSTART
    NSMutableArray *videoArr;
    if ([self isNotNull:[dictionary objectForKey:selectdType]]) {
        videoArr = [dictionary objectForKey:selectdType];
        [videoArr addObjectsFromArray:[results objectForKey:@"videos"]];
    } else {
        videoArr = [NSMutableArray arrayWithArray:[results objectForKey:@"videos"]];
    }
    
    for (VideoModal *videoModal in videoArr) {
        [appDelegate moveLoggedInUserToTopInLikesListOfVideoModal:videoModal];
    }
    
    [dictionary setObject:videoArr forKey:selectdType];
    [dictionary setObject:[results objectForKey:@"pagenumber"] forKey:[NSString stringWithFormat:@"%@pgnum",selectdType]];
    
    if ([selectdType caseInsensitiveCompare:selectedType] == NSOrderedSame) {
        if (searchSelected && reqMadeForSearch) {
            searchPgNumber = [[dictionary objectForKey:[NSString stringWithFormat:@"%@pgnum",selectedType]] integerValue];
        } else {
            pageNumber = [[dictionary objectForKey:[NSString stringWithFormat:@"%@pgnum",selectedType]] integerValue];
        }
        displayVideosArray = [dictionary objectForKey:selectedType];
        [videosTableView reloadData];
    }
    
    TCEND
}

- (void)makeVideoFeedOrMyVideosRequest:(BOOL)pagination andRequestForRefresh:(BOOL)refresh {
    TCSTART
    if ([self isNotNull:appDelegate.loggedInUser.userId]) {
        [appDelegate showNetworkIndicator];
        if ([viewType caseInsensitiveCompare:@"VideoFeed"] == NSOrderedSame) {
            requestedForVideoFeed = NO;
            if ([selectedType caseInsensitiveCompare:@"following"] == NSOrderedSame) {
                mainVC.isVideoFeedEnterBg = NO;
                [appDelegate makeVideoFeedRequestWithPageNumber:pageNumber pageSize:10 andCaller:self];
            } else {
                mainVC.isPrivateFeedEnterBg = NO;
                [appDelegate makePrivateFeedRequestWithPageNumber:pageNumber pageSize:10 andCaller:self];
            }
            if (!refresh && pageNumber == 1 && ((appDelegate.loggedInUser.videoFeed.count > 0 && [selectedType caseInsensitiveCompare:@"following"] == NSOrderedSame) || (appDelegate.loggedInUser.privateFeed.count > 0 && [selectedType caseInsensitiveCompare:@"private"] == NSOrderedSame))) {
                if ([selectedType caseInsensitiveCompare:@"following"] == NSOrderedSame) {
                    [self removeAllObjectsDisplayVideosArrayAndAddObjects:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"pagenumber",appDelegate.loggedInUser.videoFeed,@"videos", nil] inDictionary:browseDict selctType:selectedType];
                } else {
                    [self removeAllObjectsDisplayVideosArrayAndAddObjects:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"pagenumber",appDelegate.loggedInUser.privateFeed,@"videos", nil] inDictionary:browseDict selctType:selectedType];
                }
            } else {
                if (!pagination) {
//                    [browseDict removeObjectForKey:selectedType];
                    if (!refresh) {
                        [appDelegate showActivityIndicatorInView:videosTableView andText:@"Loading"];
                    }
                }
            }
        } else {
            [appDelegate makeRequestForMypageVideosPageNumber:pageNumber perPage:10 andCaller:self];
            if (!pagination) {
                [browseDict removeObjectForKey:selectedType];
                if (!refresh) {
                    [appDelegate showActivityIndicatorInView:videosTableView andText:@"Loading"];
                }
            }
        }
    }
    TCEND
}

- (void)didFinishedGetMypageVideos:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:videosTableView];
    [self dataSourceDidFinishLoadingNewData];
    
    if ([self isNotNull:[results objectForKey:@"videos"]]) {
        //        if ([self isNotNull:[results objectForKey:@"pagenumber"]] && [[results objectForKey:@"pagenumber"] integerValue] == 2 && [self isNotNull:[browseDict objectForKey:selectedType]]) {
        //            [browseDict removeObjectForKey:selectedType];
        //        }
        [self removeAllObjectsDisplayVideosArrayAndAddObjects:results inDictionary:browseDict selctType:selectedType];
    }
    TCEND
}
- (void)didFailToGetMypageVideosWithError:(NSDictionary *)errorDict {
    TCSTART
    [self dataSourceDidFinishLoadingNewData];
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:videosTableView];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    [videosTableView reloadData];
    TCEND
}
- (void)didFinishedToGetVideoFeed:(NSDictionary *)results {
    TCSTART
//    selectedType = @"following";
//    selectedType = @"private";
//    if ([selectedType caseInsensitiveCompare:@"following"] == NSOrderedSame) {
        requestedForVideoFeed = YES;
        [appDelegate hideNetworkIndicator];
        [appDelegate removeNetworkIndicatorInView:videosTableView];
        [self dataSourceDidFinishLoadingNewData];
        if ([self isNotNull:[results objectForKey:@"videos"]]) {
            if ([[results objectForKey:@"pagenumber"] integerValue] == 1) {
                [browseDict removeObjectForKey:@"following"];
                appDelegate.loggedInUser.videoFeed = [results objectForKey:@"videos"];
                [appDelegate saveLoggedUserData:appDelegate.loggedInUser];
            }
            [self removeAllObjectsDisplayVideosArrayAndAddObjects:results inDictionary:browseDict selctType:@"following"];
            
        } else {
            if ([selectedType caseInsensitiveCompare:@"following"] == NSOrderedSame) {
                [videosTableView reloadData];
            }
        }
        if ([selectedType caseInsensitiveCompare:@"following"] == NSOrderedSame) {
            if (displayVideosArray.count == 0 && appDelegate.loggedInUser.totalNoOfFollowings.intValue <= 0) {
                friendFinderVC.pageNumber = 1;
                [friendFinderVC makeRequestForSuggestedUsersForFirstTime];
            }
        }
        
        mainVC.videofeedIndicatorLbl.hidden = YES;
//    }
    TCEND
}

- (void)didFailToGetVideoFeedWithError:(NSDictionary *)errorDict {
    TCSTART
    requestedForVideoFeed = YES;
    [self dataSourceDidFinishLoadingNewData];
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:videosTableView];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    [videosTableView reloadData];
    TCEND
}

#pragma mark Private feed
- (void)didFinishedToGetPrivateFeed:(NSDictionary *)results {
    TCSTART
    requestedForVideoFeed = YES;
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:videosTableView];
    [self dataSourceDidFinishLoadingNewData];
    if ([self isNotNull:[results objectForKey:@"videos"]]) {
        if ([[results objectForKey:@"pagenumber"] integerValue] == 1) {
            [browseDict removeObjectForKey:@"private"];
            appDelegate.loggedInUser.privateFeed = [results objectForKey:@"videos"];
            [appDelegate saveLoggedUserData:appDelegate.loggedInUser];
        }
        [self removeAllObjectsDisplayVideosArrayAndAddObjects:results inDictionary:browseDict selctType:@"private"];
        
    } else {
        if ([selectedType caseInsensitiveCompare:@"private"] == NSOrderedSame) {
            [videosTableView reloadData];
        }
        
    }
    if ([selectedType caseInsensitiveCompare:@"private"] == NSOrderedSame) {
        if (displayVideosArray.count == 0 && appDelegate.loggedInUser.totalNoOfPrivateUsers.intValue <= 0) {
            friendFinderVC.pageNumber = 1;
            [friendFinderVC makeRequestForSuggestedUsersForFirstTime];
        }
    }
    mainVC.videofeedIndicatorLbl.hidden = YES;
    TCEND
}

- (void)didFailToGetPrivateFeedWithError:(NSDictionary *)errorDict {
    TCSTART
    requestedForVideoFeed = YES;
    [self dataSourceDidFinishLoadingNewData];
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:videosTableView];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    [videosTableView reloadData];
    TCEND
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onClickOfQuickLinksBtn:(id)sender {
    TCSTART
    if ([self isNotNull:mainVC] && [mainVC respondsToSelector:@selector(onClickOfMenuButton)]) {
        [mainVC onClickOfMenuButton];
    }
    TCEND
}

/** When clicked on search button adjusting all UI objects frames
 */
- (IBAction)onClickOfSearchBtn:(id)sender {
    TCSTART
    UIButton *searchBtn = (UIButton *)sender;
    if (displayVideosArray.count == 0 && requestedForVideoFeed && !searchSelected && [self isNotNull:friendFinderVC]) {
        [friendFinderVC onClickOfSearchBtn:searchBtn];
    } else {
        CGFloat searchBarHeight = videosSearchBar.frame.size.height;
        if (!videoLoadingView.isHidden) {
            //        searchBarHeight = searchBarHeight + 30;
            videosSearchBar.frame = CGRectMake(videosSearchBar.frame.origin.x, 92, videosSearchBar.frame.size.width, videosSearchBar.frame.size.height);
        } else {
            videosSearchBar.frame = CGRectMake(videosSearchBar.frame.origin.x, 42, videosSearchBar.frame.size.width, videosSearchBar.frame.size.height);
        }
        if (searchBtn.tag == 1) {
            refreshView.hidden = YES;
            [videosSearchBar becomeFirstResponder];
            searchBtn.tag = 123;
            searchSelected = YES;
            //Search
            searchBtn.frame = CGRectMake(250, searchBtn.frame.origin.y, 65, searchBtn.frame.size.height);
            [searchBtn setBackgroundImage:[UIImage imageNamed:@"SearchCancel"] forState:UIControlStateNormal];
            [searchBtn setBackgroundImage:[UIImage imageNamed:@"SearchCancel_f"] forState:UIControlStateHighlighted];
            [searchBtn setTitle:@"Cancel" forState:UIControlStateNormal];
            videosSearchBar.hidden = NO;
            searchBarBg.hidden = NO;
            [self adjustAllButtonsInScreenWithOriginY:searchBarHeight];
        } else {
            reqMadeForSearch = NO;
            refreshView.hidden = NO;
            [videosSearchBar resignFirstResponder];
            searchBtn.tag = 1;
            //cancel
            searchSelected = NO;
            videosSearchBar.hidden = YES;
            searchBarBg.hidden = YES;
            searchPgNumber = 1;
            videosSearchBar.text = @"";
            [searchDict removeAllObjects];
            
            searchBtn.frame = CGRectMake(285, searchBtn.frame.origin.y, 30, searchBtn.frame.size.height);
            [searchBtn setBackgroundImage:[UIImage imageNamed:@"HomeSearch"] forState:UIControlStateNormal];
            [searchBtn setBackgroundImage:[UIImage imageNamed:@"HomeSearch"] forState:UIControlStateHighlighted];
            [searchBtn setTitle:@"" forState:UIControlStateNormal];
            [self adjustAllButtonsInScreenWithOriginY:-searchBarHeight];
            [videosTableView reloadData];
            [self addVideosToTheVideoDisplayArray];
        }
    }
    
    TCEND
}

- (void)adjustAllButtonsInScreenWithOriginY:(CGFloat)searchBarY {
    TCSTART
    
    followingFeedBtn.frame = CGRectMake(followingFeedBtn.frame.origin.x, followingFeedBtn.frame.origin.y + searchBarY, followingFeedBtn.frame.size.width, followingFeedBtn.frame.size.height);
    feedBgImgView.frame = CGRectMake(feedBgImgView.frame.origin.x, feedBgImgView.frame.origin.y + searchBarY, feedBgImgView.frame.size.width, feedBgImgView.frame.size.height);
    privateFeedBtn.frame = CGRectMake(privateFeedBtn.frame.origin.x, privateFeedBtn.frame.origin.y + searchBarY, privateFeedBtn.frame.size.width, privateFeedBtn.frame.size.height);
    
    videosTableView.frame = CGRectMake(videosTableView.frame.origin.x, videosTableView.frame.origin.y + searchBarY, videosTableView.frame.size.width, videosTableView.frame.size.height - searchBarY);
    TCEND
}

#pragma mark Tableview Delegate and Datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //    return displayVideosArray.count;
    int pgnum;
    if ([viewType caseInsensitiveCompare:@"VideoFeed"] == NSOrderedSame) {
        pgnum = pageNumber;
    } else {
        pgnum = pageNumber - 1;
    }
    if(displayVideosArray.count >= ((searchSelected && reqMadeForSearch)?searchPgNumber:pgnum) * 10 && displayVideosArray.count > 0) {
        return displayVideosArray.count + 1;
    } else {
        return displayVideosArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == displayVideosArray.count) {
        return 40;
    } else {
        return [self getHeightOfRowInSection:indexPath];
    }
}

- (CGFloat)getHeightOfRowInSection:(NSIndexPath *)indexPath {
    TCSTART
    if (indexPath.section == 0) {
        VideoModal *video = [displayVideosArray objectAtIndex:indexPath.row];
        CGFloat height;
        if ([self isNotNull:video]) {
            if ([video.numberOfCmnts integerValue] <= 0 && [video.numberOfLikes integerValue] <= 0 && [video.numberOfTags integerValue] <= 0) {
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
    TCSTART
    if (displayVideosArray.count == 0 && requestedForVideoFeed && !searchSelected) {
//        if ([selectedType caseInsensitiveCompare:@"following"] == NSOrderedSame) {
//            return videosTableView.frame.size.height - 40;
//        } else if ([selectedType caseInsensitiveCompare:@"private"] == NSOrderedSame) {
//            return 50;
//        }
        return videosTableView.frame.size.height - 40;
    } else {
        if (searchSelected && reqMadeForSearch && displayVideosArray.count == 0 && videosSearchBar.text.length > 0) {
            return 40;
        }
    }
    return 0;
    TCEND
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TCSTART
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
    if (displayVideosArray.count == 0 && requestedForVideoFeed && !searchSelected) {
        
        headerView.backgroundColor = [UIColor clearColor];
        
        UILabel *notificationTextLbl = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, videosTableView.frame.size.width-10, 50)];
        notificationTextLbl.numberOfLines = 0;
        notificationTextLbl.backgroundColor = [UIColor clearColor];
        notificationTextLbl.font = [UIFont fontWithName:descriptionTextFontName size:14];
        notificationTextLbl.textAlignment = UITextAlignmentCenter;
        if ([appDelegate statusForNetworkConnectionWithOutMessage]) {
            if ([selectedType caseInsensitiveCompare:@"private"] == NSOrderedSame) {
                if (appDelegate.loggedInUser.totalNoOfPrivateUsers.intValue <= 0) {
                    notificationTextLbl.backgroundColor = [UIColor whiteColor];
                    notificationTextLbl.frame = CGRectMake(5, 0, videosTableView.frame.size.width-10, 40);
                    notificationTextLbl.text = @"No private videos available, Add your connections to private group";
                    if ([self isNull:friendFinderVC]) {
                        friendFinderVC = [[FriendFinderViewController alloc] initWithNibName:@"FriendFinderViewController" bundle:nil];
                    } else {
                        
                    }
                    [friendFinderVC setFrameForView:headerView.frame];
                    [headerView addSubview:friendFinderVC.view];
                    friendFinderVC.superVC = self;
                } else {
                    notificationTextLbl.text = @"No Private Videos available, Click on the camera to create one to share to your private group connections";
                }
            } else {
                if (appDelegate.loggedInUser.totalNoOfFollowings.intValue <= 0) {
                    notificationTextLbl.frame = CGRectMake(5, 0, videosTableView.frame.size.width-10, 40);
                    notificationTextLbl.text = @"No video feeds available, Follow your connections and see what they've shared";
                    notificationTextLbl.backgroundColor = [UIColor whiteColor];
                    if ([self isNull:friendFinderVC]) {
                        friendFinderVC = [[FriendFinderViewController alloc] initWithNibName:@"FriendFinderViewController" bundle:nil];
                    } else {
                        
                    }
                    [friendFinderVC setFrameForView:headerView.frame];
                    [headerView addSubview:friendFinderVC.view];
                    friendFinderVC.superVC = self;
                } else {
                    notificationTextLbl.text = @"No video feeds available, Click on the camera to create one to share to your followers";
                }
            }
        } else {
            notificationTextLbl.text = @"Video feeds not available at this moment, We are facing trouble with your internet access, Try again";
        }
        [headerView addSubview:notificationTextLbl];
    } else {
        if (searchSelected && reqMadeForSearch && displayVideosArray.count <= 0 && section == 0 && videosSearchBar.text.length > 0) {
            headerView.frame = CGRectMake(0, 0, 320, 40);
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
    }
    return headerView;
    TCEND
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if(indexPath.row == displayVideosArray.count) {
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
        
        if ([viewType caseInsensitiveCompare:@"videofeed"] == NSOrderedSame) {
            //            cell.deleteBtn.hidden = YES;
            cell.videoTitleLbl.hidden = YES;
            cell.videosViewsLbl.hidden = YES;
            cell.viewsLbl.hidden = YES;
            cell.videoCreatedLbl.hidden = YES;
            cell.videoDisplayTimeLbl.hidden = YES;
        } else {
            cell.userPicBtn.hidden = YES;
            cell.userNameLbel.hidden = YES;
            cell.userProfileImgView.hidden = YES;
            cell.latestTagLbl.hidden = YES;
            cell.userInfoBgImgView.hidden = YES;
            cell.videoFeedDisplayTimeLbl.hidden = YES;
            cell.videoFeedCreatedLbl.hidden = YES;
            //            [cell.deleteBtn addTarget:self action:@selector(deleteVideo: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        VideoModal *video = [displayVideosArray objectAtIndex:indexPath.row];
        
        cell.tagsViewBgLbl.backgroundColor = [appDelegate colorWithHexString:@"fafafa"];
        
        
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
        
        if ([viewType caseInsensitiveCompare:@"videofeed"] == NSOrderedSame) {
            //Tag expression
            NSString *tagExpreStr;
            if ([self isNotNull:video.latestTagExpression]) {
                tagExpreStr = video.latestTagExpression;
            } else {
                tagExpreStr = video.title;
            }
            
            cell.latestTagLbl.text = tagExpreStr;
            cell.latestTagLbl.frame = CGRectMake(0, cell.latestTagLbl.frame.origin.y, 320, cell.latestTagLbl.frame.size.height);
        }
        
        // userphoto
        if ([self isNotNull:video.userPhoto]) {
            [cell.userProfileImgView setImageWithURL:[NSURL URLWithString:video.userPhoto] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached];
        } else {
            cell.userProfileImgView.image = [UIImage imageNamed:@"OwnerPic"];
        }
        
        cell.userProfileImgView.layer.cornerRadius = 17.5;
        cell.userProfileImgView.layer.borderWidth = 1.5f;
        cell.userProfileImgView.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
        cell.userProfileImgView.layer.masksToBounds = YES;
        
        // username
        if ([self isNotNull:video.userName]) {
            cell.userNameLbel.text = video.userName;
        } else {
            cell.userNameLbel.text = @"";
        }
        
        if ([self isNotNull:video.userId] && [viewType caseInsensitiveCompare:@"videofeed"] == NSOrderedSame) {
            cell.userPicBtn.hidden = NO;
            cell.userPicBtn.tag = [video.userId intValue];
            [cell.userPicBtn addTarget:self action:@selector(onClickOfUserNameBtn:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            cell.userPicBtn.hidden = YES;

        }
        
        //Video display time
        if ([self isNotNull:video.creationTime]) {
            cell.videoDisplayTimeLbl.text = [appDelegate relativeDateString:video.creationTime];
            cell.videoFeedDisplayTimeLbl.text = [appDelegate relativeDateString:video.creationTime];
        } else {
            cell.videoDisplayTimeLbl.text = @"";
            cell.videoFeedDisplayTimeLbl.text = @"";
        }
        
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
        
        //options view
        CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
        //        NSLog(@"Row height:%f",cellRect.size.height);
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
    if ([video.numberOfTags integerValue] <= 0 && [video.numberOfLikes integerValue] <= 0  && [video.numberOfCmnts integerValue] <= 0) {
        cell.tagsViewsBg.hidden = YES;
        cell.tagsViewBgLbl.hidden = YES;
    } else {
        CGFloat tagsViewBgWidth = cell.tagsView.frame.size.width + cell.likesView.frame.size.width + cell.commentsView.frame.size.width;
        if ([video.numberOfTags integerValue] <= 0) {
            tagsViewBgWidth = tagsViewBgWidth - cell.tagsView.frame.size.width;
            cell.tagsView.hidden = YES;
            cell.tagsView.frame = CGRectMake(0, 0, 0, 30);
        }
        
        if ([video.numberOfLikes integerValue] <= 0) {
            tagsViewBgWidth = tagsViewBgWidth - cell.likesView.frame.size.width;
            cell.likesView.hidden = YES;
            cell.likesView.frame = CGRectMake(cell.tagsView.frame.origin.x + cell.tagsView.frame.size.width, 0, 0, 30);
        } else {
            cell.likesView.frame = CGRectMake(cell.tagsView.frame.origin.x + cell.tagsView.frame.size.width, 0, 75, 30);
        }
        
        if ([video.numberOfCmnts integerValue] <= 0) {
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
    VideoModal *video = [displayVideosArray objectAtIndex:indexPath.row];
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
            if (i == 0 && [self isNotNull:[dict objectForKey:@"user_id"]] && [[dict objectForKey:@"user_id"] intValue] == appDelegate.loggedInUser.userId.intValue) {
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
        //        cell.lovedPersonsView.frame = CGRectMake(0, 0, 0, 0);
        cell.lovedPersonsView.hidden = YES;
    }
    
    TCEND
}

- (void) addCommentViewToTheCell:(MyPageVideoCell *)cell andIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    VideoModal *video = [displayVideosArray objectAtIndex:indexPath.row];
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
    if (userNameBtn.tag != [appDelegate.loggedInUser.userId integerValue]) {
        appDelegate.isVideoFeedVCDisplays = NO;
        OthersPageViewController *otherPageVC = [[OthersPageViewController alloc] initWithNibName:@"OthersPageViewController" bundle:Nil andUser:[NSString stringWithFormat:@"%d",userNameBtn.tag]];
        [self.navigationController pushViewController:otherPageVC animated:YES];
        otherPageVC.caller = self;
    }
    TCEND
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        if (indexPath.row == displayVideosArray.count) {
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
    if (searchSelected && reqMadeForSearch) {
        searchPgNumber = searchPgNumber + 1;
        [self makeSearchRequestWithSearchString:videosSearchBar.text andPageNumber:searchPgNumber requestForPagination:YES];
    } else {
        pageNumber = pageNumber + 1;
        [self makeVideoFeedOrMyVideosRequest:YES andRequestForRefresh:NO];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    //    MyPageVideoDetailsViewController *detailsVC = [[MyPageVideoDetailsViewController alloc] initWithNibName:@"MyPageVideoDetailsViewController" bundle:Nil];
    //    [mainVC.navigationController pushViewController:detailsVC animated:YES];
    TCEND
}

#pragma mark optionsView
- (void)onClickOfOptionsBtn:(id)sender  withEvent:(UIEvent *)event {
    TCSTART
    //    [ShowAlert showAlert:@"In Development"];
    selectedIndexPath = [appDelegate getIndexPathForEvent:event ofTableView:videosTableView];
    VideoModal *video = [displayVideosArray objectAtIndex:selectedIndexPath.row];
    UIActionSheet *actionSheet;
    
    if (video.userId.integerValue == appDelegate.loggedInUser.userId.integerValue || [viewType caseInsensitiveCompare:@"mypagevideos"] == NSOrderedSame) {
        
        actionSheet = [[UIActionSheet alloc]
                       initWithTitle:nil
                       delegate:self
                       cancelButtonTitle:@"Cancel"
                       destructiveButtonTitle:nil
                       otherButtonTitles:@"Delete",@"Access Permission",@"Share Video",@"Copy Share URL",@"Tag", nil];
    } else {
        actionSheet = [[UIActionSheet alloc]
                       initWithTitle:nil
                       delegate:self
                       cancelButtonTitle:@"Cancel"
                       destructiveButtonTitle:nil
                       otherButtonTitles:@"Report Inappropriate",@"Share Video",@"Copy Share URL", nil];
    }
    
    actionSheet.backgroundColor = [UIColor whiteColor];
    [actionSheet showInView:appDelegate.window];

    
    TCEND
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	TCSTART
	NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([buttonTitle caseInsensitiveCompare:@"Report Inappropriate"] == NSOrderedSame) {
        [self reportVideoAtIndexPath:selectedIndexPath];
    } else if([buttonTitle caseInsensitiveCompare:@"Access Permission"] == NSOrderedSame) {
        [self accessPermissionOfVideoAtIndexPath:selectedIndexPath];
    } else if([buttonTitle caseInsensitiveCompare:@"Share Video"] == NSOrderedSame) {
        [self shareVideoAtIndexPath:selectedIndexPath];
    } else if([buttonTitle caseInsensitiveCompare:@"Copy Share URL"] == NSOrderedSame) {
        VideoModal *video = [displayVideosArray objectAtIndex:selectedIndexPath.row];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = video.shareUrl;
    } else if([buttonTitle caseInsensitiveCompare:@"Tag"] == NSOrderedSame) {
        [self gotoPlayerScreenWithIndexPath:selectedIndexPath];
    } else if([buttonTitle caseInsensitiveCompare:@"Delete"] == NSOrderedSame) {
        [self deleteVideoAtIndexPAth:selectedIndexPath];
    }
	TCEND
}

#pragma mark Goto Shareviewcontroller
- (void)accessPermissionOfVideoAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [displayVideosArray objectAtIndex:indexPath.row];
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
        VideoModal *video = [displayVideosArray objectAtIndex:indexPath.row];
        if ([self isNotNull:video]) {
            appDelegate.isVideoFeedVCDisplays = NO;
            ShareViewController *shareVC = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil withSelectedVideo:video andCaller:self];
            [self.navigationController pushViewController:shareVC animated:YES];
        }
    }
    TCEND
}

- (void)deleteVideoAtIndexPAth:(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [displayVideosArray objectAtIndex:indexPath.row];
        if ([self isNotNull:video]) {
            [appDelegate showActivityIndicatorInView:self.view andText:@"Deleting"];
            [appDelegate showNetworkIndicator];
            [appDelegate makeRequestForDeleteVideoWithVideoId:video.videoId andUserId:appDelegate.loggedInUser.userId andCaller:self atIndexpath:indexPath];
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
        [displayVideosArray removeObjectAtIndex:indexPath.row];
        NSInteger numberOfVideos = [appDelegate.loggedInUser.totalNoOfVideos intValue];
        numberOfVideos = numberOfVideos - 1;
        appDelegate.loggedInUser.totalNoOfVideos = [NSNumber numberWithInt:numberOfVideos];
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

#pragma mark Report Video Delegate methods
- (void)reportVideoAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [displayVideosArray objectAtIndex:indexPath.row];
        if ([self isNotNull:video]) {
            ReportVideoViewController *reportVC = [[ReportVideoViewController alloc] initWithNibName:@"ReportVideoViewController" bundle:nil forVideo:video.videoId];
            if ([self isNotNull:mainVC]) {
                [mainVC presentViewController:reportVC animated:YES completion:nil];
            } else {
                [self presentViewController:reportVC animated:YES completion:nil];
            }
        }
    }
    TCEND
}


#pragma mark Get All Likes Delegate Methods
- (void)onClickOfGetAllVideoUsersLoved:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:videosTableView];
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [displayVideosArray objectAtIndex:indexPath.row];
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
        VideoModal *video = [displayVideosArray objectAtIndex:indexPath.row];
        //        if ([self isNotNull:video]) {
        //            [appDelegate makeRequestForLikeVideoWithVideoId:video.videoId andCaller:self andIndexPaht:indexPath];
        //        }
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
        VideoModal *video = [displayVideosArray objectAtIndex:indexpath.row];
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
        VideoModal *video = [displayVideosArray objectAtIndex:indexpath.row];
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
        VideoModal *video = [displayVideosArray objectAtIndex:indexPath.row];
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
    }  else {
        count = [video.numberOfLikes integerValue];
    }
    
    allCmntsVC = [[AllCommentsViewController alloc] initWithNibName:@"AllCommentsViewController" bundle:nil withVideoModal:video user:nil viewType:type andSelectedIndexPath:indexPath andTotalCount:count andCaller:self];
    appDelegate.isVideoFeedVCDisplays = NO;
    if ([type caseInsensitiveCompare:@"Comment"] == NSOrderedSame) {
         [mainVC.navigationController pushViewController:allCmntsVC animated:YES];
    } else {
        [self.navigationController pushViewController:allCmntsVC animated:YES];
    }
   
    TCEND
}

- (void)allCommentsScreenDismissCalledSelectedIndexPath:(NSIndexPath *)indexPath andViewType:(NSString *)viewType_ {
    TCSTART
    if ([self isNotNull:indexPath]) {
        if ([viewType_ caseInsensitiveCompare:@"Like"] == NSOrderedSame) {
            VideoModal *video = [displayVideosArray objectAtIndex:indexPath.row];
            [appDelegate moveLoggedInUserToTopInLikesListOfVideoModal:video];
        }
        [videosTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self setBoolValueForControllerVariable];
    mainVC.customTabView.hidden = NO;
    allCmntsVC = nil;
    customMoviePlayerVC = nil;
    TCEND
}

#pragma mark Video Play
- (void)playVideo:(id)sender withEvent:(UIEvent *)event  {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:videosTableView];
    [self gotoPlayerScreenWithIndexPath:indexPath];
    TCEND
}

- (void)gotoPlayerScreenWithIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [displayVideosArray objectAtIndex:indexPath.row];
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
            video = [displayVideosArray objectAtIndex:indexPath.row];
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
        if ([self isNotNull:mainVC]) {
            [mainVC presentViewController:customMoviePlayerVC animated:YES completion:nil];
        } else {
            [self presentViewController:customMoviePlayerVC animated:YES completion:nil];
        }
        customMoviePlayerVC.caller = self;
        customMoviePlayerVC.selectedIndexPath = [results objectForKey:@"indexpath"];
    }
    TCEND
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        reqMadeForSearch = YES;
        NSString *searchType;
        [searchDict setObject:searchString forKey:[NSString stringWithFormat:@"%@SearchString",selectedType]];
        //
        if ([selectedType caseInsensitiveCompare:@"following"] == NSOrderedSame) {
            searchType = @"videofeedsearch";
        } else if ([selectedType caseInsensitiveCompare:@"private"] == NSOrderedSame) {
            searchType = @"pvtgroup_videofeedsearch";
        } else {
            searchType = @"mypagesearch";
        }
        [appDelegate makeRequestForSearchWithString:searchString ofSearchType:searchType pageNumber:pgnum anduserId:appDelegate.loggedInUser.userId andCaller:self];
        if (!pagination) {
            [searchDict removeObjectForKey:selectedType];
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
        NSString *searchReqType;
        if ([self isNotNull:[results objectForKey:@"searchRequestType"]]) {
            if ([[results objectForKey:@"searchRequestType"] caseInsensitiveCompare:@"videofeedsearch"] == NSOrderedSame) {
                searchReqType = @"following";
            } else if ([[results objectForKey:@"searchRequestType"] caseInsensitiveCompare:@"pvtgroup_videofeedsearch"] == NSOrderedSame) {
                searchReqType = @"private";
            } else {
                searchReqType = @"myvideos";
            }
        }
        [self removeAllObjectsDisplayVideosArrayAndAddObjects:results inDictionary:searchDict selctType:searchReqType?:selectedType];
        //        [videosTableView reloadData];
    } else {
        [videosTableView reloadData];
    }
    TCEND
}

- (void)didFailToGetSearchReqDetailsWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:self.view];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    [videosTableView reloadData];
    TCEND
}

#pragma mark Scrolling Overrides
#pragma mark TableScrollView Delegate Methods Refreshing Table
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    @try {
        [self completedVideoUploading];
        [videosSearchBar resignFirstResponder];
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
            [self refreshTheScreen];
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

-(void)dataSourceDidFinishLoadingNewData {
    
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

- (void)refreshTheScreen {
    if (!searchSelected) {
        if ([viewType caseInsensitiveCompare:@"VideoFeed"] == NSOrderedSame) {
            pageNumber = 1;
        } else {
            pageNumber = 2;
        }
        [self completedVideoUploading];
        [self makeVideoFeedOrMyVideosRequest:NO andRequestForRefresh:YES];
    }
}
- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    TCSTART
    NSLog(@"VideofeedVC Disappear");
    [super viewWillDisappear:animated];
    TCEND
}
- (void)viewDidUnload {
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
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
