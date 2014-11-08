/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "FriendsViewController.h"
#import "SuggestedUserCell.h"

@interface FriendsViewController () {
    WooTagPlayerAppDelegate *appDelegate;
}
@end

@implementation FriendsViewController

@synthesize friendsList;
@synthesize isLoadingFriends;
@synthesize isGPlusFriendsLoaded;
@synthesize isTWFriendsLoaded;
@synthesize isWTFriendsLoaded;
@synthesize isFBFriendsLoaded;
@synthesize isContactsLoaded;

@synthesize shareVC;
@synthesize selectedUserDict;
@synthesize pagesArray;
@synthesize loggedInUserDictArray;

@synthesize caller;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    return self;
}

- (void)viewDidLoad {
    TCSTART
    [super viewDidLoad];
    selectedArray = [[NSMutableArray alloc] init];
    pagesArray = [[NSMutableArray alloc] init];
    loggedInUserDictArray = [[NSMutableArray alloc] init];
    
    appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.view.backgroundColor = [appDelegate colorWithHexString:@"e7e7e7"];
    
    friendsSearchBar.keyboardType = UIKeyboardTypeDefault;
    friendsSearchBar.barStyle = UIBarStyleDefault;
    
    [self setBackgroundForSearchBar:friendsSearchBar withImagePath:@"SearchBarBg"];
    friendsSearchBar.backgroundColor = [UIColor clearColor];
    
    // Do any additional setup after loading the view from its nib.
    
    friendsList = [[NSMutableArray alloc]init];
    filteredFriendsList = [[NSMutableArray alloc]init];
    isSearching = NO;
    friendsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    friendsTable.backgroundColor = [UIColor clearColor];
    
    [friendsTable registerNib:[UINib nibWithNibName:@"SuggestedUserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SuggestedUserCellID"];
    
    TCEND
}

#pragma mark WooTag users
- (void)makeRequestForListOfWooTagFreinds:(BOOL)pagination andPageNum:(NSInteger)pagNum {
    TCSTART
    if ([self isNotNull:appDelegate.loggedInUser.userId]) {
        [appDelegate showNetworkIndicator];
        if (!pagination) {
            [appDelegate showActivityIndicatorInView:friendsTable andText:@""];
        }
        [appDelegate makeRequestForWooTagFreindsWithUserId:appDelegate.loggedInUser.userId pageNumber:pagNum andCaller:self];
    }
    TCEND
}

- (void)didFinishedToGetWooTagFreinds:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:friendsTable];
    isLoadingFriends = NO;
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"isResponseNull"]] && ![[results objectForKey:@"isResponseNull"] boolValue]) {
        if (pageNumber == 1) {
            [friendsList removeAllObjects];
            if ([self isNotNull:selectedUserDict] && [self isNotNull:[selectedUserDict objectForKey:@"id"]] && [[selectedUserDict objectForKey:@"id"] isEqualToString:appDelegate.loggedInUser.userId]) {
                selectedUserDict = [NSDictionary dictionaryWithObjectsAndKeys:appDelegate.loggedInUser.userId?:@"",@"id",appDelegate.loggedInUser.userName?:@"",@"displayname",appDelegate.loggedInUser.photoPath?:@"",@"image",@"loggedin",@"type", nil];
            } else {
                [self.loggedInUserDictArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:appDelegate.loggedInUser.userId?:@"",@"id",appDelegate.loggedInUser.userName?:@"",@"displayname",appDelegate.loggedInUser.photoPath?:@"",@"image", nil]];
            }
        }
        [friendsList addObjectsFromArray:[self formatFollowingsUsersData:[results objectForKey:@"friends"]]];
    }
    
    [friendsTable reloadData];
    TCEND
}

- (void)didFailToGetWooTagFreindsWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:friendsTable];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    [friendsTable reloadData];
    TCEND
}

- (NSArray *)formatFollowingsUsersData:(NSArray *)array {
    TCSTART
    NSMutableArray *usersArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in array) {
        NSMutableDictionary *dictM = [[NSMutableDictionary alloc] init];
        if ([self isNotNull:[dict objectForKey:@"user_id"]]) {
            [dictM setObject:[dict objectForKey:@"user_id"] forKey:@"id"];
        }
        if ([self isNotNull:[dict objectForKey:@"user_name"]]) {
            [dictM setObject:[dict objectForKey:@"user_name"] forKey:@"displayname"];
        }
        
        if ([self isNotNull:[dict objectForKey:@"user_photo"]]) {
            [dictM setObject:[dict objectForKey:@"user_photo"] forKey:@"image"];
        }
        if ([self isNotNull:selectedUserDict] && [self isNotNull:[selectedUserDict objectForKey:@"id"]] && [[selectedUserDict objectForKey:@"id"] isEqualToString:[dict objectForKey:@"user_id"]]) {
            [dictM setObject:@"friends" forKey:@"type"];
            
            selectedUserDict = dictM;
        } else {
            [usersArray addObject:dictM];
        }
    }
    return usersArray;
    TCEND
}


- (void)viewWillAppear:(BOOL)animated {
    TCSTART
    [super viewWillAppear:YES];
    TCEND
}

- (void)viewDidAppear:(BOOL)animated {
    TCSTART
    [super viewDidAppear:YES];
//    [self setImageForSearchBgPlaceholder];
    TCEND
}

