/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "TagToolViewController.h"
#import "WooTagPlayerAppDelegate.h"
#import "CustomMoviePlayerViewController.h"
#import "FriendsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import "ProductInfoViewController.h"

@interface TagToolViewController ()

//@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;

@end

@implementation TagToolViewController

//@synthesize friendPickerController = _friendPickerController;
@synthesize customMoviePlayerController = _customMoviePlayerController;
@synthesize videoPlaybacktime;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    TCSTART
    [super viewDidLoad];
    wootagProductDetails = [[NSMutableDictionary alloc] init];
    [[UIActivityIndicatorView appearance] setColor:[UIColor whiteColor]];
    helpScreen.hidden = YES;
    appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication]delegate];
    durationStr = @"5";
    colorLbl.tag = 1;
    friendsVCCloseBtn.hidden = YES;
    
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor clearColor];
    tagDisplayTimeView.backgroundColor = [appDelegate colorWithHexString:@"e7e7e7"];
    scrollViewBgLbl.backgroundColor = [appDelegate colorWithHexString:@"e7e7e7"];
    tagColorView.backgroundColor = [appDelegate colorWithHexString:@"e7e7e7"];
    linkItView.backgroundColor = [appDelegate colorWithHexString:@"e7e7e7"];
    
    nameTextview.layer.borderWidth = 1.0f;
    nameTextview.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
    nameTextview.layer.masksToBounds = YES;
    
    linkField.layer.borderWidth = 1.0f;
    linkField.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
    linkField.layer.masksToBounds = YES;
    linkItView.hidden = YES;
    tagToolScrollView.directionalLockEnabled = YES;
    
    tagDisplayTimeView.hidden = YES;
    tagColorView.hidden = YES;
    colorLbl.backgroundColor = [UIColor redColor];
    [self setRoundedCornersToColorViewSubViews];
    [self setRoundedCornersToDisplayTimeViewSubviews];
    [self setTextColorForUIElements];
    [appDelegate setLeftPaddingforTextField:linkField];
    
    appDelegate.twitterEngine.delegate = self;

    [self addHelpTextLblsToScrollView];
    if (![appDelegate.ftue.tagged boolValue]) {
        [self displayHelpScreen];
    }
    
    TCEND
}

- (void)displayHelpScreen {
    TCSTART
    helpScreen.hidden = NO;
    helpBtn.enabled = NO;
    TCEND
}
- (void)addHelpTextLblsToScrollView {
    TCSTART
    if (CURRENT_DEVICE_VERSION >= 7.0) {
        helpScrollview.frame = CGRectMake(helpScrollview.frame.origin.x, helpScrollview.frame.origin.y, helpScrollview.frame.size.width, helpScrollview.frame.size.height - 10);
    }
    helpScrollview.contentSize = CGSizeMake(appDelegate.window.frame.size.height*6, helpScrollview.frame.size.height);
    NSArray *array = [[NSArray alloc] initWithObjects:kTagSelected, kPlaceMarker,kEnteredTagExp,kSelectedConnections,KTagLinked,kTagCreationDone, nil];
    CGFloat originX = 20;
    for (int i = 0; i < array.count; i ++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(originX, 20, (appDelegate.window.frame.size.height - 40), 60)];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:titleFontName size:13];
        label.text = [array objectAtIndex:i];
        label.numberOfLines = 0;
        [helpScrollview addSubview:label];
        originX = originX + label.frame.size.width + 40;
    }
    
    TCEND
}

- (void)setFrameForHelpArrowWithIndex:(int)index {
    TCSTART
    helpArrowImgView.hidden = NO;
    UIImage *leftArrowImage = [UIImage imageNamed:@"TagToolHelpArrow"];
    UIImage *rightArrowImage = [UIImage imageNamed:@"TagToolHelpArrowRight"];
    UIImage *topImageView = [UIImage imageNamed:@"TagToolHelpArrowTop"];
    
    if (index == 0) {
        helpArrowImgView.frame = CGRectMake(((appDelegate.window.frame.size.height > 480)?487:400), 0, 50, 60);
        helpArrowImgView.image = topImageView;
    } else if (index == 1) {
        helpArrowImgView.hidden = YES;
    } else if (index == 2) {
        helpArrowImgView.frame = CGRectMake(182, 114, 50, 60);
        helpArrowImgView.image = leftArrowImage;
    } else if (index == 3) {
        helpArrowImgView.frame = CGRectMake(397, 114, 50, 60);
        helpArrowImgView.image = rightArrowImage;
    } else if (index == 4) {
        helpArrowImgView.frame = CGRectMake(182, 164, 50, 60);
        helpArrowImgView.image = leftArrowImage;
    } else {
        helpArrowImgView.frame = CGRectMake(((appDelegate.window.frame.size.height > 480)?472:400), 114, 50, 60);
        helpArrowImgView.image = rightArrowImage;
    }
    if (appDelegate.window.frame.size.height == 480) {
        CGRect frame;
        if (index == 5) {
             frame.origin.x = tagToolScrollView.contentSize.width - 480;
        } else {
            frame.origin.x = 0;
        }
        frame.origin.y = 0;
        frame.size = tagToolScrollView.frame.size;
        [tagToolScrollView scrollRectToVisible:frame animated:YES];
    }
    TCEND
}

- (void)firstTimeExpForTagCompleted {
    appDelegate.ftue.tagged = [NSNumber numberWithBool:YES];
    [[DataManager sharedDataManager] saveChanges];
}

- (IBAction)onClickOfHelpBtn:(id)sender {
    TCSTART
    [self displayHelpScreen];
    TCEND
}
- (IBAction)onClickOfHelpCloseBtn:(id)sender {
    TCSTART
    helpScreen.hidden = YES;
    helpBtn.enabled = YES;
    if (![appDelegate.ftue.tagged boolValue]) {
        [self onClickOfCancel:cancelBtn];
    } else {
        [self firstTimeExpForTagCompleted];
    }
    TCEND
}
- (IBAction)helpPagechanged:(id)sender {
    TCSTART
    CGRect frame;
    frame.origin.x = helpScrollview.frame.size.width * helpPageControl.currentPage;
    frame.origin.y = 0;
    frame.size = helpScrollview.frame.size;
    [helpScrollview scrollRectToVisible:frame animated:YES];
    [self setFrameForHelpArrowWithIndex:helpPageControl.currentPage];
    TCEND
}

