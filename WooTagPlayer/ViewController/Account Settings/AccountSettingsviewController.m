/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "AccountSettingsviewController.h"
#import "ChangePassWordViewController.h"
#import "Base64.h"


@interface AccountSettingsviewController ()

@end

@implementation AccountSettingsviewController
@synthesize userDataModal;
@synthesize mainVC;
@synthesize imagePicker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad
{
    TCSTART
    [super viewDidLoad];
    NSLog(@"Starting");
//    genderView.hidden = YES;
    genderArray = [[NSArray alloc] initWithObjects:@"Not Specified",@"Male",@"Female", nil];
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height - 20);
    [self.view removeGestureRecognizer:appDelegate.revealController.panGestureRecognizer];
    newAvatar = nil;
    newBanner = nil;
    editTableView.tableHeaderView = headerView;
    headerView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [appDelegate colorWithHexString:@"f5f5f5"];
    [self setColorsToAllObjects];
    NSLog(@"Ending");
    firstTime = YES;
    [self setProfileInformationToUIObjects];
    TCEND
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    TCSTART
    if (firstTime) {
        firstTime = NO;
        [self getAccountDetailsOfLoggedInUser];
        [self getFacebookLoggedInUserEmailId];
        [self getGooglePlusLoggedInUserEmailAddress];
        [self getTwitterLoggedInUserEmailAddress];
    }
    TCEND
}

- (void)getAccountDetailsOfLoggedInUser {
    TCSTART
    if ([self isNotNull:appDelegate.loggedInUser.userId]) {
        [appDelegate getAccountDetialsOfLoggedInUserWithCaller:self];
        [appDelegate showActivityIndicatorInView:editTableView andText:@""];
        [appDelegate showNetworkIndicator];
    }
    TCEND
}
- (void)didFinishedToGetAccountDetialsLoggedInUser:(NSDictionary *)results {
    TCSTART
    [appDelegate removeNetworkIndicatorInView:editTableView];
    [appDelegate hideNetworkIndicator];
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"user"]]) {
        NSDictionary *userdict = [results objectForKey:@"user"];
        if ([self isNotNull:[userdict objectForKey:@"name"]]) {
            userDataModal.userName = [userdict objectForKey:@"name"];
        }
        
        if ([self isNotNull:[userdict objectForKey:@"bio"]]) {
            userDataModal.bio = [userdict objectForKey:@"bio"];
        } else {
            userDataModal.bio = @"";
        }
        
        if ([self isNotNull:[userdict objectForKey:@"country"]]) {
            userDataModal.country = [userdict objectForKey:@"country"];
        } else {
            userDataModal.country = @"";
        }
        
        if ([self isNotNull:[userdict objectForKey:@"profession"]]) {
            userDataModal.profession = [userdict objectForKey:@"profession"];
        } else {
            userDataModal.profession = @"";
        }
        
        if ([self isNotNull:[userdict objectForKey:@"website"]]) {
            userDataModal.website = [userdict objectForKey:@"website"];
        } else {
            userDataModal.website = @"";
        }
        
        if ([self isNotNull:[userdict objectForKey:@"photo_path"]]) {
            userDataModal.photoPath = [userdict objectForKey:@"photo_path"];
        } else {
            userDataModal.photoPath = @"";
        }
        
        if ([self isNotNull:[userdict objectForKey:@"banner_path"]]) {
            userDataModal.bannerPath = [userdict objectForKey:@"banner_path"];
        } else {
            userDataModal.bannerPath = @"";
        }
        
        if ([self isNotNull:[userdict objectForKey:@"email"]]) {
            userDataModal.emailAddress = [userdict objectForKey:@"email"];
        } else {
            userDataModal.emailAddress = @"";
        }
        
        if ([self isNotNull:[userdict objectForKey:@"phone"]]) {
            userDataModal.phoneNumber = [userdict objectForKey:@"phone"];
        } else {
            userDataModal.phoneNumber = @"";
        }
        
        if ([self isNotNull:[userdict objectForKey:@"gender"]]) {
            userDataModal.gender = [userdict objectForKey:@"gender"];
        } else {
            userDataModal.gender = @"Not Specified";
        }
        [self setProfileInformationToUIObjects];
        [self updateAppDelegateLoggedInUserObjectValues];
        [editTableView reloadData];
    }
    TCEND
}

- (void)didFailToGetAccountDetialsLoggedInUserWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate removeNetworkIndicatorInView:editTableView];
    [appDelegate hideNetworkIndicator];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

