/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "TrendsDetailsViewController.h"
#import "MyPageVideoCell.h"
#import "OthersPageViewController.h"
#import "CustomMoviePlayerViewController.h"
#import "ShareViewController.h"
#import "AccessPermissionsViewController.h"
#import "ReportVideoViewController.h"

@interface TrendsDetailsViewController () {
    CustomMoviePlayerViewController *customMoviePlayerVC;
}

@end

@implementation TrendsDetailsViewController
@synthesize caller;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil SelectedTagName:(NSString *)tagName_
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        tagName = tagName_;
    }
    return self;
}

- (void)viewDidLoad
{
    TCSTART
    [super viewDidLoad];
    displayTrendsArray = [[NSMutableArray alloc] init];
    pageNumber = 1;
    titleLabel.text = tagName;
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height - 20);
    [trendsTableView registerNib:[UINib nibWithNibName:@"MyPageVideoCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MyPageVideoCellID"];
    trendsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self makeTrendsDetailsRequestforPagination:NO andPageNumber:1];
    TCEND
}

- (void)makeTrendsDetailsRequestforPagination:(BOOL)requestForPagination andPageNumber:(NSInteger) pgNum {
    TCSTART
    [appDelegate makeRequestForTrendsDetailsWithPageNumber:pgNum andTagName:tagName andCaller:self];
    if (!requestForPagination) {
        [appDelegate showActivityIndicatorInView:trendsTableView andText:@""];
    }
    [appDelegate showNetworkIndicator];
    TCEND
}

- (void)didFinishedToGetBrowseDetails:(NSDictionary *)results {
    TCSTART
    
    if ([self isNotNull:[results objectForKey:@"pagenumber"]] && [[results objectForKey:@"pagenumber"] integerValue] == 1) {
        [displayTrendsArray removeAllObjects];
    }
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"results"]]) {
        [displayTrendsArray addObjectsFromArray:[results objectForKey:@"results"]];
    }
    for (VideoModal *videoModal in displayTrendsArray) {
        [appDelegate moveLoggedInUserToTopInLikesListOfVideoModal:videoModal];
    }
    [appDelegate removeNetworkIndicatorInView:trendsTableView];
    [appDelegate hideNetworkIndicator];
    [trendsTableView reloadData];
    TCEND
}
- (void)didFailToGetBrowseDetailsWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate removeNetworkIndicatorInView:trendsTableView];
    [appDelegate hideNetworkIndicator];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