#pragma mark
#pragma mark scroll view delegate method
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    TCSTART
    if (scrollView.tag == -524) {
        // Update the page when more than 50% of the previous/next page is visible
        CGFloat pageWidth = helpScrollview.frame.size.width;
        int page = floor((helpScrollview.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        helpPageControl.currentPage = page;
    }
    TCEND
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    TCSTART
    if (scrollView.tag == -524) {
        [self setFrameForHelpArrowWithIndex:helpPageControl.currentPage];
    }
    TCEND
}
#pragma mark
#pragma mark Layout
- (void) viewDidLayoutSubviews {
    if (CURRENT_DEVICE_VERSION >= 7.0 && self.view.frame.size.height == appDelegate.window.frame.size.width) {
        CGRect viewBounds = self.view.bounds;
        NSLog(@"viewController Frame :%f %f",viewBounds.origin.y,viewBounds.size.height);
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.origin.y = -topBarOffset;
        self.view.bounds = viewBounds;
        NSLog(@"viewController Frame :%f %f",viewBounds.origin.y,viewBounds.size.height);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (void)setTextColorForUIElements {
    TCSTART
    dividerLbl1.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
    dividerLbl2.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
    dividerLbl3.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
    dividerLbl4.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
    
    commentChars_Lbl_.textColor = [appDelegate colorWithHexString:@"11a3e7"];
    
    colorLbl.layer.cornerRadius = 7.0f;
    colorLbl.layer.masksToBounds = YES;

    TCEND
}

- (void)setRoundedCornersToColorViewSubViews {
    TCSTART
    for (UIView *subview in tagColorView.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)subview;
            btn.layer.cornerRadius = 10.0f;
            btn.layer.masksToBounds = YES;
            btn.backgroundColor = [appDelegate colorWithHexString:[appDelegate stringFromColorLabelTag:btn.tag]];
        }
    }
    TCEND
}

- (void)setRoundedCornersToDisplayTimeViewSubviews {
    TCSTART
    for (UIView *subview in tagDisplayTimeView.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)subview;
            btn.layer.borderWidth = 1.0f;
            
            btn.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
            btn.layer.masksToBounds = YES;
        }
    }
    TCEND
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [tagToolScrollView setContentSize:CGSizeMake(568, tagToolScrollView.frame.size.height)];
    scrollViewBgLbl.frame = CGRectMake(0, 0, 568, tagToolScrollView.frame.size.height);
    if (helpPageControl.currentPage == 0) {
        [self setFrameForHelpArrowWithIndex:0];
    }
}

-(IBAction)onClickOfDisplayTime:(id)sender {
    TCSTART
    
    [nameTextview resignFirstResponder];
    [linkField resignFirstResponder];
    if (isViewModeUp) {
        [self setViewMovedUp:NO];
    }
    if (tagDisplayTimeView.hidden) {
        tagDisplayTimeView.hidden = NO;
        [self.view bringSubviewToFront:tagDisplayTimeView];
    } else {
        tagDisplayTimeView.hidden = YES;
    }
    tagColorView.hidden = YES;
    tagDisplayTimeView.frame = CGRectMake(tagDisplayTimeView.frame.origin.x, tagColorView.frame.origin.y, tagDisplayTimeView.frame.size.width, tagDisplayTimeView.frame.size.height);
    TCEND
}

-(IBAction)onClickOfColor:(id)sender {
    TCSTART
    [nameTextview resignFirstResponder];
    [linkField resignFirstResponder];
    if (isViewModeUp) {
        [self setViewMovedUp:NO];
    }
    
    tagDisplayTimeView.hidden = YES;
    if (tagColorView.hidden) {
        tagColorView.hidden = NO;
        [self.view bringSubviewToFront:tagColorView];
    } else {
        tagColorView.hidden = YES;
    }
    TCEND
}

#pragma mark FaceBook SignIn & Delegate Methods
- (IBAction)onClickOfFB:(id)sender {
    [[UIActivityIndicatorView appearance] setColor:[appDelegate colorWithHexString:@"11a3e7"]];
    // FBSample logic
    // if the session is open, then load the data for our view controller
    if (!FBSession.activeSession.isOpen) {
        // if the session is closed, then we open it here, and establish a handler for state changes
        [FBSession openActiveSessionWithReadPermissions:appDelegate.facebookReadPermissions
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState state,
                                                          NSError *error) {
                                          if (error) {
                                              [ShowAlert showError:@"Authentication failed, please try again"];
                                          } else if (session.isOpen) {
                                              [self onClickOfFB:sender];
                                          }
                                      }];
        return;
    } else {
        tagColorView.hidden = YES;
        tagDisplayTimeView.hidden = YES;
        tagToolScrollView.hidden = YES;
        [nameTextview resignFirstResponder];
        [linkField resignFirstResponder];
        if (isViewModeUp) {
            [self setViewMovedUp:NO];
        }
        friendsVC = [self loadFriendsViewController];
        [friendsVC setAllBoolVariablesToNo];
        friendsVC.isFBFriendsLoaded = YES;
        [friendsVC setImageForSearchBgPlaceholder];
        
        [FBRequestConnection startWithGraphPath:@"me" parameters:[NSDictionary dictionaryWithObject:@"picture,username,email,name" forKey:@"fields"] HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
            if (error) {
                GTMLoggerError(@"error:%@",error);
                friendsVC.isLoadingFriends = NO;
                [friendsVC reloadData];
            } else {
                NSMutableArray *friends = [[NSMutableArray alloc]init];
                NSMutableDictionary *userInfoDict = [[NSMutableDictionary alloc]init];
                [userInfoDict setObject:[result objectForKey:@"email"]?:@"" forKey:@"email"];
                [userInfoDict setObject:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",[result objectForKey:@"id"]]?:@"" forKey:@"image"];
                [userInfoDict setObject:[result objectForKey:@"name"]?:@"" forKey:@"displayname"];
                [userInfoDict setObject:[result objectForKey:@"id"] forKey:@"id"];
                
                if ([self isNotNull:appDelegate.loggedInUser]) {
                    if ([self isNull:appDelegate.loggedInUser.socialContactsDictionary]) {
                        appDelegate.loggedInUser.socialContactsDictionary = [[NSMutableDictionary alloc] init];
                    }
                    [appDelegate.loggedInUser.socialContactsDictionary setObject:[result objectForKey:@"name"]?:@"" forKey:@"FB"];
                }
                
                if (fbTagId.length > 0 && [[userInfoDict objectForKey:@"id"] isEqualToString:fbTagId]) {
                    [userInfoDict setObject:@"loggedin" forKey:@"type"];
                    friendsVC.selectedUserDict = userInfoDict;
                } else {
                    [friendsVC.loggedInUserDictArray addObject:userInfoDict];
                }
                
                if ([FBSession.activeSession.permissions indexOfObject:@"manage_pages"] == NSNotFound) {
                    
                    [FBSession.activeSession requestNewPublishPermissions:@[@"manage_pages"]
                                                          defaultAudience:FBSessionDefaultAudienceFriends
                                                        completionHandler:^(FBSession *session, NSError *error) {
                                                            if (!error) {
                                                                [self managePermissionsAllowedWith:friends];
                                                            } else {
                                                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission denied" message:@"Unable to get permission to manage pages" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                [alertView show];
                                                                [self getFriends:friends];
                                                            }
                                                        }];
                } else {
                    [self managePermissionsAllowedWith:friends];
                }
            }
        }];
    }
}

