/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "ChangePassWordViewController.h"

@interface ChangePassWordViewController ()

@end

@implementation ChangePassWordViewController

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
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height - 20);
    passwordsDict = [[NSMutableDictionary alloc] init];

    if (CURRENT_DEVICE_VERSION >= 7.0) {
        changePasswordTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 42, self.view.frame.size.width, self.view.frame.size.height - 42) style:UITableViewStyleGrouped];
    } else {
        changePasswordTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 42, self.view.frame.size.width, self.view.frame.size.height - 42) style:UITableViewStylePlain];
    }
    changePasswordTableView.backgroundColor = [UIColor clearColor];
    changePasswordTableView.separatorColor = [appDelegate colorWithHexString:@"11a3e7"];
    changePasswordTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    changePasswordTableView.delegate = self;
    changePasswordTableView.dataSource = self;
    [self.view addSubview:changePasswordTableView];
    self.view.backgroundColor = [appDelegate colorWithHexString:@"f5f5f5"];
    TCEND
}

- (void) viewDidLayoutSubviews {
    TCSTART
    if (CURRENT_DEVICE_VERSION >= 7.0  && self.view.frame.size.height == appDelegate.window.frame.size.height) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.size.height = viewBounds.size.height - topBarOffset;
        self.view.frame = CGRectMake(viewBounds.origin.x, topBarOffset, viewBounds.size.width, viewBounds.size.height);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    TCEND
}

- (IBAction)onClickOfCancelBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onclickOfSaveBtn:(id)sender {
    TCSTART
    if ([self validateInput]) {
        [appDelegate changePassword:[passwordsDict objectForKey:@"current"] changedPassword:[passwordsDict objectForKey:@"new"] andCaller:self];
        [appDelegate showActivityIndicatorInView:changePasswordTableView andText:@"Changing"];
        [appDelegate showNetworkIndicator];
    }
    TCEND
}

- (void)didFinishedChangePasswordRequest:(NSDictionary *)results {
    TCSTART
    [appDelegate removeNetworkIndicatorInView:changePasswordTableView];
    [appDelegate hideNetworkIndicator];
    [self.navigationController popViewControllerAnimated:YES];
    TCEND
}
- (void)didFailChangePasswordRequestWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate removeNetworkIndicatorInView:changePasswordTableView];
    [appDelegate hideNetworkIndicator];
    
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

#pragma mark Tableview delegate and Data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (CURRENT_DEVICE_VERSION < 7.0) {
        return 35;
    } else {
        return 0;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    static NSString *cellIdentifier = @"cellId";
    
    UITextField *passwordTextfield;
    UILabel *lineLbl;
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        passwordTextfield = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 40)];
        passwordTextfield.borderStyle = UITextBorderStyleNone;
        passwordTextfield.textAlignment = UITextAlignmentCenter;
        passwordTextfield.font = [UIFont fontWithName:descriptionTextFontName size:14];
        passwordTextfield.textColor = [UIColor blackColor];
        passwordTextfield.tag = indexPath.row + 1 + indexPath.section;
        passwordTextfield.delegate = self;
        passwordTextfield.secureTextEntry = YES;
        passwordTextfield.clearsOnBeginEditing = NO;
        passwordTextfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [cell addSubview:passwordTextfield];
        
        lineLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, cell.frame.size.width, 1)];
        lineLbl.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
        [cell addSubview:lineLbl];
    }
    
    if ([self isNull:passwordTextfield]) {
        passwordTextfield = (UITextField *)[cell viewWithTag:indexPath.row + 1 + indexPath.section];
    }
    passwordTextfield.returnKeyType = UIReturnKeyNext;
    if (indexPath.row == 0 && indexPath.section == 0) {
        if ([self isNotNull:[passwordsDict objectForKey:@"current"]] && [[passwordsDict objectForKey:@"current"] length] > 0) {
            passwordTextfield.text = [passwordsDict objectForKey:@"current"];
        } else {
            passwordTextfield.placeholder = @"Current Password";
        }
        
    } else if (indexPath.row == 0 && indexPath.section == 1) {
        if ([self isNotNull:[passwordsDict objectForKey:@"new"]] && [[passwordsDict objectForKey:@"new"] length] > 0) {
            passwordTextfield.text = [passwordsDict objectForKey:@"new"];
        } else {
            passwordTextfield.placeholder = @"New password";
        }
    } else {
        if ([self isNotNull:[passwordsDict objectForKey:@"confirm"]] && [[passwordsDict objectForKey:@"confirm"] length] > 0) {
            passwordTextfield.text = [passwordsDict objectForKey:@"confirm"];
        } else {
           passwordTextfield.placeholder = @"New password, again";
        }
        passwordTextfield.returnKeyType = UIReturnKeyDone;
    }
    
    cell.imageView.image = [UIImage imageNamed:@"password"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0 && CURRENT_DEVICE_VERSION < 7.0) {
        lineLbl.hidden = NO;
    } else {
        lineLbl.hidden = YES;
    }
    return cell;
    
    TCEND
}

#pragma mark TextField Delegate Methods
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
        [passwordsDict setObject:textString?:@"" forKey:@"current"];
    }
    if (textField.tag == 2) {
        [passwordsDict setObject:textString?:@"" forKey:@"new"];
    }
    if (textField.tag == 3) {
        [passwordsDict setObject:textString?:@"" forKey:@"confirm"];
    }
   
    return YES;
    TCEND
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    @try {
        if (textField.tag == 1) {
            UITableViewCell *cell = (UITableViewCell *)[changePasswordTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            UITextField *textfiel = (UITextField *)[cell viewWithTag:2];
            [textfiel becomeFirstResponder];
        }
        
        if (textField.tag >= 2) {
            UITableViewCell *cell = (UITableViewCell *)[changePasswordTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
            UITextField *textfiel = (UITextField *)[cell viewWithTag:3];
            if (textField.tag == 2) {
                [textfiel becomeFirstResponder];
            } else {
                [textfiel resignFirstResponder];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

-(BOOL) validateInput {
    
    TCSTART
    NSString *currentPWD = @"";
    NSString *newPWD = @"";
    NSString *confirmPWD = @"";
    if ([self isNotNull:[passwordsDict objectForKey:@"current"]]) {
        currentPWD = [passwordsDict objectForKey:@"current"];
    }
    if ([self isNotNull:[passwordsDict objectForKey:@"new"]]) {
        newPWD = [passwordsDict objectForKey:@"new"];
    }
    if ([self isNotNull:[passwordsDict objectForKey:@"confirm"]]) {
        confirmPWD = [passwordsDict objectForKey:@"confirm"];
    }
    BOOL isValid = YES;
    if (isValid && currentPWD.length <= 0) {
        [ShowAlert showAlert:@"Please enter your current password"];
        isValid = NO;
    }
    //        //password field
    if (isValid && (newPWD.length < 8 || newPWD.length > 20)) {
        [ShowAlert showAlert:@"Please enter a valid password of min 8 and max 20 characters"];
        isValid = NO;
    }
    //        //confirm password
    if(isValid && ![newPWD isEqualToString:confirmPWD]) {
        isValid = NO;
        [ShowAlert showAlert:@"Your password does not match"];
    }
    return isValid;
    TCEND
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
