/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "NotificationsViewController.h"
#import "NotificationModal.h"
#import "OthersPageViewController.h"
#import "VideoDetailsPageViewController.h"
#import <CoreText/CoreText.h>

@interface NotificationsViewController ()

@end

@implementation NotificationsViewController
@synthesize mainVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andFrame:(CGRect)frame
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.view.frame = frame;
    
    }
    return self;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    TCSTART
    if ([self isNotNull:appDelegate.loggedInUser]) {
         NSLog(@"applicationDidEnterBackground notifications vc");
    }
    TCEND
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    TCSTART
    if ([self isNotNull:appDelegate.loggedInUser]) {
        NSLog(@"applicationWillEnterForeground notifications vc");
        [self refreshNotificationsScreen];
    }
    TCEND
}

- (void)viewDidLoad {
    TCSTART
    [super viewDidLoad];
    searchBt.hidden = YES;
    self.view.backgroundColor = [appDelegate colorWithHexString:@"f5f5f5"];;
    [self getNotificationsFromDB];
    notificationsSearchBar.hidden = YES;
    searchBarBg.hidden = YES;
    [self customizeSearchBar];
//    [notificationsTableView registerNib:[UINib nibWithNibName:@"NotificationsTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"NotificationsTableViewCellID"];
    notificationsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    notificationsTableView.separatorColor = [appDelegate colorWithHexString:@"11a3e7"];
    notificationsTableView.delegate = self;
    notificationsTableView.dataSource = self;
    if ([notificationsTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [notificationsTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    refreshView = [[RefreshView alloc] initWithFrame:
                   CGRectMake(notificationsTableView.frame.origin.x,- notificationsTableView.bounds.size.height,
                              notificationsTableView.frame.size.width, notificationsTableView.bounds.size.height)];
    [notificationsTableView addSubview:refreshView];
    notificationsTableView.backgroundColor = [UIColor clearColor];
    notificationsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//    [notificationsTableView setEditing:YES animated:YES];
    [self getUserNotificationsRequestForNotifications:NO];
    TCEND
}

- (void)getNotificationsFromDB {
    TCSTART
    [notificationsArray removeAllObjects];
    notificationsArray = nil;
    [[DataManager sharedDataManager] removeAllNotificationsWhichAreCreated7DaysAgo];
    notificationsArray = [[NSMutableArray alloc] initWithArray:[[DataManager sharedDataManager] getAllNotificationsByUserId:appDelegate.loggedInUser.userId]];
    TCEND
}
- (IBAction)editingTableView:(id)sender {
    if ([notificationsTableView isEditing]) {
        [notificationsTableView setEditing:NO animated:YES];
    } else {
        [notificationsTableView setEditing:YES animated:YES];
    }
}
- (void)hideOrUnhideNotificationsRedLabelOnTabbar:(BOOL)show {
    TCSTART
    if (show) {
        mainVC.notificationsIndicatorLbl.hidden = NO;
    } else {
        mainVC.notificationsIndicatorLbl.hidden = YES;
    }
    TCEND
}

//For status bar in ios7
- (void) viewDidLayoutSubviews {
    if (CURRENT_DEVICE_VERSION >= 7.0 && self.view.frame.size.height == appDelegate.window.frame.size.height) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.size.height = viewBounds.size.height - topBarOffset;
        self.view.frame = CGRectMake(viewBounds.origin.x, topBarOffset, viewBounds.size.width, viewBounds.size.height);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

#pragma mark Get user notifications
- (void)getUserNotificationsRequestForNotifications:(BOOL)refresh {
    TCSTART
    if ([self isNotNull:appDelegate.loggedInUser.userId]) {
        requestedForNotifications = NO;
        if (!refresh && notificationsArray.count <= 0) {
            [appDelegate showActivityIndicatorInView:notificationsTableView andText:@"Loading"];
        }
        [appDelegate showNetworkIndicator];
        [appDelegate getLoggedInUserNotificationsWithCaller:self];
    }
    TCEND
}
- (void)didFinishedToGetUserNotifications:(NSDictionary *)results {
    TCSTART
    requestedForNotifications = YES;
    mainVC.isNotificationsEnterBg = NO;
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:notificationsTableView];
    [self dataSourceDidFinishLoadingNewData];
    [notificationsArray removeAllObjects];
    [notificationsArray addObjectsFromArray:[[DataManager sharedDataManager] getAllNotificationsByUserId:appDelegate.loggedInUser.userId]];
//    if ([self isNotNull:[results objectForKey:@"newnotifications"]]) {
//        [self hideOrUnhideNotificationsRedLabelOnTabbar:[[results objectForKey:@"newnotifications"] boolValue]];
//    }
    mainVC.notificationsIndicatorLbl.hidden = YES;
    [notificationsTableView reloadData];
    TCEND
}

- (void)didFailToGetUserNotificationsWithError:(NSDictionary *)errorDict {
    TCSTART
    requestedForNotifications = NO;
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:notificationsTableView];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    [self dataSourceDidFinishLoadingNewData];
    TCEND
}
- (IBAction)onClickOfQuickLinksBtn:(id)sender {
    TCSTART
    if ([self isNotNull:mainVC] && [mainVC respondsToSelector:@selector(onClickOfMenuButton)]) {
        [mainVC onClickOfMenuButton];
    }
    TCEND
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableAttributedString *)formatTitleMessageText:(NotificationModal *)notification {
    TCSTART
    if ([self isNotNull:notification.messageText]) {
        NSMutableAttributedString *commentAttributedString = nil;
        
        NSMutableArray *boldRangesMutableArray = [[NSMutableArray alloc]init];
        NSMutableArray *italicRangesArray = [[NSMutableArray alloc] init];
        NSRange boldStrRange  = NSMakeRange(0, 0);
        NSRange italicStrRange = NSMakeRange(0, 0);
        NSRange blueColorRange;

        NSMutableString *rowString = [[NSMutableString alloc]init];
        NSString *commentText;
        if ([self isNotNull:notification.descriptionText]) {
           commentText = [NSString stringWithFormat:@"\n%@",notification.descriptionText?:@""];
        }
        
        [rowString appendString:notification.messageText];
        NSString *dateText = [NSString stringWithFormat:@"\n%@", ([self isNotNull:notification.createdTime])?[appDelegate relativeDateString:notification.createdTime]:@""];
        if ([self isNotNull:commentText]) {
            [rowString appendString:commentText];
        }
        [rowString appendString:dateText];
        
        if([self isNotNull:notification.otherUserId] && [notification.otherUserId intValue] == appDelegate.loggedInUser.userId.intValue) {
            boldStrRange = [rowString rangeOfString:@"You"];
        } else {
            boldStrRange = [rowString rangeOfString:notification.otherUserName];
        }
        italicStrRange = [rowString rangeOfString:dateText];
        blueColorRange = boldStrRange;

        if(boldStrRange.location != NSNotFound && boldStrRange.length > 0) {
            [boldRangesMutableArray addObject:[NSValue valueWithRange:boldStrRange]];
        }
        
        
        if (italicStrRange.location != NSNotFound && italicStrRange.length > 0) {
            [italicRangesArray addObject:[NSValue valueWithRange:italicStrRange]];
        }
        if([self isNotNull:rowString]) {
            return [appDelegate getAttributedStringForString:rowString withBoldRanges:boldRangesMutableArray WithBoldFontName:titleFontName withNormalFontName:descriptionTextFontName italicRangesArray:italicRangesArray];
        } else {
            return nil;
        }
        
        return commentAttributedString;
    } else {
        return nil;
    }
    
    TCEND
}

- (CGFloat)getHeightOfAttributedStringAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    NotificationModal *notification = [notificationsArray objectAtIndex:indexPath.row];
    CGFloat width;
    if ([notification.notificationType intValue] == AcceptPrivateGroup || [notification.notificationType intValue] == Follow) {
        width = 270;
    } else if ([notification.notificationType intValue] == UserTag || [notification.notificationType intValue] == Comment || [notification.notificationType intValue] == Like) {
        width = 215;
    } else {
        width = 200;
    }
    NSAttributedString *attrStr = [self formatTitleMessageText:notification];
    CGSize attrStrSize = [appDelegate getFrameSizeForAttributedString:attrStr withWidth:width];
    if ((attrStrSize.height + 10 + (([notification.notificationType intValue] == Comment)?10:0)) > 50) {
        if ([notification.notificationType intValue] == Comment && attrStr.length>= 150) {
            return attrStrSize.height + 10 + 15 * (floor(attrStr.length/150));
        } else {
            return attrStrSize.height + 10 + (([notification.notificationType intValue] == Comment)?10:0) ;
        }
    } else {
        return 50;
    }
//    if ((attrStrSize.height + 10 + (([notification.notificationType intValue] == Comment)?10:0)) > 50) {
//        if ([notification.notificationType intValue] == Comment && attrStrSize.height > 150) {
//            return attrStrSize.height + 10 + 40;
//        } else {
//            return attrStrSize.height + 10 + (([notification.notificationType intValue] == Comment)?10:0);
//        }
//        
//    } else {
//        return 50;
//    }
    
    TCEND
}
#pragma mark Tableview Delegate and Datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return notificationsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  [self getHeightOfAttributedStringAtIndexPath:indexPath] + 10;
//    return 200;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (notificationsArray.count == 0 && requestedForNotifications) {
        return 40;
    } else {
        return 1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
    if (notificationsArray.count == 0 && requestedForNotifications) {
        headerView.frame = CGRectMake(0, 0, notificationsTableView.frame.size.width, 40);
        headerView.backgroundColor = [UIColor clearColor];
        
        UILabel *notificationTextLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, notificationsTableView.frame.size.width, 40)];
        notificationTextLbl.numberOfLines = 0;
        notificationTextLbl.backgroundColor = [UIColor clearColor];
        notificationTextLbl.font = [UIFont fontWithName:descriptionTextFontName size:14];
        notificationTextLbl.textAlignment = UITextAlignmentCenter;
        notificationTextLbl.text = @"No new notifications!";
        [headerView addSubview:notificationTextLbl];
    }
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    static NSString *cellIdentifier = @"NotificationsTableViewCellID";
    UIImageView *profileImgView = nil;
    UIImageView *videoThumbImgView = nil;
    UIButton *addUserBtn = nil;
    UIButton *deleteUserBtn = nil;
    CATextLayer *textLayer = nil;   //used to draw the attributed string
    CALayer *layer = nil;           //used to draw the attributed string on textlayer and add that as a subview
    UIButton *usernameBtn;
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        profileImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 8, 35, 35)];
        profileImgView.tag = 1;
        [cell.contentView addSubview:profileImgView];
        
        videoThumbImgView = [[UIImageView alloc] initWithFrame:CGRectMake(265, 5, 50, 50)];
        videoThumbImgView.tag = 2;
        [cell.contentView addSubview:videoThumbImgView];
        
        addUserBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addUserBtn.frame = CGRectMake(250, 10, 30, 30);
        addUserBtn.tag = 3;
        [addUserBtn setBackgroundImage:[UIImage imageNamed:@"AddSuggestedUser"] forState:UIControlStateNormal];
        [addUserBtn addTarget:self action:@selector(acceptPrivateUserRequest: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:addUserBtn];
        
        deleteUserBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteUserBtn.frame = CGRectMake(285, 10, 30, 30);
        [deleteUserBtn setBackgroundImage:[UIImage imageNamed:@"UnfollowSuggestedUser"] forState:UIControlStateNormal];
        deleteUserBtn.tag = 4;
        [deleteUserBtn addTarget:self action:@selector(deletePrivateGroupUserRequest: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:deleteUserBtn];
        
        textLayer = [[CATextLayer alloc] init];
        textLayer.backgroundColor = [UIColor clearColor].CGColor;
        [textLayer setForegroundColor:[[UIColor blackColor] CGColor]];
        [textLayer setContentsScale:[[UIScreen mainScreen] scale]];
        textLayer.wrapped = YES;
        
        layer = cell.contentView.layer; //self is a view controller contained by a navigation controller
        [layer addSublayer:textLayer];

        usernameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        usernameBtn.tag = 5;
//        [usernameBtn setBackgroundColor:[UIColor redColor]];
        [usernameBtn addTarget:self action:@selector(onClickOfUserNameButton: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:usernameBtn];
    }
    
    if (!profileImgView) {
        profileImgView = (UIImageView *)[cell.contentView viewWithTag:1];
    }
    
    if (!videoThumbImgView) {
        videoThumbImgView = (UIImageView *)[cell.contentView viewWithTag:2];
    }
    
    if (!addUserBtn) {
        addUserBtn = (UIButton *)[cell.contentView viewWithTag:3];
    }
    
    if (!deleteUserBtn) {
        deleteUserBtn = (UIButton *)[cell.contentView viewWithTag:4];
    }
    
    if (!usernameBtn) {
        usernameBtn = (UIButton *)[cell.contentView viewWithTag:5];
    }
    
    NotificationModal *notification = [notificationsArray objectAtIndex:indexPath.row];
    addUserBtn.hidden = YES;
    deleteUserBtn.hidden = YES;
    videoThumbImgView.hidden = YES;
    usernameBtn.hidden = YES;
    
    [profileImgView setImageWithURL:[NSURL URLWithString:notification.otherUserProfileImgUrl] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached];
    profileImgView.layer.cornerRadius = 17.5;
    profileImgView.layer.borderWidth = 1.5f;
    profileImgView.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
    profileImgView.layer.masksToBounds = YES;
    if ([self isNotNull:notification.otherUserProfileImgUrl] && ([notification.notificationType intValue] == Follow || [notification.notificationType intValue] == PrivateGroup || [notification.notificationType intValue] == AcceptPrivateGroup)) {
        if ([notification.notificationType intValue] == PrivateGroup) {
            addUserBtn.hidden = NO;
            deleteUserBtn.hidden = NO;
        
        }
    } else {
        if ([self isNotNull:notification.otherUserId] && notification.otherUserId.intValue != appDelegate.loggedInUser.userId.intValue) {
            usernameBtn.hidden = NO;
            usernameBtn.frame = [self getFrameOfUserNameButton:notification];
        } else {
            usernameBtn.hidden = YES;
        }
        
        videoThumbImgView.hidden = NO;
        if ([self isNotNull:notification.videoImgUrl]) {
            [videoThumbImgView setImageWithURL:[NSURL URLWithString:notification.videoImgUrl] placeholderImage:[UIImage imageNamed:@"DefaultVideoThumb"]];
        }
    }
    
    if (!layer)
        layer = cell.contentView.layer;
    for (id subLayer in layer.sublayers) {
        if ([subLayer isKindOfClass:[CATextLayer class]]) {
//            NSLog(@"found textlayer");
            textLayer = subLayer;
        }
    }

    NSMutableAttributedString *mAttrbtdStr = [self formatTitleMessageText:notification];
    textLayer.string = mAttrbtdStr;
    CGFloat width;
    if ([notification.notificationType intValue] == AcceptPrivateGroup || [notification.notificationType intValue] == Follow) {
        width = 270;
    } else if ([notification.notificationType intValue] == UserTag || [notification.notificationType intValue] == Comment || [notification.notificationType intValue] == Like) {
        width = 215;
    } else {
        width = 200;
    }
    
    CGSize textHeight = [appDelegate getFrameSizeForAttributedString:mAttrbtdStr withWidth:width];
    CGFloat height;
    if (textHeight.height > 40) {
        if ([notification.notificationType intValue] == Comment && mAttrbtdStr.length>= 150) {
            height = textHeight.height + 10 +15 *(floor(mAttrbtdStr.length/150));
        } else {
            height = textHeight.height + 20 ;
        }
    } else {
        height = 55;
    }
    textLayer.frame = CGRectMake(45, 5, width, height);
//    NSMutableDictionary *newActions = [appDelegate getTextLayerTextAnimationStopProperties];
//    
//    textLayer.actions = newActions;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    TCEND
}

//- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"willBeginEditingRowAtIndexPath");
//}
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"canEditRowAtIndexPath");
//    return YES;
//}
//
//- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView
//           editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath {
//    @try {
//        NSLog(@"editingStyleForRowAtIndexPath");
//        return UITableViewCellEditingStyleDelete;
//    }
//    @catch (NSException *exception) {
//        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
//    }
//    @finally {
//    }
//}
//
//
//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return @"delete";
//}
//
//- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)style
//forRowAtIndexPath:(NSIndexPath*)indexPath {
//    @try {
//        if (style == UITableViewCellEditingStyleDelete) {
//            NotificationModal *notification = [notificationsArray objectAtIndex:indexPath.row];
//            [self removeNotificationFromTable:notification];
//        }
//    }
//    @catch (NSException *exception) {
//        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
//    }
//    @finally {
//    }
//}
//
//- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
////    [tableView reloadData];
//}
//
//- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
//    return NO;
//}

