/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "VideoInfoViewController.h"
#import "CustomMoviePlayerViewController.h"
#import "SelectCoverFrameViewController.h"

@interface VideoInfoViewController ()

@end

@implementation VideoInfoViewController

@synthesize filePath;
@synthesize superVC;
@synthesize recordedPath;
@synthesize thumbImg;
@synthesize coverFrameValue;
@synthesize selectFRameVCRef;
@synthesize filterStatus;
@synthesize isLibraryVideo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil clientVideoId:(int)clientVideoId_
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        clientVideoId = clientVideoId_;
    }
    return self;
}

- (void)viewDidLoad {
    TCSTART
    [super viewDidLoad];
    
    appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication]delegate];
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.height, appDelegate.window.frame.size.width - 20);
    if (![appDelegate.ftue.tagged boolValue]) {
        tagLbl.text = kTagExpr;
    } else {
        tagLbl.text = kTouchToTag;
    }

    tagLbl.layer.borderColor = [UIColor whiteColor].CGColor;
    tagLbl.layer.borderWidth = 1.0;
    tagLbl.layer.cornerRadius = 4.0f;
    tagLbl.layer.masksToBounds = YES;
    
    shareTableView.tableHeaderView = headerView;
    if ([shareTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [shareTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    shareTableView.separatorColor = [appDelegate colorWithHexString:@"11a3e7"];
    
    if (appDelegate.window.frame.size.height > 480) {
    } else {
        privateFeedSwitch.frame = CGRectMake(298, 35, 53, 33);
    }
    
    infoView.text = @"type your video information here";
    infoView.textColor = [UIColor lightGrayColor];
    
    if (CURRENT_DEVICE_VERSION >= 7.0) {
        shareTableView.frame = CGRectMake(shareTableView.frame.origin.x, shareTableView.frame.origin.y, shareTableView.frame.size.width, shareTableView.frame.size.height - 20);
        uploadBtn.frame = CGRectMake(uploadBtn.frame.origin.x, uploadBtn.frame.origin.y - 20, uploadBtn.frame.size.width, uploadBtn.frame.size.height);
    }
    
    [self setRightAndLeftImagesToSwitches:privateFeedSwitch tag:1];
    [self setRightAndLeftImagesToSwitches:publicSwitch tag:2];
    [self setRightAndLeftImagesToSwitches:followersSwitch tag:3];
    
    shareSocialDict = [[NSMutableDictionary alloc] init];
    sharingType = 1;
    tagRLaterView.hidden = YES;
    TCEND
}

- (void)viewWillAppear:(BOOL)animated {
    TCSTART
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if ([self isNotNull:thumbImg]) {
         UIImage *croppedImage = [appDelegate getImageByCroppingImage:thumbImg toRect:CGRectMake((thumbImg.size.width - 320)/2, (thumbImg.size.height - 320)/2, 320, 320)];
        videoThumbNail.image = croppedImage;
//        [self createVideoThumbNailImage];
        tagRLaterViewBgView.image = thumbImg;
    }
    TCEND
}

//- (void)createVideoThumbNailImage {
//    TCSTART
//    AVAsset *myAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:filePath] options:nil];
//    NSArray *tracksArray = [myAsset tracks];
//    
//    CGFloat frameRate;
//    if (tracksArray.count > 0) {
//        frameRate = [[tracksArray objectAtIndex:0] nominalFrameRate];
//    }
//    
//    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:myAsset];
//    imageGenerator.appliesPreferredTrackTransform = YES;
//    imageGenerator.maximumSize = CGSizeMake(360, 360);
//    
//    NSError *error;
//    CMTime actualTime;
//    CMTime timeFrame = CMTimeMakeWithSeconds(coverFrameValue, 600);
//    CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:timeFrame actualTime:&actualTime error:&error];
//    UIImage *iamge = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
//    videoThumbNail.image = iamge;
//
//    TCEND
//}

- (void)viewDidAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

//- (BOOL)tagsAreCreatedToThisVideo {
//    TCSTART
//    NSLog(@"ClientVideoId :%d",clientVideoId);
//    NSArray *array = [[DataManager sharedDataManager] getAllTagsByVideoIdAndClientVideoId:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",clientVideoId],@"clientVideoId", nil]];
//    if ([self isNotNull:array] && array.count > 0) {
//        return YES;
//    } else {
//        return NO;
//    }
//    TCEND
//}

- (void) viewDidLayoutSubviews {
    if (CURRENT_DEVICE_VERSION >= 7.0  && self.view.frame.size.height == appDelegate.window.frame.size.width) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.origin.y = -topBarOffset;
        self.view.bounds = viewBounds;
    }
}

- (void)setRightAndLeftImagesToSwitches:(UICustomSwitch *)customSwitch tag:(int)tag {
    TCSTART
    
    customSwitch.leftLabel.text = @"";
    customSwitch.rightLabel.text = @"";
    
    [customSwitch setThumbImage:[UIImage imageNamed:@"ToggleThumb"] forState:UIControlStateNormal];
    [customSwitch setMinimumTrackImage:[[UIImage imageNamed:@"ToggleOn"]resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)] forState:UIControlStateNormal];
    [customSwitch setMaximumTrackImage:[[UIImage imageNamed:@"ToggleOff"]resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)] forState:UIControlStateNormal];
    customSwitch.tag = tag;
    [customSwitch addTarget:self action:@selector(shareToFrinedsByChangingSwitches:) forControlEvents:UIControlEventValueChanged];
    
    if (tag == 1) {
        privateFeedSwitch = customSwitch;
        // private
        customSwitch.on = NO;
    } else {
        if (tag == 2) {
            publicSwitch = customSwitch;
        } else {
            followersSwitch = customSwitch;
        }
        customSwitch.on = YES;
    }
    
    TCEND
}
//- (void) viewDidLayoutSubviews {
//    if (CURRENT_DEVICE_VERSION >= 7.0) {
//        CGRect viewBounds = self.view.bounds;
//        CGFloat topBarOffset = self.topLayoutGuide.length;
//        viewBounds.size.height = viewBounds.size.height - topBarOffset;
//        self.view.frame = CGRectMake(viewBounds.origin.x, topBarOffset, viewBounds.size.width, viewBounds.size.height);
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    }
//}
//
//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

