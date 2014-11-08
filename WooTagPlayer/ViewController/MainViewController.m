/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "MainViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "NSObject+PE.h"

#import "SWRevealViewController.h"

#import "CustomMoviePlayerViewController.h"
#import "NSData+MD5.h"
#import "RecordingViewController.h"
#import "TrimVideoViewController.h"

#import "NotificationsViewController.h"
#import "SBJson.h"

@interface MainViewController() <SWRevealViewControllerDelegate> {
    SWRevealViewController *swRevealCntr;
    CustomMoviePlayerViewController *customMoviePlayerVC;
}

@end
@implementation MainViewController
@synthesize customTabView;
@synthesize notificationsIndicatorLbl;
@synthesize videofeedIndicatorLbl;

@synthesize isVideoFeedEnterBg;
@synthesize isPrivateFeedEnterBg;
@synthesize isBrowseVideosEnterBg;
@synthesize isBrowsePeopleEnterBg;
@synthesize isBrowseTagsEnterBg;
@synthesize isBrowseTrendsEnterBg;
@synthesize isNotificationsEnterBg;
@synthesize isMypageEnterBg;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        if (self) {
            // Custom initialization
            appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication]delegate];
            if(&UIApplicationDidEnterBackgroundNotification != nil)
            {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
            }
            
            if(&UIApplicationWillEnterForegroundNotification != nil)
            {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
            }
        }
    return self;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    TCSTART
    if ([self isNotNull:appDelegate.loggedInUser]) {
        NSLog(@"applicationDidEnterBackground Main vc");
        [self setBoolValuesForAllVaribles];
    }
    TCEND
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    TCSTART
    if ([self isNotNull:appDelegate.loggedInUser]) {
        NSLog(@"applicationWillEnterForeground Main vc");
        [self refreshAllScreens];
    }
    TCEND
}

- (void)setBoolValuesForAllVaribles {
    isVideoFeedEnterBg = YES;
    isPrivateFeedEnterBg = YES;
    isBrowseVideosEnterBg = YES;
    isBrowsePeopleEnterBg = YES;
    isBrowseTagsEnterBg = YES;
    isBrowseTrendsEnterBg = YES;
    isNotificationsEnterBg = YES;
    isMypageEnterBg = YES;
}

- (void)refreshVideofeed:(BOOL)videofeed NotificationsScreen:(BOOL)notification{
    TCSTART
    if (videofeed) {
        isVideoFeedEnterBg = YES;
        isPrivateFeedEnterBg = YES;
        if ([self isNotNull:videoFeedNavVC] && !videoFeedNavVC.view.hidden) {
            [self refreshVideoFeedScreen];
        }
    } else if (notification) {
        isNotificationsEnterBg = YES;
        if ([self isNotNull:notificationsNavVC] && !notificationsNavVC.view.hidden) {
            [self refreshNotificationsPage];
        }
    }
    TCEND
}

- (void)refreshAllScreens {
    TCSTART
    if ([self isNotNull:appDelegate.loggedInUser]) {
        [self setBoolValuesForAllVaribles];
        if ([self isNotNull:videoFeedNavVC] && !videoFeedNavVC.view.hidden) {
            [self refreshVideoFeedScreen];
        } else if ([self isNotNull:browseNavVC] && !browseNavVC.view.hidden) {
            [self refreshBrowseScreen];
        } else if ([self isNotNull:notificationsNavVC] && !notificationsNavVC.view.hidden) {
            [self refreshNotificationsPage];
        } else if ( [self isNotNull:myPageNavVC] && !myPageNavVC.view.hidden) {
            [self refreshMypageVideos];
        }
    }
    TCEND
}

