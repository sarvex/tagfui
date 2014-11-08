/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "CommentTextView.h"
#import "WooTagPlayerAppDelegate.h"
#import "VideoService.h"
#import "UserService.h"
#import "UserModal.h"
#import "VideoModal.h"
#import "Video.h"
#import "ConnectionsViewController.h"

/** Common ViewController for video likes, video comments, user followings, followers and privategroup
 */
@interface AllCommentsViewController : UIViewController<UITextViewDelegate, UITableViewDataSource, UITableViewDelegate,VideoServiceDelegate,UserServiceDelegate, UIActionSheetDelegate> {
    
    /** for Comment box layout
     */
    IBOutlet UIView *cmtTextViewBg;
    IBOutlet CommentTextView *cmntTextView;
    IBOutlet UITableView *commentsTableView;
    
    /** Title for screen
     */
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *headerLbl;
    WooTagPlayerAppDelegate *appDelegate;
   
    id caller;
    
    /** For animation
     */
    CGFloat chatBarMovedHeight;
    NSIndexPath *selectedIndexPath;
    
    NSIndexPath *selectedUserIndexPath;
    
    /** Selected video for displaying likes/ comments
     */
    VideoModal *selectedVideoModal;
    
    /** Selected user inof for displaying follwoings/follwers/privategroup
     */
    UserModal *user;
    
    /** List objects to display in tableview (list of followings/followers/private group/ video likes/ video comments)
     */
    NSMutableArray *videoCmntsArray;
    
    /** Maintaining pagenumber for load more
     */
    NSInteger pageNumber;
    NSInteger count;
    NSString *viewType;
    
    /** Edit button is for privategroup deletion
     */
    IBOutlet UIButton *editBtn;
    
    NSMutableString *taggedTextStr;
    
    /** This is for tagging users when typing in comment (@username)
     */
    ConnectionsViewController *connectionsVC;

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withVideoModal:(VideoModal *)videoModal user:(UserModal *)selectedUser viewType:(NSString *)type andSelectedIndexPath:(NSIndexPath *)_indexPath andTotalCount:(NSInteger)totalcount andCaller:(id)caller_;

- (IBAction)onClickOfBackButton:(id)sender;
- (void)unFollowedUserFromOtherPageViewControllerWithSelectedIndex:(NSIndexPath *)indexPath andUserId:(NSString *)userId;

- (void)taggedUserDict:(NSDictionary *)userDict;
- (void)refreshScreen;
@end
