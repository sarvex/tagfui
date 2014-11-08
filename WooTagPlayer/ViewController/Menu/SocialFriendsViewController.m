/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "SocialFriendsViewController.h"
#import "SuggestedUserCell.h"
#import <MessageUI/MessageUI.h>

@interface SocialFriendsViewController ()

@end

@implementation SocialFriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andViewType:(NSString *)viewType
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        reqType = viewType;
    }
    return self;
}

- (void)viewDidLoad {
    TCSTART
    [super viewDidLoad];
    next_cursor = @"0";
    isTWFriendsLoaded = NO;
    selectedFreindsList = [[NSMutableArray alloc] init];
    inviteBtn.enabled = NO;
    self.view.backgroundColor = [appDelegate colorWithHexString:@"f8f8f8"];
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height - 20);
    
    friendsSearchBar.keyboardType = UIKeyboardTypeDefault;
    friendsSearchBar.barStyle = UIBarStyleDefault;
    isSearching = NO;
    [self setBackgroundForSearchBar:friendsSearchBar withImagePath:@"SearchBarBg"];
    filteredFriendsList = [[NSMutableArray alloc]init];
    friendsSearchBar.backgroundColor = [UIColor clearColor];
    
    // Do any additional setup after loading the view from its nib.
    
    friendsList = [[NSMutableArray alloc]init];
    
    
    [friendsTable registerNib:[UINib nibWithNibName:@"SuggestedUserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SuggestedUserCellID"];
    friendsTable.backgroundColor = [UIColor clearColor];
    friendsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    friendsTable.frame = CGRectMake(friendsTable.frame.origin.x, friendsTable.frame.origin.y, friendsTable.frame.size.width, self.view.frame.size.height - ((CURRENT_DEVICE_VERSION < 7.0)?93:113));
    
    isLoadingFriends = YES;
    [friendsTable reloadData];
    inviteBtn.hidden = YES;
    if ([reqType caseInsensitiveCompare:@"facebook"] == NSOrderedSame) {
        searchBarBackgroundImg.image = [UIImage imageNamed:@"FBSearch"];
        [self requestForFacebookFriendsList];
        titleLabl.text = @"Facebook";
    } else if ([reqType caseInsensitiveCompare:@"twitter"] == NSOrderedSame) {
        isTWFriendsLoaded = YES;
        [self requestForTWFriendsList];
        titleLabl.text = @"Twitter";
        searchBarBackgroundImg.image = [UIImage imageNamed:@"TWSearch"];
    } else if ([reqType caseInsensitiveCompare:@"PhoneContacts"] == NSOrderedSame) {
        searchBarBackgroundImg.image = [UIImage imageNamed:@"Contacts"];
        [self requestForAddressBookContacts];
        titleLabl.text = @"Contacts";
        inviteBtn.hidden = NO;
    } else {
        [self requestForGPlusFriendsList];
        titleLabl.text = @"Google+";
        searchBarBackgroundImg.image = [UIImage imageNamed:@"GPlusSearch"];
    }
    TCEND
}

- (void) viewDidLayoutSubviews {
    if (CURRENT_DEVICE_VERSION >= 7.0  && self.view.frame.size.height == appDelegate.window.frame.size.height) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.size.height = viewBounds.size.height - topBarOffset;
        self.view.frame = CGRectMake(viewBounds.origin.x, topBarOffset, viewBounds.size.width, viewBounds.size.height);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (IBAction)onClickOfBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)finishedPickingFriendList:(NSMutableArray *)friendsList_ {
    TCSTART
    if ([self isNotNull:appDelegate.loggedInUser.userId]) {
        [appDelegate makeSocialFriendsInfoRequestWithUserId:appDelegate.loggedInUser.userId andCaller:self friendsList:friendsList_];
        if (friendsList.count <= 0) {
            [appDelegate showActivityIndicatorInView:friendsTable andText:@"Loading"];
        }
        
        [appDelegate showNetworkIndicator];
    }
    TCEND
}

