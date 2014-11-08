/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "ReportVideoViewController.h"

@interface ReportVideoViewController ()

@end

@implementation ReportVideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forVideo:(NSString *)videoId
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        reportVideoId = videoId;
    }
    return self;
}

- (void)viewDidLoad
{
    TCSTART
    [super viewDidLoad];
   
    reportTypesArray = [[NSArray alloc] initWithObjects:@"I don't like this video",@"This video is spam or a scam",@"This video puts people at risk",@"This video shouldn't be on Wootag", nil];
    
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height - 20);
    reportVideoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 42, self.view.frame.size.width, self.view.frame.size.height - 42) style:UITableViewStyleGrouped];
    if (CURRENT_DEVICE_VERSION < 7.0) {
        reportVideoTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        reportVideoTableView.backgroundView = nil;
    }
    reportVideoTableView.backgroundColor = [UIColor clearColor];
    reportVideoTableView.separatorColor = [UIColor lightGrayColor];
    reportVideoTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    reportVideoTableView.delegate = self;
    reportVideoTableView.dataSource = self;
    [self.view addSubview:reportVideoTableView];
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

- (IBAction)reportVideoDone {
    TCSTART
    [self dismissViewControllerAnimated:YES completion:nil];
    TCEND
}
#pragma mark Tableview delegate and Data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return reportTypesArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return [self heightOfHeader];
    
}
- (CGFloat)heightOfHeader {
    return (CURRENT_DEVICE_VERSION < 7.0)?60:45;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TCSTART
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, [self heightOfHeader])];
    headerView.backgroundColor = [UIColor clearColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, (CURRENT_DEVICE_VERSION < 7.0)?15:0, 300, 20)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont fontWithName:titleFontName size:15];
    titleLabel.textColor = [UIColor blackColor];
    [headerView addSubview:titleLabel];
    
    UILabel *descrptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, (CURRENT_DEVICE_VERSION < 7.0)?35:25, 300, 20)];
    descrptionLabel.backgroundColor = [UIColor clearColor];
    descrptionLabel.font = [UIFont fontWithName:descriptionTextFontName size:13];
    descrptionLabel.textColor = [UIColor grayColor];
    [headerView addSubview:descrptionLabel];
    if (sentReport) {
        titleLabel.text = @"Thank you";
        descrptionLabel.text = @"We have received your report";
    } else {
        titleLabel.text = @"REPORT VIDEO";
        descrptionLabel.text = @"Why are you reporting this video?";
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
    cell.textLabel.text = [reportTypesArray objectAtIndex:indexPath.row];
    bottomLineLbl.hidden = YES;
    
    if (CURRENT_DEVICE_VERSION < 7.0) {
        topLineLbl.hidden = NO;
        if (indexPath.row == reportTypesArray.count - 1) {
            bottomLineLbl.hidden = NO;
        }
        cell.backgroundView = nil;
    } else {
        topLineLbl.hidden = YES;
        bottomLineLbl.hidden = YES;
    }
//    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory"]];
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
    [appDelegate makeRequestForReportVideoWithVideoId:reportVideoId andCaller:self andReason:[reportTypesArray objectAtIndex:indexPath.row]];
    TCEND
}

- (void)didFinishedReportVideo:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    sentReport = YES;
    reportTypesArray = nil;
    [reportVideoTableView reloadData];
    TCEND
}
- (void)didFailedReportVideoWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    TCEND
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
