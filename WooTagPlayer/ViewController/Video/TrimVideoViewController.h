/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"
#import "VideoTrimSlider.h"
#import <MediaPlayer/MediaPlayer.h>

@interface TrimVideoViewController : UIViewController<VideoTrimSliderDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    
    WooTagPlayerAppDelegate *appDelegate;
    VideoTrimSlider *videoTrimSlider;
    AVAssetExportSession *exportSession;
    NSString *originalVideoPath;
    NSString *tmpVideoPath;
    CGFloat startTime;
    CGFloat stopTime;
    UIActivityIndicatorView *myActivityIndicator;
    
    BOOL videoSelectedForTriming;
    MPMoviePlayerController *moviePlayerController;
    
    BOOL isExporting;
    
    IBOutlet UIButton *nextBtn;
    IBOutlet UIButton *cancelBtn;
    IBOutlet UILabel *topLbl;
    IBOutlet UIButton *playButton;
    
    UILabel *videoPlayerMarker;
    NSTimer *markerTimer;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (IBAction)onClickOfCancel:(id)sender;
- (IBAction)onClickOfNext:(id)sender;
- (void)openGallery;
- (IBAction)onclickOfPlaybutton:(id)sender;
@end