- (void)managePermissionsAllowedWith:(NSMutableArray *)friends {
    TCSTART
    [FBRequestConnection startWithGraphPath:@"me/accounts" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            GTMLoggerError(@"error:%@",error);
        } else {
            NSLog(@"pages Result:%@",result);
            NSMutableArray *pagesArray = [[NSMutableArray alloc] init];
            for(NSDictionary *userDict in [result objectForKey:@"data"]) {
                NSMutableDictionary *friend = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[userDict objectForKey:@"name"]?:@"",@"displayname",[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",[userDict objectForKey:@"id"]]?:@"",@"image",[userDict objectForKey:@"id"]?:@"",@"id", nil];
                if (fbTagId.length > 0 && [[userDict objectForKey:@"id"] isEqualToString:fbTagId]) {
                    [friend setObject:@"pages" forKey:@"type"];
                    friendsVC.selectedUserDict = friend;
                } else {
                    [pagesArray addObject:friend];
                }
            }
            friendsVC.pagesArray = pagesArray;
        }
        [self getFriends:friends];
    }];
    
    TCEND
}

- (void)getFriends:(NSMutableArray *)friends {
    TCSTART
    [FBRequestConnection startWithGraphPath:@"me/friends" completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
        if (error) {
            GTMLoggerError(@"error:%@",error);
            friendsVC.isLoadingFriends = NO;
            [friendsVC reloadData];
        } else {
            NSLog(@"Result:%@",result);
            for(NSDictionary *userDict in [result objectForKey:@"data"]) {
                NSMutableDictionary *friend = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[userDict objectForKey:@"name"]?:@"",@"displayname",[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",[userDict objectForKey:@"id"]]?:@"",@"image",[userDict objectForKey:@"id"]?:@"",@"id", nil];
                if (fbTagId.length > 0 && [[userDict objectForKey:@"id"] isEqualToString:fbTagId]) {
                    [friend setObject:@"friends" forKey:@"type"];
                    friendsVC.selectedUserDict = friend;
                } else {
                    [friends addObject:friend];
                }
            }
            [friendsVC.friendsList addObjectsFromArray:friends];
            [friendsVC reloadData];
        }
    }];
    
    TCEND
}

- (void)finishedPickingFBFriend:(NSString *)fbId {
    [fbBtn setBackgroundImage:[UIImage imageNamed:@"FBBtn"] forState:UIControlStateNormal];
    fbTagId = fbId;
    [self removeFriendsView];
}

- (void)removeFriendsView {
    TCSTART
    [friendsVC.view removeFromSuperview];
    friendsVC = nil;
    friendsVCCloseBtn.hidden = YES;
    tagToolScrollView.hidden = NO;
    TCEND
}

- (IBAction)closeFriendsViewController:(id)sender {
    [self removeFriendsView];
}

#pragma mark Twittter SignIn & Delegate Methods
- (IBAction)onClickOfTW:(id)sender {
    TCSTART
   [[UIActivityIndicatorView appearance] setColor:[appDelegate colorWithHexString:@"11a3e7"]];
    appDelegate.twitterEngine.delegate = (id)self;
    if(!appDelegate.twitterEngine) {
        [appDelegate initializeTwitterEngineWithDelegate:self];
    }
    [appDelegate.twitterEngine loadAccessToken];
    if(![appDelegate.twitterEngine isAuthorized]) {
        [appDelegate authenticateTwitterAccountWithDelegate:self andPresentFromVC:self.customMoviePlayerController];
    } else {
        [self requestForTWFollowersList:@"-1" loadMore:NO];
    }
    TCEND
}

- (void)storeAccessToken:(NSString *)body {
    TCSTART
    NSLog(@"Got tw oauth response %@",body);
    [[NSUserDefaults standardUserDefaults]setObject:body forKey:@"SavedAccessHTTPBody"];
    if ([self isNull:appDelegate.loggedInUser.socialContactsDictionary]) {
        appDelegate.loggedInUser.socialContactsDictionary = [[NSMutableDictionary alloc] init];
    }
    [appDelegate.loggedInUser.socialContactsDictionary setObject:appDelegate.twitterEngine.loggedInUsername?:@"" forKey:@"TW"];
    if (appDelegate.twitterEngine.loggedInUsername.length > 0) {
        [self requestForTWFollowersList:@"-1" loadMore:NO];
    }
    TCEND
}