- (void)shareToFrinedsByChangingSwitches:(id)sender {
    UICustomSwitch *customSwt = (UICustomSwitch *)sender;
    if (customSwt.tag == 1) {
       //Private
        [self setPrivateSwitchState:(privateFeedSwitch.on?YES:NO)];
    } else if (customSwt.tag == 2) {
        //Public
        [self setPublicSwitchState:(publicSwitch.on?YES:NO)];
    } else {
        //Follower
        [self setFollowerSwitchState:(followersSwitch.on?YES:NO)];
    }
}

- (void)setPrivateSwitchState:(BOOL)state {
    if (state) {
        privateFeedSwitch.on = YES;
        publicSwitch.on = NO;
        followersSwitch.on = NO;
        sharingType = 0;
    } else {
        privateFeedSwitch.on = NO;
        publicSwitch.on = YES;
        followersSwitch.on = YES;
        sharingType = 1;
    }
}

- (void)setFollowerSwitchState:(BOOL)state {
    if (state) {
        publicSwitch.on = NO;
        privateFeedSwitch.on = NO;
        followersSwitch.on = YES;
        sharingType = 2;
    } else {
        [self setPrivateSwitchState:YES];
    }
}

- (void)setPublicSwitchState:(BOOL)state {
    [self setPrivateSwitchState:!state];
}

- (NSNumber *)getSharingTypeValue {
    if (privateFeedSwitch.on) {
        return [NSNumber numberWithInt:0];
    } else if (publicSwitch.on) {
        return [NSNumber numberWithInt:1];
    } else if (followersSwitch.on) {
        return [NSNumber numberWithInt:2];
    } else {
        return [NSNumber numberWithInt:1];
    }
}


