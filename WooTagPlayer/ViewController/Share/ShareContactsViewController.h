/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "FriendsViewController.h"
#import "ShareViewController.h"
#import "WooTagPlayerAppDelegate.h"

@class ShareViewController;

@interface ShareContactsViewController : UIViewController {
    
    FriendsViewController *friendsVC;
    NSMutableArray *selectedFriendsArray;
    WooTagPlayerAppDelegate *appDelegate;
    
    IBOutlet UIButton *doneBtn;
    
    NSString *contactsType;
    
    ShareViewController *shareVC;
}

@property (nonatomic, strong) FriendsViewController *friendsVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andType:(NSString *)type andCaller:(id)caller;
- (void)requestForTWFollowersList:(NSString *)pageNumber loadMore:(BOOL) loadMore;
- (IBAction)onClickOfCancelBtn:(id)sender;
- (IBAction)onClickOfDoneBtn:(id)sender;

- (void)finishedPickingTWFriend:(NSString *)twId;
- (void)finishedPickingGPlusFriend:(NSString *)gPlusId;
- (void)finishedPickingFBFriend:(NSString *)fbId;
- (void)unSelectedPickedFriend:(NSString *)userId;
- (void)unSelectedPickedContactFriend:(NSDictionary *)contact;
- (void)finishedPickingContacts:(NSDictionary *)contact;
@end
