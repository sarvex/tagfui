/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "CustomMoviePlayerViewController.h"
#import "WooTagPlayerAppDelegate.h"
#import "NSObject+PE.h"
#import "Tag.h"
#import "TagMarkerView.h"
#import "ShareViewController.h"
#import "SelectCoverFrameViewController.h"
#import "TrendsDetailsViewController.h"
#import "OthersPageViewController.h"

@interface CustomMoviePlayerViewController ()

@end

@implementation CustomMoviePlayerViewController
@synthesize selectedIndexPath;
@synthesize caller;

NSString * const hashTagKey = @"HashTag";
NSString * const normalKey = @"NormalKey";
NSString * const wordType = @"WordType";

#pragma mark ViewLife Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil video:(VideoModal *)video_ videoFilePath:(NSString *)videoFilePath_ andClientVideoId:(NSString *)clientVideoId_ showInstrcutnScreen:(BOOL)show
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication]delegate];
        video = video_;
        videoFilePath = videoFilePath_;
        clientVideoId = clientVideoId_;
        showInstructnScreen = show;
        // On iOS 4.0+ only, listen for background notification
        if(UIApplicationWillResignActiveNotification != nil) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        }
        
        // On iOS 4.0+ only, listen for foreground notification
        if(UIApplicationDidBecomeActiveNotification != nil) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        }
    }
    return self;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    TCSTART
    if (playPauseBtn.tag == 0) { /// pause
        isPlaying = NO;
        playPauseBtn.tag = 1;
        [self onClickOfPlayPauseBtn];
    } else { /// playing
        isPlaying = YES;
    }
    TCEND
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    TCSTART
    if (!tagMarkerView && isPlaying) {
        [self addLoadingView];
        [self performSelector:@selector(removeLoadingViewFromPlayerView) withObject:nil afterDelay:3];
    }
    
    if (moviePlayerController.currentPlaybackTime == moviePlayerController.duration && moviePlayerController.currentPlaybackTime != 0.0) {
        
    } else {
        if (!tagMarkerView && isPlaying) {
            [self performSelector:@selector(playVideo) withObject:nil afterDelay:3];
        }
    }
    TCEND
}

- (void)addLoadingView {
    TCSTART
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, moviePlayerController.view.frame.size.width, moviePlayerController.view.frame.size.height)];
    loadingView.backgroundColor = [UIColor clearColor];
    /* UIImage *image;
     if ([[UIScreen mainScreen] bounds].size.height > 480) {
     image = [UIImage imageNamed:@"PlayerBgiPhone5"];
     } else {
     image = [UIImage imageNamed:@"PlayerBg"];
     }
     UIImageView *backgroundImgView = [[UIImageView alloc] initWithImage:image];
     backgroundImgView.frame = CGRectMake(0, 0, loadingView.frame.size.width, loadingView.frame.size.height);
     [loadingView addSubview:backgroundImgView]; */
    [moviePlayerController.view addSubview:loadingView];
    [moviePlayerController.view bringSubviewToFront:loadingView];
    [appDelegate showActivityIndicatorInView:loadingView andText:@"Buffering"];
    TCEND
}

- (void)removeLoadingViewFromPlayerView {
    TCSTART
    [appDelegate removeNetworkIndicatorInView:loadingView];
    [loadingView removeFromSuperview];
    loadingView = nil;
    TCEND
}

- (void)playVideo {
    if (!tagMarkerView && [self isNotNull:moviePlayerController]) {
        playPauseBtn.tag = 0;
        [self onClickOfPlayPauseBtn];
    }
}

- (void)linkItWebviewLoadErrorWithPlaybackTime:(float)currentplayTime {
   TCSTART
    NSLog(@"moviePlayerController.currentPlaybackTime:%f",moviePlayerController.currentPlaybackTime);
    if ([self isNotNull:moviePlayerController] && moviePlayerController.currentPlaybackTime == 0.00) {
        moviePlayerController.currentPlaybackTime = currentplayTime;
        NSLog(@"moviePlayerController.currentPlaybackTime:%f",moviePlayerController.currentPlaybackTime);
        if (video && video.videoId.intValue > 0) {
            [self performSelector:@selector(playVideo) withObject:nil afterDelay:2];
            [self performSelector:@selector(pauseVideoPlayer) withObject:nil afterDelay:2.5];
        } else if(clientVideoId && clientVideoId.intValue > 0) {
            [self playVideo];
            [self performSelector:@selector(pauseVideoPlayer) withObject:nil afterDelay:0.01];
        }
    }
    TCEND
}

- (void)pauseVideoPlayer {
    TCSTART
    playPauseBtn.tag = 1;
    [self onClickOfPlayPauseBtn];
    TCEND
}
- (void)viewDidLoad {
    TCSTART
    [super viewDidLoad];
    
    introzoneView.backgroundColor = [UIColor clearColor];
    introZoneLbl1.backgroundColor = [UIColor whiteColor];
    introZoneLbl1.layer.borderWidth = 1.0f;
    introZoneLbl1.layer.borderColor = [UIColor blackColor].CGColor;
    introZoneLbl1.layer.masksToBounds = YES;

    introZoneLbl2.backgroundColor = [UIColor whiteColor];
    introZoneLbl2.layer.borderWidth = 1.0f;
    introZoneLbl2.layer.borderColor = [UIColor blackColor].CGColor;
    introZoneLbl2.layer.masksToBounds = YES;
    
    
    self.view.frame = CGRectMake(0, 0, appDelegate.window.frame.size.height, appDelegate.window.frame.size.width - 20);
    playingFirstTime = YES;
    canDisplayTags = YES;
    isOtherVCSPresented = NO;
    self.navigationController.navigationBarHidden = YES;
    taggedUserDetialsDict = [[NSMutableDictionary alloc] init];
    
    
//    othersVideoToastView.alpha = 0.8;
//    othersVideoToastView.layer.borderColor = [UIColor whiteColor].CGColor;
//    othersVideoToastView.layer.borderWidth = 1.0;
//    othersVideoToastView.layer.cornerRadius = 4.0f;
//    othersVideoToastView.layer.masksToBounds = YES;
    
    if (showInstructnScreen) {
        topViewCmntBtn.hidden = YES;
        topViewLikeBtn.hidden = YES;
        topViewShareBtn.hidden = YES;
        [homeBtn setImage:[UIImage imageNamed:@"PlayerUploadBtn"] forState:UIControlStateNormal];
        playerBackBtn.hidden = NO;
        playerTagLabel.hidden = NO;
        videoOwnerPic.hidden = YES;
        ownerName.hidden = YES;
        ownerDetailsBgImgView.hidden = YES;
    } else {
        if ([self isNotNull:video] && [video.userId isEqualToString:appDelegate.loggedInUser.userId] && ![appDelegate.ftue.tagged boolValue]) {
            isFirstTimeOpened = YES;
            showInstructnScreen = YES;
        }
        playerBackBtn.hidden = YES;
        videoOwnerPic.hidden = NO;
        playerTagLabel.hidden = YES;
        ownerName.hidden = NO;
        ownerDetalisBgLbl.hidden = YES;
    }
    
    messageTextView.layer.borderWidth = 1.0f;
    messageTextView.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
    messageTextView.layer.masksToBounds = YES;
    
    
    //NSLog(@"View Height:%f",self.view.frame.size.height);
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateTagColor:) name:NOTIFY_UPDATED_TAG_COLOR object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(publishTag:) name:NOTIFY_TAG_PUBLISH object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cancelTagTool:) name:NOTIFY_TAGTOOL_CANCEL object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(editTag:) name:NOTIFY_TAG_EDIT object:nil];
    
    tagMarkerView.hidden = YES;
    
    [self hidePlayerSettingsView];
    
    [self hidePlayerControlles];
    //NSLog(@"video:%@",video);
    if (video && video.path.length > 0) {
        [self createAndConfigurePlayerWithURL:[NSURL URLWithString:video.path] sourceType:MPMovieSourceTypeFile];
    } else if(videoFilePath && videoFilePath.length > 0){
        [self createAndConfigurePlayerWithURL:[NSURL fileURLWithPath:videoFilePath] sourceType:MPMovieSourceTypeFile];
    } else {
        [self createAndConfigurePlayerWithURL:[self localMovieURL] sourceType:MPMovieSourceTypeFile];
    }
    
    
    [moviePlayerController play];
    
    [playPauseBtn setImage:[UIImage imageNamed:@"PauseBtn"] forState:UIControlStateNormal];
    playPauseBtn.tag = 1;
    
    //[videoProgressSlider addTarget:self action:@selector(sliderAction) forControlEvents:UIControlEventValueChanged | UIControlEventTouchUpInside];
    videoProgressSlider.continuous = YES;
    [videoProgressSlider addTarget:self action:@selector(sliderAction) forControlEvents:UIControlEventTouchUpInside];
    [videoProgressSlider addTarget:self action:@selector(sliderEventValueChanged) forControlEvents:UIControlEventValueChanged];
    if (CURRENT_DEVICE_VERSION >= 7.0) {
        videoProgressSlider.tintColor = [UIColor clearColor];
    }
    
    videoProgressSlider.minimumTrackTintColor = [UIColor clearColor];
    videoProgressSlider.maximumTrackTintColor = [UIColor clearColor];
    videoProgressSlider.minimumValue = 0.0f;
    videoProgressSlider.maximumValue = moviePlayerController.duration;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesture:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.delegate = self;
    [moviePlayerController.view addGestureRecognizer:tapGestureRecognizer];
    
    moviePlayerController.view.multipleTouchEnabled = YES;
    
    //    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinchGesture:)];
    //    pinchGestureRecognizer.delegate = self;
    //    [moviePlayerController.view addGestureRecognizer:pinchGestureRecognizer];
    //
    //    UIPanGestureRecognizer *panchGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    //    panchGestureRecognizer.delegate = self;
    //    [moviePlayerController.view addGestureRecognizer:panchGestureRecognizer];
    
    taggedUserDetailsView.hidden = YES;
    
    //LinkWebview
    
    webviewBackgroundView.hidden = YES;

    // SettingsView
    
    [tagSwitch setThumbImage:[UIImage imageNamed:@"ToggleThumb"] forState:UIControlStateNormal];
    [tagSwitch setMinimumTrackImage:[[UIImage imageNamed:@"ToggleOn"]resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)] forState:UIControlStateNormal];
    [tagSwitch setMaximumTrackImage:[[UIImage imageNamed:@"ToggleOff"]resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)] forState:UIControlStateNormal];
    tagSwitch.leftLabel.text = @"";
    tagSwitch.rightLabel.text = @"";
    
    [editSwitch setThumbImage:[UIImage imageNamed:@"ToggleThumb"] forState:UIControlStateNormal];
    [editSwitch setMinimumTrackImage:[[UIImage imageNamed:@"ToggleOn"]resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)] forState:UIControlStateNormal];
    [editSwitch setMaximumTrackImage:[[UIImage imageNamed:@"ToggleOff"]resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)] forState:UIControlStateNormal];
    editSwitch.leftLabel.text = @"";
    editSwitch.rightLabel.text = @"";
    
    tagSwitch.on = YES;
    editSwitch.on = NO;
    
//    playerSettingsView.backgroundColor = [appDelegate colorWithHexString:@"454674"];
    TCEND
}

