/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "AllCommentsViewController.h"
#import "OthersPageViewController.h"
#import "CommentUserCell.h"
#import "Video.h"
#import "User.h"
#import "PendingPrivateGroupViewController.h"

#define COMMENTVIEW_TABLEORIGINY 70
#define KEYBOARD_PORTRAIT_HEIGHT 216
@interface AllCommentsViewController ()

@end

@implementation AllCommentsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withVideoModal:(VideoModal *)videoModal user:(UserModal *)selectedUser viewType:(NSString *)type andSelectedIndexPath:(NSIndexPath *)_indexPath andTotalCount:(NSInteger)totalcount andCaller:(id)caller_ {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        selectedVideoModal = videoModal;
        user = selectedUser;
        viewType = type;
        selectedIndexPath = _indexPath;
        count = totalcount;
        caller = caller_;
    }
    return self;
}

- (void)viewDidLoad {
    TCSTART
    [super viewDidLoad];
    [commentsTableView registerNib:[UINib nibWithNibName:@"CommentUserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CommentUserCellID"];
    pageNumber = 1;
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height - 20);
    titleLabel.backgroundColor = [appDelegate colorWithHexString:@"fafafa"];
    editBtn.hidden = YES;
    if ([viewType caseInsensitiveCompare:@"Like"] == NSOrderedSame) {
        titleLabel.text = [NSString stringWithFormat:@"%d %@%@",count,viewType,[appDelegate returningPluralFormWithCount:count]];
        videoCmntsArray = [selectedVideoModal.likesList mutableCopy];
        headerLbl.text = @"Likes";
    } else {
        titleLabel.text = [NSString stringWithFormat:@"%d %@%@",count,viewType,[appDelegate returningPluralFormWithCount:count]];
        if ([viewType caseInsensitiveCompare:@"comment"] == NSOrderedSame) {
            videoCmntsArray = [selectedVideoModal.comments mutableCopy];
            headerLbl.text = @"Comments";
        } else if ([viewType caseInsensitiveCompare:@"Follower"] == NSOrderedSame) {
            videoCmntsArray = [user.followers mutableCopy];
            headerLbl.text = @"Followers";
        } else if ([viewType caseInsensitiveCompare:@"Private connections"] == NSOrderedSame) {
            if ([user.userId integerValue] == [appDelegate.loggedInUser.userId  intValue]) {
                editBtn.hidden = NO;
            }
            videoCmntsArray = [user.privateUsers mutableCopy];
            headerLbl.text = @"Private connections";
            titleLabel.text = [NSString stringWithFormat:@"%d/150 %@",count,viewType];
        } else {
            videoCmntsArray = [user.followings mutableCopy];
            headerLbl.text = @"Following";
        }
    }
    
    //    if (videoCmntsArray.count != count) {
    [self makeRequestBasedOnViewType:NO];
    //    }
    
    
    commentsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if ([viewType caseInsensitiveCompare:@"comment"] == NSOrderedSame) {
        cmtTextViewBg.hidden = NO;
        cmntTextView.hidden = NO;
        cmntTextView.text = @"type your comment here";
        cmntTextView.textColor = [UIColor lightGrayColor];
        commentsTableView.frame = CGRectMake(commentsTableView.frame.origin.x, commentsTableView.frame.origin.y, commentsTableView.frame.size.width, commentsTableView.frame.size.height - (([caller isKindOfClass:[CustomMoviePlayerViewController class]] || CURRENT_DEVICE_VERSION < 7.0)?0:20));
        
    } else {
        cmtTextViewBg.hidden = YES;
        cmntTextView.hidden = YES;
        commentsTableView.frame = CGRectMake(commentsTableView.frame.origin.x, commentsTableView.frame.origin.y, commentsTableView.frame.size.width, commentsTableView.frame.size.height + 48);
    }
    if ([caller isKindOfClass:[CustomMoviePlayerViewController class]]) {
        
    } else {
        cmtTextViewBg.frame = CGRectMake(0, self.view.frame.size.height - ((CURRENT_DEVICE_VERSION < 7.0)?48:68), cmtTextViewBg.frame.size.width, cmtTextViewBg.frame.size.height);
    }
    
    cmntTextView.layer.cornerRadius = 4.0f;
    cmntTextView.layer.borderWidth = 1.0f;
    cmntTextView.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
    cmntTextView.layer.masksToBounds = YES;
    TCEND
}

- (void)makeRequestBasedOnViewType:(BOOL)isPagination {
    TCSTART
    if ([viewType caseInsensitiveCompare:@"Follower"] == NSOrderedSame) {
        [self makeRequestForListOfFollowers:isPagination];
    } else if ([viewType caseInsensitiveCompare:@"Following"] == NSOrderedSame) {
        [self makeRequestForListOfFollowings:isPagination];
    } else if ([viewType caseInsensitiveCompare:@"Private connections"] == NSOrderedSame) {
        [self makeRequestForListOfPrivateUsers:isPagination];
    } else if ([viewType caseInsensitiveCompare:@"Comment"] == NSOrderedSame) {
        [self makeRequestForAllComments:isPagination];
    } else {
        [self makeRequestForListOfLovedUsers:isPagination];
    }
    TCEND
}

