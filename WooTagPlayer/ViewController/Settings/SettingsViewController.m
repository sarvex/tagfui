/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "SettingsViewController.h"
#import "AccountSettingsviewController.h"
#import "WebViewController.h"
#import "FeedbackViewController.h"
#import "ShareSettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize mainVC;

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
//    ,@"Videos I am Tagged"
    NSArray *firstSectionArray = [[NSArray alloc] initWithObjects:@"Edit My Profile", nil];
    NSArray *secondSectionArray = [[NSArray alloc] initWithObjects:@"Privacy Policy",@"Terms of Service",@"WooTag Help Center", nil];
    NSArray *thirdSectionArray = [[NSArray alloc] initWithObjects:@"Share Settings",@"Push Notification Settings", nil];
    sectionsArray = [[NSArray alloc] initWithObjects:firstSectionArray,secondSectionArray,thirdSectionArray, nil];
    
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height - 20);
    settingsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 42, self.view.frame.size.width, self.view.frame.size.height - 42) style:UITableViewStyleGrouped];
    if (CURRENT_DEVICE_VERSION < 7.0) {
        settingsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        settingsTableView.backgroundView = nil;
    } 
    settingsTableView.backgroundColor = [UIColor clearColor];
    settingsTableView.separatorColor = [UIColor lightGrayColor];
    settingsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    settingsTableView.delegate = self;
    settingsTableView.dataSource = self;
    [self.view addSubview:settingsTableView];
    self.view.backgroundColor = [appDelegate colorWithHexString:@"f5f5f5"];
    
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

- (IBAction)onClickOfBackBtn:(id)sender {
    TCSTART
    [self.navigationController popViewControllerAnimated:NO];
    TCEND
}

#pragma mark Tableview delegate and Data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sectionsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[sectionsArray objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self heightOfHeaderAtSection:section];
}

- (CGFloat)heightOfHeaderAtSection:(int)section {
    if (section == 0 && CURRENT_DEVICE_VERSION < 7.0) {
        return 35;
    } else if (section == 1 || section == 2){
        return ((CURRENT_DEVICE_VERSION < 7.0)?50:40);
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TCSTART
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, [self heightOfHeaderAtSection:section])];
    headerView.backgroundColor = [UIColor clearColor];
    if (section != 0) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, (headerView.frame.size.height - 24), 300, 20)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont fontWithName:descriptionTextFontName size:14];
        if (section == 1) {
            titleLabel.text = @"SUPPORT";
        } else {
            titleLabel.text = @"PREFERENCES";
        }
        titleLabel.textColor = [UIColor grayColor];
        [headerView addSubview:titleLabel];
    }
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
        cell.textLabel.tag = 1;
        
        [cell addSubview:cell.textLabel];
        
        topLineLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, cell.frame.size.width, 0.5)];
        topLineLbl.backgroundColor = [UIColor lightGrayColor];
        [cell addSubview:topLineLbl];
        
        bottomLineLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 39.5, cell.frame.size.width, 0.5)];
        bottomLineLbl.backgroundColor = [UIColor lightGrayColor];
        [cell addSubview:bottomLineLbl];
    }
    
//    if ([self isNull:leftLabel]) {
//        leftLabel = (UILabel *)[cell viewWithTag:1];
//    }
    cell.textLabel.text = [[sectionsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    bottomLineLbl.hidden = YES;
    
    if (CURRENT_DEVICE_VERSION < 7.0) {
        topLineLbl.hidden = NO;
        if ((indexPath.section == 0 && indexPath.row == 1) || (indexPath.section == 1 && indexPath.row == 3) || (indexPath.section == 2 && indexPath.row == 1)) {
            bottomLineLbl.hidden = NO;
        }
        cell.backgroundView = nil;
    } else {
        topLineLbl.hidden = YES;
        bottomLineLbl.hidden = YES;
    }
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory"]];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:appDelegate.loggedInUser];
            AccountSettingsviewController *accountSettingsVC = [[AccountSettingsviewController alloc] initWithNibName:@"AccountSettingsviewController" bundle:nil];
            accountSettingsVC.userDataModal = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [self.navigationController pushViewController:accountSettingsVC animated:YES];
            accountSettingsVC.mainVC = mainVC;
        } else if (indexPath.row == 1) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *path = [paths objectAtIndex:0];
            
            path = [path stringByAppendingPathComponent:@"DeveloperLog.txt"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                if ([MFMailComposeViewController canSendMail]) {
                    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
                    controller.mailComposeDelegate = self;
                    [controller setSubject:@"DeveloperLog"];
                    [controller setToRecipients:[NSArray arrayWithObjects:@"aruna.y@spoors.in", nil]];
                
                    NSData *developerLogData = [[NSData alloc]initWithContentsOfFile:path];
                    [controller addAttachmentData:developerLogData mimeType:@"text/plain" fileName:@"DeveloperLog.txt"];
                    [self presentViewController:controller animated:YES completion:nil];
                    
                }
            }
        }
    } else if (indexPath.section == 1) {
        NSString *url;
        if (indexPath.row == 0) {
            url = @"http://www.wootag.com/user/privacy";
        } else if (indexPath.row == 1) {
            url = @"http://www.wootag.com/user/terms";
        } else {
            url = @"http://wootag.com/user/helpcenter";
        }
        WebViewController *webVC = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:Nil withWebUrl:url];
        [self.navigationController pushViewController:webVC animated:YES];

    } else if (indexPath.section == 2) {
        NSString *viewType;
        if (indexPath.row == 0) {
            viewType = @"Share Settings";
        } else if (indexPath.row == 1) {
            viewType = @"notifications";
        }
        ShareSettingsViewController *shareVC;
        shareVC = [[ShareSettingsViewController alloc] initWithNibName:@"ShareSettingsViewController" bundle:nil viewType:viewType];
        [self.navigationController pushViewController:shareVC animated:YES];
    }
    TCEND
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    TCSTART
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title caseInsensitiveCompare:@"Spam or Abuse"] == NSOrderedSame) {
        WebViewController *webVC = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:Nil withWebUrl:@"https://www.google.com"];
        [self.navigationController pushViewController:webVC animated:YES];
    } else if ([title caseInsensitiveCompare:@"Broken Feature"] == NSOrderedSame) {
        FeedbackViewController *feedbackVC = [[FeedbackViewController alloc] initWithNibName:@"FeedbackViewController" bundle:nil];
        [self.navigationController pushViewController:feedbackVC animated:YES];
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
                //                [ShowAlert showAlert:@"Mail sent"];
                //  NSLog(@"mail sent");
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
