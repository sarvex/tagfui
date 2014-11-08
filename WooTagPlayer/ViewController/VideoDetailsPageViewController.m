/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "VideoDetailsPageViewController.h"
#import "CommentUserCell.h"
#import "OthersPageViewController.h"

@interface VideoDetailsPageViewController () {
    CustomMoviePlayerViewController *customMoviePlayerVC;
}

@end

@implementation VideoDetailsPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withVideoModal:(VideoModal *)videoModal andNotificationType:(NotificationType )notificationType
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        selectedVideo = videoModal;
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        type = notificationType;
    }
    return self;
}

- (void)viewDidLoad {
    TCSTART
    [super viewDidLoad];
    videoTitleHeaderLabel.text = selectedVideo.title;
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height-20);
    [commentsTableView registerNib:[UINib nibWithNibName:@"CommentUserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CommentUserCellID"];
    commentsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if ([self isNotNull:selectedVideo]) {
        [self setupUIObjectsData];
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

- (void)setupUIObjectsData {
    TCSTART
    //Video ThumbPath
    if ([self isNotNull:selectedVideo.videoThumbPath]) {
        [videoThumbPath setImageWithURL:[NSURL URLWithString:selectedVideo.videoThumbPath] placeholderImage:[UIImage imageNamed:@"DefaultVideoThumb"]];
    } else {
        videoThumbPath.image = [UIImage imageNamed:@"DefaultVideoThumb"];
    }
    
    
    if ([self isNotNull:selectedVideo.userPhoto]) {
        [profilePic setImageWithURL:[NSURL URLWithString:selectedVideo.userPhoto] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached];
    } else {
        profilePic.image = [UIImage imageNamed:@"OwnerPic"];
    }
    profilePic.layer.cornerRadius = 16.5f;
    profilePic.layer.borderWidth = 1.5f;
    profilePic.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
    profilePic.layer.masksToBounds = YES;
    
    videoInfoBgLbl.backgroundColor = [appDelegate colorWithHexString:@"fafafa"];
    
    dividerLabel.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
    
    if ([self isNotNull:selectedVideo.userName]) {
        userNameLabel.text = selectedVideo.userName;
    } else {
        userNameLabel.text = @"";
    }
    
    if ([self isNotNull:selectedVideo.latestTagExpression]) {
        videoTitleLbl.text = selectedVideo.latestTagExpression;
    } else {
        videoTitleLbl.text = selectedVideo.title?:@"";
    }
    
    if ([self isNotNull:selectedVideo.creationTime]) {
        videoCreatedlbl.text = [appDelegate relativeDateString:selectedVideo.creationTime];
    } else {
        videoCreatedlbl.text = @"";
    }
    
    
    if ([self isNotNull:selectedVideo.numberOfViews]) {
        videoViewsLabel.text = [NSString stringWithFormat:@"%@",[appDelegate getUserStatisticsFormatedString:[selectedVideo.numberOfViews longLongValue]]];
    } else {
        videoViewsLabel.text = @"";
    }
    
    
    if ([self isNotNull:selectedVideo.numberOfCmnts]) {
        numberOfCmntsLabel.text = [NSString stringWithFormat:@"%@ Comment%@",[appDelegate getUserStatisticsFormatedString:[selectedVideo.numberOfCmnts longLongValue]],[appDelegate returningPluralFormWithCount:[selectedVideo.numberOfCmnts integerValue]]];
    } else {
        numberOfCmntsLabel.text = @"";
    }
    
    if ([self isNotNull:selectedVideo.numberOfLikes]) {
        numberOfLikesLabel.text = [NSString stringWithFormat:@"%@ Like%@",[appDelegate getUserStatisticsFormatedString:[selectedVideo.numberOfLikes longLongValue]],[appDelegate returningPluralFormWithCountForLikes:[selectedVideo.numberOfLikes integerValue]]];
    } else {
        numberOfLikesLabel.text = @"";
    }
    
    if ([self isNotNull:selectedVideo.numberOfTags]) {
        numberOfTagsLabel.text = [NSString stringWithFormat:@"%@ Tag%@",[appDelegate getUserStatisticsFormatedString:[selectedVideo.numberOfTags longLongValue]],[appDelegate returningPluralFormWithCount:[selectedVideo.numberOfTags integerValue]]];
    } else {
        numberOfTagsLabel.text = @"";
    }
    
    if (selectedVideo.comments.count > 0 || selectedVideo.likesList.count > 0) {
        commentsTableView.hidden = NO;
        [commentsTableView reloadData];
    } else {
        commentsTableView.hidden = YES;
    }
    
    TCEND
}

- (IBAction)onClickUserNameBtn:(id)sender {
    TCSTART
    if (selectedVideo.userId.intValue != [appDelegate.loggedInUser.userId integerValue]) {
        OthersPageViewController *otherPageVC = [[OthersPageViewController alloc] initWithNibName:@"OthersPageViewController" bundle:Nil andUser:selectedVideo.userId];
        [self.navigationController pushViewController:otherPageVC animated:YES];
        otherPageVC.caller = self;
    }
    TCEND
}
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark tableview datasource and Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (type == Like) {
        return selectedVideo.likesList.count;
    } else {
        return selectedVideo.comments.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    CGFloat heightOfTheRow = 50;
    if (type == Comment || type == UserTag) {
        NSDictionary *commentDict = [selectedVideo.comments objectAtIndex:indexPath.row];
        CGSize descptnSize = [[Base64Converter decodedString:[commentDict objectForKey:@"comment_text"]] sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:12] constrainedToSize:CGSizeMake(265, 2222) lineBreakMode:UILineBreakModeWordWrap];
        
        if (descptnSize.height > 20) {
            heightOfTheRow = 30 + descptnSize.height + 5;
        }
    }
    
    return heightOfTheRow;
    
    TCEND
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        
        //static NSString *user_messageCell = @"messageCell";
        static NSString *CellIndentifier = @"CommentUserCellID";
        
        //            CGFloat rowHeight = 50;
        
        CommentUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
        //initialize cell and its subviews instances once and use them when table scrolling through their instances retrieved based on "Tag" value
        if (cell == nil) {
            cell = [[CommentUserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIndentifier];
        }
        
        cell.addUserBtn.hidden = YES;
        cell.deleteUserBtn.hidden = YES;
        cell.userPicImgView.layer.cornerRadius = 20.0f;
        cell.userPicImgView.layer.borderWidth = 1.5f;
        cell.userPicImgView.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
        cell.userPicImgView.layer.masksToBounds = YES;
        
        cell.userNameLbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
        
        cell.cellDividerLbl.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
        
        cell.commentTextLbl.textColor = [UIColor darkGrayColor];
        
        NSDictionary *commentDict;
        
        if (type == Like) {
            commentDict = [selectedVideo.likesList objectAtIndex:indexPath.row];
        } else  {
            commentDict = [selectedVideo.comments objectAtIndex:indexPath.row];
        }
        //check if Like data for a row is not null
        if ([self isNotNull:commentDict]) {
            if ([self isNotNull:[commentDict objectForKey:@"photo_path"]]) {
                [cell.userPicImgView setImageWithURL:[NSURL URLWithString:[commentDict objectForKey:@"photo_path"]] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached];
            } else {
                cell.userPicImgView.image = [UIImage imageNamed:@"OwnerPic"];
            }
            
            //Display the name of user
            if ([self isNotNull:[commentDict objectForKey:@"user_name"]]) {
                cell.userNameLbl.text = [commentDict objectForKey:@"user_name"];
            } else {
                cell.userNameLbl.text = @"";
            }
            
            if ([self isNotNull:[commentDict objectForKey:@"comment_text"]]) {
                cell.commentTextLbl.text = [Base64Converter decodedString:[commentDict objectForKey:@"comment_text"]];
                CGSize descptnSize = [[Base64Converter decodedString:[commentDict objectForKey:@"comment_text"]] sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:12] constrainedToSize:CGSizeMake(265, 2222) lineBreakMode:UILineBreakModeWordWrap];
                
                cell.commentTextLbl.frame = CGRectMake(50, 25, 265, (descptnSize.height>20)?(descptnSize.height + 5):23);
                cell.userNameLbl.frame = CGRectMake(50, 4, 265, 20);
            } else {
                cell.commentTextLbl.text = @"";
                cell.userNameLbl.frame = CGRectMake(50, 4, 265, 50 - 8);
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    NSDictionary *commentDict;
    if (type == Like) {
        commentDict = [selectedVideo.likesList objectAtIndex:indexPath.row];
    } else  {
        commentDict = [selectedVideo.comments objectAtIndex:indexPath.row];
    }
    if ([self isNotNull:[commentDict objectForKey:@"user_id"]] && [[commentDict objectForKey:@"user_id"] intValue] != [appDelegate.loggedInUser.userId intValue]) {
        OthersPageViewController *otherPageVC = [[OthersPageViewController alloc] initWithNibName:@"OthersPageViewController" bundle:Nil andUser:[NSString stringWithFormat:@"%d",[[commentDict objectForKey:@"user_id"] intValue]]];
        [self.navigationController pushViewController:otherPageVC animated:YES];
        otherPageVC.caller = self;
        otherPageVC.selectedIndexPath = indexPath;
    }
    TCEND
}

#pragma mark Get All Likes Delegate Methods
- (IBAction)onClickOfGetAllLikesButton:(id)sender {
    TCSTART
    if ([self isNotNull:selectedVideo]) {
        [self gotoAllCommentsScreenType:@"Like"];
    }
    TCEND
}

#pragma mark Comment Related Methods and Get All Comments Delegate methods
- (IBAction)onClickOfCommentButton:(id)sender {
    TCSTART
    if ([self isNotNull:selectedVideo]) {
        [self gotoAllCommentsScreenType:@"Comment"];
    }
    TCEND
}

- (void)gotoAllCommentsScreenType:(NSString *)type_ {
    TCSTART
    NSInteger count;
    if ([type_ caseInsensitiveCompare:@"Comment"] == NSOrderedSame) {
        count = [selectedVideo.numberOfCmnts integerValue];
        appDelegate.videoFeedVC.mainVC.customTabView.hidden = YES;
    } /*else if ([type caseInsensitiveCompare:@"Follower"] == NSOrderedSame) {
       usersArray = user.followers;
       } else if ([type caseInsensitiveCompare:@"Following"] == NSOrderedSame) {
       usersArray = user.followings;
       } */else {
           count = [selectedVideo.numberOfLikes integerValue];
       }
    
    allCmntsVC = [[AllCommentsViewController alloc] initWithNibName:@"AllCommentsViewController" bundle:nil withVideoModal:selectedVideo user:nil viewType:type_ andSelectedIndexPath:nil andTotalCount:count andCaller:self];
    
    if ([type_ caseInsensitiveCompare:@"Comment"] == NSOrderedSame) {
        [appDelegate.videoFeedVC.mainVC.navigationController pushViewController:allCmntsVC animated:YES];
    } else {
        [self.navigationController pushViewController:allCmntsVC animated:YES];
    }
    
    TCEND
}

- (void)allCommentsScreenDismissCalledSelectedIndexPath:(NSIndexPath *)indexPath andViewType:(NSString *)viewType {
    TCSTART
    numberOfCmntsLabel.text = [NSString stringWithFormat:@"%@ Comment%@",[appDelegate getUserStatisticsFormatedString:[selectedVideo.numberOfCmnts longLongValue]],[appDelegate returningPluralFormWithCount:[selectedVideo.numberOfCmnts integerValue]]];
    numberOfLikesLabel.text = [NSString stringWithFormat:@"%@ Like%@",[appDelegate getUserStatisticsFormatedString:[selectedVideo.numberOfLikes longLongValue]],[appDelegate returningPluralFormWithCountForLikes:[selectedVideo.numberOfLikes integerValue]]];
    numberOfTagsLabel.text = [NSString stringWithFormat:@"%@ Tag%@",[appDelegate getUserStatisticsFormatedString:[selectedVideo.numberOfTags longLongValue]],[appDelegate returningPluralFormWithCount:[selectedVideo.numberOfTags integerValue]]];
    videoViewsLabel.text = [NSString stringWithFormat:@"%@",[appDelegate getUserStatisticsFormatedString:[selectedVideo.numberOfViews longLongValue]]];
    allCmntsVC = nil;
    appDelegate.videoFeedVC.mainVC.customTabView.hidden = NO;
    if (selectedVideo.comments.count > 0) {
        commentsTableView.hidden = NO;
        [commentsTableView reloadData];
    }
    customMoviePlayerVC = nil;
    TCEND
}


- (IBAction)onClickOfPlayButton:(id)sender {
    TCSTART
    if ([self isNotNull:selectedVideo]) {
        [appDelegate requestForPlayBackWithVideoId:selectedVideo.videoId andcaller:self andIndexPath:Nil refresh:NO];
    }
    TCEND
}

- (void)playBackResponse:(NSDictionary *)results {
    TCSTART
    if ([self isNotNull:results] && ![[results objectForKey:@"isResponseNull"] boolValue]) {
        VideoModal *video;
        if ([self isNotNull:[results objectForKey:@"refresh"]] && ![[results objectForKey:@"refresh"] boolValue]) {
            if ([self isNotNull:[[results objectForKey:@"results"] objectForKey:@"uid"]]) {
                selectedVideo.userId = [[results objectForKey:@"results"] objectForKey:@"uid"];
            }
            if ([self isNotNull:[[results objectForKey:@"results"] objectForKey:@"video_url"]]) {
                selectedVideo.path = [[results objectForKey:@"results"] objectForKey:@"video_url"];
            }
            if ([self isNotNull:[[results objectForKey:@"results"] objectForKey:@"username"]]) {
                selectedVideo.userName = [[results objectForKey:@"results"] objectForKey:@"username"];
            }
            if ([self isNotNull:[[results objectForKey:@"results"] objectForKey:@"user_photo"]]) {
                video.userPhoto = [[results objectForKey:@"results"] objectForKey:@"user_photo"];
            }
            video = selectedVideo;
        } else {
            if ([self isNotNull:[results objectForKey:@"video"]]) {
                video = [results objectForKey:@"video"];
            }
        }
        customMoviePlayerVC = [[CustomMoviePlayerViewController alloc] initWithNibName:@"CustomMoviePlayerViewController" bundle:nil video:video videoFilePath:nil andClientVideoId:video.videoId showInstrcutnScreen:NO];
        [self presentViewController:customMoviePlayerVC animated:YES completion:nil];
        customMoviePlayerVC.caller = self;
    }
    TCEND
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