-(NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
}

- (void)requestForTWFollowersList:(NSString *)pageNumber loadMore:(BOOL) loadMore {
    TCSTART
    tagColorView.hidden = YES;
    tagDisplayTimeView.hidden = YES;
    tagToolScrollView.hidden = YES;
    [nameTextview resignFirstResponder];
    [linkField resignFirstResponder];
    NSDictionary *userDict;
    if (isViewModeUp) {
        [self setViewMovedUp:NO];
    }
    if (!loadMore) {
         friendsVC = [self loadFriendsViewController];
        [friendsVC setAllBoolVariablesToNo];
    }
    friendsVC.isTWFriendsLoaded = YES;
    if (!loadMore) {
        [friendsVC setImageForSearchBgPlaceholder];
        
        dispatch_async(GCDBackgroundThread, ^{
            @autoreleasepool {
                NSDictionary *dict = [appDelegate.twitterEngine getUserProfileForUserId:appDelegate.twitterEngine.loggedInID];
                NSMutableDictionary *userDict;
                if ([self isNotNull:dict] && [self isNotNull:[dict objectForKey:@"name"]]) {
                    userDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[dict objectForKey:@"name"]?:@"",@"displayname",[dict objectForKey:@"profile_image_url_https"]?:@"",@"image",[[dict objectForKey:@"id"] stringValue],@"id",[dict objectForKey:@"description"]?:@"",@"description",[dict objectForKey:@"location"]?:@"",@"location",[dict objectForKey:@"screen_name"]?:@"",@"screen_name",[dict objectForKey:@"url"]?:@"",@"url", nil];
                }
                
                if ([self isNotNull:twTagId] && twTagId.length > 0) {
                    if ([self isNotNull:userDict] && [[userDict objectForKey:@"id"] isEqualToString:twTagId]) {
                        [userDict setObject:@"loggedin" forKey:@"type"];
                        friendsVC.selectedUserDict = [userDict copy];
                        userDict = nil;
                    } else {
                        NSDictionary *dict = [appDelegate.twitterEngine getUserProfileForUserId:twTagId];
                        if ([self isNotNull:dict] && [self isNotNull:[dict objectForKey:@"name"]]) {
                            friendsVC.selectedUserDict = [[NSDictionary alloc]initWithObjectsAndKeys:[dict objectForKey:@"name"]?:@"",@"displayname",[dict objectForKey:@"profile_image_url_https"]?:@"",@"image",[[dict objectForKey:@"id"] stringValue],@"id",[dict objectForKey:@"description"]?:@"",@"description",[dict objectForKey:@"location"]?:@"",@"location",[dict objectForKey:@"screen_name"]?:@"",@"screen_name",[dict objectForKey:@"url"]?:@"",@"url",@"friends",@"type", nil];
                            
                        }
                    }
                }
                // Handle twitterData (see "About GET Requests")
                dispatch_sync(GCDMainThread, ^{
                    @autoreleasepool {
                        dispatch_async(GCDBackgroundThread, ^{
                            @autoreleasepool {
                                id twitterData = [appDelegate.twitterEngine listFriendsForUser:appDelegate.twitterEngine.loggedInUsername isID:NO withCursor:pageNumber];
                                // Handle twitterData (see "About GET Requests")
                                dispatch_sync(GCDMainThread, ^{
                                    @autoreleasepool {
                                        // Update UI
                                        friendsVC.isLoadingFriends = NO;
                                        [friendsVC formatTWDataAndReloadFriendsTable:twitterData loggedInUserInfo:userDict andRequestForLoadMore:loadMore];
                                    }
                                });
                            }
                        });
                    }
                });
            }
        });
    } else {
        dispatch_async(GCDBackgroundThread, ^{
            @autoreleasepool {
                id twitterData = [appDelegate.twitterEngine listFriendsForUser:appDelegate.twitterEngine.loggedInUsername isID:NO withCursor:pageNumber];
                // Handle twitterData (see "About GET Requests")
                dispatch_sync(GCDMainThread, ^{
                    @autoreleasepool {
                        // Update UI
                        friendsVC.isLoadingFriends = NO;
                        [friendsVC formatTWDataAndReloadFriendsTable:twitterData loggedInUserInfo:userDict andRequestForLoadMore:loadMore];
                    }
                });
            }
        });
    }
    
    TCEND
}

- (void)finishedPickingTWFriend:(NSString *)twId {
    
    [twBtn setBackgroundImage:[UIImage imageNamed:@"TwitterBtn"] forState:UIControlStateNormal];
    twTagId = twId;
    [self removeFriendsView];
}



