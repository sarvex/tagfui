/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "ShareViewController.h"
#import "CustomMoviePlayerViewController.h"
#import "FriendsViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withSelectedVideo:(VideoModal *)video andCaller:(id)caller_
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        selectedVideo = video;
        caller = caller_;
    }
    return self;
}

- (void)viewDidLoad {
    TCSTART
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height - 20);
    shareDetailsArray = [[NSArray alloc] initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"FBFinder",@"image",@"Facebook",@"title", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"TWFinder",@"image",@"Twitter",@"title", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"GPlusFinder",@"image",@"Google+",@"title", nil]/**,[NSDictionary dictionaryWithObjectsAndKeys:@"WootagSharBtn",@"image",@"Wootag",@"title", nil]*/,[NSDictionary dictionaryWithObjectsAndKeys:@"ShareMail",@"image",@"Email",@"title", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Contacts",@"image",@"Contacts",@"title", nil], nil];
    
    if ([shareTableView respondsToSelector:@selector(setSeparatorInset:)]) {
//        shareTableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
        [shareTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    shareTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, shareTableView.bounds.size.width, 0.01f)];
    shareTableView.separatorColor = [appDelegate colorWithHexString:@"11a3e7"];
    shareTableView.backgroundColor = [UIColor clearColor];
//    http:\/\/wootagvideostorage.s3.amazonaws.com\/78e78abbcd6a74103a701e19a99cc6d8-640x320_0000.jpg
    [videoThumbImgView setImageWithURL:[NSURL URLWithString:selectedVideo.videoThumbPath] placeholderImage:[UIImage imageNamed:@"DefaultVideoThumb"]];
    
    TCEND
}

//- (NSString *)getImagePath {
//    TCSTART
//    NSString *imagePath;
//    NSArray *array = [selectedVideo.videoThumbPath componentsSeparatedByString:@"-640x"];
//    if (array.count >= 2) {
//        imagePath = [NSString stringWithFormat:@"%@-640x320_0000.jpg",[array objectAtIndex:0]];
//    }
//    return imagePath;
//    TCEND
//}
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

- (IBAction)goBack:(id)sender {
    TCSTART
    if ([self isNotNull:caller] && ([caller isKindOfClass:[CustomMoviePlayerViewController class]] || [caller isKindOfClass:[WooTagPlayerAppDelegate class]])) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        if ([caller isKindOfClass:[VideoFeedAndMoreVideosViewController class]]) {
            [caller setBoolValueForControllerVariable];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    TCEND
}

- (void)dismissedContactsViewController {
    shareContactsVC = nil;
}

#pragma mark Tableview Delegate and Datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return shareDetailsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25; //25
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
    
    UIImageView *headerBannerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
    headerBannerImgView.image = [UIImage imageNamed:@"ShareTitleBanner"];
    
    //    UILabel *backgorundLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
    //    backgorundLabel.backgroundColor = [appDelegate colorWithHexString:@"01739b"];
    
    UILabel *shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 25)];
    shareLabel.backgroundColor = [UIColor clearColor];
    shareLabel.textColor = [UIColor whiteColor];
    shareLabel.font = [UIFont fontWithName:descriptionTextFontName size:13];
    shareLabel.text = @"SHARE TO";
    [headerView addSubview:headerBannerImgView];
    [headerView addSubview:shareLabel];
    
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    
    static NSString *cellIdentifier = @"cellId";
    
    UIImageView *shareIamgeView = nil;
    UILabel *shareLabel = nil;
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        shareIamgeView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 45 , 45)];
        shareIamgeView.tag = 1;
        [cell addSubview:shareIamgeView];
        
        shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 5, 100, 55)];
        shareLabel.backgroundColor = [UIColor clearColor];
        shareLabel.textColor = [appDelegate colorWithHexString:@"11a3e7"];
        shareLabel.tag = 2;
        shareLabel.font = [UIFont fontWithName:titleFontName size:14];
        [cell addSubview:shareLabel];
    }
    
    if ([self isNull:shareIamgeView]) {
        shareIamgeView = (UIImageView *)[cell viewWithTag:1];
    }
    
    if ([self isNull:shareLabel]) {
        shareLabel = (UILabel *)[cell viewWithTag:2];
    }
    
    NSDictionary *dict = [shareDetailsArray objectAtIndex:indexPath.row];
    
    shareLabel.text = [dict objectForKey:@"title"];
    
    shareIamgeView.image = [UIImage imageNamed:[dict objectForKey:@"image"]];
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
    TCEND
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if (indexPath.row == 0) {
        if (!FBSession.activeSession.isOpen) {
            [appDelegate loginThroughFacebookFromCaller:self];
        } else {
            [self FBLoginSuccessful];
        }
        
    } else if (indexPath.row == 1) {
        [self onSelectedTwitter];
    } else if (indexPath.row == 2) {
        [self onClickOfGPlus];
    } else if (indexPath.row == 3) {
        [self shareVideoInfoThroughMail];
    } else if (indexPath.row == 4) {
        [self openShareVideoInfoThroughMessage];
    }
    TCEND
}