#pragma mark Followers
- (void)makeRequestForListOfFollowers:(BOOL)pagination {
    TCSTART
    if ([self isNotNull:user.userId]) {
        [appDelegate showNetworkIndicator];
        if (!pagination) {
//            [appDelegate showActivityIndicatorInView:commentsTableView andText:@"Loading"];
        }
        [appDelegate makeRequestForUserFollowersWithUserId:user.userId pageNumber:pageNumber andCaller:self];
    }
    TCEND
}

- (void)didFinishedToGetUserFollowers:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:commentsTableView];
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"isResponseNull"]] && ![[results objectForKey:@"isResponseNull"] boolValue]) {
        if (pageNumber == 1) {
            videoCmntsArray = [results objectForKey:@"followers"];
        } else {
            [videoCmntsArray addObjectsFromArray:[results objectForKey:@"followers"]];
        }
        if (count < videoCmntsArray.count) {
            count = videoCmntsArray.count;
            titleLabel.text = [NSString stringWithFormat:@"%d %@%@",count,viewType,[appDelegate returningPluralFormWithCount:count]];
        }
    }
    [commentsTableView reloadData];
    TCEND
}
- (void)didFailToGetUserFollowersWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:commentsTableView];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    [commentsTableView reloadData];
    TCEND
}

#pragma mark Followings
- (void)makeRequestForListOfFollowings:(BOOL)pagination {
    TCSTART
    if ([self isNotNull:user.userId]) {
        [appDelegate showNetworkIndicator];
        if (!pagination) {
//            [appDelegate showActivityIndicatorInView:commentsTableView andText:@"Loading"];
        }
        [appDelegate makeRequestForUserFollowingsWithUserId:user.userId pageNumber:pageNumber andCaller:self];
    }
    TCEND
}

- (void)didFinishedToGetUserFollowings:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:commentsTableView];
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"isResponseNull"]] && ![[results objectForKey:@"isResponseNull"] boolValue]) {
        if (pageNumber == 1) {
            videoCmntsArray = [results objectForKey:@"followings"];
        } else {
            [videoCmntsArray addObjectsFromArray:[results objectForKey:@"followings"]];
        }
        if (count < videoCmntsArray.count) {
            count = videoCmntsArray.count;
            titleLabel.text = [NSString stringWithFormat:@"%d %@%@",count,viewType,[appDelegate returningPluralFormWithCount:count]];
        }
    }
    [commentsTableView reloadData];
    TCEND
}
- (void)didFailToGetUserFollowingsWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:commentsTableView];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    [commentsTableView reloadData];
    TCEND
}

#pragma mark List private users
- (void)makeRequestForListOfPrivateUsers:(BOOL)pagination {
    TCSTART
    if ([self isNotNull:user.userId]) {
        [appDelegate showNetworkIndicator];
        if (!pagination) {
//            [appDelegate showActivityIndicatorInView:commentsTableView andText:@"Loading"];
        }
        [appDelegate makeRequestForPrivateUsersWithUserId:user.userId pageNumber:pageNumber andCaller:self];
    }
    TCEND
}

- (void)didFinishedToGetPrivateUsers:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:commentsTableView];
    if ([self isNotNull:[results objectForKey:@"total_no_of_pendingpvtgroup"]]) {
        user.totalNoOfPeningPrivateUsers = [NSNumber numberWithInt:[[results objectForKey:@"total_no_of_pendingpvtgroup"] intValue]];
    }
    
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"isResponseNull"]] && ![[results objectForKey:@"isResponseNull"] boolValue]) {
        
        if (pageNumber == 1) {
            //
            videoCmntsArray = [results objectForKey:@"pvtgroup"];
        } else {
            [videoCmntsArray addObjectsFromArray:[results objectForKey:@"pvtgroup"]];
        }
        if (count < videoCmntsArray.count) {
            count = videoCmntsArray.count;
            titleLabel.text = [NSString stringWithFormat:@"%d/150 %@",count,viewType];
        }
    }
    [commentsTableView reloadData];
    TCEND
}
- (void)didFailToGetPrivateUsersWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:commentsTableView];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    [commentsTableView reloadData];
    TCEND
}

#pragma mark Loved list
- (void)makeRequestForListOfLovedUsers:(BOOL)pagination {
    TCSTART
    if ([self isNotNull:selectedVideoModal.videoId]) {
        [appDelegate showNetworkIndicator];
        if (!pagination) {
//            [appDelegate showActivityIndicatorInView:commentsTableView andText:@"Loading"];
        }
        [appDelegate getAllLikesListOfVideoWithVideoId:selectedVideoModal.videoId andCaller:self andIndexPath:selectedIndexPath andPageNumber:pageNumber];
    }
    TCEND
}
- (void)didFinishedToGetAllLikesOfVideo:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:commentsTableView];
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"isResponseNull"]] && ![[results objectForKey:@"isResponseNull"] boolValue] && [self isNotNull:[results objectForKey:@"likelist"]]) {
        if (pageNumber == 1) {
            videoCmntsArray = [results objectForKey:@"likelist"];
        } else {
            [videoCmntsArray addObjectsFromArray:[results objectForKey:@"likelist"]];
        }
        if (count < videoCmntsArray.count) {
            count = videoCmntsArray.count;
            titleLabel.text = [NSString stringWithFormat:@"%d %@%@",count,viewType,[appDelegate returningPluralFormWithCount:count]];
        }
    }
    [commentsTableView reloadData];
    TCEND
}