- (void)updateAppDelegateLoggedInUserObjectValues {
    TCSTART
    appDelegate.loggedInUser.bannerPath = userDataModal.bannerPath;
    appDelegate.loggedInUser.photoPath = userDataModal.photoPath;
    appDelegate.loggedInUser.country = userDataModal.country;
    appDelegate.loggedInUser.profession = userDataModal.profession;
    appDelegate.loggedInUser.website = userDataModal.website;
    appDelegate.loggedInUser.emailAddress = userDataModal.emailAddress;
    appDelegate.loggedInUser.gender = userDataModal.gender;
    appDelegate.loggedInUser.phoneNumber = userDataModal.phoneNumber;
    appDelegate.loggedInUser.bio = userDataModal.bio;
    if ([self isNotNull:appDelegate.loggedInUser.profession]) {
        appDelegate.loggedInUser.userDesc = appDelegate.loggedInUser.profession;
    }
    if ([self isNotNull:appDelegate.loggedInUser.country]) {
        if ([self isNotNull:appDelegate.loggedInUser.userDesc] && appDelegate.loggedInUser.userDesc.length > 0) {
            appDelegate.loggedInUser.userDesc = [NSString stringWithFormat:@"%@ | %@",appDelegate.loggedInUser.userDesc,appDelegate.loggedInUser.country];
        } else {
            appDelegate.loggedInUser.userDesc = appDelegate.loggedInUser.country;
        }
    }
    
    if ([self isNotNull:appDelegate.loggedInUser.website]) {
        if ([self isNotNull:appDelegate.loggedInUser.userDesc] && appDelegate.loggedInUser.userDesc.length > 0) {
            appDelegate.loggedInUser.userDesc = [NSString stringWithFormat:@"%@ | %@",appDelegate.loggedInUser.userDesc,appDelegate.loggedInUser.website];
        } else {
            appDelegate.loggedInUser.userDesc = appDelegate.loggedInUser.website;
        }
    }
    if ([self isNotNull:mainVC] && [mainVC respondsToSelector:@selector(updateMypageDetails)]) {
        [mainVC updateMypageDetails];
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
                 [editTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:4 inSection:0], nil] withRowAnimation:UITableViewRowAnimationAutomatic];
             }
         }];
    } 
    
    TCEND
}

- (void)getTwitterLoggedInUserEmailAddress {
    TCSTART
    if (self) {
        appDelegate.twitterEngine.delegate = (id)appDelegate;
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
        [editTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:5 inSection:0], nil] withRowAnimation:UITableViewRowAnimationAutomatic];
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
     [editTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:6 inSection:0], nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    TCEND
}

- (void)setColorsToAllObjects {
    TCSTART
    userProfilePic.layer.cornerRadius = 30.0f;
    userProfilePic.layer.borderWidth = 1.5f;
    userProfilePic.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
    userProfilePic.layer.masksToBounds = YES;
    
    usernameLbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
    
    usernameLblDivider.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
    bioDivider.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
    websiteDivider.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];

    if (CURRENT_DEVICE_VERSION >= 7.0) {
        usernameLblDivider.frame = CGRectMake(usernameLblDivider.frame.origin.x, usernameLblDivider.frame.origin.y, usernameLblDivider.frame.size.width, 0.5);
        bioDivider.frame = CGRectMake(bioDivider.frame.origin.x, bioDivider.frame.origin.y, bioDivider.frame.size.width, 0.5);
        websiteDivider.frame = CGRectMake(websiteDivider.frame.origin.x, websiteDivider.frame.origin.y, websiteDivider.frame.size.width, 0.5);
        
    }
//    [bannerBtn setTitleColor:[appDelegate colorWithHexString:@"11a3e7"] forState:UIControlStateNormal];
    
    editTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    editTableView.separatorColor = [appDelegate colorWithHexString:@"11a3e7"];
    editTableView.backgroundColor = [UIColor clearColor];
    if ([editTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [editTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    TCEND
}

- (void)setProfileInformationToUIObjects {
    TCSTART
    if ([self isNotNull:newAvatar]) {
        userProfilePic.image = newAvatar;
    } else {
        [userProfilePic setImageWithURL:[NSURL URLWithString:userDataModal.photoPath] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached];
        NSData *photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:userDataModal.photoPath]];
        if ([self isNotNull:photoData] && photoData.length > 0) {
            userProfilePic.image = [UIImage imageWithData:photoData];
        }
    }
    
    if ([self isNotNull:userDataModal.userName]) {
        usernameLbl.text = userDataModal.userName;
    } else {
        usernameLbl.text = @"";
    }

    if ([self isNotNull:userDataModal.website]) {
        websiteTxtField.text = userDataModal.website;
    } else {
        websiteTxtField.placeholder = @"Website...";
    }
    
    if ([self isNotNull:userDataModal.bio]) {
        bioTextField.text = userDataModal.bio;
    } else {
        bioTextField.placeholder = @"bio...";
    }
    TCEND
}