////-(IBAction)tag:(id)sender {
////    TCSTART
////    BOOL showInstruntnScreen = ![self tagsAreCreatedToThisVideo];
////    CustomMoviePlayerViewController *customMoviePlayerVC = [[CustomMoviePlayerViewController alloc]initWithNibName:@"CustomMoviePlayerViewController" bundle:nil video:nil videoFilePath:filePath andClientVideoId:[NSString stringWithFormat:@"%d",clientVideoId] showInstrcutnScreen:showInstruntnScreen];
////    customMoviePlayerVC.caller = self;
////    [self presentViewController:customMoviePlayerVC animated:YES completion:nil];
////    TCEND
////}
////
////- (void)playerScreenDismissed {
////    TCSTART
////    tagRLaterView.hidden = YES;
////    if (![self tagsAreCreatedToThisVideo]) {
////        [ShowAlert showAlert:@"Remember to tag your video anytime after the video is uploaded"];
////    }
////    TCEND
////}
////- (void)clickedOnPlayerScreenBackButton {
////    TCSTART
////    [self back:Nil];
////    TCEND
////}
//- (IBAction)onClickOfTagRLaterCancel:(id)sender {
//    TCSTART
//    tagRLaterView.hidden = YES;
//    TCEND
//}

- (IBAction)publish:(id)sender {
    TCSTART
    if (infoView.textColor != [UIColor lightGrayColor] && infoView.text.length > 0) {
        infoView.text = [appDelegate removingLastSpecialCharecter:infoView.text];
    }
    
    if (infoView.textColor != [UIColor lightGrayColor] && infoView && infoView.text.length > 0) {
        appDelegate.ftue.videoUploaded = [NSNumber numberWithBool:YES];
        NSString *creationTime = [appDelegate formattedGMTDateInString];
        NSLog(@"LoggedInUserId:%@",appDelegate.loggedInUser.userId);
        NSMutableDictionary *videoDict = [[NSMutableDictionary  alloc] initWithObjectsAndKeys:filePath,@"path",creationTime,@"creationTime",[NSNumber numberWithBool:FALSE],@"isUploading",[NSNumber numberWithBool:FALSE],@"isUploaded",[NSNumber numberWithBool:TRUE],@"waitingToUpload",[NSString stringWithFormat:@"%d",clientVideoId],@"clientId",infoView.text?:@"",@"title",/*infoView.text?:@"",@"info",*/[NSNumber numberWithInt:sharingType],@"public",appDelegate.loggedInUser.userId,@"uid",[NSNumber numberWithFloat:coverFrameValue],@"frame_time",[NSNumber numberWithInt:filterStatus],@"filterNumber",[NSNumber numberWithBool:isLibraryVideo],@"isLibraryVideo", nil];
        
        [videoDict addEntriesFromDictionary:shareSocialDict];
        [[DataManager sharedDataManager] addVideo:videoDict];
        
        appDelegate.isRecordingScreenDisplays = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:recordedPath] && ![recordedPath isEqualToString:filePath]) {
            [[NSFileManager defaultManager]removeItemAtPath:recordedPath error:nil];
        }
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
        
        [self checkForAlertViewDisplay];
        
    } else {
        [ShowAlert showWarning:@"Please add some description about your video"];
    }
    
    TCEND
}

- (void)checkForAlertViewDisplay {
    TCSTART
//    NSArray *pendingPublishVideos = [appDelegate.managedObjectContext fetchObjectsForEntityName:@"Video" withPredicate:[NSPredicate predicateWithFormat:@"waitingToUpload == %d && fileUploadCompleted == %d && userId == %@ && hitCount <= 2",TRUE,TRUE,appDelegate.loggedInUser.userId]];
//    NSArray *pendingUploads = [appDelegate.managedObjectContext fetchObjectsForEntityName:@"Video" withPredicate:[NSPredicate predicateWithFormat:@"waitingToUpload == %d && fileUploadCompleted == %d && userId == %@ && checkSumFailed == %d",TRUE,FALSE,appDelegate.loggedInUser.userId,FALSE]];
    
    if (appDelegate.isUploading) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Hey! We have some pending video which is getting uploaded. This video will be added to pending videos queue." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        [appDelegate performSelector:@selector(uploadVideo) withObject:nil afterDelay:0.1];
        [superVC dismissViewControllerAnimated:YES completion:nil];
        [appDelegate showVideoFeedScreenWithUploadProgressBar];
    }
    TCEND
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    TCSTART
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:NO];
    [appDelegate performSelector:@selector(uploadVideo) withObject:nil afterDelay:0.1];
    [superVC dismissViewControllerAnimated:YES completion:nil];
    TCEND
}