- (void)didFinishedToGetSocialNetWorkFriendsInfo:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:friendsTable];
    if ([self isNotNull:results]) {
        isLoadingFriends = NO;
        [friendsList addObjectsFromArray:[results objectForKey:@"friends"]];
        [friendsTable reloadData];
    }
    TCEND
}
- (void)didFailToGetSocialNetWorkFriendsInfoWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:friendsTable];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

- (void)requestForFacebookFriendsList {
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
                                              [self onClickOfBackButton:nil];
                                          } else if (session.isOpen) {
                                              [self requestForFacebookFriendsList];
                                          }
                                      }];
        return;
    } else {
        
        [FBRequestConnection startWithGraphPath:@"me/friends" completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
            
            if (error) {
                isLoadingFriends = NO;
                GTMLoggerError(@"error:%@",error);
                [friendsTable reloadData];
            } else {
                NSLog(@"Result:%@",result);
                NSMutableArray *friends = [[NSMutableArray alloc]init];
                for(NSDictionary *userDict in [result objectForKey:@"data"]) {
                    NSDictionary *friend = [[NSDictionary alloc]initWithObjectsAndKeys:[userDict objectForKey:@"name"]?:@"",@"user_name",[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",[userDict objectForKey:@"id"]]?:@"",@"photo_path",[userDict objectForKey:@"id"]?:@"",@"id",@"",@"description", nil];
                    [friends addObject:friend];
                }
                if (friends.count > 0) {
                    [self finishedPickingFriendList:friends];
                } else {
                    [friendsTable reloadData];
                }
            }
        }];
    }
}

#pragma mark Twittter SignIn & Delegate Methods
- (void)requestForTWFriendsList {
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
                [self onClickOfBackButton:nil];
            } else {

            }
        }];
    } else {
        next_cursor = @"-1";
        [self requestForTWFollowersList];
    }
    TCEND
}
- (void)cancelTwitterAuthentication {
    [appDelegate hideNetworkIndicator];
    [self onClickOfBackButton:nil];
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
        next_cursor = @"-1";
        [self requestForTWFollowersList];
    }
    TCEND
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
}

- (void)requestForTWFollowersList {
    TCSTART
    dispatch_async(GCDBackgroundThread, ^{
        @autoreleasepool {
            id twitterData = [appDelegate.twitterEngine listFriendsForUser:appDelegate.twitterEngine.loggedInUsername isID:NO withCursor:next_cursor];
            // Handle twitterData (see "About GET Requests")
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    [self formatTWDataAndReloadFriendsTable:twitterData];
                }
            });
        }
    });
    
    TCEND
}

- (void)formatTWDataAndReloadFriendsTable:(id)twData {
    TCSTART
    if (twData != nil && [twData isKindOfClass:[NSDictionary class]]) {
        next_cursor = [twData objectForKey:@"next_cursor_str"];
        NSMutableArray *friends = [[NSMutableArray alloc]init];
        NSArray *users = [twData objectForKey:@"users"];
        NSLog(@"UsersCount :%d",users.count);
        for (NSDictionary *user in users) {
            NSDictionary *friend = [[NSDictionary alloc]initWithObjectsAndKeys:[user objectForKey:@"name"]?:@"",@"user_name",[user objectForKey:@"profile_image_url_https"]?:@"",@"photo_path",[NSNumber numberWithLong:[[user objectForKey:@"id"] longValue]],@"id",[user objectForKey:@"description"]?:@"",@"description",[user objectForKey:@"screen_name"],@"screen_name", nil];
            [friends addObject:friend];
        }
        [self finishedPickingFriendList:friends];
    } else {
        next_cursor = @"0";
        isLoadingFriends = NO;
        [friendsTable reloadData];
    }
    
    TCEND
}