- (void)removeAllTabsFromVC {
    TCSTART
    [self removeObservers];
    if ( browseNavVC) {
        [browseNavVC.view removeFromSuperview];
        browseNavVC = nil;
    }
    
    if (videoFeedNavVC) {
        [appDelegate.videoFeedVC removeObservers];
        [videoFeedNavVC.view removeFromSuperview];
        videoFeedNavVC = nil;
    }
    
    if (myPageNavVC) {
        [myPageNavVC.view removeFromSuperview];
        myPageNavVC = nil;
    }
    
    if (notificationsNavVC ) {
        [notificationsNavVC.view removeFromSuperview];
        notificationsNavVC = nil;
    }
    TCEND
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    TCSTART
        [super viewDidLoad];
        notificationsIndicatorLbl.hidden = YES;
        videofeedIndicatorLbl.hidden = YES;
        swRevealCntr = [self revealViewController];
        [self.view addGestureRecognizer:swRevealCntr.panGestureRecognizer];
        NSLog(@"ViewFrame in view didload: %f %f %f %f",self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width, self.view.frame.size.height);
    
        [self bringAllFooterIconsToFront];
        if (appDelegate.loggedInUser.totalNoOfFollowings.intValue > 0 || appDelegate.loggedInUser.totalNoOfPrivateUsers.intValue > 0) {
            [self disPlayVideoFeed:videoFeed_Btn];
        } else {
            [self displayBrowseView:browse_Btn];
        }
    TCEND
}