- (IBAction)onClickOfPhotoEditButton:(id)sender {
    TCSTART
    isActionSheetOpenedForBanner = NO;
    [self showActionSheet];
    TCEND
}

- (void)onClickOfCoverPhotoBtn {
    TCSTART
    isActionSheetOpenedForBanner = YES;
    [self showActionSheet];
    TCEND
}

- (void)showActionSheet {
    TCSTART
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Take photo",@"Choose from library", nil];
    actionSheet.backgroundColor = [UIColor whiteColor];
    [actionSheet showInView:appDelegate.window];
//    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    TCEND
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	TCSTART
	NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([buttonTitle caseInsensitiveCompare:@"Take photo"] == NSOrderedSame) {
        isImgSourceTypeCamera = YES;
        [self openCamera];
    } else if([buttonTitle caseInsensitiveCompare:@"Choose from library"] == NSOrderedSame) {
        isImgSourceTypeCamera = NO;
        [self chooseFromLibrary];
    }
	TCEND
}

- (void)chooseFromLibrary {
    @try {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            isImgSourceTypeCamera = NO;
            if (isActionSheetOpenedForBanner) {
                self.imagePicker = [[GKImagePicker alloc] init];
                self.imagePicker.cropSize = CGSizeMake(320, 150);
                self.imagePicker.delegate = self;
                self.imagePicker.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:self.imagePicker.imagePickerController animated:YES completion:nil];
            } else {
                UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.delegate = self;
                imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePickerController.allowsEditing = YES;
                [self presentViewController:imagePickerController animated:YES completion:nil];
            }
        }
        else{
            UIAlertView *camerAlert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Your device doesn't support camera or it is damaged" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil , nil];
            [camerAlert show];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)openCamera {
    
    @try {
        //Check whether camera is available or not
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            isImgSourceTypeCamera = YES;
            if (isActionSheetOpenedForBanner) {
                self.imagePicker = [[GKImagePicker alloc] init];
                self.imagePicker.cropSize = CGSizeMake(320, 150);
                self.imagePicker.delegate = self;
                self.imagePicker.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:self.imagePicker.imagePickerController animated:YES completion:nil];
            } else {
                UIImagePickerController *picker=[[UIImagePickerController alloc]init];
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                picker.delegate = self;
                picker.allowsEditing = YES;
                [self presentViewController:picker animated:YES completion:nil];
            }
            
        }
        else{
            UIAlertView *camerAlert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Your device doesn't support camera or it is damaged" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil , nil];
            [camerAlert show];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

#pragma mark ImagePicker Delegate methods.
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    TCSTART
    [self finishedPickingImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];//dismissing the camera view controller.
    TCEND
}

