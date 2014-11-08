/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */
#import "RecordingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VideoFilterPlayerViewController.h"

@implementation RecordingViewController
@synthesize caller;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   
    // for start up orientation
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        recordVideoCompleted = NO;
    } else {
        recordVideoCompleted = YES;
    }
    
//    recordVideoCompleted = YES;
    if (self) {
        if(UIApplicationWillResignActiveNotification != nil) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        }
    }
    return self;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    TCSTART
    if (isRecording) {
        [self onClickOfRecordBtn:recordBtn];
    }
    TCEND
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    TCSTART

    TCEND
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    TCSTART
    [super viewDidLoad];
    appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //Recording view;
    recordFooterLbl.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
    doneBtn.enabled = NO;
    
    [self initialiseVideoCamera];
   
    recordVideoCompleted = NO;
    
    [self addOrientationViewToScreen];
    [self hideORUnhideOrientationView];
    isRecording = NO;
    TCEND
}

- (void)addOrientationViewToScreen {
    TCSTART
    isOrientationViewDisplaysFirstTime = YES;
    orientationView.frame = CGRectMake(0, 0, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height-20);
    if (appDelegate.window.frame.size.height > 480) {
        orientationImgView.image = [UIImage imageNamed:@"RecordingInstructionScreeniPhone5"];
    } else {
        orientationImgView.image = [UIImage imageNamed:@"RecordingInstructionScreen"];
    }
    [self.view addSubview:orientationView];
    
    TCEND
}

- (void)addToastViewtoViewWithString:(NSString *)message {
    TCSTART
    if ((![appDelegate.ftue.startRecord boolValue] || ![appDelegate.ftue.recording boolValue] || ![appDelegate.ftue.pause boolValue]) && ![appDelegate.ftue.videoUploaded boolValue]) {
        toastView = [appDelegate getToastViewWithMessageText:message andFrame:CGRectMake((appDelegate.window.frame.size.height - 324)/2, 0, 324, 50)];
    }  else {
        [self removeToastViewFromParentView];
    }
        
    if ([self isNotNull:toastView]) {
        [self.view addSubview:toastView];
        [self.view bringSubviewToFront:toastView];
    }
    TCEND
}

- (void)hideORUnhideOrientationView {
    TCSTART
    if (![appDelegate.ftue.startRecord boolValue]) {
        [self addToastViewtoViewWithString:kStartRecord];
    }
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        orientationView.hidden = NO;
        toastView.hidden = YES;
        //Cancel button should be work when clicking on the camera first time when screen on portrait mode
        [self.view bringSubviewToFront:recordingView];
        recordBtn.userInteractionEnabled = NO;
        camPostionBtn.userInteractionEnabled = NO;
        videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    } else {
        orientationView.hidden = YES;
        toastView.hidden = NO;
        videoCamera.outputImageOrientation = [[UIDevice currentDevice] orientation];
        
        [self.view bringSubviewToFront:orientationView];
        recordBtn.userInteractionEnabled = YES;
        camPostionBtn.userInteractionEnabled = YES;
    
    }
    TCEND
}

- (void) viewDidLayoutSubviews {
    if (CURRENT_DEVICE_VERSION >= 7.0  && (self.view.frame.size.height == appDelegate.window.frame.size.width || (self.view.frame.size.height == appDelegate.window.frame.size.height && isOrientationViewDisplaysFirstTime))) {
        isOrientationViewDisplaysFirstTime = NO;
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.origin.y = -topBarOffset;
        self.view.bounds = viewBounds;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (void)startRecording {
    TCSTART
    isRecording = YES;
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                // Microphone enabled code
                NSLog(@"Microphone is enabled..");
                videoCamera.audioEncodingTarget = movieWriter;
                movieWriter.shouldPassthroughAudio = YES;
            } else {
                // Microphone disabled code
                NSLog(@"Microphone is disabled..");
            }
        }];
    } else {
        videoCamera.audioEncodingTarget = movieWriter;
        movieWriter.shouldPassthroughAudio = YES;
    }
    [movieWriter startRecording];
    TCEND
}