- (CGRect)getFrameOfUserNameButton:(NotificationModal *)notification {
    TCSTART
    CGSize size = [notification.otherUserName sizeWithFont:[UIFont fontWithName:titleFontName size:14] constrainedToSize:CGSizeMake(2222, 222) lineBreakMode:UILineBreakModeWordWrap];
    return CGRectMake(45, 5, size.width, size.height);
    TCEND
}
- (void)onClickOfUserNameButton:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:notificationsTableView];
    NotificationModal *notification = [notificationsArray objectAtIndex:indexPath.row];
    if ([self isNotNull:notification.otherUserId]) {
        [self hideNotificationsRedLabel];
        OthersPageViewController *otherPageVC = [[OthersPageViewController alloc] initWithNibName:@"OthersPageViewController" bundle:Nil andUser:notification.otherUserId];
        [self.navigationController pushViewController:otherPageVC animated:YES];
    }
    TCEND
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    NotificationModal *notification = [notificationsArray objectAtIndex:indexPath.row];
    if ([notification.notificationType intValue] == Follow || [notification.notificationType intValue] == PrivateGroup || [notification.notificationType intValue] == AcceptPrivateGroup) {
        [self hideNotificationsRedLabel];
        OthersPageViewController *otherPageVC = [[OthersPageViewController alloc] initWithNibName:@"OthersPageViewController" bundle:Nil andUser:notification.otherUserId];
        [self.navigationController pushViewController:otherPageVC animated:YES];
    } else {
        [self makeRequestForVideoDetailsWithVideoId:notification.videoId andIndexPath:indexPath notificationType:[notification.notificationType intValue]];
    }
    TCEND
}

