/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"
#import "VideoInfoViewController.h"

@interface SelectCoverFrameViewController : UIViewController {
    IBOutlet UIImageView *thumbImageView;
    IBOutlet UIView *framesView;

    Float64 selectedThumbTime;
    WooTagPlayerAppDelegate *appDelegate;
    VideoInfoViewController *videoInfoVC;
    
    IBOutlet UIImageView *selectedFrameImgView;
    
    int clientVideoId;
    BOOL firstTime;
    BOOL clickedOnNext;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withThumbImage:(UIImage *)image_;
@property (nonatomic, readwrite) BOOL isLibraryVideo;
@property (nonatomic, readwrite) int filterStatus;
@property (nonatomic, retain) UIImage *thumbImg;
@property (nonatomic, retain) NSString *filePath;
@property (nonatomic, retain) NSString *recordedPath;
@property (nonatomic,retain) id superVC;

- (IBAction)onClickOfBackBtn:(id)sender;
- (IBAction)onClickOFNextBtn:(id)sender;
- (void)playerScreenDismissed;
- (void)clickedOnPlayerScreenBackButton;
- (void)videoInfoScreenBackClicked;
@end