- (void) viewDidLayoutSubviews {
    if (CURRENT_DEVICE_VERSION >= 7.0  && self.view.frame.size.height == appDelegate.window.frame.size.height) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.origin.y = -topBarOffset;
        self.view.bounds = viewBounds;

        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    @try {
        [super viewWillAppear:YES];
        if (self.navigationController.interfaceOrientation != UIInterfaceOrientationPortrait) {
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
            UIViewController *firstViewController = [[UIViewController alloc] init];
//            [self presentModalViewController:firstViewController animated:NO];
            [self presentViewController:firstViewController animated:NO completion:nil];
            [firstViewController dismissViewControllerAnimated:NO completion:nil];
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    } @finally {
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
}

- (void)checkVideoShouldPlayWhenCameFromBrowser:(NSString *)videoId {
    TCSTART
    if ([self isNotNull:videoId]) {
        [appDelegate requestForPlayBackWithVideoId:videoId andcaller:self andIndexPath:Nil refresh:YES];
    }
    TCEND
}

- (void)playBackResponse:(NSDictionary *)results {
    TCSTART
    if ([self isNotNull:results] && ![[results objectForKey:@"isResponseNull"] boolValue]) {
        VideoModal *video;
        BOOL playVideo = NO;
        if ([self isNotNull:[results objectForKey:@"video"]]) {
            video = [results objectForKey:@"video"];
        }
        if (video.userId.intValue == appDelegate.loggedInUser.userId.intValue || [video.public intValue] == 1) {
            playVideo = YES;
        } else if ([video.public intValue] == 0 && [self isvideoUplaodedUserInLoggedInUserPrivateGroup:video.userId]) {
            playVideo = YES;
        } else if ([video.public intValue] == 2 && [self isvideoUplaodedUserInLoggedInUserFollowings:video.userId]) {
            playVideo = YES;
        }
        if (playVideo) {
            customMoviePlayerVC = [[CustomMoviePlayerViewController alloc] initWithNibName:@"CustomMoviePlayerViewController" bundle:nil video:video videoFilePath:nil andClientVideoId:nil showInstrcutnScreen:NO];
            customMoviePlayerVC.caller = self;
            [self presentViewController:customMoviePlayerVC animated:YES completion:nil];
        }
    }
    TCEND
}
- (void)playerScreenDismissed {
    TCSTART
    customMoviePlayerVC = nil;
    TCEND
}
- (BOOL)isvideoUplaodedUserInLoggedInUserPrivateGroup:(NSString *)videoUplaodedUserId {
    TCSTART
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@/checkpvtgroup/%@/%@",APP_URL,appDelegate.loggedInUser.userId,videoUplaodedUserId]]];
    [request setHTTPMethod: @"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:30];
    
    NSHTTPURLResponse *resp = nil;
    NSError *error = nil;
    NSData *response = response = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error: &error];
    if (!error) {
        NSString *responseString = [[NSString alloc] initWithData:response encoding: NSUTF8StringEncoding];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
        if (!error) {
            NSNumber *code = [responseDict objectForKey:@"error_code"];
            if ([code intValue] == 0) {
                return [[responseDict objectForKey:@"following"] boolValue];
            }
        }
    }
    for (NSDictionary *dict in appDelegate.loggedInUser.privateUsers) {
        if ([[dict objectForKey:@"user_id"] intValue] == [videoUplaodedUserId intValue]) {
            return YES;
        }
    }
    return NO;
    TCEND
}

- (BOOL)isvideoUplaodedUserInLoggedInUserFollowings:(NSString *)videoUplaodedUserId {
    TCSTART
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@/checkfollowing/%@/%@",APP_URL,appDelegate.loggedInUser.userId,videoUplaodedUserId]]];
    [request setHTTPMethod: @"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:30];
    
    NSHTTPURLResponse *resp = nil;
    NSError *error = nil;
    NSData *response = response = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error: &error];
    if (!error) {
        NSString *responseString = [[NSString alloc] initWithData:response encoding: NSUTF8StringEncoding];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *responseDict = [parser objectWithString:responseString error:&error];
        if (!error) {
            NSNumber *code = [responseDict objectForKey:@"error_code"];
            if ([code intValue] == 0) {
                return [[responseDict objectForKey:@"following"] boolValue];
            }
        }
    }
    for (NSDictionary *dict in appDelegate.loggedInUser.followings) {
        if ([[dict objectForKey:@"user_id"] intValue] == [videoUplaodedUserId intValue]) {
            return YES;
        }
    }
    return NO;
    TCEND
}

- (IBAction)onClickOfMenuButton {
    TCSTART
    [appDelegate.videoFeedVC setBoolValueForControllerVariable];
    [swRevealCntr revealToggle:self];
    TCEND
}

- (void)bringAllFooterIconsToFront {
    TCSTART
    [self.view bringSubviewToFront:customTabView];
    [customTabView bringSubviewToFront:customTab_ImgView];
    [customTabView bringSubviewToFront:browse_Btn];
    [customTabView bringSubviewToFront:videoFeed_Btn];
    [customTabView bringSubviewToFront:videoAction_Btn];
    [customTabView bringSubviewToFront:notifications_Btn];
    [customTabView bringSubviewToFront:myPagebutton];
    [customTabView bringSubviewToFront:notificationsIndicatorLbl];
    [customTabView bringSubviewToFront:videofeedIndicatorLbl];
    TCEND
}

#pragma mark - TabButtons Actions & Their Configuration.
- (void)setImageForCustomTabbar:(NSString *)customfooter {
    @try {
        [customTab_ImgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",customfooter]]];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
        
    }
}

- (void)manageViewController:(BOOL)browse viewCont:(BOOL)myVideoFeed viewCont:(BOOL)videoAction viewCont:(BOOL)notifications viewCont:(BOOL)myPage {
    
    @try {
        
        if (browse && browseNavVC) {
            browseNavVC.view.hidden = YES;
        }

        if (myVideoFeed && videoFeedNavVC) {
            videoFeedNavVC.view.hidden = YES;
            appDelegate.isVideoFeedVCDisplays = NO;
        }
        
        if (myPage && myPageNavVC) {
            myPageNavVC.view.hidden = YES;
        }
        
        if (notificationsNavVC && notifications) {
            notificationsNavVC.view.hidden = YES;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (IBAction)displayBrowseView:(id)sender {
    @try {
        [self setImageForCustomTabbar:@"Tab2"];
        // show the LiveFeed view and remove all other views
        [self manageViewController:NO viewCont:YES viewCont:YES viewCont:YES viewCont:YES];
        if ([self isNull:browseNavVC]) {
            CGRect navFrame = CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - (CURRENT_DEVICE_VERSION < 7.0 ? 50 : 70));
            BrowseViewController *browseVC = [[BrowseViewController alloc] initWithNibName:@"BrowseViewController" bundle:Nil viewFrame:CGRectMake(0, 0, navFrame.size.width, navFrame.size.height)];
            browseNavVC = [[UINavigationController alloc] initWithRootViewController:browseVC];

            [browseNavVC.navigationBar setFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
            [browseNavVC.view setFrame:navFrame];
            
            [self.view addSubview:browseNavVC.view];
            [self addChildViewController:browseNavVC];
            
            browseNavVC.navigationBarHidden = YES;
            browseVC.superVC = self;
        } else {
            browseNavVC.view.hidden = NO;
            [self refreshBrowseScreen];
        }
        [self bringAllFooterIconsToFront];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)refreshBrowseScreen {
    if (isBrowseVideosEnterBg || isBrowsePeopleEnterBg || isBrowseTagsEnterBg || isBrowseTagsEnterBg) {
        BrowseViewController *browseVC = [browseNavVC.viewControllers firstObject];
        [browseVC applicationDidEnterForegroundNotificationFromMainVC];
    }
}
-(IBAction)disPlayVideoFeed:(id)sender {
    
    @try {
        [self setImageForCustomTabbar:@"Tab1"];
        [self manageViewController:YES viewCont:NO viewCont:YES viewCont:YES viewCont:YES];
        if ([self isNull:videoFeedNavVC]) {
            CGRect navFrame = CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - (CURRENT_DEVICE_VERSION < 7.0 ? 50 : 70));
            VideoFeedAndMoreVideosViewController *videoFeedVC = [[VideoFeedAndMoreVideosViewController alloc] initWithNibName:@"VideoFeedAndMoreVideosViewController" bundle:Nil andFrame:CGRectMake(0, 0, navFrame.size.width, navFrame.size.height) andViewType:@"videoFeed"];
            videoFeedVC.mainVC = self;
            videoFeedNavVC = [[UINavigationController alloc] initWithRootViewController:videoFeedVC];
            
            [videoFeedNavVC.navigationBar setFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
            [videoFeedNavVC.view setFrame:navFrame];
            
            [self.view addSubview:videoFeedNavVC.view];
            [self addChildViewController:videoFeedNavVC];
            
            videoFeedNavVC.navigationBarHidden = YES;
            appDelegate.videoFeedVC = videoFeedVC;
            
        } else {
            videoFeedNavVC.view.hidden = NO;
            [self refreshVideoFeedScreen];
        }
        
        appDelegate.isVideoFeedVCDisplays = YES;
        [self bringAllFooterIconsToFront];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)refreshVideoFeedScreen {
    if (isVideoFeedEnterBg || isPrivateFeedEnterBg) {
        VideoFeedAndMoreVideosViewController *videoFeedVC = (VideoFeedAndMoreVideosViewController *)[videoFeedNavVC.viewControllers firstObject];
        [videoFeedVC applicationDidEnterForegroundNotificationFromMainVC];
    }
}
- (IBAction)displayVideoAction:(id)sender {
    @try {

        [self recordOrPickVideo];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)recordOrPickVideo {
    TCSTART
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Select" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Record",@"Choose from Library", nil];
    actionSheet.backgroundColor = [UIColor whiteColor];
    [actionSheet showInView:appDelegate.window];
    TCEND
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    TCSTART
    if (buttonIndex == 0) { //Record the video
        appDelegate.isRecordingScreenDisplays = YES;
        [self displayRecordVideoScreen];
    } else if(buttonIndex == 1) { //Pick from library.
       appDelegate.isRecordingScreenDisplays = YES;
        [self displayTrimVideoScreen];
    }
    TCEND
}

- (void)displayRecordVideoScreen {
    TCSTART
    RecordingViewController *recordingVideoScreen = [[RecordingViewController alloc] initWithNibName:@"RecordingViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:recordingVideoScreen];
    navController.navigationBarHidden = YES;
    [self presentViewController:navController animated:YES completion:nil];
    recordingVideoScreen.caller = self;
    TCEND
}



- (void)displayTrimVideoScreen {
    TCSTART
    TrimVideoViewController *trimVideoVC = [[TrimVideoViewController alloc] initWithNibName:@"TrimVideoViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:trimVideoVC];
    navController.navigationBarHidden = YES;
    [self presentViewController:navController animated:NO completion:^ {
        [trimVideoVC openGallery];
    }];
    TCEND
}

#pragma mark 
#pragma mark Mypage
- (IBAction)displayMyPage:(id)sender {
    TCSTART
    [self manageViewController:YES viewCont:YES viewCont:YES viewCont:YES viewCont:NO];
    
    [self setImageForCustomTabbar:@"Tab5"];
    
    if ([self isNull:myPageNavVC]) {
        CGRect navFrame = CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - (CURRENT_DEVICE_VERSION < 7.0 ? 50 : 70));
        myPageVC = [[MyPageViewController alloc] initWithNibName:@"MyPageViewController" bundle:nil andFrame:CGRectMake(0, 0, navFrame.size.width, navFrame.size.height)];
        myPageNavVC = [[UINavigationController alloc] initWithRootViewController:myPageVC];
        
        [myPageNavVC.navigationBar setFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        [myPageNavVC.view setFrame:navFrame];
        
        [self.view addSubview:myPageNavVC.view];
        [self addChildViewController:myPageNavVC];
        
        myPageNavVC.navigationBarHidden = YES;
        myPageVC.mainVC = self;
    } else {
        myPageNavVC.view.hidden = NO;
        [self refreshMypageVideos];
    }
    
    [self bringAllFooterIconsToFront];
    TCEND
}

- (void)refreshMypageVideos {
    if (isMypageEnterBg) {
        isMypageEnterBg = NO;
        [myPageVC refreshMyPageVideos];
    }
}
- (void)updateMypageDetails {
    [myPageVC afterUpdateProfileFromAccountSettings];
}

- (IBAction)displayMyNotifications:(id)sender {
    
    @try {
        //   NSLog(@"getDetails");
        [self setImageForCustomTabbar:@"Tab4"];
        // show the getDetails view and hide all other views
        [self manageViewController:YES viewCont:YES viewCont:YES viewCont:NO viewCont:YES];
//        NSURL *whatsappURL = [NSURL URLWithString:@"whatsapp://"];
//        if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
//            [[UIApplication sharedApplication] openURL: whatsappURL];
//        }
        
        if ([self isNull:notificationsNavVC]) {
            CGRect navFrame = CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - (CURRENT_DEVICE_VERSION < 7.0 ? 50 : 70));
            NotificationsViewController *notificationsVC = [[NotificationsViewController alloc] initWithNibName:@"NotificationsViewController" bundle:nil andFrame:CGRectMake(0, 0, navFrame.size.width, navFrame.size.height)];
            
            notificationsNavVC = [[UINavigationController alloc] initWithRootViewController:notificationsVC];
            
            [notificationsNavVC.navigationBar setFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
            [notificationsNavVC.view setFrame:navFrame];
            
            [self.view addSubview:notificationsNavVC.view];
            [self addChildViewController:notificationsNavVC];
            
            notificationsNavVC.navigationBarHidden = YES;
            
            notificationsVC.mainVC = self;
            
        } else {
            notificationsNavVC.view.hidden = NO;
            [self refreshNotificationsPage];
        }
        [self bringAllFooterIconsToFront];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
        
    }
}

- (void)refreshNotificationsPage {
    TCSTART
    if (isNotificationsEnterBg) {
        NotificationsViewController *notifictnsVC = (NotificationsViewController *)[notificationsNavVC.viewControllers firstObject];
        [notifictnsVC refreshNotificationsScreen];
        isNotificationsEnterBg = NO;
    }
    TCEND
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
}
- (void)viewDidUnload {
    [super viewDidUnload];
}


//For iOS 6
- (BOOL)shouldAutorotate
{
//    if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) && recordVideoSelected) {
//        [self displayRecordVideoScreen];
//    }
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        return YES;
    } else {
//        if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) && recordVideoSelected) {
//            [self displayRecordVideoScreen];
//        }
        return NO;
    }
}


@end
