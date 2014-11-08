/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "MenuViewController.h"
#import "SWRevealViewController.h"
#import "MainViewController.h"
#import "MainViewController.h"
#import "FriendFinderViewController.h"
#import "MenuCell.h"
#import "PendingVideosViewController.h"
#import "SettingsViewController.h"
#import "FeedbackViewController.h"
#import "PurchasedProductNamesViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    TCSTART
    [super viewDidLoad];
//    self.view.backgroundColor = [appDelegate colorWithHexString:@"fafafa"];
    footerView.backgroundColor = [UIColor clearColor];
    logoutBtn.layer.cornerRadius = 5.0f;
    logoutBtn.layer.masksToBounds = YES;
    
    [menuTableView registerNib:[UINib nibWithNibName:@"MenuCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MenuCellID"];
    
    rowsArray = [[NSArray alloc] initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"Menuhome",@"imagename",@"Home",@"title", nil],[NSDictionary dictionaryWithObjectsAndKeys:appDelegate.loggedInUser.photoPath?:@"",@"imagename",appDelegate.loggedInUser.userName?:@"",@"title", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"PurchaseRequests",@"imagename",@"Purchase Requests",@"title", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"FriendFinder",@"imagename",@"Find Friends",@"title", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"MenuAccountSettings",@"imagename",@"Settings",@"title", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"feedback",@"imagename",@"Feedback",@"title", nil], nil];
   
    menuTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    menuTableView.separatorColor = [appDelegate colorWithHexString:@"11a3e7"];
    menuTableView.backgroundColor = [UIColor clearColor];
    
    dividerLbl1.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
    dividerLbl2.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
    dividerLbl3.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
    if ([menuTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [menuTableView setSeparatorInset:UIEdgeInsetsZero];
    }

    
    TCEND
    
}

- (void)viewWillAppear:(BOOL)animated {
    TCSTART
    [self.revealViewController setFrontViewPosition:FrontViewPositionRight animated:NO];
    NSArray *array = [appDelegate.managedObjectContext fetchObjectsForEntityName:@"Video" withPredicate:[NSPredicate predicateWithFormat:@"waitingToUpload == %d && userId == %@",TRUE,appDelegate.loggedInUser.userId]];
    if (array.count > 0) {
        footerView.frame = CGRectMake(0, 0, footerView.frame.size.width, 140);
        notificationView.hidden = NO;
        pendingVideosLbl.text = [NSString stringWithFormat:@"%d Pending Videos",array.count];
    } else {
        footerView.frame = CGRectMake(0, 0, footerView.frame.size.width, 48);
        notificationView.hidden = YES;
    }
    menuTableView.tableFooterView = footerView;
    [menuTableView reloadData];
    TCEND
}

- (void) viewDidLayoutSubviews {
    if (CURRENT_DEVICE_VERSION >= 7.0  && self.view.frame.size.height == appDelegate.window.frame.size.height) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.origin.y = -topBarOffset;
        self.view.bounds = viewBounds;
        
       
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (IBAction)onClickOfPendingVideosBtn {
    TCSTART
    [self.revealViewController setFrontViewPosition:FrontViewPositionRightMost animated:NO];
    if ([self isNull:appDelegate.pendingVideosVC]) {
         appDelegate.pendingVideosVC = [[PendingVideosViewController alloc] initWithNibName:@"PendingVideosViewController" bundle:nil];
    }
    [self.navigationController pushViewController:appDelegate.pendingVideosVC animated:NO];
    
    TCEND
}

#pragma mark Tableview Delegate and Datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TCSTART
    return [[UIView alloc] initWithFrame:CGRectZero];
    
    TCEND
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    TCSTART
    return 6;
    TCEND
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCSTART
    static NSString * cellIdentifier = @"MenuCellID";
    
    MenuCell *cell = (MenuCell *)[tableView_ dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[MenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSDictionary *dict = [rowsArray objectAtIndex:indexPath.row];
    if (indexPath.row != 1) {
        cell.thumbnailImg.image = [UIImage imageNamed:[dict objectForKey:@"imagename"]];
        cell.titleLbl.text = [dict objectForKey:@"title"];
    } else {
        [cell.thumbnailImg setImageWithURL:[NSURL URLWithString:appDelegate.loggedInUser.photoPath] placeholderImage:[UIImage imageNamed:@"OwnerPic"]];
        cell.titleLbl.text = appDelegate.loggedInUser.userName;

        cell.thumbnailImg.layer.cornerRadius = 15.0f;
        cell.thumbnailImg.layer.borderWidth = 1.5f;
        cell.thumbnailImg.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
        cell.thumbnailImg.layer.masksToBounds = YES;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    TCEND
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    SWRevealViewController *revealController = self.revealViewController;
    
    // We know the frontViewController is a NavigationController
    UINavigationController *frontNavigationController = (id)revealController.frontViewController;
    if (indexPath.row == 0) {
        // Grab a handle to the reveal controller, as if you'd do with a navigtion controller via self.navigationController.
          // <-- we know it is a NavigationController
        if ([frontNavigationController.topViewController isKindOfClass:[MainViewController class]]) {
            MainViewController *mainVC = (MainViewController *)frontNavigationController.topViewController;
            [revealController revealToggle:self];
            [mainVC disPlayVideoFeed:nil];
        }
    } else if (indexPath.row == 1) {
        if ([frontNavigationController.topViewController isKindOfClass:[MainViewController class]]) {
            MainViewController *mainVC = (MainViewController *)frontNavigationController.topViewController;
            [revealController revealToggle:self];
            [mainVC displayMyPage:nil];
        }
    } else if (indexPath.row == 2) {
        [self.revealViewController setFrontViewPosition:FrontViewPositionRightMost animated:NO];
        PurchasedProductNamesViewController *purchasedProductNamesVC = [[PurchasedProductNamesViewController alloc] initWithNibName:@"PurchasedProductNamesViewController" bundle:Nil];
        [self.navigationController pushViewController:purchasedProductNamesVC animated:YES];
    } else if (indexPath.row == 3) {
        [self.revealViewController setFrontViewPosition:FrontViewPositionRightMost animated:NO];
        FriendFinderViewController *friendFinderViewController = [[FriendFinderViewController alloc] initWithNibName:@"FriendFinderViewController" bundle:Nil];
        [self.navigationController pushViewController:friendFinderViewController animated:YES];
    } else if (indexPath.row == 4) {
        [self.revealViewController setFrontViewPosition:FrontViewPositionRightMost animated:NO];
        
        SettingsViewController *settingsVC = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
        
        [self.navigationController pushViewController:settingsVC animated:YES];
        
        MainViewController *mainVC = (MainViewController *)frontNavigationController.topViewController;
        settingsVC.mainVC = mainVC;
    } else if (indexPath.row == 5){
        [self.revealViewController setFrontViewPosition:FrontViewPositionRightMost animated:NO];
        FeedbackViewController *feedbackVC = [[FeedbackViewController alloc] initWithNibName:@"FeedbackViewController" bundle:nil];
        [self.navigationController pushViewController:feedbackVC animated:YES];
    }
    TCEND
}

- (IBAction)logoutFromApp:(id)sender {
    [appDelegate logoutRequestFromApp];
}

- (void)onClickOfSettingsBtn {
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//For iOS 6
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        return YES;
    } else {
        return NO;
    }
}

@end