- (void)didFailToGetAllLikesOfVideoWithError:(NSDictionary *)errorDict {
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:commentsTableView];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    [commentsTableView reloadData];
}

- (void)makeRequestForAllComments:(BOOL)pagination {
    TCSTART
    if ([self isNotNull:selectedVideoModal.videoId]) {
        [appDelegate showNetworkIndicator];
        if (!pagination) {
//            [appDelegate showActivityIndicatorInView:commentsTableView andText:@"Loading"];
        }
        [appDelegate getAllCommentsOfVideoWithVideoId:selectedVideoModal.videoId andCaller:self andIndexPath:selectedIndexPath pageNumber:pageNumber];
    }
    TCEND
}

- (void)didFinishedToGetAllCommentsOfVideo:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:commentsTableView];
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"isResponseNull"]] && ![[results objectForKey:@"isResponseNull"] boolValue] && [self isNotNull:[results objectForKey:@"VideoId"]]) {
        if (pageNumber == 1) {
            videoCmntsArray = [results objectForKey:@"comments"];
        } else {
            [videoCmntsArray addObjectsFromArray:[results objectForKey:@"comments"]];
        }
        if (count < videoCmntsArray.count) {
            count = videoCmntsArray.count;
            titleLabel.text = [NSString stringWithFormat:@"%d %@%@",count,viewType,[appDelegate returningPluralFormWithCount:count]];
        }
    }
    [commentsTableView reloadData];
    TCEND
}

- (void)didFailToGetAllCommentsOfVideoWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:commentsTableView];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    [commentsTableView reloadData];
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)onClickOfBackButton:(id)sender {
    TCSTART
//    [commentsTableView setEditing:NO animated:NO];
    cmntTextView.delegate = nil;
    cmntTextView = nil;
    if ([viewType caseInsensitiveCompare:@"Following"] == NSOrderedSame || [viewType caseInsensitiveCompare:@"Private connections"] == NSOrderedSame || [viewType caseInsensitiveCompare:@"Follower"] == NSOrderedSame) {
        if ([viewType caseInsensitiveCompare:@"Following"] == NSOrderedSame) {
            user.followings = [NSArray arrayWithArray:videoCmntsArray];
            user.totalNoOfFollowings = [NSNumber numberWithInt:count];
        } else if ([viewType caseInsensitiveCompare:@"Private connections"] == NSOrderedSame) {
            user.privateUsers = [NSArray arrayWithArray:videoCmntsArray];
            user.totalNoOfPrivateUsers = [NSNumber numberWithInt:count];
        } else {
            user.followers = [NSArray arrayWithArray:videoCmntsArray];
            user.totalNoOfFollowers = [NSNumber numberWithInt:count];
        }
    }
    
    if ([viewType caseInsensitiveCompare:@"Like"] == NSOrderedSame) {
        selectedVideoModal.likesList = [NSArray arrayWithArray:videoCmntsArray];
        selectedVideoModal.numberOfLikes = [NSNumber numberWithInt:count];
    } else {
        if (videoCmntsArray.count > 2) {
            selectedVideoModal.comments = [videoCmntsArray subarrayWithRange:NSMakeRange(videoCmntsArray.count - 2, 2)];
        } else {
            selectedVideoModal.comments = [NSArray arrayWithArray:videoCmntsArray];
        }
        selectedVideoModal.numberOfCmnts = [NSNumber numberWithInt:count];
    }
    
    if ([caller respondsToSelector:@selector(allCommentsScreenDismissCalledSelectedIndexPath: andViewType:)]) {
        [caller allCommentsScreenDismissCalledSelectedIndexPath:selectedIndexPath andViewType:viewType];
    }
    
    if ([caller isKindOfClass:[CustomMoviePlayerViewController class]]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    TCEND
}

#pragma mark Delete Comment
- (BOOL)canDeleteCommentAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    BOOL canEdit = NO;
    if ([self isNotNull:indexPath]) {
        NSDictionary *cmnt = [videoCmntsArray objectAtIndex:indexPath.row];
        int userId;
        if ([self isNotNull:user.userId]) {
            userId = user.userId.intValue;
        } else {
            userId = selectedVideoModal.userId.intValue;
        }
        if (userId == appDelegate.loggedInUser.userId.intValue) {
            canEdit = YES;
        } else if ([self isNotNull:[cmnt objectForKey:@"comment_id"]] && [self isNotNull:[cmnt objectForKey:@"user_id"]] && [[cmnt objectForKey:@"user_id"] intValue] == [appDelegate.loggedInUser.userId intValue]) {
            canEdit = YES;
        } else {
            canEdit = NO;
        }
    }
    return canEdit;
    TCEND
}
- (void)onClickOfCommentButtonAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:indexPath]) {
        NSDictionary *cmnt = [videoCmntsArray objectAtIndex:indexPath.row];
        if ([self isNotNull:[cmnt objectForKey:@"comment_id"]]) {
            [appDelegate showNetworkIndicator];
            [appDelegate makeDeleteCommentRequestForVideoWithcmntId:[cmnt objectForKey:@"comment_id"] andCaller:self andIndexPath:indexPath];
        }
    }
    TCEND
}

