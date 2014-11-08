/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "ProductInfoViewController.h"
#import "ProductDetailTextField.h"

@interface ProductInfoViewController ()

@end

@implementation ProductInfoViewController
@synthesize tagDetailsDict;
@synthesize tagToolVC;

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
    categoriesArray = [[NSArray alloc] initWithObjects:@"Fashion",@"Apparels",@"Sports",@"Electronics",@"Travel",@"Others", nil];
    currencyListArray = [[NSArray alloc] initWithObjects:@"IDR",@"INR",@"USD", nil];

    productDetailsTableView.backgroundColor = [UIColor clearColor];
    productDetailsTableView.separatorColor = [UIColor clearColor];
    productDetailsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (CURRENT_DEVICE_VERSION < 7.0) {
        productDetailsTableView.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    } else {
        if ([productDetailsTableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [productDetailsTableView setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    self.view.backgroundColor = [appDelegate colorWithHexString:@"eeeeee"];
    TCEND
}

- (void)viewWillAppear:(BOOL)animated {
    TCSTART
    if ([self isNull:[tagDetailsDict objectForKey:@"productCategory"]]) {
        [tagDetailsDict setObject:[categoriesArray objectAtIndex:0] forKey:@"productCategory"];
    }
    if ([self isNull:[tagDetailsDict objectForKey:@"productCurrencyType"]]) {
        [tagDetailsDict setObject:[currencyListArray objectAtIndex:0] forKey:@"productCurrencyType"];
    }
    TCEND
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
    [productDetailsTableView reloadData];
}

- (IBAction)onClickOfCancelBtn:(id)sender {
    [tagToolVC cancelWTVC];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onclickOfDoneBtn:(id)sender {
    [tagToolVC finishedPickingWTFriend:@"123"];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark Tableview delegate and Data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1 && categoryListExpanded) {
        return categoriesArray.count + 1;
    } else if (section == 2 && currencyListExpanded) {
        return currencyListArray.count + 1;
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 4) {
        return 50;
    }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 45;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, productDetailsTableView.frame.size.width, 45)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, productDetailsTableView.frame.size.width - 20, 30)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont fontWithName:titleFontName size:14];
    headerLabel.textAlignment = UITextAlignmentLeft;
    headerLabel.textColor = [UIColor blackColor];
    [headerView addSubview:headerLabel];
    headerView.backgroundColor = [UIColor clearColor];
    
    if (section == 0) {
        headerLabel.text = @"NAME";
    } else if (section == 1) {
        headerLabel.text = @"CATEGORY";
    } else if (section == 2) {
        headerLabel.text = @"CURRENCY TYPE";
    } else if (section == 3) {
        headerLabel.text = @"PRICE";
    } else {
        headerLabel.text = @"DESCRIPTION";
    }
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    static NSString *cellIdentifier = @"cellId";
    
    UILabel *categoryTypeLabl;
    ProductDetailTextField *productAnsTextField;
    UIImageView *collopseRExpandImg;
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        categoryTypeLabl = [[UILabel alloc] init];
        categoryTypeLabl.backgroundColor = [UIColor clearColor];
        categoryTypeLabl.font = [UIFont fontWithName:titleFontName size:14];
        categoryTypeLabl.tag = 1;
        categoryTypeLabl.textAlignment = UITextAlignmentLeft;
        categoryTypeLabl.textColor = [UIColor blackColor];
        [cell addSubview:categoryTypeLabl];
        
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
        
        collopseRExpandImg = [[UIImageView alloc] initWithFrame:CGRectMake(280, (40-15)/2, 15, 15)];
        collopseRExpandImg.tag = 4;
        [cell addSubview:collopseRExpandImg];
    }
    
    if ([self isNull:categoryTypeLabl]) {
        categoryTypeLabl = (UILabel *)[cell viewWithTag:1];
    }
    if ([self isNull:productAnsTextField]) {
        productAnsTextField = (ProductDetailTextField *)[cell viewWithTag:2];
    }
    
    if ([self isNull:collopseRExpandImg]) {
        collopseRExpandImg = (UIImageView *)[cell viewWithTag:4];
    }
    
    productAnsTextField.userInteractionEnabled = YES;
    productAnsTextField.hidden = NO;
    productAnsTextField.frame = CGRectMake(10, 0, cell.frame.size.width - 20, 40);
    categoryTypeLabl.hidden = YES;
    collopseRExpandImg.hidden = YES;
    productAnsTextField.indexPath = indexPath;
    productAnsTextField.placeholder = @"";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    productAnsTextField.keyboardType = UIKeyboardTypeDefault;
        
    if (indexPath.section == 0) {
        productAnsTextField.returnKeyType = UIReturnKeyDone;
        if ([self isNotNull:[tagDetailsDict objectForKey:@"productName"]]) {
             productAnsTextField.text = [tagDetailsDict objectForKey:@"productName"];
        } else {
            productAnsTextField.text = @"";
            productAnsTextField.placeholder = @"Type the name of your product";
        }
        [productAnsTextField setBackground:[UIImage imageNamed:@"TextEnterBox"]];
    } else if (indexPath.section == 1) {
        productAnsTextField.userInteractionEnabled = NO;
        if (indexPath.row == 0) {
            collopseRExpandImg.hidden = NO;
            if ([self isNotNull:[tagDetailsDict objectForKey:@"productCategory"]]) {
                productAnsTextField.text = [tagDetailsDict objectForKey:@"productCategory"];
            } else {
                productAnsTextField.text = @"";
                productAnsTextField.placeholder = @"Choose";
            }
            if (categoryListExpanded) {
                [collopseRExpandImg setImage:[UIImage imageNamed:@"Collapse"]];
            } else {
                [collopseRExpandImg setImage:[UIImage imageNamed:@"Expand"]];
            }
            [productAnsTextField setBackground:[UIImage imageNamed:@"DropDownBox"]];
        } else {
            categoryTypeLabl.text = [categoriesArray objectAtIndex:indexPath.row - 1];
            categoryTypeLabl.frame = CGRectMake(0, 0, cell.frame.size.width , 40);
            categoryTypeLabl.textAlignment = UITextAlignmentCenter;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            productAnsTextField.hidden = YES;
            categoryTypeLabl.hidden = NO;
        }
    
    } else if (indexPath.section == 2) {
        productAnsTextField.userInteractionEnabled = NO;
        if (indexPath.row == 0) {
            collopseRExpandImg.hidden = NO;
            if ([self isNotNull:[tagDetailsDict objectForKey:@"productCurrencyType"]]) {
                productAnsTextField.text = [tagDetailsDict objectForKey:@"productCurrencyType"];
            } else {
                productAnsTextField.text = @"";
                productAnsTextField.placeholder = @"Choose";
            }
            if (currencyListExpanded) {
                [collopseRExpandImg setImage:[UIImage imageNamed:@"Collapse"]];
            } else {
                [collopseRExpandImg setImage:[UIImage imageNamed:@"Expand"]];
            }
            [productAnsTextField setBackground:[UIImage imageNamed:@"DropDownBox"]];
        } else {
            categoryTypeLabl.text = [currencyListArray objectAtIndex:indexPath.row - 1];
            categoryTypeLabl.frame = CGRectMake(0, 0, cell.frame.size.width , 40);
            categoryTypeLabl.textAlignment = UITextAlignmentCenter;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            productAnsTextField.hidden = YES;
             categoryTypeLabl.hidden = NO;
        }
    } else if (indexPath.section == 3) {
        if ([self isNotNull:[tagDetailsDict objectForKey:@"productPrice"]]) {
            productAnsTextField.text = [tagDetailsDict objectForKey:@"productPrice"];
        } else {
            productAnsTextField.text = @"";
        }
        productAnsTextField.returnKeyType = UIReturnKeyNext;
        productAnsTextField.keyboardType = UIKeyboardTypeNumberPad;
        [productAnsTextField setBackground:[UIImage imageNamed:@"TextEnterBox"]];
    } else {
        if ([self isNotNull:[tagDetailsDict objectForKey:@"productDescription"]]) {
            productAnsTextField.text = [tagDetailsDict objectForKey:@"productDescription"];
        } else {
            productAnsTextField.text = @"";
        }
        productAnsTextField.returnKeyType = UIReturnKeyDone;
        [productAnsTextField setBackground:[UIImage imageNamed:@"TextEnterBox"]];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    return cell;
    TCEND
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = (UITableViewCell *)[productDetailsTableView cellForRowAtIndexPath:indexPath];
            UIImageView *collopseRExpandImg = (UIImageView *)[cell viewWithTag:4];
            if (collopseRExpandImg.image == [UIImage imageNamed:@"Collapse"]) {
                categoryListExpanded = NO;
            } else {
                categoryListExpanded = YES;
            }
        } else {
            [tagDetailsDict setObject:[categoriesArray objectAtIndex:indexPath.row - 1] forKey:@"productCategory"];
            categoryListExpanded = NO;
        }
       
        [productDetailsTableView reloadData];
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = (UITableViewCell *)[productDetailsTableView cellForRowAtIndexPath:indexPath];
            UIImageView *collopseRExpandImg = (UIImageView *)[cell viewWithTag:4];
            if (collopseRExpandImg.image == [UIImage imageNamed:@"Collapse"]) {
                currencyListExpanded = NO;
            } else {
                currencyListExpanded = YES;
            }
        } else {
            [tagDetailsDict setObject:[currencyListArray objectAtIndex:indexPath.row - 1] forKey:@"productCurrencyType"];
            currencyListExpanded = NO;
        }
        
        [productDetailsTableView reloadData];
    }
}

