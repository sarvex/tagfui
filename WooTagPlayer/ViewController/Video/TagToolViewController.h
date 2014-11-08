/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"
#import "Tag.h"

@class CustomMoviePlayerViewController;
@class FriendsViewController;

@interface TagToolViewController : UIViewController<UITextFieldDelegate,UIScrollViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,GPPSignInDelegate,FHSTwitterEngineAccessTokenDelegate,UITextViewDelegate,UIWebViewDelegate> {
    
    WooTagPlayerAppDelegate *appDelegate;
    
    IBOutlet UITextView *nameTextview;
    IBOutlet UITextField *linkField;
    
    IBOutlet UIButton *resetBtn;
    IBOutlet UIButton *publishBtn;
    IBOutlet UIButton *cancelBtn;
    
    IBOutlet UIButton *gPlusBtn;
    IBOutlet UIButton *twBtn;
    IBOutlet UIButton *fbBtn;
    IBOutlet UIButton *wtBtn;
    
    IBOutlet UILabel *colorLbl;
    IBOutlet UILabel *durationLbl;
    NSString *durationStr;
    IBOutlet UIScrollView *tagToolScrollView;
    IBOutlet UILabel *scrollViewBgLbl;
    
    IBOutlet UIView *tagDisplayTimeView;
    IBOutlet UIView *tagColorView;
    
    NSString *fbTagId;
    NSString *twTagId;
    NSString *gPlusTagId;
    NSString *wtId;
    
    IBOutlet UILabel *commentChars_Lbl_;
    
    FriendsViewController *friendsVC;
    IBOutlet UIButton *friendsVCCloseBtn;
    Tag *tag;
    
    //Divider Labels
    IBOutlet UILabel *dividerLbl1;
    IBOutlet UILabel *dividerLbl2;
    IBOutlet UILabel *dividerLbl3;
    IBOutlet UILabel *dividerLbl4;
    

    BOOL isViewModeUp;
    
    IBOutlet UIView *linkItView;
    IBOutlet UIWebView *linkwebView;
    IBOutlet UIButton *reloadBtn;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    BOOL isNetworkIndicator;
    IBOutlet UIButton *backLinkBtn;
    IBOutlet UIButton *fwdLinkBtn;

    IBOutlet UIView *helpScreen;
    IBOutlet UIImageView *helpArrowImgView;
    IBOutlet UIButton *helpBtn;
    IBOutlet UIScrollView *helpScrollview;
    IBOutlet UIPageControl *helpPageControl;
    
    NSMutableDictionary *wootagProductDetails;
}

@property (nonatomic,retain) CustomMoviePlayerViewController *customMoviePlayerController;
@property (nonatomic, readwrite) float videoPlaybacktime;
-(IBAction)onClickOfDisplayTime:(id)sender;
-(IBAction)onClickOfColor:(id)sender;
-(IBAction)onClickOfFB:(id)sender;
-(IBAction)onClickOfTW:(id)sender;
-(IBAction)onClickOfGPlus:(id)sender;
-(IBAction)onClickOfWT:(id)sender;
-(IBAction)onClickOfReset:(id)sender;
-(IBAction)onClickOfPublish:(id)sender;

-(IBAction)onClickOfSelectedTime:(id)sender;
-(IBAction)onClickOfSelectedColor:(id)sender;

-(IBAction)onClickOfCancel:(id)sender;

- (void)finishedPickingTWFriend:(NSString *)twId;
- (void)deletedTaggedFriendOfType:(NSString *)taggedType;
- (void)finishedPickingGPlusFriend:(NSString *)gPlusId;
- (void)finishedPickingWTFriend:(NSString *)wtId;
- (void)cancelWTVC;
- (void)finishedPickingFBFriend:(NSString *)fbId;

- (void)requestForTWFollowersList:(NSString *)pageNumber loadMore:(BOOL) loadMore;
- (void)updateTagToolObjects:(Tag *)tag;

- (IBAction)closeFriendsViewController:(id)sender;

- (IBAction)onClickOfTagToolLinkBtn;
- (IBAction)onClickOfLinkItBtn;
- (IBAction)onclickOfBackLinkBtn;
- (IBAction)onClickOfFwdLinkBtn;
- (IBAction)onClickOfReloadBtn:(id)sender;

- (IBAction)onClickOflinkViewCloseBtn:(id)sender;

- (IBAction)onClickOfHelpBtn:(id)sender;
- (IBAction)onClickOfHelpCloseBtn:(id)sender;
- (IBAction)helpPagechanged:(id)sender;
@end
