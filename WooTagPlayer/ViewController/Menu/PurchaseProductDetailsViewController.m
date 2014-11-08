/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "PurchaseProductDetailsViewController.h"

@interface PurchaseProductDetailsViewController ()

@end

@implementation PurchaseProductDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withProductInfo:(NSDictionary *)productInfo
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        productName = [productInfo objectForKey:@"productName"];
        productId = [productInfo objectForKey:@"id"];
    }
    return self;
}

- (void)viewDidLoad
{
    TCSTART
    [super viewDidLoad];
    productNameLbl.text = productName;
    self.view.backgroundColor = [appDelegate colorWithHexString:@"f5f5f5"];
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height - 20);
    buyersListArray = [[NSMutableArray alloc] init];
    if (CURRENT_DEVICE_VERSION < 7.0) {
        buyersListTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        buyersListTableView.backgroundView = nil;
    } else {
        buyersListTableView.frame = CGRectMake(buyersListTableView.frame.origin.x, buyersListTableView.frame.origin.y, buyersListTableView.frame.size.width, buyersListTableView.frame.size.height-20);
    }
    buyersListTableView.backgroundColor = [UIColor clearColor];
    buyersListTableView.separatorColor = [UIColor lightGrayColor];
    buyersListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self makeRequestForPurchaseRequestsOfProductWithProductId];
    TCEND
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)makeRequestForPurchaseRequestsOfProductWithProductId {
    TCSTART
    if ([self isNotNull:appDelegate.loggedInUser.userId] && [self isNotNull:productId]) {
        [appDelegate getPurchaseRequestsOfProductWithProductId:productId andCaller:self];
        [appDelegate showActivityIndicatorInView:buyersListTableView andText:@"Loading"];
        [appDelegate showNetworkIndicator];
    }
    TCEND
}
- (void)didFinishedToPurchaseRequestForProduct:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:buyersListTableView];
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"products"]] && [[results objectForKey:@"products"] isKindOfClass:[NSArray class]]) {
        buyersListArray = [results objectForKey:@"products"];
    }
    if (buyersListArray.count <= 0) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, buyersListTableView.frame.size.width, 40)];
        headerView.backgroundColor = [UIColor clearColor];
        UILabel *headerLabl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, 40)];
        headerLabl.textAlignment = UITextAlignmentCenter;
        headerLabl.font = [UIFont fontWithName:titleFontName size:14];
        headerLabl.textColor = [UIColor blackColor];
        headerLabl.numberOfLines = 0;
        headerLabl.backgroundColor = [UIColor clearColor];
        headerLabl.tag = 1;
        headerLabl.text = @"No purchase requests recieved";
        [headerView addSubview:headerLabl];
        buyersListTableView.tableHeaderView = headerView;
    }
    [buyersListTableView reloadData];
    TCEND
}
- (void)didFailToGetPurchaseRequestForProductWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:buyersListTableView];
    [ShowAlert showAlert:[errorDict objectForKey:@"msg"]];
    TCEND
}

- (IBAction)onClickOfBackButton:(id)sender {
    TCSTART
    [self.navigationController popViewControllerAnimated:YES];
    TCEND
}