#pragma mark TextField Delegate Methods
- (BOOL)textFieldShouldBeginEditing:(ProductDetailTextField *)textField {
    productDetailsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 200)];
    [productDetailsTableView scrollToRowAtIndexPath:textField.indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
        [tagDetailsDict setObject:textString?:@"" forKey:@"productName"];
    }
    if (textField.indexPath.section == 3) {
        [tagDetailsDict setObject:textString?:@"" forKey:@"productPrice"];
    }
    if (textField.indexPath.section == 4) {
        [tagDetailsDict setObject:textString?:@"" forKey:@"productDescription"];
    }
    
    return YES;
    TCEND
}

- (BOOL)textFieldShouldReturn:(ProductDetailTextField *)textField {
    
    @try {
        if (textField.indexPath.section == 3) {
            UITableViewCell *cell = (UITableViewCell *)[productDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4]];
            ProductDetailTextField *productAnsTextField = (ProductDetailTextField *)[cell viewWithTag:2];
            [productAnsTextField becomeFirstResponder];
        } else {
            [textField resignFirstResponder];
            productDetailsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
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
//    productDetailsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 200)];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
//    [productDetailsTableView scrollToRowAtIndexPath:indexPath
//                             atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    return YES;
//}
//
//
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    TCSTART
//    if ([text isEqualToString:@"\n"]) {
//        [textView resignFirstResponder];
//        return NO;
//    }
//    [tagDetailsDict setObject:textView.text?:@"" forKey:@"productDescription"];
//    return YES;
//    TCEND
//}
//
//- (void)textViewDidEndEditing:(UITextView *)textView {
//    TCSTART
//    productDetailsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
//    [textView resignFirstResponder];
//    TCEND
//}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table ScrollView Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    TCSTART
    UITableViewCell *cell = (UITableViewCell *)[productDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    ProductDetailTextField *productAnsTextField = (ProductDetailTextField *)[cell viewWithTag:2];
    [productAnsTextField resignFirstResponder];
     productDetailsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
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
