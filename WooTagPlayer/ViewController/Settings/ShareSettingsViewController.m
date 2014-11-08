/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "ShareSettingsViewController.h"

@interface ShareSettingsViewController ()

@end

@implementation ShareSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil viewType:(NSString *)viewType
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        type = viewType;
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad {
    TCSTART
    [super viewDidLoad];
    pushNotificationsDictionary = [[NSMutableDictionary alloc] init];
    
    if ([type caseInsensitiveCompare:@"SHARE SETTINGS"] == NSOrderedSame) {
        [self shareSettingsArray];
    } else if ([type caseInsensitiveCompare:@"FACEBOOK"] == NSOrderedSame || [type caseInsensitiveCompare:@"TWITTER"] == NSOrderedSame || [type caseInsensitiveCompare:@"GOOGLE +"] == NSOrderedSame) {
        rowsArray = [[NSArray alloc] initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"Unlink",@"title", nil], nil];
    } else if ([type caseInsensitiveCompare:@"notifications"] == NSOrderedSame) {
        pushNotificationsArray = [[NSArray alloc] initWithObjects:@"likes",@"comments",@"mentions", nil];
        rowsArray = [[NSArray alloc] initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"Off",@"title",@"checkmark",@"imagename", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"On",@"title",@"checkmark",@"imagename", nil], nil];
    }
    
    titleLabel.text = type;
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height - 20);
    settingsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 42, self.view.frame.size.width, self.view.frame.size.height - 42) style:UITableViewStyleGrouped];
    if (CURRENT_DEVICE_VERSION < 7.0) {
        settingsTableView.separatorColor = [UIColor clearColor];
        settingsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        settingsTableView.backgroundView = nil;
    }
    
    settingsTableView.backgroundColor = [UIColor clearColor];
    settingsTableView.separatorColor = [UIColor lightGrayColor];
    settingsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    settingsTableView.delegate = self;
    settingsTableView.dataSource = self;
    [self.view addSubview:settingsTableView];
    self.view.backgroundColor = [appDelegate colorWithHexString:@"f5f5f5"];
    
    [self getNotificationsSettingsDetails];

    TCEND
}

- (void)getNotificationsSettingsDetails {
    TCSTART
    settingsTableView.hidden = YES;
    [appDelegate getNotificationsSettingsCaller:self];
    TCEND
}
- (void)didFinishedToGetNotificationSettings:(NSDictionary *)results {
    TCSTART
    settingsTableView.hidden = NO;
    NSLog(@"Results:%@",results);
    [pushNotificationsDictionary addEntriesFromDictionary:results];
    if ([self isNotNull:[pushNotificationsDictionary objectForKey:@"error_code"]]) {
        [pushNotificationsDictionary removeObjectForKey:@"error_code"];
    }
    [pushNotificationsDictionary setObject:appDelegate.loggedInUser.userId forKey:@"user_id"];
    [settingsTableView reloadData];
    TCEND
}