#pragma mark Remove notification
- (void)removeNotificationFromTable:(NotificationModal *)notification {
    TCSTART
    [appDelegate removeLoggedInUserNotificationWithNotificationId:notification.notificationId andCaller:self];
    [notificationsArray removeObject:notification];
    [[DataManager sharedDataManager] deleteNotificationModal:notification];
    [notificationsTableView reloadData];
    mainVC.notificationsIndicatorLbl.hidden = YES;
    TCEND
}

- (void)hideNotificationsRedLabel {
    mainVC.notificationsIndicatorLbl.hidden = YES;
}
#pragma mark video details
- (void)makeRequestForVideoDetailsWithVideoId:(NSString *)videoId andIndexPath:(NSIndexPath *)indexPath notificationType:(NotificationType)type {
    TCSTART
    if ([self isNotNull:videoId] && [self isNotNull:indexPath]) {
        [appDelegate showActivityIndicatorInView:notificationsTableView andText:@""];
        [appDelegate showNetworkIndicator];
        [appDelegate getVideoDetailsOfVideoId:videoId notificationType:type  indexPath:indexPath andCaller:self];
    }
    TCEND
}
- (void)didFinishedToGetVideoDetails:(NSDictionary *)results {
    TCSTART
    [appDelegate removeNetworkIndicatorInView:notificationsTableView];
    [appDelegate hideNetworkIndicator];
    
    if ([self isNotNull:[results objectForKey:@"videos"]] && [[results objectForKey:@"videos"] count] > 0) {
        NSIndexPath *indexPath = [results objectForKey:@"indexpath"];
        NotificationModal *notification = [notificationsArray objectAtIndex:indexPath.row];
        VideoModal *selectVideo = [[results objectForKey:@"videos"] objectAtIndex:0];
        
        VideoDetailsPageViewController *videoDetailsPageVC = [[VideoDetailsPageViewController alloc] initWithNibName:@"VideoDetailsPageViewController" bundle:nil withVideoModal:selectVideo andNotificationType:[notification.notificationType intValue]];
        [self.navigationController pushViewController:videoDetailsPageVC animated:YES];
        
        [self hideNotificationsRedLabel];
    }
    TCEND
}

- (void)didFailToGetVideoDetailsWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate removeNetworkIndicatorInView:notificationsTableView];
    [appDelegate hideNetworkIndicator];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

#pragma mark Accept Private group request
- (void)acceptPrivateUserRequest:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:notificationsTableView];
    NotificationModal *notification = [notificationsArray objectAtIndex:indexPath.row];
    if ([self isNotNull:appDelegate.loggedInUser.userId] && [self isNotNull:notification.otherUserId]) {
        [appDelegate makeAcceptPrivateUserWithUserId:appDelegate.loggedInUser.userId privateUserId:notification.otherUserId andCaller:self andIndexPath:indexPath];
        [appDelegate showActivityIndicatorInView:notificationsTableView andText:@"Accepting"];
        [appDelegate showNetworkIndicator];
    }
    TCEND
}
- (void)didFinishedToAcceptPrivateUser:(NSDictionary *)results {
    TCSTART
    [appDelegate removeNetworkIndicatorInView:notificationsTableView];
    [appDelegate hideNetworkIndicator];
    NSIndexPath *indexPath = [results objectForKey:@"indexpath"];
    NotificationModal *notification = [notificationsArray objectAtIndex:indexPath.row];
    [self removeNotificationFromTable:notification];
    TCEND
}
- (void)didFailToAcceptPrivateUserWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate removeNetworkIndicatorInView:notificationsTableView];
    [appDelegate hideNetworkIndicator];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