- (void) viewDidLayoutSubviews {
    if (CURRENT_DEVICE_VERSION >= 7.0) {
        CGRect viewBounds = self.view.bounds;
        //NSLog(@"viewController Frame :%f %f",viewBounds.origin.y,viewBounds.size.height);
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.origin.y = -topBarOffset;
        self.view.bounds = viewBounds;
        //NSLog(@"viewController Frame :%f %f",viewBounds.origin.y,viewBounds.size.height);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)setPlayerTopViewDetails {
    TCSTART
    ownerName.textColor = [appDelegate colorWithHexString:@"11a3e7"];
    ownerName.text = video.userName;
    videoOwnerPic.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
    videoOwnerPic.layer.cornerRadius = 16;
    videoOwnerPic.layer.borderWidth = 1;
    videoOwnerPic.layer.masksToBounds = YES;
    [videoOwnerPic setImageWithURL:[NSURL URLWithString:video.userPhoto] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached];
    playTimeLbl.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
    playTimeLbl.layer.cornerRadius = 2.0f;
    playTimeLbl.layer.masksToBounds = YES;
    
    if ([self isNull:video] && [self isNotNull:clientVideoId]) {
        ownerName.text = appDelegate.loggedInUser.userName;
        [videoOwnerPic setImageWithURL:[NSURL URLWithString:appDelegate.loggedInUser.photoPath] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached];
    }
    
    if (([self isNotNull:video.userId] && video.userId.intValue == appDelegate.loggedInUser.userId.intValue) || ([self isNull:video] && [self isNotNull:clientVideoId])) {
        //        [topViewTagBtn setImage:[UIImage imageNamed:@"TagIconPlay"] forState:UIControlStateApplication];
        topViewTagBtn.userInteractionEnabled = YES;
        topViewTagBtn.enabled = YES;
        if ([self isNull:video] && [self isNotNull:clientVideoId]) {
            topViewCmntBtn.userInteractionEnabled = NO;
            topViewCmntBtn.enabled = NO;
            
            topViewLikeBtn.userInteractionEnabled = NO;
            topViewLikeBtn.enabled = NO;
            
            topViewShareBtn.userInteractionEnabled = NO;
            topViewShareBtn.enabled = NO;
        }
    } else {
        if ([appDelegate.ftue.tagOnOthersVideo boolValue]) {
            topViewTagBtn.userInteractionEnabled = NO;
            topViewTagBtn.enabled = NO;
        }
        
    }
    TCEND
}

- (void)setFrameForAllviews {
    TCSTART
    if ([caller isKindOfClass:[SelectCoverFrameViewController class]]) {
        playerTopView.frame = CGRectMake(0, 0, appDelegate.window.frame.size.height, 54);
        playerBottomView.frame = CGRectMake(0, appDelegate.window.frame.size.width - 68, appDelegate.window.frame.size.height, 48);
    } else {
        playerTopView.frame = CGRectMake(0, 0, self.view.frame.size.height, 54);
        playerBottomView.frame = CGRectMake(0, self.view.frame.size.width - ((CURRENT_DEVICE_VERSION < 7.0)?48:68), self.view.frame.size.height, 48);
    }
    if (CURRENT_DEVICE_VERSION < 7.0) {
        videoProgressSlider.frame = CGRectMake(videoProgressSlider.frame.origin.x, videoProgressSlider.frame.origin.y + 4, videoProgressSlider.frame.size.width, videoProgressSlider.frame.size.height);
    }
    
    //BottomView
    //    playTimeLbl.frame = CGRectMake(videoProgressSlider.frame.origin.x + videoProgressSlider.frame.size.width - 75, playTimeLbl.frame.origin.y, playTimeLbl.frame.size.width, playTimeLbl.frame.size.height);
    //    settingsBtn.frame = CGRectMake(videoProgressSlider.frame.origin.x + videoProgressSlider.frame.size.width + 3, settingsBtn.frame.origin.y, settingsBtn.frame.size.width, settingsBtn.frame.size.height);
    //    homeBtn.frame = CGRectMake(settingsBtn.frame.origin.x + settingsBtn.frame.size.width + 3, homeBtn.frame.origin.y, homeBtn.frame.size.width, homeBtn.frame.size.height);
    
    playerSettingsView.frame = CGRectMake(playTimeLbl.frame.origin.x, playerBottomView.frame.origin.y - playerSettingsView.frame.size.height, 110, 70);
    
    [self setPlayerTopViewDetails];
    
    if (showInstructnScreen && ![appDelegate.ftue.tagged boolValue] && tagToolVC) {
        [self hidePlayerControlles];
        [self.view bringSubviewToFront:tagToolVC.view];
        tagToolVC.view.frame = CGRectMake(0, 0, appDelegate.window.frame.size.height, appDelegate.window.frame.size.width - 20);
    }
    TCEND
}

- (void)viewWillAppear:(BOOL)animated {
    TCSTART
    if (!isOtherVCSPresented) {
        [super viewWillAppear:YES];
        if (!isFrameSet) {
            isFrameSet = YES;
            [self setFrameForAllviews];
        }
        if (sliderTimer == nil) {
            sliderTimer = [NSTimer scheduledTimerWithTimeInterval:.05 target:self selector:@selector(changeSlider) userInfo:nil repeats:YES ];
        }
    }
    
    TCEND
}

- (void)viewDidAppear:(BOOL)animated {
    TCSTART
    NSLog(@"TagmarkerView %@",tagMarkerView);
    if (!isOtherVCSPresented) {
        isOtherVCSPresented = YES;
        NSLog(@"view DID appear");
        
        [super viewDidAppear:YES];
        if (![appDelegate.ftue.tagged boolValue]) {
            [self.view bringSubviewToFront:tagToolVC.view];
        }
        if (video && video.videoId.intValue > 0) {
            createdTagsArray = [[[DataManager sharedDataManager] getAllTagsByVideoIdAndClientVideoId:[NSDictionary dictionaryWithObjectsAndKeys:video.videoId,@"videoId", nil]] mutableCopy];
        } else if(clientVideoId && clientVideoId.intValue > 0) {
            createdTagsArray = [[[DataManager sharedDataManager] getAllTagsByVideoIdAndClientVideoId:[NSDictionary dictionaryWithObjectsAndKeys:clientVideoId,@"clientVideoId", nil]] mutableCopy];
        }
    }
   
    TCEND
}

//- (NSString *)getImageNameFromCoordinates:(CGPoint)tagRectPoint {
//    TCSTART
//    NSString *imageName = nil;
//    if (tagRectPoint.x < 0.5 && tagRectPoint.y > 0.5) {
//        // Quadrant 3
//        imageName = @"arrow_right_down";
//    } else if(tagRectPoint.x > 0.5 && tagRectPoint.y < 0.5) {
//        // Quadrant 1
//        imageName = @"arrow_left_up";
//
//    } else if(tagRectPoint.x > 0.5 && tagRectPoint.y > 0.5) {
//        //Quadrant 4
//        imageName = @"arrow_left_down";
//    } else if(tagRectPoint.x < 0.5 && tagRectPoint.y < 0.5) {
//        //Quadrant 2
//        imageName = @"arrow_right_up";
//    }
//    return imageName;
//    TCEND
//}
//
//- (CGPoint)getTagMarkerThumbPosition:(NSString *)imageName_ {
//    TCSTART
//    CGFloat markerFieldsYPoint = 0;
//    CGFloat markerFieldsXPoint = 0;
//    if ([imageName_ isEqualToString:@"arrow_right_up"]) {
//        markerFieldsXPoint = 0;
//        markerFieldsYPoint = 20;
//    } else if ([imageName_ isEqualToString:@"arrow_right_down"]) {
//        markerFieldsXPoint = 0;
//        markerFieldsYPoint = 100;
//    } else if ([imageName_ isEqualToString:@"arrow_left_up"]) {
//        markerFieldsXPoint = ((![tagMarkerView.deleteBtn isHidden])?183:150);
//        markerFieldsYPoint = 20;
//    } else {
//        markerFieldsYPoint = 100;
//        markerFieldsXPoint = ((![tagMarkerView.deleteBtn isHidden])?183:150);
//    }
//
//    return CGPointMake(markerFieldsXPoint, markerFieldsYPoint);;
//    TCEND
//}

- (CGPoint)getTagPointByUsingtagRectPointFromServer:(CGPoint)tagRectPointFromServer {
    CGPoint tagPoint;
    tagPoint.x = (self.view.frame.size.height * tagRectPointFromServer.x)/100 /**- diff.x*/;
    tagPoint.y = (self.view.frame.size.width * tagRectPointFromServer.y)/100 /**- diff.y*/;
    return tagPoint;
}

//- (CGPoint)getTagPointByUsingtagRectPointFromServer:(CGPoint)tagRectPointFromServer andWebResolution:(CGSize)screenSizeFromServer {
//    CGPoint tagPoint;
//    tagPoint.x = (self.view.frame.size.width * tagRectPointFromServer.x)/screenSizeFromServer.width;
//    tagPoint.y = (self.view.frame.size.height * tagRectPointFromServer.y)/screenSizeFromServer.height;
//    return tagPoint;
//}

- (void)updateTagMarkerOnSlider:(NSTimer *)timer {
    TCSTART
    
    for (Tag *tag in createdTagsArray) {
        //        [videoProgressSlider setValue:tag.videoPlaybackTime.floatValue animated:YES];
        float value = (float)tag.videoPlaybackTime.floatValue;
        videoProgressSlider.value = value;
        [self createTagMarkOnSliderAt:videoProgressSlider];
    }
    if (playingFirstTime) {
        playingFirstTime = NO;
        videoProgressSlider.value = 0.0;
    }
    //NSLog(@"VideoProgressSlider :%f",videoProgressSlider.value);
    //    videoProgressSlider.value = 0.0;//reset the slider value to initial point.
    TCEND
}

#pragma mark Video Progress
- (void)sliderEventValueChanged {
    ////NSLog(@"sliderEventValueChanged called");
    [sliderTimer invalidate];
    sliderTimer = nil;
    
}

// Slider action for seeking the current playing position or vice-versa
-(void)sliderAction {
    TCSTART
    // //NSLog(@"SliderAction called");
    //    int state = 0;
    //    if (playPauseBtn.tag == 1 && state == 0) {
    //        state = 1;
    //        [sliderTimer invalidate];
    //        sliderTimer = nil;
    //        [moviePlayerController pause];
    //    }
    
    moviePlayerController.currentPlaybackTime = (NSTimeInterval)videoProgressSlider.value;
    [self changeSlider];
    if (playPauseBtn.tag == 1 && sliderTimer == nil) {
        sliderTimer = [NSTimer scheduledTimerWithTimeInterval:.05 target:self selector:@selector(changeSlider) userInfo:nil repeats:YES ];
    }
    //    if (state == 1) {
    //        [moviePlayerController play];
    //    }
    TCEND
}

//Method called by the timer to change the slider according to the currentplayback time and displaying time.
- (void)changeSlider {
	
   TCSTART
        
        // //NSLog(@"movie currentplaybacktime is %f",moviePlayerController.currentPlaybackTime);
        ////NSLog(@"movie duration is %f",moviePlayerController.duration);
        
        if (moviePlayerController.currentPlaybackTime == moviePlayerController.duration && moviePlayerController.currentPlaybackTime != 0.0) {
            playPauseBtn.tag = 1;
            [self onClickOfPlayPauseBtn];
            [sliderTimer invalidate];
            sliderTimer = nil;
        }
        
        NSTimeInterval bufferedTime = [moviePlayerController playableDuration];
        NSTimeInterval currentPlaybackTime = [moviePlayerController currentPlaybackTime];
        
        playerBufferView.bufferValue = bufferedTime / moviePlayerController.duration;
        [playerBufferView setNeedsDisplay];
        
        if (moviePlayerController.currentPlaybackTime > 0) {
            [videoProgressSlider setValue:moviePlayerController.currentPlaybackTime animated:YES];
        }
        playerBufferView.progressValue = currentPlaybackTime / moviePlayerController.duration;
        
        videoProgressSlider.maximumValue = moviePlayerController.duration;
        videoProgressSlider.thumbTintColor = [UIColor whiteColor];
        int hour = floor(moviePlayerController.currentPlaybackTime/(60*60));//current playback hour
        int minutes = floor((moviePlayerController.currentPlaybackTime-hour*60*60)/60);//current playback minutes
        int seconds = round(moviePlayerController.currentPlaybackTime-hour*60*60-minutes*60);//current playback seconds
        
        int duration_hour = floor(moviePlayerController.duration/(60*60));//total hour
        int duration_min = floor((moviePlayerController.duration-duration_hour*60*60)/60);//total minutes
        int duration_sec = floor(moviePlayerController.duration -duration_hour*60*60 - duration_min*60);//total seconds
        
        NSString *playbackTime; /*= [[NSString alloc]init];*///removed due to never read need to be checked
        if (hour == 0) {
            if(minutes == 0){
                if(seconds < 10)
                    playbackTime = [NSString stringWithFormat:@"00:0%d",seconds];
                else
                    playbackTime = [NSString stringWithFormat:@"00:%2d",seconds];
            }
            else if(minutes < 10){
                if(seconds < 10)
                    playbackTime = [NSString stringWithFormat:@"0%d:0%d",minutes,seconds];
                else
                    playbackTime = [NSString stringWithFormat:@"0%d:%2d",minutes,seconds];
            }
            else {
                if(seconds<10)
                    playbackTime = [NSString stringWithFormat:@"%2d:0%d",minutes,seconds];
                else
                    playbackTime = [NSString stringWithFormat:@"%2d:%2d",minutes,seconds];
            }
        }
        else {
            if(minutes == 0) {
                if(seconds<10)
                    playbackTime = [NSString stringWithFormat:@"0%d:0:0%d",hour,seconds];
                else
                    playbackTime = [NSString stringWithFormat:@"0%d:0:%2d",hour,seconds];
            }
            else if(minutes<10) {
                if(seconds<10)
                    playbackTime = [NSString stringWithFormat:@"0%d:0%d:0%d",hour,minutes,seconds];
                else
                    playbackTime = [NSString stringWithFormat:@"0%d:0%d:%2d",hour,minutes,seconds];
            }
            else {
                if(seconds<10)
                    playbackTime = [NSString stringWithFormat:@"0%d:%2d:0%d",hour,minutes,seconds];
                else
                    playbackTime = [NSString stringWithFormat:@"0%d:%2d:%2d",hour,minutes,seconds];
            }
        }
        NSString *durationTime; /*= [[NSString alloc]init]; Removed due to never read leak need to be checked*/
        if (duration_hour == 0) {
            if(duration_min==0){
                if(duration_sec<10)
                    durationTime = [NSString stringWithFormat:@"00:0%d",duration_sec];
                else
                    durationTime = [NSString stringWithFormat:@"00:%2d",duration_sec];
            }
            else if(duration_min<10){
                if(duration_sec<10)
                    durationTime = [NSString stringWithFormat:@"0%d:0%d",duration_min,duration_sec];
                else
                    durationTime = [NSString stringWithFormat:@"0%d:%2d",duration_min,duration_sec];
            }
            else {
                if(duration_sec<10)
                    durationTime = [NSString stringWithFormat:@"%2d:0%d",duration_min,duration_sec];
                else
                    durationTime = [NSString stringWithFormat:@"%2d:%2d",duration_min,duration_sec];
            }
        }
        else {
            if(duration_min==0){
                if(duration_sec<10)
                    durationTime = [NSString stringWithFormat:@"0%d:00:0%d",duration_hour,duration_sec];
                else
                    durationTime = [NSString stringWithFormat:@"0%d:00:%2d",duration_hour,duration_sec];
            }
            else if(duration_min<10){
                if(duration_sec<10)
                    durationTime = [NSString stringWithFormat:@"0%d:0%d:0%d",duration_hour,duration_min,duration_sec];
                else
                    durationTime = [NSString stringWithFormat:@"0%d:0%d:%2d",duration_hour,duration_min,duration_sec];
            }
            else {
                if(duration_sec<10)
                    durationTime = [NSString stringWithFormat:@"0%d:%2d:0%d",duration_hour,duration_min,duration_sec];
                else
                    durationTime = [NSString stringWithFormat:@"0%d:%2d:%2d",duration_hour,duration_min,duration_sec];
            }
        }
        playTimeLbl.text = [NSString stringWithFormat:@"%@/%@",playbackTime,durationTime];
        
        for (Tag *tag in createdTagsArray) {
            NSString *currentPlaybackTime = [NSString stringWithFormat:@"%.1f",moviePlayerController.currentPlaybackTime];
            NSString *tagPlaybackTime = [NSString stringWithFormat:@"%.1f",[tag.videoPlaybackTime floatValue]];
            //            //NSLog(@"moviePlayerCurrentPlaybackTime %@, tagVideoPlaybacktime %@ while playback",currentPlaybackTime,tagPlaybackTime);
            if ([tagPlaybackTime isEqualToString:currentPlaybackTime]) {
                TagMarkerView *view;
                if ([self isNotNull:tag.clientTagId] && [tag.clientTagId intValue] > 0) {
                    view = (TagMarkerView *)[moviePlayerController.view viewWithTag:tag.clientTagId.intValue];
                    if (!view) {
                        view = (TagMarkerView *)[moviePlayerController.view viewWithTag:tag.tagId.intValue];
                    }
                } else {
                    view = (TagMarkerView *)[moviePlayerController.view viewWithTag:tag.tagId.intValue];
                }
                
                [view removeFromSuperview];
                
                tagMarkerView = [[[NSBundle mainBundle] loadNibNamed:@"TagMarkerView" owner:nil options:nil] objectAtIndex:0];
                
                tagMarkerView.caller = self;
                touchPoint = [self getTagPointByUsingtagRectPointFromServer:CGPointMake([tag.tagX floatValue], [tag.tagY floatValue])];
                
                
                cancelTagMarkerBtn.hidden = YES;
                confirmTagMarkerBtn.hidden = YES;
                
                [self showAndUpdateTagMarkerView];
                
                NSMutableDictionary *tagFields = [[NSMutableDictionary alloc]initWithObjectsAndKeys:tag.name?:@"",@"name",tag.link?:@"",@"link",tag.displayTime?:@"",@"displaytime",tag.tagColorName?:@"",@"tagColorName",tag.fbId?:@"",@"fbtagid",tag.twId?:@"",@"twtagid",tag.wtId?:@"",@"wtId",tag.gPlusId?:@"",@"gplustagid",tag.tagId?:[NSNumber numberWithInt:0],@"tagid",tag.clientTagId?:[NSNumber numberWithInt:0],@"clientTagId",tag.productName?:@"",@"productName", nil];
                
                [self updateTagInfo:tagFields];
                tagMarkerView = nil;
            }
        }
    TCEND
}

-(void)updateTagColor:(NSNotification *)notificaiton {
    TCSTART
    UILabel *colorLbl = notificaiton.object;
    //    switch (colorBtn.tag) {
    //        case orange:
    //
    //            break;
    //
    //        default:
    //            break;
    //    }
    
    // markerImageView.image = [self getImageWithUnsaturatedPixelsOfImage:markerImageView.image];
    //NSLog(@"tagMarkerView Background : %@",tagMarkerView.markerImageView.image);
    tagMarkerView.markerImageView.image = [self getImageWithTintedColor:tagMarkerView.markerImageView.image withTint:colorLbl.backgroundColor withIntensity:1.0];
    TCEND
}

- (UIImage *) getImageWithUnsaturatedPixelsOfImage:(UIImage *)image {
    TCSTART
    const int RED = 1, GREEN = 2, BLUE = 3;
    
    CGRect imageRect = CGRectMake(0, 0, image.size.width*2, image.size.height*2);
    
    int width = imageRect.size.width, height = imageRect.size.height;
    
    uint32_t * pixels = (uint32_t *) malloc(width*height*sizeof(uint32_t));
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [image CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t * rgbaPixel = (uint8_t *) &pixels[y*width+x];
            uint32_t gray = (0.3*rgbaPixel[RED]+0.59*rgbaPixel[GREEN]+0.11*rgbaPixel[BLUE]);
            
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    UIImage * resultUIImage = [UIImage imageWithCGImage:newImage scale:2 orientation:0];
    CGImageRelease(newImage);
    
    return resultUIImage;
    TCEND
}

-(UIImage *) getImageWithTintedColor:(UIImage *)image withTint:(UIColor *)color withIntensity:(float)alpha {
    TCSTART
    CGSize size = image.size;
    
    UIGraphicsBeginImageContextWithOptions(size, FALSE, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [image drawAtPoint:CGPointZero blendMode:kCGBlendModeNormal alpha:1.0];
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    CGContextSetAlpha(context, alpha);
    
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(CGPointZero.x, CGPointZero.y, image.size.width, image.size.height));
    
    UIImage * tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
    TCEND
}

- (void)publishTag:(NSNotification *)notification {
    TCSTART
    //Get the tagFields entered through TagTool from notification object.
    NSMutableDictionary *tagFields = notification.object;
    
    //name must be presented to publish the tag.
    if ([self isNotNull:tagFields] && [self isNotNull:[tagFields objectForKey:@"name"]]) {
        
        [self updateTagInfo:tagFields];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[tagFields objectForKey:@"tagid"],@"tagid",[tagFields objectForKey:@"clientTagId"],@"clientTagId", nil];
        Tag *tag = [[DataManager sharedDataManager] getTagByTagIdORClientTagId:dict];
        
        if (!tag) {
//            NSLog(@"CurrentPlayBackTime:%f",moviePlayerController.currentPlaybackTime);
//            [tagFields setObject:[NSString stringWithFormat:@"%.1f",moviePlayerController.currentPlaybackTime] forKey:@"videoplaybacktime"];
            //            CGPoint diff = [self getTagMarkerThumbPosition:tagMarkerView.markerImageView.accessibilityIdentifier];
            CGFloat tagX = (touchPoint.x / self.view.frame.size.height) * 100;
            CGFloat tagY = (touchPoint.y / self.view.frame.size.width) * 100;
            //NSLog(@"Tag Point :%f %f",touchPoint.x, touchPoint.y);
            [tagFields setObject:[NSString stringWithFormat:@"%f",tagX] forKey:@"tagX"];
            [tagFields setObject:[NSString stringWithFormat:@"%f",tagY] forKey:@"tagY"];
            
            [self createTagWithCreationFields:tagFields];
            
            [self createTagMarkOnSliderAt:videoProgressSlider];
        } else {
            tagMarkerView.editBtn.enabled = YES;
            [self createTagWithCreationFields:tagFields];
            //            if (video && video.videoId.intValue > 0) {
            //                 [self addTagsResponseForVideoCompleted:NO];
            //                 [self updateTagMarkerOnSlider:nil];
            //            }
        }
    }
    tagMarkerView = nil;
    [tagToolVC.view removeFromSuperview];
    tagToolVC = nil;
    //playPauseBtn.tag = 0;
    //[self onClickOfPlayPauseBtn];
    TCEND
}

- (void)updateTagInfo:(NSMutableDictionary *)tagFields {
    TCSTART
    NSString *name = [tagFields objectForKey:@"name"];
    NSString *link = [tagFields objectForKey:@"link"];
    NSString *fbId = [tagFields objectForKey:@"fbtagid"];
    NSString *twId = [tagFields objectForKey:@"twtagid"];
    NSString *gplusId = [tagFields objectForKey:@"gplustagid"];
//    NSString *wtId = [tagFields objectForKey:@"wtId"];
    NSString *imageName_ = tagMarkerView.markerImageView.accessibilityIdentifier;
    
    int markerFieldsXPoint = 0;
    int markerFieldsYPoint = 0;
    int deleteBtnXPoint = 0;
    int deleteBtnYPoint = 0;
    
    int markernamelblXpoint = 0;
    int markernamelblYpoint = 0;
    int markernamelblwidth = 0;
    int markernamelblheight = 0;
    //    int deleteBtnXPosition = 0;
    if ([imageName_ rangeOfString:@"arrow_right_up"].location != NSNotFound) {
        markerFieldsXPoint =  40;
        markerFieldsYPoint = 0;
        markernamelblXpoint = 37;
        markernamelblYpoint = 3;
        markernamelblwidth = 140;
        markernamelblheight = 45;
        deleteBtnYPoint = 35;
        deleteBtnXPoint = 180;
    } else if([imageName_ rangeOfString:@"arrow_right_down"].location != NSNotFound) {
        markerFieldsXPoint =  40;
        markerFieldsYPoint = 0;
        markernamelblXpoint = 40;
        markernamelblYpoint = -2;
        markernamelblwidth = 180;
        markernamelblheight = 30;
        deleteBtnYPoint = 20;
        deleteBtnXPoint = 180;
    } else if([imageName_ rangeOfString:@"arrow_left_up"].location != NSNotFound) {
        markerFieldsXPoint = 0 + 30;
        markerFieldsYPoint = 0;
        markernamelblXpoint = 37;
        markernamelblYpoint = 3;
        markernamelblwidth = 140;
        markernamelblheight = 45;
        deleteBtnYPoint = 35;
        deleteBtnXPoint = 0;
    } else {
        markerFieldsXPoint = 0 + 30;
        markerFieldsYPoint = 0;
        markernamelblXpoint = 37;
        markernamelblYpoint = 0;
        markernamelblwidth = 180;
        markernamelblheight = 30;
        deleteBtnYPoint = 20;
        deleteBtnXPoint = 0;
    }
    //NSLog(@"markerview height:%f",tagMarkerView.frame.size.height);
    
    if ([imageName_ rangeOfString:@"arrow_left_up"].location != NSNotFound || [imageName_ rangeOfString:@"arrow_left_down"].location != NSNotFound) {
        tagMarkerView.markerImageView.frame = CGRectMake(30, tagMarkerView.markerImageView.frame.origin.y, tagMarkerView.markerImageView.frame.size.width, tagMarkerView.markerImageView.frame.size.height);
        tagMarkerView.editBtn.frame = CGRectMake(30, tagMarkerView.editBtn.frame.origin.y, tagMarkerView.editBtn.frame.size.width, tagMarkerView.editBtn.frame.size.height);
    }
    if ([imageName_ rangeOfString:@"arrow_left_up"].location != NSNotFound || [imageName_ rangeOfString:@"arrow_right_up"].location != NSNotFound) {
        tagMarkerView.markerImageView.frame = CGRectMake(tagMarkerView.markerImageView.frame.origin.x, markerFieldsYPoint, tagMarkerView.markerImageView.frame.size.width, tagMarkerView.markerImageView.frame.size.height);
        
    }
    
    tagMarkerView.markerImageView.image = [self getImageWithTintedColor:tagMarkerView.markerImageView.image withTint:[appDelegate colorWithHexString:[appDelegate HexStringFromColorName:[tagFields objectForKey:@"tagColorName"]]] withIntensity:1.0];
    
    if ([self isNotNull:imageName_]) {
        [tagFields setObject:imageName_ forKey:@"imagename"];
    }
    
    tagMarkerView.markernameTxtView.frame = CGRectMake(([imageName_ rangeOfString:@"arrow_right_up"].location != NSNotFound)?markernamelblXpoint:tagMarkerView.markerImageView.frame.origin.x,markernamelblYpoint,markernamelblwidth,markernamelblheight);
    
    tagMarkerView.markernameTxtView.layer.cornerRadius = 5.0f;
    tagMarkerView.markernameTxtView.layer.masksToBounds = YES;
    

    tagMarkerView.markerLinkBtn.frame = CGRectMake(tagMarkerView.markerImageView.frame.origin.x,markernamelblYpoint,tagMarkerView.markernameTxtView.frame.size.width,tagMarkerView.markernameTxtView.frame.size.height);
    tagMarkerView.fbBtn.frame = CGRectMake(0.0,tagMarkerView.markernameTxtView.frame.origin.y + tagMarkerView.markernameTxtView.frame.size.height + 6,tagMarkerView.fbBtn.frame.size.width,tagMarkerView.fbBtn.frame.size.height);
    tagMarkerView.twBtn.frame = CGRectMake(0.0,tagMarkerView.fbBtn.frame.origin.y,tagMarkerView.twBtn.frame.size.width,tagMarkerView.twBtn.frame.size.height);
    tagMarkerView.gPlusBtn.frame = CGRectMake(0.0,tagMarkerView.fbBtn.frame.origin.y,tagMarkerView.gPlusBtn.frame.size.width,tagMarkerView.gPlusBtn.frame.size.height);
    tagMarkerView.wtBtn.frame = CGRectMake(0.0,tagMarkerView.fbBtn.frame.origin.y,tagMarkerView.wtBtn.frame.size.width,tagMarkerView.wtBtn.frame.size.height);
    tagMarkerView.weblinkBtn.frame = CGRectMake(0.0,tagMarkerView.fbBtn.frame.origin.y,tagMarkerView.weblinkBtn.frame.size.width,tagMarkerView.weblinkBtn.frame.size.height);
    
    //Name
    tagMarkerView.markernameTxtView.hidden = NO;
    tagMarkerView.markernameTxtView.caller = self;


    [tagMarkerView.markernameTxtView setTextToTextLayer:name];
    tagMarkerView.fbBtn.frame = CGRectMake(markernamelblXpoint-6,tagMarkerView.fbBtn.frame.origin.y,0.0,tagMarkerView.fbBtn.frame.size.height);
    
    //Facebook
    if ([self isNotNull:fbId] && fbId.length > 0) {
        tagMarkerView.fbBtn.hidden = NO;
        tagMarkerView.fbBtn.frame = CGRectMake(markernamelblXpoint-6,tagMarkerView.fbBtn.frame.origin.y,30,tagMarkerView.fbBtn.frame.size.height);
    }
    tagMarkerView.twBtn.frame = CGRectMake(tagMarkerView.fbBtn.frame.origin.x + tagMarkerView.fbBtn.frame.size.width,tagMarkerView.fbBtn.frame.origin.y,0.0f,tagMarkerView.twBtn.frame.size.height);
    
    //Twitter
    if ([self isNotNull:twId] && twId.length > 0) {
        tagMarkerView.twBtn.hidden = NO;
        tagMarkerView.twBtn.frame = CGRectMake(tagMarkerView.fbBtn.frame.origin.x + tagMarkerView.fbBtn.frame.size.width,tagMarkerView.fbBtn.frame.origin.y,30,tagMarkerView.twBtn.frame.size.height);
    }
    
    tagMarkerView.gPlusBtn.frame = CGRectMake(tagMarkerView.twBtn.frame.origin.x + tagMarkerView.twBtn.frame.size.width,tagMarkerView.twBtn.frame.origin.y,0.0f,tagMarkerView.gPlusBtn.frame.size.height);
    //Google+
    if ([self isNotNull:gplusId] && gplusId.length > 0) {
        tagMarkerView.gPlusBtn.hidden = NO;
        tagMarkerView.gPlusBtn.frame = CGRectMake(tagMarkerView.twBtn.frame.origin.x + tagMarkerView.twBtn.frame.size.width,tagMarkerView.gPlusBtn.frame.origin.y,30,tagMarkerView.gPlusBtn.frame.size.height);
    }
    
    // Wooatg
    tagMarkerView.wtBtn.frame = CGRectMake(tagMarkerView.gPlusBtn.frame.origin.x + tagMarkerView.gPlusBtn.frame.size.width,tagMarkerView.gPlusBtn.frame.origin.y,0.0f,tagMarkerView.wtBtn.frame.size.height);
    if ([self isNotNull:[tagFields objectForKey:@"productName"]]) {
        tagMarkerView.wtBtn.hidden = NO;
        tagMarkerView.wtBtn.tagId = [[tagFields objectForKey:@"tagid"] intValue];
        tagMarkerView.wtBtn.clientTagId = [[tagFields objectForKey:@"clientTagId"] intValue];
        tagMarkerView.wtBtn.frame = CGRectMake(tagMarkerView.gPlusBtn.frame.origin.x + tagMarkerView.gPlusBtn.frame.size.width, tagMarkerView.wtBtn.frame.origin.y, 30, 30);
    } else {
        tagMarkerView.wtBtn.hidden = YES;
    }
    
    if ([self isNotNull:link] && link.length > 0) {
        tagMarkerView.weblinkBtn.tagLink = link;
        if ([self isNotNull:[tagFields objectForKey:@"tagid"]]) {
            tagMarkerView.weblinkBtn.tagId = [[tagFields objectForKey:@"tagid"] intValue];
        }
        
        tagMarkerView.weblinkBtn.hidden = NO;
        tagMarkerView.weblinkBtn.frame = CGRectMake(tagMarkerView.wtBtn.frame.origin.x + tagMarkerView.wtBtn.frame.size.width, tagMarkerView.weblinkBtn.frame.origin.y, 30, 30);
    } else {
        tagMarkerView.weblinkBtn.hidden = YES;
    }
    
    tagMarkerView.deleteBtn.frame = CGRectMake(deleteBtnXPoint,deleteBtnYPoint, tagMarkerView.deleteBtn.frame.size.width, tagMarkerView.deleteBtn.frame.size.height);
    
    if (editSwitch.on) {
        tagMarkerView.editBtn.hidden = NO;
        [tagMarkerView bringSubviewToFront:tagMarkerView.editBtn];
        tagMarkerView.deleteBtn.hidden = NO;
    } else {
        tagMarkerView.editBtn.hidden = YES;
        tagMarkerView.deleteBtn.hidden = YES;
    }
    
    tagMarkerView.editBtn.tagId = [[tagFields objectForKey:@"tagid"] intValue];
    tagMarkerView.editBtn.clientTagId = [[tagFields objectForKey:@"clientTagId"] intValue];
    
    tagMarkerView.twBtn.tagId = [[tagFields objectForKey:@"tagid"]intValue];
    tagMarkerView.twBtn.clientTagId = [[tagFields objectForKey:@"clientTagId"] intValue];
    
    tagMarkerView.gPlusBtn.tagId = [[tagFields objectForKey:@"tagid"]intValue];
    tagMarkerView.gPlusBtn.clientTagId = [[tagFields objectForKey:@"clientTagId"] intValue];
    
    tagMarkerView.fbBtn.tagId = [[tagFields objectForKey:@"tagid"]intValue];
    tagMarkerView.fbBtn.clientTagId = [[tagFields objectForKey:@"clientTagId"] intValue];
    
    tagMarkerView.deleteBtn.tagId = [[tagFields objectForKey:@"tagid"]intValue];
    tagMarkerView.deleteBtn.clientTagId = [[tagFields objectForKey:@"clientTagId"] intValue];
    
    if ([self isNotNull:[tagFields objectForKey:@"clientTagId"]] && [[tagFields objectForKey:@"clientTagId"] intValue] > 0) {
        tagMarkerView.tag = [[tagFields objectForKey:@"clientTagId"] intValue];
    } else {
        tagMarkerView.tag = [[tagFields objectForKey:@"tagid"] intValue];
    }
    
    int displayTime = [[tagFields objectForKey:@"displaytime"]intValue];
    
    markerDisplayTimer = [NSTimer scheduledTimerWithTimeInterval:displayTime target:self selector:@selector(hideTagMarker:) userInfo:tagFields repeats:NO];
    if (canDisplayTags) {
        tagMarkerView.hidden = NO;
    } else {
        tagMarkerView.hidden = YES;
    }
    TCEND
}


#pragma mark Hash tag text
- (void)hashTagButtonTouchedWithText:(NSString *)text {
    TCSTART
    playPauseBtn.tag = 1;
    [self onClickOfPlayPauseBtn];
    [self gotoTrendsDetailsPageWithText:text];
    TCEND
}
- (void)gotoTrendsDetailsPageWithText:(NSString *)hashText {
    TCSTART
    TrendsDetailsViewController *trendsDetialsVC = [[TrendsDetailsViewController alloc] initWithNibName:@"TrendsDetailsViewController" bundle:nil SelectedTagName:hashText];
    trendsDetialsVC.caller = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:trendsDetialsVC];
    navController.navigationBarHidden = YES;
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:navController animated:YES completion:nil];
    TCEND
}