//For status bar in ios7
- (void) viewDidLayoutSubviews {
    if (CURRENT_DEVICE_VERSION >= 7.0  && self.view.frame.size.height == appDelegate.window.frame.size.height) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.size.height = viewBounds.size.height - topBarOffset;
        self.view.frame = CGRectMake(viewBounds.origin.x, topBarOffset, viewBounds.size.width, viewBounds.size.height);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (IBAction)goBack:(id)sender {
    TCSTART
    if ([self isNotNull:caller]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    TCEND
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)moveLoggedInUserToFirstIndexOfVideoList {
    TCSTART
    for (VideoModal *videoModal in displayTrendsArray) {
        [appDelegate moveLoggedInUserToTopInLikesListOfVideoModal:videoModal];
    }
    [trendsTableView reloadData];
    TCEND
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Tableview Delegate and Datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(displayTrendsArray.count >=  pageNumber * 10 && displayTrendsArray.count > 0) {
        return displayTrendsArray.count + 1;
    } else {
        return displayTrendsArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == displayTrendsArray.count) {
        return 40;
    }
    return [self getHeightOfRowInSection:indexPath];
}

- (CGFloat)getHeightOfRowInSection:(NSIndexPath *)indexPath {
    TCSTART
    if (indexPath.section == 0) {
        VideoModal *video = [displayTrendsArray objectAtIndex:indexPath.row];
        CGFloat height;
        if ([self isNotNull:video]) {
            if (video.numberOfCmnts.integerValue <= 0 && video.numberOfLikes.integerValue <= 0 && video.numberOfTags.integerValue <= 0) {
                return 186 + 20 + 3; // 20 for gap between options tab and line
            }
            height = 186 + 30 + 20 + 3; // 20 for gap between options tab and line
        }
        if ([video.numberOfLikes integerValue] <= 0 && [video.numberOfCmnts integerValue] <= 0) {
            return height;
        } else {
            height =  height + (([video.numberOfLikes integerValue] > 0)?25:0);
            if ([video.numberOfCmnts integerValue] > 0) {
                height = height + [self getCommentViewHeightForVideoModal:video];
            }
            return height;
        }
    }
    TCEND
}

- (CGFloat)getCommentViewHeightForVideoModal:(VideoModal *)video {
    TCSTART
    int count = 0;
    CGFloat totalHeight = 0;
    if (video.comments.count > 1) {
        count = 2;
    } else {
        count = 1;
    }
    for (int i = 0; i < count; i ++) {
        NSDictionary *dict;
        if (i < [video.comments count]) {
            dict = [video.comments objectAtIndex:i];
        }
        NSString *name;
        if ([self isNotNull:[dict objectForKey:@"user_id"]] && [[dict objectForKey:@"user_id"] intValue] == appDelegate.loggedInUser.userId.intValue) {
            name = @"You:";
        } else {
            name = [NSString stringWithFormat:@"%@:",[dict objectForKey:@"user_name"]];
        }
        
        CGSize btnSize = [name sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:13.0] constrainedToSize:CGSizeMake(270, 25) lineBreakMode:NSLineBreakByTruncatingMiddle];
        
        
        NSString *cmnt = [Base64Converter decodedString:[dict objectForKey:@"comment_text"]];
        CGSize cmntSize = [cmnt sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:13.0] constrainedToSize:CGSizeMake((285-btnSize.width), 38)];
        
        totalHeight = totalHeight + ((cmntSize.height < 25)?25:38);
    }
    return totalHeight;
    TCEND
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if(indexPath.row == displayTrendsArray.count) {
        UITableViewCell *indicatorCell;
        static NSString *loadMoreCellIdentifier = @"loadMoreCellIdentifier";
        UIActivityIndicatorView *activityIndicator_view = nil;
        indicatorCell = [tableView dequeueReusableCellWithIdentifier:loadMoreCellIdentifier];
        if(indicatorCell == nil){
            indicatorCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadMoreCellIdentifier];
            
            activityIndicator_view = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityIndicator_view.frame = CGRectMake((320 - 20)/2, 10, 20, 20);
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
        
        static NSString *cellIdentifier = @"MyPageVideoCellID";
        
        MyPageVideoCell *cell = (MyPageVideoCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil) {
            cell = [[MyPageVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell.videoTitleLbl.hidden = YES;
        cell.videosViewsLbl.hidden = YES;
        cell.viewsLbl.hidden = YES;
        cell.videoCreatedLbl.hidden = YES;
        cell.videoDisplayTimeLbl.hidden = YES;
        
        VideoModal *video = [displayTrendsArray objectAtIndex:indexPath.row];
        
        cell.tagsViewBgLbl.backgroundColor = [appDelegate colorWithHexString:@"fafafa"];
        
        
        [cell.videoPlayBtn addTarget:self action:@selector(playVideo: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        //Likes
        [cell.likesBtn addTarget:self action:@selector(onClickOfGetAllVideoUsersLoved: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        cell.numberOfLikesLbl.text =  [NSString stringWithFormat:@"%@ Like%@",[appDelegate getUserStatisticsFormatedString:[video.numberOfLikes longLongValue]],[appDelegate returningPluralFormWithCountForLikes:[video.numberOfLikes integerValue]]];
        
        //Comments
        [cell.commentsBtn addTarget:self action:@selector(seeAllCommentsOfVideo: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        cell.numberofCmntsLbl.text = [NSString stringWithFormat:@"%@ Comment%@",[appDelegate getUserStatisticsFormatedString:[video.numberOfCmnts longLongValue]],[appDelegate returningPluralFormWithCount:[video.numberOfCmnts integerValue]]];
        
        //Tags
        cell.numberOfTagsLbl.text = [NSString stringWithFormat:@"%@ Tag%@",[appDelegate getUserStatisticsFormatedString:[video.numberOfTags longLongValue]],[appDelegate returningPluralFormWithCount:[video.numberOfTags integerValue]]];
        
       
        
        NSString *tagExpreStr;
        if ([self isNotNull:video.latestTagExpression]) {
            tagExpreStr = video.latestTagExpression;
        } else {
            tagExpreStr = video.title;
        }
        
        cell.latestTagLbl.text = tagExpreStr;
        cell.latestTagLbl.frame = CGRectMake(0, cell.latestTagLbl.frame.origin.y, 320, cell.latestTagLbl.frame.size.height);
        
        // userphoto
        if ([self isNotNull:video.userPhoto]) {
            [cell.userProfileImgView setImageWithURL:[NSURL URLWithString:video.userPhoto] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached];
        } else {
            cell.userProfileImgView.image = [UIImage imageNamed:@"OwnerPic"];
        }
        
        cell.userProfileImgView.layer.cornerRadius = 17.5;
        cell.userProfileImgView.layer.borderWidth = 1.5f;
        cell.userProfileImgView.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
        cell.userProfileImgView.layer.masksToBounds = YES;
        
        // username
        if ([self isNotNull:video.userName]) {
            cell.userNameLbel.text = video.userName;
        } else {
            cell.userNameLbel.text = @"";
        }
        if ([self isNotNull:video.userId]) {
            cell.userPicBtn.hidden = NO;
            cell.userPicBtn.tag = [video.userId intValue];
            [cell.userPicBtn addTarget:self action:@selector(onClickOfUserNameBtn:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            cell.userPicBtn.hidden = YES;
        }
       
        //Video display time
        if ([self isNotNull:video.creationTime]) {
            cell.videoFeedDisplayTimeLbl.text = [appDelegate relativeDateString:video.creationTime];
        } else {
            cell.videoFeedDisplayTimeLbl.text = @"";
        }
        
        // Video thumb
        [cell.videoBgImgView setImageWithURL:[NSURL URLWithString:video.videoThumbPath] placeholderImage:[UIImage imageNamed:@"DefaultVideoThumb"] ];
        
        cell.dividerLbl.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
        
        [self setVisibilityForTagsCommentsAndLovedForCell:cell atVideo:video];
        [self addLovedPersonsViewWithIndexPath:indexPath toCell:cell];
        
        [self addCommentViewToTheCell:cell andIndexPath:indexPath];
        
        if (video.hasLovedVideo) {
            [cell.likeBtn setImage:[UIImage imageNamed:@"OptionLoved"] forState:UIControlStateNormal];
        } else {
            [cell.likeBtn setImage:[UIImage imageNamed:@"OptionUnLoved"] forState:UIControlStateNormal];
        }
        
        if (video.hasCommentedOnVideo) {
            [cell.commentBtn setImage:[UIImage imageNamed:@"OptionCmnt"] forState:UIControlStateNormal];
        } else {
            [cell.commentBtn setImage:[UIImage imageNamed:@"OptionUnCmnt"] forState:UIControlStateNormal];
        }
        
        //options view
        CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
        //        NSLog(@"Row height:%f",cellRect.size.height);
        cell.optionsView.frame = CGRectMake(cell.optionsView.frame.origin.x, cellRect.size.height - 48, cell.optionsView.frame.size.width, cell.optionsView.frame.size.height);
        
        [cell.commentBtn addTarget:self action:@selector(seeAllCommentsOfVideo: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        [cell.likeBtn addTarget:self action:@selector(onClickOfLikeBtn: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        [cell.optionsBtn setTitleColor:[appDelegate colorWithHexString:@"11a3e7"] forState:UIControlStateNormal];
        [cell.optionsBtn addTarget:self action:@selector(onClickOfOptionsBtn: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    TCEND
}

- (void)setVisibilityForTagsCommentsAndLovedForCell:(MyPageVideoCell *)cell atVideo:(VideoModal *)video {
    TCSTART
    cell.tagsViewsBg.hidden = NO;
    cell.tagsViewBgLbl.hidden = NO;
    cell.tagsView.hidden = NO;
    cell.likesView.hidden = NO;
    cell.commentsView.hidden = NO;
    cell.tagsView.frame = CGRectMake(0, 0, 65, 30);
    cell.likesView.frame = CGRectMake(65, 0, 75, 30);
    cell.commentsView.frame = CGRectMake(140, 0, 100, 30);
    if (video.numberOfTags.integerValue <= 0 && video.numberOfCmnts.integerValue <= 0  && video.numberOfLikes.integerValue <= 0) {
        cell.tagsViewsBg.hidden = YES;
        cell.tagsViewBgLbl.hidden = YES;
    } else {
        CGFloat tagsViewBgWidth = cell.tagsView.frame.size.width + cell.likesView.frame.size.width + cell.commentsView.frame.size.width;
        if (video.numberOfTags.integerValue <= 0) {
            tagsViewBgWidth = tagsViewBgWidth - cell.tagsView.frame.size.width;
            cell.tagsView.hidden = YES;
            cell.tagsView.frame = CGRectMake(0, 0, 0, 30);
        }
        
        if (video.numberOfLikes.integerValue <= 0) {
            tagsViewBgWidth = tagsViewBgWidth - cell.likesView.frame.size.width;
            cell.likesView.hidden = YES;
            cell.likesView.frame = CGRectMake(cell.tagsView.frame.origin.x + cell.tagsView.frame.size.width, 0, 0, 30);
        } else {
            cell.likesView.frame = CGRectMake(cell.tagsView.frame.origin.x + cell.tagsView.frame.size.width, 0, 75, 30);
        }
        
        if (video.numberOfCmnts.integerValue <= 0) {
            tagsViewBgWidth = tagsViewBgWidth - cell.commentsView.frame.size.width;
            cell.commentsView.hidden = YES;
            //            cell.commentsView.frame = CGRectMake(127, 0, 85, 30);
            cell.commentsView.frame = CGRectMake(cell.likesView.frame.origin.x + cell.likesView.frame.size.width, 0, 0, 30);
        } else {
            cell.commentsView.frame = CGRectMake(cell.likesView.frame.origin.x + cell.likesView.frame.size.width, 0, 100, 30);
        }
        
        cell.tagsViewsBg.frame = CGRectMake((320-tagsViewBgWidth)/2, 160, tagsViewBgWidth, 30);
    }
    TCEND
}
- (void)addLovedPersonsViewWithIndexPath:(NSIndexPath *)indexPath toCell:(MyPageVideoCell *)cell {
    TCSTART
    VideoModal *video = [displayTrendsArray objectAtIndex:indexPath.row];
    cell.lovedPersonsView.backgroundColor = [UIColor clearColor];
    cell.lovedPersonsView.hidden = NO;
    cell.lovedPerson2.hidden = NO;
    cell.seeAllLovedBtn.hidden = NO;
    CGFloat totalWidth = 30.0;
    CGFloat buttonWidth;
    if ([self isNotNull:video.likesList] && video.likesList.count > 0 && [video.numberOfLikes integerValue] > 0) {
        for (int i = 0 ; i < 2; i++) {
            NSDictionary *dict;
            UIButton *lovedPersonBtn = nil;
            if (i < [video.likesList count]) {
                dict = [video.likesList objectAtIndex:i];
            }
            NSString *name;
            if (i == 0 && [self isNotNull:[dict objectForKey:@"user_id"]] && [[dict objectForKey:@"user_id"] intValue] == appDelegate.loggedInUser.userId.intValue) {
                name = @"You";
            } else {
                name = [dict objectForKey:@"user_name"];
            }
            
            if (i == 0 && [video.likesList count] > 1) {
                name = [NSString stringWithFormat:@"%@, ",name];
            }
            
            if (i == 0) {
                lovedPersonBtn = (UIButton *)cell.lovedPerson1;
            } else {
                lovedPersonBtn = (UIButton *)cell.lovedPerson2;
            }
            
            if (i == 0 && [video.likesList count] == 1) {
                cell.lovedPerson2.hidden = YES;
                buttonWidth = 300;
                //                lovedPersonBtn.frame = CGRectMake(totalWidth, 0, 300, 25);
                //                totalWidth = 320;
            } else {
                if ([video.numberOfLikes integerValue] == 2) {
                    buttonWidth = 150;
                } else {
                    buttonWidth = 85;
                }
            }
            
            CGSize btnSize = [name sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:13.0] constrainedToSize:CGSizeMake(buttonWidth, 25) lineBreakMode:NSLineBreakByTruncatingMiddle];
            lovedPersonBtn.frame = CGRectMake(totalWidth, 0, btnSize.width, 25);
            totalWidth = totalWidth + btnSize.width;
            
            lovedPersonBtn.tag = [[dict objectForKey:@"user_id"] integerValue];
            
            [lovedPersonBtn addTarget:self action:@selector(onClickOfUserNameBtn:) forControlEvents:UIControlEventTouchUpInside];
            
            [lovedPersonBtn setTitle:name forState:UIControlStateNormal];
            [lovedPersonBtn setTitleColor:[appDelegate colorWithHexString:@"11a3e7"] forState:UIControlStateNormal];
        }
        
        if ([video.numberOfLikes integerValue] > 2) {
            [cell.seeAllLovedBtn setTitleColor:[appDelegate colorWithHexString:@"11a3e7"] forState:UIControlStateNormal];
            NSString *name = [NSString stringWithFormat:@" and %@ Other%@ Liked",[appDelegate getUserStatisticsFormatedString:([video.numberOfLikes longLongValue] - 2)],[appDelegate returningPluralFormWithCount:([video.numberOfLikes integerValue] - 2)]];
            CGSize nameSize = [name sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:13.0] constrainedToSize:CGSizeMake(120, 25)];
            [cell.seeAllLovedBtn setTitle:name forState:UIControlStateNormal];
            [cell.seeAllLovedBtn addTarget:self action:@selector(onClickOfGetAllVideoUsersLoved: withEvent:) forControlEvents:UIControlEventTouchUpInside];
            cell.seeAllLovedBtn.frame = CGRectMake(totalWidth, 0, nameSize.width, 25);
            totalWidth = totalWidth + nameSize.width;
        } else {
            cell.seeAllLovedBtn.hidden = YES;
        }
        cell.lovedPersonsView.frame = CGRectMake(0, 190, totalWidth, 25);
    } else {
        cell.lovedPersonsView.frame = CGRectMake(0, 0, 0, 0);
        cell.lovedPersonsView.hidden = YES;
    }
    
    TCEND
}

- (void) addCommentViewToTheCell:(MyPageVideoCell *)cell andIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    VideoModal *video = [displayTrendsArray objectAtIndex:indexPath.row];
    cell.allCommentsView.backgroundColor = [UIColor clearColor];
    cell.allCommentsView.hidden = NO;
    cell.commentor2View.hidden = NO;
    //    cell.seeAllComments.hidden = NO;
    
    CGFloat totalHeight = 0.0;
    if ([self isNotNull:video.comments] && video.comments.count > 0 && video.numberOfCmnts.integerValue > 0 ) {
        for (int i = 0 ; i < 2; i++) {
            
            CGFloat totalWidth = 0.0;
            NSDictionary *dict;
            UIButton *commentorBtn = nil;
            UILabel *commentText = nil;
            UIView *commentorView = nil;
            
            if (i < [video.comments count]) {
                dict = [video.comments objectAtIndex:i];
            }
            
            if (i == 0) {
                commentorBtn = (UIButton *)cell.commentor1;
                commentText = (UILabel *)cell.commentText1;
                commentorView = (UIView *)cell.commentor1View;
            } else {
                commentorBtn = (UIButton *)cell.commentor2;
                commentText = (UILabel *)cell.commentText2;
                commentorView = (UIView *)cell.commentor2View;
            }
            
            if (i == 0 && [video.comments count] == 1) {
                cell.commentor2View.hidden = YES;
            }
            
            commentorBtn.tag = [[dict objectForKey:@"user_id"] integerValue];
            [commentorBtn addTarget:self action:@selector(onClickOfUserNameBtn:) forControlEvents:UIControlEventTouchUpInside];
            
            NSString *name;
            if ([self isNotNull:[dict objectForKey:@"user_id"]] && [[dict objectForKey:@"user_id"] intValue] == appDelegate.loggedInUser.userId.intValue) {
                name = @"You:";
            } else {
                name = [NSString stringWithFormat:@"%@:",[dict objectForKey:@"user_name"]];
            }
            
            CGSize btnSize = [name sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:13.0] constrainedToSize:CGSizeMake(270, 25) lineBreakMode:NSLineBreakByTruncatingMiddle];
            commentorBtn.frame = CGRectMake(0, 0, btnSize.width, 25);
            [commentorBtn setTitle:name forState:UIControlStateNormal];
            [commentorBtn setTitleColor:[appDelegate colorWithHexString:@"11a3e7"] forState:UIControlStateNormal];
            
            totalWidth = totalWidth + btnSize.width;
            
            commentText.textColor = [UIColor darkGrayColor];
            NSString *cmnt = [Base64Converter decodedString:[dict objectForKey:@"comment_text"]];
            
            CGSize cmntSize = [cmnt sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:13.0] constrainedToSize:CGSizeMake((285-btnSize.width), 38)];
            commentText.text = cmnt;
            commentText.frame = CGRectMake(totalWidth + 3, 0, cmntSize.width, (cmntSize.height < 25)?25:38);
            
            totalWidth = totalWidth + cmntSize.width;
            commentorView.frame = CGRectMake(30, totalHeight, totalWidth, (cmntSize.height < 25)?25:38);
            totalHeight = totalHeight + ((cmntSize.height < 25)?25:38);
        }
        cell.allCommentsView.frame = CGRectMake(0, ([video.likesList count] > 0)?215:190, 320, totalHeight);
    } else {
        cell.allCommentsView.frame = CGRectMake(0, 0, 0, 0);
        cell.allCommentsView.hidden = YES;
    }
    TCEND
}

- (void) onClickOfUserNameBtn:(id)sender {
    TCSTART
    UIButton *userNameBtn = (UIButton *)sender;
    if (userNameBtn.tag != [appDelegate.loggedInUser.userId integerValue]) {
        OthersPageViewController *otherPageVC = [[OthersPageViewController alloc] initWithNibName:@"OthersPageViewController" bundle:Nil andUser:[NSString stringWithFormat:@"%d",userNameBtn.tag]];
        [self.navigationController pushViewController:otherPageVC animated:YES];
    }
    TCEND
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    //    MyPageVideoDetailsViewController *detailsVC = [[MyPageVideoDetailsViewController alloc] initWithNibName:@"MyPageVideoDetailsViewController" bundle:Nil];
    //    [mainVC.navigationController pushViewController:detailsVC animated:YES];
    TCEND
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        if (indexPath.row == displayTrendsArray.count) {
            [self performSelector:@selector(loadMoreTrends) withObject:nil afterDelay:0.001];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)loadMoreTrends {
    pageNumber = pageNumber + 1;
    [self makeTrendsDetailsRequestforPagination:YES andPageNumber:pageNumber];
}

#pragma mark optionsView
- (void)onClickOfOptionsBtn:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    //    [ShowAlert showAlert:@"In Development"];
    selectedIndexPath = [appDelegate getIndexPathForEvent:event ofTableView:trendsTableView];
    VideoModal *video = [displayTrendsArray objectAtIndex:selectedIndexPath.row];
    UIActionSheet *actionSheet;
    
    if ([self isNotNull:video.userId] && video.userId.integerValue == appDelegate.loggedInUser.userId.integerValue) {
        
        actionSheet = [[UIActionSheet alloc]
                       initWithTitle:nil
                       delegate:self
                       cancelButtonTitle:@"Cancel"
                       destructiveButtonTitle:nil
                       otherButtonTitles:@"Delete",@"Access Permission",@"Share Video",@"Copy Share URL",@"Tag", nil];
    } else {
        actionSheet = [[UIActionSheet alloc]
                       initWithTitle:nil
                       delegate:self
                       cancelButtonTitle:@"Cancel"
                       destructiveButtonTitle:nil
                       otherButtonTitles:@"Report Inappropriate",@"Share Video",@"Copy Share URL", nil];
    }
    actionSheet.backgroundColor = [UIColor whiteColor];
    [actionSheet showInView:appDelegate.window];
    TCEND
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	TCSTART
	NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([buttonTitle caseInsensitiveCompare:@"Report Inappropriate"] == NSOrderedSame) {
        [self reportVideoAtIndexPath:selectedIndexPath];
    } else if([buttonTitle caseInsensitiveCompare:@"Access Permission"] == NSOrderedSame) {
        [self accessPermissionOfVideoAtIndexPath:selectedIndexPath];
    } else if([buttonTitle caseInsensitiveCompare:@"Share Video"] == NSOrderedSame) {
        [self shareVideoAtIndexPath:selectedIndexPath];
    } else if([buttonTitle caseInsensitiveCompare:@"Copy Share URL"] == NSOrderedSame) {
        VideoModal *video = [displayTrendsArray objectAtIndex:selectedIndexPath.row];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = video.shareUrl;
    } else if([buttonTitle caseInsensitiveCompare:@"Tag"] == NSOrderedSame) {
        [self gotoPlayerScreenWithIndexPath:selectedIndexPath];
    } else if([buttonTitle caseInsensitiveCompare:@"Delete"] == NSOrderedSame) {
        [self deleteVideoAtIndexPAth:selectedIndexPath];
    }
	TCEND
}


- (void)deleteVideoAtIndexPAth:(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [displayTrendsArray objectAtIndex:indexPath.row];
        if ([self isNotNull:video]) {
            [appDelegate showActivityIndicatorInView:self.view andText:@"Deleting"];
            [appDelegate showNetworkIndicator];
            [appDelegate makeRequestForDeleteVideoWithVideoId:video.videoId andUserId:appDelegate.loggedInUser.userId andCaller:self atIndexpath:indexPath];
        }
    }
    TCEND
}
- (void)didFinishedDeleteVideo:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:self.view];
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"indexpath"]]) {
        
        NSIndexPath *indexPath = [results objectForKey:@"indexpath"];
        [displayTrendsArray removeObjectAtIndex:indexPath.row];
        
        NSInteger numberOfVideos = [appDelegate.loggedInUser.totalNoOfVideos intValue];
        numberOfVideos = numberOfVideos - 1;
        appDelegate.loggedInUser.totalNoOfVideos = [NSNumber numberWithInt:numberOfVideos];
        
        [trendsTableView reloadData];
    }
    TCEND
}
- (void)didFailedDeleteVideoWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:self.view];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

#pragma mark Goto Shareviewcontroller
- (void)accessPermissionOfVideoAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [displayTrendsArray objectAtIndex:indexPath.row];
        if ([self isNotNull:video]) {
            AccessPermissionsViewController *permissionsVC = [[AccessPermissionsViewController alloc] initWithNibName:@"AccessPermissionsViewController" bundle:nil withSelectedVideo:video andCaller:self];
            [self.navigationController pushViewController:permissionsVC animated:YES];
        }
    }
    TCEND
}

#pragma mark Goto Shareviewcontroller
- (void)shareVideoAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [displayTrendsArray objectAtIndex:indexPath.row];
        if ([self isNotNull:video]) {
            ShareViewController *shareVC = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil withSelectedVideo:video andCaller:self];
            [self.navigationController pushViewController:shareVC animated:YES];
        }
    }
    TCEND
}

#pragma mark Report Video Delegate methods
- (void)reportVideoAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [displayTrendsArray objectAtIndex:indexPath.row];
        if ([self isNotNull:video]) {
            ReportVideoViewController *reportVC = [[ReportVideoViewController alloc] initWithNibName:@"ReportVideoViewController" bundle:nil forVideo:video.videoId];
            [self presentViewController:reportVC animated:YES completion:nil];
        }
    }
    TCEND
}