#pragma mark GPlus SignIn & Delegate Methods
-(void)requestForGPlusFriendsList {
    TCSTART
    if ([[GPPSignIn sharedInstance] authentication]) {
        // The user is signed in.
        GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
        plusService.retryEnabled = YES;
        [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
        if ([self isNull:appDelegate.loggedInUser.socialContactsDictionary]) {
            appDelegate.loggedInUser.socialContactsDictionary = [[NSMutableDictionary alloc] init];
        }
        [appDelegate.loggedInUser.socialContactsDictionary setObject:[GPPSignIn sharedInstance].authentication.userEmail?:@"" forKey:@"GPLUS"];
        GTLQueryPlus *query =
        [GTLQueryPlus queryForPeopleListWithUserId:@"me"
                                        collection:kGTLPlusCollectionVisible];
        
        [plusService executeQuery:query
                completionHandler:^(GTLServiceTicket *ticket,
                                    GTLPlusPeopleFeed *peopleFeed,
                                    NSError *error) {
                    
                    if (error) {
                        GTMLoggerError(@"Error: %@", error);
                        isLoadingFriends = NO;
                        [friendsTable reloadData];
                        [self onClickOfBackButton:nil];
                    } else {
                        // Get an array of people from GTLPlusPeopleFeed
                        NSArray* peopleList = peopleFeed.items;
                        NSLog(@"GooglePlus Friends List : %@",peopleList);
                        NSMutableArray *friends = [[NSMutableArray alloc]init];
                        for(GTLPlusPerson *gPlusPersion in peopleList) {
                            NSDictionary *friend = [[NSDictionary alloc]initWithObjectsAndKeys:gPlusPersion.displayName?:@"",@"user_name",gPlusPersion.image.url?:@"",@"photo_path",gPlusPersion.identifier?:@"",@"id",gPlusPersion.currentLocation?:@"",@"description", nil];
                            [friends addObject:friend];
                        }
                        [self finishedPickingFriendList:friends];
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
                   error: (NSError *) error {
    if (error) {
        [ShowAlert showError:@"Authentication failed, please try again"];
        isLoadingFriends = NO;
        [friendsTable reloadData];
        [self onClickOfBackButton:nil];
    } else {
        NSLog(@"GPlus SignIn Success");
        [self requestForGPlusFriendsList];
    }
}


#pragma mark Address contacts
- (void)requestForAddressBookContacts {
    TCSTART
    if (CURRENT_DEVICE_VERSION >= 6.0) {
        if ([appDelegate getAccessPermission]) {
            [self getAddressBookContacts];
        } else {
            [self onClickOfBackButton:nil];
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
    isLoadingFriends = YES;
    friendsList = [appDelegate getAddressBookContacts];
    isLoadingFriends = NO;
    [friendsTable reloadData];
    TCEND
}

#pragma mark TableView Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if (friendsList.count > 0 && (isTWFriendsLoaded && next_cursor.intValue != 0) && !isSearching) {
        numberOfRows = friendsList.count + 1;
    } else if(friendsList.count > 0 && !isSearching) {
        numberOfRows = friendsList.count;
    } else if(filteredFriendsList.count > 0 && isSearching) {
        numberOfRows = filteredFriendsList.count;
    } else {
        numberOfRows = 1;
    }
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if (friendsList.count == 0 && !isSearching) {
        static NSString * infoCellIdentifier = @"infoCell";
        UITableViewCell *infocell = [tableView_ dequeueReusableCellWithIdentifier:infoCellIdentifier];
        
        if(infocell == nil) {
            infocell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:infoCellIdentifier];
        }
        
        UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityIndicator setFrame:CGRectMake(280/2, 0 , 40, 30)];
        [infocell.contentView addSubview:activityIndicator];
        
        NSString *helpText = nil;
        if (isLoadingFriends) {
            [activityIndicator startAnimating];
            activityIndicator.hidden = NO;
            helpText = @"Loading... Please wait";
        } else {
            [activityIndicator stopAnimating];
            activityIndicator.hidden = YES;
            helpText = @"No friends found";
        }
        infocell.textLabel.text = helpText;
        infocell.textLabel.font = [UIFont fontWithName:descriptionTextFontName size:13];
        infocell.textLabel.textAlignment = UITextAlignmentCenter;
        infocell.imageView.hidden = YES;
        infocell.backgroundColor = [UIColor clearColor];
        return infocell;
    } else if(filteredFriendsList.count == 0 && isSearching) {
        
        static NSString * cellIdentifier = @"nocell";
        
        UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        
        cell.textLabel.text = @"Search contact is not available";
        cell.textLabel.font = [UIFont fontWithName:descriptionTextFontName size:13];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
        
    } else if(friendsList.count > 0 && isTWFriendsLoaded && friendsList.count == indexPath.row && !isSearching) {
        
        UITableViewCell *loadMoreCell = nil;
        
        //show the load more activity with text if array count is equal to current row index.
        UIActivityIndicatorView *activityIndicator_view = nil;
        static NSString *loadMoreCellIdentifier = @"loadMoreCellIdentifier";
        loadMoreCell = [tableView_ dequeueReusableCellWithIdentifier:loadMoreCellIdentifier];
        
        if(loadMoreCell == nil) {
            loadMoreCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadMoreCellIdentifier];
            
            activityIndicator_view = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityIndicator_view.frame = CGRectMake((loadMoreCell.frame.size.width - 20)/2, 20, 20, 20);
            activityIndicator_view.tag = 1;
            [loadMoreCell.contentView addSubview:activityIndicator_view];
        }
        if (!activityIndicator_view) {
            activityIndicator_view = (UIActivityIndicatorView *)[loadMoreCell.contentView viewWithTag:1];
        }
        loadMoreCell.selectionStyle = UITableViewCellSelectionStyleNone;
        loadMoreCell.imageView.hidden = YES;
        loadMoreCell.backgroundColor = [UIColor clearColor];
        [activityIndicator_view startAnimating];
        return loadMoreCell;
    } else {
        static NSString *cellIdentifier = @"SuggestedUserCellID";
        SuggestedUserCell *cell = (SuggestedUserCell *)[tableView_ dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil) {
            cell = [[SuggestedUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        NSDictionary *friend = nil;
        if (friendsList.count > indexPath.row && !isSearching) {
            friend = [friendsList objectAtIndex:indexPath.row];
        } else if(filteredFriendsList.count > indexPath.row && isSearching) {
            friend = [filteredFriendsList objectAtIndex:indexPath.row];
        }
        
        cell.userProfileImgView.layer.cornerRadius = 23.5f;
        cell.userProfileImgView.layer.borderWidth = 1.5f;
        cell.userProfileImgView.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
        cell.userProfileImgView.layer.masksToBounds = YES;
        
        cell.userNameLbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
        
        if ([reqType caseInsensitiveCompare:@"PhoneContacts"] == NSOrderedSame) {
            if ([self isNotNull:[friend objectForKey:@"image_data"]]) {
                cell.userProfileImgView.image = [UIImage imageWithData:[friend objectForKey:@"image_data"]]; //profile image
            } else {
                cell.userProfileImgView.image = [UIImage imageNamed:@"default_picture"];
            }
            if ([self isNull:[friend objectForKey:@"user_name"]]) {
                cell.userNameLbl.text = [friend objectForKey:@"phonenumber"];
            } else {
                cell.userNameLbl.text = [friend objectForKey:@"user_name"];
            }
        } else {
            if ([self isNotNull:[friend objectForKey:@"photo_path"]]) {
                [cell.userProfileImgView setImageWithURL:[NSURL URLWithString:[friend objectForKey:@"photo_path"]] placeholderImage:[UIImage imageNamed:@"default_picture"]]; //profile image
            } else {
                cell.userProfileImgView.image = [UIImage imageNamed:@"default_picture"];
            }
            cell.userNameLbl.text = [friend objectForKey:@"user_name"];//display name
        }
    
        if ([self isNotNull:[friend objectForKey:@"description"]]) {
            cell.descLbl.text = [friend objectForKey:@"description"];
            cell.userNameLbl.frame = CGRectMake(cell.userNameLbl.frame.origin.x, 9, cell.userNameLbl.frame.size.width, 21);
        } else {
            cell.descLbl.text = @"";
            cell.userNameLbl.frame = CGRectMake(cell.userNameLbl.frame.origin.x, 10, cell.userNameLbl.frame.size.width, 40);
            cell.userNameLbl.numberOfLines = 0;
        }
        
        if ([self isNotNull:[friend objectForKey:@"wootag_id"]]) {
            cell.addBtn.hidden = NO;
            cell.inviteBtn.hidden = YES;
            if ([self isNotNull:[friend objectForKey:@"following"]] && [[friend objectForKey:@"following"] boolValue]) {
                [cell.addBtn setBackgroundImage:[UIImage imageNamed:@"Followed"] forState:UIControlStateNormal];
                cell.addBtn.userInteractionEnabled = NO;
            } else {
                [cell.addBtn setBackgroundImage:[UIImage imageNamed:@"AddSuggestedUser"] forState:UIControlStateNormal];
                 cell.addBtn.userInteractionEnabled = YES;
            }
        } else {
            cell.addBtn.hidden = YES;
            cell.inviteBtn.hidden = NO;
        }
        
        if ([reqType caseInsensitiveCompare:@"PhoneContacts"] == NSOrderedSame) {
            cell.addBtn.hidden = YES;
            cell.inviteBtn.hidden = YES;
            if ([selectedFreindsList containsObject:friend]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
        [cell.addBtn addTarget:self action:@selector(clickedOnFollowBtn:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        [cell.inviteBtn addTarget:self action:@selector(clickedOnInviteBtn:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
        return cell;
    }
    TCEND
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TCSTART
    if (isTWFriendsLoaded && friendsList.count > 0 && indexPath.row == [friendsList count] && !isSearching) {
        [self performSelector:@selector(requestForTWFollowersList) withObject:nil afterDelay:0.001];
    }
    TCEND
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if ([reqType caseInsensitiveCompare:@"PhoneContacts"] == NSOrderedSame && friendsList.count > 0 && friendsList.count > indexPath.row) {
        NSDictionary *friend = nil;
        if (isSearching && filteredFriendsList.count > 0) {
            friend = [filteredFriendsList objectAtIndex:indexPath.row];
        } else if (!isSearching) {
            friend = [friendsList objectAtIndex:indexPath.row];
        }
        if ([self isNotNull:friend]) {
            SuggestedUserCell *cell = (SuggestedUserCell *)[tableView cellForRowAtIndexPath:indexPath];
            if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                cell.accessoryType = UITableViewCellAccessoryNone;
                if ([selectedFreindsList containsObject:friend]) {
                    [selectedFreindsList removeObject:friend];
                }
            } else {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [selectedFreindsList addObject:friend];
            }
        }
        if (selectedFreindsList.count > 0) {
            inviteBtn.enabled = YES;
        } else {
            inviteBtn.enabled = NO;
        }
    }
    TCEND
}

#pragma mark Facebook Invitation
- (void)sendInvitationToFacebookFriendOfId:(NSString *)userId andUserName:(NSString *)username {
    TCSTART
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Record, Tag - self,people, place, product inside your videos and Share.",@"name",@"www.wootag.com/invite.html",@"link",userId,@"to",@"http://wootag.com/invite.jpg",@"picture",nil];

    [appDelegate sendInvitationtoFaceBookFriendWithParams:params];
    TCEND
}

#pragma mark Twitter tweet
- (void)sendInvitationToTwitterFriendOfUserId:(NSString *)userId andUserName:(NSString *)username {
    TCSTART
    NSDictionary *dict = [appDelegate.twitterEngine getUserProfileForUserId:userId];
    if ([self isNotNull:dict] && [self isNotNull:[dict objectForKey:@"screen_name"]]) {
        [appDelegate PostToTwitterWithMsg:@"Record, Tag - self,people, place, product inside your videos and Share.\n www.wootag.com/invite.html" toUser:[dict objectForKey:@"screen_name"] withImageUrl:@"http://wootag.com/invite.jpg" andVideoId:nil];
    }
    
    TCEND
}
#pragma mark GooglePlus Sharing
- (void)sendInvitaitonToGooglePlusUserWithUserId:(NSString *)gPlusId andUserName:(NSString *)username {
    TCSTART
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    
    [shareBuilder setPrefillText:@"Record, Tag - self,people, place, product inside your videos and Share. \n www.wootag.com/invite.html"];
    [shareBuilder attachImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://wootag.com/invite.jpg"]]];
    
    
    [shareBuilder setPreselectedPeopleIDs:[NSArray arrayWithObject:gPlusId]];
    [shareBuilder open];
    TCEND
}

- (void)finishedSharing: (BOOL)shared {
    if (shared) {
//        [ShowAlert showAlert:@"Shared successfully"];
    } else {
        [ShowAlert showAlert:@"Something went wrong, please share again"];
    }
}

#pragma mark Invite
- (void)clickedOnInviteBtn:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    [friendsSearchBar resignFirstResponder];
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:friendsTable];
    NSDictionary *userDict;
    if (isSearching && filteredFriendsList.count > 0) {
        userDict = [filteredFriendsList objectAtIndex:indexPath.row];
    } else {
        userDict = [friendsList objectAtIndex:indexPath.row];
    }
    
    if ([reqType caseInsensitiveCompare:@"facebook"] == NSOrderedSame) {
        [self sendInvitationToFacebookFriendOfId:[userDict objectForKey:@"id"] andUserName:[userDict objectForKey:@"user_name"]];
        
    } else if ([reqType caseInsensitiveCompare:@"twitter"] == NSOrderedSame) {
        [self sendInvitationToTwitterFriendOfUserId:[NSString stringWithFormat:@"%ld",[[userDict objectForKey:@"id"] longValue]] andUserName:[userDict objectForKey:@"user_name"]];
    } else if ([reqType caseInsensitiveCompare:@"PhoneContacts"] == NSOrderedSame) {
//        [self sendInvitationThroughMessageToNumber:[userDict objectForKey:@"phonenumber"] andName:[userDict objectForKey:@"user_name"]];
    } else {
        [self sendInvitaitonToGooglePlusUserWithUserId:[userDict objectForKey:@"id"] andUserName:[userDict objectForKey:@"user_name"]];
    }
    TCEND
}

#pragma mark Multiple Invite for Contacts
- (IBAction)onClickOfInviteButton {
    TCSTART
    if (selectedFreindsList.count > 0) {
        [self sendInvitationThroughMessageToContacts:selectedFreindsList];
    }
    TCEND
}
#pragma mark ShareSpecial Through Message

- (void)sendInvitationThroughMessageToContacts:(NSArray *)contactsArray {
    TCSTART
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText]) {
        
        //            [controller attachImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://wootag.com/invite.jpg"]]];
        NSString *message;
        if (contactsArray.count > 1) {
            controller.recipients = [contactsArray valueForKey:@"phonenumber"];
            [controller setBody:[NSString stringWithFormat:@"Hi All, Found this interesting app Wootag\n\nIt allows me to upload my video and tag the product I want to sell or myself or the location – All Inside the Video! Try Wootag www.wootag.com/invite.html"]];
        } else {
            controller.recipients = [contactsArray valueForKey:@"phonenumber"];
           [controller setBody:[NSString stringWithFormat:@"Hi %@, Found this interesting app Wootag\n\nIt allows me to upload my video and tag the product I want to sell or myself or the location – All Inside the Video! Try Wootag www.wootag.com/invite.html",[contactsArray valueForKey:@"user_name"]]];
            [controller setBody:message];
        }
        
        controller.subject = @"Invitation";
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
        case MessageComposeResultSent:
            NSLog(@"Message sent");
            break;
        default:
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
    
    TCEND
}


#pragma mark Follow User
- (void)clickedOnFollowBtn:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    [friendsSearchBar resignFirstResponder];
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:friendsTable];
    NSDictionary *friend;
    if (isSearching && filteredFriendsList.count > 0) {
        friend = [filteredFriendsList objectAtIndex:indexPath.row];
    } else {
        friend = [friendsList objectAtIndex:indexPath.row];
    }
   
    if ([self isNotNull:[friend objectForKey:@"following"]] && ![[friend objectForKey:@"following"] boolValue] && [self isNotNull:[friend objectForKey:@"wootag_id"]]) {
        [appDelegate makeFollowUserWithUserId:appDelegate.loggedInUser.userId followerId:[friend objectForKey:@"wootag_id"] andCaller:self andIndexPath:indexPath];
    }
    TCEND
}

- (void)didFinishedToFollowUser:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
//    [ShowAlert showAlert:@"Followed successfully"];
    
    NSIndexPath *indexpath = [results objectForKey:@"indexpath"];
    NSDictionary *friendDict;
    if (isSearching && filteredFriendsList.count > 0) {
        friendDict = [filteredFriendsList objectAtIndex:indexpath.row];
    } else {
        friendDict = [friendsList objectAtIndex:indexpath.row];
    }
    NSMutableDictionary *friend = [friendDict mutableCopy];
    
    [friend setObject:[NSNumber numberWithBool:YES] forKey:@"following"];
    if (isSearching && filteredFriendsList.count > 0) {
        [filteredFriendsList replaceObjectAtIndex:indexpath.row withObject:friend];
    } else {
        [friendsList replaceObjectAtIndex:indexpath.row withObject:friend];
    }
    
    
    NSInteger totalFollowings = [appDelegate.loggedInUser.totalNoOfFollowings integerValue];
    totalFollowings = totalFollowings + 1;
    appDelegate.loggedInUser.totalNoOfFollowings = [NSNumber numberWithInt:totalFollowings];
    [friendsTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexpath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    TCEND
}
- (void)didFailToFollowUserWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}


#pragma mark UISearchBar Delegate Methods
- (void)setBackgroundForSearchBar:(UISearchBar *)searchbar withImagePath:(NSString *)imgPath {
    
    @try {
        //        [searchbar setShowsCancelButton:YES animated:NO];
        UITextField *searchField;
        NSArray *searchSubViews;
        if (CURRENT_DEVICE_VERSION < 7.0) {
            searchSubViews = searchbar.subviews;
        } else {
            searchSubViews = [[searchbar.subviews objectAtIndex:0] subviews];
        }
        for(int i = 0; i < searchSubViews.count; i++) {
            if([[searchSubViews objectAtIndex:i] isKindOfClass:[UITextField class]]) { //conform?
                searchField = [searchSubViews objectAtIndex:i];
                searchField.returnKeyType = UIReturnKeySearch;
                searchField.backgroundColor = [UIColor whiteColor];
            }
        }
        if(!(searchField == nil)) {
            searchField.textColor = [UIColor blackColor];
            [searchField setBackground: [UIImage imageNamed:imgPath]];
            searchField.backgroundColor = [UIColor whiteColor];
            [searchField setBorderStyle:UITextBorderStyleNone];
            searchField.enablesReturnKeyAutomatically = YES;
        }
        //remove the search bar background view.
        for (int i = 0; i < searchSubViews.count; i++) {
            if ([[searchSubViews objectAtIndex:i] isKindOfClass:NSClassFromString
                 (@"UISearchBarBackground")]) {
                [[searchSubViews objectAtIndex:i]removeFromSuperview];
            }
        }
        [self enableSearchBarCancelButton:searchbar];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)enableSearchBarCancelButton:(UISearchBar *)searchBar {
    TCSTART
    NSArray *searchSubViews;
    if (CURRENT_DEVICE_VERSION < 7.0) {
        searchSubViews = searchBar.subviews;
    } else {
        searchSubViews = [[searchBar.subviews objectAtIndex:0] subviews];
    }
    for (UIView *subview in searchSubViews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *cancelButton = (UIButton*)subview;
            [cancelButton addTarget:self action:@selector(searchBarCancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            cancelButton.enabled = YES;
            break;
        }
    }
    TCEND
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    @try {
        [filteredFriendsList removeAllObjects];
        
        int i;
        if (searchText.length > 0) {
            isSearching = YES;
            for(i = 0; i < [friendsList count]; i++) {
                
                NSRange range = [[[friendsList objectAtIndex:i] objectForKey:@"user_name"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
                
                if (range.length > 0) {
                    [filteredFriendsList addObject:[friendsList objectAtIndex:i]];
                }
            }
        } else {
            isSearching = NO;
            [friendsSearchBar resignFirstResponder];
        }
        [friendsTable reloadData];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
        
    }
    @finally {
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    isSearching = NO;
    [friendsTable reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)reloadData {
    [friendsTable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table ScrollView Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    @try {
        if([self isNotNull:friendsSearchBar]) {
            [friendsSearchBar resignFirstResponder];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
        
    }
}
@end