- (void)initialiseVideoCamera {
    TCSTART
    timerLbl.text = 0;
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    videoCamera.outputImageOrientation = UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
    videoCamera.horizontallyMirrorFrontFacingCamera = NO;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;
//    videoCamera.frameRate = 30;
    filter = [[GPUImageFilter alloc] init];
    [videoCamera addTarget:filter];
    
    GPUImageView *filterView = (GPUImageView *)gpuImageView;
    [filter addTarget:filterView];
    
    filterView.fillMode = kGPUImageFillModeStretch;
    recordedMoviePath = [self getFilePathToSaveRecordedVideo];
    
    unlink([recordedMoviePath UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:recordedMoviePath];
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake((appDelegate.window.frame.size.height) * 2, (appDelegate.window.frame.size.width) * 2)];
    
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                // Microphone enabled code
                NSLog(@"Microphone is enabled..");
                videoCamera.audioEncodingTarget = movieWriter;
                movieWriter.shouldPassthroughAudio = YES;
            }
            else {
                // Microphone disabled code
                NSLog(@"Microphone is disabled..");
                [[[UIAlertView alloc] initWithTitle:@"Please Allow Access"
                                            message:@"Allowing access to the Microphone lets you record sound for your videos. \n Please go to settings > Privacy > Microphone to allow Wootag to record with sound."
                                           delegate:nil
                                  cancelButtonTitle:@"Ok,I understand"
                                  otherButtonTitles:nil] show];
            }
        }];
    } else {
        videoCamera.audioEncodingTarget = movieWriter;
        movieWriter.shouldPassthroughAudio = YES;
    }
    
    [filter addTarget:movieWriter];
    
    [videoCamera startCameraCapture];
    timerLbl.text = 0;
    TCEND
}

- (void)scheduleTimerToUpdateRecordingTime {
    TCSTART
    if ([self isNull:recordTimeUpdateTimer]) {
        recordTimeUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                 target:self
                                                               selector:@selector(timerFireMethod:)
                                                               userInfo:nil
                                                                repeats:YES];
    }
    TCEND
}

- (void)timerFireMethod:(NSTimer*)theTimer {
    TCSTART
        int currentTime = [timerLbl.text intValue];
        if (currentTime == 29) {
            [theTimer invalidate];
            theTimer = nil;
            [self onClickOfDoneBtn:doneBtn];
        } else {
            currentTime++;
            timerLbl.text = [NSString stringWithFormat:@"%d",currentTime];
        }
    TCEND
}

- (NSString *)getFilePathToSaveRecordedVideo {
    TCSTART
    NSString *directory = [appDelegate getApplicationDocumentsDirectoryAsString];
	directory = [directory stringByAppendingString:@"/Recorded"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory])
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    NSString *clientVideoId = [appDelegate generateUniqueVideoId];
    if(![[NSFileManager defaultManager]fileExistsAtPath:[NSString stringWithFormat:@"%@/Video%@.mov", directory , clientVideoId]]) {
        return [NSString stringWithFormat:@"%@/Video%@.mov", directory , clientVideoId];
    } else {
        return [self getFilePathToSaveRecordedVideo];
    }
    TCEND
}

