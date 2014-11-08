/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"
#import "VideoInfoViewController.h"

@interface TagAndLaterViewController : UIViewController {
    IBOutlet UIView *tagRLaterView;
    IBOutlet UIImageView *tagRLaterViewBgView;
    IBOutlet UILabel *tagLbl;
    WooTagPlayerAppDelegate *appDelegate;
    int clientVideoId;
    VideoInfoViewController *videoInfoVC;
}

@property (nonatomic, retain) UIImage *thumbImg;
@property (nonatomic, retain) NSString *filePath;
@property (nonatomic, retain) NSString *recordedPath;
@property (nonatomic, readwrite) float coverFrameValue;
@property (nonatomic,retain) id superVC;

- (IBAction)tag:(id)sender;
- (IBAction)onClickOfNext:(id)sender;
- (IBAction)back:(id)sender;
- (void)playerScreenDismissed;
- (void)clickedOnPlayerScreenBackButton;
@end
