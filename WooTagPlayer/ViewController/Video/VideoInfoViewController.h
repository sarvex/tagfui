/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"
#import "UICustomSwitch.h"
#import "RecordingViewController.h"
@class RecordingViewController;

@interface VideoInfoViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate,UITableViewDelegate, UITableViewDataSource, GPPSignInDelegate,FHSTwitterEngineAccessTokenDelegate> {
    
    IBOutlet UIView *headerView;
    
    IBOutlet UITextView *infoView;
    
    IBOutlet UICustomSwitch *publicSwitch;
    IBOutlet UICustomSwitch *privateFeedSwitch;
    IBOutlet UICustomSwitch *followersSwitch;
    
    
    WooTagPlayerAppDelegate *appDelegate;
    NSString *filePath;
    
    int clientVideoId;
    
    id superVC;
    int sharingType;
    BOOL isViewModeUp;
    
    IBOutlet UIImageView *videoThumbNail;
    UIImage *thumbImg;
    float coverFrameValue;

//    UIView *toastView;
    IBOutlet UIView *tagRLaterView;
    IBOutlet UIImageView *tagRLaterViewBgView;
    IBOutlet UILabel *tagLbl;
    
    IBOutlet UITableView *shareTableView;
    NSMutableDictionary *shareSocialDict;
    IBOutlet UIButton *uploadBtn;
    
    BOOL isLibraryVideo;
    int filterStatus;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil clientVideoId:(int)clientVideoId_;
@property (nonatomic, readwrite) BOOL isLibraryVideo;
@property (nonatomic, readwrite) int filterStatus;
@property (nonatomic, retain) UIImage *thumbImg;
@property (nonatomic, retain) NSString *filePath;
@property (nonatomic, retain) NSString *recordedPath;
@property (nonatomic, readwrite) float coverFrameValue;
@property (nonatomic, retain) id superVC;
@property (nonatomic, retain) id selectFRameVCRef;
- (void)shareToFrinedsByChangingSwitches:(id)sender;
//- (IBAction)tag:(id)sender;
//- (IBAction)onClickOfTagRLaterCancel:(id)sender;
//- (void)playerScreenDismissed;
- (IBAction)publish:(id)sender;
- (IBAction)cancel:(id)sender;
//- (void)clickedOnPlayerScreenBackButton;

@end
