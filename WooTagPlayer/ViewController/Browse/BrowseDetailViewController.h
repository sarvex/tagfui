/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"
#import "AllCommentsViewController.h"
#import "VideoService.h"
#import "VideoModal.h"
#import "BrowseService.h"
#import "MainViewController.h"

@interface BrowseDetailViewController : UIViewController <UIScrollViewDelegate, VideoServiceDelegate, BrowseServiceDelegate> {
    WooTagPlayerAppDelegate *appDelegate;
    
    
    NSMutableArray *allBrowseVideosArray;
    NSInteger selectedIndex;
    VideoModal *selectedVideo;
    
    IBOutlet UIScrollView *allVideosScrollView;
    IBOutlet UIScrollView *viewScrollView;
    
    IBOutlet UIImageView *videoThumbPath;
    IBOutlet UIButton *playBtn;
    IBOutlet UILabel *dividerLabel;
    IBOutlet UILabel *dividerLbl;
    
    IBOutlet UIImageView *profilePic;
    IBOutlet UILabel *userNameLabel;
    IBOutlet UILabel *videoCreatedlbl;
    IBOutlet UILabel *videoViewsLabel;
    
    IBOutlet UILabel *numberOfTagsLabel;
    IBOutlet UILabel *numberOfLikesLabel;
    IBOutlet UILabel *numberOfCmntsLabel;
    
    IBOutlet UILabel *videoInfoBgLbl;
    IBOutlet UILabel *videoTitleLbl;
    IBOutlet UILabel *videoInfoLbl;

    IBOutlet UIButton *nextButton;
    IBOutlet UIButton *previousButton;
    
    AllCommentsViewController *allCmntsVC;
    
    NSInteger myOtherStuffPgNum;
    
    IBOutlet UILabel *loadingLbl;
    
    IBOutlet UILabel * headerLabl;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withVideosArray:(NSArray *)videosArray selectedIndex:(NSInteger)index;

- (IBAction)goBack:(id)sender;

- (IBAction)onClickOfNextButton:(id)sender;
- (IBAction)onClickOfPreviousButton:(id)sender;
- (IBAction)onClickOfShareButton:(id)sender;
- (IBAction)onClickOfLikeButton:(id)sender;
- (IBAction)onClickOfRememberMeButton:(id)sender;
- (IBAction)onClickOfPlayButton:(id)sender;

- (IBAction)onClickOfUserPic:(id)sender;

- (IBAction)onClickOfCommentButton:(id)sender;

- (void)allCommentsScreenDismissCalledSelectedIndexPath:(NSIndexPath *)indexPath andViewType:(NSString *)viewType;

- (void)playBackResponse:(NSDictionary *)results;
@end