# pragma mark -
# pragma mark GKImagePicker Delegate Methods
- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image {
    [self finishedPickingImage:image];
    [self.imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)finishedPickingImage:(UIImage *)image {
    TCSTART
//    photoConfirmationView.frame = CGRectMake(0, 20 , photoConfirmationView.frame.size.width, photoConfirmationView.frame.size.height);
//    [appDelegate.window addSubview:photoConfirmationView];
//    
//    capturedImgView.layer.cornerRadius = 10.0f;
//    capturedImgView.layer.masksToBounds = YES;
    
    if (isActionSheetOpenedForBanner) {
        newBanner = image;
        NSData *imageData = UIImageJPEGRepresentation(newBanner,0);
        newBannerDataBase64 = [Base64 encodeBase64WithData:imageData];
    } else {
        newAvatar = image;
        NSData *imageData = UIImageJPEGRepresentation(newAvatar, 0);
        newAvatarDataBase64 = [Base64 encodeBase64WithData:imageData];
    }
    [self setProfileInformationToUIObjects];
//    [capturedImgView setImage:image];
    TCEND
}

- (IBAction)onClickOfCancelBtn:(id)sender {
    appDelegate.caller_ = nil;
    newAvatarDataBase64 = nil;
    newBannerDataBase64 = nil;
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)onclickOfSaveBtn:(id)sender {
    TCSTART
    if ([self verifyWebsite]) {
        appDelegate.caller_ = nil;
        NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
        [userDict setObject:userDataModal.userId?:@"" forKey:@"userid"];
        [userDict setObject:userDataModal.userName?:@"" forKey:@"name"];
        [userDict setObject:userDataModal.country?:@"" forKey:@"country"];
        [userDict setObject:userDataModal.profession?:@"" forKey:@"profession"];
        [userDict setObject:userDataModal.website?:@"" forKey:@"website"];
        [userDict setObject:userDataModal.phoneNumber?:@"" forKey:@"phone"];
        [userDict setObject:userDataModal.gender?:@"" forKey:@"gender"];
        [userDict setObject:userDataModal.bio?:@"" forKey:@"bio"];
        if ([self isNotNull:newBannerDataBase64] && newBannerDataBase64.length > 0) {
            [userDict setObject:newBannerDataBase64 forKey:@"banner"];
        }
        if ([self isNotNull:newAvatarDataBase64] && newAvatarDataBase64.length > 0) {
            [userDict setObject:newAvatarDataBase64 forKey:@"photo"];
        }
        [appDelegate updateProfileOfLoggedInUserWithCaller:self withUserInfo:userDict];
        [appDelegate showActivityIndicatorInView:editTableView andText:@"Saving"];
        [appDelegate showNetworkIndicator];
    } else {
        [ShowAlert showError:@"Website url is not valid."];
        [websiteTxtField becomeFirstResponder];
    }
    
    TCEND
}

- (BOOL)verifyWebsite {
    if ([self isNotNull:userDataModal.website]) {
        NSString *url;
        if (![userDataModal.website hasPrefix:@"http://"]) {
            url = [NSString stringWithFormat:@"http://%@",userDataModal.website];
        } else {
            url = userDataModal.website;
        }
        return [appDelegate validateUrl:url];
    } else {
        return YES;
    }
}

/** After updating profile check for photo_path or banner_path
 */
- (void)didFinishedToUpdateUserProfile:(NSDictionary *)results {
    TCSTART
    [appDelegate removeNetworkIndicatorInView:editTableView];
    [appDelegate hideNetworkIndicator];
    if ([self isNotNull:[results objectForKey:@"photo_path"]]) {
        userDataModal.photoPath = [results objectForKey:@"photo_path"];
    }
    
    if ([self isNotNull:[results objectForKey:@"banner_path"]]) {
        [[SDImageCache sharedImageCache] removeImageForKey:userDataModal.bannerPath];
        userDataModal.bannerPath = [results objectForKey:@"banner_path"];
    }
    
    [self updateAppDelegateLoggedInUserObjectValues];
    newAvatarDataBase64 = nil;
    newAvatar = nil;
    newBannerDataBase64 = nil;
    newBanner = nil;
    [self.navigationController popViewControllerAnimated:YES];
    TCEND
}

- (void)didFailToUpdateUserProfileWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate removeNetworkIndicatorInView:editTableView];
    [appDelegate hideNetworkIndicator];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

