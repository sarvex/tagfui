/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "ConnectionsViewController.h"
#import "CommentUserCell.h"
#import "AllCommentsViewController.h"

@interface ConnectionsViewController ()

@end

@implementation ConnectionsViewController
@synthesize caller;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andFrame:(CGRect)frame
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.view.frame = frame;
    }
    return self;
}

- (void)viewDidLoad {
    TCSTART
    [super viewDidLoad];
    connectionsArray = [[NSMutableArray alloc] init];
    [connectionTableview registerNib:[UINib nibWithNibName:@"CommentUserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CommentUserCellID"];
    connectionTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = [appDelegate colorWithHexString:@"fafafa"];
    connectionTableview.backgroundColor = [UIColor clearColor];
    TCEND
}

#pragma mark TagCommentUsers
- (void)makeRequestForTagCommentUsersWithText:(NSString *)enteredText {
    TCSTART
    NSMutableString *text = [[NSMutableString alloc] initWithString:enteredText];
    [text replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
    [appDelegate makeRequestForTagUserCommentsWithData:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:text?:@"",@"user_name", nil], nil], @"comments", nil] andCaller:self];
    TCEND
}

- (void)didFinishedToGetTagCommentUsersInfo:(NSDictionary *)results {
    TCSTART
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"isResponseNull"]] && ![[results objectForKey:@"isResponseNull"] boolValue]) {
        [connectionsArray removeAllObjects];
        [connectionsArray addObjectsFromArray:[results objectForKey:@"tag_user_comment"]];
        [connectionTableview reloadData];
    }
    TCEND
}
- (void)didFailToGetTagCommentUsersInfoWithError:(NSDictionary *)errorDict {
    TCSTART
    TCEND
}

#pragma mark tableview datasource and Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return connectionsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCSTART
    return 50;
    TCEND
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        
        //static NSString *user_messageCell = @"messageCell";
        static NSString *CellIndentifier = @"CommentUserCellID";
        
        CommentUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
        //initialize cell and its subviews instances once and use them when table scrolling through their instances retrieved based on "Tag" value
        if (cell == nil) {
            cell = [[CommentUserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIndentifier];
        }
        
        
        cell.userPicImgView.layer.cornerRadius = 20.0f;
        cell.userPicImgView.layer.borderWidth = 1.5f;
        cell.userPicImgView.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
        cell.userPicImgView.layer.masksToBounds = YES;
        
        cell.userNameLbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
        
        cell.cellDividerLbl.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
        
        cell.commentTextLbl.hidden = YES;
        cell.addUserBtn.hidden = YES;
        cell.deleteUserBtn.hidden = YES;
        cell.userNameLbl.frame = CGRectMake(cell.userNameLbl.frame.origin.x, 0, 265, 50);
        
        NSDictionary *userDict = [connectionsArray objectAtIndex:indexPath.row];
        
        if ([self isNotNull:[userDict objectForKey:@"photo_path"]]) {
            [cell.userPicImgView setImageWithURL:[NSURL URLWithString:[userDict objectForKey:@"photo_path"]] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached];
        } else {
            cell.userPicImgView.image = [UIImage imageNamed:@"OwnerPic"];
        }
        //Display the name of user
        if ([self isNotNull:[userDict objectForKey:@"user_name"]]) {
            cell.userNameLbl.text = [userDict objectForKey:@"user_name"];
        } else {
            cell.userNameLbl.text = @"";
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
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
    if (indexPath.row < connectionsArray.count) {
        NSDictionary *userDict = [connectionsArray objectAtIndex:indexPath.row];
        if ([caller isKindOfClass:[AllCommentsViewController class]] && [caller respondsToSelector:@selector(taggedUserDict:)]) {
            AllCommentsViewController *cmntsVC = (AllCommentsViewController *)caller;
            [cmntsVC taggedUserDict:userDict];
        }
    }
    TCEND
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
