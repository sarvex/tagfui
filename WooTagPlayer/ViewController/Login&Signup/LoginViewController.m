/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "ForgotPasswordViewController.h"

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
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
//    if (isViewModeUp) {
//        [self setViewMovedUp:NO andFieldTag:0];
//        previousMovedUpHeight = 0;
//    }
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    // NSLog(@"applicationWillResignActive from loginview");
    //    userNameTextField.text = @"";
    //    passWordTextField.text = @"";
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    //   NSLog(@"applicationWillEnterForeground in loginview");
    //    [self setTextToEmailFieldAndPassword];
//    previousMovedUpHeight = 0;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    TCSTART
    [super viewDidLoad];
    loginDetailsDict = [[NSMutableDictionary alloc] init];
    int diff = ((CURRENT_DEVICE_VERSION >= 7.0)?0:-20);
    if (appDelegate.window.frame.size.height > 480) {
        backgroundImageView.image = [UIImage imageNamed:@"loginbgiPhone5"];
        forgotPasswordButton.frame = CGRectMake(95, 317, 130, 28);
        loginButton.frame = CGRectMake(55, 354, 209, 38);
        signUpButton.frame = CGRectMake(55, 395, 209, 38);
    } else {
         backgroundImageView.image = [UIImage imageNamed:@"login_bg"];
        forgotPasswordButton.frame = CGRectMake(95, 274 + diff, 130, 28);
        loginButton.frame = CGRectMake(55, 311 + diff, 209, 38);
        signUpButton.frame = CGRectMake(55, 352 + diff, 209, 38);
    }
    loginTableView.backgroundView = nil;
    loginTableView.backgroundColor = [UIColor clearColor];
    if (CURRENT_DEVICE_VERSION < 7.0) {
        loginTableView.separatorColor = [UIColor clearColor];
    } else {
        loginTableView.separatorColor = [UIColor whiteColor];
    }
//    [self setImageToRememberMeButton];
    [self setTextToEmailFieldAndPassword];
    
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
    return 2;
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
    
    NSString *cellIdentifier = @"LoginCellIdentifier";
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
    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"LoginMailIcon"];
        if ([self isNotNull:[loginDetailsDict objectForKey:@"email"]]) {
            userTextField.text = [loginDetailsDict objectForKey:@"email"]?:@"";
        } else {
            userTextField.placeholder = @"email address";
        }
        userTextField.returnKeyType = UIReturnKeyNext;
        userTextField.keyboardType = UIKeyboardTypeEmailAddress;
    } else {
        cell.imageView.image = [UIImage imageNamed:@"LoginPasswordIcon"];
        if ([self isNotNull:[loginDetailsDict objectForKey:@"password"]]) {
            userTextField.text = [loginDetailsDict objectForKey:@"password"];
        } else {
            userTextField.placeholder = @"password";
        }
        
        userTextField.returnKeyType = UIReturnKeyDone;
        userTextField.keyboardType = UIKeyboardTypeDefault;
        userTextField.secureTextEntry = YES;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (CURRENT_DEVICE_VERSION < 7.0) {
        if (indexPath.row == 0) {
            toplineLbl.frame = CGRectMake(0, 0, cell.frame.size.width, 0.5);
            toplineLbl.hidden = NO;
            bottomlineLbl.hidden = YES;
        } else {
            toplineLbl.frame = CGRectMake(50, 0, cell.frame.size.width - 50, 0.5);
            bottomlineLbl.hidden = NO;
        }
    } else {
        toplineLbl.hidden = YES;
        bottomlineLbl.hidden = YES;
    }
    [userTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    return cell;
    
    TCEND
}

- (void)setTextToEmailFieldAndPassword {
    TCSTART
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [loginDetailsDict setObject:[defaults objectForKey:@"username"]?:@"" forKey:@"email"];
    [loginDetailsDict setObject:[defaults objectForKey:@"password"]?:@"" forKey:@"password"];
    [loginTableView reloadData];
    TCEND
}


//- (void) viewDidLayoutSubviews {
//    if (CURRENT_DEVICE_VERSION >= 7.0  && self.view.frame.size.height == appDelegate.window.frame.size.height) {
//        CGRect viewBounds = self.view.bounds;
//        CGFloat topBarOffset = self.topLayoutGuide.length;
//        viewBounds.size.height = viewBounds.size.height - topBarOffset;
//        self.view.frame = CGRectMake(viewBounds.origin.x, topBarOffset, viewBounds.size.width, viewBounds.size.height);
//        
//    }
//}

//- (void)setImageToRememberMeButton {
//    TCSTART
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"remember"]) {
//        [rememberBtn setImage:[UIImage imageNamed:@"Reminder_f"] forState:UIControlStateNormal];
//    } else {
//        [rememberBtn setImage:[UIImage imageNamed:@"Reminder"] forState:UIControlStateNormal];
//    }
//    TCEND
//}
//- (IBAction)onClickOfRemembermeButton:(id)sender {
//    TCSTART
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"remember"]) {
//        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"remember"];
//    } else {
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"remember"];
//    }
//    [self setImageToRememberMeButton];
//    TCEND
//}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)btnForgotPasswordTouched:(id)sender {
    
    TCSTART