#pragma mark
#pragma TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    if (indexPath.row < 3) {
        return 40;
    } else if (indexPath.row == 3) {
        return 120;
    } else {
        return 65;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    @try {
        //////for first section of edit ui
        if (indexPath.section == 0) {
            if (indexPath.row == 0)  {
                static NSString *cellIdentifier = @"PrivateCellId";
                
                UILabel *emailLbl = nil;
                UIImageView *emailImgView = nil;
                UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if(cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    
                    emailLbl = [[UILabel alloc] initWithFrame:CGRectMake(44, 5, 266, 30)];
                    emailLbl.backgroundColor = [UIColor clearColor];
                    emailLbl.textColor = [UIColor blackColor];
                    emailLbl.font = [UIFont fontWithName:descriptionTextFontName size:12];
                    emailLbl.tag = 1;
                    emailLbl.textAlignment = UITextAlignmentLeft;
                    [cell addSubview:emailLbl];
                    
                    emailImgView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 24, 24)];
                    emailImgView.tag = 2;
                    [cell addSubview:emailImgView];
                }
                
                if ([self isNull:emailLbl]) {
                    emailLbl = (UILabel *)[cell viewWithTag:1];
                }
                
                if ([self isNull:emailImgView]) {
                    emailImgView = (UIImageView *)[cell viewWithTag:2];
                }
                if ([self isNotNull:userDataModal.emailAddress]) {
                    emailLbl.text = userDataModal.emailAddress;
                } else  {
                    emailLbl.text = userDataModal.userName;
                }
                
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                emailImgView.image = [UIImage imageNamed:@"email"];
                return cell;
            }
            
            if (indexPath.row == 1) {
                static NSString *cellIdentifier = @"PhoneNumCellID";
            
                UITextField *phoneField = nil;
                UIImageView *phoneImgView = nil;
                UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if(cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                
                    phoneField = [[UITextField alloc] initWithFrame:CGRectMake(44, 5, 266, 30)];
                    phoneField.backgroundColor = [UIColor clearColor];
                    phoneField.textColor = [UIColor blackColor];
                    phoneField.font = [UIFont fontWithName:descriptionTextFontName size:12];
                    phoneField.tag = 3;
                    phoneField.delegate = self;
                    phoneField.returnKeyType = UIReturnKeyDone;
                    phoneField.textAlignment = UITextAlignmentLeft;
                    phoneField.borderStyle = UITextBorderStyleNone;
                    phoneField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                    [cell addSubview:phoneField];
                    
                    phoneImgView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 24, 24)];
                    phoneImgView.tag = 1;
                    [cell addSubview:phoneImgView];
                    
                }
                
                if ([self isNull:phoneImgView]) {
                    phoneImgView = (UIImageView *)[cell viewWithTag:1];
                }
                if ([self isNull:phoneField]) {
                    phoneField = (UITextField *)[cell viewWithTag:3];
                }
                
                if ([self isNotNull:userDataModal.phoneNumber]) {
                    phoneField.text = userDataModal.phoneNumber;
                } else {
                    phoneField.placeholder = @"Phone number...";
                }
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                phoneImgView.image = [UIImage imageNamed:@"phone"];
                return cell;
            }
            
            if (indexPath.row == 2) {
                static NSString *cellIdentifier = @"GenderCellId";
                
                UILabel *genderLabl = nil;
                UIImageView *genderImgView = nil;
                
                UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if(cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

                    
                    genderLabl = [[UILabel alloc] initWithFrame:CGRectMake(44, 5, 168, 30)];
                    genderLabl.backgroundColor = [UIColor clearColor];
                    genderLabl.textColor = [UIColor blackColor];
                    genderLabl.font = [UIFont fontWithName:descriptionTextFontName size:12];
                    genderLabl.tag = 2;
                   
                    genderLabl.textAlignment = UITextAlignmentLeft;
                    [cell addSubview:genderLabl];
                    
                    genderImgView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 24, 24)];
                    genderImgView.tag = 3;
                    [cell addSubview:genderImgView];
                    
                }
                
                if ([self isNull:genderLabl]) {
                    genderLabl = (UILabel *)[cell viewWithTag:2];
                }
                
                if ([self isNull:genderImgView]) {
                    genderImgView = (UIImageView *)[cell viewWithTag:3];
                }
                if ([self isNotNull:userDataModal.gender] && userDataModal.gender.length > 0) {
                    genderLabl.text = userDataModal.gender;
                } else {
                    genderLabl.text = @"Not Specified";
                }
                
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                genderImgView.image = [UIImage imageNamed:@"gender"];
                return cell;
            }
            if (indexPath.row == 3) {
                static NSString *cellIdentifier = @"ChangePWDCellId";
                
                UIButton *changePWDBtn = nil;
                UILabel *changepwdLbl = nil;
                UIImageView *changePwdImage = nil;
                UIButton *coverBgBtn = nil;
                UILabel *shareTitleLbl = nil;
                
                UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if(cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                
                    changePwdImage = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 24, 24)];
                    changePwdImage.tag = 1;
                    [cell addSubview:changePwdImage];
                    
                    changepwdLbl = [[UILabel alloc] initWithFrame:CGRectMake(44, 5, 266, 30)];
                    changepwdLbl.backgroundColor = [UIColor clearColor];
                    changepwdLbl.textColor = [UIColor blackColor];
                    changepwdLbl.font = [UIFont fontWithName:descriptionTextFontName size:12];
                    changepwdLbl.tag = 2;
                    changepwdLbl.textAlignment = UITextAlignmentLeft;
                    changepwdLbl.text = @"change password";
                    [cell addSubview:changepwdLbl];
                    
                    changePWDBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    changePWDBtn.frame = CGRectMake(0, 0, 320, 40);
                    changePWDBtn.tag = 3;
                    [changePWDBtn addTarget:self action:@selector(changePassword) forControlEvents:UIControlEventTouchUpInside];
                    [cell addSubview:changePWDBtn];
                    
                    
                    coverBgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [coverBgBtn setBackgroundColor:[UIColor whiteColor]];
                    [coverBgBtn setTitle:@"Set Cover Background" forState:UIControlStateNormal];
                    [coverBgBtn setTitleColor:[appDelegate colorWithHexString:@"11a3e7"] forState:UIControlStateNormal];
                    coverBgBtn.titleLabel.font = [UIFont fontWithName:titleFontName size:15];
                    coverBgBtn.frame = CGRectMake(0, 40, 320, 40);
                    coverBgBtn.tag = 4;
                    [coverBgBtn addTarget:self action:@selector(onClickOfCoverPhotoBtn) forControlEvents:UIControlEventTouchUpInside];
                    [cell addSubview:coverBgBtn];
                    
                    shareTitleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, 320, 40)];
                    shareTitleLbl.backgroundColor = [UIColor clearColor];
                    shareTitleLbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
                    shareTitleLbl.font = [UIFont fontWithName:titleFontName size:15];
                    shareTitleLbl.tag = 5;
                    shareTitleLbl.text = @"Sharing";
                    shareTitleLbl.textAlignment = UITextAlignmentCenter;
                    [cell addSubview:shareTitleLbl];
                }
                if ([self isNull:changePwdImage]) {
                    changePwdImage = (UIImageView *)[cell viewWithTag:1];
                }
                if ([self isNull:changepwdLbl]) {
                    changepwdLbl = (UILabel *)[cell viewWithTag:2];
                }
                if ([self isNull:changePWDBtn]) {
                    changePWDBtn = (UIButton *)[cell viewWithTag:3];
                }
                if ([self isNull:coverBgBtn]) {
                    coverBgBtn = (UIButton *)[cell viewWithTag:4];
                }
                
                if ([self isNull:shareTitleLbl]) {
                    shareTitleLbl = (UILabel *)[cell viewWithTag:5];
                }
                
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"issociallogin"]) {
                    changePWDBtn.enabled = NO;
                } else {
                    changePWDBtn.enabled = YES;
                }
                
                changePwdImage.image = [UIImage imageNamed:@"password"];
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            
            if (indexPath.row > 3) {
                static NSString *cellIdentifier = @"shareCellId";
                
                UIImageView *shareIamgeView = nil;
                UILabel *shareLabel = nil;
                UILabel *shareEmailLbl = nil;
                UICustomSwitch *connectSwitch = nil;
                UIButton *connectBtn;
                UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if(cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    
                    shareIamgeView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 45 , 45)];
                    shareIamgeView.tag = 1;
                    [cell addSubview:shareIamgeView];
                    
                    shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 5, 100, 25)];
                    shareLabel.backgroundColor = [UIColor clearColor];
                    shareLabel.textColor = [appDelegate colorWithHexString:@"11a3e7"];
                    shareLabel.tag = 2;
                    shareLabel.font = [UIFont fontWithName:titleFontName size:14];
                    [cell addSubview:shareLabel];
                    
                    shareEmailLbl = [[UILabel alloc] initWithFrame:CGRectMake(85, 35, 150, 20)];
                    shareEmailLbl.backgroundColor = [UIColor clearColor];
                    shareEmailLbl.textColor = [UIColor blackColor];
                    shareEmailLbl.font = [UIFont fontWithName:descriptionTextFontName size:11];
                    shareEmailLbl.tag = 3;
                    [cell addSubview:shareEmailLbl];
                    
                    CGRect connectSwitchRect = CGRectMake(230, 16, 55, 33);
                    connectSwitch = [UICustomSwitch switchWithLeftText:@"" andRight:@""];
                    connectSwitch.frame = connectSwitchRect;
                    [connectSwitch setThumbImage:[UIImage imageNamed:@"ToggleThumb" ] forState:UIControlStateNormal];
                    [connectSwitch setMinimumTrackImage:[[UIImage imageNamed:@"ToggleOn"]resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)] forState:UIControlStateNormal];
                    [connectSwitch setMaximumTrackImage:[[UIImage imageNamed:@"ToggleOff"]resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)] forState:UIControlStateNormal];
                    connectSwitch.tag = 4;
                    [connectSwitch addTarget:self action:@selector(connectSwitchFlipped: withEvent:) forControlEvents:UIControlEventValueChanged];
                    [cell addSubview:connectSwitch];
                    
                    connectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [connectBtn setBackgroundImage:[UIImage imageNamed:@"SocialNameBtn"] forState:UIControlStateNormal];
                    [connectBtn setTitle:@"Connect" forState:UIControlStateNormal];
                    [connectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    connectBtn.titleLabel.font = [UIFont fontWithName:titleFontName size:12];
                    connectBtn.frame = CGRectMake(225, 20, 60, 26);
                    connectBtn.tag = 5;
                    [connectBtn addTarget:self action:@selector(onClickOfConnectButton: withEvent:) forControlEvents:UIControlEventTouchUpInside];
                    [cell addSubview:connectBtn];
                }
                
                if ([self isNull:shareIamgeView]) {
                    shareIamgeView = (UIImageView *)[cell viewWithTag:1];
                }
                
                if ([self isNull:shareLabel]) {
                    shareLabel = (UILabel *)[cell viewWithTag:2];
                }
                
                if ([self isNull:shareEmailLbl]) {
                    shareEmailLbl = (UILabel *)[cell viewWithTag:3];
                }

                if ([self isNull:connectSwitch]) {
                    connectSwitch = (UICustomSwitch *)[cell viewWithTag:4];
                }
                
                if ([self isNull:connectBtn]) {
                    connectBtn = (UIButton *)[cell viewWithTag:5];
                }
                
                if (indexPath.row == 4) {
                    shareLabel.text = @"Facebook";
                    shareIamgeView.image = [UIImage imageNamed:@"FBFinder"];
                    if ([self isNotNull:[appDelegate.loggedInUser.socialContactsDictionary objectForKey:@"FB"]]) {
                        shareEmailLbl.text = [appDelegate.loggedInUser.socialContactsDictionary objectForKey:@"FB"];
                    } else {
                        shareEmailLbl.text = @"";
                    }
                } else if (indexPath.row == 5) {
                    shareLabel.text = @"Twitter";
                    shareIamgeView.image = [UIImage imageNamed:@"TWFinder"];
                    if ([self isNotNull:[appDelegate.loggedInUser.socialContactsDictionary objectForKey:@"TW"]]) {
                        shareEmailLbl.text = [appDelegate.loggedInUser.socialContactsDictionary objectForKey:@"TW"];
                    } else {
                        shareEmailLbl.text = @"";
                    }
                    
                } else {
                    shareLabel.text = @"Google+";
                    shareIamgeView.image = [UIImage imageNamed:@"GPlusFinder"];
                    if ([self isNotNull:[appDelegate.loggedInUser.socialContactsDictionary objectForKey:@"GPLUS"]]) {
                        shareEmailLbl.text = [appDelegate.loggedInUser.socialContactsDictionary objectForKey:@"GPLUS"];
                    } else {
                        shareEmailLbl.text = @"";
                    }
                }
                
                if (shareEmailLbl.text.length > 0) {
                    shareEmailLbl.hidden = NO;
                    connectSwitch.hidden = NO;
                    connectSwitch.on = YES;
                    connectBtn.hidden = YES;
                    shareLabel.frame = CGRectMake(shareLabel.frame.origin.x, shareLabel.frame.origin.y, shareLabel.frame.size.width, 35);
                } else {
                    shareEmailLbl.hidden = YES;
                    connectSwitch.hidden = YES;
                    connectSwitch.on = NO;
                    connectBtn.hidden = NO;
                    shareLabel.frame = CGRectMake(shareLabel.frame.origin.x, shareLabel.frame.origin.y, shareLabel.frame.size.width, 55);
                }
                
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;
            }
        }
        return nil;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if (indexPath.row == 2) {
        [self configureTheGenderPicker];
    }
    TCEND
}