- (void)setAllBoolVariablesToNo {
    isTWFriendsLoaded = NO;
    isWTFriendsLoaded = NO;
    pageNumber = 1;
    isGPlusFriendsLoaded = NO;
    isFBFriendsLoaded = NO;
    isContactsLoaded = NO;
}

- (void)setImageForSearchBgPlaceholder {
    if (isTWFriendsLoaded) {
        searchBarBackgroundImg.image = [UIImage imageNamed:@"TWSearch"];
    } else if (isGPlusFriendsLoaded) {
        searchBarBackgroundImg.image = [UIImage imageNamed:@"GPlusSearch"];
    } else if (isWTFriendsLoaded) {
        searchBarBackgroundImg.image = [UIImage imageNamed:@"WTSearch"];
    } else if (isContactsLoaded) {
        searchBarBackgroundImg.image = [UIImage imageNamed:@"Contacts"];
    } else {
        searchBarBackgroundImg.image = [UIImage imageNamed:@"FBSearch"];
    }
    [pagesArray removeAllObjects];
    [loggedInUserDictArray removeAllObjects];
    [filteredFriendsList removeAllObjects];
    [friendsList removeAllObjects];
}

#pragma mark TableView Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self isNotNull:caller] && [caller isKindOfClass:[TagToolViewController class]] && !isSearching) {
        return 4;
    } else if ([self isNotNull:shareVC] && !isSearching) {
        return 3;
    }
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && !isSearching) {
         if ([caller isKindOfClass:[TagToolViewController class]]) {
             if ([self isNotNull:selectedUserDict] && [self isNotNull:[selectedUserDict objectForKey:@"id"]]) {
                 return 1;
             }
         } else if ([self isNotNull:shareVC]) {
             if (loggedInUserDictArray.count > 0) {
                 return 1;
             }
         }
        return 0;
    } else if (section == 1 && !isSearching) {
        if ([caller isKindOfClass:[TagToolViewController class]]) {
            if (loggedInUserDictArray.count > 0) {
                return 1;
            }
        } else if ([self isNotNull:shareVC]) {
            if (pagesArray.count > 0) {
                return pagesArray.count;
            }
        }
        return 0;
    } else if (section == 2 && !isSearching) {
        if ([caller isKindOfClass:[TagToolViewController class]]) {
            return pagesArray.count;
        }
    }
    return [self getNumberOfRowForFreindsList];
}

