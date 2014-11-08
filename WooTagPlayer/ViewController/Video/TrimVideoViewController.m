/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "TrimVideoViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoFilterPlayerViewController.h"

@interface TrimVideoViewController ()

@end

@implementation TrimVideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    TCSTART
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        if(UIApplicationWillResignActiveNotification != nil) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        }
        
        // On iOS 4.0+ only, listen for foreground notification
        if(UIApplicationDidBecomeActiveNotification != nil) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        }
    }
    return self;
    TCEND
}

- (void)applicationWillResignActive:(UIApplication *)application {
    TCSTART
    playButton.tag = 2;
    [self changePlayButton];
    TCEND
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    TCSTART
//    [moviePlayerController play];
    TCEND
}

- (void)viewDidLoad {
    TCSTART
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.height, appDelegate.window.frame.size.width - 20);
    videoPlayerMarker = [[UILabel alloc] init];
    videoPlayerMarker.layer.cornerRadius = 1;
    videoPlayerMarker.layer.masksToBounds = YES;
    videoPlayerMarker.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:videoPlayerMarker];
    tmpVideoPath = [self getFilePathToSaveTrimVideo];
    originalVideoPath = [self getFilePathToSavePickedVideo];
    TCEND
}

- (void)viewDidAppear:(BOOL)animated {
    TCSTART
    [super viewDidAppear:animated];
    TCEND
}

#pragma mark
- (void) viewDidLayoutSubviews {
    TCSTART
    if (CURRENT_DEVICE_VERSION >=7.0 && self.view.frame.size.height == appDelegate.window.frame.size.width) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.origin.y = -topBarOffset;
        self.view.bounds = viewBounds;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    TCEND
}


#pragma mark 
#pragma mark Filenames
- (NSString *)getFilePathToSaveTrimVideo {
    TCSTART
    NSString *directory = [appDelegate getApplicationDocumentsDirectoryAsString];
	directory = [directory stringByAppendingString:@"/Trim"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory])
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    NSString *clientVideoId = [appDelegate generateUniqueVideoId];
    if(![[NSFileManager defaultManager]fileExistsAtPath:[NSString stringWithFormat:@"%@/Video%@.mov", directory , clientVideoId]]) {
        return [NSString stringWithFormat:@"%@/Video%@.mov", directory , clientVideoId];
    } else {
        return [self getFilePathToSaveTrimVideo];
    }
    TCEND
}

- (NSString *)getFilePathToSavePickedVideo {
    TCSTART
    NSString *directory = [appDelegate getApplicationDocumentsDirectoryAsString];
	directory = [directory stringByAppendingString:@"/Picked"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory])
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    NSString *clientVideoId = [appDelegate generateUniqueVideoId];
    if(![[NSFileManager defaultManager]fileExistsAtPath:[NSString stringWithFormat:@"%@/Video%@.mov", directory , clientVideoId]]) {
        return [NSString stringWithFormat:@"%@/Video%@.mov", directory , clientVideoId];
    } else {
        return [self getFilePathToSavePickedVideo];
    }
    TCEND
}

#pragma mark
#pragma mark Gallery
- (void)openGallery {
    TCSTART
    appDelegate.isVideoRecording = YES;
    if (appDelegate.isVideoExporting) {
        isExporting = appDelegate.isVideoExporting;
        [appDelegate cancelExport];
    }
    originalVideoPath = [self getFilePathToSavePickedVideo];
    UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    [self presentViewController:imagePickerController animated:NO completion:nil];
    TCEND
}

#pragma mark ImagePicker Delegate methods.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:NO completion:^{
        [self deleteAllFiles];
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    TCSTART
    [picker dismissViewControllerAnimated:NO completion:^{
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:@"public.movie"]) {
            
            NSData *videoData = [NSData dataWithContentsOfURL:[info objectForKey:UIImagePickerControllerMediaURL]];
            BOOL success = [videoData writeToFile:originalVideoPath atomically:NO];
            appDelegate.isVideoRecording = NO;
            if (isExporting) {
                [appDelegate uploadVideo];
            }
            if (success) {
                NSString *tempPath = NSTemporaryDirectory();
                NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tempPath error:nil];
                NSArray *onlyMOVS = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.MOV'"]];
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                if (onlyMOVS) {
                    for (int i = 0; i < [onlyMOVS count]; i++) {
                        NSString *contentsOnly = [NSString stringWithFormat:@"%@%@", tempPath, [onlyMOVS objectAtIndex:i]];
                        [fileManager removeItemAtPath:contentsOnly error:nil];
                    }
                }
                [self initialiseVideoPlayerAndVideoTrimView];
            } else {
                [self openGalleryAgainAnythingWentWrong];
            }
        }
    }];//dismissing the camera view controlle
    
    TCEND
}