- (void)didFailToGetNotificationSettingsWithError:(NSDictionary *)errorDict {
    TCSTART
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

- (void)updateNotifications {
    TCSTART
    [appDelegate updateNotificationsSettingsWithParameters:pushNotificationsDictionary andCaller:self];
    TCEND
}
- (void)didFinishedToUpdateNotificationsSettings:(NSDictionary *)results {
    TCSTART
    TCEND
}
- (void)didFailToUpdateNotificationsSettingsWithError:(NSDictionary *)errorDict {
    TCSTART
    TCEND
}
- (void)viewDidAppear:(BOOL)animated {
    if ([type caseInsensitiveCompare:@"SHARE SETTINGS"] == NSOrderedSame) {
        [self getFacebookLoggedInUserEmailId];
        [self getTwitterLoggedInUserEmailAddress];
        [self getGooglePlusLoggedInUserEmailAddress];
    }
}

- (void)shareSettingsArray {
    TCSTART
    rowsArray = [[NSArray alloc] initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"Facebook",@"title",(FBSession.activeSession.isOpen)?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO],@"loggedin",@"FBBtn",@"imagename", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Twitter",@"title",@"TwitterBtn",@"imagename",[self twitterAuthorized]?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO],@"loggedin", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"Google+",@"title",@"GooglePlusBtn",@"imagename",([[GPPSignIn sharedInstance] authentication] || [[GPPSignIn sharedInstance] hasAuthInKeychain])?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO],@"loggedin", nil], nil];
    
    TCEND
}

- (BOOL)twitterAuthorized {
    appDelegate.twitterEngine.delegate = self;
    if(!appDelegate.twitterEngine) {
        [appDelegate initializeTwitterEngineWithDelegate:appDelegate];
    }
    [appDelegate.twitterEngine loadAccessToken];
    if([appDelegate.twitterEngine isAuthorized]) {
        return YES;
    } else {
        return NO;
    }
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

- (IBAction)onClickOfBackBtn:(id)sender {
    TCSTART
    [self.navigationController popViewControllerAnimated:YES];
    TCEND
}

#pragma mark Tableview delegate and Data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([type caseInsensitiveCompare:@"notifications"] == NSOrderedSame) {
        return 3;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return rowsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return [self heightOfHeaderAtSection:section];
    
}

- (CGFloat)heightOfHeaderAtSection:(int)section {
    if ([type caseInsensitiveCompare:@"SHARE SETTINGS"] == NSOrderedSame) {
        if (section == 0 && CURRENT_DEVICE_VERSION < 7.0) {
            return 35;
        }
    } else if ([type caseInsensitiveCompare:@"FACEBOOK"] == NSOrderedSame || [type caseInsensitiveCompare:@"TWITTER"] == NSOrderedSame || [type caseInsensitiveCompare:@"GOOGLE +"] == NSOrderedSame || [type caseInsensitiveCompare:@"notifications"] == NSOrderedSame) {
        if (section == 0 && CURRENT_DEVICE_VERSION >= 7.0) {
            return 35;
        }
        return ((CURRENT_DEVICE_VERSION < 7.0)?50:40);
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, [self heightOfHeaderAtSection:section])];
    headerView.backgroundColor = [UIColor clearColor];
    if ([type caseInsensitiveCompare:@"FACEBOOK"] == NSOrderedSame || [type caseInsensitiveCompare:@"TWITTER"] == NSOrderedSame || [type caseInsensitiveCompare:@"GOOGLE +"] == NSOrderedSame || [type caseInsensitiveCompare:@"notifications"] == NSOrderedSame) {
        UILabel *headerTitleLabl = [[UILabel alloc] initWithFrame:CGRectMake(10, (headerView.frame.size.height - 24), 300, 20)];
        headerTitleLabl.backgroundColor = [UIColor clearColor];
        headerTitleLabl.font = [UIFont fontWithName:descriptionTextFontName size:14];
        if ([type caseInsensitiveCompare:@"FACEBOOK"] == NSOrderedSame || [type caseInsensitiveCompare:@"TWITTER"] == NSOrderedSame || [type caseInsensitiveCompare:@"GOOGLE +"] == NSOrderedSame) {
            headerTitleLabl.text = @"ACCOUNT";
        } else {
            headerTitleLabl.text = [[pushNotificationsArray objectAtIndex:section] uppercaseString];
        }
        headerTitleLabl.textColor = [UIColor grayColor];
        [headerView addSubview:headerTitleLabl];
    }
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    static NSString *cellIdentifier = @"cellId";
    
    UILabel *topLineLbl;
    UILabel *bottomLineLbl;
    UILabel *loggedInUserNameLbl;
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        //        leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 40)];
        cell.textLabel.textAlignment = UITextAlignmentLeft;
        cell.textLabel.font = [UIFont fontWithName:descriptionTextFontName size:17];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.tag = 1;
        
        loggedInUserNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(170, 5, 110, 30)];
        loggedInUserNameLbl.textAlignment = UITextAlignmentRight;
        loggedInUserNameLbl.textColor = [UIColor lightGrayColor];
        loggedInUserNameLbl.tag = 2;
        loggedInUserNameLbl.font = [UIFont fontWithName:descriptionTextFontName size:17];
        loggedInUserNameLbl.backgroundColor = [UIColor clearColor];
        [cell addSubview:loggedInUserNameLbl];
        
        topLineLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, cell.frame.size.width, 0.5)];
        topLineLbl.backgroundColor = [UIColor lightGrayColor];
        [cell addSubview:topLineLbl];
        
        bottomLineLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 39.5, cell.frame.size.width, 0.5)];
        bottomLineLbl.backgroundColor = [UIColor lightGrayColor];
        [cell addSubview:bottomLineLbl];
    }
    
    if (!loggedInUserNameLbl) {
        loggedInUserNameLbl = (UILabel *)[cell viewWithTag:2];
    }
    NSDictionary *dict = [rowsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict objectForKey:@"title"];
    bottomLineLbl.hidden = YES;
    loggedInUserNameLbl.hidden = YES;
    if ([type caseInsensitiveCompare:@"notifications"] == NSOrderedSame || [type caseInsensitiveCompare:@"SHARE SETTINGS"] == NSOrderedSame) {
        cell.imageView.hidden = NO;
        cell.imageView.image = [UIImage imageNamed:[dict objectForKey:@"imagename"]];
        if ([type caseInsensitiveCompare:@"SHARE SETTINGS"] == NSOrderedSame) {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory"]];
            loggedInUserNameLbl.hidden = NO;
            if (indexPath.row == 0) {
                if ([self isNotNull:[appDelegate.loggedInUser.socialContactsDictionary objectForKey:@"FB"]]) {
                    loggedInUserNameLbl.text = [appDelegate.loggedInUser.socialContactsDictionary objectForKey:@"FB"];
                } else {
                    loggedInUserNameLbl.text = @"";
                }
            } else if (indexPath.row == 1) {
                
                if ([self isNotNull:[appDelegate.loggedInUser.socialContactsDictionary objectForKey:@"TW"]]) {
                    loggedInUserNameLbl.text = [appDelegate.loggedInUser.socialContactsDictionary objectForKey:@"TW"];
                } else {
                    loggedInUserNameLbl.text = @"";
                }
                
            } else {
               
                if ([self isNotNull:[appDelegate.loggedInUser.socialContactsDictionary objectForKey:@"GPLUS"]]) {
                    loggedInUserNameLbl.text = [appDelegate.loggedInUser.socialContactsDictionary objectForKey:@"GPLUS"];
                } else {
                    loggedInUserNameLbl.text = @"";
                }
            }
        } else {
            if (([self isNotNull:[pushNotificationsDictionary objectForKey:[pushNotificationsArray objectAtIndex:indexPath.section]]] && [[pushNotificationsDictionary objectForKey:[pushNotificationsArray objectAtIndex:indexPath.section]] boolValue] && indexPath.row == 1) || ([self isNotNull:[pushNotificationsDictionary objectForKey:[pushNotificationsArray objectAtIndex:indexPath.section]]] && ![[pushNotificationsDictionary objectForKey:[pushNotificationsArray objectAtIndex:indexPath.section]] boolValue] && indexPath.row == 0)) {
                cell.imageView.hidden = NO;
            } else {
                cell.imageView.hidden = YES;
            }
        }
    } else {
        cell.imageView.hidden = YES;
        cell.textLabel.textAlignment = UITextAlignmentCenter;
    }
    if (CURRENT_DEVICE_VERSION < 7.0) {
        topLineLbl.hidden = NO;
        if ((indexPath.row == 0 && ([type caseInsensitiveCompare:@"FACEBOOK"] == NSOrderedSame || [type caseInsensitiveCompare:@"TWITTER"] == NSOrderedSame || [type caseInsensitiveCompare:@"GOOGLE +"] == NSOrderedSame)) || (indexPath.row == 1 && [type caseInsensitiveCompare:@"notifications"] == NSOrderedSame) || (indexPath.row == 2 && [type caseInsensitiveCompare:@"SHARE SETTINGS"] == NSOrderedSame)) {
            bottomLineLbl.hidden = NO;
        }
        cell.backgroundView = nil;
    } else {
        topLineLbl.hidden = YES;
        bottomLineLbl.hidden = YES;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
    TCEND
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (CURRENT_DEVICE_VERSION < 7.0) {
        cell.backgroundView = nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if ([type caseInsensitiveCompare:@"SHARE SETTINGS"] == NSOrderedSame) {
        if (indexPath.row == 0) {
            //Facebook
            if (!FBSession.activeSession.isOpen) {
                // if the session is closed, then we open it here, and establish a handler for state changes
                [FBSession openActiveSessionWithReadPermissions:appDelegate.facebookReadPermissions allowLoginUI:YES
                                              completionHandler:^(FBSession *session,
                                                                  FBSessionState state,
                                                                  NSError *error) {
                                                  if (error) {
                                                      [ShowAlert showError:@"Authentication failed, please try again"];
                                                  } else if (session.isOpen) {
                                                      [self getFacebookLoggedInUserEmailId];
                                                  }
                                              }];
                
            } else {
                [self navigateToSocialLinkScreen:indexPath];
            }
        } else if (indexPath.row == 1) {
            //Twitter
            appDelegate.twitterEngine.delegate = self;
            if(!appDelegate.twitterEngine) {
                [appDelegate initializeTwitterEngineWithDelegate:appDelegate];
            }
            [appDelegate.twitterEngine loadAccessToken];
            if(![appDelegate.twitterEngine isAuthorized]) {
                [[FHSTwitterEngine sharedEngine] showOAuthLoginControllerFromViewController:self withCompletion:^(BOOL success) {
                    if (!success) {
                        [ShowAlert showError:@"Authentication failed, please try again"];
                    } else {
                        NSLog(@"Twitter login success");
                    }
                }];
            } else {
                [self navigateToSocialLinkScreen:indexPath];
            }
        } else {
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
                [self navigateToSocialLinkScreen:indexPath];
            }
        }
    } else if ([type caseInsensitiveCompare:@"notifications"] == NSOrderedSame) {
        NSNumber *number;
        if (indexPath.row == 0 ) {
            number = [NSNumber numberWithInt:0];
        } else {
            number = [NSNumber numberWithInt:1];
        }
        [pushNotificationsDictionary setObject:number forKey:[pushNotificationsArray objectAtIndex:indexPath.section]];
        [settingsTableView reloadData];
        [self updateNotifications];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:[NSString stringWithFormat:@"Unlink your %@ account?",type] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes, I'm sure", nil];
        [alert show];
    }
    
    TCEND
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    TCSTART
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title caseInsensitiveCompare:@"Yes, I'm sure"] == NSOrderedSame) {
        if ([type caseInsensitiveCompare:@"FACEBOOK"] == NSOrderedSame) {
            [appDelegate facebookLogout];
            [appDelegate.loggedInUser.socialContactsDictionary setObject:@"" forKey:@"FB"];
        } else if ([type caseInsensitiveCompare:@"TWITTER"] == NSOrderedSame) {
            [appDelegate.twitterEngine clearAccessToken];
            appDelegate.twitterEngine.delegate = nil;
            appDelegate.twitterEngine = nil;
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SavedAccessHTTPBody"];
            [appDelegate.loggedInUser.socialContactsDictionary setObject:@"" forKey:@"TW"];
        } else {
            [[GPPSignIn sharedInstance] signOut];
            [[GPPSignIn sharedInstance] disconnect];
            [appDelegate.loggedInUser.socialContactsDictionary setObject:@"" forKey:@"GPLUS"];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    TCEND
}

- (void)navigateToSocialLinkScreen:(NSIndexPath *)indexPath {
    TCSTART
    ShareSettingsViewController *shareVC;
    shareVC = [[ShareSettingsViewController alloc] initWithNibName:@"ShareSettingsViewController" bundle:nil viewType:[[rowsArray objectAtIndex:indexPath.row] objectForKey:@"title"]];
    [self.navigationController pushViewController:shareVC animated:YES];
    TCEND
}

#pragma mark Facebook
- (void)getFacebookLoggedInUserEmailId {
    TCSTART
    if (FBSession.activeSession.isOpen  && [self isNull:[appDelegate.loggedInUser.socialContactsDictionary objectForKey:@"FB"]]) {
        [FBRequestConnection startForMeWithCompletionHandler:
         ^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 if ([self isNotNull:appDelegate.loggedInUser]) {
                     if ([self isNull:appDelegate.loggedInUser.socialContactsDictionary]) {
                         appDelegate.loggedInUser.socialContactsDictionary = [[NSMutableDictionary alloc] init];
                     }
                     [appDelegate.loggedInUser.socialContactsDictionary setObject:[result objectForKey:@"name"]?:@"" forKey:@"FB"];
                 }
                 [settingsTableView reloadData];
             }
         }];
    }
    TCEND
}