- (IBAction)cancel:(id)sender {
    TCSTART
    appDelegate.isRecordingScreenDisplays = NO;
    NSLog(@"sharing value %d",sharingType);
    if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
    }
    if ([[NSFileManager defaultManager]fileExistsAtPath:recordedPath]) {
        [[NSFileManager defaultManager]removeItemAtPath:recordedPath error:nil];
    }
    [[DataManager sharedDataManager] deleteAllTagsWhereClientVideoId:[NSNumber numberWithInt:clientVideoId]];
    
    [superVC dismissViewControllerAnimated:YES completion:nil];
    TCEND
}


- (IBAction)back:(id)sender {
    TCSTART
    [selectFRameVCRef videoInfoScreenBackClicked];
    [self.navigationController popViewControllerAnimated:YES];
    TCEND
}


//- (void)setViewMovedUp:(BOOL)movedUp {
//    @try {
//#define kOFFSET_FOR_KEYBOARD 110
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDuration:0.5]; // if you want to slide up the view
//        
//        CGRect viewRect = self.view.frame;
//        if (movedUp) {
//            isViewModeUp = YES;
//            // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
//            // 2. increase the size of the view so that the area behind the keyboard is covered up.
//            //bgImageViewRect.size.height -= kOFFSET_FOR_KEYBOARD;
//            //bgImageViewRect.origin.y  += 75;
//            // bgImageViewRect.size.height -= 10;
//            viewRect.origin.y -= /*(appDelegate.window.frame.size.height > 480) ?kOFFSET_FOR_KEYBOARDiPhone : */kOFFSET_FOR_KEYBOARD;
//            //            viewRect.size.height += /*(appDelegate.window.frame.size.height > 480) ?kOFFSET_FOR_KEYBOARDiPhone : */kOFFSET_FOR_KEYBOARD;
//        } else {
//            isViewModeUp = NO;
//            // revert back to the normal state.
//            // bgImageViewRect.size.height += kOFFSET_FOR_KEYBOARD;
//            //bgImageViewRect.origin.y  -= 75;
//            // bgImageViewRect.size.height += 10;
//            
//            viewRect.origin.y += /*(appDelegate.window.frame.size.height > 480) ?kOFFSET_FOR_KEYBOARDiPhone : */kOFFSET_FOR_KEYBOARD;
//            //            viewRect.size.height -= /*(appDelegate.window.frame.size.height > 480) ?kOFFSET_FOR_KEYBOARDiPhone : */kOFFSET_FOR_KEYBOARD;
//        }
//        self.view.frame = viewRect;
//        
//        [UIView commitAnimations];
//        
//    }
//    @catch (NSException *exception) {
//        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
//    }
//    @finally {
//    }
//}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [toastView removeFromSuperview];
//    toastView = nil;

    [infoView resignFirstResponder];
}
//- (void)tap:(UITapGestureRecognizer *)tapRec {
//    [[self view] endEditing: YES];
//}
//
//#pragma mark - gesture delegate
//// this allows you to dispatch touches
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    
//    // Disallow recognition of tap gestures in the UIButton.
//    if (([touch.view isKindOfClass:[UIButton class]])) {
//        return NO;
//    }
//        
//    return YES;
//}


