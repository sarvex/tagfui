/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "ShareContactsViewController.h"

@interface ShareContactsViewController ()

@end

@implementation ShareContactsViewController
@synthesize friendsVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andType:(NSString *)type andCaller:(id)caller
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        contactsType = type;
        shareVC = (ShareViewController *)caller;
    }
    return self;
}

- (void)viewDidLoad
{
    TCSTART
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 20, self.view.frame.size.width, appDelegate.window.frame.size.height - 20);
    [self initialiseFriendsVC];
    selectedFriendsArray = [[NSMutableArray alloc] init];
    [self enableOrDisableDoneButton];
    TCEND
}

//For status bar in ios7
- (void) viewDidLayoutSubviews {
    if (CURRENT_DEVICE_VERSION >= 7.0 && self.view.frame.size.height == appDelegate.window.frame.size.height) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.size.height = viewBounds.size.height - topBarOffset;
        self.view.frame = CGRectMake(viewBounds.origin.x, topBarOffset, viewBounds.size.width, viewBounds.size.height);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (IBAction)onClickOfCancelBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [shareVC dismissedContactsViewController];
}

- (void)enableOrDisableDoneButton {
    if (selectedFriendsArray.count > 0) {
        doneBtn.enabled = YES;
    } else {
        doneBtn.enabled = NO;
    }
}
- (IBAction)onClickOfDoneBtn:(id)sender {
    TCSTART
    if (selectedFriendsArray.count > 0) {
        if ([contactsType caseInsensitiveCompare:@"Contacts"] == NSOrderedSame) {
            [self dismissViewControllerAnimated:YES completion:^ {
                [shareVC shareVideoInfoThroughMessage:selectedFriendsArray];
            }];
        } else {
            if ([contactsType caseInsensitiveCompare:@"FB"] == NSOrderedSame) {
                [shareVC finishedPickingFBFriend:[selectedFriendsArray objectAtIndex:0]];
            } else if ([contactsType caseInsensitiveCompare:@"GPlus"] == NSOrderedSame) {
                [shareVC shareToGooglePlusUserWithUserId:selectedFriendsArray];
            }  else {
                [shareVC finishedPickingTWFriend:[selectedFriendsArray objectAtIndex:0]];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
    TCEND
}

#pragma mark 
#pragma mark Twitter LoadMore delegate method
- (void)requestForTWFollowersList:(NSString *)pageNumber loadMore:(BOOL) loadMore {
    [shareVC requestForTWFollowersList:pageNumber loadMore:loadMore];
}

#pragma mark FRIENDS VC
- (void)initialiseFriendsVC {
    TCSTART
    friendsVC = [[FriendsViewController alloc]initWithNibName:@"FriendsViewController" bundle:nil];
    friendsVC.view.frame = CGRectMake(0, 42, self.view.frame.size.width, self.view.frame.size.height - 42);
    friendsVC.isLoadingFriends = YES;
    friendsVC.shareVC = self;
    [self.view addSubview:friendsVC.view];
    TCEND
}

- (void)finishedPickingFBFriend:(NSString *)fbId {
    TCSTART
    [selectedFriendsArray removeAllObjects];
    [selectedFriendsArray addObject:fbId];
    [self enableOrDisableDoneButton];
    TCEND
}

-(void)finishedPickingTWFriend:(NSString *)twId {
    TCSTART
    [selectedFriendsArray removeAllObjects];
    [selectedFriendsArray addObject:twId];
    [self enableOrDisableDoneButton];
    TCEND
}

- (void)finishedPickingGPlusFriend:(NSString *)gPlusId {
    TCSTART
    [selectedFriendsArray addObject:gPlusId];
    [self enableOrDisableDoneButton];
    TCEND
}

- (void)unSelectedPickedFriend:(NSString *)userId {
    TCSTART
    if ([selectedFriendsArray containsObject:userId]) {
        [selectedFriendsArray removeObject:userId];
    }
    [self enableOrDisableDoneButton];
    TCEND
}

- (void)unSelectedPickedContactFriend:(NSDictionary *)contact {
    TCSTART
    if ([selectedFriendsArray containsObject:contact]) {
        [selectedFriendsArray removeObject:contact];
    }
    [self enableOrDisableDoneButton];
    TCEND
}
- (void)finishedPickingContacts:(NSDictionary *)contact {
    TCSTART
    [selectedFriendsArray addObject:contact];
    [self enableOrDisableDoneButton];
    TCEND
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark for ios 6 orientation support
- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
    
}

@end
