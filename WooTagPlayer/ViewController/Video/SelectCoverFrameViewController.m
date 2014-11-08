/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "SelectCoverFrameViewController.h"
#import "FrameCustomButton.h"


@interface SelectCoverFrameViewController ()

@end

@implementation SelectCoverFrameViewController
@synthesize superVC;
@synthesize thumbImg;
@synthesize recordedPath;
@synthesize filePath;
@synthesize isLibraryVideo;
@synthesize filterStatus;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withThumbImage:(UIImage *)image_
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        thumbImg = image_;
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}


- (void)viewDidLoad {
    TCSTART
    firstTime = YES;
    self.view.frame = CGRectMake(0, 0, appDelegate.window.frame.size.height, appDelegate.window.frame.size.width-20);
    [super viewDidLoad];
    thumbImageView.image = thumbImg;
    
    selectedFrameImgView.layer.borderWidth = 3.0;
    selectedFrameImgView.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
    selectedFrameImgView.layer.masksToBounds = YES;
    selectedThumbTime = 0.00;
    
    clientVideoId = [appDelegate generateUniqueId];
    TCEND
}

- (void)viewDidAppear:(BOOL)animated {
    TCSTART
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if (!clickedOnNext) {
        CGRect frameViewFrame = framesView.frame;
        frameViewFrame.origin.x = 0;
        frameViewFrame.size.width = appDelegate.window.frame.size.height;
        framesView.frame = frameViewFrame;
        [self removeAllFrameCustomButtonsFromFramesView];
        
        [self createFramesFromVideo];
        [framesView bringSubviewToFront:selectedFrameImgView];
    }
    TCEND
}

- (void)removeAllFrameCustomButtonsFromFramesView {
    TCSTART
    for (UIView *subview in framesView.subviews) {
        if ([subview isKindOfClass:[FrameCustomButton class]]) {
            [subview removeFromSuperview];
        }
    }
    
    TCEND
}

