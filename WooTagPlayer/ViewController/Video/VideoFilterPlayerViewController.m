/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "VideoFilterPlayerViewController.h"
#import "DLCGrayscaleContrastFilter.h"

@interface VideoFilterPlayerViewController ()

@end

@implementation VideoFilterPlayerViewController
@synthesize superVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil recordedMoviePath:(NSString *)filePath isLibraryVideo:(BOOL)isLibraryVideo {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        recordedMoviePath = filePath;
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        libraryVideo = isLibraryVideo;
    }
    return self;
}

- (void)viewDidLoad {
    TCSTART
    fastFwdLabl.hidden = YES;
    [super viewDidLoad];
    selectedFilterIndex = 1;
    beforeSelectedFilterIndex = 1;
    
    if (libraryVideo) {
        videoOrientaiton = [self getPickedVideoOrientationAndTransForm];
    }

    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:recordedMoviePath]];
    UIImage *thumbNailImage = [player thumbnailImageAtTime:player.duration timeOption:MPMovieTimeOptionNearestKeyFrame];
    [player stop];

    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:recordedMoviePath]];
    
    NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    NSLog(@"Audio track count:%d",audioTracks.count);
    if (audioTracks.count > 0) {
        soundenable = YES;
    } else {
        soundenable = NO;
    }
    
    thumbImageView.image = thumbNailImage;
    
    filteredMoviePath = [self getFilePathToSaveHQVideoAfterFilter];
    NSString *directory = [appDelegate getApplicationDocumentsDirectoryAsString];
    dummyVideoPath = [NSString stringWithFormat:@"%@/DummyVideo.mov", directory];
    
    [self setFilter:selectedFilterIndex showtoast:NO];
    [self addFilterButtonsToScrollview];
    thumbImageView.hidden = NO;
    TCEND
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
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