- (void)initialiseVideoPlayerAndVideoTrimView {
   TCSTART
    [self createAndConfigurePlayerWithURL:[NSURL fileURLWithPath:originalVideoPath] sourceType:MPMovieSourceTypeFile];
    
    videoTrimSlider = [[VideoTrimSlider alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 70 -((CURRENT_DEVICE_VERSION >= 7.0)?20:0), self.view.frame.size.width, 70) videoUrl:[NSURL fileURLWithPath:originalVideoPath] withDelegate:self];
    videoTrimSlider.topBorder.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
    videoTrimSlider.bottomBorder.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:videoTrimSlider];
    [self.view bringSubviewToFront:videoPlayerMarker];
    videoPlayerMarker.frame = CGRectMake(0, videoTrimSlider.frame.origin.y + 20, 3, 50);
    TCEND
}

- (void)openGalleryAgainAnythingWentWrong {
    TCSTART
    if ([[NSFileManager defaultManager] fileExistsAtPath:originalVideoPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:originalVideoPath error:nil];
    }
    [self openGallery];
    TCEND
}

#pragma mark
#pragma mark MPMoviePlayer
- (void)createAndConfigurePlayerWithURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType {
    TCSTART
    /* Create a new movie player object. */
    moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    
    if (moviePlayerController) {
        
        moviePlayerController.controlStyle = MPMovieControlStyleNone;
        
        /* Specify the URL that points to the movie file. */
        [moviePlayerController setContentURL:movieURL];
        
        /* If you specify the movie type before playing the movie it can result
         in faster load times. */
        [moviePlayerController setMovieSourceType:sourceType];
        /* Inset the movie frame in the parent view frame. */
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayBackDidFinish:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:moviePlayerController];
        
        [[moviePlayerController view] setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 73 - ((CURRENT_DEVICE_VERSION >= 7.0)?20:0))];
        
        [moviePlayerController view].backgroundColor = [UIColor blackColor];
        
        [self.view insertSubview:moviePlayerController.view atIndex:0];
        [moviePlayerController play];
        
        playButton.tag = 2;
        [self changePlayButton];
    }
    TCEND
}

- (IBAction)onclickOfPlaybutton:(id)sender {
    [self changePlayButton];
}

- (void)changePlayButton {
    TCSTART
    if (playButton.tag == 2) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [playButton setImage:[UIImage imageNamed:@"MypageVideoPlayBtn"] forState:UIControlStateNormal];
        [moviePlayerController pause];
        playButton.tag = 1;
        [markerTimer invalidate];
        markerTimer = nil;
        CGRect videoMarkerFrmae = videoPlayerMarker.frame;
        videoMarkerFrmae.origin.x = 0;
        videoPlayerMarker.frame = videoMarkerFrmae;
    } else {
        [playButton setImage:[UIImage imageNamed:@"s"] forState:UIControlStateNormal];
        moviePlayerController.initialPlaybackTime = startTime;
        moviePlayerController.currentPlaybackTime = startTime;
        playButton.tag = 2;
        if (stopTime > 0.0) {
            NSLog(@"TIME:%f",(stopTime-startTime));
            [self performSelector:@selector(playerPause) withObject:nil afterDelay:(stopTime-startTime)];
        }
        
        [moviePlayerController play];
        if (markerTimer == nil) {
            markerTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(changeSliderPosition) userInfo:nil repeats:YES ];
        }
    }
    TCEND
}

- (void)changeSliderPosition {
    TCSTART
    CGFloat originX = (moviePlayerController.currentPlaybackTime - startTime) * ((appDelegate.window.frame.size.height > 480)?18.9:16);
    if (originX < 0) {
        originX = originX * -1;
    }
    if (originX > (stopTime * ((appDelegate.window.frame.size.height > 480)?18.9:16))) {
        originX = (stopTime * ((appDelegate.window.frame.size.height > 480)?18.9:16));
    }
    
//    NSLog(@"CurrentPlaybakcTime:%f StartTime:%f originX:%f",moviePlayerController.currentPlaybackTime,startTime,originX);
    CGRect videoMarkerFrmae = videoPlayerMarker.frame;
    videoMarkerFrmae.origin.x = originX;
    videoPlayerMarker.frame = videoMarkerFrmae;
    TCEND
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    TCSTART
    
    NSNumber *reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
	switch ([reason integerValue]) {
            /* The end of the movie was reached. */
		case MPMovieFinishReasonPlaybackEnded:
            playButton.tag = 2;
            [self changePlayButton];
			break;
            
            /* An error was encountered during playback. */
		case MPMovieFinishReasonPlaybackError:
            
			break;
            
            /* The user stopped playback. */
		case MPMovieFinishReasonUserExited:
            
			break;
            
		default:
			break;
	}
    
    TCEND
}