- (void) viewDidLayoutSubviews {
    if (CURRENT_DEVICE_VERSION >= 7.0  && self.view.frame.size.height == appDelegate.window.frame.size.width) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.origin.y = -topBarOffset;
        self.view.bounds = viewBounds;
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (IBAction)onClickOfBackBtn:(id)sender {
    clickedOnNext = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onClickOFNextBtn:(id)sender {
    TCSTART
    clickedOnNext = YES;
//    BOOL showInstruntnScreen = ![self tagsAreCreatedToThisVideo];
    CustomMoviePlayerViewController *customMoviePlayerVC = [[CustomMoviePlayerViewController alloc]initWithNibName:@"CustomMoviePlayerViewController" bundle:nil video:nil videoFilePath:filePath andClientVideoId:[NSString stringWithFormat:@"%d",clientVideoId] showInstrcutnScreen:YES];
    customMoviePlayerVC.caller = self;
    [self presentViewController:customMoviePlayerVC animated:NO completion:nil];
    TCEND
}

- (void)videoInfoScreenBackClicked {
    [self onClickOFNextBtn:nil];
}

- (BOOL)tagsAreCreatedToThisVideo {
    TCSTART
    NSLog(@"ClientVideoId :%d",clientVideoId);
    NSArray *array = [[DataManager sharedDataManager] getAllTagsByVideoIdAndClientVideoId:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",clientVideoId],@"clientVideoId", nil]];
    if ([self isNotNull:array] && array.count > 0) {
        return YES;
    } else {
        return NO;
    }
    TCEND
}

- (void)playerScreenDismissed {
    TCSTART
    clickedOnNext = YES;
    //    tagRLaterView.hidden = YES;
    if (![self tagsAreCreatedToThisVideo]) {
        [ShowAlert showAlert:@"Remember to tag your video anytime after the video is uploaded"];
    }
    
    [self gotoVideoInfoVC];
    
    TCEND
}

- (void)gotoVideoInfoVC {
    TCSTART
    if ([self isNull:videoInfoVC]) {
        videoInfoVC = [[VideoInfoViewController alloc]initWithNibName:@"VideoInfoViewController" bundle:nil clientVideoId:clientVideoId];
    }
    videoInfoVC.isLibraryVideo = isLibraryVideo;
    videoInfoVC.filterStatus = filterStatus;
    videoInfoVC.filePath = filePath;
    videoInfoVC.recordedPath = recordedPath;
    videoInfoVC.superVC = superVC;
    videoInfoVC.thumbImg = thumbImg;
    videoInfoVC.coverFrameValue = selectedThumbTime;
    videoInfoVC.selectFRameVCRef = self;
    [self.navigationController pushViewController:videoInfoVC animated:YES];
    TCEND
}
- (void)clickedOnPlayerScreenBackButton {
    TCSTART
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    TCEND
}

- (void)createFramesFromVideo {
    TCSTART
    AVAsset *myAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:filePath] options:nil];
    NSArray *tracksArray = [myAsset tracks];
    
    CGFloat frameRate;
    if (tracksArray.count > 0) {
        frameRate = [[tracksArray objectAtIndex:0] nominalFrameRate];
    }
    
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:myAsset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    imageGenerator.maximumSize = CGSizeMake(thumbImageView.frame.size.width * 2, thumbImageView.frame.size.height * 2);
    
    NSError *error;
    CMTime actualTime;
    
    int picsCnt;
    CGFloat _durationSeconds = CMTimeGetSeconds([myAsset duration]);
    if (appDelegate.window.frame.size.height > 480) {
        if ((_durationSeconds*frameRate) < 11) {
            picsCnt = (_durationSeconds * frameRate);
        } else {
            picsCnt = 11;
        }
    } else {
        if ((_durationSeconds*frameRate) < 9) {
            picsCnt = (_durationSeconds * frameRate);
        } else {
            picsCnt = 9;
        }
    }
    
    int originX = 0;
    CGFloat picWidth = 50;
    CGRect framesviewFrame = framesView.frame;
    framesviewFrame.size.width = picWidth * picsCnt;
    framesviewFrame.origin.x = (framesView.frame.size.width - (picsCnt * picWidth))/2;
    framesView.frame = framesviewFrame;
    framesView.layer.cornerRadius = 5.0;
//    framesView.layer.borderColor = [UIColor blackColor].CGColor;
//    framesView.layer.borderWidth = 2.0;
    framesView.layer.masksToBounds = YES;
    
    NSMutableArray *allTimes = [[NSMutableArray alloc] init];
    
    if (CURRENT_DEVICE_VERSION >= 7.0) {
        // Bug iOS7 - generateCGImagesAsynchronouslyForTimes
        
        for (int i = 0; i < picsCnt; i++) {
            
            CMTime timeFrame = CMTimeMakeWithSeconds((_durationSeconds/picsCnt)*i, 600);
            NSLog(@"%f", (_durationSeconds/picsCnt)*i);
            [allTimes addObject:[NSValue valueWithCMTime:timeFrame]];
            
            CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:timeFrame actualTime:&actualTime error:&error];
            
            UIImage *videoFrame;
            if ([self isRetina]){
                videoFrame = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
            } else {
                videoFrame = [[UIImage alloc] initWithCGImage:halfWayImage];
            }
            
//            [imageFramesArray addObject:videoFrame];
            
            FrameCustomButton *tmp = [FrameCustomButton buttonWithType:UIButtonTypeCustom];
            [tmp setBackgroundImage:videoFrame forState:UIControlStateNormal];
            tmp.timeFrameValue = (_durationSeconds/picsCnt)*i;
            [tmp addTarget:self action:@selector(onClickOfFrameBtn:) forControlEvents:UIControlEventTouchUpInside];
            CGRect currentFrame = tmp.frame;
            currentFrame.origin.x = originX;
            currentFrame.origin.y = 0;
            currentFrame.size.height = 50;
            currentFrame.size.width = picWidth;
            tmp.frame = currentFrame;
            originX = originX + tmp.frame.size.width;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [framesView addSubview:tmp];
                if (tmp.timeFrameValue == selectedThumbTime && !firstTime) {
                    [self onClickOfFrameBtn:tmp];
                }
                if (i == 0) {
                    if (firstTime) {
                        [self onClickOfFrameBtn:tmp];
                    }
                }
                if (i == picsCnt-1) {
                    [framesView bringSubviewToFront:selectedFrameImgView];
                }
                
            });
            
            CGImageRelease(halfWayImage);
        }
        
        return;
    }
    
    for (int i = 0; i < picsCnt; i++) {
        CMTime timeFrame = CMTimeMakeWithSeconds((_durationSeconds/picsCnt)*i, 600);
        [allTimes addObject:[NSValue valueWithCMTime:timeFrame]];
    }
    
    NSArray *times = allTimes;
    
    __block int i = 0;
    
    [imageGenerator generateCGImagesAsynchronouslyForTimes:times
                                         completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime,
                                                             AVAssetImageGeneratorResult result, NSError *error) {
                                             
                                             if (result == AVAssetImageGeneratorSucceeded) {
                                                 UIImage *videoFrame;
                                                 if ([self isRetina]){
                                                     videoFrame = [[UIImage alloc] initWithCGImage:image scale:2.0 orientation:UIImageOrientationUp];
                                                 } else {
                                                     videoFrame = [[UIImage alloc] initWithCGImage:image];
                                                 }
//                                                 [imageFramesArray addObject:videoFrame];
                                                 
                                                 FrameCustomButton *tmp = [FrameCustomButton buttonWithType:UIButtonTypeCustom];
                                                 [tmp addTarget:self action:@selector(onClickOfFrameBtn:) forControlEvents:UIControlEventTouchUpInside];
                                                 [tmp setBackgroundImage:videoFrame forState:UIControlStateNormal];
                                                 tmp.timeFrameValue = (_durationSeconds/picsCnt)*i;                                             CGRect currentFrame = tmp.frame;
                                                 currentFrame.origin.x = i*picWidth;
                                                 currentFrame.origin.y = 0;
                                                 currentFrame.size.height = 50;
                                                 currentFrame.size.width = picWidth;
                                                 NSLog(@"%d",i);
                                                 tmp.frame = currentFrame;
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [framesView bringSubviewToFront:selectedFrameImgView];
                                                     [framesView addSubview:tmp];
                                                     if (tmp.timeFrameValue == selectedThumbTime && !firstTime) {
                                                         [self onClickOfFrameBtn:tmp];
                                                     }
                                                     if (i == 0) {
                                                         if (firstTime) {
                                                             [self onClickOfFrameBtn:tmp];
                                                         }
                                                     }
                                                 });
                                                 i++;
                                             }
                                             
                                             if (result == AVAssetImageGeneratorFailed) {
                                                 NSLog(@"Failed with error: %@", [error localizedDescription]);
                                             }
                                             if (result == AVAssetImageGeneratorCancelled) {
                                                 NSLog(@"Canceled");
                                             }
                                         }];
    TCEND
}

//- (void)

- (IBAction)onClickOfFrameBtn:(FrameCustomButton *)sender {
    TCSTART
    firstTime = NO;
    CGRect frameBtnFrame = sender.frame;
    selectedFrameImgView.image = [sender backgroundImageForState:UIControlStateNormal];
    selectedFrameImgView.frame = frameBtnFrame;
    selectedThumbTime = sender.timeFrameValue;
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:filePath]];
    thumbImg = [player thumbnailImageAtTime:sender.timeFrameValue timeOption:MPMovieTimeOptionNearestKeyFrame];
    [player stop];
    thumbImageView.image = thumbImg;
    [framesView bringSubviewToFront:selectedFrameImgView];
    NSLog(@"selected cover frame:%.2f",selectedThumbTime);
    TCEND
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)isRetina {
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            
            ([UIScreen mainScreen].scale == 2.0));
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if((interfaceOrientation == UIInterfaceOrientationLandscapeRight)||(interfaceOrientation == UIInterfaceOrientationLandscapeLeft))
	{
		return YES;
	}
	else
        return NO;
}

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
    return UIInterfaceOrientationLandscapeLeft;
}

@end