#pragma make Delete comment request and resposne
- (void)didFinishedDeleteCommentVideo:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:commentsTableView];
    if ([self isNotNull:[results objectForKey:@"indexPath"]]) {
        NSIndexPath *indexpath = [results objectForKey:@"indexPath"];
        
        [videoCmntsArray removeObjectAtIndex:indexpath.row];
        
        NSInteger noofCmts;
        noofCmts  = [selectedVideoModal.numberOfCmnts integerValue];
        noofCmts = noofCmts - 1;
        selectedVideoModal.numberOfCmnts = [NSNumber numberWithInt:noofCmts];
        count = [selectedVideoModal.numberOfCmnts integerValue];
        titleLabel.text = [NSString stringWithFormat:@"%d %@%@",count,viewType,[appDelegate returningPluralFormWithCount:count]];
        selectedVideoModal.hasCommentedOnVideo = NO;
        
        for (NSDictionary *cmntDict in videoCmntsArray) {
            if ([self isNotNull:[cmntDict objectForKey:@"user_id"]] && [[cmntDict objectForKey:@"user_id"] intValue] == appDelegate.loggedInUser.userId.intValue) {
                selectedVideoModal.hasCommentedOnVideo = YES;
                break;
            }
        }
        
        [commentsTableView reloadData];
    }
    TCEND
}
- (void)didFailToDeleteCommentVideoWithError:(NSDictionary *)errorDict {
    TCSTART
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:commentsTableView];
    TCEND
}

#pragma mark Post Comment
- (IBAction)makePostCommentRequest {
    TCSTART
    
    if (cmntTextView.textColor == [UIColor blackColor] && cmntTextView.text.length > 0) {
        cmntTextView.commentText = [appDelegate removingLastSpecialCharecter:cmntTextView.text];
        if (cmntTextView.commentText.length > 0) {
            [self dismissKeyboard:nil];
            [appDelegate makePostCommentRequestForVideo:selectedVideoModal.videoId withCommentText:[Base64Converter encodeString:cmntTextView.commentText] andCaller:self andIndexPath:selectedIndexPath];
            cmntTextView.text = @"";
            [appDelegate showNetworkIndicator];
            [self removeTagUsersList];
        } else {
//            [ShowAlert showError:@"You should enter comment text"];
        }
    }
    
    TCEND
}

- (void)didFinishedCommentingVideo:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:commentsTableView];
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"isResponseNull"]] && ![[results objectForKey:@"isResponseNull"] boolValue]) {
        
        [videoCmntsArray addObject:[results objectForKey:@"comments"]];
        NSInteger noofCmts;
        noofCmts  = [selectedVideoModal.numberOfCmnts integerValue];
        noofCmts = noofCmts + 1;
        selectedVideoModal.numberOfCmnts = [NSNumber numberWithInt:noofCmts];
        count = [selectedVideoModal.numberOfCmnts integerValue];
        titleLabel.text = [NSString stringWithFormat:@"%d %@%@",count,viewType,[appDelegate returningPluralFormWithCount:count]];
        [commentsTableView reloadData];
        
        selectedVideoModal.hasCommentedOnVideo = YES;
    }
    TCEND
}

- (void)didFailToCommentVideoWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:commentsTableView];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    //    cmntTextView.text = @"";
    cmntTextView.text = cmntTextView.commentText;
    TCEND
}