#pragma mark Twitter
- (void)getTwitterLoggedInUserEmailAddress {
    TCSTART
    if (self) {
        appDelegate.twitterEngine.delegate = self;
        if(!appDelegate.twitterEngine) {
            [appDelegate initializeTwitterEngineWithDelegate:appDelegate];
        }
        [appDelegate.twitterEngine loadAccessToken];
        if([appDelegate.twitterEngine isAuthorized] && [self isNull:[appDelegate.loggedInUser.socialContactsDictionary objectForKey:@"TW"]]) {
            if ([self isNull:appDelegate.loggedInUser.socialContactsDictionary]) {
                appDelegate.loggedInUser.socialContactsDictionary = [[NSMutableDictionary alloc] init];
            }
            [appDelegate.loggedInUser.socialContactsDictionary setObject:appDelegate.twitterEngine.loggedInUsername?:@"" forKey:@"TW"];
        }
        [settingsTableView reloadData];
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
    [settingsTableView reloadData];
    TCEND
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
}

#pragma mark Google Plus
- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    TCSTART
    if (error) {
        [ShowAlert showError:@"Authentication failed, please try again"];
    } else {
        if ([self isNull:appDelegate.loggedInUser.socialContactsDictionary]) {
            appDelegate.loggedInUser.socialContactsDictionary = [[NSMutableDictionary alloc] init];
        }
        [appDelegate.loggedInUser.socialContactsDictionary setObject:auth.userEmail?:@"" forKey:@"GPLUS"];
        [settingsTableView reloadData];
    }
    TCEND
}

- (void)getGooglePlusLoggedInUserEmailAddress {
    TCSTART
    if ([[GPPSignIn sharedInstance] hasAuthInKeychain]) {
        NSLog(@"already Signedin");
    } else {
        NSLog(@"not sign");
    }
    if (([[GPPSignIn sharedInstance] authentication] || [[GPPSignIn sharedInstance] hasAuthInKeychain]) && [self isNull:[appDelegate.loggedInUser.socialContactsDictionary objectForKey:@"GPLUS"]]) {
        GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
        GPPSignIn *signIn = [GPPSignIn sharedInstance];
        signIn.shouldFetchGoogleUserEmail = YES;
        plusService.retryEnabled = YES;
        [plusService setAuthorizer:signIn.authentication];
        if ([self isNull:appDelegate.loggedInUser.socialContactsDictionary]) {
            appDelegate.loggedInUser.socialContactsDictionary = [[NSMutableDictionary alloc] init];
        }
        [appDelegate.loggedInUser.socialContactsDictionary setObject:signIn.authentication.userEmail?:@"" forKey:@"GPLUS"];
    }
    [settingsTableView reloadData];
    TCEND
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