#pragma mark GPlus SignIn & Delegate Methods
-(IBAction)onClickOfGPlus:(id)sender {
    TCSTART
    [[UIActivityIndicatorView appearance] setColor:[appDelegate colorWithHexString:@"11a3e7"]];
    if ([[GPPSignIn sharedInstance] authentication]) {
        gPlusBtn.enabled = YES;
        // The user is signed in.
        GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
        plusService.retryEnabled = YES;
        [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
        if ([self isNull:appDelegate.loggedInUser.socialContactsDictionary]) {
            appDelegate.loggedInUser.socialContactsDictionary = [[NSMutableDictionary alloc] init];
        }
        [appDelegate.loggedInUser.socialContactsDictionary setObject:[GPPSignIn sharedInstance].authentication.userEmail?:@"" forKey:@"GPLUS"];
        
        tagToolScrollView.hidden = YES;
        tagColorView.hidden = YES;
        tagDisplayTimeView.hidden = YES;
        [nameTextview resignFirstResponder];
        [linkField resignFirstResponder];
        if (isViewModeUp) {
            [self setViewMovedUp:NO];
        }
        friendsVC = [self loadFriendsViewController];
        [friendsVC setAllBoolVariablesToNo];
        friendsVC.isGPlusFriendsLoaded = YES;
        [friendsVC setImageForSearchBgPlaceholder];
        
        GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
        [plusService executeQuery:query
                completionHandler:^(GTLServiceTicket *ticket,
                                    GTLPlusPerson *person,
                                    NSError *error) {
                    if (error) {
                        friendsVC.isLoadingFriends = NO;
                        [friendsVC reloadData];
                        GTMLoggerError(@"Error: %@", error);
                    } else {
                        NSLog(@"UserINFO :%@\n",person.JSON);
                        NSMutableArray *friends = [[NSMutableArray alloc]init];
                        NSMutableDictionary *userInfoDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:person.displayName?:@"",@"displayname",person.image.url?:@"",@"image",person.identifier?:@"",@"id",person.currentLocation?:@"",@"description", nil];
                        
                        if (gPlusTagId.length > 0 && [[userInfoDict objectForKey:@"id"] isEqualToString:gPlusTagId]) {
                            [userInfoDict setObject:@"loggedin" forKey:@"type"];
                            friendsVC.selectedUserDict = userInfoDict;
                        } else {
                            [friendsVC.loggedInUserDictArray addObject:userInfoDict];
                        }
                    
                        GTLQueryPlus *listquery =
                        [GTLQueryPlus queryForPeopleListWithUserId:@"me"
                                                        collection:kGTLPlusCollectionVisible];
                        
                        friendsVC = [self loadFriendsViewController];
                        friendsVC.isGPlusFriendsLoaded = YES;
                        
                        [plusService executeQuery:listquery
                                completionHandler:^(GTLServiceTicket *ticket,
                                                    GTLPlusPeopleFeed *peopleFeed,
                                                    NSError *error) {
                                    if (error) {
                                        GTMLoggerError(@"Error: %@", error);
                                        friendsVC.isLoadingFriends = NO;
                                        [friendsVC reloadData];
                                    } else {
                                        // Get an array of people from GTLPlusPeopleFeed
                                        NSArray* peopleList = peopleFeed.items;
                                        NSLog(@"GooglePlus Friends List : %@",peopleList);
                                        friendsVC.isLoadingFriends = NO;
                                        
                                        for(GTLPlusPerson *gPlusPersion in peopleList) {
                                            NSMutableDictionary *friend = [[NSMutableDictionary alloc]initWithObjectsAndKeys:gPlusPersion.displayName?:@"",@"displayname",gPlusPersion.image.url?:@"",@"image",gPlusPersion.identifier?:@"",@"id",gPlusPersion.currentLocation?:@"",@"description", nil];
                                            if (gPlusTagId.length > 0 && [[friend objectForKey:@"id"] isEqualToString:gPlusTagId]) {
                                                [friend setObject:@"friends" forKey:@"type"];
                                                friendsVC.selectedUserDict = friend;
                                            } else {
                                                [friends addObject:friend];
                                            }
                                        }
                                        [friendsVC.friendsList addObjectsFromArray:friends];
                                        [friendsVC reloadData];
                                    }
                                }];
                        
                    }
                }];
        
//        [plusService executeQuery:query
//                completionHandler:^(GTLServiceTicket *ticket,
//                                    GTLPlusPeopleFeed *peopleFeed,
//                                    NSError *error) {
//                    if (error) {
//                        GTMLoggerError(@"Error: %@", error);
//                        friendsVC.isLoadingFriends = NO;
//                        [friendsVC reloadData];
//                    } else {
//                        // Get an array of people from GTLPlusPeopleFeed
//                        NSArray* peopleList = peopleFeed.items;
//                        NSLog(@"GooglePlus Friends List : %@",peopleList);
//                       friendsVC.isLoadingFriends = NO;
//                        NSMutableArray *friends = [[NSMutableArray alloc]init];
//                        for(GTLPlusPerson *gPlusPersion in peopleList) {
//                            NSDictionary *friend = [[NSDictionary alloc]initWithObjectsAndKeys:gPlusPersion.displayName?:@"",@"displayname",gPlusPersion.image.url?:@"",@"image",gPlusPersion.identifier?:@"",@"id",gPlusPersion.currentLocation?:@"",@"description", nil];
//                            [friends addObject:friend];
//                        }
//                        [friendsVC.friendsList addObjectsFromArray:friends];
//                        [friendsVC reloadData];
//                    }
//                }];
    } else {
        GPPSignIn *signIn = [GPPSignIn sharedInstance];
        signIn.clientID = kGooglePlusClientId;
        signIn.shouldFetchGoogleUserEmail = YES;
        signIn.shouldFetchGoogleUserID = YES;
        [signIn setScopes:[NSArray arrayWithObjects: @"https://www.googleapis.com/auth/plus.login", @"https://www.googleapis.com/auth/userinfo.email", @"https://www.googleapis.com/auth/plus.me", nil]];
        signIn.delegate = self;
        [signIn authenticate];
        gPlusBtn.enabled = NO;
    }
    TCEND
}


- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    if (error) {
        gPlusBtn.enabled = YES;
        [ShowAlert showError:@"Authentication failed, please try again"];
    } else {
        NSLog(@"GPlus SignIn Success");
        [self onClickOfGPlus:nil];
    }
}

- (void)finishedPickingGPlusFriend:(NSString *)gPlusId {
    
     [gPlusBtn setBackgroundImage:[UIImage imageNamed:@"GooglePlusBtn"] forState:UIControlStateNormal];

    gPlusTagId = gPlusId;
    
    [self removeFriendsView];
}

- (FriendsViewController *)loadFriendsViewController {
    TCSTART
    if ([self isNull:friendsVC]) {
        friendsVC = [[FriendsViewController alloc]initWithNibName:@"FriendsViewController" bundle:nil];
        friendsVC.view.frame = CGRectMake((appDelegate.window.frame.size.height > 480)?330:242, 5, 235, 290);
        friendsVC.isLoadingFriends = YES;
        friendsVC.caller = self;
        [self.view addSubview:friendsVC.view];
        friendsVCCloseBtn.hidden = NO;
    }
    [self.view bringSubviewToFront:friendsVC.view];
    [self.view bringSubviewToFront:friendsVCCloseBtn];
    return friendsVC;
    TCEND
}