- (void)refreshScreen {
    if ([appDelegate statusForNetworkConnectionWithOutMessage]) {
        pageNumber = 1;
        [self makeRequestBasedOnViewType:NO];
    } else {
        [commentsTableView reloadData];
    }

}
#pragma mark tableview datasource and Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (user.userId.intValue == appDelegate.loggedInUser.userId.intValue && user.totalNoOfPeningPrivateUsers.intValue > 0 && [viewType caseInsensitiveCompare:@"Private connections"] == NSOrderedSame) {
        return 2;
    } else {
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (user.userId.intValue == appDelegate.loggedInUser.userId.intValue && user.totalNoOfPeningPrivateUsers.intValue > 0 && [viewType caseInsensitiveCompare:@"Private connections"] == NSOrderedSame && section == 0) {
        return 1;
    } else {
        if(videoCmntsArray.count >= pageNumber * 10 && videoCmntsArray.count > 0) {
            return videoCmntsArray.count + 1;
        } else {
            return videoCmntsArray.count;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 1.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return [[UIView alloc] initWithFrame:CGRectZero];
 
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCSTART
    if (indexPath.row == videoCmntsArray.count) {
        return 40;
    } else {
        CGFloat heightOfTheRow = 50;
        if ([viewType caseInsensitiveCompare:@"comment"] == NSOrderedSame) {
            NSDictionary *commentDict = [videoCmntsArray objectAtIndex:indexPath.row];
            CGSize descptnSize = [[Base64Converter decodedString:[commentDict objectForKey:@"comment_text"]] sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:12] constrainedToSize:CGSizeMake(265, 2222) lineBreakMode:UILineBreakModeWordWrap];
            
            if (descptnSize.height > 20) {
                heightOfTheRow = 30 + descptnSize.height + 5;
            }
        }
        return heightOfTheRow;
    }
    TCEND
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        if (user.userId.intValue == appDelegate.loggedInUser.userId.intValue && user.totalNoOfPeningPrivateUsers.intValue > 0 && [viewType caseInsensitiveCompare:@"Private connections"] == NSOrderedSame && indexPath.section == 0) {
            
            //static NSString *user_messageCell = @"messageCell";
            static NSString *CellIndentifier = @"CommentUserCellID";
            
            CGFloat rowHeight = 50;
            
            CommentUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
            //initialize cell and its subviews instances once and use them when table scrolling through their instances retrieved based on "Tag" value
            if (cell == nil) {
                cell = [[CommentUserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIndentifier];
            }
            cell.deleteUserBtn.hidden = YES;
            cell.commentTextLbl.hidden = YES;
            cell.addUserBtn.hidden = YES;
            cell.userPicImgView.hidden = YES;
            
            cell.userNameLbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
            cell.userNameLbl.text = [NSString stringWithFormat:@"%d Private request%@ pending",[user.totalNoOfPeningPrivateUsers intValue],[appDelegate returningPluralFormWithCount:[user.totalNoOfPeningPrivateUsers intValue]]];
            cell.cellDividerLbl.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
             cell.userNameLbl.frame = CGRectMake(10, 4, 265, rowHeight - 8);
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
            return cell;
        } else {
            if(indexPath.row == videoCmntsArray.count) {
                UITableViewCell *indicatorCell;
                static NSString *loadMoreCellIdentifier = @"loadMoreCellIdentifier";
                UIActivityIndicatorView *activityIndicator_view = nil;
                indicatorCell = [tableView dequeueReusableCellWithIdentifier:loadMoreCellIdentifier];
                if(indicatorCell == nil){
                    indicatorCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadMoreCellIdentifier];
                    
                    activityIndicator_view = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    activityIndicator_view.frame = CGRectMake(300/2, 10, 20, 20);
                    [indicatorCell.contentView addSubview:activityIndicator_view];
                    activityIndicator_view.tag = -7000;
                    
                }
                if (!activityIndicator_view) {
                    activityIndicator_view = (UIActivityIndicatorView *)[indicatorCell.contentView viewWithTag:-7000];
                }
                [activityIndicator_view startAnimating];
                indicatorCell.backgroundColor = [UIColor clearColor];
                return indicatorCell;
            } else {
                
                //static NSString *user_messageCell = @"messageCell";
                static NSString *CellIndentifier = @"CommentUserCellID";
                
                CGFloat rowHeight = 50;
                
                CommentUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
                //initialize cell and its subviews instances once and use them when table scrolling through their instances retrieved based on "Tag" value
                if (cell == nil) {
                    cell = [[CommentUserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIndentifier];
                }
                cell.userPicImgView.hidden = NO;
                cell.deleteUserBtn.hidden = YES;
                cell.userPicImgView.layer.cornerRadius = 20.0f;
                cell.userPicImgView.layer.borderWidth = 1.5f;
                cell.userPicImgView.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
                cell.userPicImgView.layer.masksToBounds = YES;
                
                cell.userNameLbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
                
                cell.cellDividerLbl.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
                
                cell.commentTextLbl.textColor = [UIColor darkGrayColor];
                
                NSDictionary *commentDict = [videoCmntsArray objectAtIndex:indexPath.row];
                
                if ([viewType caseInsensitiveCompare:@"comment"] == NSOrderedSame) {
                    cell.commentTextLbl.hidden = NO;
                } else {
                    cell.commentTextLbl.hidden = YES;
                }
                
                if (([viewType caseInsensitiveCompare:@"Follower"] == NSOrderedSame || [viewType caseInsensitiveCompare:@"Following"] == NSOrderedSame) && [self isNotNull:[commentDict objectForKey:@"user_id"]] && [[commentDict objectForKey:@"user_id"] intValue] != appDelegate.loggedInUser.userId.intValue) {
                    cell.userNameLbl.frame = CGRectMake(50, 4, 225, 20);
                    if ([self isNotNull:[commentDict objectForKey:@"following"]]) {
                        cell.addUserBtn.hidden = NO;
                        [cell.addUserBtn addTarget:self action:@selector(userFollowOrUnfollow: withEvent:) forControlEvents:UIControlEventTouchUpInside];
                        if ([[commentDict objectForKey:@"following"] boolValue]) {
                            [cell.addUserBtn setImage:[UIImage imageNamed:@"Followed"] forState:UIControlStateNormal];
                        } else {
                            [cell.addUserBtn setImage:[UIImage imageNamed:@"AddSuggestedUser"] forState:UIControlStateNormal];
                        }
                    }
                    
                } else {
                    cell.addUserBtn.hidden = YES;
                    cell.userNameLbl.frame = CGRectMake(50, 4, 265, rowHeight - 8);
                }
                
                //check if Like data for a row is not null
                if ([self isNotNull:commentDict]) {
                    
                    if ([self isNotNull:[commentDict objectForKey:@"user_photo"]]) {
                        [cell.userPicImgView setImageWithURL:[NSURL URLWithString:[commentDict objectForKey:@"user_photo"]] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached];
                    } else if ([self isNotNull:[commentDict objectForKey:@"photo_path"]]) {
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
                        NSLog(@"Description size :%f",descptnSize.height);
                        cell.commentTextLbl.frame = CGRectMake(50, 25, 265, (descptnSize.height>20)?(descptnSize.height+5):23);
                        cell.userNameLbl.frame = CGRectMake(50, 4, 265, 20);
                    } else {
                        cell.commentTextLbl.text = @"";
                        cell.userNameLbl.frame = CGRectMake(50, 4, 265, rowHeight - 8);
                    }
                    
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor whiteColor];
                cell.accessoryType = UITableViewCellAccessoryNone;
                return cell;
            }
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        if (indexPath.row == videoCmntsArray.count && videoCmntsArray.count > 0) {
            [self performSelector:@selector(loadMoreRequest) withObject:nil afterDelay:0.001];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if (user.userId.intValue == appDelegate.loggedInUser.userId.intValue && user.totalNoOfPeningPrivateUsers.intValue > 0 && [viewType caseInsensitiveCompare:@"Private connections"] == NSOrderedSame && indexPath.section == 0) {
        PendingPrivateGroupViewController *pendingPrvtGroup = [[PendingPrivateGroupViewController alloc] initWithNibName:@"PendingPrivateGroupViewController" bundle:nil user:user];
        pendingPrvtGroup.allCmntsVC = self;
        [self.navigationController pushViewController:pendingPrvtGroup animated:YES];
    } else {
        if (indexPath.row < videoCmntsArray.count) {
            NSDictionary *commentDict = [videoCmntsArray objectAtIndex:indexPath.row];
            if ([self isNotNull:[commentDict objectForKey:@"user_id"]] && [[commentDict objectForKey:@"user_id"] intValue] != [appDelegate.loggedInUser.userId intValue]) {
                OthersPageViewController *otherPageVC = [[OthersPageViewController alloc] initWithNibName:@"OthersPageViewController" bundle:Nil andUser:[NSString stringWithFormat:@"%d",[[commentDict objectForKey:@"user_id"] intValue]]];
                [self.navigationController pushViewController:otherPageVC animated:YES];
                otherPageVC.caller = self;
                otherPageVC.selectedIndexPath = indexPath;
            }
        }
    }

    TCEND
}

- (void)unFollowedUserFromOtherPageViewControllerWithSelectedIndex:(NSIndexPath *)indexPath andUserId:(NSString *)userId {
    TCSTART
    if ( [viewType caseInsensitiveCompare:@"Following"] == NSOrderedSame && indexPath.row < videoCmntsArray.count) {
        [videoCmntsArray removeObjectAtIndex:indexPath.row];
        count = count - 1;
        [commentsTableView reloadData];
    }
    TCEND
}

#pragma mark Action sheet for follow unfollow
- (void)userFollowOrUnfollow:(id)sender  withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexpath = [appDelegate getIndexPathForEvent:event ofTableView:commentsTableView];
    NSDictionary *userDict = [videoCmntsArray objectAtIndex:indexpath.row];
    selectedUserIndexPath = indexpath;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:[userDict objectForKey:@"user_name"]
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:([[userDict objectForKey:@"following"] boolValue])?@"Unfollow":@"Follow", nil];
    //    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.backgroundColor = [UIColor whiteColor];
    [actionSheet showInView:appDelegate.window];
    
    
    TCEND
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	TCSTART
	NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSDictionary *userDict = [videoCmntsArray objectAtIndex:selectedUserIndexPath.row];
    
    if([buttonTitle caseInsensitiveCompare:@"Unfollow"] == NSOrderedSame) {
        [appDelegate makeUnFollowUserWithUserId:appDelegate.loggedInUser.userId followerId:[userDict objectForKey:@"user_id"] andCaller:self andIndexPath:selectedUserIndexPath];
    } else if([buttonTitle caseInsensitiveCompare:@"Follow"] == NSOrderedSame) {
        [appDelegate makeFollowUserWithUserId:appDelegate.loggedInUser.userId followerId:[userDict objectForKey:@"user_id"] andCaller:self andIndexPath:selectedUserIndexPath];
    }
	TCEND
}

- (void)didFinishedToUnFollowUser:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
//    [ShowAlert showAlert:@"Unfollowed successfully"];
    if ([self isNotNull:[results objectForKey:@"indexpath"]]) {
        NSIndexPath *indexPath = [results objectForKey:@"indexpath"];
        NSMutableDictionary *userDict = [videoCmntsArray objectAtIndex:indexPath.row];
        if ([viewType caseInsensitiveCompare:@"Following"] == NSOrderedSame && appDelegate.loggedInUser.userId.integerValue == user.userId.intValue) {
            [videoCmntsArray removeObject:userDict];
            [commentsTableView reloadData];
            count = videoCmntsArray.count;
            titleLabel.text = [NSString stringWithFormat:@"%d %@%@",count,viewType,[appDelegate returningPluralFormWithCount:count]];
        } else {
            [userDict setObject:[NSNumber numberWithBool:NO] forKey:@"following"];
            [videoCmntsArray replaceObjectAtIndex:indexPath.row withObject:userDict];
            [commentsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    
    NSInteger totalFollowings = [appDelegate.loggedInUser.totalNoOfFollowings integerValue];
    if (totalFollowings > 0) {
        totalFollowings = totalFollowings - 1;
    }
    appDelegate.loggedInUser.totalNoOfFollowings = [NSNumber numberWithInt:totalFollowings];
    
    TCEND
}

- (void)didFailToUnFollowUserWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

- (void)didFinishedToFollowUser:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
//    [ShowAlert showAlert:@"Followed successfully"];
    
    if ([self isNotNull:[results objectForKey:@"indexpath"]]) {
        NSIndexPath *indexPath = [results objectForKey:@"indexpath"];
        NSMutableDictionary *userDict = [videoCmntsArray objectAtIndex:indexPath.row];
        [userDict setObject:[NSNumber numberWithBool:YES] forKey:@"following"];
        [videoCmntsArray replaceObjectAtIndex:indexPath.row withObject:userDict];
        [commentsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    NSInteger totalFollowings = [appDelegate.loggedInUser.totalNoOfFollowings integerValue];
    totalFollowings = totalFollowings + 1;
    appDelegate.loggedInUser.totalNoOfFollowings = [NSNumber numberWithInt:totalFollowings];
    TCEND
}

- (void)didFailToFollowUserWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

#pragma mark tableview editing styles

- (IBAction)enterEditMode:(id)sender {
    
    if ([commentsTableView isEditing]) {
        [commentsTableView setEditing:NO animated:YES];
    } else {
        [commentsTableView setEditing:YES animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([viewType caseInsensitiveCompare:@"comment"] == NSOrderedSame) {
        return [self canDeleteCommentAtIndexPath:indexPath];
    } else if ([editBtn isHidden] || !commentsTableView.isEditing) {
        return NO;
    } else if (commentsTableView.isEditing && user.userId.intValue == appDelegate.loggedInUser.userId.intValue && user.totalNoOfPeningPrivateUsers.intValue > 0 && [viewType caseInsensitiveCompare:@"Private connections"] == NSOrderedSame && indexPath.section == 0) {
        return NO;
    }
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath {
    @try {
        return UITableViewCellEditingStyleDelete;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([viewType caseInsensitiveCompare:@"comment"] == NSOrderedSame) {
        return @"delete";
    }
    return @"unshare";
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)style
forRowAtIndexPath:(NSIndexPath*)indexPath {
    @try {
        if (style == UITableViewCellEditingStyleDelete) {
            if ([viewType caseInsensitiveCompare:@"comment"] == NSOrderedSame) {
                [self onClickOfCommentButtonAtIndexPath:indexPath];
            } else {
                [self makeUnPrivateRequestAtIndexPath:indexPath];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}
- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)makeUnPrivateRequestAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    NSDictionary *commentDict = [videoCmntsArray objectAtIndex:indexPath.row];
    if ([self isNotNull:[commentDict objectForKey:@"user_id"]]) {
        [appDelegate makeUnPrivateUserWithUserId:appDelegate.loggedInUser.userId privateUserId:[commentDict objectForKey:@"user_id"] andCaller:self andIndexPath:indexPath];
    }
    TCEND
}

- (void)didFinishedToUnPrivateUser:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    
    NSInteger totalPrivateUsers = [appDelegate.loggedInUser.totalNoOfPrivateUsers integerValue];
    if (totalPrivateUsers > 0) {
        totalPrivateUsers = totalPrivateUsers - 1;
    }
    appDelegate.loggedInUser.totalNoOfPrivateUsers = [NSNumber numberWithInt:totalPrivateUsers];
    NSIndexPath *indexPath = [results objectForKey:@"indexpath"];
    [videoCmntsArray removeObjectAtIndex:indexPath.row];
    [commentsTableView reloadData];
    
    count = videoCmntsArray.count;
    titleLabel.text = [NSString stringWithFormat:@"%d/150 %@",count,viewType];
    
    TCEND
}

- (void)didFailToUnPrivateUserWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

- (void)loadMoreRequest {
    pageNumber = pageNumber + 1;
    [self makeRequestBasedOnViewType:YES];
}

#pragma mark TextView Delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    @try {
        if (textView.textColor == [UIColor lightGrayColor]) {
            textView.text = @"";
            textView.textColor = [UIColor blackColor];
        }
        
        if ((cmtTextViewBg.frame.size.height + cmtTextViewBg.frame.origin.y) > (self.view.frame.size.height - KEYBOARD_PORTRAIT_HEIGHT)) {
            chatBarMovedHeight = (cmtTextViewBg.frame.size.height + cmtTextViewBg.frame.origin.y) - (self.view.frame.size.height - KEYBOARD_PORTRAIT_HEIGHT) - (([caller isKindOfClass:[CustomMoviePlayerViewController class]] || CURRENT_DEVICE_VERSION < 7.0)?0:-20);
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            
            [commentsTableView setFrame:CGRectMake(commentsTableView.frame.origin.x, COMMENTVIEW_TABLEORIGINY, commentsTableView.frame.size.width, commentsTableView.frame.size.height - (chatBarMovedHeight))];
            cmtTextViewBg.frame = CGRectMake(cmtTextViewBg.frame.origin.x, cmtTextViewBg.frame.origin.y - chatBarMovedHeight, cmtTextViewBg.frame.size.width, cmtTextViewBg.frame.size.height);
            //            cmntTextView.frame = CGRectMake(cmntTextView.frame.origin.x, cmntTextView.frame.origin.y - chatBarMovedHeight, cmntTextView.frame.size.width, cmntTextView.frame.size.height);
            [UIView commitAnimations];
            [self scrollToBottomAnimated:YES];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    
    @try {
        NSInteger comntsCount = [videoCmntsArray count];
        if (comntsCount > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:comntsCount-1 inSection:0];
            [commentsTableView scrollToRowAtIndexPath:indexPath
                                     atScrollPosition:UITableViewScrollPositionTop animated:animated];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
        
    }
}
- (void)textViewDidChange:(UITextView *) textView  {
    @try {
        
        if (textView.textColor == [UIColor blackColor]) {
            
        }
        
        if(textView.text.length == 0 && textView.textColor == [UIColor blackColor]) {
            textView.textColor = [UIColor lightGrayColor];
            textView.text = @"type your comment here";
            [textView setSelectedRange:NSMakeRange(0, 0)];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    TCSTART
    // Don't allow input beyond the char limit, other then backspace and cut
    if (textView.textColor == [UIColor lightGrayColor]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    
    if (textView.textColor == [UIColor blackColor] && [text  isEqualToString: @"@"]) {
        taggedTextStr = [[NSMutableString alloc] initWithString:text];
    }
    
    if ([text isEqualToString:@" "]) {
        [self removeTagUsersList];
    }
    
    if ([text isEqualToString:@""] && [self isNotNull:taggedTextStr]) {
        [taggedTextStr replaceCharactersInRange:NSMakeRange(taggedTextStr.length-1, 1) withString:@""];
        
    }
    
    if ([self isNotNull:taggedTextStr]) {
        if (![text isEqualToString:@"@"]) {
            [taggedTextStr appendString:text];
        }
        
        if ([self isNull:connectionsVC]) {
            connectionsVC = [[ConnectionsViewController alloc] initWithNibName:@"ConnectionsViewController" bundle:nil andFrame:CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height - chatBarMovedHeight - 90 - (([caller isKindOfClass:[CustomMoviePlayerViewController class]] || CURRENT_DEVICE_VERSION < 7.0)?0:20))];
            [self.view addSubview:connectionsVC.view];
            connectionsVC.caller = self;
        }
        [connectionsVC makeRequestForTagCommentUsersWithText:taggedTextStr];
    } else {
        [self removeTagUsersList];
    }
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
    TCEND
}

- (void)removeTagUsersList {
    taggedTextStr = nil;
    [connectionsVC.view removeFromSuperview];
    connectionsVC = nil;
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    TCSTART
    if(textView.text.length == 0 && textView.textColor == [UIColor blackColor]) {
        textView.textColor = [UIColor lightGrayColor];
        textView.text = @"type your comment here";
        [textView setSelectedRange:NSMakeRange(0, 0)];
    }
    if (textView.textColor == [UIColor blackColor] && textView.text.length > 0) {
        cmntTextView.commentText = textView.text;
    }
    [self rearrangeTable];
    [self removeTagUsersList];
    TCEND
}

- (void)dismissKeyboard:(id)sender {
    @try {
        
        if ([cmntTextView isFirstResponder]){
            [cmntTextView resignFirstResponder];
            [self rearrangeTable];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}
- (void)rearrangeTable {
    TCSTART
    if ([cmntTextView resignFirstResponder]) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [commentsTableView setFrame:CGRectMake(commentsTableView.frame.origin.x, COMMENTVIEW_TABLEORIGINY, commentsTableView.frame.size.width, commentsTableView.frame.size.height + chatBarMovedHeight)];
        cmtTextViewBg.frame = CGRectMake(cmtTextViewBg.frame.origin.x, cmtTextViewBg.frame.origin.y + chatBarMovedHeight, cmtTextViewBg.frame.size.width, cmtTextViewBg.frame.size.height);
        [UIView commitAnimations];
    }
    TCEND
}

- (void)taggedUserDict:(NSDictionary *)userDict {
    TCSTART
    NSString *cmntText = cmntTextView.text;
    NSString *newCmntText = [cmntText stringByReplacingOccurrencesOfString:taggedTextStr withString:[userDict objectForKey:@"user_name"]];
    cmntTextView.text = newCmntText;
    [self removeTagUsersList];
    TCEND
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
