/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "GPUImage.h"
#import "WooTagPlayerAppDelegate.h"
#import "RecordingViewController.h"
#import "SelectCoverFrameViewController.h"

@interface VideoFilterPlayerViewController : UIViewController<GPUImageMovieWriterDelegate> {
    GPUImageMovie *movieFile;
    GPUImageMovieWriter *movieWriterFilter;
    GPUImageFilter *rgbFilter;
    WooTagPlayerAppDelegate *appDelegate;
   
    NSString *filteredMoviePath;
    NSString *recordedMoviePath;
    BOOL completedFiltering;
    BOOL clickedOnNextButton;
    
    //These two variables is to play normal video and if user selects same filter that he selects recently. In these two cases no need to apply filter to recorded video.
    NSString *dummyVideoPath;
    BOOL isdummyVideoPlaying;
    
    IBOutlet GPUImageView *gpuImageView;
    IBOutlet UIView *filtersView;
    IBOutlet UIButton *discardVideoBtn;
    
    IBOutlet UIScrollView *filtersScrollView;
    
    int selectedFilterIndex;
    int beforeSelectedFilterIndex;
    
    //Video will start when user selects filter until then need to show first frame of recorded video
    IBOutlet UIImageView *thumbImageView;
    
    SelectCoverFrameViewController *selectCoverFrameVC;
    BOOL isExporting;
//    UIView *toastView;
    IBOutlet UILabel *fastFwdLabl;
    BOOL soundenable;
    
    
    // Picked video from Library orientation and natural size
    CGAffineTransform videoTransform;
    AVAssetTrack *videoAssetTrack;
    UIInterfaceOrientation videoOrientaiton;
    BOOL libraryVideo;
}
@property (nonatomic, retain)id superVC;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil recordedMoviePath:(NSString *)filePath isLibraryVideo:(BOOL)isLibraryVideo;

- (IBAction)onClickOfNextBtn:(id)sender;
- (IBAction)onClickOfDiscardVideo:(id)sender;
@end
