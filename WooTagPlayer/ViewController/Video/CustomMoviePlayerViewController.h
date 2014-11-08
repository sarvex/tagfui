/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "VideoService.h"
#import "TagToolViewController.h"
#import "CustomButton.h"
#import "WooTagPlayerAppDelegate.h"
#import "TagMarkerView.h"
#import "AllCommentsViewController.h"
#import "VideoModal.h"
#import "PlayerProgressView.h"
#import "UICustomSwitch.h"
#import "TagLabelView.h"

#import "WootagInfoViewController.h"

@interface CustomMoviePlayerViewController : UIViewController<UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate,GPPShareDelegate,UITextViewDelegate,FHSTwitterEngineAccessTokenDelegate,GPPSignInDelegate,UIWebViewDelegate,VideoServiceDelegate,CustomLabelDelegate> {
  
    WooTagPlayerAppDelegate *appDelegate;
    
    MPMoviePlayerController *moviePlayerController;
   
    IBOutlet UIView *playerTopView;
    IBOutlet UIView *playerBottomView;
    IBOutlet UIView *playerSettingsView;
    IBOutlet UIView *taggedUserDetailsView;
    IBOutlet UIView *optionsView;
    IBOutlet UIButton *playPauseBtn;
    
    IBOutlet UIButton *playerBackBtn;
    IBOutlet UILabel *playerTagLabel;
    //Settings View
    IBOutlet UICustomSwitch *tagSwitch;
    BOOL canDisplayTags;
    IBOutlet UICustomSwitch *editSwitch;
//    IBOutlet UILabel *privacyLbl;
//    IBOutlet UIButton *settingsViewEditBtn;
    
    //Tag Marker
    TagMarkerView *tagMarkerView;
    CGPoint touchPoint;
    IBOutlet UIButton *cancelTagMarkerBtn;
    IBOutlet UIButton *confirmTagMarkerBtn;

    //TagTool
    IBOutlet UIView *tagToolView;
    
    TagToolViewController *tagToolVC;
    
    //BottomView
    IBOutlet UIButton *settingsBtn;
    IBOutlet UIButton *homeBtn;
    IBOutlet UISlider *videoProgressSlider;
    IBOutlet PlayerProgressView *playerBufferView;
    IBOutlet UILabel *playTimeLbl;
    
    NSTimer *markerDisplayTimer;
    NSTimer *sliderTimer;
    
    float mLastScale;
    float mCurrentScale;
    
    VideoModal *video;
    NSString *videoFilePath;
    NSString *clientVideoId;
    
    //VideoplayerTopView
    IBOutlet UILabel *ownerName;
    IBOutlet UIImageView *videoOwnerPic;
    IBOutlet UIButton  *topViewTagBtn;
    IBOutlet UIButton  *topViewLikeBtn;
    IBOutlet UIButton  *topViewCmntBtn;
    IBOutlet UIButton  *topViewShareBtn;
    
    //taggedUserDetailsView
    IBOutlet UIView *userInfoBgView;
    IBOutlet UILabel *userName;
    IBOutlet UIImageView *userPic;
    IBOutlet UIButton *addFriendBtn;
    IBOutlet UIButton *pageLikeBtn;
    IBOutlet UIButton *fbPageCommentBtn;
    IBOutlet UITableView *aboutFriendTableView;
    IBOutlet UIImageView *detailsViewBannerImgView;
    IBOutlet UILabel *background;
    IBOutlet UIButton *socialMessageBtn;
    IBOutlet UIButton *birthDayMsgBtn;
    IBOutlet UIButton *shareVideoBtn;
    IBOutlet UIImageView *onlineDotImgView;
    IBOutlet UILabel *onlineLbl;
    
    IBOutlet UIWebView *likePageWebview;
    IBOutlet UIButton *likePageWebviewCloseBtn;
    
    NSString *taggedUserType;
    NSString *taggedTWId;
    NSString *taggedGPlusId;
    NSString *taggedFBId;
    
    float videoCurrentPalyBackTimeBeforeLinkBtnclicked;
    
    //Social Messaging;
    IBOutlet UIView *customMessageView;
   IBOutlet UITextView *messageTextView;
    
    NSMutableDictionary *taggedUserDetialsDict;
    
    NSMutableArray *createdTagsArray;
    
    //Link Webview
    IBOutlet UIView *webviewBackgroundView;
    IBOutlet UIWebView *linkWebView;
    IBOutlet UIButton *reloadBtn;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    BOOL isNetworkIndicator;
    IBOutlet UIButton *backLinkBtn;
    IBOutlet UIButton *fwdLinkBtn;
    IBOutlet UIButton *webViewShareBtn;
    