#pragma mark Phone Number tag text
- (void)phoneNumberTouchedWithText:(NSString *)text {
    TCSTART
    playPauseBtn.tag = 1;
    [self onClickOfPlayPauseBtn];
    if ([self isNotNull:text]) {
        UIAlertView *phoneCallAlertView = [[UIAlertView alloc]initWithTitle:text message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Call", nil];
        [phoneCallAlertView show];
    }
    TCEND
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle caseInsensitiveCompare:@"Call"] == NSOrderedSame) {
        [appDelegate openPhoneApp:alertView.title];
    }
}

- (void)createTagWithCreationFields:(NSMutableDictionary *)tagFields {
    TCSTART
    if (video && video.videoId.intValue > 0) {
        [tagFields setObject:video.videoId forKey:@"videoId"];
    } else if(clientVideoId && clientVideoId.intValue > 0) {
        [tagFields setObject:clientVideoId forKey:@"clientVideoId"];
    } /**else {
       [tagFields setObject:@"1000" forKey:@"videoId"];
       }*/
    
    //Screen resolution
    if ([self isNull:[tagFields objectForKey:@"screenWidth"]]) {
        [tagFields setObject:[NSNumber numberWithFloat:self.view.frame.size.width] forKey:@"screenWidth"];
    }
    
    if ([self isNull:[tagFields objectForKey:@"screenHeight"]]) {
        [tagFields setObject:[NSNumber numberWithFloat:self.view.frame.size.height] forKey:@"screenHeight"];
    }
    
    if ([self isNull:[tagFields objectForKey:@"screenX"]]) {
        [tagFields setObject:[NSNumber numberWithFloat:self.view.frame.origin.x] forKey:@"screenX"];
    }
    
    if ([self isNull:[tagFields objectForKey:@"screenY"]]) {
        [tagFields setObject:[NSNumber numberWithFloat:self.view.frame.origin.y] forKey:@"screenY"];
    }
    
    //Video Resolution
    if ([self isNull:[tagFields objectForKey:@"videoHeight"]]) {
        [tagFields setObject:[NSNumber numberWithFloat:self.view.frame.size.width] forKey:@"videoHeight"];
    }
    
    if ([self isNull:[tagFields objectForKey:@"videoWidth"]]) {
        [tagFields setObject:[NSNumber numberWithFloat:self.view.frame.size.height] forKey:@"videoWidth"];
    }
    
    if ([self isNull:[tagFields objectForKey:@"videoX"]]) {
        [tagFields setObject:[NSNumber numberWithFloat:self.view.frame.origin.x] forKey:@"videoX"];
    }
    
    if ([self isNull:[tagFields objectForKey:@"videoY"]]) {
        [tagFields setObject:[NSNumber numberWithFloat:self.view.frame.origin.y] forKey:@"videoY"];
    }
    
    if ([self isNotNull:appDelegate.loggedInUser.userId]) {
        [tagFields setObject:appDelegate.loggedInUser.userId forKey:@"uid"];
    }
    [[DataManager sharedDataManager] addTag:tagFields];
    
    //NSLog(@"VideoId:%@",video.videoId);
    if (video && video.videoId.intValue > 0) {
        if ([[tagFields objectForKey:@"tagid"] intValue] > 0) {
            //update tags
            [appDelegate makeUpdateTagsRequestCaller:self];
        } else {
            //AddTags Request
            [appDelegate makeAddTagsRequestWithCaller:self ofUserWithUserId:video.userId];
        }
    } else {
        [createdTagsArray removeAllObjects];
        createdTagsArray = [[[DataManager sharedDataManager] getAllTagsByVideoIdAndClientVideoId:[NSDictionary dictionaryWithObjectsAndKeys:clientVideoId,@"clientVideoId", nil]] mutableCopy];
        [self updateTagMarkerOnSlider:nil];
    }
    TCEND
}

#pragma mark Addtags Request callBack
- (void)addTagsResponseForVideoCompleted:(BOOL)tagAdded andResults:(NSDictionary *)results {
    TCSTART
    if ([self isNotNull:[results objectForKey:@"tags"]] && [self isNotNull:[results objectForKey:@"tags"]]) {
        [appDelegate shareVideoInformationToSocialSites:video andTag:[results objectForKey:@"tags"]];
    }
    
    [createdTagsArray removeAllObjects];
    createdTagsArray = [[[DataManager sharedDataManager] getAllTagsByVideoIdAndClientVideoId:[NSDictionary dictionaryWithObjectsAndKeys:video.videoId,@"videoId", nil]] mutableCopy];
    if (tagAdded) {
        NSInteger numberOfTags = [video.numberOfTags integerValue];
        numberOfTags = numberOfTags + 1;
        video.numberOfTags = [NSNumber numberWithInt:numberOfTags];
    }
    TCEND
}

- (void)didFailAddingTags {
    TCSTART
    [createdTagsArray removeAllObjects];
    createdTagsArray = [[[DataManager sharedDataManager] getAllTagsByVideoIdAndClientVideoId:[NSDictionary dictionaryWithObjectsAndKeys:video.videoId,@"videoId", nil]] mutableCopy];
//    [self updateTagMarkerOnSlider:nil];
    TCEND
}


#pragma mark remove all tagmarks
- (void)removeAllTagMarksOnSliderOfPlayerBottomView {
    TCSTART
    NSArray *playerBottomViewSubviews = [playerBottomView subviews];
    for (int i = 0; i < playerBottomViewSubviews.count; i++) {
        if ([[playerBottomViewSubviews objectAtIndex:i] tag] == -10000) {
            TagMarkerView *view = [playerBottomViewSubviews objectAtIndex:i];
            [view removeFromSuperview];
        }
    }
    TCEND
}

#pragma mark create tag marks
- (void)createTagMarkOnSliderAt:(UISlider *)slider {
    TCSTART
    
    //NSLog(@"\n\n\n\nSlider Minimum Value %f",slider.minimumValue);
    //NSLog(@"Slider Maximum Value %f",slider.maximumValue);
    //NSLog(@"Slider Value %f",slider.value);
    
    CGFloat sliderMin =  slider.minimumValue;
	CGFloat sliderMax = slider.maximumValue;
	CGFloat sliderMaxMinDiff = sliderMax - sliderMin;
	CGFloat sliderValue = slider.value;
	
	if(sliderMin < 0.0) {
        
		sliderValue = slider.value - sliderMin;
		sliderMax = sliderMax - sliderMin;
		sliderMin = 0.0;
		sliderMaxMinDiff = sliderMax - sliderMin;
	}
	
    UIImageView *sliderMarkImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"VideoTagPoint"]];
    sliderMarkImgView.frame = CGRectMake(0, 0, 20, 20);
    
	CGFloat xCoord = ((sliderValue-sliderMin)/sliderMaxMinDiff)*[slider frame].size.width-sliderMarkImgView.frame.size.width/2.0;
    //NSLog(@"Xcoord :%f",((sliderValue-sliderMin)/sliderMaxMinDiff));
	xCoord += slider.frame.origin.x;
    //NSLog(@"Xcoord :%f",xCoord);
	CGFloat halfMax = (sliderMax+sliderMin)/2.0;
	
	if(sliderValue > halfMax) {
		
		sliderValue = (sliderValue - halfMax)+(sliderMin*1.0);
		sliderValue = sliderValue/halfMax;
		sliderValue = sliderValue*11.0;
		
		xCoord = xCoord - sliderValue;
	}
	
	else if(sliderValue <  halfMax) {
		
		sliderValue = (halfMax - sliderValue)+(sliderMin*1.0);
		sliderValue = sliderValue/halfMax;
		sliderValue = sliderValue*11.0;
		
		xCoord = xCoord + sliderValue;
	}
    //NSLog(@"TagMarkOnSlider At %f",xCoord);
    sliderMarkImgView.frame = CGRectMake(xCoord, 0, 20, 20);
    sliderMarkImgView.tag = -10000;
    [playerBottomView addSubview:sliderMarkImgView];
    //    playingFirstTime = NO;
    TCEND
}

-(void)hideTagMarker:(NSTimer *)timer {
    TCSTART
    if (playPauseBtn.tag == 0) {
        return;
    }
    NSMutableDictionary *tagFields = timer.userInfo;
    
    TagMarkerView *view;
    if ([self isNotNull:[tagFields objectForKey:@"clientTagId"]] && [[tagFields objectForKey:@"clientTagId"] intValue] > 0) {
        view = (TagMarkerView *)[moviePlayerController.view viewWithTag:[[tagFields objectForKey:@"clientTagId"]intValue]];
    } else if ([self isNotNull:[tagFields objectForKey:@"tagid"]] && [[tagFields objectForKey:@"tagid"] intValue] > 0){
        view = (TagMarkerView *)[moviePlayerController.view viewWithTag:[[tagFields objectForKey:@"tagid"]intValue]];
    }
    if (!view.editBtn.hidden && tagMarkerView.tag == view.tag) {
        ////NSLog(@"edit view timer called return without hiding it.");
        return;
    }
    [view removeFromSuperview];
    //NSLog(@"Remove TagMarker");
    TCEND
}


- (void)cancelTagTool:(NSNotification *)notification {
    TCSTART
    //    tagMarkerView.editBtn.enabled = YES;
    [tagToolVC.view removeFromSuperview];
    tagToolVC = nil;
    showInstructnScreen = NO;
    [self onClickOfCancelTagMarker:nil];
    TCEND
}

- (void)editTag:(NSNotification *)notification {
    TCSTART
    CustomButton *btn = notification.object;
    btn.enabled = NO;
    for (Tag *tag in createdTagsArray) {
        if ( (tag.tagId.intValue > 0 && tag.tagId.intValue == btn.tagId) || tag.clientTagId.intValue == btn.clientTagId) {
            [self removeTagMarker];
            playPauseBtn.tag = 1;
            [self onClickOfPlayPauseBtn];
            [self hidePlayerControlles];
            [self hidePlayerSettingsView];
            
            if ([self isNotNull:tag.clientTagId] && [tag.clientTagId intValue] > 0) {
                tagMarkerView = (TagMarkerView *)[moviePlayerController.view viewWithTag:tag.clientTagId.intValue];
                if (!tagMarkerView) {
                    tagMarkerView = (TagMarkerView *)[moviePlayerController.view viewWithTag:tag.tagId.intValue];
                }
            } else {
                tagMarkerView = (TagMarkerView *)[moviePlayerController.view viewWithTag:tag.tagId.intValue];
            }
            
            [self onClickOfConfirmTagMarker:nil];
            [tagToolVC updateTagToolObjects:tag];
            break;
        }
    }
    TCEND
}

- (void)removeTagMarkerViewWithTagId:(NSNumber *)tagId orClientTagId:(NSNumber *)clientTagId {
    TCSTART
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:tagId?:[NSNumber numberWithInt:0],@"tagid",clientTagId?:[NSNumber numberWithInt:0],@"clientTagId", nil];
    Tag *tag = [[DataManager sharedDataManager] getTagByTagIdORClientTagId:dict];
    
    if ([self isNotNull:tag]) {
        TagMarkerView *view;
        if ([self isNotNull:tag.clientTagId] && [tag.clientTagId intValue] > 0) {
            view = (TagMarkerView *)[moviePlayerController.view viewWithTag:tag.clientTagId.intValue];
            if (!view) {
                view = (TagMarkerView *)[moviePlayerController.view viewWithTag:tag.tagId.intValue];
            }
        } else {
            view = (TagMarkerView *)[moviePlayerController.view viewWithTag:tag.tagId.intValue];
        }
        
        [view removeFromSuperview];
        [createdTagsArray removeObject:tag];
        [self removeAllTagMarksOnSliderOfPlayerBottomView];
        [self updateTagMarkerOnSlider:nil];
        [[DataManager sharedDataManager] deleteTag:tag];
    }
    
    TCEND
}

-(void)removeAllTagMarkers {
    TCSTART
    NSArray *moviePlayerSubviews = [moviePlayerController.view subviews];
    for (int i = 0; i < moviePlayerSubviews.count; i++) {
        if ([[moviePlayerSubviews objectAtIndex:i] isKindOfClass:[TagMarkerView class]]) {
            
            TagMarkerView *view = [moviePlayerSubviews objectAtIndex:i];
            [view removeFromSuperview];
        }
    }
    TCEND
}

