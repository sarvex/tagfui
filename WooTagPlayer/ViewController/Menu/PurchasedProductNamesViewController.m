/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "PurchasedProductNamesViewController.h"
#import "PurchaseProductDetailsViewController.h"
@interface PurchasedProductNamesViewController ()

@end

@implementation PurchasedProductNamesViewController

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
    self.view.backgroundColor = [appDelegate colorWithHexString:@"f5f5f5"];
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height - 20);
    productListArray = [[NSMutableArray alloc] init];
    [self makeRequestForProductList];
    if (CURRENT_DEVICE_VERSION < 7.0) {
        productsListTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        productsListTableView.backgroundView = nil;
    } else {
        productsListTableView.frame = CGRectMake(productsListTableView.frame.origin.x, productsListTableView.frame.origin.y, productsListTableView.frame.size.width, productsListTableView.frame.size.height-20);
    }
    productsListTableView.backgroundColor = [UIColor clearColor];
    productsListTableView.separatorColor = [UIColor lightGrayColor];
    productsListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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


// Products Related
- (void)makeRequestForProductList {
    TCSTART
    if ([self isNotNull:appDelegate.loggedInUser.userId]) {
        [appDelegate getListOfProductsWithCaller:self];
        [appDelegate showActivityIndicatorInView:productsListTableView andText:@"Loading"];
        [appDelegate showNetworkIndicator];
    }
    TCEND
}
- (void)didFinishedToGetProductsList:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:productsListTableView];
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"products"]] && [[results objectForKey:@"products"] isKindOfClass:[NSArray class]]) {
        productListArray = [results objectForKey:@"products"];
    }
    if (productListArray.count <= 0) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, productsListTableView.frame.size.width, 40)];
        headerView.backgroundColor = [UIColor clearColor];
        UILabel *headerLabl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, 40)];
        headerLabl.textAlignment = UITextAlignmentCenter;
        headerLabl.font = [UIFont fontWithName:titleFontName size:14];
        headerLabl.textColor = [UIColor blackColor];
        headerLabl.numberOfLines = 0;
        headerLabl.backgroundColor = [UIColor clearColor];
        headerLabl.tag = 1;
        headerLabl.text = @"No products tagged for sale";
        [headerView addSubview:headerLabl];
        productsListTableView.tableHeaderView = headerView;
    }
    [productsListTableView reloadData];
    TCEND
}
- (void)didFailToGetProductsListWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:productsListTableView];
    [ShowAlert showAlert:[errorDict objectForKey:@"msg"]];
    TCEND
}

- (IBAction)onClickOfBackButton:(id)sender {
    TCSTART
    [self.navigationController popViewControllerAnimated:NO];
    TCEND
}

#pragma mark Tableview delegate and Data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return productListArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self heightOfHeaderAtSection:section];
}

- (CGFloat)heightOfHeaderAtSection:(int)section {
//    if (section == 0 && CURRENT_DEVICE_VERSION < 7.0) {
//        return 35;
//    } else if (section == 1 || section == 2){
//        return ((CURRENT_DEVICE_VERSION < 7.0)?50:40);
//    }
//    return 0;
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TCSTART
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, [self heightOfHeaderAtSection:section])];
    headerView.backgroundColor = [UIColor clearColor];
    
    return headerView;
    TCEND
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    static NSString *cellIdentifier = @"cellId";
    
    UILabel *topLineLbl;
    UILabel *bottomLineLbl;
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        //        leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 40)];
        cell.textLabel.textAlignment = UITextAlignmentLeft;
        cell.textLabel.font = [UIFont fontWithName:descriptionTextFontName size:17];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.tag = 1;
        
        [cell addSubview:cell.textLabel];
        
        topLineLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, cell.frame.size.width, 0.5)];
        topLineLbl.backgroundColor = [UIColor lightGrayColor];
        topLineLbl.tag = 2;
        [cell addSubview:topLineLbl];
        
        bottomLineLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 39.5, cell.frame.size.width, 0.5)];
        bottomLineLbl.backgroundColor = [UIColor lightGrayColor];
        bottomLineLbl.tag = 3;
        [cell addSubview:bottomLineLbl];
    }
    
    if (!topLineLbl) {
        topLineLbl = (UILabel *)[cell viewWithTag:2];
    }
    if (!bottomLineLbl) {
        bottomLineLbl = (UILabel *)[cell viewWithTag:3];
    }
    
    NSDictionary *productDict = [productListArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [productDict objectForKey:@"productName"];
    bottomLineLbl.hidden = YES;
    
    if (CURRENT_DEVICE_VERSION < 7.0) {
        topLineLbl.hidden = NO;
        if (indexPath.row == (productListArray.count - 1)) {
            bottomLineLbl.hidden = NO;
        }
//        cell.backgroundView = nil;
        cell.backgroundColor = [UIColor whiteColor];
    } else {
        topLineLbl.hidden = YES;
        bottomLineLbl.hidden = YES;
    }
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory"]];
    UIView *selectview = [[UIView alloc] init];
    selectview.backgroundColor = [appDelegate colorWithHexString:@"3bcaf1"];
    cell.selectedBackgroundView = selectview;
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
    PurchaseProductDetailsViewController *purchasedProductDetailsVC = [[PurchaseProductDetailsViewController alloc] initWithNibName:@"PurchaseProductDetailsViewController" bundle:Nil withProductInfo:[productListArray objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:purchasedProductDetailsVC animated:YES];
    TCEND
}

@end