#pragma mark Delete private group request
- (void)deletePrivateGroupUserRequest:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:notificationsTableView];
    NotificationModal *notification = [notificationsArray objectAtIndex:indexPath.row];
    [appDelegate makeUnPrivateUserWithUserId:appDelegate.loggedInUser.userId privateUserId:notification.otherUserId andCaller:self andIndexPath:indexPath];
    TCEND
}

- (void)didFinishedToUnPrivateUser:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    NSIndexPath *indexPath = [results objectForKey:@"indexpath"];
    NotificationModal *notification = [notificationsArray objectAtIndex:indexPath.row];
    [self removeNotificationFromTable:notification];
    TCEND
}

- (void)didFailToUnPrivateUserWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

#pragma mark
#pragma mark Search
- (IBAction)onClickOfSearchBtn:(id)sender {
    TCSTART
    UIButton *searchBtn = (UIButton *)sender;
    CGFloat searchBarHeight = notificationsSearchBar.frame.size.height;
    if (searchBtn.tag == 1) {
        refreshView.hidden = YES;
        searchBtn.tag = 123;
        searchSelected = YES;
        [notificationsSearchBar becomeFirstResponder];
        //Search
        searchBtn.frame = CGRectMake(250, searchBtn.frame.origin.y, 65, searchBtn.frame.size.height);
        [searchBtn setBackgroundImage:[UIImage imageNamed:@"SearchCancel"] forState:UIControlStateNormal];
        [searchBtn setBackgroundImage:[UIImage imageNamed:@"SearchCancel_f"] forState:UIControlStateHighlighted];
        [searchBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        notificationsSearchBar.hidden = NO;
        searchBarBg.hidden = NO;
        notificationsTableView.frame = CGRectMake(notificationsTableView.frame.origin.x, notificationsTableView.frame.origin.y + searchBarHeight, notificationsTableView.frame.size.width, notificationsTableView.frame.size.height - searchBarHeight);
    } else {
        refreshView.hidden = NO;
        [notificationsSearchBar resignFirstResponder];
        searchBtn.tag = 1;
        //cancel
        searchSelected = NO;
        [self getNotificationsFromDB];
        notificationsSearchBar.hidden = YES;
        searchBarBg.hidden = YES;
        //        [searchDict removeAllObjects];
        notificationsSearchBar.text = @"";
        searchBtn.frame = CGRectMake(285, searchBtn.frame.origin.y, 30, searchBtn.frame.size.height);
        [searchBtn setBackgroundImage:[UIImage imageNamed:@"HomeSearch"] forState:UIControlStateNormal];
        [searchBtn setBackgroundImage:[UIImage imageNamed:@"HomeSearch"] forState:UIControlStateHighlighted];
        [searchBtn setTitle:@"" forState:UIControlStateNormal];
        notificationsTableView.frame = CGRectMake(notificationsTableView.frame.origin.x, notificationsTableView.frame.origin.y - searchBarHeight, notificationsTableView.frame.size.width, notificationsTableView.frame.size.height + searchBarHeight);
        [notificationsTableView reloadData];
    }
    //    [self refreshTableViewWithSelectedBrowseTypePage:(searchSelected?[NSString stringWithFormat:@"%@SearchPgNum",browseType]:[NSString stringWithFormat:@"%@BrowsePgNum",browseType])];
    TCEND
}

- (void)customizeSearchBar {
    @try {
        notificationsSearchBar.placeholder = @"Search";
        notificationsSearchBar.keyboardType = UIKeyboardTypeDefault;
        notificationsSearchBar.barStyle = UIBarStyleDefault;
        notificationsSearchBar.delegate = self;
        
        [self setBackgroundForSearchBar:notificationsSearchBar withImagePath:@"SearchBarBg"];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)setBackgroundForSearchBar:(UISearchBar *)searchbar withImagePath:(NSString *)imgPath {
    
    @try {
        //set the searchbar textfield to image view.
        UITextField *searchField;
        NSArray *searchSubViews;
        if (CURRENT_DEVICE_VERSION < 7.0) {
            searchSubViews = searchbar.subviews;
        } else {
            searchSubViews = [[searchbar.subviews objectAtIndex:0] subviews];
        }
        for(int i = 0; i < searchSubViews.count; i++) {
            if([[searchSubViews objectAtIndex:i] isKindOfClass:[UITextField class]]) { //conform?
                searchField = [searchSubViews objectAtIndex:i];
                searchField.returnKeyType = UIReturnKeySearch;
            }
        }
        if(!(searchField == nil)) {
            searchField.textColor = [UIColor blackColor];
            searchField.backgroundColor = [UIColor clearColor];
            [searchField setBackground: [UIImage imageNamed:imgPath]];
            
            [searchField setBorderStyle:UITextBorderStyleNone];
            searchField.enablesReturnKeyAutomatically = YES;
        }
        //remove the search bar background view.
        for (int i = 0; i < searchSubViews.count; i++) {
            if ([[searchSubViews objectAtIndex:i] isKindOfClass:NSClassFromString
                 (@"UISearchBarBackground")]) {
                [[searchSubViews objectAtIndex:i]removeFromSuperview];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

#pragma searchBarDelegate Methods
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    TCSTART
    TCEND
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    TCSTART
    [self makeSearchRequestWithSearchString:searchBar.text];
    [searchBar resignFirstResponder];
    TCEND
}

#pragma mark Search
- (void)makeSearchRequestWithSearchString:(NSString *)searchString {
    TCSTART
    if (searchString.length > 0) {
        searchString = [appDelegate removingLastSpecialCharecter:searchString];
    }
    if (searchString.length > 0) {
        [appDelegate makeNotificaitonsSearchRequestWithSearchKeyword:searchString andCaller:self];
        [appDelegate showActivityIndicatorInView:notificationsTableView andText:@"Loading"];
        [appDelegate showNetworkIndicator];
    } else {
        [ShowAlert showWarning:@"Please enter search keyword"];
    }
    TCEND
}

- (void)didFinishedToGetUserNotificationsSearch:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:notificationsTableView];
    [notificationsArray removeAllObjects];
    [notificationsArray addObjectsFromArray:[results objectForKey:@"searcResponse"]];
    [notificationsTableView reloadData];
    TCEND
}

- (void)didFailToGetUserNotificationsSearchWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:notificationsTableView];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
//    [notificationsTableView reloadData];
    TCEND
}


#pragma mark Scrolling Overrides
#pragma mark TableScrollView Delegate Methods Refreshing Table
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    @try {
        if (!reloading) {
            checkForRefresh = YES;  //  only check offset when dragging
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    @try {
        // NSLog(@"scrollViewDidScroll with offset %f",scrollView.contentOffset.y);
        if (reloading) return;
        
        if (checkForRefresh ) {
            if (refreshView.isFlipped && scrollView.contentOffset.y > -45.0f && scrollView.contentOffset.y < 0.0f && !reloading) {
                [refreshView flipImageAnimated:YES];
                [refreshView setStatus:kPullToReloadStatus];
                
            } else if (!refreshView.isFlipped && scrollView.contentOffset.y < -45.0f) {
                [refreshView flipImageAnimated:YES];
                [refreshView setStatus:kReleaseToReloadStatus];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    @try {
        if (reloading) return;
        
        if (scrollView.contentOffset.y <= -45.0f) {
            [self showReloadAnimationAnimated:YES];
            [self refreshNotificationsScreen];
        }
        checkForRefresh = NO;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}

- (void) showReloadAnimationAnimated:(BOOL)animated {
    @try {
        reloading = YES;
        [refreshView toggleActivityView:YES];
        
        if (animated) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.2];
            notificationsTableView.contentInset = UIEdgeInsetsMake(40.0f, 0.0f, 0.0f, 0.0f);
            [UIView commitAnimations];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)dataSourceDidFinishLoadingNewData {
    @try {
        reloading = NO;
        [refreshView flipImageAnimated:NO];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.3];
        [notificationsTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        [refreshView setStatus:kPullToReloadStatus];
        [refreshView toggleActivityView:NO];
        [UIView commitAnimations];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)refreshNotificationsScreen {
    mainVC.isNotificationsEnterBg = NO;
    [self getUserNotificationsRequestForNotifications:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
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
