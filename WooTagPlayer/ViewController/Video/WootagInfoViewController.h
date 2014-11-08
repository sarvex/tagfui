/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "CustomMoviePlayerViewController.h"
#import "WooTagPlayerAppDelegate.h"

@interface WootagInfoViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate> {
    
    IBOutlet UIButton *closeBtn;
    
    IBOutlet UIView *productInfoView;
    IBOutlet UIImageView *productImgView;
    IBOutlet UILabel *productName;
    IBOutlet UILabel *productDesc;
    IBOutlet UILabel *productPrice;
    IBOutlet UILabel *currencyLabel;
    
    IBOutlet UIButton *imInterestedBtn;
    
    CustomMoviePlayerViewController *customMVPlayer;
    WooTagPlayerAppDelegate *appDelegate;
    
    Tag *tag;
    VideoModal *playingVideo;
    
    BOOL isViewMoveup;
}

@property (nonatomic, retain) CustomMoviePlayerViewController *customMVPlayer;
- (IBAction)onClickOfImInterestedBtn:(id)sender;
- (void)onClickOfBuyBtnWithDict:(NSMutableDictionary *)parmasDict;
- (IBAction)onClickOfCloseBtn:(id)sender;

- (void)updateTagDetails:(Tag *)tag_ andVideo:(VideoModal *)video;
@end
