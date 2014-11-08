/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "BrowseDetailViewController.h"
#import "ShareViewController.h"
#import "OthersPageViewController.h"
#import "ReportVideoViewController.h"
@interface BrowseDetailViewController () {
    CustomMoviePlayerViewController *customMoviePlayerVC;
}

@end

@implementation BrowseDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withVideosArray:(NSArray *)videosArray selectedIndex:(NSInteger)index
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        allBrowseVideosArray = [[NSMutableArray alloc] initWithArray:videosArray];
        selectedIndex = index;
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    TCSTART
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height-20);
    if (appDelegate.window.frame.size.height > 480) {
        viewScrollView.frame = CGRectMake(0, 41, 320, 460);
    } else {
        viewScrollView.frame = CGRectMake(0, 41, 320, 370);
        loadingLbl.frame = CGRectMake(0, 0, 320, 410);
    }
    [viewScrollView setContentSize:CGSizeMake(320, 410)];
    
    loadingLbl.hidden = YES;
    
    [self enablePreviousNextButtons];
    
    TCEND
}

- (void)viewWillAppear:(BOOL)animated {
//    mainVC.customTabView.hidden = NO;
}

#pragma mark Browse Detail
- (void)makeVideoDetailRequestWithVideoId:(NSString *)videoId pageNumber:(NSInteger)pgNum andUserID:(NSString *)userId {
    TCSTART
    if ([self isNotNull:videoId]) {
        loadingLbl.hidden = NO;
        [appDelegate makeRequestForBrowseDetailOfVideo:videoId andUserId:userId pageNumber:1 andCaller:self];
        [appDelegate showActivityIndicatorInView:viewScrollView andText:@""];
        [appDelegate showNetworkIndicator];
    }
    TCEND
}

- (void)didFinishedToGetBrowseVideoDetails:(NSDictionary *)results {
    TCSTART
    [appDelegate removeNetworkIndicatorInView:viewScrollView];
    [appDelegate hideNetworkIndicator];
    loadingLbl.hidden = YES;
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"results"]] && [[results objectForKey:@"results"] count] > 0) {
        NSMutableDictionary *dict = [allBrowseVideosArray objectAtIndex:selectedIndex];
        selectedVideo = [[results objectForKey:@"results"] objectAtIndex:0];
        [dict setObject:selectedVideo forKey:@"video"];
        myOtherStuffPgNum = [[dict objectForKey:@"pgnum"] intValue];
        [self refreshTheViewWithSelectedVideo:selectedVideo];
    }
//    [self makeMyOtherStuffRequestWithPageNumber:myOtherStuffPgNum];
    TCEND
}
- (void)didFailToGetBrowseVideoDetailsWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate removeNetworkIndicatorInView:viewScrollView];
    [appDelegate hideNetworkIndicator];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

#pragma mark Myotherstuff
- (void)makeMyOtherStuffRequestWithPageNumber:(NSInteger)pgNum {
    TCSTART
    if ([self isNotNull:selectedVideo.userId]) {
        [appDelegate makeRequestForOtherStuffOfUserId:selectedVideo.userId pageNumber:pgNum andCaller:self];
        [appDelegate showNetworkIndicator];
    } else {
        [ShowAlert showError:@"UserId should not be null"];
        [self stopAnimating];
        myOtherStuffPgNum = myOtherStuffPgNum - 1;
    }
    TCEND
}

- (void)didFinishedToGetOtherStuffDetails:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    NSMutableArray *otherStuff = [selectedVideo.myotherStuff mutableCopy];
    [otherStuff addObjectsFromArray:[results objectForKey:@"videos"]];
    selectedVideo.myotherStuff = otherStuff;
    
    NSMutableDictionary *dict = [allBrowseVideosArray objectAtIndex:selectedIndex];
    [dict setObject:selectedVideo forKey:@"video"];
    [dict setObject:[NSNumber numberWithInt:myOtherStuffPgNum] forKey:@"pgnum"];
    
    [self addViewsToTheScrollView];
    TCEND
}

- (void)didFailToGetOtherStuffDetailsWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [self stopAnimating];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    myOtherStuffPgNum = myOtherStuffPgNum - 1;
    TCEND
}