#pragma mark Filters View
- (void)addFilterButtonsToScrollview {
    TCSTART
    CGFloat totalButtonWidth = 5.0f;
    for(int i = 1; i < 9; i++) {
        UIButton *filterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        filterBtn.tag = i;
        [filterBtn addTarget:self action:@selector(setFilterToTheVideo:) forControlEvents:UIControlEventTouchUpInside];
        filterBtn.frame = CGRectMake(totalButtonWidth, 3, 63, 63);
        [filterBtn setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d",i]] forState:UIControlStateNormal];
        [filtersScrollView addSubview:filterBtn];
        totalButtonWidth = 5 + filterBtn.frame.size.width + filterBtn.frame.origin.x;
    }
    if (totalButtonWidth < appDelegate.window.frame.size.height) {
        filtersScrollView.frame = CGRectMake((appDelegate.window.frame.size.height-totalButtonWidth)/2, filtersScrollView.frame.origin.y, totalButtonWidth, filtersScrollView.frame.size.height);
    }
    [filtersScrollView setContentSize:CGSizeMake(totalButtonWidth, filtersScrollView.frame.size.height)];
    TCEND
}

- (void) setFilter:(int) index showtoast:(BOOL)toast {
    TCSTART
    if (toast) {
        fastFwdLabl.hidden = NO;
    } else {
        fastFwdLabl.hidden = YES;
    }
    
    NSLog(@"VideoEncodingTargetBefore:%d",movieFile.videoEncodingIsFinished);
    [self performSelectorOnMainThread:@selector(cancelFilterVideoProcessing) withObject:nil waitUntilDone:YES];
//    [self cancelFilterVideoProcessing];
    NSLog(@"VideoEncodingTargetAfter:%d",movieFile.videoEncodingIsFinished);
    
    switch (index) {
        case 1:
            rgbFilter = [[GPUImageFilter alloc] init];
            break;
        case 2:
            rgbFilter = [[GPUImageRGBFilter alloc] init];
            [(GPUImageRGBFilter *)rgbFilter setRed:181.0f/255.0f];
            [(GPUImageRGBFilter *)rgbFilter setGreen:217.0f/255.0f];
            [(GPUImageRGBFilter *)rgbFilter setBlue:255.0f/255.0f];
            break;
        case 3:
            rgbFilter = [[GPUImageRGBFilter alloc] init];
            [(GPUImageRGBFilter *)rgbFilter setRed:238.0f/255.0f];
            [(GPUImageRGBFilter *)rgbFilter setGreen:255.0f/255.0f];
            [(GPUImageRGBFilter *)rgbFilter setBlue:190.0f/255.0f];
            break;
        case 4:
            rgbFilter = [[GPUImageRGBFilter alloc] init];
            [(GPUImageRGBFilter *)rgbFilter setRed:242.0f/255.0f];
            [(GPUImageRGBFilter *)rgbFilter setGreen:193.0f/255.0f];
            [(GPUImageRGBFilter *)rgbFilter setBlue:167.0f/255.0f];
            break;
        case 5:
            rgbFilter = [[GPUImageRGBFilter alloc] init];
            [(GPUImageRGBFilter *)rgbFilter setRed:249.0f/255.0f];
            [(GPUImageRGBFilter *)rgbFilter setGreen:182.0f/255.0f];
            [(GPUImageRGBFilter *)rgbFilter setBlue:188.0f/255.0f];
            break;
        case 6:
            rgbFilter = [[GPUImageRGBFilter alloc] init];
            [(GPUImageRGBFilter *)rgbFilter setRed:242.0f/255.0f];
            [(GPUImageRGBFilter *)rgbFilter setGreen:212.0f/255.0f];
            [(GPUImageRGBFilter *)rgbFilter setBlue:142.0f/255.0f];
            break;
        case 7:
            rgbFilter = [[GPUImageRGBFilter alloc] init];
            [(GPUImageRGBFilter *)rgbFilter setRed:251.0f/255.0f];
            [(GPUImageRGBFilter *)rgbFilter setGreen:233.0f/255.0f];
            [(GPUImageRGBFilter *)rgbFilter setBlue:147.0f/255.0f];
            break;
        case 8:
            rgbFilter = [[DLCGrayscaleContrastFilter alloc] init];
            break;
        default:
            break;
    }
    
    if (!(selectedFilterIndex == 1 || selectedFilterIndex == beforeSelectedFilterIndex)) {
        completedFiltering = NO;
        isdummyVideoPlaying = NO;
    } else {
        completedFiltering = YES;
        isdummyVideoPlaying = YES;
    }
    if (libraryVideo) {
//        if (!toast)
            [self applyFilterToPickedVideo];
//        else
//            [self performSelector:@selector(applyFilterToPickedVideo) withObject:nil afterDelay:0.011];
    } else {
//        if (!toast)
            [self applyFilterToRecordedVideo];
//        else
//            [self performSelector:@selector(applyFilterToRecordedVideo) withObject:nil afterDelay:0.007];
    }
    
    TCEND
}

- (void)setFilterToTheVideo:(id)sender {
    TCSTART
    UIButton *btn = (UIButton *)sender;
    selectedFilterIndex = btn.tag;
    [self setFilter:selectedFilterIndex showtoast:YES];
    TCEND
}

- (void)applyFilterToRecordedVideo {
    TCSTART
    movieFile = [[GPUImageMovie alloc] initWithURL:[NSURL fileURLWithPath:recordedMoviePath]];
    movieFile.runBenchmark = NO;
    movieFile.playAtActualSpeed = NO;
    
    if ([self isNull:rgbFilter]) {
        rgbFilter = [[GPUImageFilter alloc] init];
    }
    [movieFile addTarget:rgbFilter];
    
    // Only rotate the video for display, leave orientation the same for recording
    GPUImageView *filterView = (GPUImageView *)gpuImageView;
    [rgbFilter addTarget:filterView];
    NSURL *movieURL;
    
    if (isdummyVideoPlaying) {
        unlink([dummyVideoPath UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
        movieURL = [NSURL fileURLWithPath:dummyVideoPath];
    } else {
        unlink([filteredMoviePath UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
        movieURL = [NSURL fileURLWithPath:filteredMoviePath];
    }

    movieWriterFilter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake((appDelegate.window.frame.size.height) * 2, (appDelegate.window.frame.size.width) * 2)];
//    movieWriterFilter.delegate = self;
    [rgbFilter addTarget:movieWriterFilter];
    
    // Configure this for video from the movie file, where we want to preserve all video frames and audio samples
    if (soundenable) {
        movieWriterFilter.shouldPassthroughAudio = YES;
//        movieWriterFilter.encodingLiveVideo = NO;
        movieFile.audioEncodingTarget = movieWriterFilter;
    }
    [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriterFilter];
    
    appDelegate.isVideoRecording = YES;
    if (appDelegate.isVideoExporting) {
        isExporting = appDelegate.isVideoExporting;
        [appDelegate cancelExport];
    }
    NSLog(@"filter started");
    [movieWriterFilter startRecording];
    [movieFile startProcessing];

    //for Avoiding white flicker hidding here
    thumbImageView.hidden = YES;
    
    __unsafe_unretained typeof(self) weakSelf = self;
    [movieWriterFilter setCompletionBlock:^{
        [weakSelf performSelectorOnMainThread:@selector(completedPlaying) withObject:nil waitUntilDone:NO];
         NSLog(@"Completed movie playing");
    }];
    TCEND
}

- (UIInterfaceOrientation)getPickedVideoOrientationAndTransForm {
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:recordedMoviePath] options:nil];
    videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    videoTransform = videoAssetTrack.preferredTransform;
//    if (size.width == txf.tx && size.height == txf.ty) return UIInterfaceOrientationLandscapeLeft; else if (txf.tx == 0 && txf.ty == 0) return UIInterfaceOrientationLandscapeRight
    if (videoAssetTrack.naturalSize.width == videoTransform.tx && videoAssetTrack.naturalSize.height == videoTransform.ty)
        return UIInterfaceOrientationLandscapeLeft;
    else if (videoTransform.tx == 0 && videoTransform.ty == 0)
        return UIInterfaceOrientationLandscapeRight;
    else if (videoTransform.tx == 0 && videoTransform.ty == videoAssetTrack.naturalSize.width)
        return UIInterfaceOrientationPortraitUpsideDown;
    else
        return UIInterfaceOrientationPortrait;
}


- (void)applyFilterToPickedVideo {
    TCSTART
    
    movieFile = [[GPUImageMovie alloc] initWithURL:[NSURL fileURLWithPath:recordedMoviePath]];
    movieFile.runBenchmark = NO;
    movieFile.playAtActualSpeed = NO;
    
    if ([self isNull:rgbFilter]) {
        rgbFilter = [[GPUImageFilter alloc] init];
    }
    [movieFile addTarget:rgbFilter];
    
    // Only rotate the video for display, leave orientation the same for recording
    GPUImageView *filterView = (GPUImageView *)gpuImageView;
    [filterView setInputSize:CGSizeMake(videoAssetTrack.naturalSize.width, videoAssetTrack.naturalSize.height) atIndex:0];
    if (videoOrientaiton == UIInterfaceOrientationPortraitUpsideDown) {
        [filterView setInputRotation:kGPUImageRotateLeft atIndex:0];
    } else if (videoOrientaiton == UIInterfaceOrientationPortrait) {
        [filterView setInputRotation:kGPUImageRotateRight atIndex:0];
    } else if (videoOrientaiton == UIInterfaceOrientationLandscapeLeft) {
        [filterView setInputRotation:kGPUImageRotate180 atIndex:0];
    }
    
    [rgbFilter addTarget:filterView];
    NSURL *movieURL;
    
    if (isdummyVideoPlaying) {
        unlink([dummyVideoPath UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
        movieURL = [NSURL fileURLWithPath:dummyVideoPath];
    } else {
        unlink([filteredMoviePath UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
        movieURL = [NSURL fileURLWithPath:filteredMoviePath];
    }
    
   
    movieWriterFilter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(videoAssetTrack.naturalSize.width, videoAssetTrack.naturalSize.height)];
//    movieWriterFilter.delegate = self;
    [rgbFilter addTarget:movieWriterFilter];
    
    // Configure this for video from the movie file, where we want to preserve all video frames and audio samples
    if (soundenable) {
        movieWriterFilter.shouldPassthroughAudio = YES;
//        movieWriterFilter.encodingLiveVideo = NO;
        movieFile.audioEncodingTarget = movieWriterFilter;
    }
    [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriterFilter];
    
    appDelegate.isVideoRecording = YES;
    if (appDelegate.isVideoExporting) {
        isExporting = appDelegate.isVideoExporting;
        [appDelegate cancelExport];
    }
    
    NSLog(@"filter started");
    [movieWriterFilter startRecordingInOrientation:videoTransform];
//    [movieWriterFilter startRecording];
    [movieFile startProcessing];
    
    //for Avoiding white flicker hidding here
    thumbImageView.hidden = YES;
    
    __unsafe_unretained typeof(self) weakSelf = self;
    [movieWriterFilter setCompletionBlock:^{
        [weakSelf performSelectorOnMainThread:@selector(completedPlaying) withObject:nil waitUntilDone:NO];
        NSLog(@"Completed movie playing");
    }];
    TCEND
}

- (void)cancelFilterVideoProcessing {
    TCSTART
    
    [rgbFilter removeAllTargets];
    [movieWriterFilter cancelRecording];
    [movieWriterFilter finishRecording];
    movieWriterFilter = nil;
    
    [movieFile cancelProcessing];
    [movieFile removeAllTargets];
    movieFile.assetReader = nil;
    movieFile.asset = nil;
    movieFile.audioEncodingTarget = nil;
    movieFile = nil;
    TCEND
}

- (void)movieRecordingFailedWithError:(NSError*)error {
    TCSTART
    NSLog(@"Movie Record Canceled:%@",[error localizedDescription]);
    TCEND
}
- (void)movieRecordingCompleted {
    NSLog(@"movieRecordingCompleted");
}
- (void)completedPlaying {
    
    TCSTART
    beforeSelectedFilterIndex = selectedFilterIndex;
    [rgbFilter removeTarget:movieWriterFilter];
    [movieWriterFilter finishRecording];
//    [movieFile endProcessing];
    [movieFile removeTarget:rgbFilter];
    completedFiltering = YES;
//    movieWriterFilter.completionBlock = NULL;
    [appDelegate removeNetworkIndicatorInView:filtersView];
    [appDelegate hideNetworkIndicator];
    if (clickedOnNextButton) {
        [self onClickOfNextBtn:nil];
    }
    appDelegate.isVideoRecording = NO;
    if (isExporting) {
        [appDelegate uploadVideo];
    }
    NSLog(@"Playing Completed");
    TCEND
}

- (NSString *)getFilePathToSaveHQVideoAfterFilter {
    TCSTART
    NSString *directory = [appDelegate getApplicationDocumentsDirectoryAsString];
	directory = [directory stringByAppendingString:@"/HQVideos"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory])
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    NSString *clientVideoId = [appDelegate generateUniqueVideoId];
	if(![[NSFileManager defaultManager]fileExistsAtPath:[NSString stringWithFormat:@"%@/Video%@.mov", directory , clientVideoId]]) {
        return [NSString stringWithFormat:@"%@/Video%@.mov", directory , clientVideoId];
    } else {
        return [self getFilePathToSaveHQVideoAfterFilter];
    }
    TCEND
}

#pragma mark Filters view next button actions
- (IBAction)onClickOfNextBtn:(id)sender {
    TCSTART
    fastFwdLabl.hidden = YES;
    clickedOnNextButton = YES;
    if (completedFiltering) {
        if (isdummyVideoPlaying) {
            isdummyVideoPlaying = NO;
            [self cancelFilterVideoProcessing];
            if ([[NSFileManager defaultManager] fileExistsAtPath:dummyVideoPath]) {
                [[NSFileManager defaultManager]removeItemAtPath:dummyVideoPath error:nil];
            }
        }
        if (selectedFilterIndex == 1) {
            [self videoCaptureDone:recordedMoviePath];
        } else if (beforeSelectedFilterIndex == selectedFilterIndex) {
            [self videoCaptureDone:filteredMoviePath];
        }
        appDelegate.isVideoRecording = NO;
        if (isExporting) {
            [appDelegate uploadVideo];
        }
    } else {
        [appDelegate showNetworkIndicator];
        [appDelegate showActivityIndicatorInView:filtersView andText:@"Applying filter"];
        [filtersView bringSubviewToFront:discardVideoBtn];
    }
    TCEND
}

- (void)videoCaptureDone:(NSString *)filePath {
    TCSTART
    NSLog(@"Started");
    clickedOnNextButton = NO;
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:filePath]];
    UIImage *thumbNailImage = [player thumbnailImageAtTime:player.duration timeOption:MPMovieTimeOptionNearestKeyFrame];
    [player stop];
    NSLog(@"Ended");
    
    if ([self isNull:selectCoverFrameVC]) {
        selectCoverFrameVC = [[SelectCoverFrameViewController alloc]initWithNibName:@"SelectCoverFrameViewController" bundle:nil withThumbImage:thumbNailImage];
        selectCoverFrameVC.thumbImg = thumbNailImage;
    }
    selectCoverFrameVC.isLibraryVideo = libraryVideo;
    selectCoverFrameVC.filterStatus = selectedFilterIndex;
    selectCoverFrameVC.filePath = filePath;
    selectCoverFrameVC.recordedPath = recordedMoviePath;
    selectCoverFrameVC.superVC = superVC;
    [self.navigationController pushViewController:selectCoverFrameVC animated:YES];
    TCEND
}

#pragma mark Filters view Discard button actions
- (IBAction)onClickOfDiscardVideo:(id)sender {
    TCSTART
    [appDelegate removeNetworkIndicatorInView:filtersView];
    [appDelegate hideNetworkIndicator];
    fastFwdLabl.hidden = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Discard Video" message:@"Do you want to discard this video?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Ok", nil];
    [alert show];
    TCEND
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    TCSTART
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title caseInsensitiveCompare:@"Ok"] == NSOrderedSame) {
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:NO];
        [self removeAllVideoFilesFromDocuments];
        appDelegate.isVideoRecording = NO;
        if (isExporting) {
            [appDelegate uploadVideo];
        }
    }
    TCEND
}

- (void)removeAllVideoFilesFromDocuments {
    TCSTART
    [self cancelFilterVideoProcessing];
    appDelegate.isRecordingScreenDisplays = NO;
    if ([[NSFileManager defaultManager]fileExistsAtPath:recordedMoviePath]) {
        [[NSFileManager defaultManager]removeItemAtPath:recordedMoviePath error:nil];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:dummyVideoPath]) {
        [[NSFileManager defaultManager]removeItemAtPath:dummyVideoPath error:nil];
    }
    if ([[NSFileManager defaultManager]fileExistsAtPath:filteredMoviePath]) {
        [[NSFileManager defaultManager]removeItemAtPath:filteredMoviePath error:nil];
    }
    [superVC dismissViewControllerAnimated:YES completion:nil];

    TCEND
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    fastFwdLabl.hidden = YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