- (void)updateAllTagMarkers {
    TCSTART
    NSArray *moviePlayerSubviews = [moviePlayerController.view subviews];
    for (int i = 0; i < moviePlayerSubviews.count; i++) {
        if ([[moviePlayerSubviews objectAtIndex:i] isKindOfClass:[TagMarkerView class]]) {
            
            TagMarkerView *view = [moviePlayerSubviews objectAtIndex:i];
            if (editSwitch.on) {
                view.editBtn.hidden = NO;
                [view bringSubviewToFront:tagMarkerView.editBtn];
                view.deleteBtn.hidden = NO;
            } else {
                view.editBtn.hidden = YES;
                view.deleteBtn.hidden = YES;
            }
        }
    }
    TCEND
}


#pragma mark - gesture delegate
// this allows you to dispatch touches
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    // Disallow recognition of tap gestures in the UIButton.
    if (([touch.view isKindOfClass:[UIButton class]]) || [touch.view isKindOfClass:[UISlider class]]) {
        return NO;
    }
    
    if (tagToolVC) {
        return NO;
    }
    
    touchPoint = [touch locationInView:moviePlayerController.view];
    //    //NSLog(@"touch point %f %f", touchPoint.x,touchPoint.y);
    return YES;
}

// this enables you to handle multiple recognizers on single view
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    
    if (!tagMarkerView) {
        if (!playerTopView.hidden) {
            [self hidePlayerControlles];
        } else {
            [self showPlayerControlles];
        }
    } else {
        [self showAndUpdateTagMarkerView];
    }
    [messageTextView resignFirstResponder];
}

-(void)handlePinchGesture:(UIPinchGestureRecognizer *)pinchGesture {
    TCSTART
    if (playPauseBtn.tag == 1) {
        return;
    }
    //NSLog(@"latscale = %f",mLastScale);
    
    mCurrentScale += [pinchGesture scale] - mLastScale;
    mLastScale = [pinchGesture scale];
    
    if (pinchGesture.state == UIGestureRecognizerStateEnded)
    {
        mLastScale = 1.0;
    }
    
    CGAffineTransform currentTransform = CGAffineTransformIdentity;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform,mCurrentScale, mCurrentScale);
    moviePlayerController.view.transform = newTransform;
    
    //    pinchGesture.view.transform = CGAffineTransformScale(pinchGesture.view.transform, pinchGesture.scale, pinchGesture.scale);
    //    pinchGesture.scale = 1;
    TCEND
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
}

/* Returns a URL to a local movie in the app bundle. */
-(NSURL *)localMovieURL
{
    TCSTART
	NSURL *theMovieURL = nil;
	NSBundle *bundle = [NSBundle mainBundle];
	if (bundle)
	{
		NSString *moviePath = [bundle pathForResource:@"Movie" ofType:@"m4v"];
		if (moviePath)
		{
			theMovieURL = [NSURL fileURLWithPath:moviePath];
		}
	}
    return theMovieURL;
    TCEND
}

- (void)createAndConfigurePlayerWithURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType {
    TCSTART
    /* Create a new movie player object. */
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    
    if (player) {
        /* Save the movie object. */
        moviePlayerController = player;
        
        player.controlStyle = MPMovieControlStyleNone;
        
        /* Register the current object as an observer for the movie
         notifications. */
        [self installMovieNotificationObservers];
        
        /* Specify the URL that points to the movie file. */
        [player setContentURL:movieURL];
        
        /* If you specify the movie type before playing the movie it can result
         in faster load times. */
        //[player setMovieSourceType:sourceType];
        
        /* Apply the user movie preference settings to the movie player object. */
        //[self applyUserSettingsToMoviePlayer];
        
        /* Add a background view as a subview to hide our other view controls
         underneath during movie playback. */
        [player.view addSubview:playerTopView];
        [player.view addSubview:playerBottomView];
        [player.view addSubview:playerSettingsView];
        optionsView.userInteractionEnabled = NO;
        /* Inset the movie frame in the parent view frame. */
        [[player view] setFrame:self.view.frame];
        
        [player view].backgroundColor = [UIColor blackColor];
        
        [self insertLoadingViewAtFirstPositionOfPlayerView];
        /* To present a movie in your application, incorporate the view contained
         in a movie player’s view property into your application’s view hierarchy.
         Be sure to size the frame correctly. */
        [self.view addSubview: [player view]];
    }
    TCEND
}

- (void)insertLoadingViewAtFirstPositionOfPlayerView {
    TCSTART
    if ([self isNull:loadingView]) {
        loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        loadingView.backgroundColor = [UIColor clearColor];
        /**UIImage *image;
         if ([[UIScreen mainScreen] bounds].size.height > 480) {
         image = [UIImage imageNamed:@"PlayerBgiPhone5"];
         } else {
         image = [UIImage imageNamed:@"PlayerBg"];
         }
         UIImageView *backgroundImgView = [[UIImageView alloc] initWithImage:image];
         backgroundImgView.frame = CGRectMake(0, 0, loadingView.frame.size.width, loadingView.frame.size.height);
         [loadingView addSubview:backgroundImgView];*/
        [moviePlayerController.view insertSubview:loadingView atIndex:0];
    } else {
        loadingView.hidden = NO;
    }
    [appDelegate showActivityIndicatorInView:loadingView andText:@"Buffering"];
    TCEND
}

#pragma mark Movie Notification Handlers
#pragma mark MPMoviePlayerLoadStateDidChangeNotification
- (void)moviePlayerLoadStateChanged:(NSNotification *)notification {
    @try {
        if ([[notification object] loadState] == MPMovieLoadStateUnknown)
            return;
        
        NSDictionary *userInfo = [notification userInfo];
        
        NSError *error = [userInfo objectForKey:@"error"];
        //NSLog(@"Error:%@",error);
        
        if (!error) {
            videoProgressSlider.value = 0.0;
            optionsView.userInteractionEnabled = YES;
            [self startPlayer];
            [self removeLoadingViewFromPlayerView];
            [self showPlayerControlles];
            [self checkForFirstTime];
        } else {
            [self onClickOfStopBtn:nil];
            [ShowAlert showError:[error localizedDescription]];
        }
    }
    @catch (NSException *exception) {
        //NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
        
    }
}

- (void)checkForFirstTime {
    TCSTART
//    if ([self isNotNull:video] && [self isNotNull:video.userId] && appDelegate.loggedInUser.userId.intValue != video.userId.intValue && ![appDelegate.ftue.openOthersVideo boolValue]) {
//        isFirstTimeOpened = YES;
//        appDelegate.ftue.openOthersVideo = [NSNumber numberWithBool:YES];
//        [[DataManager sharedDataManager] saveChanges];
//        othersVideoToastView.frame = CGRectMake((appDelegate.window.frame.size.height - 420)/2, (appDelegate.window.frame.size.width - 120)/2, 420, 100);
//        playPauseBtn.tag = 1;
//        [self onClickOfPlayPauseBtn];
//        [self.view addSubview:othersVideoToastView];
//        [self.view bringSubviewToFront:othersVideoToastView];
//    }
    NSInteger othersVideoopenCoutnt = 1;
    if ([self isNotNull:[[NSUserDefaults standardUserDefaults] objectForKey:@"openothersvideocount"]]) {
        othersVideoopenCoutnt = [[[NSUserDefaults standardUserDefaults] objectForKey:@"openothersvideocount"] integerValue];
    }
    if ([self isNotNull:video] && [self isNotNull:video.userId] && appDelegate.loggedInUser.userId.intValue != video.userId.intValue && othersVideoopenCoutnt <= 10) {
        isFirstTimeOpened = YES;
        othersVideoopenCoutnt = othersVideoopenCoutnt + 1;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:othersVideoopenCoutnt] forKey:@"openothersvideocount"];
        introzoneView.frame = CGRectMake(0, 0, appDelegate.window.frame.size.height, appDelegate.window.frame.size.width-20);
        playPauseBtn.tag = 1;
        [self onClickOfPlayPauseBtn];
        [self.view addSubview:introzoneView];
        [self.view bringSubviewToFront:introzoneView];
    } else {
        introzoneView = nil;
    }
    
    if (showInstructnScreen) {
        if (![appDelegate.ftue.tagged boolValue]) {
            isFirstTimeOpened = YES;
            playPauseBtn.tag = 1;
            [self onClickOfPlayPauseBtn];
            [self hidePlayerControlles];
            [self onClickOfConfirmTagMarker:nil];
        }
    }
    TCEND
}

- (void)startPlayer {
    TCSTART
    if (video && video.videoId.intValue > 0) {
        [self performSelector:@selector(updateTagMarkerOnSlider:) withObject:nil afterDelay:1.0];
    } else {
        [self performSelector:@selector(updateTagMarkerOnSlider:) withObject:nil afterDelay:0.3];
    }
    TCEND
}
/*  Notification called when the movie finished playing. */
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    TCSTART
    [self removeMovieNotificationHandlers];
    
    NSNumber *reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
	switch ([reason integerValue]) {
            /* The end of the movie was reached. */
		case MPMovieFinishReasonPlaybackEnded:
            //NSLog(@"MPMovieFinishReasonPlaybackEnded");
            [playPauseBtn setImage:[UIImage imageNamed:@"MypageVideoPlayBtn"] forState:UIControlStateNormal];
            playPauseBtn.tag = 0;
            [moviePlayerController pause];
			break;
            
            /* An error was encountered during playback. */
		case MPMovieFinishReasonPlaybackError:
            //NSLog(@"An error was encountered during playback");
            [self performSelectorOnMainThread:@selector(displayError:) withObject:[[notification userInfo] objectForKey:@"error"]
                                waitUntilDone:NO];
            [self onClickOfStopBtn:nil];
            //[self hidePlayerControlles];
            //[self.backgroundView removeFromSuperview];
			break;
            
            /* The user stopped playback. */
		case MPMovieFinishReasonUserExited:
            [self onClickOfStopBtn:nil];
            //[self removeMovieViewFromViewHierarchy];
            //[self removeOverlayView];
            //[self.backgroundView removeFromSuperview];
			break;
            
		default:
			break;
	}
    
    TCEND
}

- (void)displayError:(NSError *)error {
    TCSTART
    //NSLog(@"Error : %@",error);
    [ShowAlert showError:[error localizedDescription]];
    TCEND
}
/* Handle movie load state changes. */
- (void)loadStateDidChange:(NSNotification *)notification
{
    TCSTART
	MPMoviePlayerController *player = notification.object;
	MPMovieLoadState loadState = player.loadState;
    
	/* The load state is not known at this time. */
	if (loadState & MPMovieLoadStateUnknown)
	{
        //        [self.overlayController setLoadStateDisplayString:@"n/a"];
        //
        //        [overlayController setLoadStateDisplayString:@"unknown"];
	}
	
	/* The buffer has enough data that playback can begin, but it
	 may run out of data before playback finishes. */
	if (loadState & MPMovieLoadStatePlayable)
	{
        //[overlayController setLoadStateDisplayString:@"playable"];
	}
	
	/* Enough data has been buffered for playback to continue uninterrupted. */
	if (loadState & MPMovieLoadStatePlaythroughOK)
	{
        // Add an overlay view on top of the movie view
        //[self addOverlayView];
        
        //[overlayController setLoadStateDisplayString:@"playthrough ok"];
	}
	
	/* The buffering of data has stalled. */
	if (loadState & MPMovieLoadStateStalled)
	{
        //[overlayController setLoadStateDisplayString:@"stalled"];
	}
    TCEND
}

/* Called when the movie playback state has changed. */
- (void) moviePlayBackStateDidChange:(NSNotification*)notification
{
    TCSTART
	MPMoviePlayerController *player = notification.object;
    
	/* Playback is currently stopped. */
	if (player.playbackState == MPMoviePlaybackStateStopped)
	{
        //[overlayController setPlaybackStateDisplayString:@"stopped"];
	}
	/*  Playback is currently under way. */
	else if (player.playbackState == MPMoviePlaybackStatePlaying)
	{
        //[overlayController setPlaybackStateDisplayString:@"playing"];
	}
	/* Playback is currently paused. */
	else if (player.playbackState == MPMoviePlaybackStatePaused)
	{
        //[overlayController setPlaybackStateDisplayString:@"paused"];
	}
	/* Playback is temporarily interrupted, perhaps because the buffer
	 ran out of content. */
	else if (player.playbackState == MPMoviePlaybackStateInterrupted)
	{
        //[overlayController setPlaybackStateDisplayString:@"interrupted"];
	}
    TCEND
}

/* Notifies observers of a change in the prepared-to-play state of an object
 conforming to the MPMediaPlayback protocol. */
- (void) mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
	// Add an overlay view on top of the movie view
    [self showPlayerControlles];
}


- (void) movieNaturalSizeAvailable:(NSNotification *)notification {
    TCSTART
//    MPMoviePlayerController *player = notification.object;
    //NSLog(@"player actual size : %f %f",player.naturalSize.width,player.naturalSize.height);
    TCEND
}

#pragma mark Install Movie Notifications

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    TCSTART
    MPMoviePlayerController *player = moviePlayerController;
    
    //this is for checking whether loding is done or not.if loding is done it calls movieplayerloadstatechanged...
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerLoadStateChanged:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieNaturalSizeAvailable:)
                                                 name:MPMovieNaturalSizeAvailableNotification
                                               object:player];
    //	[[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
    //                                                 name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
    //                                               object:player];
    //
    //	[[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(moviePlayBackStateDidChange:)
    //                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
    //                                               object:player];
    TCEND
}


#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationHandlers
{
    TCSTART
    MPMoviePlayerController *player = moviePlayerController;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMovieNaturalSizeAvailableNotification object:player];
    
    TCEND
}

- (void)removeTagNBackgroundObservers {
    TCSTART
    if (sliderTimer) {
        [sliderTimer invalidate];
        sliderTimer = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_UPDATED_TAG_COLOR object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_TAG_PUBLISH object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_TAGTOOL_CANCEL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_TAG_EDIT object:nil];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    TCEND
}

#pragma mark Handling Player Gesture Events
- (void)hidePlayerControlles {
    TCSTART
    playerTopView.hidden = YES;
    if (playerSettingsView.hidden) {
        playerBottomView.hidden = YES;
    }
    TCEND
}

- (void)showPlayerControlles {
    TCSTART
    if (playerTopView.hidden) {
        [NSTimer scheduledTimerWithTimeInterval:7.0f target:self selector:@selector(hidePlayerControlles) userInfo:nil repeats:NO];
        playerTopView.hidden = NO;
        playerBottomView.hidden = NO;
        [moviePlayerController.view bringSubviewToFront:playerBottomView];
        [moviePlayerController.view bringSubviewToFront:playerTopView];
    }
    TCEND
}

- (void)hidePlayerSettingsView {
    TCSTART
    if (playerTopView.hidden) {
        playerBottomView.hidden = YES;
    }
    playerSettingsView.hidden = YES;
    TCEND
}

- (void)showPlayerSettingsView {
    TCSTART
    if (!tagMarkerView) {
        playerSettingsView.hidden = NO;
    }
    TCEND
}

#pragma mark Playback Controls
//This is the method for the Play/Pause buttonfor player control.
- (IBAction)onClickOfPlayPauseBtn {
    TCSTART
	if(playPauseBtn.tag == 0) {
        playPauseBtn.tag = 1;
        
        [playPauseBtn setImage:[UIImage imageNamed:@"PauseBtn"] forState:UIControlStateNormal];
    
        [moviePlayerController play];
        if (sliderTimer == nil) {
            sliderTimer = [NSTimer scheduledTimerWithTimeInterval:.05 target:self selector:@selector(changeSlider) userInfo:nil repeats:YES ];
        }
        [self removeAllTagMarkers];
        if (isFirstTimeOpened) {
            isFirstTimeOpened = NO;
            [self performSelector:@selector(updateTagMarkerOnSlider:) withObject:nil afterDelay:0.3];
        }
    } else {
        playPauseBtn.tag = 0;
        [playPauseBtn setImage:[UIImage imageNamed:@"MypageVideoPlayBtn"] forState:UIControlStateNormal];
        [moviePlayerController pause];
        if (sliderTimer) {
            [sliderTimer invalidate];
            sliderTimer = nil;
        }
    }
    TCEND
}

//Method for stop button of the Player.
- (IBAction)onClickOfStopBtn:(UIButton *)sender {
	TCSTART
    if (sliderTimer) {
        [sliderTimer invalidate];
        sliderTimer = nil;
    }
    [self removeMovieNotificationHandlers];
    [self removeTagNBackgroundObservers];
    [moviePlayerController stop];
    [moviePlayerController.view removeFromSuperview];
    moviePlayerController = nil;
    [playPauseBtn setImage:[UIImage imageNamed:@"MypageVideoPlayBtn"] forState:UIControlStateNormal];
    playPauseBtn.tag = 0;

    NSInteger numberofviews = [video.numberOfViews integerValue];
    numberofviews = numberofviews + 1;
    video.numberOfViews = [NSNumber numberWithInt:numberofviews];
    
    if ([self isNotNull:caller] && [caller respondsToSelector:@selector(allCommentsScreenDismissCalledSelectedIndexPath:andViewType:)]) {
        [caller allCommentsScreenDismissCalledSelectedIndexPath:selectedIndexPath andViewType:@"Comment"];
    } else if ([caller respondsToSelector:@selector(playerScreenDismissed)]) {
        if (sender.tag == -10) {
            if ([caller respondsToSelector:@selector(clickedOnPlayerScreenBackButton)]) {
                [caller clickedOnPlayerScreenBackButton];
            }
        } else {
            [caller playerScreenDismissed];
        }
    }
    if ([caller isKindOfClass:[SelectCoverFrameViewController class]]) {
        [self dismissViewControllerAnimated:NO completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    TCEND
}

#pragma mark Player Settings Control Actions
-(IBAction) onClickOfSettingsBtn {
    TCSTART
    if (playerSettingsView.hidden == YES) {
        if (([self isNotNull:video.userId] && video.userId.intValue == appDelegate.loggedInUser.userId.intValue) || ([self isNull:video] && [self isNotNull:clientVideoId])) {
            editSwitch.userInteractionEnabled = YES;
        } else {
            editSwitch.userInteractionEnabled = NO;
        }
        [self showPlayerSettingsView];
        [moviePlayerController.view bringSubviewToFront:playerSettingsView];
    } else {
        [self hidePlayerSettingsView];
    }
    TCEND
}

- (IBAction)tagSettingsSwitchChanged:(id)sender {
    TCSTART
    if (tagSwitch.on) {
        canDisplayTags = YES;
        [self unhideAllTagMarkersOnView];
    } else {
        canDisplayTags = NO;
        [self hideAllTagMarkersOnView];
    }
    TCEND
}

- (void)unhideAllTagMarkersOnView {
    TCSTART
    NSArray *moviePlayerSubviews = [moviePlayerController.view subviews];
    for (int i = 0; i < moviePlayerSubviews.count; i++) {
        if ([[moviePlayerSubviews objectAtIndex:i] isKindOfClass:[TagMarkerView class]]) {
            
            TagMarkerView *view = [moviePlayerSubviews objectAtIndex:i];
            view.hidden = NO;
        }
    }
    
    TCEND
}

- (void)hideAllTagMarkersOnView {
    TCSTART
    NSArray *moviePlayerSubviews = [moviePlayerController.view subviews];
    for (int i = 0; i < moviePlayerSubviews.count; i++) {
        if ([[moviePlayerSubviews objectAtIndex:i] isKindOfClass:[TagMarkerView class]]) {
            
            TagMarkerView *view = [moviePlayerSubviews objectAtIndex:i];
            view.hidden = YES;
        }
    }
    TCEND
}
-(IBAction)editSettingsSwitchChanged:(id)sender {
    TCSTART
    [self updateAllTagMarkers];
    TCEND
}

//-(IBAction)onClickOfPrivacySettingsBtn:(id)sender {
//    TCSTART
//    if ([privacyLbl.text isEqualToString:@"Off"]) {
//        privacyLbl.text = @"On";
//    } else if ([privacyLbl.text isEqualToString:@"On"]) {
//        privacyLbl.text = @"Off";
//    }
//    TCEND
//}

#pragma mark Player RightView Actions
#pragma mark
#pragma Share
-(IBAction)onClickOfShareBtn:(id)sender {
    TCSTART
    playPauseBtn.tag = 1;
    [self onClickOfPlayPauseBtn];
    ShareViewController *shareVC = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil withSelectedVideo:video andCaller:self];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:shareVC];
    navController.navigationBarHidden = YES;
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:navController animated:YES completion:nil];
    TCEND
}