#pragma mark Address contacts
- (void)openShareVideoInfoThroughMessage {
    TCSTART
    if (CURRENT_DEVICE_VERSION >= 6.0) {
        if ([appDelegate getAccessPermission]) {
            [self getAddressBookContacts];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Please Allow Access"
                                        message:@"Allowing access to the Contacts lets you send message. \n Please go to settings > Privacy > Contacts to allow Wootag to show your contacts."
                                       delegate:nil
                              cancelButtonTitle:@"Ok,I understand"
                              otherButtonTitles:nil] show];
        }
    } else {
        [self getAddressBookContacts];
    }
    
    TCEND
}

- (void)getAddressBookContacts {
    TCSTART
    [self initialiseAndPresentShareContactsViewControllerWithType:@"Contacts"];
    shareContactsVC.friendsVC.isContactsLoaded = YES;
    [shareContactsVC.friendsVC setImageForSearchBgPlaceholder];
    
    [shareContactsVC.friendsVC.friendsList addObjectsFromArray:[appDelegate getAddressBookContacts]];
    shareContactsVC.friendsVC.isLoadingFriends = NO;
    [shareContactsVC.friendsVC reloadData];
    TCEND
}

#pragma mark ShareContactsViewController
- (void)initialiseAndPresentShareContactsViewControllerWithType:(NSString *)type {
    TCSTART
    if ([self isNull:shareContactsVC]) {
        shareContactsVC = [[ShareContactsViewController alloc] initWithNibName:@"ShareContactsViewController" bundle:nil andType:type andCaller:self];
        
        [self presentViewController:shareContactsVC animated:YES completion:nil];
    }
    TCEND
}

