/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "BuyerInfoViewController.h"
#import "ProductDetailTextField.h"

@interface BuyerInfoViewController ()

@end

@implementation BuyerInfoViewController
@synthesize wootagInfoVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withBuyerInfo:(BuyerInfo *)info
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        buyerInfo = info;
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad
{
    TCSTART
    [super viewDidLoad];
    buyerDetailsDict = [[NSMutableDictionary alloc] init];
    if ([self isNotNull:buyerInfo]) {
        [buyerDetailsDict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:buyerInfo.name?:@"",@"name",buyerInfo.address?:@"",@"address",buyerInfo.mobileNumber?:@"",@"mobileNumber", nil]];
    }
    [buyerDetailsDict setObject:buyerInfo.emailId?:(appDelegate.loggedInUser.emailAddress?:@"") forKey:@"emailId"];
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height - 20);
    buyerDetailsTableView.backgroundColor = [UIColor clearColor];
    buyerDetailsTableView.separatorColor = [UIColor clearColor];
    buyerDetailsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, buyerDetailsTableView.frame.size.width, 60)];
    headerView.backgroundColor = [UIColor clearColor];
    UILabel *headerViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, buyerDetailsTableView.frame.size.width - 20, 50)];
    headerViewLabel.backgroundColor = [UIColor clearColor];
    headerViewLabel.font = [UIFont fontWithName:titleFontName size:14];
    headerViewLabel.textAlignment = UITextAlignmentLeft;
    headerViewLabel.textColor = [UIColor blackColor];
    headerViewLabel.numberOfLines = 0;
    headerViewLabel.text = [NSString stringWithFormat:@"Hi %@, Thanks for your interest in this product, please send in your details and will contact shortly to deliver",appDelegate.loggedInUser.userName];
    [headerView addSubview:headerViewLabel];
    buyerDetailsTableView.tableHeaderView = headerView;
    
    if (CURRENT_DEVICE_VERSION < 7.0) {
        buyerDetailsTableView.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    self.view.backgroundColor = [appDelegate colorWithHexString:@"eeeeee"];
    TCEND
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
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
- (void)reloadTable {
    [buyerDetailsTableView reloadData];
}

- (IBAction)onClickOfCancelBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [wootagInfoVC onClickOfCloseBtn:nil];
}
- (IBAction)onclickOfDoneBtn:(id)sender {
    if ([self validateInput]) {
        [wootagInfoVC onClickOfBuyBtnWithDict:[buyerDetailsDict mutableCopy]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)validateInput {
    TCSTART
    BOOL isValid = YES;
    NSString *buyerName = [buyerDetailsDict objectForKey:@"name"];
    if (buyerName.length > 0) {
        buyerName = [appDelegate removingLastSpecialCharecter:buyerName];
    }
    if (buyerName.length > 0) {
        
    } else {
        [ShowAlert showAlert:@"Please enter your Name, It is important for the seller to process the delivery"];
        isValid = NO;
        return isValid;
    }
    
    NSString *addrStr = [buyerDetailsDict objectForKey:@"address"];
    if (addrStr.length > 0) {
        addrStr = [appDelegate removingLastSpecialCharecter:addrStr];
    }
    
    if ([self isNotNull:[buyerDetailsDict objectForKey:@"emailId"]]) {
        NSString *emailId = [buyerDetailsDict objectForKey:@"emailId"];
        if (emailId.length > 0) {
            emailId = [appDelegate removingLastSpecialCharecter:emailId];
        }
        if (emailId.length <= 0) {
            isValid = NO;
        }
    } else {
        isValid = NO;
    }
    
    NSString *mobileNum = [buyerDetailsDict objectForKey:@"mobileNumber"];
    if (mobileNum.length > 0) {
        mobileNum = [appDelegate removingLastSpecialCharecter:mobileNum];
    }
    if (!isValid && mobileNum.length <= 0) {
        [ShowAlert showAlert:@"Please enter your Mobile No or Mail ID, It is important for the seller to process the delivery"];
    } else {
        isValid = YES;
    }
    
    NSString *messageStr = [buyerDetailsDict objectForKey:@"message"];
    if (messageStr.length > 0) {
        messageStr = [appDelegate removingLastSpecialCharecter:messageStr];
    }
    
    return isValid;
    TCEND
}

#pragma mark Tableview delegate and Data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 45;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, buyerDetailsTableView.frame.size.width, 45)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, buyerDetailsTableView.frame.size.width - 20, 30)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont fontWithName:titleFontName size:14];
    headerLabel.textAlignment = UITextAlignmentLeft;
    headerLabel.textColor = [UIColor blackColor];
    [headerView addSubview:headerLabel];
    headerView.backgroundColor = [UIColor clearColor];
    
    if (section == 0) {
        headerLabel.text = @"NAME";
    } else if (section == 1) {
        headerLabel.text = @"ADDRESS";
    } else if (section == 2) {
        headerLabel.text = @"EMAIL";
    } else if (section == 3) {
        headerLabel.text = @"MOBILE NUMBER";
    } else if (section == 4) {
        headerLabel.text = @"MESSAGE";
    }
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    static NSString *cellIdentifier = @"cellId";
    
    ProductDetailTextField *productAnsTextField;
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
        productAnsTextField = [[ProductDetailTextField alloc] init];
        productAnsTextField.borderStyle = UITextBorderStyleNone;
        productAnsTextField.font = [UIFont fontWithName:descriptionTextFontName size:14];
        productAnsTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        productAnsTextField.textColor = [UIColor blackColor];
        productAnsTextField.tag = 2;
        productAnsTextField.delegate = self;
        productAnsTextField.clearsOnBeginEditing = NO;
        productAnsTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        productAnsTextField.textAlignment = UITextAlignmentLeft;
        [appDelegate setLeftPaddingforTextField:productAnsTextField];
        
        [cell addSubview:productAnsTextField];
        
    }
    
    if ([self isNull:productAnsTextField]) {
        productAnsTextField = (ProductDetailTextField *)[cell viewWithTag:2];
    }
    
    
    productAnsTextField.frame = CGRectMake(10, 0, cell.frame.size.width - 20, 40);
    productAnsTextField.indexPath = indexPath;
    [productAnsTextField setBackground:[UIImage imageNamed:@"TextEnterBox"]];
    productAnsTextField.returnKeyType = UIReturnKeyNext;
     productAnsTextField.keyboardType = UIKeyboardTypeDefault;
    if (indexPath.section == 0) {
        if ([self isNotNull:[buyerDetailsDict objectForKey:@"name"]]) {
            productAnsTextField.text = [buyerDetailsDict objectForKey:@"name"];
        } else {
            productAnsTextField.text = @"";
            productAnsTextField.placeholder = @"Type your name";
        }
        
    } else if (indexPath.section == 1) {
       
        if ([self isNotNull:[buyerDetailsDict objectForKey:@"address"]]) {
            productAnsTextField.text = [buyerDetailsDict objectForKey:@"address"];
        } else {
            productAnsTextField.text = @"";
            productAnsTextField.placeholder = @"Type your address with postal code";
        }
        
    } else if (indexPath.section == 2) {
        
        if ([self isNotNull:[buyerDetailsDict objectForKey:@"emailId"]]) {
            productAnsTextField.text = [buyerDetailsDict objectForKey:@"emailId"];
        } else {
            productAnsTextField.text = @"";
            productAnsTextField.placeholder = @"Type your email address";
        }
        
    } else if (indexPath.section == 3) {
        if ([self isNotNull:[buyerDetailsDict objectForKey:@"mobileNumber"]]) {
            productAnsTextField.text = [buyerDetailsDict objectForKey:@"mobileNumber"];
        } else {
            productAnsTextField.text = @"";
            productAnsTextField.placeholder = @"Type your mobile number";
        }
         productAnsTextField.keyboardType = UIKeyboardTypeNumberPad;
    } else if (indexPath.section == 4) {
        if ([self isNotNull:[buyerDetailsDict objectForKey:@"message"]]) {
            productAnsTextField.text = [buyerDetailsDict objectForKey:@"message"];
        } else {
            productAnsTextField.text = @"";
            productAnsTextField.placeholder = @"Type any specific message to seller";
        }
        productAnsTextField.returnKeyType = UIReturnKeyDone;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    TCEND
}

#pragma mark TextField Delegate Methods
- (BOOL)textFieldShouldBeginEditing:(ProductDetailTextField *)textField {
    buyerDetailsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 200)];
    [buyerDetailsTableView scrollToRowAtIndexPath:textField.indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return YES;
}