#pragma mark Get All Likes Delegate Methods
- (void)onClickOfGetAllVideoUsersLoved:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:trendsTableView];
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [displayTrendsArray objectAtIndex:indexPath.row];
        if ([self isNotNull:video]) {
            [self gotoAllCommentsScreenWithVideo:video andSelectedIndexPath:indexPath andType:@"Like"];
        }
    }
    TCEND
}

#pragma mark
#pragma mark Like Video Delegate Methods
-(IBAction)onClickOfLikeBtn:(id)sender  withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:trendsTableView];
    UIButton *likeBtn = (UIButton *)sender;
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [displayTrendsArray objectAtIndex:indexPath.row];
        if (likeBtn.currentImage == [UIImage imageNamed:@"OptionUnLoved"]) {
            NSLog(@"unlovedImage");
            [appDelegate makeRequestForLikeVideoWithVideoId:video.videoId andCaller:self andIndexPaht:indexPath];
        } else {
            NSLog(@"loved image");
            [appDelegate makeRequestForUnLikeVideoWithVideoId:video.videoId andCaller:self andIndexPaht:indexPath];
        }
    }
    TCEND
}

- (void)didFinishedLikeVideo:(NSDictionary *)results {
    TCSTART
    
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    if ([self isNotNull:[results objectForKey:@"indexpath"]]) {
        NSIndexPath *indexpath = [results objectForKey:@"indexpath"];
        VideoModal *video = [displayTrendsArray objectAtIndex:indexpath.row];
        NSInteger likesCount = [video.numberOfLikes integerValue];
        likesCount = likesCount + 1;
        video.numberOfLikes = [NSNumber numberWithInteger:likesCount];
        
        NSMutableArray *likeList = [[NSMutableArray alloc] initWithArray:video.likesList];
        [likeList insertObject:[NSDictionary dictionaryWithObjectsAndKeys:appDelegate.loggedInUser.userId,@"user_id",appDelegate.loggedInUser.userName?:@"",@"user_name", nil] atIndex:0];
        video.likesList = likeList;
        video.hasLovedVideo = YES;
        
        [trendsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexpath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    TCEND
}
- (void)didFailedLikeVideoWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

//unliked
- (void)didFinishedUnLikeVideo:(NSDictionary *)results {
    TCSTART
    
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    if ([self isNotNull:[results objectForKey:@"indexpath"]]) {
        NSIndexPath *indexpath = [results objectForKey:@"indexpath"];
        VideoModal *video = [displayTrendsArray objectAtIndex:indexpath.row];
        NSInteger likesCount = [video.numberOfLikes integerValue];
        likesCount = likesCount - 1;
        video.numberOfLikes = [NSNumber numberWithInteger:likesCount];
        
        NSMutableArray *likeList = [[NSMutableArray alloc] initWithArray:video.likesList];
        for (NSDictionary *userDict in likeList) {
            if ([self isNotNull:[userDict objectForKey:@"user_id"]] && [[userDict objectForKey:@"user_id"] intValue] == appDelegate.loggedInUser.userId.intValue) {
                [likeList removeObject:userDict];
                break;
            }
        }
        //        [likeList insertObject:[NSDictionary dictionaryWithObjectsAndKeys:appDelegate.loggedInUser.userId,@"user_id",appDelegate.loggedInUser.userName?:@"",@"user_name", nil] atIndex:0];
        video.likesList = likeList;
        video.hasLovedVideo = NO;
        
        [trendsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexpath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    TCEND
}
- (void)didFailedUnLikeVideoWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

#pragma mark Get All Comments Delegate methods
- (void)seeAllCommentsOfVideo:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:trendsTableView];
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [displayTrendsArray objectAtIndex:indexPath.row];
        if ([self isNotNull:video]) {
            [self gotoAllCommentsScreenWithVideo:video andSelectedIndexPath:indexPath andType:@"Comment"];
        }
    }
    TCEND
}

- (void)gotoAllCommentsScreenWithVideo:(VideoModal *)video andSelectedIndexPath:(NSIndexPath *)indexPath andType:(NSString *)type {
    TCSTART
    NSInteger count;
    if ([type caseInsensitiveCompare:@"Comment"] == NSOrderedSame) {
        count = [video.numberOfCmnts integerValue];
        appDelegate.videoFeedVC.mainVC.customTabView.hidden = YES;
    } else {
        count = [video.numberOfLikes integerValue];
    }
    
    allCmntsVC = [[AllCommentsViewController alloc] initWithNibName:@"AllCommentsViewController" bundle:nil withVideoModal:video user:nil viewType:type andSelectedIndexPath:indexPath andTotalCount:count andCaller:self];
    if ([type caseInsensitiveCompare:@"Comment"] == NSOrderedSame) {
        [appDelegate.videoFeedVC.mainVC.navigationController pushViewController:allCmntsVC animated:YES];
    } else {
        [self.navigationController pushViewController:allCmntsVC animated:YES];
    }
    
    
    TCEND
}

- (void)allCommentsScreenDismissCalledSelectedIndexPath:(NSIndexPath *)indexPath andViewType:(NSString *)viewType {
    TCSTART
    if ([self isNotNull:indexPath]) {
        if ([viewType caseInsensitiveCompare:@"Like"] == NSOrderedSame) {
            VideoModal *video = [displayTrendsArray objectAtIndex:indexPath.row];
            [appDelegate moveLoggedInUserToTopInLikesListOfVideoModal:video];
        }
        [trendsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    appDelegate.videoFeedVC.mainVC.customTabView.hidden = NO;
    allCmntsVC = nil;
    customMoviePlayerVC = nil;
    TCEND
}

#pragma mark Video Play
- (void)playVideo:(id)sender withEvent:(UIEvent *)event  {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:trendsTableView];
    [self gotoPlayerScreenWithIndexPath:indexPath];
    TCEND
}

- (void)gotoPlayerScreenWithIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [displayTrendsArray objectAtIndex:indexPath.row];
        [appDelegate requestForPlayBackWithVideoId:video.videoId andcaller:self andIndexPath:indexPath refresh:NO];
    }
    TCEND
}