#pragma mark WooTag Delegate methods
- (IBAction)onClickOfWT:(id)sender {
    TCSTART
    [[UIActivityIndicatorView appearance] setColor:[appDelegate colorWithHexString:@"11a3e7"]];
    
    tagColorView.hidden = YES;
    tagDisplayTimeView.hidden = YES;
    [nameTextview resignFirstResponder];
    [linkField resignFirstResponder];
    if (isViewModeUp) {
        [self setViewMovedUp:NO];
    }
//    friendsVC = [self loadFriendsViewController];
//    if ([self isNotNull:wtId] && wtId.length > 0) {
//        friendsVC.selectedUserDict = [NSDictionary dictionaryWithObjectsAndKeys:wtId,@"id", nil];
//    }
//    [friendsVC setAllBoolVariablesToNo];
//    friendsVC.isWTFriendsLoaded = YES;
//    [friendsVC setImageForSearchBgPlaceholder];
//    [friendsVC makeRequestForListOfWooTagFreinds:YES andPageNum:1];
    ProductInfoViewController *productInfoVC = [[ProductInfoViewController alloc] initWithNibName:@"ProductInfoViewController" bundle:nil];
    productInfoVC.tagDetailsDict = wootagProductDetails;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:productInfoVC];
    navController.navigationBarHidden = YES;
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.customMoviePlayerController presentViewController:navController animated:YES completion:nil];
    productInfoVC.tagToolVC = self;
    [productInfoVC reloadTable];
    TCEND
}

- (void)finishedPickingWTFriend:(NSString *)wtId_ {
    TCSTART
    if ([wootagProductDetails count] > 0 && [self isNotNull:[wootagProductDetails objectForKey:@"productName"]]) {
        [wtBtn setBackgroundImage:[UIImage imageNamed:@"WooTagBtn"] forState:UIControlStateNormal];
    } else {
        [self cancelWTVC];
    }
    [self removeFriendsView];
    TCEND
}

- (void)cancelWTVC {
    TCSTART
    if ([wootagProductDetails count] > 0 && [self isNotNull:[wootagProductDetails objectForKey:@"productName"]]) {
        
    } else {
        [wtBtn setBackgroundImage:[UIImage imageNamed:@"WooTagBtn_f"] forState:UIControlStateNormal];
    }
    TCEND
}
- (void)deletedTaggedFriendOfType:(NSString *)taggedType {
    TCSTART
    if ([taggedType caseInsensitiveCompare:@"FB"] == NSOrderedSame) {
        fbTagId = @"";
        [fbBtn setBackgroundImage:[UIImage imageNamed:@"FBBtn_f"] forState:UIControlStateNormal];
    } else if ([taggedType caseInsensitiveCompare:@"TW"] == NSOrderedSame) {
        twTagId = @"";
        [twBtn setBackgroundImage:[UIImage imageNamed:@"TwitterBtn_f"] forState:UIControlStateNormal];
    } else if ([taggedType caseInsensitiveCompare:@"GPlus"] == NSOrderedSame) {
        gPlusTagId = @"";
        [gPlusBtn setBackgroundImage:[UIImage imageNamed:@"GooglePlusBtn_f"] forState:UIControlStateNormal];
    } else {
        wtId = @"";
        [wtBtn setBackgroundImage:[UIImage imageNamed:@"WooTagBtn_f"] forState:UIControlStateNormal];
    }
    TCEND
}

#pragma mark Reset
- (IBAction)onClickOfReset:(id)sender {
    nameTextview.text = nil;
    linkField.text = nil;
    durationLbl.text = @"5 sec";
    durationStr = @"5";
    colorLbl.backgroundColor = [UIColor redColor];
    colorLbl.tag = 1;
    [fbBtn setBackgroundImage:[UIImage imageNamed:@"FBBtn_f"] forState:UIControlStateNormal];
    [twBtn setBackgroundImage:[UIImage imageNamed:@"TwitterBtn_f"] forState:UIControlStateNormal];
    [gPlusBtn setBackgroundImage:[UIImage imageNamed:@"GooglePlusBtn_f"] forState:UIControlStateNormal];
    [wtBtn setBackgroundImage:[UIImage imageNamed:@"WooTagBtn_f"] forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFY_UPDATED_TAG_COLOR object:colorLbl];
}

