/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"
#import "AllCommentsViewController.h"

@interface VideoDetailsPageViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, TagServiceDelegate> {
    VideoModal *selectedVideo;
    
    WooTagPlayerAppDelegate *appDelegate;
    IBOutlet UIScrollView *viewScrollView;
    
    IBOutlet UILabel *videoTitleHeaderLabel;
    
    IBOutlet UIImageView *videoThumbPath;
    IBOutlet UILabel *dividerLabel;
    
    IBOutlet UIImageView *profilePic;
    IBOutlet UILabel *userNameLabel;
    IBOutlet UILabel *videoCreatedlbl;
    IBOutlet UILabel *videoViewsLabel;
    
    IBOutlet UILabel *numberOfTagsLabel;
    IBOutlet UILabel *numberOfLikesLabel;
    IBOutlet UILabel *numberOfCmntsLabel;
    
    IBOutlet UILabel *videoInfoBgLbl;
    IBOutlet UILabel *videoTitleLbl;
    
    IBOutlet UITableView *commentsTableView;
    NotificationType type;
    AllCommentsViewController *allCmntsVC;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withVideoModal:(VideoModal *)videoModal andNotificationType:(NotificationType )notificationType;

- (IBAction)goBack:(id)sender;
- (IBAction)onClickOfPlayButton:(id)sender;
- (IBAction)onClickOfCommentButton:(id)sender;
- (IBAction)onClickOfGetAllLikesButton:(id)sender;
- (void)allCommentsScreenDismissCalledSelectedIndexPath:(NSIndexPath *)indexPath andViewType:(NSString *)viewType;
- (IBAction)onClickUserNameBtn:(id)sender;
- (void)playBackResponse:(NSDictionary *)results;

@end