#pragma mark
#pragma mark Like Video Delegate Methods
-(IBAction)onClickOfLikeBtn:(id)sender {
    if ([self isNotNull:video]) {
        playPauseBtn.tag = 1;
        [self onClickOfPlayPauseBtn];
        [appDelegate makeRequestForLikeVideoWithVideoId:video.videoId andCaller:self andIndexPaht:nil];
    }
}

- (void)didFinishedLikeVideo:(NSDictionary *)results {
    TCSTART

    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    NSInteger likesCount = [video.numberOfLikes integerValue];
    likesCount = likesCount + 1;
    video.numberOfLikes = [NSNumber numberWithInteger:likesCount];
    
    NSMutableArray *likeList = [[NSMutableArray alloc] initWithArray:video.likesList];
    [likeList insertObject:[NSDictionary dictionaryWithObjectsAndKeys:appDelegate.loggedInUser.userId,@"user_id",appDelegate.loggedInUser.userName?:@"",@"user_name", nil] atIndex:0];
    video.likesList = likeList;
    video.hasLovedVideo = YES;
    //    [[DataManager sharedDataManager] saveChanges];
    TCEND
}
- (void)didFailedLikeVideoWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

#pragma mark
#pragma mark Comment Related Methods and Get All Comments Delegate methods
-(IBAction)onClickOfCommentBtn:(id)sender {
    TCSTART
    if ([self isNotNull:video]) {
        playPauseBtn.tag = 1;
        [self onClickOfPlayPauseBtn];
        [self gotoAllCommentsScreenWithVideo:video];
    }
    TCEND
}

- (void)gotoAllCommentsScreenWithVideo:(VideoModal *)video_ {
    TCSTART
    allCmntsVC = [[AllCommentsViewController alloc] initWithNibName:@"AllCommentsViewController" bundle:nil withVideoModal:video_ user:nil viewType:@"Comment" andSelectedIndexPath:nil andTotalCount:[video_.numberOfCmnts integerValue] andCaller:self];
    
    allCmntsVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:allCmntsVC];
    navController.navigationBarHidden = YES;
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:navController animated:YES completion:nil];
    TCEND
}

- (void)allCommentsScreenDismissCalledSelectedIndexPath:(NSIndexPath *)indexPath andViewType:(NSString *)viewType {
    TCSTART
    allCmntsVC = nil;
    TCEND
}

#pragma mark
#pragma mark Tag
- (IBAction)onClickOfTagBtn:(id)sender {
    TCSTART
    [self removeToastView];
    if (([self isNotNull:video.userId] && video.userId.intValue == appDelegate.loggedInUser.userId.intValue) || ([self isNull:video] && [self isNotNull:clientVideoId])) {
        playPauseBtn.tag = 1;
        [self onClickOfPlayPauseBtn];
//        NSLog(@"CurrentPlayBackTime:%f",moviePlayerController.currentPlaybackTime);
        
        tagMarkerView = [[[NSBundle mainBundle] loadNibNamed:@"TagMarkerView" owner:nil options:nil] objectAtIndex:0];
        tagMarkerView.caller = self;
        tagMarkerView.editBtn.hidden = YES;
        tagMarkerView.deleteBtn.hidden = YES;
        
        [self hidePlayerControlles];
        [self hidePlayerSettingsView];
        
        cancelTagMarkerBtn.hidden = NO;
        confirmTagMarkerBtn.hidden = NO;
        
        //When tag button is selected reset the touchpoint to 0,0 to place the marker at top left corner within the player.
        touchPoint = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
        
        [self showAndUpdateTagMarkerView];
//        if ([self isNotNull:clientVideoId] && ![appDelegate.ftue.placeTagMarker boolValue]) {
//            appDelegate.ftue.placeTagMarker = [NSNumber numberWithBool:YES];
//            toastView = [appDelegate getToastViewWithMessageText:kPlaceMarker andFrame:CGRectMake((appDelegate.window.frame.size.height - 324)/2, (appDelegate.window.frame.size.width - 200)/2 + 20, 324, 200)];
//            [self.view addSubview:toastView];
//            [self.view bringSubviewToFront:toastView];
//        }
    } else {
        if (![appDelegate.ftue.tagOnOthersVideo boolValue]) {
            topViewTagBtn.userInteractionEnabled = NO;
            topViewTagBtn.enabled = NO;
            appDelegate.ftue.tagOnOthersVideo = [NSNumber numberWithBool:YES];
            toastView = [appDelegate getToastViewWithMessageText:kTagOnOthersVideo andFrame:CGRectMake((appDelegate.window.frame.size.height - 324)/2, (appDelegate.window.frame.size.width - 150)/2 + 20, 324, 150)];
            playPauseBtn.tag = 1;
            [self onClickOfPlayPauseBtn];
            [self.view addSubview:toastView];
            [self.view bringSubviewToFront:toastView];
            
        }
    }
    TCEND
}

#pragma mark TagMarker
-(void)showAndUpdateTagMarkerView {
    TCSTART
    [moviePlayerController.view addSubview:tagMarkerView];
//    tagMarkerView.frame = CGRectMake(0, 0, 213, tagMarkerView.frame.size.height);
    tagMarkerView.markernameTxtView.hidden = YES;
    tagMarkerView.markerLinkBtn.hidden = YES;
    tagMarkerView.fbBtn.hidden = YES;
    tagMarkerView.twBtn.hidden = YES;
    tagMarkerView.gPlusBtn.hidden = YES;
    tagMarkerView.weblinkBtn.hidden = YES;
    tagMarkerView.wtBtn.hidden = YES;
    
    
    CGFloat markerViewYPoint = 0.0f;
    CGFloat markerViewXPoint = 0.0f;
    CGFloat nextBtnXPoint = 0.0f;
    CGFloat nextBtnYPoint = 0.0f;
    
    //    CGFloat xThresholdPoint = self.view.frame.size.height/2;//landscape
    //    CGFloat yThresholdPoint = self.view.frame.size.width/2;//landscape
    CGFloat xThresholdPoint = self.view.frame.size.height - 213;
    CGFloat yThresholdPoint = tagMarkerView.frame.size.height;
    
    
    //    //NSLog(@"Touch point %f %f",touchPoint.x, touchPoint.y);
    if (touchPoint.y > yThresholdPoint) {
        markerViewYPoint = touchPoint.y - tagMarkerView.frame.size.height;
        nextBtnYPoint = markerViewYPoint + 20;
    } else {
        markerViewYPoint = touchPoint.y;
        nextBtnYPoint = markerViewYPoint + 35;
    }
    
    if (touchPoint.x > xThresholdPoint) {
        markerViewXPoint = touchPoint.x - ((![tagMarkerView.deleteBtn isHidden])?213:180);
        nextBtnXPoint = markerViewXPoint - confirmTagMarkerBtn.frame.size.width;
    } else {
        markerViewXPoint = touchPoint.x;
        nextBtnXPoint = markerViewXPoint + ((![tagMarkerView.deleteBtn isHidden])?213:180);
    }
    
    NSString *imageName = nil;
    if (touchPoint.y > yThresholdPoint && touchPoint.x < xThresholdPoint) {
        imageName = @"arrow_right_down";
    } else if(touchPoint.x > xThresholdPoint && touchPoint.y < yThresholdPoint) {
        imageName = @"arrow_left_up";
    } else if(touchPoint.x > xThresholdPoint && touchPoint.y > yThresholdPoint) {
        imageName = @"arrow_left_down";
    } else if(touchPoint.x < xThresholdPoint && touchPoint.y < yThresholdPoint) {
        imageName = @"arrow_right_up";
    }
    //    if (![tagMarkerView.deleteBtn isHidden]) {
    //        imageName = [NSString stringWithFormat:@"%@l",imageName];
    //    }
    
    if (![tagMarkerView.deleteBtn isHidden]) {
        tagMarkerView.frame = CGRectMake(markerViewXPoint, markerViewYPoint, 213, tagMarkerView.frame.size.height);
    } else {
        tagMarkerView.frame = CGRectMake(markerViewXPoint, markerViewYPoint, 180, tagMarkerView.frame.size.height);
    }
    tagMarkerView.markerImageView.image = [UIImage imageNamed:imageName];
    tagMarkerView.markerImageView.accessibilityIdentifier = imageName;
    
    //update the confirm and cancel tag marker buttons frame.
    cancelTagMarkerBtn.frame = CGRectMake(10, 10, 68, 27);
    confirmTagMarkerBtn.frame = CGRectMake(nextBtnXPoint,nextBtnYPoint , confirmTagMarkerBtn.frame.size.width, confirmTagMarkerBtn.frame.size.height);
    [moviePlayerController.view addSubview:confirmTagMarkerBtn];
    [moviePlayerController.view addSubview:cancelTagMarkerBtn];
    TCEND
}

-(IBAction)onClickOfConfirmTagMarker:(id)sender {
    TCSTART
    cancelTagMarkerBtn.hidden = YES;
    confirmTagMarkerBtn.hidden = YES;
    
    [self showTagTool];
    TCEND
}

-(IBAction)onClickOfCancelTagMarker:(id)sender {
    TCSTART
    //[moviePlayerController play];
    //    playPauseBtn.tag = 0;
    //    [self onClickOfPlayPauseBtn];
    
    [self removeTagMarker];
    TCEND
}

#pragma mark TaggedUserDetailsView related
- (void)setTaggedUserDetailsBySelectedTagToTaggedUserDetailsView:(Tag *)tag  {
    TCSTART
    if ([taggedUserDetailsView isHidden]) {
        
        //Pausing video playertagma
        playPauseBtn.tag = 1;
        [self onClickOfPlayPauseBtn];
        [self hidePlayerControlles];
        [self hidePlayerSettingsView];
        
        taggedUserDetailsView.hidden = NO;
        pageLikeBtn.hidden = YES;
        likePageWebviewCloseBtn.hidden = YES;
        likePageWebview.hidden = YES;
        fbPageCommentBtn.hidden = YES;
        userPic.hidden = YES;
        userName.hidden = YES;
        onlineDotImgView.hidden = YES;
        onlineLbl.hidden = YES;
        addFriendBtn.hidden = YES;
        birthDayMsgBtn.hidden = YES;
        shareVideoBtn.hidden = YES;
        socialMessageBtn.hidden = YES;
        customMessageView.hidden = YES;
//        updateStatusBtn.hidden = YES;
        aboutFriendTableView.hidden = YES;
        aboutFriendTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        aboutFriendTableView.separatorColor = [appDelegate colorWithHexString:@"11a3e7"];
        if ([aboutFriendTableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [aboutFriendTableView setSeparatorInset:UIEdgeInsetsZero];
        }
        
        background.backgroundColor = [appDelegate colorWithHexString:@"e7e7e7"];
        taggedUserDetailsView.backgroundColor = [UIColor clearColor];
        if (appDelegate.window.frame.size.height <= 480) {
            taggedUserDetailsView.frame = CGRectMake(0, 0, 480, 320);
        }
        
        [self.view addSubview:taggedUserDetailsView];
        
        //Table Headerview
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, aboutFriendTableView.frame.size.width, 40)];
        tableHeaderView.backgroundColor = [UIColor lightGrayColor];
        
        UILabel *aboutLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, tableHeaderView.frame.size.width - 10, tableHeaderView.frame.size.height - 10)];
        aboutLabel.textAlignment = UITextAlignmentLeft;
        aboutLabel.text = @"About";
        aboutLabel.backgroundColor = [UIColor clearColor];
        aboutLabel.textColor = [UIColor darkGrayColor];
        aboutLabel.font = [UIFont fontWithName:descriptionTextFontName size:18];
        [tableHeaderView addSubview:aboutLabel];
        aboutFriendTableView.tableHeaderView = tableHeaderView;
        
        [appDelegate setMaskTo:background byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight withRadii:CGSizeMake(8.0, 8.0)];
        userPic.layer.cornerRadius = 30;
        userPic.layer.borderWidth = 1.5f;
        userPic.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
        userPic.layer.masksToBounds = YES;
        
        detailsViewBannerImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@Banner",taggedUserType]];
        
        if ([taggedUserType caseInsensitiveCompare:@"FB"] == NSOrderedSame) {
            taggedFBId = tag.fbId;
            
            if (!FBSession.activeSession.isOpen) {
                
                [FBSession openActiveSessionWithReadPermissions:appDelegate.facebookReadPermissions
                                                   allowLoginUI:YES
                                              completionHandler:^(FBSession *session,
                                                                  FBSessionState state,
                                                                  NSError *error) {
                                                  if (error) {
                                                      [ShowAlert showError:@"Authentication failed, please try again"];
                                                  } else if (session.isOpen) {
                                                      [self getFBUserInfoWithUserId:tag.fbId];
                                                  }
                                              }];
                return;
            } else {
                [self getFBUserInfoWithUserId:tag.fbId];
            }
            
        } else if ([taggedUserType caseInsensitiveCompare:@"Twitter"] == NSOrderedSame) {
            taggedTWId = tag.twId;
            appDelegate.twitterEngine.delegate = (id)self;
            if(!appDelegate.twitterEngine) {
                [appDelegate initializeTwitterEngineWithDelegate:self];
            }
            [appDelegate.twitterEngine loadAccessToken];
            if(![appDelegate.twitterEngine isAuthorized]) {
                [appDelegate authenticateTwitterAccountWithDelegate:self andPresentFromVC:self];
            } else {
                [self getTwitterUserProfileByUserId:tag.twId];
            }
        } else {
            taggedGPlusId = tag.gPlusId;
            if ([[GPPSignIn sharedInstance] authentication]) {
                [self getGPlusUserInfoWithUserId:tag.gPlusId];
            } else {
                GPPSignIn *signIn = [GPPSignIn sharedInstance];
                signIn.clientID = kGooglePlusClientId;
                signIn.shouldFetchGoogleUserEmail = YES;
                signIn.shouldFetchGoogleUserID = YES;
                [signIn setScopes:[NSArray arrayWithObjects: @"https://www.googleapis.com/auth/plus.login", @"https://www.googleapis.com/auth/userinfo.email", @"https://www.googleapis.com/auth/plus.me", nil]];
                signIn.delegate = self;
                [signIn authenticate];
            }
        }
    }
    TCEND
}

#pragma mark scenario types
/** Scenario : 1 -------- Logged in User and tagged User are Same
 Scenario : 2 -------- Logged in User and Tagged user are connected on the social media
 Scenario : 3 -------- Logged in User and Tagged user are not connected
 */
- (void)allSocialUserInfoScreenButtonNames:(NSString *)type andScenario:(int)scenariotype page:(BOOL)isFbpage {
    TCSTART
    userPic.hidden = NO;
    userName.hidden = NO;
    pageLikeBtn.hidden = YES;
    fbPageCommentBtn.hidden = YES;
    socailTaggedUserScenarioType = scenariotype;
//    updateStatusBtn.hidden = YES;
    aboutFriendTableView.hidden = NO;
    userInfoBgView.frame = CGRectMake(detailsViewBannerImgView.frame.origin.x + 1, userInfoBgView.frame.origin.y, userInfoBgView.frame.size.width, userInfoBgView.frame.size.height);
    if (isFbpage) {
        [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/me/likes/%@",[taggedUserDetialsDict objectForKey:@"id"]] parameters:nil HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
            [appDelegate hideNetworkIndicator];
            [appDelegate removeNetworkIndicatorInView:appDelegate.window];
            if (error) {
                NSLog(@"error :%@",error);
            } else {
                NSLog(@"Result :%@",result);
                if ([self isNotNull:result] && [self isNotNull:[result objectForKey:@"data"]] && [[result objectForKey:@"data"] count] > 0) {
                    pageLikeBtn.hidden = YES;
                } else {
                    pageLikeBtn.hidden = NO;
                }
            }
        }];

        fbPageCommentBtn.hidden = NO;
        userInfoBgView.frame = CGRectMake((taggedUserDetailsView.frame.size.width - 179)/2, userInfoBgView.frame.origin.y, userInfoBgView.frame.size.width, userInfoBgView.frame.size.height);
        aboutFriendTableView.hidden = YES;
        socialMessageBtn.hidden = YES;
        shareVideoBtn.hidden = YES;
        onlineLbl.hidden = YES;
        onlineDotImgView.hidden = YES;
        
    } else {
        if (scenariotype == 1) {
            userInfoBgView.frame = CGRectMake((taggedUserDetailsView.frame.size.width - 179)/2, userInfoBgView.frame.origin.y, userInfoBgView.frame.size.width, userInfoBgView.frame.size.height);
            aboutFriendTableView.hidden = YES;
            socialMessageBtn.hidden = NO;
            shareVideoBtn.hidden = NO;
            onlineLbl.hidden = YES;
            onlineDotImgView.hidden = YES;
            if ([type caseInsensitiveCompare:@"FB"] == NSOrderedSame) {
                [socialMessageBtn setTitle:@"Update status" forState:UIControlStateNormal];
                //            updateStatusBtn.hidden = NO;
            } else if ([type caseInsensitiveCompare:@"Twitter"] == NSOrderedSame) {
                [socialMessageBtn setTitle:@"Tweet" forState:UIControlStateNormal];
            } else {
                [socialMessageBtn setTitle:@"Share an update" forState:UIControlStateNormal];
            }
        } else if (scenariotype == 2) {
            socialMessageBtn.hidden = NO;
            addFriendBtn.hidden = YES;
            
            if ([type caseInsensitiveCompare:@"FB"] == NSOrderedSame) {
                [socialMessageBtn setTitle:@"Write on wall" forState:UIControlStateNormal];
            } else if ([type caseInsensitiveCompare:@"Twitter"] == NSOrderedSame) {
                [socialMessageBtn setTitle:@"Tweet" forState:UIControlStateNormal];
            } else {
                [socialMessageBtn setTitle:@"Comment" forState:UIControlStateNormal];
            }
            
            if ([self isNotNull:[taggedUserDetialsDict objectForKey:@"online_presence"]]) {
                onlineLbl.hidden = NO;
                onlineDotImgView.hidden = NO;
                if ([[taggedUserDetialsDict objectForKey:@"online_presence"] rangeOfString:@"idle" options:NSCaseInsensitiveSearch].location != NSNotFound || [[taggedUserDetialsDict objectForKey:@"online_presence"] rangeOfString:@"active" options:NSCaseInsensitiveSearch].location != NSNotFound || [[taggedUserDetialsDict objectForKey:@"online_presence"] rangeOfString:@"online" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    onlineLbl.text = @"online";
                    [onlineDotImgView setImage:[UIImage imageNamed:@"online"]];
                } else {
                    onlineLbl.text = @"offline";
                    [onlineDotImgView setImage:[UIImage imageNamed:@"offline"]];
                }
            }
            
            if ([self isNotNull:[taggedUserDetialsDict objectForKey:@"birthday"]]) {
                if ([type caseInsensitiveCompare:@"FB"] == NSOrderedSame) {
                    if ([appDelegate isFacebookBirthDateMathesToday:[taggedUserDetialsDict objectForKey:@"birthday"]]) {
                        birthDayMsgBtn.hidden = NO;
                    }
                } else {
                    if ([appDelegate isGooglePlusBirthDateMathesToday:[taggedUserDetialsDict objectForKey:@"birthday"]]) {
                        birthDayMsgBtn.hidden = NO;
                    }
                }
            }
        } else {
            addFriendBtn.hidden = NO;
            if ([type caseInsensitiveCompare:@"FB"] == NSOrderedSame) {
                [addFriendBtn setTitle:@"Add friend" forState:UIControlStateNormal];
            } else if ([type caseInsensitiveCompare:@"Twitter"] == NSOrderedSame) {
                [addFriendBtn setTitle:@"Follow" forState:UIControlStateNormal];
            } else {
                [addFriendBtn setTitle:@"Add friend" forState:UIControlStateNormal];
                addFriendBtn.hidden = YES;
            }
        }
        
        [aboutFriendTableView reloadData];
    }
    
    
    TCEND
}