    BOOL isFrameSet;
    BOOL isPlaying;
    
    UIView *loadingView;
    
    AllCommentsViewController *allCmntsVC;
    BOOL playingFirstTime;
    
    BOOL showInstructnScreen;
    
    int socailTaggedUserScenarioType;

    UIView *toastView;
//    IBOutlet UIView *othersVideoToastView;
    BOOL isOtherVCSPresented;
    BOOL isFirstTimeOpened;
    //To check social contacts tagging and share to those contacts
    NSString *publishClientTagId;
    
    
    // open player for playback
    IBOutlet UIImageView *ownerDetailsBgImgView;
    //Before video upload to create tag
    IBOutlet UILabel *ownerDetalisBgLbl;
    
    // Introzone view for others video
    IBOutlet UIView *introzoneView;
    IBOutlet UILabel *introZoneLbl1;
    IBOutlet UILabel *introZoneLbl2;
    
    WootagInfoViewController *wootagInfoVC;
}
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) id caller;
//
//@property (nonatomic,retain)Video *video;
//@property (nonatomic,retain)NSString *videoFilePath;
//@property (nonatomic,retain)NSString *clientVideoId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil video:(VideoModal *)video_ videoFilePath:(NSString *)videoFilePath_ andClientVideoId:(NSString *)clientVideoId_ showInstrcutnScreen:(BOOL)show;

//Playback Controls
-(IBAction)onClickOfPlayPauseBtn;
-(IBAction) onClickOfStopBtn:(UIButton *)sender;
-(IBAction)onClickOfSettingsBtn;

//Settings Actions
-(IBAction)tagSettingsSwitchChanged:(id)sender;
-(IBAction)editSettingsSwitchChanged:(id)sender;
//-(IBAction)onClickOfPrivacySettingsBtn:(id)sender;

//Player RightView button Actions
-(IBAction)onClickOfShareBtn:(id)sender;
-(IBAction)onClickOfLikeBtn:(id)sender;
-(IBAction)onClickOfCommentBtn:(id)sender;
-(IBAction)onClickOfTagBtn:(id)sender;

-(IBAction)onClickOfConfirmTagMarker:(id)sender;
-(IBAction)onClickOfCancelTagMarker:(id)sender;


- (void)onClickOfTagMarkerViewTwitterBtn:(id)sender;
- (void)onClickOfTagMarkerViewFacebookBtn:(id)sender;
- (void)onClickOfTagMarkerViewGPlusBtn:(id)sender;
- (void)onClickOfTagMarkerViewWTBtn:(id)sender;
- (void)onClickOfOpenLink:(CustomButton *)sender;
- (void)onClickOfDeleteTag:(id)sender;

- (IBAction)onclickOfAddFriendbutton:(id)sender;
- (IBAction)onclickOfDetailsViewCloseBtn:(id)sender;
- (IBAction)sendMessageButton:(id)sender;
- (IBAction)onClickOfBirthDayMessageButton:(id)sender;
- (IBAction)onClickOfShareVideoButton:(id)sender;
- (IBAction)onclickOfSocialMessgeButton:(id)sender;
//- (IBAction)onClickOfUpdateStatusBtn:(id)sender;

- (void)addTagsResponseForVideoCompleted:(BOOL)tagAdded andResults:(NSDictionary *)results;
- (void)didFailAddingTags;
- (void)deleteTagsResponseWithTagId:(NSNumber *)tagid;

- (void)openTagLinkStr:(NSString *)link andSender:(CustomButton *)sender ;

//- (void)addTagsResponse:(NSDictionary *)results;
//- (void)deleteTagsResponseWithTagId:(NSNumber *)tagid;
//- (void)updateTagResponse:(NSDictionary *)results
- (IBAction)onClickOfWebviewCloseBtn:(id)sender;
- (IBAction)onclickOfBackLinkBtn;
- (IBAction)onClickOfFwdLinkBtn;
- (IBAction)onClickOfReloadBtn:(id)sender;

- (void)allCommentsScreenDismissCalledSelectedIndexPath:(NSIndexPath *)indexPath andViewType:(NSString *)viewType;
- (void)linkItWebviewLoadErrorWithPlaybackTime:(float)currentplayTime;

- (IBAction)onClickOfPageLikeBtn;
- (IBAction)onclickOfFacebookPagecommentBtn;
- (IBAction)onClickOflikePageWebviewCloseBtn;

- (void)onClickOfCloseBtnOfWootagProductInfoVC;
@end