#pragma mark FB
- (void)FBLoginSuccessful {
    TCSTART
    
    if ([self isNull:shareContactsVC]) {
        [self initialiseAndPresentShareContactsViewControllerWithType:@"FB"];
        shareContactsVC.friendsVC.isFBFriendsLoaded = YES;
        [shareContactsVC.friendsVC setImageForSearchBgPlaceholder];
        [FBRequestConnection startWithGraphPath:@"me" parameters:[NSDictionary dictionaryWithObject:@"picture,username,email,name" forKey:@"fields"] HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
            if (error) {
                GTMLoggerError(@"error:%@",error);
                shareContactsVC.friendsVC.isLoadingFriends = NO;
                [shareContactsVC.friendsVC reloadData];
            } else {
                NSMutableArray *friends = [[NSMutableArray alloc]init];
                NSMutableDictionary *userInfoDict = [[NSMutableDictionary alloc]init];
                [userInfoDict setObject:[result objectForKey:@"email"]?:@"" forKey:@"email"];
                [userInfoDict setObject:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",[result objectForKey:@"id"]]?:@"" forKey:@"image"];
                [userInfoDict setObject:[result objectForKey:@"name"]?:@"" forKey:@"displayname"];
                [userInfoDict setObject:[result objectForKey:@"id"] forKey:@"id"];
                [shareContactsVC.friendsVC.loggedInUserDictArray addObject:userInfoDict];
                
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
    TCEND
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
                NSDictionary *friend = [[NSDictionary alloc]initWithObjectsAndKeys:[userDict objectForKey:@"name"]?:@"",@"displayname",[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",[userDict objectForKey:@"id"]]?:@"",@"image",[userDict objectForKey:@"id"]?:@"",@"id", nil];
                [pagesArray addObject:friend];
            }
            shareContactsVC.friendsVC.pagesArray = pagesArray;
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
            shareContactsVC.friendsVC.isLoadingFriends = NO;
            [shareContactsVC.friendsVC reloadData];
        } else {
            NSLog(@"Result:%@",result);
            for(NSDictionary *userDict in [result objectForKey:@"data"]) {
                NSDictionary *friend = [[NSDictionary alloc]initWithObjectsAndKeys:[userDict objectForKey:@"name"]?:@"",@"displayname",[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",[userDict objectForKey:@"id"]]?:@"",@"image",[userDict objectForKey:@"id"]?:@"",@"id", nil];
                [friends addObject:friend];
            }
            [shareContactsVC.friendsVC.friendsList addObjectsFromArray:friends];
            [shareContactsVC.friendsVC reloadData];
        }
    }];
    
    TCEND
}
//- (void)FBLoginSuccessful {
//    TCSTART
//    friendsVC = [self loadFriendsViewController];
//    friendsVC.isFBFriendsLoaded = YES;
//    [FBRequestConnection startWithGraphPath:@"me/friends" completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
//        if (error) {
//            GTMLoggerError(@"error:%@",error);
//            friendsVC.isLoadingFriends = NO;
//            [friendsVC reloadData];
//        } else {
//            NSLog(@"Result:%@",result);
//            NSMutableArray *friends = [[NSMutableArray alloc]init];
//            for(NSDictionary *userDict in [result objectForKey:@"data"]) {
//                NSDictionary *friend = [[NSDictionary alloc]initWithObjectsAndKeys:[userDict objectForKey:@"name"]?:@"",@"displayname",[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",[userDict objectForKey:@"id"]]?:@"",@"image",[userDict objectForKey:@"id"]?:@"",@"id", nil];
//                [friends addObject:friend];
//            }
//            [friendsVC.friendsList addObjectsFromArray:friends];
//            [friendsVC reloadData];
//        }
//    }];
//    TCEND
//}

- (void)finishedPickingFBFriend:(NSString *)fbId {
    TCSTART
    shareContactsVC = nil;
    if (FBSession.activeSession.isOpen) {
        [appDelegate performPublishAction:^ {
            [appDelegate postToFacebookUserWallWithOutDialog:selectedVideo andToId:fbId];
        }];
    } else {
        [appDelegate postToFacebookUserWallWithOutDialog:selectedVideo andToId:fbId];
    }
    
    TCEND
}

#pragma Twitter
- (void)onSelectedTwitter {
    TCSTART
    appDelegate.twitterEngine.delegate = (id)self;
    if(!appDelegate.twitterEngine) {
        [appDelegate initializeTwitterEngineWithDelegate:self];
    }
    [appDelegate.twitterEngine loadAccessToken];
    if(![appDelegate.twitterEngine isAuthorized]) {
        [[FHSTwitterEngine sharedEngine] showOAuthLoginControllerFromViewController:self withCompletion:^(BOOL success) {
            if (!success) {
                [ShowAlert showError:@"Authentication failed, please try again"];
            } else {
//                [self requestForTWFollowersList:@"-1" loadMore:NO];
            }
        }];
    } else {
        [self requestForTWFollowersList:@"-1" loadMore:NO];
    }
    TCEND
}

- (void)storeAccessToken:(NSString *)body {
    TCSTART
    NSLog(@"Got tw oauth response %@",body);
    [[NSUserDefaults standardUserDefaults]setObject:body forKey:@"SavedAccessHTTPBody"];
    [self performSelector:@selector(getTWFollowers) withObject:nil afterDelay:0.7];
    TCEND
}

- (void)getTWFollowers {
    TCSTART
    if ([self isNull:appDelegate.loggedInUser.socialContactsDictionary]) {
        appDelegate.loggedInUser.socialContactsDictionary = [[NSMutableDictionary alloc] init];
    }
    [appDelegate.loggedInUser.socialContactsDictionary setObject:appDelegate.twitterEngine.loggedInUsername?:@"" forKey:@"TW"];
    if (appDelegate.twitterEngine.loggedInUsername.length > 0) {
        [self requestForTWFollowersList:@"-1" loadMore:NO];
    }
    TCEND
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
}


//- (void)requestForTWFollowersList:(NSString *)pageNumber loadMore:(BOOL) loadMore {
//    TCSTART
//    [self initialiseAndPresentShareContactsViewControllerWithType:@"TW"];
//    shareContactsVC.friendsVC.isTWFriendsLoaded = YES;
//    [shareContactsVC.friendsVC setImageForSearchBgPlaceholder];
//    NSDictionary *dict = [appDelegate.twitterEngine getUserProfileForUserId:appDelegate.twitterEngine.loggedInID];
//    NSDictionary *userDict = [[NSDictionary alloc]initWithObjectsAndKeys:[dict objectForKey:@"name"]?:@"",@"displayname",[dict objectForKey:@"profile_image_url_https"]?:@"",@"image",[[dict objectForKey:@"id"] stringValue],@"id",[dict objectForKey:@"description"]?:@"",@"description",[dict objectForKey:@"location"]?:@"",@"location",[dict objectForKey:@"screen_name"]?:@"",@"screen_name",[dict objectForKey:@"url"]?:@"",@"url", nil];
//    
//    dispatch_async(GCDBackgroundThread, ^{
//        @autoreleasepool {
//            id twitterData = [appDelegate.twitterEngine listFriendsForUser:appDelegate.twitterEngine.loggedInUsername isID:NO withCursor:pageNumber];
//            // Handle twitterData (see "About GET Requests")
//            dispatch_sync(GCDMainThread, ^{
//                @autoreleasepool {
//                    // Update UI
//                    shareContactsVC.friendsVC.isLoadingFriends = NO;
//                    [shareContactsVC.friendsVC formatTWDataAndReloadFriendsTable:twitterData loggedInUserInfo:userDict andRequestForLoadMore:loadMore];
//                }
//            });
//        }
//    });
//    TCEND
//}

- (void)requestForTWFollowersList:(NSString *)pageNumber loadMore:(BOOL) loadMore {
    TCSTART

    if (!loadMore) {
        [self initialiseAndPresentShareContactsViewControllerWithType:@"TW"];
        shareContactsVC.friendsVC.isTWFriendsLoaded = YES;
        [shareContactsVC.friendsVC setImageForSearchBgPlaceholder];
        dispatch_async(GCDBackgroundThread, ^{
            @autoreleasepool {
                NSDictionary *dict = [appDelegate.twitterEngine getUserProfileForUserId:appDelegate.twitterEngine.loggedInID];
                NSDictionary *userDict;
                if ([self isNotNull:dict] && [dict isKindOfClass:[NSDictionary class]] && [self isNotNull:[dict objectForKey:@"name"]]) {
                    userDict = [[NSDictionary alloc]initWithObjectsAndKeys:[dict objectForKey:@"name"]?:@"",@"displayname",[dict objectForKey:@"profile_image_url_https"]?:@"",@"image",[[dict objectForKey:@"id"] stringValue],@"id",[dict objectForKey:@"description"]?:@"",@"description",[dict objectForKey:@"location"]?:@"",@"location",[dict objectForKey:@"screen_name"]?:@"",@"screen_name",[dict objectForKey:@"url"]?:@"",@"url", nil];
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
                                        shareContactsVC.friendsVC.isLoadingFriends = NO;
                                        [shareContactsVC.friendsVC formatTWDataAndReloadFriendsTable:twitterData loggedInUserInfo:userDict andRequestForLoadMore:loadMore];
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
                        shareContactsVC.friendsVC.isLoadingFriends = NO;
                        [shareContactsVC.friendsVC formatTWDataAndReloadFriendsTable:twitterData loggedInUserInfo:nil andRequestForLoadMore:loadMore];
                    }
                });
            }
        });
    }
    
    TCEND
}

- (void)finishedPickingTWFriend:(NSString *)twId {
    TCSTART
    NSString *string = [NSString stringWithFormat:@"%@\n%@",selectedVideo.latestTagExpression?:selectedVideo.title,selectedVideo.shareUrl];
    [appDelegate PostToTwitterWithMsg:string toUser:twId withImageUrl:selectedVideo.videoThumbPath andVideoId:selectedVideo.videoId];
    shareContactsVC = nil;
    TCEND
}

#pragma mark
#pragma mark GPlus
#pragma mark GPlus SignIn & Delegate Methods
- (void)onClickOfGPlus {
    TCSTART
    if ([[GPPSignIn sharedInstance] authentication]) {
        // The user is signed in.
        GPPSignIn *signIn = [GPPSignIn sharedInstance];
        signIn.shouldFetchGoogleUserEmail = YES;
        
        GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
        plusService.retryEnabled = YES;
        [plusService setAuthorizer:signIn.authentication];
        if ([self isNull:appDelegate.loggedInUser.socialContactsDictionary]) {
            appDelegate.loggedInUser.socialContactsDictionary = [[NSMutableDictionary alloc] init];
        }
        [appDelegate.loggedInUser.socialContactsDictionary setObject:signIn.authentication.userEmail?:@"" forKey:@"GPLUS"];
        
        GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
        [plusService executeQuery:query
                completionHandler:^(GTLServiceTicket *ticket,
                                    GTLPlusPerson *person,
                                    NSError *error) {
                    if (error) {
                        shareContactsVC.friendsVC.isLoadingFriends = NO;
                        [shareContactsVC.friendsVC reloadData];
                        GTMLoggerError(@"Error: %@", error);
                    } else {
                        NSLog(@"UserINFO :%@\n",person.JSON);
                        NSMutableArray *friends = [[NSMutableArray alloc]init];
                        NSMutableDictionary *userInfoDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:person.displayName?:@"",@"displayname",person.image.url?:@"",@"image",person.identifier?:@"",@"id",person.currentLocation?:@"",@"description", nil];
                        
                        
                        GTLQueryPlus *listquery =
                        [GTLQueryPlus queryForPeopleListWithUserId:@"me"
                                                        collection:kGTLPlusCollectionVisible];
                        
                        [self initialiseAndPresentShareContactsViewControllerWithType:@"GPlus"];
                        shareContactsVC.friendsVC.isGPlusFriendsLoaded = YES;
                        [shareContactsVC.friendsVC setImageForSearchBgPlaceholder];
                        [shareContactsVC.friendsVC.loggedInUserDictArray addObject:userInfoDict];
                        [plusService executeQuery:listquery
                                completionHandler:^(GTLServiceTicket *ticket,
                                                    GTLPlusPeopleFeed *peopleFeed,
                                                    NSError *error) {
                                    if (error) {
                                        GTMLoggerError(@"Error: %@", error);
                                        shareContactsVC.friendsVC.isLoadingFriends = NO;
                                        [shareContactsVC.friendsVC reloadData];
                                    } else {
                                        // Get an array of people from GTLPlusPeopleFeed
                                        NSArray* peopleList = peopleFeed.items;
                                        NSLog(@"GooglePlus Friends List : %@",peopleList);
                                        shareContactsVC.friendsVC.isLoadingFriends = NO;
                                        
                                        for(GTLPlusPerson *gPlusPersion in peopleList) {
                                            NSDictionary *friend = [[NSDictionary alloc]initWithObjectsAndKeys:gPlusPersion.displayName?:@"",@"displayname",gPlusPersion.image.url?:@"",@"image",gPlusPersion.identifier?:@"",@"id",gPlusPersion.currentLocation?:@"",@"description", nil];
                                            [friends addObject:friend];
                                        }
                                        [shareContactsVC.friendsVC.friendsList addObjectsFromArray:friends];
                                        [shareContactsVC.friendsVC reloadData];
                                    }
                                }];
                        
                    }
                }];
    } else {
        
        GPPSignIn *signIn = [GPPSignIn sharedInstance];
        signIn.clientID = kGooglePlusClientId;
        signIn.shouldFetchGoogleUserEmail = YES;
        signIn.shouldFetchGoogleUserID = YES;
        [signIn setScopes:[NSArray arrayWithObjects: @"https://www.googleapis.com/auth/plus.login", @"https://www.googleapis.com/auth/userinfo.email", @"https://www.googleapis.com/auth/plus.me", nil]];
        signIn.delegate = self;
        [signIn authenticate];
    }
    TCEND
}


- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    if (error) {
       [ShowAlert showError:@"Authentication failed, please try again"];
    } else {
        NSLog(@"GPlus SignIn Success");
        [self onClickOfGPlus];
        //        [self shareToGooglePlusUserWithUserId:@"me"];
    }
}