#pragma mark Gender
- (void)configureTheGenderPicker {
    TCSTART
    [websiteTxtField resignFirstResponder];
    [bioTextField resignFirstResponder];
    UITableViewCell *cell = (UITableViewCell *)[editTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UITextField *phoneNumTxtField = (UITextField *)[cell viewWithTag:3];
    [phoneNumTxtField resignFirstResponder];
    
    genderView.frame = CGRectMake(0, 0, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height);
    [appDelegate.window addSubview:genderView];
    
    genderView.backgroundColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:.8f];
    if ([userDataModal.gender caseInsensitiveCompare:@"Male"] == NSOrderedSame) {
        [genderPickerView selectRow:1 inComponent:0 animated:YES];
    } else if ([userDataModal.gender caseInsensitiveCompare:@"Female"] == NSOrderedSame) {
        [genderPickerView selectRow:2 inComponent:0 animated:YES];
    } else {
        [genderPickerView selectRow:0 inComponent:0 animated:YES];
    }
    
    if (appDelegate.window.frame.size.height == 480) {
        editTableView.contentInset = UIEdgeInsetsMake(0.0, 0.0f, 120, 0.0f);
        [editTableView setContentOffset:CGPointMake(editTableView.contentOffset.x, 120) animated:YES];
    }
    
    TCEND
}