#pragma mark Tableview datasource and delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
        static NSString *cellIdentifier = @"shareCellId";
        
        UIImageView *shareIamgeView = nil;
        UILabel *shareLabel = nil;
        UICustomSwitch *connectSwitch = nil;
    
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            shareIamgeView = [[UIImageView alloc] initWithFrame:CGRectMake((appDelegate.window.frame.size.height > 480)?149:105, 5, 45 , 45)];
            shareIamgeView.tag = 1;
            [cell addSubview:shareIamgeView];
            
            shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(shareIamgeView.frame.origin.x+ shareIamgeView.frame.size.width + 10, 15, 60, 25)];
            shareLabel.backgroundColor = [UIColor clearColor];
            shareLabel.textColor = [appDelegate colorWithHexString:@"11a3e7"];
            shareLabel.tag = 2;
            shareLabel.font = [UIFont fontWithName:titleFontName size:12];
            [cell addSubview:shareLabel];
            
            CGRect connectSwitchRect = CGRectMake(shareLabel.frame.origin.x + shareLabel.frame.size.width + 105, 11, 53, 33);
            connectSwitch = [UICustomSwitch switchWithLeftText:@"" andRight:@""];
            connectSwitch.frame = connectSwitchRect;
            [connectSwitch setThumbImage:[UIImage imageNamed:@"ToggleThumb" ] forState:UIControlStateNormal];
            [connectSwitch setMinimumTrackImage:[[UIImage imageNamed:@"ToggleOn"]resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)] forState:UIControlStateNormal];
            [connectSwitch setMaximumTrackImage:[[UIImage imageNamed:@"ToggleOff"]resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)] forState:UIControlStateNormal];
            connectSwitch.tag = 3;
            [connectSwitch addTarget:self action:@selector(connectSwitchFlipped: withEvent:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:connectSwitch];
        }
        
        if ([self isNull:shareIamgeView]) {
            shareIamgeView = (UIImageView *)[cell viewWithTag:1];
        }
        
        if ([self isNull:shareLabel]) {
            shareLabel = (UILabel *)[cell viewWithTag:2];
        }
    
        if ([self isNull:connectSwitch]) {
            connectSwitch = (UICustomSwitch *)[cell viewWithTag:3];
        }
    
        if (indexPath.row == 0) {
            shareIamgeView.image = [UIImage imageNamed:@"FBFinder"];
            shareLabel.text = @"Facebook";
            if ([[shareSocialDict objectForKey:@"shareToFB"] boolValue]) {
                connectSwitch.on = YES;
            } else {
                connectSwitch.on = NO;
            }
        } else if (indexPath.row == 1) {
            shareIamgeView.image = [UIImage imageNamed:@"TWFinder"];
            shareLabel.text = @"Twitter";
            if ([[shareSocialDict objectForKey:@"shareToTw"] boolValue]) {
                connectSwitch.on = YES;
            } else {
                connectSwitch.on = NO;
            }
        } else if (indexPath.row == 2) {
            shareIamgeView.image = [UIImage imageNamed:@"GPlusFinder"];
            shareLabel.text = @"Google+";
            if ([[shareSocialDict objectForKey:@"shareToGPlus"] boolValue]) {
                connectSwitch.on = YES;
            } else {
                connectSwitch.on = NO;
            }
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        TCEND
}


#pragma mark Sharing
- (void)connectSwitchFlipped:(UICustomSwitch *)connectSwitch withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:shareTableView];
    if (indexPath.row == 0) {
        //Facebook
        if (connectSwitch.on) {
            //Facebook
            if (!FBSession.activeSession.isOpen) {
                // if the session is closed, then we open it here, and establish a handler for state changes
                [FBSession openActiveSessionWithReadPermissions:appDelegate.facebookReadPermissions allowLoginUI:YES
                                              completionHandler:^(FBSession *session,
                                                                  FBSessionState state,
                                                                  NSError *error) {
                                                  if (error) {
                                                      [ShowAlert showError:@"Authentication failed, please try again"];
                                                      connectSwitch.on = NO;
                                                  } else if (session.isOpen) {
                                                      [shareSocialDict setObject:[NSNumber numberWithBool:YES] forKey:@"shareToFB"];
                                                  }
                                              }];
                
            } else {
                [shareSocialDict setObject:[NSNumber numberWithBool:YES] forKey:@"shareToFB"];
            }
        } else {
            [shareSocialDict setObject:[NSNumber numberWithBool:NO] forKey:@"shareToFB"];
        }
    } else if (indexPath.row == 1) {
        //Twitter
        if (connectSwitch.on) {
            //Twitter
            appDelegate.twitterEngine.delegate = self;
            if(!appDelegate.twitterEngine) {
                [appDelegate initializeTwitterEngineWithDelegate:self];
            }
            [appDelegate.twitterEngine loadAccessToken];
           
            if(![appDelegate.twitterEngine isAuthorized]) {
                [[FHSTwitterEngine sharedEngine] showOAuthLoginControllerFromViewController:self withCompletion:^(BOOL success) {
                    if (!success) {
                        connectSwitch.on = NO;
                    } else {
                        NSLog(@"Twitter login success");
//                       [shareSocialDict setObject:[NSNumber numberWithBool:YES] forKey:@"twitter"];
                    }
                }];
            } else {
                [shareSocialDict setObject:[NSNumber numberWithBool:YES] forKey:@"shareToTw"];
            }
        } else {
            [shareSocialDict setObject:[NSNumber numberWithBool:NO] forKey:@"shareToTw"];
        }
    } else {
        //Google plus
        if (connectSwitch.on) {
            // Google plus
            if (![[GPPSignIn sharedInstance] authentication]) {
                GPPSignIn *signIn = [GPPSignIn sharedInstance];
                signIn.clientID = kGooglePlusClientId;
                signIn.shouldFetchGoogleUserEmail = YES;
                signIn.shouldFetchGoogleUserID = YES;
                [signIn setScopes:[NSArray arrayWithObjects: @"https://www.googleapis.com/auth/plus.login", @"https://www.googleapis.com/auth/userinfo.email", @"https://www.googleapis.com/auth/plus.me", nil]];
                signIn.delegate = self;
               
                [signIn authenticate];
            } else {
                [shareSocialDict setObject:[NSNumber numberWithBool:YES] forKey:@"shareToGPlus"];
            }
        } else {
            [shareSocialDict setObject:[NSNumber numberWithBool:NO] forKey:@"shareToGPlus"];
        }
    }
    
    TCEND
}