#pragma mark Twiiter Authentication delegate methods
- (void)storeAccessToken:(NSString *)body {
    TCSTART
    //NSLog(@"Got tw oauth response %@",body);
    [[NSUserDefaults standardUserDefaults]setObject:body forKey:@"SavedAccessHTTPBody"];
    if ([self isNull:appDelegate.loggedInUser.socialContactsDictionary]) {
        appDelegate.loggedInUser.socialContactsDictionary = [[NSMutableDictionary alloc] init];
    }
    [appDelegate.loggedInUser.socialContactsDictionary setObject:appDelegate.twitterEngine.loggedInUsername?:@"" forKey:@"TW"];
    if (appDelegate.twitterEngine.loggedInUsername.length > 0) {
        [self getTwitterUserProfileByUserId:taggedTWId];
    }
    TCEND
}

-(NSString *)loadAccessToken {
    TCSTART
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
    TCEND
}

#pragma mark GooglePlus Delegate method
- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    if (error) {
        [ShowAlert showError:@"Authentication failed, please try again"];
    } else {
        //NSLog(@"GPlus SignIn Success");
        [self getGPlusUserInfoWithUserId:taggedGPlusId];
    }
}

#pragma mark TagMarkerView Delegate methods
- (IBAction)onClickOfPageLikeBtn {
//    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//                            @"https://www.facebook.com/pages/Test/1422018814731517", @"object",
//                            nil
//                            ];
//    /* make the API call */
//    [FBRequestConnection startWithGraphPath:@"/me/og.likes"
//                                 parameters:params
//                                 HTTPMethod:@"POST"
//                          completionHandler:^(
//                                              FBRequestConnection *connection,
//                                              id result,
//                                              NSError *error
//                                              ) {
//                              if (error) {
//                                  NSLog(@"Error:%@",error);
//                              } else {
//                                  NSLog(@"Result :%@",result);
//                              }
//                          }];
    TCSTART
    likePageWebviewCloseBtn.hidden = NO;
    likePageWebview.hidden = NO;
    NSString *likeButtonIframe = [NSString stringWithFormat:@"<iframe src=\"http://www.facebook.com/plugins/likebox.php?id=%@&amp;width=179&amp;connections=0&amp;stream=false&amp;header=false&amp;height=198\" scrolling=\"yes\" frameborder=\"0\" style=\"border:none; overflow:hidden; width:179px; height:198px;\" allowTransparency=\"true\"></iframe>",[taggedUserDetialsDict objectForKey:@"id"]];
    NSString *likeButtonHtml = [NSString stringWithFormat:@"<HTML><BODY>%@</BODY></HTML>", likeButtonIframe];
    [likePageWebview loadHTMLString:likeButtonHtml baseURL:[NSURL URLWithString:@""]];
    TCEND
}

- (IBAction)onClickOflikePageWebviewCloseBtn {
    likePageWebview.hidden = YES;
    likePageWebviewCloseBtn.hidden = YES;
    [likePageWebview endEditing:YES];
    [likePageWebview stopLoading];
    [self allSocialUserInfoScreenButtonNames:taggedUserType andScenario:1 page:YES];
}

- (IBAction)onclickOfFacebookPagecommentBtn {
    TCSTART
    [self openTagLinkStr:[NSString stringWithFormat:@"https://www.facebook.com/pages/%@/%@",[taggedUserDetialsDict objectForKey:@"Name"],[taggedUserDetialsDict objectForKey:@"id"]] andSender:nil];
    webViewShareBtn.hidden = YES;
    
//    likePageWebview.hidden = NO;
//    likePageWebviewCloseBtn.hidden = NO;
//    [likePageWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.facebook.com/pages/%@/%@",[taggedUserDetialsDict objectForKey:@"Name"],[taggedUserDetialsDict objectForKey:@"id"]]]]];
//    customMessageView.hidden = NO;
//    customMessageView.backgroundColor = [appDelegate colorWithHexString:@"e7e7e7"];
//    messageTextView.text = @"";
//    [messageTextView becomeFirstResponder];
    TCEND
}
- (void)sendCommentToFaceBookPage:(NSString *)text {
    TCSTART
    
    [appDelegate performPublishAction:^ {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                text, @"message",
                                nil
                                ];
        /* make the API call */
        [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@/comments",[taggedUserDetialsDict objectForKey:@"id"]]
                                     parameters:params
                                     HTTPMethod:@"POST"
                              completionHandler:^(FBRequestConnection *connection,id result, NSError *error) {
                                  if (error) {
                                      [ShowAlert showAlert:@"Something went wrong, please try again"];
                                  } else {
                                      NSLog (@"commented successfully");
                                  }
                              }];
    }];
    
    
    TCEND
}
- (IBAction)onclickOfAddFriendbutton:(id)sender {
    TCSTART
    if ([[taggedUserDetialsDict objectForKey:@"type"] isEqualToString:@"Twitter"]) {
        [self followTwitterUserWithUserId:[taggedUserDetialsDict objectForKey:@"id"]];
    } if ([[taggedUserDetialsDict objectForKey:@"type"] isEqualToString:@"FB"]) {
        [self addFriendRequestToFBUserByUserId:[taggedUserDetialsDict objectForKey:@"id"]];
    } else {
        
    }
    TCEND
}

- (IBAction)onclickOfDetailsViewCloseBtn:(id)sender {
    TCSTART
    taggedUserDetailsView.hidden = YES;
    [taggedUserDetialsDict removeAllObjects];
    taggedUserType = @"";
    taggedFBId = @"";
    taggedTWId = @"";
    taggedGPlusId = @"";
    
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    TCEND
}

- (IBAction)sendMessageButton:(id)sender {
    TCSTART
    if ([[taggedUserDetialsDict objectForKey:@"type"] isEqualToString:@"Twitter"]) {
        customMessageView.hidden = NO;
        customMessageView.backgroundColor = [appDelegate colorWithHexString:@"e7e7e7"];
        messageTextView.text = @"";
        [messageTextView becomeFirstResponder];
    } else if ([[taggedUserDetialsDict objectForKey:@"type"] isEqualToString:@"FB"]) {
        [self postMessageToFBFriend:[taggedUserDetialsDict objectForKey:@"id"] andMessage:@"Record, Tag - self,people, place, product inside your videos and Share" andLink:@"www.wootag.com/invite.html" andImage:@"http://wootag.com/invite.jpg"];
    } else {
        [self sendDirectMessageToGPlusUserWithUserId:[taggedUserDetialsDict objectForKey:@"id"] andDescriptionText:@"Record, Tag - self,people, place, product inside your videos and Share" andURLToshare:@"www.wootag.com/invite.html"];
    }
    
    TCEND
}

- (IBAction)onclickOfSocialMessgeButton:(id)sender {
    TCSTART

    if (messageTextView.text.length > 0) {
        messageTextView.text = [appDelegate removingLastSpecialCharecter:messageTextView.text];
    }
    if (messageTextView.text.length > 0) {
        customMessageView.hidden = YES;
        if ([[taggedUserDetialsDict objectForKey:@"type"] isEqualToString:@"FB"]) {
            [self sendCommentToFaceBookPage:messageTextView.text];
        } else {
            [self sendDirectMessageToTheTwitterFriendByUserId:[taggedUserDetialsDict objectForKey:@"id"] andText:messageTextView.text];
        }
    } else {
        [ShowAlert showError:@"Please enter message"];
    }
    
    TCEND
}

- (IBAction)onClickOfBirthDayMessageButton:(id)sender {
    TCSTART
    NSString *birthDayMessage = @"Happy birthday \n Hope your birthday blossoms into lots of dreams come true!";
    if ([[taggedUserDetialsDict objectForKey:@"type"] isEqualToString:@"Twitter"]) {
        [self sendDirectMessageToTheTwitterFriendByUserId:[taggedUserDetialsDict objectForKey:@"id"] andText:birthDayMessage];
    } else if ([[taggedUserDetialsDict objectForKey:@"type"] isEqualToString:@"FB"]) {
        [self postMessageToFBFriend:[taggedUserDetialsDict objectForKey:@"id"] andMessage:birthDayMessage andLink:nil andImage:nil];
    } else {
        [self sendDirectMessageToGPlusUserWithUserId:[taggedUserDetialsDict objectForKey:@"id"] andDescriptionText:birthDayMessage andURLToshare:nil];
    }
    TCEND
}

- (IBAction)onClickOfShareVideoButton:(id)sender {
    TCSTART
    if ([[taggedUserDetialsDict objectForKey:@"type"] isEqualToString:@"Twitter"]) {
        //Twitter handle
        NSString *string = [NSString stringWithFormat:@"%@\n%@\n",video.latestTagExpression?:video.title,video.shareUrl];
        [appDelegate PostToTwitterWithMsg:string toUser:[taggedUserDetialsDict objectForKey:@"Twitter handle"] withImageUrl:video.videoThumbPath andVideoId:video.videoId];
        
    } else if ([[taggedUserDetialsDict objectForKey:@"type"] isEqualToString:@"FB"]) {
        if (FBSession.activeSession.isOpen) {
            [appDelegate performPublishAction:^ {
                [appDelegate postToFacebookUserWallWithOutDialog:video andToId:[taggedUserDetialsDict objectForKey:@"id"]];
            }];
        } else {
            [appDelegate postToFacebookUserWallWithOutDialog:video andToId:[taggedUserDetialsDict objectForKey:@"id"]];
        }
        
    } else {
        [appDelegate shareToGooglePlusUserWithUserId:[NSArray arrayWithObjects:[taggedUserDetialsDict objectForKey:@"id"], nil] andVideo:video];
    }
    TCEND
}

#pragma mark Twitter Related methods
- (void)onClickOfTagMarkerViewTwitterBtn:(id)sender {
    TCSTART
    CustomButton *twbtn = (CustomButton *)sender;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:twbtn.tagId],@"tagid",[NSNumber numberWithInt:twbtn.clientTagId],@"clientTagId", nil];
    Tag *tag = [[DataManager sharedDataManager] getTagByTagIdORClientTagId:dict];
    
    if ([self isNotNull:tag.twId]) {
        taggedUserType = @"Twitter";
        [self setTaggedUserDetailsBySelectedTagToTaggedUserDetailsView:tag];
    }
    
    if (tag.tagId.intValue > 0) {
//        [appDelegate makeRequestForAnalyticsOfVideo:video.videoId analyticsTagClicksOrShareId:TwitterClicksorMailShare isForShare:NO shareCount:0];
        [appDelegate makeRequestForAnalyticsOfVideo:video.videoId analyticsTagClicksOrShareId:TwitterClicksorMailShare analyticsTagInteractions:FB socialPlatform:FB isForShare:NO isReqForInteractions:NO shareCount:0];
    }
    
    TCEND
}

- (void) followTwitterUserWithUserId:(NSString *)userId {
    TCSTART
    dispatch_async(GCDBackgroundThread, ^{
        @autoreleasepool {
            NSError *returnCode = [appDelegate.twitterEngine followUser:userId isID:YES];
            [appDelegate showActivityIndicatorInView:appDelegate.window andText:@"Loading"];
            [appDelegate showNetworkIndicator];
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    [appDelegate hideNetworkIndicator];
                    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
                    if (!returnCode) {
                        [appDelegate makeRequestForAnalyticsOfVideo:video.videoId analyticsTagClicksOrShareId:VideoViewsOrFBShare analyticsTagInteractions:TWorFollow socialPlatform:TWorFollow isForShare:NO isReqForInteractions:YES shareCount:1];
                        [self allSocialUserInfoScreenButtonNames:taggedUserType andScenario:2 page:NO];
                    } else {
                        [ShowAlert showAlert:@"Something went wrong, please try again"];
                    }
                }
            });
        }
    });
    TCEND
}

- (void) getTwitterUserProfileByUserId:(NSString *)userId {
    TCSTART
    [appDelegate showActivityIndicatorInView:appDelegate.window andText:@"Loading"];
    [appDelegate showNetworkIndicator];
    NSDictionary *dict = [appDelegate.twitterEngine getUserProfileForUserId:userId];
    if ([self isNotNull:dict] && [dict isKindOfClass:[NSDictionary class]]) {
        [taggedUserDetialsDict setObject:[dict objectForKey:@"profile_image_url_https"]?:@"" forKey:@"Profileimage"];
        if ([[dict objectForKey:@"followers_count"] isKindOfClass:[NSString class]]) {
            [taggedUserDetialsDict setObject:[dict objectForKey:@"followers_count"] forKey:@"followers_count"];
        } else {
            [taggedUserDetialsDict setObject:[[dict objectForKey:@"followers_count"] stringValue] forKey:@"followers_count"];
        }
        
        [taggedUserDetialsDict setObject:[dict objectForKey:@"url"]?:@"" forKey:@"Website Url"];
        [taggedUserDetialsDict setObject:[dict objectForKey:@"screen_name"]?:@"" forKey:@"Twitter handle"];
        [taggedUserDetialsDict setObject:[dict objectForKey:@"name"]?:@"" forKey:@"Name"];
        [taggedUserDetialsDict setObject:[dict objectForKey:@"location"]?:@"" forKey:@"Lives In"];
        if ([[dict objectForKey:@"id"] isKindOfClass:[NSString class]]) {
            [taggedUserDetialsDict setObject:[dict objectForKey:@"id"]?:@"" forKey:@"id"];
        } else {
            [taggedUserDetialsDict setObject:[NSString stringWithFormat:@"%lld",[[dict objectForKey:@"id"] longLongValue]]?:@"" forKey:@"id"];
        }
        
        [taggedUserDetialsDict setObject:[dict objectForKey:@"description"]?:@"" forKey:@"Description"];
        [taggedUserDetialsDict setObject:@"Twitter" forKey:@"type"];
        
        if ([self isNotNull:[dict objectForKey:@"status"]]) {
            NSDictionary *statusDcit = [dict objectForKey:@"status"];
            [taggedUserDetialsDict setObject:[statusDcit objectForKey:@"text"]?:@"" forKey:@"status"];
            [taggedUserDetialsDict setObject:[statusDcit objectForKey:@"created_at"]?:@"" forKey:@"lastupdate"];
        }
    }
    //NSLog(@"UserProfile:%@",taggedUserDetialsDict);
    userName.text = [taggedUserDetialsDict objectForKey:@"Name"];
    if ([self isNotNull:[taggedUserDetialsDict objectForKey:@"Profileimage"]]) {
        [userPic setImageWithURL:[NSURL URLWithString:[taggedUserDetialsDict objectForKey:@"Profileimage"]] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached];
    } else {
        userPic.image = [UIImage imageNamed:@"OwnerPic"];
    }
    
    if ([self isThisUserFriendForMeByTwitterUserId:[taggedUserDetialsDict objectForKey:@"id"]] || [appDelegate.twitterEngine.loggedInID isEqualToString:[taggedUserDetialsDict objectForKey:@"id"]]) {
        [self allSocialUserInfoScreenButtonNames:taggedUserType andScenario:([appDelegate.twitterEngine.loggedInID isEqualToString:[taggedUserDetialsDict objectForKey:@"id"]]?1:2) page:NO];
    } else {
        [self allSocialUserInfoScreenButtonNames:taggedUserType andScenario:3 page:NO];
    }
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    [appDelegate hideNetworkIndicator];
    
    TCEND
}

- (BOOL)isThisUserFriendForMeByTwitterUserId:(NSString *)userId {
    TCSTART
    BOOL isFriend = false;
    
    id twitterData = [appDelegate.twitterEngine getFriendsIDs];
    if (twitterData != nil && [twitterData isKindOfClass:[NSDictionary class]]) {
        if ([self isNotNull:[twitterData objectForKey:@"ids"]]) {
            for (NSNumber *friendId in [twitterData objectForKey:@"ids"]) {
                if ([friendId longLongValue] == [userId longLongValue]) {
                    isFriend = true;
                    return isFriend;
                    //                    [NSNumber numberWithLong:[[user objectForKey:@"id"] longValue]]
                } else {
                    isFriend = false;
                }
            }
            return isFriend;
        }
    }
    TCEND
}

- (void)sendDirectMessageToTheTwitterFriendByUserId:(NSString *)userId andText:(NSString *)text {
    TCSTART
    dispatch_async(GCDBackgroundThread, ^{
        @autoreleasepool {
            if ([self isNotNull:userId]) {
                NSDictionary *dict = [appDelegate.twitterEngine getUserProfileForUserId:userId];
                if ([self isNotNull:dict] && [self isNotNull:[dict objectForKey:@"screen_name"]]) {
                    [appDelegate showNetworkIndicator];
                    [appDelegate showActivityIndicatorInView:appDelegate.window andText:@"Posting tweet"];
                    NSError *returnCode = [appDelegate.twitterEngine postTweet:[NSString stringWithFormat:@"@%@ %@",[dict objectForKey:@"screen_name"], text]];
                    
                    dispatch_sync(GCDMainThread, ^{
                        @autoreleasepool {
                            [appDelegate hideNetworkIndicator];
                            [appDelegate removeNetworkIndicatorInView:appDelegate.window];
                            if (!returnCode) {
                                NSLog (@"Posted to twitter");
                                [appDelegate makeRequestForAnalyticsOfVideo:video.videoId analyticsTagClicksOrShareId:VideoViewsOrFBShare analyticsTagInteractions:GPlusorWriteOnWall socialPlatform:TWorFollow isForShare:NO isReqForInteractions:YES shareCount:1];
                            } else {
                                NSLog(@"Failed to post to twitter");
                            }
                        }
                    });
                }
            }
        }
    });
    
    TCEND
}

