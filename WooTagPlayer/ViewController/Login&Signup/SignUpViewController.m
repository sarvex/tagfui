/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "SignUpViewController.h"
#import "WooTagPlayerAppDelegate.h"

@implementation SignUpViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication]delegate];
        // On iOS 4.0+ only, listen for background notification
        if(&UIApplicationWillResignActiveNotification != nil)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        }
        
        // On iOS 4.0+ only, listen for foreground notification
        if(&UIApplicationWillEnterForegroundNotification != nil)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardHideNotification) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)keyBoardHideNotification {
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    //   NSLog(@"applicationWillEnterForeground in loginview");
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    TCSTART
    [super viewDidLoad];
    signUpDetailsDict = [[NSMutableDictionary alloc] init];
//    int diff = ((CURRENT_DEVICE_VERSION >= 7.0)?0:-20);
    if (appDelegate.window.frame.size.height > 480) {
        backgroundImgView.image = [UIImage imageNamed:@"loginbgiPhone5"];
        cancelButton.frame = CGRectMake(20, 394, 135, 38);
        signUpButton.frame = CGRectMake(165, 394, 135, 38);
    } else {
        backgroundImgView.image = [UIImage imageNamed:@"login_bg"];
        cancelButton.frame = CGRectMake(20, 336, 135, 38);
        signUpButton.frame = CGRectMake(165, 336, 135, 38);
    }
    
    signUpTableView.backgroundView = nil;
    signUpTableView.backgroundColor = [UIColor clearColor];
    if (CURRENT_DEVICE_VERSION < 7.0) {
        signUpTableView.separatorColor = [UIColor clearColor];
    } else {
        signUpTableView.separatorColor = [UIColor whiteColor];
    }
    if (appDelegate.window.frame.size.height > 480) {
        signUpTableView.scrollEnabled = NO;
    } else {
        signUpTableView.scrollEnabled = YES;
    }
    TCEND
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark DataSource and Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    
    NSString *cellIdentifier = @"RegCellIdentifier";
    UITextField *userTextField = nil;
    UILabel *toplineLbl;
    UILabel *bottomlineLbl;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        userTextField = [[UITextField alloc] init];
        userTextField.delegate = self;
        userTextField.font = [UIFont fontWithName:descriptionTextFontName size:15];
        userTextField.borderStyle = UITextBorderStyleNone;
        userTextField.backgroundColor = [UIColor clearColor];
        userTextField.textAlignment = UITextAlignmentLeft;
        userTextField.textColor = [UIColor whiteColor];
        userTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        [userTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        userTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [cell addSubview:userTextField];
        
        toplineLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 0.5)];
        toplineLbl.backgroundColor = [UIColor whiteColor];
        [cell addSubview:toplineLbl];
        
        bottomlineLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 39.5, cell.frame.size.width, 0.5)];
        bottomlineLbl.backgroundColor = [UIColor whiteColor];
        [cell addSubview:bottomlineLbl];
    }
    userTextField.tag = indexPath.row + 1;
    if (!userTextField) {
        userTextField = (UITextField *)[cell viewWithTag:indexPath.row + 1];
    }
    userTextField.frame = CGRectMake(50, 0, 230, 40);
    userTextField.secureTextEntry = NO;
    userTextField.keyboardType = UIKeyboardTypeDefault;
    userTextField.returnKeyType = UIReturnKeyNext;
    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"LoginUsernameIcon"];
        if ([self isNotNull:[signUpDetailsDict objectForKey:@"username"]]) {
            userTextField.text = [signUpDetailsDict objectForKey:@"username"]?:@"";
        } else {
            userTextField.placeholder = @"username";
        }
        
    } else if (indexPath.row == 1) {
        cell.imageView.image = [UIImage imageNamed:@"LoginMailIcon"];
        if ([self isNotNull:[signUpDetailsDict objectForKey:@"email"]]) {
            userTextField.text = [signUpDetailsDict objectForKey:@"email"]?:@"";
        } else {
            userTextField.placeholder = @"email address";
        }
        
        userTextField.keyboardType = UIKeyboardTypeEmailAddress;
    } else if (indexPath.row == 2) {
        cell.imageView.image = [UIImage imageNamed:@"LoginPasswordIcon"];
        if ([self isNotNull:[signUpDetailsDict objectForKey:@"password"]]) {
            userTextField.text = [signUpDetailsDict objectForKey:@"password"]?:@"";
        } else {
            userTextField.placeholder = @"password";
        }
        
        userTextField.secureTextEntry = YES;
    } else {
        cell.imageView.image = [UIImage imageNamed:@"LoginPasswordIcon"];
        if ([self isNotNull:[signUpDetailsDict objectForKey:@"confirmpassword"]]) {
            userTextField.text = [signUpDetailsDict objectForKey:@"confirmpassword"]?:@"";
        } else {
            userTextField.placeholder = @"confirm password";
        }
        
        userTextField.returnKeyType = UIReturnKeyDone;
        userTextField.secureTextEntry = YES;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (CURRENT_DEVICE_VERSION < 7.0) {
        if (indexPath.row == 0) {
            toplineLbl.frame = CGRectMake(0, 0, cell.frame.size.width, 0.5);
            toplineLbl.hidden = NO;
        } else {
            toplineLbl.frame = CGRectMake(50, 0, cell.frame.size.width - 50, 0.5);
        }
        if (indexPath.row == 3) {
            bottomlineLbl.hidden = NO;
        } else {
            bottomlineLbl.hidden = YES;
        }
    } else {
        toplineLbl.hidden = YES;
        bottomlineLbl.hidden = YES;
    }
    [userTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    return cell;
    
    TCEND
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    
}


-(IBAction)btnFaceBookTouched:(id)sender{
    [appDelegate loginThroughFacebookFromCaller:nil];
}

- (IBAction)btnTwitterTouched:(id)sender {
    TCSTART
    [appDelegate loginThroughTwitterFromViewController:self];
    TCEND
}
-(IBAction)btnGooglePlusTouched:(id)sender{
    [appDelegate loginThroughGooglePlus];
}

-(IBAction)btnCancelTouched:(id)sender {
    
    TCSTART
    [self.navigationController popViewControllerAnimated:YES];
    TCEND
}

- (UITextField *)getTextFieldFromCellIndexRow:(NSInteger)row {
    TCSTART
    UITableViewCell *cell = [signUpTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    return (UITextField *)[cell viewWithTag:row+1];
    TCEND
}
- (IBAction)btnSignUpTouched:(id)sender {
    TCSTART
    if ([self validateInput]) {
        [appDelegate signUpUser:[signUpDetailsDict objectForKey:@"username"] withEmail:[signUpDetailsDict objectForKey:@"email"] withPassword:[signUpDetailsDict objectForKey:@"password"]];
    }
    TCEND
}

- (BOOL) validateInput {
    
    TCSTART
    BOOL isValid = YES;
    NSString *username = [signUpDetailsDict objectForKey:@"username"];
    if (username.length > 0) {
        username = [appDelegate removingLastSpecialCharecter:username];
    }
    // full name field
    if (username.length == 0) {
        [ShowAlert showAlert:@"Please enter username"];
        [[self getTextFieldFromCellIndexRow:0] becomeFirstResponder];
        isValid = NO;
        return isValid;
    }
    
    //        //email field
    NSString *email = [signUpDetailsDict objectForKey:@"email"];
    if (email.length > 0) {
        email = [appDelegate removingLastSpecialCharecter:email];
    }
    isValid = [appDelegate validateEmailWithString:email WithIdentifier:@"email address"];
    if (!isValid) {
        [[self getTextFieldFromCellIndexRow:1] becomeFirstResponder];
    }
    
    //        //password field
    NSString *password = [signUpDetailsDict objectForKey:@"password"];
    if (password.length > 0) {
        password = [appDelegate removingLastSpecialCharecter:password];
    }
    if (isValid && (password.length < 8 || password.length > 20)) {
        [ShowAlert showAlert:@"Please enter a valid password of min 8 and max 20 characters"];
         [[self getTextFieldFromCellIndexRow:2] becomeFirstResponder];
        isValid = NO;
    }
    
    //        //confirm password
    NSString *confirmPWd = [signUpDetailsDict objectForKey:@"confirmpassword"];
    if (confirmPWd.length > 0) {
        confirmPWd = [appDelegate removingLastSpecialCharecter:confirmPWd];
    }
    if(isValid && ![password isEqualToString:confirmPWd]) {
        isValid = NO;
        [ShowAlert showAlert:@"Passwords do not match."];
        [[self getTextFieldFromCellIndexRow:3] becomeFirstResponder];
    }
    return isValid;
    TCEND
}

#pragma mark -
#pragma mark UITextFieldDelegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
	
    TCSTART
    textField.rightViewMode = UITextFieldViewModeNever;
    NSLog(@"View origin y: %f and tag: %d",self.view.frame.origin.y,textField.tag );
    if (textField.tag == 4 && appDelegate.window.frame.size.height <= 480) {
        signUpTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, signUpTableView.frame.size.width, 20)];
        [signUpTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    return TRUE;
    TCEND
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    @try {
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    TCSTART
    if (textField.tag == 1) {
        if (textField.text.length == 0 && [string isEqualToString:@" "]) {
            return NO;
        } else {
            [signUpDetailsDict setObject:textField.text?:@"" forKey:@"username"];
            return YES;
            
        }
    } else {
        if ([string isEqualToString:@" "]) {
            return NO;
        } else {
            if (textField.tag == 2) {
                [signUpDetailsDict setObject:textField.text?:@"" forKey:@"email"];
            } else if (textField.tag == 3) {
                [signUpDetailsDict setObject:textField.text?:@"" forKey:@"password"];
            } else {
                [signUpDetailsDict setObject:textField.text?:@"" forKey:@"confirmpassword"];
            }
            return YES;
        }
    }
    
    TCEND
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
    TCSTART
    
    NSLog(@"TAG in textFieldShouldReturn: %d",textField.tag);
    if(textField.tag < 4) {
        switch (textField.tag) {
            case 1: //fullname textfield
                [[self getTextFieldFromCellIndexRow:1] becomeFirstResponder];
                return YES;
            case 2: //email address text field.
                [[self getTextFieldFromCellIndexRow:2] becomeFirstResponder];
                return YES;
            case 3: //passwordtextfield
                [[self getTextFieldFromCellIndexRow:3] becomeFirstResponder];
                return YES;
            default:
                break;
        }
    } else {
//        if (isViewModeUp) {
//            [self setViewMovedUp:NO andFieldTag:textField.tag];
//        }
    }
    
    if (textField.tag == 4 && appDelegate.window.frame.size.height <= 480) {
        [signUpTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
         signUpTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, signUpTableView.frame.size.width, 0)];
    }
    [textField resignFirstResponder];
    
    return TRUE;
    TCEND
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 1) {
        [signUpDetailsDict setObject:textField.text?:@"" forKey:@"username"];
    } else if (textField.tag == 2) {
        [signUpDetailsDict setObject:textField.text?:@"" forKey:@"email"];
    } else if (textField.tag == 3) {
        [signUpDetailsDict setObject:textField.text?:@"" forKey:@"password"];
    } else {
        [signUpDetailsDict setObject:textField.text?:@"" forKey:@"confirmpassword"];
    }
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    return YES;
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