- (BOOL)textField:(ProductDetailTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
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
    
    if (textField.indexPath.section == 0) {
        [buyerDetailsDict setObject:textString?:@"" forKey:@"name"];
    }
    if (textField.indexPath.section == 1) {
        [buyerDetailsDict setObject:textString?:@"" forKey:@"address"];
    }
    if (textField.indexPath.section == 2) {
        [buyerDetailsDict setObject:textString?:@"" forKey:@"emailId"];
    }
    if (textField.indexPath.section == 3) {
        [buyerDetailsDict setObject:textString?:@"" forKey:@"mobileNumber"];
    }
    if (textField.indexPath.section == 4) {
        [buyerDetailsDict setObject:textString?:@"" forKey:@"message"];
    }
    return YES;
    TCEND
}

- (BOOL)textFieldShouldReturn:(ProductDetailTextField *)textField {
    
    @try {
        if (textField.indexPath.section < 3) {
            UITableViewCell *cell = (UITableViewCell *)[buyerDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:(textField.indexPath.section + 1)]];
            ProductDetailTextField *productAnsTextField = (ProductDetailTextField *)[cell viewWithTag:2];
            [productAnsTextField becomeFirstResponder];
        } else {
            [textField resignFirstResponder];
            buyerDetailsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

//#pragma mark TextView Delegate methods
//#pragma mark TextView Delegate
//- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
//    if (!isViewMoveup)
//        [self setViewMovedUp:YES];
//    return YES;
//}
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    TCSTART
//    if ([text isEqualToString:@"\n"]) {
//        [textView resignFirstResponder];
//        return NO;
//    }
//    return YES;
//    TCEND
//}
//
//- (void)textViewDidEndEditing:(UITextView *)textView {
//    TCSTART
//    [mobileNumberField becomeFirstResponder];
//    TCEND
//}
#pragma mark Table ScrollView Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    TCSTART
    UITableViewCell *cell = (UITableViewCell *)[buyerDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    ProductDetailTextField *productAnsTextField = (ProductDetailTextField *)[cell viewWithTag:2];
    [productAnsTextField resignFirstResponder];
     buyerDetailsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    TCEND
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
