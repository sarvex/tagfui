/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "ForgotPasswordViewController.h"
#import "WooTagPlayerAppDelegate.h"
#import "MBProgressHUD.h"

@implementation ForgotPasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication]delegate];
    }
    return self;
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
    emailIconImgView.image = [UIImage imageNamed:@"LoginMailIcon"];
    [emailAddressTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    if (appDelegate.window.frame.size.height > 480) {
        backgroundImgView.image = [UIImage imageNamed:@"loginbgiPhone5"];
       
    } else {
        backgroundImgView.image = [UIImage imageNamed:@"login_bg"];
    }
    [emailAddressTextField becomeFirstResponder];
    TCEND
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(IBAction)popToLoginScreen:(id)sender {
    
    TCSTART
        [self.navigationController popViewControllerAnimated:YES];
    TCEND
}

-(IBAction)emailNewPassword:(id)sender {
    
   TCSTART
    [emailAddressTextField resignFirstResponder];
    if (emailAddressTextField.text.length > 0) {
        emailAddressTextField.text = [appDelegate removingLastSpecialCharecter:emailAddressTextField.text];
    }
        if ([appDelegate validateEmailWithString:emailAddressTextField.text WithIdentifier:@"email address"] ) {
            [appDelegate sendNewPasswordToEmail:emailAddressTextField.text fromViewController:self];
        }
    TCEND
}
-(void)didFailEmailNewPasswordequestWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}
- (void)didFinishEmailNewPasswordRequest:(NSDictionary *)results{

    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    
    if ([self isNotNull:results]) {
        if ([self isNotNull:results]) {
            [ShowAlert showAlert:[results objectForKey:@"msg"]];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    TCEND
}
-(void)removepasswordSentConfirmationView:(id)sender {
    
    TCSTART
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    TCEND
}


#pragma mark -
#pragma mark UITextFieldDelegate Methods

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField{
	
    return TRUE;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
	[textField resignFirstResponder];
    
	return TRUE;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@" "]) {
        return NO;
    } else
        return YES;
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