- (void)playBackResponse:(NSDictionary *)results {
    TCSTART
    if ([self isNotNull:results] && ![[results objectForKey:@"isResponseNull"] boolValue]) {
        VideoModal *video;
        NSIndexPath *indexPath = [results objectForKey:@"indexpath"];
        if ([self isNotNull:[results objectForKey:@"refresh"]] && ![[results objectForKey:@"refresh"] boolValue]) {
            video = [displayTrendsArray objectAtIndex:indexPath.row];
            if ([self isNotNull:[[results objectForKey:@"results"] objectForKey:@"uid"]]) {
                video.userId = [[results objectForKey:@"results"] objectForKey:@"uid"];
            }
            if ([self isNotNull:[[results objectForKey:@"results"] objectForKey:@"video_url"]]) {
                video.path = [[results objectForKey:@"results"] objectForKey:@"video_url"];
            }
            if ([self isNotNull:[[results objectForKey:@"results"] objectForKey:@"username"]]) {
                video.userName = [[results objectForKey:@"results"] objectForKey:@"username"];
            }
            if ([self isNotNull:[[results objectForKey:@"results"] objectForKey:@"user_photo"]]) {
                video.userPhoto = [[results objectForKey:@"results"] objectForKey:@"user_photo"];
            }
        } else {
            if ([self isNotNull:[results objectForKey:@"video"]]) {
                video = [results objectForKey:@"video"];
            }
        }
        customMoviePlayerVC = [[CustomMoviePlayerViewController alloc]initWithNibName:@"CustomMoviePlayerViewController" bundle:nil video:video videoFilePath:nil andClientVideoId:video.videoId showInstrcutnScreen:NO];
        [self presentViewController:customMoviePlayerVC animated:YES completion:nil];
        customMoviePlayerVC.caller = self;
        customMoviePlayerVC.selectedIndexPath = [results objectForKey:@"indexpath"];
    }
    TCEND
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