#pragma mark facebook Login

#pragma mark twitter login
- (void)storeAccessToken:(NSString *)body {
    NSLog(@"Got tw oauth response %@",body);
    [[NSUserDefaults standardUserDefaults]setObject:body forKey:@"SavedAccessHTTPBody"];
    if ([self isNull:appDelegate.loggedInUser.socialContactsDictionary]) {
        appDelegate.loggedInUser.socialContactsDictionary = [[NSMutableDictionary alloc] init];
    }
    [appDelegate.loggedInUser.socialContactsDictionary setObject:appDelegate.twitterEngine.loggedInUsername?:@"" forKey:@"TW"];
    [shareSocialDict setObject:[NSNumber numberWithBool:YES] forKey:@"shareToTw"];
}

-(NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
}
#pragma mark Google plus login
- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    UITableViewCell *cell = (UITableViewCell *)[shareTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    UICustomSwitch *gplusSwitch = (UICustomSwitch *)[cell viewWithTag:3];
    if (error) {
        [ShowAlert showError:@"Authentication failed, please try again"];
        gplusSwitch.on = NO;
    } else {
        [shareSocialDict setObject:[NSNumber numberWithBool:YES] forKey:@"shareToGPlus"];
    }
}

#pragma mark textview delgate methods
#pragma mark TextView Delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    @try {
        if (textView.textColor == [UIColor lightGrayColor]) {
            textView.text = @"";
            infoView.textColor = [appDelegate colorWithHexString:@"11a3e7"];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    TCSTART
    // Don't allow input beyond the char limit, other then backspace and cut
    if (textView.textColor == [UIColor lightGrayColor]) {
        textView.text = @"";
        infoView.textColor = [appDelegate colorWithHexString:@"11a3e7"];
    }
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
    TCEND
}

- (void)textViewDidChange:(UITextView *) textView  {
    @try {
        
        if (infoView.textColor != [UIColor lightGrayColor]) {
            
        }
        
        if(textView.text.length == 0 && infoView.textColor != [UIColor lightGrayColor]) {
            textView.textColor = [UIColor lightGrayColor];
            textView.text = @"type your video information here";
            [textView setSelectedRange:NSMakeRange(0, 0)];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    TCSTART
    if(textView.text.length == 0 && infoView.textColor != [UIColor lightGrayColor]) {
        textView.textColor = [UIColor lightGrayColor];
        textView.text = @"type your video information here";
        [textView setSelectedRange:NSMakeRange(0, 0)];
    }
    [textView resignFirstResponder];
    TCEND
}


//iOS 5 and earlier
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if((interfaceOrientation == UIInterfaceOrientationLandscapeRight)||(interfaceOrientation == UIInterfaceOrientationLandscapeLeft))
	{
		return YES;
	}
	else
        return NO;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