- (IBAction)onClickOfPublish:(id)sender {
    TCSTART
    [[UIActivityIndicatorView appearance] setColor:[appDelegate colorWithHexString:@"11a3e7"]];
    NSString *linkText = linkField.text;
    linkField.delegate = nil;
    linkField = nil;

    [linkwebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
    [linkwebView stopLoading];
    [linkwebView removeFromSuperview];
    linkwebView = nil;
    linkItView = nil;
    
    if (nameTextview.text.length > 0) {
        nameTextview.text = [appDelegate removingLastSpecialCharecter:nameTextview.text];
    }
    
    if (linkText.length > 0) {
        linkText = [appDelegate removingLastSpecialCharecter:linkText];
    }
    
    if (!nameTextview.text.length > 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Please enter Tag name" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    NSMutableDictionary *tagFields;
    NSInteger tagId;
    NSString *colorName = [appDelegate colorNameWithHexString:[appDelegate stringFromColorLabelTag:colorLbl.tag]];
    
    NSLog(@"Colorname:%@ gplusID :%@",colorName,gPlusTagId);
    if (tag) {
        tagId = [tag.tagId integerValue];
        tagFields = [[NSMutableDictionary alloc]initWithObjectsAndKeys:nameTextview.text?:@"",@"name",linkText?:@"",@"link",durationStr?:@"",@"displaytime",colorName,@"tagColorName",fbTagId?:@"",@"fbtagid",twTagId?:@"",@"twtagid",gPlusTagId?:@"",@"gplustagid",wtId?:@"",@"wtId",[NSNumber numberWithInt:tagId],@"tagid",[NSNumber numberWithBool:YES],@"isModified",[NSNumber numberWithBool:YES],@"isWaitingForUpload",[NSNumber numberWithBool:NO],@"isAdded", nil];
    } else {
        tagId = [appDelegate generateUniqueId];
        tagFields = [[NSMutableDictionary alloc]initWithObjectsAndKeys:nameTextview.text?:@"",@"name",linkText?:@"",@"link",durationStr?:@"",@"displaytime",colorName,@"tagColorName",fbTagId?:@"",@"fbtagid",twTagId?:@"",@"twtagid",gPlusTagId?:@"",@"gplustagid",wtId?:@"",@"wtId",[NSNumber numberWithInt:tagId],@"clientTagId",[NSNumber numberWithBool:NO],@"isModified",[NSNumber numberWithBool:YES],@"isWaitingForUpload",[NSNumber numberWithBool:YES],@"isAdded", nil];
        [tagFields setObject:[NSString stringWithFormat:@"%.1f",videoPlaybacktime] forKey:@"videoplaybacktime"];
    }
    [tagFields addEntriesFromDictionary:wootagProductDetails];
    [self firstTimeExpForTagCompleted];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFY_TAG_PUBLISH object:tagFields];
    if (self) {
        [self.view removeFromSuperview];
    }
    TCEND
}

- (IBAction)onClickOfSelectedTime:(id)sender {
    UIButton *button = (UIButton *)sender;
    durationLbl.text = button.titleLabel.text;
    durationStr = [NSString stringWithFormat:@"%d",(button.tag * 5)];
    tagDisplayTimeView.hidden = YES;
    NSLog(@"Selected Time %d",(button.tag * 5));
}

- (IBAction)onClickOfSelectedColor:(id)sender {
    UIButton *button = (UIButton *)sender;
    colorLbl.backgroundColor =  button.backgroundColor;
    colorLbl.tag = button.tag;
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFY_UPDATED_TAG_COLOR object:colorLbl];
    tagColorView.hidden = YES;
}

- (IBAction)onClickOfCancel:(id)sender {
    TCSTART
    [linkwebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
    [linkwebView stopLoading];
    [linkwebView removeFromSuperview];
    linkwebView = nil;
    linkItView = nil;
    [[UIActivityIndicatorView appearance] setColor:[appDelegate colorWithHexString:@"11a3e7"]];
    UIButton *button = (UIButton *)sender;
    linkField.delegate = nil;
    linkField = nil;
    if (button.tag == 1) { //Cancel the TagTool and continue playing the video
        [self firstTimeExpForTagCompleted];
        [self.view removeFromSuperview];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFY_TAGTOOL_CANCEL object:nil];
    } 
    TCEND
}

- (void)updateTagToolObjects:(Tag *)tag_ {
    TCSTART
    tag = tag_;
    
    nameTextview.text = tag.name;
    linkField.text = tag.link;
    durationStr = tag.displayTime;
    commentChars_Lbl_.text = [NSString stringWithFormat:@"%d", (40-nameTextview.text.length)];
    durationLbl.text = [NSString stringWithFormat:@"%@ sec",tag.displayTime];
    colorLbl.backgroundColor = [appDelegate colorWithHexString:[appDelegate HexStringFromColorName:tag.tagColorName]];
    colorLbl.tag = [appDelegate getColorLblTag:tag.tagColorName];
    if (tag.twId.length > 0) {
        twTagId = tag.twId;
        [twBtn setBackgroundImage:[UIImage imageNamed:@"TwitterBtn"] forState:UIControlStateNormal];
    }
    
    if (tag.fbId.length > 0) {
        fbTagId = tag.fbId;
        [fbBtn setBackgroundImage:[UIImage imageNamed:@"FBBtn"] forState:UIControlStateNormal];
    }
    if (tag.gPlusId.length > 0) {
        gPlusTagId = tag.gPlusId;
        [gPlusBtn setBackgroundImage:[UIImage imageNamed:@"GooglePlusBtn"] forState:UIControlStateNormal];
    }
    
    if ([self isNotNull:tag.productName] && tag.productName.length > 0) {
        [wtBtn setBackgroundImage:[UIImage imageNamed:@"WooTagBtn"] forState:UIControlStateNormal];
    }
    
    [publishBtn setTitle:@"Update" forState:UIControlStateNormal];
    [wootagProductDetails addEntriesFromDictionary:[tag dictionaryWithValuesForKeys:[NSArray arrayWithObjects:@"productName",@"productCategory",@"productDescription",@"productPrice",@"productLink",@"productCurrencyType", nil]]];
    TCEND
}