- (IBAction)onClickOfCamButton:(id)sender {
    TCSTART
    [videoCamera rotateCamera];
    if (videoCamera.cameraPosition == AVCaptureDevicePositionBack) {
        [camPostionBtn setImage:[UIImage imageNamed:@"camera_r"] forState:UIControlStateNormal];
    }
    else {
        [camPostionBtn setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    }
    
    TCEND
}

- (IBAction)onClickOfCancelBtn:(id)sender {
    TCSTART
    appDelegate.isVideoRecording = NO;
    appDelegate.isRecordingScreenDisplays = NO;
    [recordTimeUpdateTimer invalidate];
    recordTimeUpdateTimer = nil;
    [filter removeTarget:movieWriter];
    videoCamera.audioEncodingTarget = nil;
    [videoCamera stopCameraCapture];
    [movieWriter cancelRecording];
    if ([[NSFileManager defaultManager]fileExistsAtPath:recordedMoviePath]) {
        [[NSFileManager defaultManager]removeItemAtPath:recordedMoviePath error:nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    if (isExporting) {
        [appDelegate uploadVideo];
    }
    NSLog(@"Movie canceled");
    TCEND
}

- (IBAction)onClickOfDoneBtn:(id)sender {
    TCSTART
    appDelegate.isVideoRecording = NO;
    isRecording = NO;
    recordVideoCompleted = YES;
    [recordTimeUpdateTimer invalidate];
    recordTimeUpdateTimer = nil;
    [videoCamera stopCameraCapture];
    
    [videoCamera removeTarget:movieWriter];
    [filter removeTarget:movieWriter];
    videoCamera.audioEncodingTarget = nil;
    [movieWriter finishRecording];
    
    movieWriter = nil;
    filter = nil;
    
    if (isExporting) {
        [appDelegate uploadVideo];
    }
    
    VideoFilterPlayerViewController *filtePlayerVC = [[VideoFilterPlayerViewController alloc] initWithNibName:@"VideoFilterPlayerViewController" bundle:nil recordedMoviePath:recordedMoviePath isLibraryVideo:NO];
    filtePlayerVC.superVC = self;
    [self.navigationController pushViewController:filtePlayerVC animated:YES];
   TCEND
}

- (IBAction)onClickOfRecordBtn:(id)sender {
    TCSTART
    if (recordBtn.tag == 1 || recordBtn.tag == 10) {
        appDelegate.isVideoRecording = YES;
        if (appDelegate.isVideoExporting) {
            isExporting = appDelegate.isVideoExporting;
            [appDelegate cancelExport];
        }
        if (recordBtn.tag == 10) {
            appDelegate.ftue.startRecord = [NSNumber numberWithBool:YES];
            [self removeToastViewFromParentView];
            [self startRecording];
            if (![appDelegate.ftue.recording boolValue]) {
                [self addToastViewtoViewWithString:kRecording];
            }
            appDelegate.ftue.recording = [NSNumber numberWithBool:YES];
        } else {
            [self removeToastViewFromParentView];
            movieWriter.paused = NO;
        }
        [recordBtn setImage:[UIImage imageNamed:@"Pause"] forState:UIControlStateNormal];
        doneBtn.enabled = YES;
        [self scheduleTimerToUpdateRecordingTime];
        recordBtn.tag = 2;
        isRecording = YES;
    } else {
        appDelegate.isVideoRecording = NO;
        [self removeToastViewFromParentView];
        if (![appDelegate.ftue.pause boolValue]) {
            [self addToastViewtoViewWithString:kPause];
        }
        appDelegate.ftue.pause = [NSNumber numberWithBool:YES];
        movieWriter.paused = YES;
        recordBtn.tag = 1;
        [recordBtn setImage:[UIImage imageNamed:@"Record_f"] forState:UIControlStateNormal];
        doneBtn.enabled = NO;
        [recordTimeUpdateTimer invalidate];
        recordTimeUpdateTimer = nil;
        isRecording = NO;
        if (isExporting) {
            [appDelegate uploadVideo];
        }
    }
    [[DataManager sharedDataManager] saveChanges];
    TCEND
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotate {
    if (!recordVideoCompleted) {
        return YES;
    } else {
        return NO;
    }
}

- (NSUInteger)supportedInterfaceOrientations {
    if (!recordVideoCompleted) {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
    } else {
        return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
    }
}

// Returns interface orientation masks.
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (!recordVideoCompleted) {
        if (CURRENT_DEVICE_VERSION >= 7.0) {
            return (UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight);
        } else {
            if (orientationView.hidden) {
                return UIInterfaceOrientationLandscapeLeft;
            } else {
                return UIInterfaceOrientationPortrait;
            }
        }
    } else {
        return UIInterfaceOrientationLandscapeLeft ;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (!recordVideoCompleted) {
        if (interfaceOrientation == UIInterfaceOrientationPortrait ||  interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            return YES;
        } else {
            return NO;
        }
    } else {
        if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            return YES;
        } else {
            return NO;
        }
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (!recordVideoCompleted) {
        if (isRecording) {
            [self onClickOfRecordBtn:recordBtn];
        }
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            orientationView.hidden = YES;
            toastView.hidden = NO;
        } else {
            orientationView.hidden = NO;
            toastView.hidden = YES;
        }
        if (!recordBtn.isUserInteractionEnabled) {
            [self.view bringSubviewToFront:orientationView];
            recordBtn.userInteractionEnabled = YES;
            camPostionBtn.userInteractionEnabled = YES;
        }
        
        if (!orientationView.hidden) {
            [self.view bringSubviewToFront:recordingView];
            recordBtn.userInteractionEnabled = NO;
            camPostionBtn.userInteractionEnabled = NO;
        }
    }
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    } else {
        videoCamera.outputImageOrientation = (UIInterfaceOrientation)[[UIDevice currentDevice] orientation];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (orientationView.hidden) {
        [self removeToastViewFromParentView];
    }
}

- (void)removeToastViewFromParentView {
    [toastView removeFromSuperview];
    toastView = nil;
}
@end