- (void)shareToGooglePlusUserWithUserId:(NSArray *)friendsIdsArray {
    TCSTART
    shareContactsVC = nil;
    [appDelegate shareToGooglePlusUserWithUserId:friendsIdsArray andVideo:selectedVideo];
    TCEND
}

- (void)finishedSharing: (BOOL)shared {
    if (shared) {
//        [ShowAlert showAlert:@"Shared successfully"];
    } else {
        [ShowAlert showAlert:@"Something went wrong, please share again"];
    }
}

#pragma mark share through Message
#pragma mark ShareSpecial Through Message
- (void)shareVideoInfoThroughMessage:(NSArray *)contactsArray {
    TCSTART
    shareContactsVC = nil;
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText]) {
        
        NSString *message;
        if (contactsArray.count > 1) {
            controller.recipients = [contactsArray valueForKey:@"phonenumber"];
            message = [NSString stringWithFormat:@"Hi All, Loved this video on Wootag\n\n\n%@\n%@\n\n\nThis video is clickable, Watch and click the tags(icons) inside the video and discover more.\nIts great!Try this app www.wootag.com/invite.html",selectedVideo.latestTagExpression?:selectedVideo.title,selectedVideo.shareUrl];
            [controller setBody:message];
        } else {
            NSDictionary *dict = [contactsArray objectAtIndex:0];
            controller.recipients = [contactsArray valueForKey:@"phonenumber"];
            message = [NSString stringWithFormat:@"Hi %@, Loved this video on Wootag\n\n\n%@\n%@\n\n\nThis video is clickable, Watch and click the tags(icons) inside the video and discover more.\nIts great!Try this app www.wootag.com/invite.html",[dict objectForKey:@"user_name"],selectedVideo.latestTagExpression?:selectedVideo.title,selectedVideo.shareUrl];
            [controller setBody:message];
        }
        
        message = [NSString stringWithFormat:@"Hi All, Loved this video on Wootag\n\n\n%@\n%@\n\n\nThis video is clickable, Watch and click the tags(icons) inside the video and discover more.\nIts great!Try this app www.wootag.com/invite.html",selectedVideo.latestTagExpression?:selectedVideo.title,selectedVideo.shareUrl];
        controller.subject = selectedVideo.title;
        controller.messageComposeDelegate = self;
        [self presentModalViewController:controller animated:YES];
    } else {
        
    }
    TCEND
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    TCSTART
    switch (result) {
        case MessageComposeResultCancelled:
            // NSLog(@"Cancelled"
            break;
        case MessageComposeResultFailed:
            [ShowAlert showError:@"Couldn't send the share the message,please try again after some time"];
            break;
        case MessageComposeResultSent: {
            NSLog(@"Message sent");
            [appDelegate makeRequestForAnalyticsOfVideo:selectedVideo.videoId analyticsTagClicksOrShareId:ContactsShare analyticsTagInteractions:FB socialPlatform:FB isForShare:YES isReqForInteractions:NO shareCount:controller.recipients.count];
            break;
        }
        default:
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
    
    TCEND
}