#pragma mark
#pragma mark Next and Cancel Actions
- (IBAction)onClickOfCancel:(id)sender {
    TCSTART
    [self deleteAllFiles];
    [self dismissViewControllerAnimated:YES completion:nil];
    TCEND
}
- (void)deleteAllFiles {
    TCSTART
    [markerTimer invalidate];
    markerTimer = nil;
    [self removeObservers];
    appDelegate.isRecordingScreenDisplays = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:originalVideoPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:originalVideoPath error:nil];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:tmpVideoPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:tmpVideoPath error:nil];
    }
    TCEND
}
- (IBAction)onClickOfNext:(id)sender {
    TCSTART
    playButton.tag = 2;
    [self changePlayButton];
    if (videoSelectedForTriming) {
        [self showTrimmedVideo];
    } else {
        [self pushToFiltersScreenWithVideoPath:originalVideoPath isOriginalFile:YES];
    }
    TCEND
}

- (void)showTrimmedVideo {
    TCSTART
    [appDelegate showActivityIndicatorInView:self.view andText:@"Triming"];
    [appDelegate showNetworkIndicator];
    
    appDelegate.isVideoRecording = YES;
    if (appDelegate.isVideoExporting) {
        isExporting = appDelegate.isVideoExporting;
        [appDelegate cancelExport];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:tmpVideoPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:tmpVideoPath error:nil];
    }
    
    NSURL *videoFileUrl = [NSURL fileURLWithPath:originalVideoPath];
    
    AVAsset *anAsset = [[AVURLAsset alloc] initWithURL:videoFileUrl options:nil];
    
    // Implementation continues.
    
    NSURL *furl = [NSURL fileURLWithPath:tmpVideoPath];
    exportSession = [[AVAssetExportSession alloc]
                     initWithAsset:anAsset presetName:AVAssetExportPresetHighestQuality];
    exportSession.outputURL = furl;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    Float64 duratn = stopTime - startTime;
    if (duratn > 30.0) {
        duratn = 30.0;
    }
    CMTime start = CMTimeMakeWithSeconds(startTime, anAsset.duration.timescale);
    CMTime duration = CMTimeMakeWithSeconds(duratn, anAsset.duration.timescale);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    exportSession.timeRange = range;
    
    [exportSession exportAsynchronouslyWithCompletionHandler: ^{
        [appDelegate removeNetworkIndicatorInView:self.view];
        [appDelegate hideNetworkIndicator];
        
        appDelegate.isVideoRecording = NO;
        if (isExporting) {
            [appDelegate uploadVideo];
        }
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
//                    [self openGalleryAgainAnythingWentWrong];
                });
            }
                
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Export canceled");
                break;
            default:
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self pushToFiltersScreenWithVideoPath:tmpVideoPath     isOriginalFile:NO];
                });
                
                break;
        }
    }];
    TCEND
}


- (void)removeObservers {
    TCSTART
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayerController];
    [moviePlayerController stop];
    moviePlayerController = nil;
    
    TCEND
}

- (void)pushToFiltersScreenWithVideoPath:(NSString *)path isOriginalFile:(BOOL)isOriignalFile {
    TCSTART
    [self removeObservers];
    [playButton setImage:[UIImage imageNamed:@"d"] forState:UIControlStateNormal];
    if (!isOriignalFile) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:originalVideoPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:originalVideoPath error:nil];
        }
        
    } else {
        if ([[NSFileManager defaultManager] fileExistsAtPath:tmpVideoPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:tmpVideoPath error:nil];
        }
    }
    
    VideoFilterPlayerViewController *filtePlayerVC = [[VideoFilterPlayerViewController alloc] initWithNibName:@"VideoFilterPlayerViewController" bundle:nil recordedMoviePath:path isLibraryVideo:YES];
    filtePlayerVC.superVC = self;
    [self.navigationController pushViewController:filtePlayerVC animated:YES];
    
    TCEND
}

#pragma mark
#pragma mark - VideoTrimSliderDelegate
- (void)videoRange:(VideoTrimSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition
{
    TCSTART
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    startTime = leftPosition;
    stopTime = rightPosition;
    NSLog(@"Start time :%f, StopTime:%f",startTime,stopTime);
    videoSelectedForTriming = YES;
    moviePlayerController.endPlaybackTime = stopTime;
//    if ((stopTime - startTime) > 0) {
//        [self performSelector:@selector(playerPause) withObject:nil afterDelay:(stopTime - startTime)];
//    }
    playButton.tag = 2;
    [self changePlayButton];
    TCEND
}

- (void)playerPause {
    TCSTART
    playButton.tag = 2;
    [self changePlayButton];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    TCEND
}

//- (void)viewDidUnload {
//    [self setMyActivityIndicator:nil];
//    [self setTrimBtn:nil];
//    [super viewDidUnload];
//}

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