#pragma mark Facebook Related methods
- (void)onClickOfTagMarkerViewFacebookBtn:(id)sender {
    TCSTART
    CustomButton *FBbtn = (CustomButton *)sender;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:FBbtn.tagId],@"tagid",[NSNumber numberWithInt:FBbtn.clientTagId],@"clientTagId", nil];
    Tag *tag = [[DataManager sharedDataManager] getTagByTagIdORClientTagId:dict];
    if ([self isNotNull:tag.fbId]) {
        taggedUserType = @"FB";
        [self setTaggedUserDetailsBySelectedTagToTaggedUserDetailsView:tag];
    }
    
    if (tag.tagId.intValue > 0) {
        [appDelegate makeRequestForAnalyticsOfVideo:video.videoId analyticsTagClicksOrShareId:FacebookClicksorTwitterShare analyticsTagInteractions:FB socialPlatform:FB isForShare:NO isReqForInteractions:NO shareCount:0];
    }
    TCEND
}
- (void)getFBUserInfoWithUserId:(NSString *)userId {
    TCSTART
    [appDelegate showActivityIndicatorInView:appDelegate.window andText:@"Loading"];
    [appDelegate showNetworkIndicator];
    
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@",userId] parameters:nil HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
        if (error) {
            [appDelegate hideNetworkIndicator];
            [appDelegate removeNetworkIndicatorInView:appDelegate.window];
            NSLog(@"error :%@",error);
        } else {
            NSLog(@"Result :%@",result);
            if ([self isNotNull:result] && ([self isNotNull:[result objectForKey:@"is_community_page"]] || [self isNotNull:[result objectForKey:@"is_published"]])) {
                // Facebook page
                [taggedUserDetialsDict setObject:[result objectForKey:@"name"]?:@"" forKey:@"Name"];
                [taggedUserDetialsDict setObject:[result objectForKey:@"id"]?:@"" forKey:@"id"];
                [taggedUserDetialsDict setObject:@"FB" forKey:@"type"];
                [taggedUserDetialsDict setObject:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",[taggedUserDetialsDict objectForKey:@"id"]] forKey:@"Profileimage"];
                //NSLog(@"UserProfile:%@",taggedUserDetialsDict);
                userName.text = [taggedUserDetialsDict objectForKey:@"Name"];
                if ([self isNotNull:[taggedUserDetialsDict objectForKey:@"Profileimage"]]) {
                    [userPic setImageWithURL:[NSURL URLWithString:[taggedUserDetialsDict objectForKey:@"Profileimage"]] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached];
                } else {
                    userPic.image = [UIImage imageNamed:@"OwnerPic"];
                }
                [appDelegate hideNetworkIndicator];
                [appDelegate removeNetworkIndicatorInView:appDelegate.window];
                [self onclickOfFacebookPagecommentBtn];
                
//                [self allSocialUserInfoScreenButtonNames:taggedUserType andScenario:1 page:YES];
            } else {
                // User
                [self fbUserInfoWithUserId:userId];
            }
        }
    }];
    TCEND
}
- (void)fbUserInfoWithUserId:(NSString *)userId {
    TCSTART

    NSString *query = [NSString stringWithFormat:@"SELECT online_presence, status, birthday FROM user WHERE uid = %@",userId];
    // Set up the query parameter
    NSDictionary *queryParam = @{ @"q": query };
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              if (error) {
                                  NSLog(@"Error: %@", [error localizedDescription]);
                              } else {
                                  NSArray *userInfoArray = [result objectForKey:@"data"];
                                  NSLog(@"result:%@ \n userinfo array: %@",result,userInfoArray);
                                  if (userInfoArray.count > 0) {
                                      NSDictionary *dict = [userInfoArray objectAtIndex:0];
                                      if ([self isNotNull:[dict objectForKey:@"birthday"]]) {
                                          [taggedUserDetialsDict setObject:[dict objectForKey:@"birthday"]?:@"" forKey:@"birthday"];
                                      }
                                      
                                      if ([self isNotNull:[dict objectForKey:@"online_presence"]]) {
                                          [taggedUserDetialsDict setObject:[dict objectForKey:@"online_presence"]?:@"" forKey:@"online_presence"];
                                      }
                                      
                                      if ([self isNotNull:[dict objectForKey:@"status"]]) {
                                          [taggedUserDetialsDict setObject:[[dict objectForKey:@"status"] objectForKey:@"message"]?:@"" forKey:@"status"];
                                          [taggedUserDetialsDict setObject:[[dict objectForKey:@"status"] objectForKey:@"time"]?:@"" forKey:@"lastupdate"];
                                      }
                                  }
                              }
                              
                              [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@",userId] parameters:[NSDictionary dictionaryWithObject:@"education,picture,location,work,name" forKey:@"fields"] HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
                                  if (error) {
                                      GTMLoggerError(@"Error: %@",error);
                                      [appDelegate hideNetworkIndicator];
                                      [appDelegate removeNetworkIndicatorInView:appDelegate.window];
                                  } else {
                                      NSLog(@"result:%@",result);
                                      if ([self isNotNull:result] && [result isKindOfClass:[NSDictionary class]]) {
                                          ////studied at
                                          NSArray *educationArray = [result objectForKey:@"education"];
                                          if ([self isNotNull:educationArray] && educationArray.count > 0) {
                                              NSDictionary *dict = [[educationArray objectAtIndex:0] objectForKey:@"school"];
                                              [taggedUserDetialsDict setObject:[dict objectForKey:@"name"]?:@"" forKey:@"Studied at"];
                                          }
                                          
                                          //work
                                          NSArray *workingArray = [result objectForKey:@"work"];
                                          if ([self isNotNull:workingArray] && workingArray.count > 0) {
                                              NSDictionary *dict = [[workingArray objectAtIndex:0] objectForKey:@"employer"];
                                              [taggedUserDetialsDict setObject:[dict objectForKey:@"name"]?:@"" forKey:@"Working at"];
                                          }
                                          [taggedUserDetialsDict setObject:[result objectForKey:@"name"]?:@"" forKey:@"Name"];
                                          [taggedUserDetialsDict setObject:[result objectForKey:@"id"]?:@"" forKey:@"id"];
                                          [taggedUserDetialsDict setObject:@"FB" forKey:@"type"];
                                          [taggedUserDetialsDict setObject:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",[taggedUserDetialsDict objectForKey:@"id"]] forKey:@"Profileimage"];
                                          
                                          //relationship
                                          [taggedUserDetialsDict setObject:[result objectForKey:@"relationship_status"]?:@"" forKey:@"Relationship"];
                                          
                                          //From
                                          [taggedUserDetialsDict setObject:[[result objectForKey:@"hometown"] objectForKey:@"name"]?:@"" forKey:@"From"];
                                          
                                          //current location
                                          [taggedUserDetialsDict setObject:[[result objectForKey:@"location"] objectForKey:@"name"]?:@"" forKey:@"Lives In"];
                                          
                                          //NSLog(@"UserProfile:%@",taggedUserDetialsDict);
                                          userName.text = [taggedUserDetialsDict objectForKey:@"Name"];
                                          if ([self isNotNull:[taggedUserDetialsDict objectForKey:@"Profileimage"]]) {
                                              [userPic setImageWithURL:[NSURL URLWithString:[taggedUserDetialsDict objectForKey:@"Profileimage"]] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached];
                                          } else {
                                              userPic.image = [UIImage imageNamed:@"OwnerPic"];
                                          }
                                          
                                          [FBRequestConnection startForMeWithCompletionHandler:
                                           ^(FBRequestConnection *connection, id result, NSError *error) {
                                               if ([self isNotNull:appDelegate.loggedInUser]) {
                                                   if ([self isNull:appDelegate.loggedInUser.socialContactsDictionary]) {
                                                       appDelegate.loggedInUser.socialContactsDictionary = [[NSMutableDictionary alloc] init];
                                                   }
                                                   [appDelegate.loggedInUser.socialContactsDictionary setObject:[result objectForKey:@"name"]?:@"" forKey:@"FB"];
                                               }
                                               
                                               if ([[result objectForKey:@"id"] isEqualToString:[taggedUserDetialsDict objectForKey:@"id"]]) {
                                                   [appDelegate hideNetworkIndicator];
                                                   [appDelegate removeNetworkIndicatorInView:appDelegate.window];
                                                   [self allSocialUserInfoScreenButtonNames:taggedUserType andScenario:1 page:NO];
                                               } else {
                                                   [self checkThisUserFriendForMeByFBUserId:[taggedUserDetialsDict objectForKey:@"id"]];
                                               }
                                           }];
//                                          [aboutFriendTableView reloadData];
                                      }
                                  }
                              }];
                          }];
    
    
    
    TCEND
}

- (void)checkThisUserFriendForMeByFBUserId:(NSString *)userId {
    TCSTART
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/me/friends/%@",userId]
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error
                                              ) {
                              [appDelegate hideNetworkIndicator];
                              [appDelegate removeNetworkIndicatorInView:appDelegate.window];
                              if (error) {
                                  [self allSocialUserInfoScreenButtonNames:taggedUserType andScenario:3 page:NO];
                              } else {
                                  if ([self isNotNull:[result objectForKey:@"data"]] && [[result objectForKey:@"data"] count] > 0) {
                                      [self allSocialUserInfoScreenButtonNames:taggedUserType andScenario:2 page:NO];
                                  } else {
                                      [self allSocialUserInfoScreenButtonNames:taggedUserType andScenario:3 page:NO];
                                  }
                              }
                          }];
    
//    [FBRequestConnection startWithGraphPath:@"me/friends" completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
//        if (error) {
//            [appDelegate hideNetworkIndicator];
//            [appDelegate removeNetworkIndicatorInView:appDelegate.window];
//            GTMLoggerError(@"error:%@",error);
//        } else {
//            //NSLog(@"Result:%@",result);
//            [self FBFriendsArray:[result objectForKey:@"data"] andUserId:userId];
//        }
//    }];
    TCEND
}

- (void)FBFriendsArray:(NSArray *)userArray andUserId:(NSString *)userId {
    TCSTART
    BOOL isFriend = false;
    for (NSDictionary *dict in userArray) {
        if ([[dict objectForKey:@"id"] isEqualToString:userId]) {
            isFriend = true;
            break;
        } else {
            isFriend = false;
        }
    }
    if (isFriend) {
        [self allSocialUserInfoScreenButtonNames:taggedUserType andScenario:2 page:NO];
    } else {
        [self allSocialUserInfoScreenButtonNames:taggedUserType andScenario:3 page:NO];
    }
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    TCEND
}

//- (IBAction)oncLickOfFacebookFollowBtn:(id)sender {
//    TCSTART
//    if ([[taggedUserDetialsDict objectForKey:@"type"] isEqualToString:@"FB"]) {
//        NSMutableDictionary<FBGraphObject> *action = [FBGraphObject graphObject];
//        action[@"profile"] = [NSString stringWithFormat:@"http://samples.ogp.me/%@",[taggedUserDetialsDict objectForKey:@"id"]];
////        https://graph.facebook.com/FOLLOWER_UID/og.follows
//        [FBRequestConnection startForPostWithGraphPath:[NSString stringWithFormat:@"%@/og.follows",[taggedUserDetialsDict objectForKey:@"id"]]
//                                           graphObject:action
//                                     completionHandler:^(FBRequestConnection *connection,
//                                                         id result,
//                                                         NSError *error) {
//                                         if (!error) {
//                                             [ShowAlert showAlert:@"You successfully followed"];
//                                         } else {
//                                             [ShowAlert showError:[error localizedDescription]];
//                                         }
//                                     }];
//        }
//
//    TCEND
//}

- (void)addFriendRequestToFBUserByUserId:(NSString *)userId {
    TCSTART
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:userId,@"to", nil];
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:@"Friend Request"
                                                    title:@"Send Request"
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          //NSLog(@"Error sending request.");
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                          } else {
                                                              [appDelegate makeRequestForAnalyticsOfVideo:video.videoId analyticsTagClicksOrShareId:VideoViewsOrFBShare analyticsTagInteractions:AddFriend socialPlatform:FB isForShare:NO isReqForInteractions:YES shareCount:1];
                                                              [self allSocialUserInfoScreenButtonNames:taggedUserType andScenario:2 page:NO];
                                                          }
                                                      }}];
    TCEND
}

- (void)postMessageToFBFriend:(NSString *)fbId andMessage:(NSString *)description andLink:(NSString *)link andImage:(NSString *)imaegPath {
    TCSTART
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   fbId, @"to",description?:@"",@"description",
                                   nil];
    if ([self isNotNull:link]) {
        [params setObject:link forKey:@"link"];
    }
    if ([self isNotNull:imaegPath]) {
        [params setObject:imaegPath forKey:@"picture"];
    }
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:params
                                              handler:
     ^(FBWebDialogResult result, NSURL *resultURL, NSError *error)
     {
         if (error) {
             [ShowAlert showAlert:@"Something went wrong, please send again"];
             
         } else {
             if (result == FBWebDialogResultDialogCompleted) {
                 // Handle the send request callback
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"post_id"]) {
                     //NSLog(@"User canceled request.");
                 } else {
//                     [ShowAlert showAlert:@"Successfully sent"];
                     [appDelegate makeRequestForAnalyticsOfVideo:video.videoId analyticsTagClicksOrShareId:VideoViewsOrFBShare analyticsTagInteractions:GPlusorWriteOnWall socialPlatform:FB isForShare:NO isReqForInteractions:YES shareCount:1];
                 }
             }
         }
     }
     ];
    
    TCEND
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    TCSTART
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [[kv objectAtIndex:1]
         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
    TCEND
}

#pragma mark GooglePlus Related Method
- (void)onClickOfTagMarkerViewGPlusBtn:(id)sender {
    TCSTART
    CustomButton *GplusBtn = (CustomButton *)sender;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:GplusBtn.tagId],@"tagid",[NSNumber numberWithInt:GplusBtn.clientTagId],@"clientTagId", nil];
    Tag *tag = [[DataManager sharedDataManager] getTagByTagIdORClientTagId:dict];
    if ([self isNotNull:tag.gPlusId]) {
        taggedUserType = @"GPlus";
        [self setTaggedUserDetailsBySelectedTagToTaggedUserDetailsView:tag];
    }
    if (tag.tagId.intValue > 0) {
        [appDelegate makeRequestForAnalyticsOfVideo:video.videoId analyticsTagClicksOrShareId:GoogleClicksorGoogleShare analyticsTagInteractions:FB socialPlatform:FB isForShare:NO isReqForInteractions:NO shareCount:0];
    }
    TCEND
}

- (void)getGPlusUserInfoWithUserId:(NSString *)userId {
    TCSTART
    [appDelegate showNetworkIndicator];
    [appDelegate showActivityIndicatorInView:appDelegate.window andText:@"Loading"];
    
    GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGoogleUserID = YES;
    plusService.retryEnabled = YES;
    [plusService setAuthorizer:signIn.authentication];
    if ([self isNull:appDelegate.loggedInUser.socialContactsDictionary]) {
        appDelegate.loggedInUser.socialContactsDictionary = [[NSMutableDictionary alloc] init];
    }
    [appDelegate.loggedInUser.socialContactsDictionary setObject:signIn.authentication.userEmail?:@"" forKey:@"GPLUS"];
    
    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:userId];
    
    [plusService executeQuery:query
            completionHandler:^(GTLServiceTicket *ticket,
                                GTLPlusPerson *person,
                                NSError *error) {
                if (error) {
                    [appDelegate hideNetworkIndicator];
                    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
                    GTMLoggerError(@"Error: %@", error);
                } else {
                    NSLog(@"Person Data :%@",person.JSON);
                    [taggedUserDetialsDict setObject:person.image.url?:@"" forKey:@"Profileimage"];
                    [taggedUserDetialsDict setObject:person.displayName?:@"" forKey:@"Name"];
                    [taggedUserDetialsDict setObject:person.identifier?:@"" forKey:@"id"];
                    [taggedUserDetialsDict setObject:@"GPlus" forKey:@"type"];
                    [taggedUserDetialsDict setObject:person.currentLocation?:@"" forKey:@"Lives In"];
                    if ([self isNotNull:person.birthday]) {
                        [taggedUserDetialsDict setObject:person.birthday forKey:@"birthday"];
                    }
                    [taggedUserDetialsDict setObject:person.relationshipStatus?:@"" forKey:@"Relationship"];
                    if ([self isNotNull:person.tagline]) {
                        [taggedUserDetialsDict setObject:person.tagline forKey:@"status"];
                    }
                    if ([self isNotNull:person.placesLived] && person.placesLived.count > 0) {
                        for (GTLPlusPersonPlacesLivedItem *placeItem in person.placesLived) {
                            if ([placeItem.primary boolValue]) {
                                [taggedUserDetialsDict setObject:placeItem.value?:@"" forKey:@"From"];
                                if ([self isNull:[taggedUserDetialsDict objectForKey:@"Lives In"]]) {
                                    [taggedUserDetialsDict setObject:placeItem.value?:@"" forKey:@"Lives In"];
                                }
                                break;
                            }
                        }
                    }
                    
                    if ([self isNotNull:person.organizations] && person.organizations.count > 0) {
                        for (GTLPlusPersonOrganizationsItem *organisation in person.organizations) {
                            if ([organisation.type caseInsensitiveCompare:@"work"] == NSOrderedSame  && [self isNull:[taggedUserDetialsDict objectForKey:@"Working at"]]) {
                                [taggedUserDetialsDict setObject:organisation.name?:@"" forKey:@"Working at"];
                            } else if ([organisation.type caseInsensitiveCompare:@"School"] == NSOrderedSame && [self isNull:[taggedUserDetialsDict objectForKey:@"Studied at"]]) {
                                [taggedUserDetialsDict setObject:organisation.name?:@"" forKey:@"Studied at"];
                            }
                        }
                    }
                    //NSLog(@"UserProfile:%@",taggedUserDetialsDict);
                    userName.text = [taggedUserDetialsDict objectForKey:@"Name"];
                    if ([self isNotNull:[taggedUserDetialsDict objectForKey:@"Profileimage"]]) {
                        [userPic setImageWithURL:[NSURL URLWithString:[taggedUserDetialsDict objectForKey:@"Profileimage"]] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached];
                    } else {
                        userPic.image = [UIImage imageNamed:@"OwnerPic"];
                    }
                    [self displayFrindViewAfterConditionsChecks:plusService andTaggedUserId:userId];
                }
            }];
    
    
    TCEND
}

- (void)displayFrindViewAfterConditionsChecks:(GTLServicePlus *)plusService andTaggedUserId:(NSString *)userId {
    TCSTART
    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
    
    [plusService executeQuery:query
            completionHandler:^(GTLServiceTicket *ticket,
                                GTLPlusPerson *person,
                                NSError *error) {
                [appDelegate hideNetworkIndicator];
                [appDelegate removeNetworkIndicatorInView:appDelegate.window];
                if (error) {
                    [ShowAlert showError:[error localizedDescription]];
                } else {
                    if ([userId isEqualToString:person.identifier]) {
                        [self allSocialUserInfoScreenButtonNames:taggedUserType andScenario:1 page:NO];
                        
                    } else {
                        //                        [self checkThisUserFriendForMeByGPLusUserId:[taggedUserDetialsDict objectForKey:@"id"]];
                        [self allSocialUserInfoScreenButtonNames:taggedUserType andScenario:2 page:NO];
                    }
                    
//                    [aboutFriendTableView reloadData];
                }
            }];
    TCEND
}


