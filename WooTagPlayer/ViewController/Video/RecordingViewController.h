/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */
#import <UIKit/UIKit.h>
#import "GPUImage.h"
#import "WooTagPlayerAppDelegate.h"
#import "VideoInfoViewController.h"

@class WooTagPlayerAppDelegate;

@interface RecordingViewController : UIViewController {
    GPUImageVideoCamera *videoCamera;
    
    IBOutlet GPUImageView *gpuImageView;
    
    GPUImageOutput<GPUImageInput> *filter;
    
    GPUImageMovieWriter *movieWriter;
    WooTagPlayerAppDelegate *appDelegate;
    
    //RecordView;
    IBOutlet UIView *recordingView;
    IBOutlet UILabel *timerLbl;
    IBOutlet UIButton *camPostionBtn;
    IBOutlet UILabel *recordFooterLbl;
    IBOutlet UIButton *cancelBtn;
    IBOutlet UIButton *recordBtn;
    IBOutlet UIButton *doneBtn;
    NSTimer *recordTimeUpdateTimer;
    
    NSString *recordedMoviePath;
    
    BOOL isExporting;
    
    //Instructions screen
    BOOL recordVideoCompleted;
    BOOL isRecording;
    
    // this for iOS7 view layout. When orientaiton view displays first that is portrait mode so in ViewDidLayout condition will be failed. 
    BOOL isOrientationViewDisplaysFirstTime;
    IBOutlet UIView *orientationView;
    IBOutlet UIImageView *orientationImgView;
    
    UIView *toastView;
}

@property (nonatomic, strong) MainViewController *caller;

- (IBAction)onClickOfCamButton:(id)sender;
- (IBAction)onClickOfCancelBtn:(id)sender;
- (IBAction)onClickOfDoneBtn:(id)sender;
- (IBAction)onClickOfRecordBtn:(id)sender;

@end