//    [userNameTextField resignFirstResponder];
//    [passWordTextField resignFirstResponder];
    
    ForgotPasswordViewController *forgotPasswordVC = [[ForgotPasswordViewController alloc]initWithNibName:@"ForgotPasswordViewController" bundle:nil];
    [self.navigationController pushViewController:forgotPasswordVC animated:YES];
    TCEND
}

-(IBAction)btnLogInTouched:(id)sender {
    
    TCSTART
    //TODO COMMENT
    //compare username & pwds before POSTING request
    if ([self validateInput] ) {
        [appDelegate loginUser:[loginDetailsDict objectForKey:@"email"] password:[loginDetailsDict objectForKey:@"password"]];
    }
    TCEND
}

- (void)signUpViewControllerNeedToHideCancelButton:(BOOL)hide {
    TCSTART
    SignUpViewController *signUpVC = [[SignUpViewController alloc]initWithNibName:@"SignUpViewController" bundle:nil];
    [self.navigationController pushViewController:signUpVC animated:!hide];
    TCEND
}
- (IBAction)btnSignUpTouched:(id)sender {
    TCSTART
//    [userNameTextField resignFirstResponder];
//    [passWordTextField resignFirstResponder];
    [self signUpViewControllerNeedToHideCancelButton:NO];
    
    TCEND
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

- (BOOL) validateInput {
    TCSTART
    BOOL isValid = YES;
    //username
    NSString *emailAddress = [loginDetailsDict objectForKey:@"email"];
    if (emailAddress.length > 0) {
        emailAddress = [appDelegate removingLastSpecialCharecter:emailAddress];
    } else {
        UITableViewCell *cell = [loginTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UITextField *textField = (UITextField *)[cell viewWithTag:1];
        [textField becomeFirstResponder];
    }
    isValid = [appDelegate validateEmailWithString:emailAddress WithIdentifier:@"email address"];
    if (isValid) {
        //        //password field
        NSString *password = [loginDetailsDict objectForKey:@"password"];
        if (password.length > 0) {
            password = [appDelegate removingLastSpecialCharecter:password];
        }
        if ([password length] > 0) {
        } else {
            UITableViewCell *cell = [loginTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            UITextField *textField = (UITextField *)[cell viewWithTag:2];
            [textField becomeFirstResponder];
            [ShowAlert showAlert:@"Please enter password"];
            return FALSE;
        }
        return TRUE;
    } else {
        return isValid;
    }
    
    
    TCEND
}


#pragma mark -
#pragma mark UITextFieldDelegate Methods

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField{
    return TRUE;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    TCSTART
    TCEND
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    TCSTART
    if ([string isEqualToString:@" "]) {
        return NO;
    }
    if (textField.tag == 1) {
        [loginDetailsDict setObject:textField.text?:@"" forKey:@"email"];
    } else {
        [loginDetailsDict setObject:textField.text?:@"" forKey:@"password"];
    }
    return YES;
    TCEND
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
    TCSTART
    
    if(textField.tag < 2) {
        switch (textField.tag) {
            case 1: {
                UITableViewCell *cell = [loginTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                UITextField *textField = (UITextField *)[cell viewWithTag:2];
                [textField becomeFirstResponder];
            }
                return YES;
            default:
                break;
        }
    }
    
    [textField resignFirstResponder];
    
    return TRUE;
    TCEND
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 1) {
        [loginDetailsDict setObject:textField.text?:@"" forKey:@"email"];
    } else {
        [loginDetailsDict setObject:textField.text?:@"" forKey:@"password"];
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

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
    
}

@end