#pragma mark WooTag
- (void)finishedPickingWTFriend:(NSString *)wtId {
    TCSTART
    TCEND
}

#pragma mark
#pragma mark Mail
#pragma mark Sharing through Mail
- (void)shareVideoInfoThroughMail {
    @try {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            NSString *stirng = [NSString stringWithFormat:@"%@\n%@",[NSString stringWithUTF8String:[[NSString stringWithFormat:@"%@",selectedVideo.latestTagExpression?:selectedVideo.title] UTF8String]],selectedVideo.shareUrl];
            [controller setSubject:selectedVideo.title];
            [controller setMessageBody:stirng isHTML:YES];
            
            NSData *thumbPath = [NSData dataWithContentsOfURL:[NSURL URLWithString:selectedVideo.videoThumbPath]];
            UIImage *thumbImage = [UIImage imageWithData:thumbPath];
        
            NSData *thumbData = UIImagePNGRepresentation(thumbImage);
            [controller addAttachmentData:thumbData mimeType:@"image/png" fileName:@"videoscreen.png"];
            [self presentViewController:controller animated:YES completion:nil];
            
        } else {
            [ShowAlert showError:@"OOPS We could not find your mail account, please set it up"];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    @try {
        switch (result) {
            case MFMailComposeResultCancelled:
                break;
            case MFMailComposeResultFailed:
                [ShowAlert showError:@"Something went wrong, please mail again"];
                break;
            case MFMailComposeResultSent:
                [appDelegate makeRequestForAnalyticsOfVideo:selectedVideo.videoId analyticsTagClicksOrShareId:TwitterClicksorMailShare analyticsTagInteractions:FB socialPlatform:FB isForShare:YES isReqForInteractions:NO shareCount:1];
                break;
            default:
                break;
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
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