#pragma mark TextField Delegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (isViewModeUp) {
        [self setViewMovedUp:NO];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
   
    tagColorView.hidden = YES;
    tagDisplayTimeView.hidden = YES;
    if ([textField isEqual:linkField]) {
        if (self.view.frame.origin.y >= 0) {
            [self setViewMovedUp:YES];
        }
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

#pragma mark Textview
#pragma mark - textView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
   
    tagColorView.hidden = YES;
    tagDisplayTimeView.hidden = YES;
    if (!isViewModeUp) {
        [self setViewMovedUp:YES];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    @try {
        int len = 40 - textView.text.length;
        commentChars_Lbl_.text= [NSString stringWithFormat:@"%d",len];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)textViewDidChange:(UITextView *) textView  {
    @try {
        int len = 40 - textView.text.length;
        commentChars_Lbl_.text= [NSString stringWithFormat:@"%d",len];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    @try {
        if([text isEqualToString:@"\n"]){
            [textView resignFirstResponder];
            return NO;
        } else {
            int len = 40 - textView.text.length;
            if (len <= 0 && ![text isEqualToString:@""]) {
                return NO;
            }
            return YES;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
        
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    if ([self isNotNull:linkField] && [linkField canBecomeFirstResponder]) {
        [linkField becomeFirstResponder];
    }
}


- (void)setViewMovedUp:(BOOL)movedUp {
    @try {
#define kOFFSET_FOR_KEYBOARD 162
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5]; // if you want to slide up the view
        
        CGRect viewRect = self.view.frame;
    
        if (movedUp) {
            isViewModeUp = YES;
            // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
            // 2. increase the size of the view so that the area behind the keyboard is covered up.
            //bgImageViewRect.size.height -= kOFFSET_FOR_KEYBOARD;
            //bgImageViewRect.origin.y  += 75;
            // bgImageViewRect.size.height -= 10;
            viewRect.origin.y -= /*(appDelegate.window.frame.size.height > 480) ?kOFFSET_FOR_KEYBOARDiPhone : */kOFFSET_FOR_KEYBOARD;
//            viewRect.size.height += /*(appDelegate.window.frame.size.height > 480) ?kOFFSET_FOR_KEYBOARDiPhone : */kOFFSET_FOR_KEYBOARD;
        } else {
            isViewModeUp = NO;
            // revert back to the normal state.
            // bgImageViewRect.size.height += kOFFSET_FOR_KEYBOARD;
            //bgImageViewRect.origin.y  -= 75;
            // bgImageViewRect.size.height += 10;
            
            viewRect.origin.y += /*(appDelegate.window.frame.size.height > 480) ?kOFFSET_FOR_KEYBOARDiPhone : */kOFFSET_FOR_KEYBOARD;
//            viewRect.size.height -= /*(appDelegate.window.frame.size.height > 480) ?kOFFSET_FOR_KEYBOARDiPhone : */kOFFSET_FOR_KEYBOARD;
        }
        self.view.frame = viewRect;
        
        [UIView commitAnimations];
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

#pragma mark LinkIt 
- (IBAction)onClickOfTagToolLinkBtn {
    TCSTART
    appDelegate.ftue.selectedColorNTime = [NSNumber numberWithBool:NO];
    
    if ([linkItView isHidden]) {
        [[UIActivityIndicatorView appearance] setColor:[UIColor whiteColor]];
        [nameTextview resignFirstResponder];
        [linkField resignFirstResponder];
        tagColorView.hidden = YES;
        tagDisplayTimeView.hidden = YES;
        tagToolScrollView.hidden = YES;
        if (isViewModeUp) {
            [self setViewMovedUp:NO];
        }
        linkItView.hidden = NO;
        [self.view bringSubviewToFront:linkItView];
        linkwebView.scalesPageToFit = YES;
        linkwebView.delegate = self;
//        linkwebView.scrollView.showsHorizontalScrollIndicator = NO;
//        linkwebView.scrollView.showsVerticalScrollIndicator = NO;
        backLinkBtn.enabled = NO;
        fwdLinkBtn.enabled = NO;
        
        reloadBtn.hidden = YES;
        activityIndicator.hidden = YES;
        if (linkField.text.length > 0) {
            NSString *string = linkField.text;
            string = [appDelegate removingLastSpecialCharecter:string];
            if (string.length > 0) {
                if ([string hasPrefix:@"http://"] || [string hasPrefix:@"https://"]) {
                    [linkwebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
                } else {
                    [linkwebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.com/search?q=%@", [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]]];
                }
            } else {
                [linkwebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.co.in/"]]];
            }
        } else {
            [linkwebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.co.in/"]]];
        }
    }
    TCEND
}

- (IBAction)onClickOfLinkItBtn {
    TCSTART
    NSLog(@"Link URL : %@",linkwebView.request.URL.absoluteString);
    linkField.text = linkwebView.request.URL.absoluteString;
    [self onClickOflinkViewCloseBtn:nil];
    TCEND
}

- (IBAction)onclickOfBackLinkBtn {
    if ([linkwebView canGoBack]) {
        [linkwebView goBack];
    }
}
- (IBAction)onClickOfFwdLinkBtn {
    if ([linkwebView canGoForward]) {
        [linkwebView goForward];
    }
}
- (IBAction)onClickOfReloadBtn:(id)sender {
    [linkwebView reload];
}
- (IBAction)onClickOflinkViewCloseBtn:(id)sender {
    TCSTART
    [[UIActivityIndicatorView appearance] setColor:[appDelegate colorWithHexString:@"11a3e7"]];
    linkItView.hidden = YES;
    [linkwebView stopLoading];
    [linkwebView endEditing:YES];
    [activityIndicator stopAnimating];
    linkwebView.delegate = nil;
    
    tagToolScrollView.hidden = NO;
    [self.customMoviePlayerController linkItWebviewLoadErrorWithPlaybackTime:videoPlaybacktime];
    TCEND
}

#pragma mark WebView Delegate Methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView_ {
    TCSTART
        if (!isNetworkIndicator) {
            isNetworkIndicator = YES;
            reloadBtn.hidden = YES;
            activityIndicator.hidden = NO;
            [activityIndicator startAnimating];
        }
    TCEND
}

- (void)webViewDidFinishLoad:(UIWebView *)webView_ {
    TCSTART
        isNetworkIndicator = NO;
        
        reloadBtn.hidden = NO;
        activityIndicator.hidden = YES;
        [activityIndicator stopAnimating];
        if ([webView_ canGoBack]) {
            backLinkBtn.enabled = YES;
        } else {
            backLinkBtn.enabled = NO;
        }
        
        if ([webView_ canGoForward]) {
            fwdLinkBtn.enabled = YES;
        } else {
            fwdLinkBtn.enabled = NO;
        }
        
//        NSString* js =
//        @"var meta = document.createElement('meta'); " \
//        "meta.setAttribute( 'name', 'viewport' ); " \
//        "meta.setAttribute( 'content', 'width = 225, height = 255, initial-scale = 0.65, user-scalable = yes' ); " \
//        "document.getElementsByTagName('head')[0].appendChild(meta)";
//        [linkwebView stringByEvaluatingJavaScriptFromString: js];
        
    TCEND
}

- (void)webView:(UIWebView *)webView_ didFailLoadWithError:(NSError *)error {
    
    @try {
        isNetworkIndicator = NO;
        reloadBtn.hidden = NO;
        activityIndicator.hidden = YES;
        [activityIndicator stopAnimating];
        
//        if (error.code == -999)
//            [ShowAlert showError:@"Unable to load requested page"];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIActivityIndicatorView appearance] setColor:[appDelegate colorWithHexString:@"11a3e7"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