- (NSInteger)getNumberOfRowForFreindsList {
    NSInteger numberOfRows = 0;
    int count = friendsList.count - ((([selectedUserDict allValues].count) > 0)? 1 : 0);
    if (friendsList.count > 0 && ((isTWFriendsLoaded && next_cursor.intValue != 0) || (isWTFriendsLoaded && count >= pageNumber * 10)) && !isSearching) {
        numberOfRows = friendsList.count + 1;
    } else if(friendsList.count > 0 && !isSearching) {
        numberOfRows = friendsList.count;
    } else if(filteredFriendsList.count > 0 && isSearching) {
        numberOfRows = filteredFriendsList.count;
    } else {
        numberOfRows = 1;
    }
    return numberOfRows;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([caller isKindOfClass:[TagToolViewController class]] && !isSearching) {
        if (([selectedUserDict allValues].count > 0 && section == 0) || (section == 1 && loggedInUserDictArray.count > 0) || (section == 2 && pagesArray.count > 0) || (section == 3 && friendsList.count > 0)) {
            return 25;
        }
    } else if ([self isNotNull:shareVC] && !isSearching) {
        if ((section == 0 && loggedInUserDictArray.count > 0) || (section == 2 && friendsList.count > 0)) {
            return 25;
        } else if (section == 1 && pagesArray.count > 0) {
            return 25;
        }
    } else {
        return 0;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TCSTART
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, friendsTable.frame.size.width, 25)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel *headerLabl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, headerView.frame.size.height)];
    headerLabl.font = [UIFont fontWithName:titleFontName size:14];
    headerLabl.backgroundColor = [appDelegate colorWithHexString:@"f8f8f8"];
    headerLabl.textColor = [UIColor blackColor];
    headerLabl.textAlignment = UITextAlignmentCenter;
    [headerView addSubview:headerLabl];
    if ([caller isKindOfClass:[TagToolViewController class]] && !isSearching) {
        if (section == 0) {
            headerLabl.text = @"Tagged friend";
        } else if (section == 1) {
            headerLabl.text = @"Tag yourself";
        } else if (section == 2) {
            headerLabl.text = @"Tag your page";
        } else {
            if (isFBFriendsLoaded) {
                headerLabl.text = @"Tag your friend";
            } else if (isTWFriendsLoaded) {
                headerLabl.text = @"Tag your following connection";
            } else if (isWTFriendsLoaded) {
                headerLabl.text = @"Tag your private/following connection";
            } else {
                headerLabl.text = @"Tag your circle";
            }
        }
    } else if ([self isNotNull:shareVC] && !isSearching) {
        if (section == 0) {
            if (isFBFriendsLoaded)
                headerLabl.text = @"My Wall";
            else if (isTWFriendsLoaded)
                headerLabl.text = @"Tweet";
            else
                headerLabl.text = @"My Post";
        } else if (section == 1) {
            headerLabl.text = @"Pages";
        } else {
            if (isFBFriendsLoaded || isContactsLoaded)
                headerLabl.text = @"My Friends";
            else if (isTWFriendsLoaded)
                headerLabl.text = @"My Following";
            else
                headerLabl.text = @"Post it to my circle";
        }
    }
    
    return headerView;
    TCEND
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if (!isSearching && (([self isNotNull:caller] && [caller isKindOfClass:[TagToolViewController class]] && ((indexPath.section == 0 && [self isNotNull:selectedUserDict] && [selectedUserDict allKeys].count > 0) || (indexPath.section == 1 && loggedInUserDictArray.count > 0) || (indexPath.section == 2 && pagesArray.count > 0))) || ([self isNotNull:shareVC] && ((indexPath.section == 0 && loggedInUserDictArray.count > 0) || (indexPath.section == 1 && pagesArray.count > 0))))) {
        
        static NSString *cellIdentifier = @"SuggestedUserCellID";
        SuggestedUserCell *cell = (SuggestedUserCell *)[tableView_ dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil) {
            cell = [[SuggestedUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        NSDictionary *friend;
        if (indexPath.section == 0 && [selectedUserDict allKeys].count > 0 && [caller isKindOfClass:[TagToolViewController class]]) {
            friend = selectedUserDict;
        } else {
            if (indexPath.section == 0 || (indexPath.section == 1 && [caller isKindOfClass:[TagToolViewController class]])) {
                friend = [loggedInUserDictArray objectAtIndex:0];
            } else if (indexPath.section == 1 || (indexPath.section == 2 && [caller isKindOfClass:[TagToolViewController class]])) {
                friend = [pagesArray objectAtIndex:indexPath.row];
            }
        }
        cell.userProfileImgView.frame = CGRectMake(5, 10, 40, 40);
        
        cell.userNameLbl.frame = CGRectMake(50, cell.userNameLbl.frame.origin.y, cell.frame.size.width - 55, cell.userNameLbl.frame.size.height);
        cell.descLbl.frame = CGRectMake(50, cell.descLbl.frame.origin.y, cell.frame.size.width - 55, cell.descLbl.frame.size.height);
        
        if ([self isNotNull:[friend objectForKey:@"image"]]) {
            [cell.userProfileImgView setImageWithURL:[NSURL URLWithString:[friend objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached]; //profile image
        } else {
            cell.userProfileImgView.image = [UIImage imageNamed:@"OwnerPic"];
        }
        cell.userProfileImgView.layer.cornerRadius = 20.0f;
        cell.userProfileImgView.layer.borderWidth = 1.5f;
        cell.userProfileImgView.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
        cell.userProfileImgView.layer.masksToBounds = YES;
        
        cell.userNameLbl.text = [friend objectForKey:@"displayname"];//display name
        cell.userNameLbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
        
        if ([self isNotNull:[friend objectForKey:@"description"]]) {
            cell.descLbl.text = [friend objectForKey:@"description"];
            cell.userNameLbl.frame = CGRectMake(cell.userNameLbl.frame.origin.x, 9, cell.userNameLbl.frame.size.width, 21);
        } else {
            cell.descLbl.text = @"";
            cell.userNameLbl.frame = CGRectMake(cell.userNameLbl.frame.origin.x, 10, cell.userNameLbl.frame.size.width, 40);
            cell.userNameLbl.numberOfLines = 0;
        }
        
        if (indexPath.section == 0 && [self isNotNull:caller] && [caller isKindOfClass:[TagToolViewController class]]) {
            cell.addBtn.hidden = NO;
            [cell.addBtn setBackgroundImage:[UIImage imageNamed:@"use"] forState:UIControlStateNormal];
            [cell.addBtn setImage:[UIImage imageNamed:@"taggeduserdelete"] forState:UIControlStateNormal];
            [cell.addBtn addTarget:self action:@selector(deleteTaggedUser) forControlEvents:UIControlEventTouchUpInside];
        } else {
            cell.addBtn.hidden = YES;
            if ([self isNotNull:selectedArray] && [selectedArray containsObject:friend]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.inviteBtn.hidden = YES;

        return cell;
        
    } else {
        if (friendsList.count == 0) {
            static NSString * infoCellIdentifier = @"infoCell";
            UITableViewCell *infocell = [tableView_ dequeueReusableCellWithIdentifier:infoCellIdentifier];
            
            if(infocell == nil) {
                infocell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:infoCellIdentifier];
            }
            
            UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [activityIndicator setFrame:CGRectMake((tableView_.frame.size.width - 20)/2, 0 , 20, 20)];
            [infocell.contentView addSubview:activityIndicator];
            
            NSString *helpText = nil;
            if (isLoadingFriends) {
                [activityIndicator startAnimating];
                activityIndicator.hidden = NO;
                helpText = @"Loading... Please wait";
            } else {
                [activityIndicator stopAnimating];
                activityIndicator.hidden = YES;
                helpText = @"No friends found";
            }
            infocell.textLabel.text = helpText;
            infocell.textLabel.font = [UIFont fontWithName:descriptionTextFontName size:13];
            infocell.imageView.hidden = YES;
            infocell.backgroundColor = [UIColor clearColor];
            return infocell;
        } else if(friendsList.count > 0 && (isTWFriendsLoaded || isWTFriendsLoaded) && friendsList.count == indexPath.row) {
            
            UITableViewCell *loadMoreCell = nil;
            
            //show the load more activity with text if array count is equal to current row index.
            UIActivityIndicatorView *activityIndicator_view = nil;
            static NSString *loadMoreCellIdentifier = @"loadMoreCellIdentifier";
            loadMoreCell = [tableView_ dequeueReusableCellWithIdentifier:loadMoreCellIdentifier];
            
            if(loadMoreCell == nil) {
                loadMoreCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadMoreCellIdentifier];
                
                activityIndicator_view = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                activityIndicator_view.frame = CGRectMake((tableView_.frame.size.width - 20)/2, 20, 20, 20);
                activityIndicator_view.tag = 1;
                [loadMoreCell.contentView addSubview:activityIndicator_view];
            }
            if (!activityIndicator_view) {
                activityIndicator_view = (UIActivityIndicatorView *)[loadMoreCell.contentView viewWithTag:1];
            }
            loadMoreCell.selectionStyle = UITableViewCellSelectionStyleNone;
            loadMoreCell.imageView.hidden = YES;
            loadMoreCell.backgroundColor = [UIColor clearColor];
            [activityIndicator_view startAnimating];
            return loadMoreCell;
        } else if(filteredFriendsList.count == 0 && isSearching) {
            
            static NSString * cellIdentifier = @"nocell";
            
            UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if(cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
            
            cell.textLabel.text = @"Search contact is not available";
            cell.textLabel.font = [UIFont fontWithName:descriptionTextFontName size:13];
            cell.backgroundColor = [UIColor clearColor];
            return cell;
            
        } else {
            static NSString *cellIdentifier = @"SuggestedUserCellID";
            SuggestedUserCell *cell = (SuggestedUserCell *)[tableView_ dequeueReusableCellWithIdentifier:cellIdentifier];
            if(cell == nil) {
                cell = [[SuggestedUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            NSDictionary *friend = nil;
            if (friendsList.count > indexPath.row && !isSearching) {
                friend = [friendsList objectAtIndex:indexPath.row];
            } else if(filteredFriendsList.count > indexPath.row && isSearching) {
                friend = [filteredFriendsList objectAtIndex:indexPath.row];
            }
            
            cell.userProfileImgView.frame = CGRectMake(5, 10, 40, 40);
            
            cell.userNameLbl.frame = CGRectMake(50, cell.userNameLbl.frame.origin.y, cell.frame.size.width - 55, cell.userNameLbl.frame.size.height);
            cell.descLbl.frame = CGRectMake(50, cell.descLbl.frame.origin.y, cell.frame.size.width - 55, cell.descLbl.frame.size.height);
            
            if (isContactsLoaded) {
                if ([self isNotNull:[friend objectForKey:@"image_data"]]) {
                    cell.userProfileImgView.image = [UIImage imageWithData:[friend objectForKey:@"image_data"]]; //profile image
                } else {
                    cell.userProfileImgView.image = [UIImage imageNamed:@"OwnerPic"];
                }
                if ([self isNull:[friend objectForKey:@"user_name"]]) {
                    cell.userNameLbl.text = [friend objectForKey:@"phonenumber"];
                } else {
                    cell.userNameLbl.text = [friend objectForKey:@"user_name"];
                }
            } else {
                if ([self isNotNull:[friend objectForKey:@"image"]]) {
                    [cell.userProfileImgView setImageWithURL:[NSURL URLWithString:[friend objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached]; //profile image
                } else {
                    cell.userProfileImgView.image = [UIImage imageNamed:@"OwnerPic"];
                }
                cell.userNameLbl.text = [friend objectForKey:@"displayname"];//display name
            }
            
            cell.userProfileImgView.layer.cornerRadius = 20.0f;
            cell.userProfileImgView.layer.borderWidth = 1.5f;
            cell.userProfileImgView.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
            cell.userProfileImgView.layer.masksToBounds = YES;
            
            
            cell.userNameLbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
            
            if ([self isNotNull:[friend objectForKey:@"description"]]) {
                cell.descLbl.text = [friend objectForKey:@"description"];
                cell.userNameLbl.frame = CGRectMake(cell.userNameLbl.frame.origin.x, 9, cell.userNameLbl.frame.size.width, 21);
            } else {
                cell.descLbl.text = @"";
                cell.userNameLbl.frame = CGRectMake(cell.userNameLbl.frame.origin.x, 10, cell.userNameLbl.frame.size.width, 40);
                cell.userNameLbl.numberOfLines = 0;
            }
            
            cell.addBtn.hidden = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.inviteBtn.hidden = YES;
            
            if ([self isNotNull:selectedArray] && [selectedArray containsObject:friend]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            return cell;
        }
    }
    TCEND
}

//- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    TCSTART
//    if ([self isNotNull:caller] && [caller isKindOfClass:[TagToolViewController class]] && [self isNotNull:selectedUserDict] && [self isNotNull:[selectedUserDict objectForKey:@"id"]] && indexPath.section == 0 && indexPath.row == 0 && !isSearching) {
//        static NSString *cellIdentifier = @"SuggestedUserCellID";
//        SuggestedUserCell *cell = (SuggestedUserCell *)[tableView_ dequeueReusableCellWithIdentifier:cellIdentifier];
//        if(cell == nil) {
//            cell = [[SuggestedUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//        }
//
//        cell.userProfileImgView.frame = CGRectMake(5, 10, 40, 40);
//        
//        cell.userNameLbl.frame = CGRectMake(50, cell.userNameLbl.frame.origin.y, cell.frame.size.width - 55, cell.userNameLbl.frame.size.height);
//        cell.descLbl.frame = CGRectMake(50, cell.descLbl.frame.origin.y, cell.frame.size.width - 55, cell.descLbl.frame.size.height);
//        
//        if ([self isNotNull:[selectedUserDict objectForKey:@"image"]]) {
//            [cell.userProfileImgView setImageWithURL:[NSURL URLWithString:[selectedUserDict objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached]; //profile image
//        } else {
//            cell.userProfileImgView.image = [UIImage imageNamed:@"OwnerPic"];
//        }
//        cell.userProfileImgView.layer.cornerRadius = 20.0f;
//        cell.userProfileImgView.layer.borderWidth = 1.5f;
//        cell.userProfileImgView.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
//        cell.userProfileImgView.layer.masksToBounds = YES;
//        
//        cell.userNameLbl.text = [selectedUserDict objectForKey:@"displayname"];//display name
//        cell.userNameLbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
//        
//        if ([self isNotNull:[selectedUserDict objectForKey:@"description"]]) {
//            cell.descLbl.text = [selectedUserDict objectForKey:@"description"];
//            cell.userNameLbl.frame = CGRectMake(cell.userNameLbl.frame.origin.x, 9, cell.userNameLbl.frame.size.width, 21);
//        } else {
//            cell.descLbl.text = @"";
//            cell.userNameLbl.frame = CGRectMake(cell.userNameLbl.frame.origin.x, 10, cell.userNameLbl.frame.size.width, 40);
//            cell.userNameLbl.numberOfLines = 0;
//        }
//        
//        cell.addBtn.hidden = NO;
//        [cell.addBtn setBackgroundImage:[UIImage imageNamed:@"use"] forState:UIControlStateNormal];
//        [cell.addBtn setImage:[UIImage imageNamed:@"taggeduserdelete"] forState:UIControlStateNormal];
//        [cell.addBtn addTarget:self action:@selector(deleteTaggedUser) forControlEvents:UIControlEventTouchUpInside];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.backgroundColor = [UIColor clearColor];
//        cell.inviteBtn.hidden = YES;
//        
//        return cell;
//    } else {
//        if (friendsList.count == 0) {
//            static NSString * infoCellIdentifier = @"infoCell";
//            UITableViewCell *infocell = [tableView_ dequeueReusableCellWithIdentifier:infoCellIdentifier];
//            
//            if(infocell == nil) {
//                infocell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:infoCellIdentifier];
//            }
//            
//            UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//            [activityIndicator setFrame:CGRectMake((tableView_.frame.size.width - 20)/2, 0 , 20, 20)];
//            [infocell.contentView addSubview:activityIndicator];
//            
//            NSString *helpText = nil;
//            if (isLoadingFriends) {
//                [activityIndicator startAnimating];
//                activityIndicator.hidden = NO;
//                helpText = @"Loading... Please wait";
//            } else {
//                [activityIndicator stopAnimating];
//                activityIndicator.hidden = YES;
//                helpText = @"No friends found";
//            }
//            infocell.textLabel.text = helpText;
//            infocell.textLabel.font = [UIFont fontWithName:descriptionTextFontName size:13];
//            infocell.imageView.hidden = YES;
//            infocell.backgroundColor = [UIColor clearColor];
//            return infocell;
//        } else if(friendsList.count > 0 && (isTWFriendsLoaded || isWTFriendsLoaded) && friendsList.count == indexPath.row) {
//            
//            UITableViewCell *loadMoreCell = nil;
//            
//            //show the load more activity with text if array count is equal to current row index.
//            UIActivityIndicatorView *activityIndicator_view = nil;
//            static NSString *loadMoreCellIdentifier = @"loadMoreCellIdentifier";
//            loadMoreCell = [tableView_ dequeueReusableCellWithIdentifier:loadMoreCellIdentifier];
//            
//            if(loadMoreCell == nil) {
//                loadMoreCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadMoreCellIdentifier];
//                
//                activityIndicator_view = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//                activityIndicator_view.frame = CGRectMake((tableView_.frame.size.width - 20)/2, 20, 20, 20);
//                activityIndicator_view.tag = 1;
//                [loadMoreCell.contentView addSubview:activityIndicator_view];
//            }
//            if (!activityIndicator_view) {
//                activityIndicator_view = (UIActivityIndicatorView *)[loadMoreCell.contentView viewWithTag:1];
//            }
//            loadMoreCell.selectionStyle = UITableViewCellSelectionStyleNone;
//            loadMoreCell.imageView.hidden = YES;
//            loadMoreCell.backgroundColor = [UIColor clearColor];
//            [activityIndicator_view startAnimating];
//            return loadMoreCell;
//        } else if(filteredFriendsList.count == 0 && isSearching) {
//            
//            static NSString * cellIdentifier = @"nocell";
//            
//            UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:cellIdentifier];
//            
//            if(cell == nil) {
//                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
//            }
//            
//            cell.textLabel.text = @"Search contact is not available";
//            cell.textLabel.font = [UIFont fontWithName:descriptionTextFontName size:13];
//            cell.backgroundColor = [UIColor clearColor];
//            return cell;
//            
//        } else {
//            static NSString *cellIdentifier = @"SuggestedUserCellID";
//            SuggestedUserCell *cell = (SuggestedUserCell *)[tableView_ dequeueReusableCellWithIdentifier:cellIdentifier];
//            if(cell == nil) {
//                cell = [[SuggestedUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//            }
//            
//            NSDictionary *friend = nil;
//            if (friendsList.count > indexPath.row && !isSearching) {
//                friend = [friendsList objectAtIndex:indexPath.row];
//            } else if(filteredFriendsList.count > indexPath.row && isSearching) {
//                friend = [filteredFriendsList objectAtIndex:indexPath.row];
//            }
//            
//            cell.userProfileImgView.frame = CGRectMake(5, 10, 40, 40);
//            
//            cell.userNameLbl.frame = CGRectMake(50, cell.userNameLbl.frame.origin.y, cell.frame.size.width - 55, cell.userNameLbl.frame.size.height);
//            cell.descLbl.frame = CGRectMake(50, cell.descLbl.frame.origin.y, cell.frame.size.width - 55, cell.descLbl.frame.size.height);
//            
//            if (isContactsLoaded) {
//                if ([self isNotNull:[friend objectForKey:@"image_data"]]) {
//                    cell.userProfileImgView.image = [UIImage imageWithData:[friend objectForKey:@"image_data"]]; //profile image
//                } else {
//                    cell.userProfileImgView.image = [UIImage imageNamed:@"OwnerPic"];
//                }
//                if ([self isNull:[friend objectForKey:@"user_name"]]) {
//                    cell.userNameLbl.text = [friend objectForKey:@"phonenumber"];
//                } else {
//                    cell.userNameLbl.text = [friend objectForKey:@"user_name"];
//                }
//            } else {
//                if ([self isNotNull:[friend objectForKey:@"image"]]) {
//                    [cell.userProfileImgView setImageWithURL:[NSURL URLWithString:[friend objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached]; //profile image
//                } else {
//                    cell.userProfileImgView.image = [UIImage imageNamed:@"OwnerPic"];
//                }
//                 cell.userNameLbl.text = [friend objectForKey:@"displayname"];//display name
//            }
//            
//            cell.userProfileImgView.layer.cornerRadius = 20.0f;
//            cell.userProfileImgView.layer.borderWidth = 1.5f;
//            cell.userProfileImgView.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
//            cell.userProfileImgView.layer.masksToBounds = YES;
//            
//           
//            cell.userNameLbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];
//            
//            if ([self isNotNull:[friend objectForKey:@"description"]]) {
//                cell.descLbl.text = [friend objectForKey:@"description"];
//                cell.userNameLbl.frame = CGRectMake(cell.userNameLbl.frame.origin.x, 9, cell.userNameLbl.frame.size.width, 21);
//            } else {
//                cell.descLbl.text = @"";
//                cell.userNameLbl.frame = CGRectMake(cell.userNameLbl.frame.origin.x, 10, cell.userNameLbl.frame.size.width, 40);
//                cell.userNameLbl.numberOfLines = 0;
//            }
//            
//            cell.addBtn.hidden = YES;
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            cell.backgroundColor = [UIColor clearColor];
//            cell.inviteBtn.hidden = YES;
//            
//            if ([self isNotNull:selectedArray] && [selectedArray containsObject:friend]) {
//                cell.accessoryType = UITableViewCellAccessoryCheckmark;
//            } else {
//                cell.accessoryType = UITableViewCellAccessoryNone;
//            }
//            return cell;
//        }
//    }
//    TCEND
//}

- (void)deleteTaggedUser {
    TCSTART
//    [dictM setObject:@"friends" forKey:@"type"];
//    ,@"loggedin",@"type"
//    @"pages"
    if ([[selectedUserDict valueForKey:@"type"] caseInsensitiveCompare:@"loggedin"] == NSOrderedSame) {
        [loggedInUserDictArray removeAllObjects];
        [loggedInUserDictArray addObject:[selectedUserDict mutableCopy]];
    } else if ([[selectedUserDict valueForKey:@"type"] caseInsensitiveCompare:@"pages"] == NSOrderedSame) {
        [pagesArray addObject:[selectedUserDict mutableCopy]];
    } else if ([[selectedUserDict valueForKey:@"type"] caseInsensitiveCompare:@"friends"] == NSOrderedSame) {
        [friendsList addObject:[selectedUserDict mutableCopy]];
    }
    
    selectedUserDict = Nil;
    [friendsTable reloadData];
    NSString *type;
    if (isFBFriendsLoaded) {
        type = @"FB";
    } else if (isTWFriendsLoaded) {
        type = @"TW";
    } else if (isGPlusFriendsLoaded) {
        type = @"GPlus";
    } else {
        type = @"WT";
    }
    [caller deletedTaggedFriendOfType:type];
    TCEND
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TCSTART
    int count;
    if (isTWFriendsLoaded) {
        count = friendsList.count;
    } else if (isWTFriendsLoaded) {
        count = friendsList.count - ((([selectedUserDict allValues].count) > 0)? 1 : 0);
    }
    if (indexPath.section == 3 && indexPath.row == friendsList.count && count >= pageNumber * 10 && isWTFriendsLoaded && !isSearching) {
        [self performSelector:@selector(loadMoreFollowings) withObject:nil afterDelay:0.001];
    } else {
        if ((([self isNotNull:caller] && indexPath.section == 3) || indexPath.section == 2) && isTWFriendsLoaded && count > 0 && indexPath.row == count && !isSearching) {
            [self performSelector:@selector(loadMoreAcitivities:) withObject:nil afterDelay:0.001];
        }
    }
    TCEND
}

- (void)loadMoreFollowings {
    pageNumber = pageNumber + 1;
    [self makeRequestForListOfWooTagFreinds:YES andPageNum:pageNumber];
}

- (void)loadMoreAcitivities:(id)sender {
    TCSTART
    NSLog(@"Friends Count :%d",friendsList.count);
    if ([self isNotNull:shareVC] && [shareVC respondsToSelector:@selector(requestForTWFollowersList:loadMore:)]) {
        [shareVC requestForTWFollowersList:next_cursor loadMore:YES];
    } else {
        [caller requestForTWFollowersList:next_cursor loadMore:YES];
    }
    TCEND
}

#pragma mark TableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    SuggestedUserCell *cell = (SuggestedUserCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *friend = nil;
    if ((friendsList.count > 0 || pagesArray.count > 0 || loggedInUserDictArray.count > 0) && !isSearching) {
        if (((indexPath.section == 0 && [self isNotNull:shareVC]) || (indexPath.section == 1 && [self isNotNull:caller])) && loggedInUserDictArray.count > indexPath.row) {
            friend = [loggedInUserDictArray objectAtIndex:indexPath.row];
        } else if (((indexPath.section == 1 && [self isNotNull:shareVC]) || (indexPath.section == 2 && [self isNotNull:caller])) && pagesArray.count > indexPath.row) {
            friend = [pagesArray objectAtIndex:indexPath.row];
        } else if (((indexPath.section == 2 && [self isNotNull:shareVC]) || (indexPath.section == 3 && [self isNotNull:caller])) && friendsList.count > indexPath.row) {
            friend = [friendsList objectAtIndex:indexPath.row];
        }
    } if (isSearching && filteredFriendsList.count > 0) {
        friend = [filteredFriendsList objectAtIndex:indexPath.row];
    }
    [self selectedFriend:friend atTableViewCell:cell];
    TCEND
}

- (void)selectedFriend:(NSDictionary *)friend atTableViewCell:(SuggestedUserCell *)cell {
    TCSTART
    if ([self isNotNull:friend]) {
        if (isGPlusFriendsLoaded) {
            if ([self isNotNull:caller] && [caller respondsToSelector:@selector(finishedPickingGPlusFriend:)]) {
                [caller finishedPickingGPlusFriend:[friend objectForKey:@"id"]];
            } else if ([self isNotNull:shareVC] && [shareVC respondsToSelector:@selector(finishedPickingGPlusFriend:)]) {
                if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    if ([selectedArray containsObject:friend]) {
                        [selectedArray removeObject:friend];
                    }
                    [shareVC unSelectedPickedFriend:[friend objectForKey:@"id"]];
                } else {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    [shareVC finishedPickingGPlusFriend:[friend objectForKey:@"id"]];
                    [selectedArray addObject:friend];
                }
            }
            
        } else if (isContactsLoaded) {
            if ([self isNotNull:shareVC] && [shareVC respondsToSelector:@selector(finishedPickingContacts:)]) {
                if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    if ([selectedArray containsObject:friend]) {
                        [selectedArray removeObject:friend];
                    }
                    [shareVC unSelectedPickedContactFriend:friend];
                } else {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    [shareVC finishedPickingContacts:friend];
                    [selectedArray addObject:friend];
                }
            }
        } else if(isTWFriendsLoaded) {
            if ([self isNotNull:caller] && [caller respondsToSelector:@selector(finishedPickingTWFriend:)]) {
                [caller finishedPickingTWFriend:[friend objectForKey:@"id"]];
            } else if ([self isNotNull:shareVC] && [shareVC respondsToSelector:@selector(finishedPickingTWFriend:)]) {
                [selectedArray removeAllObjects];
                if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    [shareVC finishedPickingTWFriend:[friend objectForKey:@"screen_name"]];
                    [selectedArray addObject:friend];
                }
                [friendsTable reloadData];
            }
            
        } else if(isWTFriendsLoaded) {
            if ([self isNotNull:caller] && [caller respondsToSelector:@selector(finishedPickingWTFriend:)]) {
                [caller finishedPickingWTFriend:[friend objectForKey:@"id"]];
            } else if ([self isNotNull:shareVC] && [shareVC respondsToSelector:@selector(finishedPickingWTFriend:)]) {
                //                 [shareVC finishedPickingWTFriend:[friend objectForKey:@"id"]];
            }
            
        } else if (isFBFriendsLoaded) {
            if ([self isNotNull:caller] && [caller respondsToSelector:@selector(finishedPickingFBFriend:)]) {
                [caller finishedPickingFBFriend:[friend objectForKey:@"id"]];
            } else if ([self isNotNull:shareVC] && [shareVC respondsToSelector:@selector(finishedPickingFBFriend:)]) {
                [selectedArray removeAllObjects];
                if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    [shareVC finishedPickingFBFriend:[friend objectForKey:@"id"]];
                    [selectedArray addObject:friend];
                }
                [friendsTable reloadData];
            }
        }
        
        if ([self isNull:shareVC]) {
            isTWFriendsLoaded = NO;
            isWTFriendsLoaded = NO;
            isGPlusFriendsLoaded = NO;
            isFBFriendsLoaded = NO;
            isContactsLoaded = NO;
        }
    }
    TCEND
}

#pragma mark UISearchBar Delegate Methods
- (void)setBackgroundForSearchBar:(UISearchBar *)searchbar withImagePath:(NSString *)imgPath {
    
    @try {
        //        [searchbar setShowsCancelButton:YES animated:NO];
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
                searchField.backgroundColor = [UIColor whiteColor];
            }
        }
        if(!(searchField == nil)) {
            searchField.textColor = [UIColor blackColor];
            [searchField setBackground: [UIImage imageNamed:imgPath]];
            searchField.backgroundColor = [UIColor whiteColor];
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
        [self enableSearchBarCancelButton:searchbar];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)enableSearchBarCancelButton:(UISearchBar *)searchBar {
    TCSTART
    NSArray *searchSubViews;
    if (CURRENT_DEVICE_VERSION < 7.0) {
        searchSubViews = searchBar.subviews;
    } else {
        searchSubViews = [[searchBar.subviews objectAtIndex:0] subviews];
    }
    for (UIView *subview in searchSubViews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *cancelButton = (UIButton*)subview;
            [cancelButton addTarget:self action:@selector(searchBarCancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            cancelButton.enabled = YES;
            break;
        }
    }
    TCEND
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    @try {
        [filteredFriendsList removeAllObjects];
        
        int i;
        if (searchText.length > 0) {
            isSearching = YES;
            for (int j = 0; j < loggedInUserDictArray.count; j++) {
                
                NSRange range = [[[loggedInUserDictArray objectAtIndex:j] objectForKey:@"displayname"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
                
                if (range.length > 0) {
                    [filteredFriendsList addObject:[loggedInUserDictArray objectAtIndex:j]];
                }
            }
            
            for (int j = 0; j < pagesArray.count; j++) {
                
                NSRange range = [[[pagesArray objectAtIndex:j] objectForKey:@"displayname"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
                
                if (range.length > 0) {
                    [filteredFriendsList addObject:[pagesArray objectAtIndex:j]];
                }
            }
            
            for(i = 0; i < [friendsList count]; i++) {
                
                NSRange range = [[[friendsList objectAtIndex:i] objectForKey:@"displayname"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
                
                if (range.length > 0) {
                    [filteredFriendsList addObject:[friendsList objectAtIndex:i]];
                }
            }
            
            
        } else {
            isSearching = NO;
            [friendsSearchBar resignFirstResponder];
        }
        [friendsTable reloadData];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
        
    }
    @finally {
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    isSearching = NO;
    [friendsTable reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)reloadData {
    [friendsTable reloadData];
}

- (void)formatTWDataAndReloadFriendsTable:(id)twData loggedInUserInfo:(NSDictionary *)userDict andRequestForLoadMore:(BOOL)loadmore {
    TCSTART
    if (twData != nil && [twData isKindOfClass:[NSDictionary class]]) {
        next_cursor = [twData objectForKey:@"next_cursor_str"];
        NSMutableArray *friends = [[NSMutableArray alloc]init];
        NSArray *users = [twData objectForKey:@"users"];
        NSLog(@"UsersCount :%d",users.count);
        if (!loadmore && userDict) {
            [self.loggedInUserDictArray addObject:userDict];
        }
        for (NSDictionary *user in users) {
            NSMutableDictionary *friend = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[user objectForKey:@"name"]?:@"",@"displayname",[user objectForKey:@"profile_image_url_https"]?:@"",@"image",[[user objectForKey:@"id"] stringValue],@"id",[user objectForKey:@"description"]?:@"",@"description",[user objectForKey:@"location"]?:@"",@"location",[user objectForKey:@"screen_name"]?:@"",@"screen_name",[user objectForKey:@"url"]?:@"",@"url", nil];
            if ([self isNotNull:selectedUserDict] && [self isNotNull:[selectedUserDict objectForKey:@"id"]] && [[selectedUserDict objectForKey:@"id"] isEqualToString:[friend objectForKey:@"id"]]) {
                [friend setObject:@"friends" forKey:@"type"];
                selectedUserDict = friend;
            } else {
               [friends addObject:friend];
            }
        }
        [friendsList addObjectsFromArray:friends];
//        NSLog(@"friends list %@",friendsList);
    } else {
        isLoadingFriends = NO;
        next_cursor = @"0";
    }
    [friendsTable reloadData];
    TCEND
}

#pragma mark Table ScrollView Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    @try {
        if([self isNotNull:friendsSearchBar]) {
            [friendsSearchBar resignFirstResponder];
        }
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