#pragma mark
#pragma mark PickerViewRelatedMethods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 3;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    TCSTART
    return [genderArray objectAtIndex:row];
    TCEND
}
/**- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
}
*/
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    TCSTART
    userDataModal.gender = [genderArray objectAtIndex:row];
    [editTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:0], nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    TCEND
}

- (IBAction)genderPickerDoneClick {
   TCSTART
    editTableView.contentInset = UIEdgeInsetsMake(0.0, 0.0f, 0.0f, 0.0f);
    [editTableView setContentOffset:CGPointMake(editTableView.contentOffset.x, 0.0f) animated:YES];
    [genderView removeFromSuperview];
    TCEND
}

#pragma mark change password
- (void)changePassword {
    TCSTART
    ChangePassWordViewController *changePasswordVC = [[ChangePassWordViewController alloc] initWithNibName:@"ChangePassWordViewController" bundle:nil];
    [self.navigationController pushViewController:changePasswordVC animated:YES];
    TCEND
}

//#pragma mark Select Switch Flipped
//- (void)genderSwitchFlipped:(UICustomSwitch*)switchView {
//    //	NSLog(@"switchFlipped=%f  on:%@",switchView.value, (switchView.on?@"Y":@"N"));
//	if (switchView.on) {
//        userDataModal.gender = @"Male";
//        NSLog(@"Male Selected");
//    } else {
//        userDataModal.gender = @"Female";
//        NSLog(@"Female Selected");
//    }
//    [editTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:0], nil] withRowAnimation:UITableViewRowAnimationAutomatic];
//}