- (void)checkThisUserFriendForMeByGPLusUserId:(NSString *)userId {
    TCSTART
    GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
    plusService.retryEnabled = YES;
    [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
    if ([self isNull:appDelegate.loggedInUser.socialContactsDictionary]) {
        appDelegate.loggedInUser.socialContactsDictionary = [[NSMutableDictionary alloc] init];
    }
    [appDelegate.loggedInUser.socialContactsDictionary setObject:[GPPSignIn sharedInstance].authentication.userEmail?:@"" forKey:@"GPLUS"];
    
    GTLQueryPlus *query =
    [GTLQueryPlus queryForPeopleListWithUserId:@"me"
                                    collection:kGTLPlusCollectionVisible];
    
    [plusService executeQuery:query
            completionHandler:^(GTLServiceTicket *ticket,
                                GTLPlusPeopleFeed *peopleFeed,
                                NSError *error) {
                if (error) {
                    [appDelegate hideNetworkIndicator];
                    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
                    GTMLoggerError(@"Error: %@", error);
                } else {
                    [self gplusFriendArray:peopleFeed.items andUserId:userId];
                }
            }];
    TCEND
}

- (void)gplusFriendArray:(NSArray *)userArray andUserId:(NSString *)userId {
    TCSTART
    BOOL isFriend = false;
    for (GTLPlusPerson *gPlusPersion in userArray) {
        if ([gPlusPersion.identifier isEqualToString:userId]) {
            isFriend = true;
            break;
        } else {
            isFriend = false;
        }
    }
    if (isFriend) {
        [self allSocialUserInfoScreenButtonNames:taggedUserType andScenario:2 page:NO];
    } else {
        [self allSocialUserInfoScreenButtonNames:taggedUserType andScenario:3 page:NO];
    }
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    TCEND
}

- (void)sendDirectMessageToGPlusUserWithUserId:(NSString *)userId andDescriptionText:(NSString *)descriptionText andURLToshare:(NSString *)shareURL {
    TCSTART
    [GPPShare sharedInstance].delegate = self;
    
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    
    // This line will manually fill out the title, description, and thumbnail of the
    // item you're sharing.
    
    [shareBuilder setPrefillText:descriptionText];
    
    if ([self isNotNull:shareURL]) {
        [shareBuilder setURLToShare:[NSURL URLWithString:shareURL]];
    }
    
    [shareBuilder setPreselectedPeopleIDs:[NSArray arrayWithObject:userId]];
    [appDelegate makeRequestForAnalyticsOfVideo:video.videoId analyticsTagClicksOrShareId:VideoViewsOrFBShare analyticsTagInteractions:GPlusorWriteOnWall socialPlatform:GPlusorWriteOnWall isForShare:NO isReqForInteractions:YES shareCount:1];
    [shareBuilder open];
    TCEND
}

- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation {
    return [GPPURLHandler handleURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
}

- (void)finishedSharing: (BOOL)shared {
    if (shared) {
//        [ShowAlert showAlert:@"Sent successfully"];
        
    } else {
        [ShowAlert showAlert:@"Something went wrong, please share again"];
    }
}

#pragma mark Wootag Tagged user button Clicked
- (void)onClickOfTagMarkerViewWTBtn:(id)sender {
    TCSTART
    CustomButton *wtBtn = (CustomButton *)sender;
    playPauseBtn.tag = 1;
    [self onClickOfPlayPauseBtn];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:wtBtn.tagId],@"tagid",[NSNumber numberWithInt:wtBtn.clientTagId],@"clientTagId", nil];
    Tag *tag = [[DataManager sharedDataManager] getTagByTagIdORClientTagId:dict];
    
    if (tag) {
        if (!wootagInfoVC) {
            wootagInfoVC = [[WootagInfoViewController alloc] initWithNibName:@"WootagInfoViewController" bundle:nil];
            wootagInfoVC.customMVPlayer = self;
            if ([caller isKindOfClass:[SelectCoverFrameViewController class]]) {
                wootagInfoVC.view.frame = CGRectMake(0, 0, appDelegate.window.frame.size.height, appDelegate.window.frame.size.width - 20);
            } else {
                wootagInfoVC.view.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width - 20);
            }
            [self.view addSubview:wootagInfoVC.view];
        }
        
        [wootagInfoVC updateTagDetails:tag andVideo:video];
    }
////    if (wtBtn.tag != [appDelegate.loggedInUser.userId integerValue]) {
//        OthersPageViewController *otherPageVC = [[OthersPageViewController alloc] initWithNibName:@"OthersPageViewController" bundle:Nil andUser:[NSString stringWithFormat:@"%d",wtBtn.tag]];
//        otherPageVC.caller = self;
//        otherPageVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:otherPageVC];
//        navController.navigationBarHidden = YES;
//        navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//        [self presentViewController:navController animated:YES completion:nil];
////    }
    
    TCEND
}
- (void)onClickOfCloseBtnOfWootagProductInfoVC {
    TCSTART
    [wootagInfoVC.view removeFromSuperview];
    wootagInfoVC = nil;
    TCEND
}
- (void)removeTagMarker {
    TCSTART
    tagMarkerView.hidden = YES;
    [tagMarkerView removeFromSuperview];
    tagMarkerView = nil;
    cancelTagMarkerBtn.hidden = YES;
    confirmTagMarkerBtn.hidden = YES;
    TCEND
}

- (void)showTagTool {
    TCSTART
    if (tagToolVC == nil) {
        tagToolVC = [[TagToolViewController alloc]initWithNibName:@"TagToolViewController" bundle:nil];
        tagToolVC.customMoviePlayerController = self;
        tagToolVC.videoPlaybacktime = moviePlayerController.currentPlaybackTime;
        if ([caller isKindOfClass:[SelectCoverFrameViewController class]]) {
            tagToolVC.view.frame = CGRectMake(0, 0, appDelegate.window.frame.size.height, appDelegate.window.frame.size.width - 20);
        } else {
            tagToolVC.view.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width - 20);
        }
        [self.view addSubview:tagToolVC.view];
    }
    TCEND
}

#pragma mark Delete Tag
- (void)onClickOfDeleteTag:(id)sender {
    TCSTART
    playPauseBtn.tag = 1;
    [self onClickOfPlayPauseBtn];
    CustomButton *deleteBtn = (CustomButton *)sender;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:deleteBtn.tagId],@"tagid",[NSNumber numberWithInt:deleteBtn.clientTagId],@"clientTagId", nil];
    Tag *tag = [[DataManager sharedDataManager] getTagByTagIdORClientTagId:dict];
    if (tag.tagId.intValue > 0) {
        [appDelegate makeDeleteTagRequestWithTagId:[tag.tagId stringValue] andCaller:self];
    } else {
        if ([self isNotNull:tag]) {
            [self removeTagMarkerViewWithTagId:nil orClientTagId:tag.clientTagId];
        }
    }
    TCEND
}

- (void)deleteTagsResponseWithTagId:(NSNumber *)tagid {
    TCSTART
    [self removeTagMarkerViewWithTagId:tagid orClientTagId:nil];
    NSInteger numberOfTags = [video.numberOfTags integerValue];
    numberOfTags = numberOfTags - 1;
    video.numberOfTags = [NSNumber numberWithInt:numberOfTags];
    
    TCEND
}

#pragma mark Link Webview
- (void)onClickOfOpenLink:(CustomButton *)sender {
    TCSTART
    if (webviewBackgroundView.isHidden) {
        videoCurrentPalyBackTimeBeforeLinkBtnclicked = moviePlayerController.currentPlaybackTime;
        
        //Pausing video player
        playPauseBtn.tag = 1;
        [self onClickOfPlayPauseBtn];
    
        NSString *link = sender.tagLink;
        [self openTagLinkStr:link andSender:sender];
        
        
        if (sender.tagId > 0) {
            [appDelegate makeRequestForAnalyticsOfVideo:video.videoId analyticsTagClicksOrShareId:TagUrlClick analyticsTagInteractions:FB socialPlatform:FB isForShare:NO isReqForInteractions:NO shareCount:0];
        }
    }
    
    TCEND
}

- (void)openTagLinkStr:(NSString *)link andSender:(CustomButton *)sender {
    TCSTART
    [[UIActivityIndicatorView appearance] setColor:[UIColor whiteColor]];
    if (video && video.videoId.intValue > 0 && sender) {
        webViewShareBtn.hidden = NO;
    } else {
        webViewShareBtn.hidden = YES;
    }
    webviewBackgroundView.hidden = NO;
    [self.view addSubview:webviewBackgroundView];
    webviewBackgroundView.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width - ((CURRENT_DEVICE_VERSION < 7.0)?0:20));
     isNetworkIndicator = NO;
    if (![link hasPrefix:@"http"]) {
        link = [NSString stringWithFormat:@"http://%@",link];
    }
    link = [link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    linkWebView.delegate = self;
    [linkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]];
    backLinkBtn.enabled = NO;
    fwdLinkBtn.enabled = NO;
    
    reloadBtn.hidden = YES;
    activityIndicator.hidden = YES;
    TCEND
}

- (IBAction)onclickOfBackLinkBtn {
    if ([linkWebView canGoBack]) {
        [linkWebView goBack];
    }
}
- (IBAction)onClickOfFwdLinkBtn {
    if ([linkWebView canGoForward]) {
        [linkWebView goForward];
    }
}
- (IBAction)onClickOfReloadBtn:(id)sender {
    [linkWebView reload];
}
- (IBAction)onClickOfWebviewCloseBtn:(id)sender {
    TCSTART
    [activityIndicator stopAnimating];
    [[UIActivityIndicatorView appearance] setColor:[appDelegate colorWithHexString:@"11a3e7"]];
    [linkWebView endEditing:YES];
    [linkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
    [linkWebView stopLoading];
    linkWebView.delegate = nil;
    isNetworkIndicator = NO;
    webviewBackgroundView.hidden = YES;
    if (moviePlayerController.currentPlaybackTime == 0.0) {
        NSLog(@"0.00");
        moviePlayerController.currentPlaybackTime = videoCurrentPalyBackTimeBeforeLinkBtnclicked;
        if (video && video.videoId.intValue > 0) {
            [self performSelector:@selector(playVideo) withObject:nil afterDelay:2];
        } else {
            [self playVideo];
        }
    }

    [self onclickOfDetailsViewCloseBtn:nil];
    TCEND
}

#pragma mark WebView Delegate Methods
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView_ {
    
    @try {
        if (!isNetworkIndicator) {
            isNetworkIndicator = YES;
            reloadBtn.hidden = YES;
            activityIndicator.hidden = NO;
            [activityIndicator startAnimating];
        }
    }
    @catch (NSException *exception) {
        //NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView_ {
    @try {
        isNetworkIndicator = NO;
        
        reloadBtn.hidden = NO;
        activityIndicator.hidden = YES;
        [activityIndicator stopAnimating];
        if ([webView_ canGoBack]) {
            backLinkBtn.enabled = YES;
        } else {
            backLinkBtn.enabled = NO;
        }
        
        if ([webView_ canGoForward]) {
            fwdLinkBtn.enabled = YES;
        } else {
            fwdLinkBtn.enabled = NO;
        }
    }
    @catch (NSException *exception) {
        //NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)webView:(UIWebView *)webView_ didFailLoadWithError:(NSError *)error {
    @try {
        isNetworkIndicator = NO;
        reloadBtn.hidden = NO;
        activityIndicator.hidden = YES;
        [activityIndicator stopAnimating];
    }
    @catch (NSException *exception) {
        //NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

#pragma mark Orientation Support Methods
//For iOS5
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	//[[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
	
	if((interfaceOrientation == UIInterfaceOrientationLandscapeRight)||
	   (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)){
		//moviePlayerController.view.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
		return YES;
	}
	return NO;
}


#pragma mark Tableview Delegate and Datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([taggedUserType caseInsensitiveCompare:@"twitter"] == NSOrderedSame || socailTaggedUserScenarioType == 2) {
        return 3;
    } else if (socailTaggedUserScenarioType == 1){
        return 0;
    } else {
        return 5;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self getHeightOfRowAtIndexPath:indexPath];
}

- (CGFloat)getHeightOfRowAtIndexPath :(NSIndexPath *)indexPath {
    TCSTART
    if (socailTaggedUserScenarioType == 2) {
        if (indexPath.row == 0) {
            if ([self isNotNull:[taggedUserDetialsDict objectForKey:@"status"]]) {
                CGSize textSize = [[taggedUserDetialsDict objectForKey:@"status"] sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:13] constrainedToSize:CGSizeMake((appDelegate.window.frame.size.height > 480)?300:210, 2222) lineBreakMode:NSLineBreakByWordWrapping];
                if (textSize.height > 15) {
                    return textSize.height + 35;
                }
            }
        }
    }
    if (socailTaggedUserScenarioType == 3) {
        if ([taggedUserType caseInsensitiveCompare:@"twitter"] == NSOrderedSame) {
            if (indexPath.row == 0) {
                CGSize textSize = [[taggedUserDetialsDict objectForKey:@"Description"] sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:13] constrainedToSize:CGSizeMake((appDelegate.window.frame.size.height > 480)?300:210, 2222) lineBreakMode:NSLineBreakByWordWrapping];
                if (textSize.height > 15) {
                    return textSize.height + 35;
                }
            }

            if (indexPath.row == 2) {
                CGSize textSize = [[taggedUserDetialsDict objectForKey:@"Lives In"] sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:13] constrainedToSize:CGSizeMake((appDelegate.window.frame.size.height > 480)?300:210, 2222) lineBreakMode:NSLineBreakByWordWrapping];
                if (textSize.height > 15) {
                    return textSize.height + 35;
                }
            }
            
        } else {
            if (indexPath.row == 0) {
                CGSize textSize = [[taggedUserDetialsDict objectForKey:@"Working at"] sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:13] constrainedToSize:CGSizeMake((appDelegate.window.frame.size.height > 480)?300:210, 2222) lineBreakMode:NSLineBreakByWordWrapping];
                if (textSize.height > 15) {
                    return textSize.height + 35;
                }
            }
            if (indexPath.row == 1) {
                CGSize textSize = [[taggedUserDetialsDict objectForKey:@"Studied at"] sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:13] constrainedToSize:CGSizeMake((appDelegate.window.frame.size.height > 480)?300:210, 2222) lineBreakMode:NSLineBreakByWordWrapping];
                if (textSize.height > 15) {
                    return textSize.height + 35;
                }
            }
            if (indexPath.row == 2) {
                CGSize textSize = [[taggedUserDetialsDict objectForKey:@"Lives In"] sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:13] constrainedToSize:CGSizeMake((appDelegate.window.frame.size.height > 480)?300:210, 2222) lineBreakMode:NSLineBreakByWordWrapping];
                if (textSize.height > 15) {
                    return textSize.height + 35;
                }
            }
            if (indexPath.row == 3) {
                CGSize textSize = [[taggedUserDetialsDict objectForKey:@"From"] sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:13] constrainedToSize:CGSizeMake((appDelegate.window.frame.size.height > 480)?300:210, 2222) lineBreakMode:NSLineBreakByWordWrapping];
                if (textSize.height > 15) {
                    return textSize.height + 35;
                }
            }
            if (indexPath.row == 4) {
                CGSize textSize = [[taggedUserDetialsDict objectForKey:@"Relationship"] sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:13] constrainedToSize:CGSizeMake((appDelegate.window.frame.size.height > 480)?300:210, 2222) lineBreakMode:NSLineBreakByWordWrapping];
                if (textSize.height > 15) {
                    return textSize.height + 35;
                }
            }
        }
    }
	return 50;
    TCEND
}
- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    static NSString * cellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];

        cell.textLabel.font = [UIFont fontWithName:descriptionTextFontName size:14];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        
        cell.detailTextLabel.font = [UIFont fontWithName:descriptionTextFontName size:13];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.numberOfLines = 0;
        
    }
    
    if ([taggedUserType caseInsensitiveCompare:@"twitter"] == NSOrderedSame) {
        cell.textLabel.textColor = [appDelegate colorWithHexString:@"33ccff"];
    } else if ([taggedUserType caseInsensitiveCompare:@"Gplus"] == NSOrderedSame) {
        cell.textLabel.textColor = [appDelegate colorWithHexString:@"d6492f"];
    } else {
        cell.textLabel.textColor = [appDelegate colorWithHexString:@"3a589b"];
    }
    
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    cell.imageView.hidden = YES;

    if (socailTaggedUserScenarioType == 2) {
        if (indexPath.row == 0) {
            if ([taggedUserType caseInsensitiveCompare:@"Gplus"] == NSOrderedSame) {
                cell.textLabel.text = @"Tagline";
            } else {
                cell.textLabel.text = @"Status";
            }
            
            if ([self isNotNull:[taggedUserDetialsDict objectForKey:@"status"]]) {
                cell.detailTextLabel.text = [taggedUserDetialsDict objectForKey:@"status"];
            } else {
                cell.detailTextLabel.text = @"";
            }
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"Last update";
            if ([self isNotNull:[taggedUserDetialsDict objectForKey:@"lastupdate"]]) {
                if ([taggedUserType caseInsensitiveCompare:@"FB"] == NSOrderedSame) {
                    cell.detailTextLabel.text = [appDelegate facebookLastUpdateDateStringFromMillisecondsTime:[taggedUserDetialsDict objectForKey:@"lastupdate"]];
                } else {
                    cell.detailTextLabel.text = [appDelegate twitterLastUpdateDateString:[taggedUserDetialsDict objectForKey:@"lastupdate"]];
                }
            }
        }
        
        if (indexPath.row == 2) {
            cell.textLabel.text = @"Location";
            cell.detailTextLabel.text = [taggedUserDetialsDict objectForKey:@"Lives In"];
        }
    } else {
        if ([taggedUserType caseInsensitiveCompare:@"twitter"] == NSOrderedSame) {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Description";
                cell.detailTextLabel.text = [taggedUserDetialsDict objectForKey:@"Description"];
            }
            if (indexPath.row == 1) {
                cell.textLabel.text = @"No of followers";
                cell.detailTextLabel.text = [taggedUserDetialsDict objectForKey:@"followers_count"];
            }
            if (indexPath.row == 2) {
                cell.textLabel.text = @"Location";
                cell.detailTextLabel.text = [taggedUserDetialsDict objectForKey:@"Lives In"];
            }
            
        } else {
            cell.imageView.hidden = NO;
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Working At";
                cell.detailTextLabel.text = [taggedUserDetialsDict objectForKey:@"Working at"];
            }
            if (indexPath.row == 1) {
                cell.textLabel.text = @"Studied At";
                cell.detailTextLabel.text = [taggedUserDetialsDict objectForKey:@"Studied at"];
            }
            if (indexPath.row == 2) {
                cell.textLabel.text = @"Lives in";
                cell.detailTextLabel.text = [taggedUserDetialsDict objectForKey:@"Lives In"];
            }
            if (indexPath.row == 3) {
                cell.textLabel.text = @"From";
                cell.detailTextLabel.text = [taggedUserDetialsDict objectForKey:@"From"];
            }
            if (indexPath.row == 4) {
                cell.textLabel.text = @"Relationship";
                cell.detailTextLabel.text = [taggedUserDetialsDict objectForKey:@"Relationship"];
            }
        }
    }
    
    CGFloat rowHeight = [self getHeightOfRowAtIndexPath:indexPath];
    cell.textLabel.frame = CGRectMake(5, 5, cell.textLabel.frame.size.width, 20);
    cell.detailTextLabel.frame = CGRectMake(5, 30, (appDelegate.window.frame.size.height > 480)?300:210, rowHeight-35);
//    cell.detailTextLabel.backgroundColor = [UIColor redColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    TCEND
}

#pragma mark - textView Delegate

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView {
    
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    @try {
        
    }
    @catch (NSException *exception) {
        //NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)textViewDidChange:(UITextView *) textView  {
    @try {
        
    }
    @catch (NSException *exception) {
        //NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    TCSTART
        if ([text isEqualToString:@"\n"]) {
            [textView resignFirstResponder];
            return NO;
        }
        return YES;
    TCEND
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self removeToastView];
//    if (!instrtnImgView.hidden) {
//        instrtnImgView.hidden = YES;
//        playPauseBtn.tag = 0;
//        [self onClickOfPlayPauseBtn];
////        if (![appDelegate.ftue.selectedTagBtn boolValue]) {
////            appDelegate.ftue.selectedTagBtn = [NSNumber numberWithBool:YES];
////            [[DataManager sharedDataManager] saveChanges];
////            toastView = [appDelegate getToastViewWithMessageText:kTagSelected andFrame:CGRectMake((appDelegate.window.frame.size.height - 324)/2, (appDelegate.window.frame.size.width - 150)/2 + 20, 324, 150)];
////            [self.view addSubview:toastView];
////            [self.view bringSubviewToFront:toastView];
////        } else {
////            playPauseBtn.tag = 0;
////            [self onClickOfPlayPauseBtn];
////        }
//    }
    
    [messageTextView resignFirstResponder];
}

- (void)removeToastView {
//    [othersVideoToastView removeFromSuperview];
//    [toastView removeFromSuperview];
//    toastView = nil;
    [introzoneView removeFromSuperview];
    if ([self isNotNull:introzoneView]) {
        NSLog(@"not null");
        playPauseBtn.tag = 0;
        [self onClickOfPlayPauseBtn];
    }
    introzoneView = nil;
    [toastView removeFromSuperview];
    toastView = nil;
}

//For iOS 6
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        return UIInterfaceOrientationLandscapeLeft;
    } else {
        return UIInterfaceOrientationLandscapeRight;
    }
}

- (void)viewWillUnload {

    
}

#pragma mark Memory Related
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