#pragma mark Tableview delegate and Data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return buyersListArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightOfRow:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)heightOfRow:(NSIndexPath *)indexPath {
    TCSTART
    NSDictionary *buyerDict = [buyersListArray objectAtIndex:indexPath.section];
    NSString *rowStr;
    if (indexPath.row == 0 && [self isNotNull:[buyerDict objectForKey:@"buyername"]]) {
        rowStr = [buyerDict objectForKey:@"buyername"];
    } else if (indexPath.row == 1 && [self isNotNull:[buyerDict objectForKey:@"buyeremail"]]) {
        rowStr = [buyerDict objectForKey:@"buyeremail"];
    } else if (indexPath.row == 2 && [self isNotNull:[buyerDict objectForKey:@"buyermobilenumber"]]) {
        rowStr = [buyerDict objectForKey:@"buyermobilenumber"];
    } else if (indexPath.row == 3 && [self isNotNull:[buyerDict objectForKey:@"buyeraddress"]]) {
        rowStr = [buyerDict objectForKey:@"buyeraddress"];
    } else if (indexPath.row == 4 && [self isNotNull:[buyerDict objectForKey:@"buyermessage"]]) {
        rowStr = [buyerDict objectForKey:@"buyermessage"];
    } else if (indexPath.row == 5) {
        return 40;
    }
    if ([self isNotNull:rowStr]) {
        CGSize descptnSize = [rowStr sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:14] constrainedToSize:CGSizeMake(180, 2222) lineBreakMode:UILineBreakModeWordWrap];
        if (descptnSize.height > 40) {
            return descptnSize.height + 5;
        } else {
            return 40;
        }
    } else {
        return 0;
    }
    TCEND
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TCSTART
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    headerView.backgroundColor = [UIColor clearColor];
    
    return headerView;
    TCEND
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    static NSString *cellIdentifier = @"cellId";
    
    UILabel *topLineLbl;
    UILabel *bottomLineLbl;
    UILabel *leftLabel;
    UILabel *rightLabel;
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    CGFloat rowHeight = [self heightOfRow:indexPath];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        
        leftLabel = [[UILabel alloc] init];
        leftLabel.textAlignment = UITextAlignmentRight;
        leftLabel.font = [UIFont fontWithName:titleFontName size:14];
        leftLabel.textColor = [UIColor blackColor];
        leftLabel.tag = 1;
        leftLabel.numberOfLines = 0;
        leftLabel.backgroundColor = [UIColor clearColor];
        [cell addSubview:leftLabel];
        
        rightLabel = [[UILabel alloc] init];
        rightLabel.textAlignment = UITextAlignmentLeft;
        rightLabel.font = [UIFont fontWithName:descriptionTextFontName size:14];
        rightLabel.textColor = [UIColor blackColor];
        rightLabel.tag = 2;
        rightLabel.numberOfLines = 0;
        rightLabel.backgroundColor = [UIColor clearColor];
        [cell addSubview:rightLabel];
        
        topLineLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, cell.frame.size.width, 0.5)];
        topLineLbl.backgroundColor = [UIColor lightGrayColor];
        topLineLbl.tag = 3;
        [cell addSubview:topLineLbl];
        
        bottomLineLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 39.5, cell.frame.size.width, 0.5)];
        bottomLineLbl.backgroundColor = [UIColor lightGrayColor];
        bottomLineLbl.tag = 4;
        [cell addSubview:bottomLineLbl];
    }
    
    if (!leftLabel) {
        leftLabel = (UILabel *)[cell viewWithTag:1];
    }
    if (!rightLabel) {
        rightLabel = (UILabel *)[cell viewWithTag:2];
    }
    if (!topLineLbl) {
        topLineLbl = (UILabel *)[cell viewWithTag:3];
    }
    if (!bottomLineLbl) {
        bottomLineLbl = (UILabel *)[cell viewWithTag:4];
    }
    
    leftLabel.frame = CGRectMake(5, 0, 125, rowHeight);
    rightLabel.frame = CGRectMake(135, 0, 180, rowHeight);
    bottomLineLbl.frame = CGRectMake(0, rowHeight - 0.5, bottomLineLbl.frame.size.width, bottomLineLbl.frame.size.height);
    rightLabel.textColor = [UIColor blackColor];
    
    NSDictionary *buyerDict = [buyersListArray objectAtIndex:indexPath.section];
    if (indexPath.row == 0) {
        if ([self isNotNull:[buyerDict objectForKey:@"buyername"]]) {
            rightLabel.text = [buyerDict objectForKey:@"buyername"];
        } else {
            rightLabel.text = @"";
        }
        leftLabel.text = @"Name :";
    } else if (indexPath.row == 1) {
        if ([self isNotNull:[buyerDict objectForKey:@"buyeremail"]]) {
            rightLabel.textColor = [appDelegate colorWithHexString:@"007aff"];
            rightLabel.text = [buyerDict objectForKey:@"buyeremail"];
        } else {
            rightLabel.text = @"";
        }
        
        leftLabel.text = @"Mail ID :";
        
    } else if (indexPath.row == 2) {
        if ([self isNotNull:[buyerDict objectForKey:@"buyermobilenumber"]]) {
            rightLabel.textColor = [appDelegate colorWithHexString:@"007aff"];
            rightLabel.text = [buyerDict objectForKey:@"buyermobilenumber"];
        } else {
            rightLabel.text = @"";
        }
        
        leftLabel.text = @"Mobile Number :";
    } else if (indexPath.row == 3) {
        if ([self isNotNull:[buyerDict objectForKey:@"buyeraddress"]]) {
            rightLabel.text = [buyerDict objectForKey:@"buyeraddress"];
        } else {
            rightLabel.text = @"";
        }
        
        leftLabel.text = @"Address :";
    } else if (indexPath.row == 4) {
        if ([self isNotNull:[buyerDict objectForKey:@"buyermessage"]]) {
            rightLabel.text = [buyerDict objectForKey:@"buyermessage"];
        } else {
            rightLabel.text = @"";
        }
        
        leftLabel.text = @"Message :";
    } else if (indexPath.row == 5) {
        leftLabel.text = @"Requested Time :";
        if ([self isNotNull:[buyerDict objectForKey:@"requesttime"]]) {
            rightLabel.text = [appDelegate relativeDateString:[buyerDict objectForKey:@"requesttime"]];
        } else {
            rightLabel.text = @"";
        }
    }
    
    bottomLineLbl.hidden = YES;
    
    if (CURRENT_DEVICE_VERSION < 7.0) {
        topLineLbl.hidden = NO;
        if (indexPath.row == 3)
            bottomLineLbl.hidden = NO;
        cell.backgroundView = nil;
        cell.backgroundColor = [UIColor whiteColor];
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
    NSDictionary *buyerDict = [buyersListArray objectAtIndex:indexPath.section];
    if (indexPath.row == 1 && [self isNotNull:[buyerDict objectForKey:@"buyeremail"]]) {
        [self contactWithMail:[buyerDict objectForKey:@"buyeremail"]];
    } else if (indexPath.row == 2 && [self isNotNull:[buyerDict objectForKey:@"buyermobilenumber"]]) {
        [self phoneNumberTouchedWithText:[buyerDict objectForKey:@"buyermobilenumber"]];
    }
    TCEND
}

#pragma mark Phone number
- (void)phoneNumberTouchedWithText:(NSString *)text {
    TCSTART
    if ([self isNotNull:text]) {
        UIAlertView *phoneCallAlertView = [[UIAlertView alloc]initWithTitle:text message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Call", nil];
        [phoneCallAlertView show];
    }
    TCEND
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle caseInsensitiveCompare:@"Call"] == NSOrderedSame) {
        [appDelegate openPhoneApp:alertView.title];
    }
}

- (void)contactWithMail:(NSString *)mailId {
    TCSTART
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setToRecipients:[NSArray arrayWithObjects:mailId, nil]];
            [self presentViewController:controller animated:YES completion:nil];
            
        } else {
            [ShowAlert showError:@"OOPS We could not find your mail account, please set it up"];
        }
    TCEND
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
@end