#pragma mark Sharing
- (void)connectSwitchFlipped:(UICustomSwitch *)connectSwitch withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:editTableView];
    if (indexPath.row == 4) {
        //Facebook
        [appDelegate facebookLogout];
        [appDelegate.loggedInUser.socialContactsDictionary setObject:@"" forKey:@"FB"];
    } else if (indexPath.row == 5) {
        //Twitter
        [appDelegate.twitterEngine clearAccessToken];
        appDelegate.twitterEngine.delegate = nil;
        appDelegate.twitterEngine = nil;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SavedAccessHTTPBody"];
        [appDelegate.loggedInUser.socialContactsDictionary setObject:@"" forKey:@"TW"];
    } else {
        //Google plus
        [[GPPSignIn sharedInstance] signOut];
        [[GPPSignIn sharedInstance] disconnect];
        [appDelegate.loggedInUser.socialContactsDictionary setObject:@"" forKey:@"GPLUS"];
    }
    [editTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:4 inSection:0],[NSIndexPath indexPathForRow:5 inSection:0],[NSIndexPath indexPathForRow:6 inSection:0], nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    TCEND
}

- (void)onClickOfConnectButton:(UIButton *)sender withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:editTableView];
    if (indexPath.row == 4) {
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
            [self getFacebookLoggedInUserEmailId];
        }
    } else if (indexPath.row == 5) {
        //Twitter
        appDelegate.twitterEngine.delegate = (id)appDelegate;
        if(!appDelegate.twitterEngine) {
            [appDelegate initializeTwitterEngineWithDelegate:appDelegate];
        }
        [appDelegate.twitterEngine loadAccessToken];
        appDelegate.caller_ = self;
        if(![appDelegate.twitterEngine isAuthorized]) {
            [[FHSTwitterEngine sharedEngine] showOAuthLoginControllerFromViewController:self withCompletion:^(BOOL success) {
                if (!success) {
                    [ShowAlert showError:@"Authentication failed, please try again"];
                } else {
                    NSLog(@"Twitter login success");
                }
            }];
        } else {
            [self getTwitterLoggedInUserEmailAddress];
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
            [self getGooglePlusLoggedInUserEmailAddress];
            [editTableView reloadData];
        }
    }
    
    TCEND
}


- (void)storeAccessToken:(NSString *)body {
    NSLog(@"Got tw oauth response %@",body);
    [[NSUserDefaults standardUserDefaults]setObject:body forKey:@"SavedAccessHTTPBody"];
    if ([self isNull:appDelegate.loggedInUser.socialContactsDictionary]) {
        appDelegate.loggedInUser.socialContactsDictionary = [[NSMutableDictionary alloc] init];
    }
    [appDelegate.loggedInUser.socialContactsDictionary setObject:appDelegate.twitterEngine.loggedInUsername?:@"" forKey:@"TW"];
}

-(NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    if (error) {
        [ShowAlert showError:@"Authentication failed, please try again"];
    } else {
        [self getGooglePlusLoggedInUserEmailAddress];
        [editTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:6 inSection:0], nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == 3) {
        [editTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    return TRUE;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    TCSTART
    NSString *textString = textField.text;
    
    if (range.length > 0) {
        textString = [textString stringByReplacingCharactersInRange:range withString:@""];
    } else {
        if(range.location == [textString length]) {
            textString = [textString stringByAppendingString:string];
        } else {
            textString = [textString stringByReplacingCharactersInRange:range withString:string];
        }
    }
    
    if (textField.tag == 1) {
        userDataModal.website = textString?:@"";
    }
    if (textField.tag == 2) {
        userDataModal.bio = textString?:@"";
    }
    if (textField.tag == 3) {
        userDataModal.phoneNumber = textString?:@"";
    }
    return YES;
    TCEND
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
    TCSTART
    UITableViewCell *cell = (UITableViewCell *)[editTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UITextField *phoneNumTxtField = (UITextField *)[cell viewWithTag:3];
    
    switch (textField.tag) {
        case 1:
            [bioTextField becomeFirstResponder];
            return YES;
        case 2:
            [phoneNumTxtField becomeFirstResponder];
            return YES;
        case 3:
            [phoneNumTxtField resignFirstResponder];
            return YES;
        default:
            break;
    }

    [textField resignFirstResponder];
    
    return TRUE;
    TCEND
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