- (void)enablePreviousNextButtons {
    TCSTART
    if (selectedIndex < allBrowseVideosArray.count) {
        nextButton.hidden = false;
    } else {
        nextButton.hidden = true;
    }
    
    if (selectedIndex <= 0) {
        previousButton.hidden = true;
    } else {
        previousButton.hidden = false;
    }
    
    if (selectedIndex >= 0 && selectedIndex < allBrowseVideosArray.count) {
        NSDictionary *dict = [allBrowseVideosArray objectAtIndex:selectedIndex];
        if ([self isNotNull:[dict objectForKey:@"video"]]) {
            selectedVideo = [dict objectForKey:@"video"];
            myOtherStuffPgNum = [[dict objectForKey:@"pgnum"] intValue];
            [self refreshTheViewWithSelectedVideo:selectedVideo];
        } else {
            [self makeVideoDetailRequestWithVideoId:[dict objectForKey:@"video_id"] pageNumber:1 andUserID:[dict objectForKey:@"user_id"]];
        }
    }
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

- (void)refreshTheViewWithSelectedVideo:(VideoModal *)videoObject {
    TCSTART
    //Video ThumbPath
    headerLabl.text = videoObject.title;
    if ([self isNotNull:videoObject.videoThumbPath]) {
        [videoThumbPath setImageWithURL:[NSURL URLWithString:videoObject.videoThumbPath] placeholderImage:[UIImage imageNamed:@"DefaultVideoThumb"]];
    } else {
        videoThumbPath.image = [UIImage imageNamed:@"DefaultVideoThumb"];
    }
    
    
    if ([self isNotNull:videoObject.userPhoto]) {
        [profilePic setImageWithURL:[NSURL URLWithString:videoObject.userPhoto] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached];
    } else {
        profilePic.image = [UIImage imageNamed:@"OwnerPic"];
    }
    profilePic.layer.cornerRadius = 16.5f;
    profilePic.layer.borderWidth = 1.5f;
    profilePic.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
    profilePic.layer.masksToBounds = YES;
    
    videoInfoBgLbl.backgroundColor = [appDelegate colorWithHexString:@"fafafa"];
    
    dividerLabel.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
    dividerLbl.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
    
    if ([self isNotNull:videoObject.userName]) {
        userNameLabel.text = videoObject.userName;
    } else {
        userNameLabel.text = @"";
    }
    
//    if ([self isNotNull:videoObject.title]) {
//        videoTitleLbl.text = videoObject.title;
//    } else {
//        videoTitleLbl.text = @"";
//    }
    
    if ([self isNotNull:videoObject.latestTagExpression]) {
        videoTitleLbl.text = videoObject.latestTagExpression;
    } else {
        videoTitleLbl.text = videoObject.title?:@"";
    }
    
    if ([self isNotNull:videoObject.info]) {
        videoInfoLbl.text = videoObject.info;
    } else {
        videoInfoLbl.text = @"";
    }
    
    if ([self isNotNull:videoObject.creationTime]) {
         videoCreatedlbl.text = [appDelegate relativeDateString:videoObject.creationTime];
    } else {
         videoCreatedlbl.text = @"";
    }
    

    if ([self isNotNull:videoObject.numberOfViews]) {
        videoViewsLabel.text = [NSString stringWithFormat:@"%@",[appDelegate getUserStatisticsFormatedString:[videoObject.numberOfViews longLongValue]]];
    } else {
        videoViewsLabel.text = @"";
    }
    
    
    if ([self isNotNull:videoObject.numberOfCmnts]) {
        numberOfCmntsLabel.text = [NSString stringWithFormat:@"%@ Comment%@",[appDelegate getUserStatisticsFormatedString:[videoObject.numberOfCmnts longLongValue]],[appDelegate returningPluralFormWithCount:[videoObject.numberOfCmnts integerValue]]];
    } else {
        numberOfCmntsLabel.text = @"";
    }
    
    if ([self isNotNull:videoObject.numberOfLikes]) {
        numberOfLikesLabel.text = [NSString stringWithFormat:@"%@ Like%@",[appDelegate getUserStatisticsFormatedString:[videoObject.numberOfLikes longLongValue]],[appDelegate returningPluralFormWithCountForLikes:[videoObject.numberOfLikes integerValue]]];
    } else {
        numberOfLikesLabel.text = @"";
    }
    
    
    if ([self isNotNull:videoObject.numberOfTags]) {
        numberOfTagsLabel.text = [NSString stringWithFormat:@"%@ Tag%@",[appDelegate getUserStatisticsFormatedString:[videoObject.numberOfTags longLongValue]],[appDelegate returningPluralFormWithCount:[videoObject.numberOfTags integerValue]]];
    } else {
        numberOfTagsLabel.text = @"";
    }

    [self addViewsToTheScrollView];
    TCEND
}

- (void)addViewsToTheScrollView {
    TCSTART
    //Scroll view
    [self removeAllSubviewOfScrollView];
    
    CGFloat totalButtonWidth = 0.0f;
    for(int i = 0; i < selectedVideo.myotherStuff.count; i++) {
        NSDictionary *videoDict = [selectedVideo.myotherStuff objectAtIndex:i];
        UIView *videoView = [[UIView alloc] init];
        videoView.backgroundColor = [UIColor clearColor];
        videoView.frame = CGRectMake(totalButtonWidth, 0, 60, 70);
        
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
        
        [allVideosScrollView addSubview:videoView];
        totalButtonWidth += videoView.frame.size.width + ((i == (selectedVideo.myotherStuff.count - 1))?0:2);
    }
    // Update the scrollview content rect, which is the combined width of the buttons
    [allVideosScrollView setContentSize:CGSizeMake(totalButtonWidth, allVideosScrollView.frame.size.height)];
    TCEND
}
//- (NSAttributedString *)attributedStringForTimeLabel:(Video *)video {
//
//}
- (void)removeAllSubviewOfScrollView {
    TCSTART
    for (UIImageView *imageView in allVideosScrollView.subviews) {
        [imageView removeFromSuperview];
    }
    TCEND
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onClickOfNextButton:(id)sender {
    if (selectedIndex < allBrowseVideosArray.count) {
        selectedIndex = selectedIndex + 1;
        [self enablePreviousNextButtons];
    }
}
- (IBAction)onClickOfPreviousButton:(id)sender {
    if (selectedIndex > 0) {
        selectedIndex = selectedIndex - 1;
        [self enablePreviousNextButtons];
    }
}

- (IBAction)onClickOfShareButton:(id)sender {
    TCSTART
    ShareViewController *shareVC = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil withSelectedVideo:selectedVideo andCaller:self];
    [self.navigationController pushViewController:shareVC animated:YES];
//    mainVC.customTabView.hidden = YES;
    TCEND
}

-(IBAction)onClickOfLikeButton:(id)sender {
    if ([self isNotNull:selectedVideo.videoId]) {
        [appDelegate makeRequestForLikeVideoWithVideoId:selectedVideo.videoId andCaller:self andIndexPaht:nil];
    }
}

- (void)didFinishedLikeVideo:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    NSInteger likesCount = [selectedVideo.numberOfLikes integerValue];
    likesCount = likesCount + 1;
    selectedVideo.numberOfLikes = [NSNumber numberWithInteger:likesCount];
    if ([self isNotNull:selectedVideo.numberOfLikes]) {
        numberOfLikesLabel.text = [NSString stringWithFormat:@"%@ Like%@",[appDelegate getUserStatisticsFormatedString:[selectedVideo.numberOfLikes longLongValue]],[appDelegate returningPluralFormWithCountForLikes:[selectedVideo.numberOfLikes integerValue]]];
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

#pragma mark Get All Likes Delegate Methods
- (IBAction)onClickOfGetAllLikesButton:(id)sender {
    TCSTART
    if ([self isNotNull:selectedVideo]) {
        [self gotoAllCommentsScreenType:@"Like"];
    }
    TCEND
}

#pragma mark Comment Related Methods and Get All Comments Delegate methods
- (IBAction)onClickOfCommentButton:(id)sender {
    TCSTART
    if ([self isNotNull:selectedVideo]) {
        [self gotoAllCommentsScreenType:@"Comment"];
    }
    TCEND
}

- (void)gotoAllCommentsScreenType:(NSString *)type {
    TCSTART
    NSInteger count;
    if ([type caseInsensitiveCompare:@"Comment"] == NSOrderedSame) {
        count = [selectedVideo.numberOfCmnts integerValue];
        appDelegate.videoFeedVC.mainVC.customTabView.hidden = YES;
    } /*else if ([type caseInsensitiveCompare:@"Follower"] == NSOrderedSame) {
        usersArray = user.followers;
    } else if ([type caseInsensitiveCompare:@"Following"] == NSOrderedSame) {
        usersArray = user.followings;
    } */else {
        count = [selectedVideo.numberOfLikes integerValue];
    }
  
    
    allCmntsVC = [[AllCommentsViewController alloc] initWithNibName:@"AllCommentsViewController" bundle:nil withVideoModal:selectedVideo user:nil viewType:type andSelectedIndexPath:nil andTotalCount:count andCaller:self];
    
    if ([type caseInsensitiveCompare:@"Comment"] == NSOrderedSame) {
        [appDelegate.videoFeedVC.mainVC.navigationController pushViewController:allCmntsVC animated:YES];
    } else {
        [self.navigationController pushViewController:allCmntsVC animated:YES];
    }
    
//    mainVC.customTabView.hidden = YES;
    TCEND
}

- (void)allCommentsScreenDismissCalledSelectedIndexPath:(NSIndexPath *)indexPath andViewType:(NSString *)viewType {
    TCSTART
    numberOfCmntsLabel.text = [NSString stringWithFormat:@"%@ Comment%@",[appDelegate getUserStatisticsFormatedString:[selectedVideo.numberOfCmnts longLongValue]],[appDelegate returningPluralFormWithCount:[selectedVideo.numberOfCmnts integerValue]]];
    numberOfLikesLabel.text = [NSString stringWithFormat:@"%@ Like%@",[appDelegate getUserStatisticsFormatedString:[selectedVideo.numberOfLikes longLongValue]],[appDelegate returningPluralFormWithCountForLikes:[selectedVideo.numberOfLikes integerValue]]];
    numberOfTagsLabel.text = [NSString stringWithFormat:@"%@ Tag%@",[appDelegate getUserStatisticsFormatedString:[selectedVideo.numberOfTags longLongValue]],[appDelegate returningPluralFormWithCount:[selectedVideo.numberOfTags integerValue]]];
    videoViewsLabel.text = [NSString stringWithFormat:@"%@",[appDelegate getUserStatisticsFormatedString:[selectedVideo.numberOfViews longLongValue]]];
    allCmntsVC = nil;
    customMoviePlayerVC = nil;
    appDelegate.videoFeedVC.mainVC.customTabView.hidden = NO;
    TCEND
}

- (IBAction)onClickOfRememberMeButton:(id)sender {
    TCSTART
    if ([self isNotNull:selectedVideo]) {
        ReportVideoViewController *reportVC = [[ReportVideoViewController alloc] initWithNibName:@"ReportVideoViewController" bundle:nil forVideo:selectedVideo.videoId];
        [self presentViewController:reportVC animated:YES completion:nil];
    }
    TCEND
}

#pragma mark Play video
- (void)playVideoFromMoreVideos:(id)sender {
    TCSTART
    UIButton *btn = (UIButton *)sender;
    NSString *videoId = [NSString stringWithFormat:@"%d",btn.tag];
    if ([self isNotNull:videoId]) {
        [appDelegate requestForPlayBackWithVideoId:videoId andcaller:self andIndexPath:Nil refresh:YES];
    }
    TCEND
}
- (IBAction)onClickOfPlayButton:(id)sender {
    TCSTART
    if ([self isNotNull:selectedVideo]) {
        [appDelegate requestForPlayBackWithVideoId:selectedVideo.videoId andcaller:self andIndexPath:Nil refresh:NO];
    }
    TCEND
}

- (void)playBackResponse:(NSDictionary *)results {
    TCSTART
    if ([self isNotNull:results] && ![[results objectForKey:@"isResponseNull"] boolValue]) {
        VideoModal *video;
        if ([self isNotNull:[results objectForKey:@"refresh"]] && ![[results objectForKey:@"refresh"] boolValue]) {
            if ([self isNotNull:[[results objectForKey:@"results"] objectForKey:@"uid"]]) {
                selectedVideo.userId = [[results objectForKey:@"results"] objectForKey:@"uid"];
            }
            if ([self isNotNull:[[results objectForKey:@"results"] objectForKey:@"video_url"]]) {
                selectedVideo.path = [[results objectForKey:@"results"] objectForKey:@"video_url"];
            }
            if ([self isNotNull:[[results objectForKey:@"results"] objectForKey:@"username"]]) {
                selectedVideo.userName = [[results objectForKey:@"results"] objectForKey:@"username"];
            }
            if ([self isNotNull:[[results objectForKey:@"results"] objectForKey:@"user_photo"]]) {
                video.userPhoto = [[results objectForKey:@"results"] objectForKey:@"user_photo"];
            }
            video = selectedVideo;
        } else {
            if ([self isNotNull:[results objectForKey:@"video"]]) {
                video = [results objectForKey:@"video"];
            }
        }
        customMoviePlayerVC = [[CustomMoviePlayerViewController alloc] initWithNibName:@"CustomMoviePlayerViewController" bundle:nil video:video videoFilePath:nil andClientVideoId:video.videoId showInstrcutnScreen:NO];
        [self presentViewController:customMoviePlayerVC animated:YES completion:nil];
        customMoviePlayerVC.caller = self;
    }
    TCEND
}

- (IBAction)onClickOfUserPic:(id)sender {
    TCSTART
    if ([self isNotNull:selectedVideo.userId] && selectedVideo.userId.intValue != [appDelegate.loggedInUser.userId integerValue]) {
        OthersPageViewController *otherPageVC = [[OthersPageViewController alloc] initWithNibName:@"OthersPageViewController" bundle:Nil andUser:selectedVideo.userId];
        [self.navigationController pushViewController:otherPageVC animated:YES];
        otherPageVC.caller = self;
    }
    TCEND
}

#pragma mark Scroll view
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    TCSTART
    if (scrollView.tag == 10000) {
        if (selectedVideo.myotherStuff.count > 0 && selectedVideo.myotherStuff.count >= myOtherStuffPgNum * 10) {
            [scrollView setContentSize:CGSizeMake(scrollView.contentSize.width + 60, scrollView.frame.size.height)];
            CGRect frame;
            frame.origin.x = scrollView.frame.size.width;
            frame.origin.y = 0;
            frame.size = scrollView.frame.size;
            [scrollView scrollRectToVisible:frame animated:YES];
            
            UIActivityIndicatorView *activityIndicator_view = (UIActivityIndicatorView *)[scrollView viewWithTag:-7000];
            if (!activityIndicator_view) {
                activityIndicator_view = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                activityIndicator_view.tag = -7000;
                [scrollView addSubview:activityIndicator_view];
                activityIndicator_view.frame = CGRectMake(scrollView.contentSize.width - 40, 20, 20, 20);
            }
            NSLog(@"ActvitityIndicator frame : %f %f %f %f",activityIndicator_view.frame.origin.x,activityIndicator_view.frame.origin.y,activityIndicator_view.frame.size.width,activityIndicator_view.frame.size.height);
            [activityIndicator_view startAnimating];
            [self loadMoreMyOtherStuff];
        }
    }
    
    TCEND
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidEndScrollingAnimation");
}
- (void)loadMoreMyOtherStuff {
    TCSTART
    myOtherStuffPgNum = myOtherStuffPgNum + 1;
    [self makeMyOtherStuffRequestWithPageNumber:myOtherStuffPgNum];
    TCEND
}

- (void)stopAnimating {
    TCSTART
    UIActivityIndicatorView *activityIndicator_view = (UIActivityIndicatorView *)[allVideosScrollView viewWithTag:-7000];
    [activityIndicator_view stopAnimating];
    [allVideosScrollView setContentSize:CGSizeMake(allVideosScrollView.contentSize.width - 60, allVideosScrollView.frame.size.height)];
    CGRect frame;
    frame.origin.x = allVideosScrollView.frame.size.width;
    frame.origin.y = 0;
    frame.size = allVideosScrollView.frame.size;
    [allVideosScrollView scrollRectToVisible:frame animated:YES];
    TCEND
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
