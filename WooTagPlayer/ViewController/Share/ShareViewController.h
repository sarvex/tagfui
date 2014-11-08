/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"
#import "ShareContactsViewController.h"
#import <MessageUI/MessageUI.h>

@class ShareContactsViewController;

/** This VC is for displaying video info and share options
 */
@interface ShareViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,GPPShareDelegate,FHSTwitterEngineAccessTokenDelegate,GPPSignInDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate> {
    
    /** Share tableview with options Facebook, Twitter, GooglePlus, Mail, Contacts
     */
    IBOutlet UITableView *shareTableView;
    IBOutlet UIImageView *videoThumbImgView;
    WooTagPlayerAppDelegate *appDelegate;
    VideoModal *selectedVideo;
    NSArray *shareDetailsArray;

    /** For displaying freinds list to share video info
     */
    ShareContactsViewController *shareContactsVC;
    id caller;
}

/** Initializing this VC with shared video info from caller
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withSelectedVideo:(VideoModal *)video andCaller:(id)caller_;

/** Action for back button
 */
- (IBAction)goBack:(id)sender;

- (void)dismissedContactsViewController;

/** Callback for FB login successful
 */
- (void)FBLoginSuccessful;

/** Request for twitter followers list
 */
- (void)requestForTWFollowersList:(NSString *)pageNumber loadMore:(BOOL) loadMore;

- (void)shareToGooglePlusUserWithUserId:(NSArray *)friendsIdsArray;
- (void)shareVideoInfoThroughMessage:(NSArray *)phoneNumbers;
- (void)finishedPickingTWFriend:(NSString *)twId;
- (void)finishedPickingFBFriend:(NSString *)fbId ;


@end
