/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "BrowseViewController.h"
#import "OthersPageViewController.h"
#import "BrowseCell.h"
#import "SuggestedUserCell.h"

#import "TrendsDetailsViewController.h"
#import "ReportVideoViewController.h"
#import "AccessPermissionsViewController.h"
#import "ShareViewController.h"
#import "CustomMoviePlayerViewController.h"

@interface BrowseViewController () {
    CustomMoviePlayerViewController *customMoviePlayerVC;
}

@end

@implementation BrowseViewController
@synthesize superVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil viewFrame:(CGRect)frame
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.view.frame = frame;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    TCSTART
    [super viewDidLoad];
    pageNum = 1;
    reqMadeForSearch = NO;
    browseDict = [[NSMutableDictionary alloc] init];
    searchDict = [[NSMutableDictionary alloc] init];
    displayVideosArray = [[NSMutableArray alloc] init];
    browseType = @"videos";
    [self makeBrowseRequestforPagination:NO andPageNumber:1 andRequestForRefresh:NO];
    [self customizeSearchBar];
    videosSearchBar.hidden = YES;
    searchBarBg.hidden = YES;
    
    [browseTableView registerNib:[UINib nibWithNibName:@"BrowseCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"BrowseCellID"];
    
    [browseTableView registerNib:[UINib nibWithNibName:@"SuggestedUserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SuggestedUserCellID"];
    
    browseTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [browseTableView reloadData];
    refreshView = [[RefreshView alloc] initWithFrame:
                   CGRectMake(browseTableView.frame.origin.x,- browseTableView.bounds.size.height,
                              browseTableView.frame.size.width, browseTableView.bounds.size.height)];
    [browseTableView addSubview:refreshView];
    TCEND
}


- (void)makeBrowseRequestforPagination:(BOOL)requestForPagination andPageNumber:(NSInteger) pageNumber andRequestForRefresh:(BOOL)refresh {
    TCSTART
    if ([browseType caseInsensitiveCompare:@"videos"] == NSOrderedSame) {
        superVC.isBrowseVideosEnterBg = NO;
    } else if ([browseType caseInsensitiveCompare:@"people"] == NSOrderedSame) {
        superVC.isBrowsePeopleEnterBg = NO;
    } else if ([browseType caseInsensitiveCompare:@"tags"] == NSOrderedSame ) {
        superVC.isBrowseTagsEnterBg = NO;
    }
    [appDelegate makeRequestForBrowseOfType:browseType pageNumber:pageNumber perPage:10 andCaller:self];
    if (!requestForPagination && !refresh) {
        [appDelegate showActivityIndicatorInView:self.view andText:@""];
    }
    [appDelegate showNetworkIndicator];
    TCEND
}

- (void)makeTrendsRequestforPagination:(BOOL)requestForPagination andPageNumber:(NSInteger) pageNumber andRequestForRefresh:(BOOL)refresh {
    TCSTART
    [appDelegate makeRequestForTrendsPageNumber:pageNumber andCaller:self];
    if (!requestForPagination && !refresh) {
        [appDelegate showActivityIndicatorInView:self.view andText:@""];
    }
    [appDelegate showNetworkIndicator];
    TCEND
}
- (void)didFinishedToGetBrowseDetails:(NSDictionary *)results {
    TCSTART
    [displayVideosArray removeAllObjects];
    displayVideosArray = nil;
    [appDelegate removeNetworkIndicatorInView:self.view];
    [appDelegate hideNetworkIndicator];
    [self dataSourceDidFinishLoadingNewData];
    if ([self isNotNull:[results objectForKey:@"pagenumber"]] && [[results objectForKey:@"pagenumber"] integerValue] == 1 && [self isNotNull:[browseDict objectForKey:browseType]]) {
        [browseDict removeObjectForKey:browseType];
    }
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"results"]]) {
        if ([[results objectForKey:@"browseType"] caseInsensitiveCompare:@"videos"] == NSOrderedSame) {
            NSMutableArray *videoArr;
            if ([self isNotNull:[browseDict objectForKey:@"videos"]]) {
                videoArr = [browseDict objectForKey:@"videos"];
                [videoArr addObjectsFromArray:[results objectForKey:@"results"]];
            } else {
                videoArr = [NSMutableArray arrayWithArray:[results objectForKey:@"results"]];
            }
            [browseDict setObject:videoArr forKey:@"videos"];
            [browseDict setObject:[results objectForKey:@"pagenumber"] forKey:@"videosBrowsePgNum"];
        } else if ([[results objectForKey:@"browseType"] caseInsensitiveCompare:@"people"] == NSOrderedSame) {
            NSMutableArray *videoArr;
            if ([self isNotNull:[browseDict objectForKey:@"people"]]) {
                videoArr = [browseDict objectForKey:@"people"];
                [videoArr addObjectsFromArray:[results objectForKey:@"results"]];
            } else {
                videoArr = [NSMutableArray arrayWithArray:[results objectForKey:@"results"]];
            }
            [browseDict setObject:videoArr forKey:@"people"];
            [browseDict setObject:[results objectForKey:@"pagenumber"] forKey:@"peopleBrowsePgNum"];
            
        } else if ([[results objectForKey:@"browseType"] caseInsensitiveCompare:@"tags"] == NSOrderedSame) {
            NSMutableArray *videoArr;
            if ([self isNotNull:[browseDict objectForKey:@"tags"]]) {
                videoArr = [browseDict objectForKey:@"tags"];
                [videoArr addObjectsFromArray:[results objectForKey:@"results"]];
            } else {
                videoArr = [NSMutableArray arrayWithArray:[results objectForKey:@"results"]];
            }
            [browseDict setObject:videoArr forKey:@"tags"];
            [browseDict setObject:[results objectForKey:@"pagenumber"] forKey:@"tagsBrowsePgNum"];
        } else if ([[results objectForKey:@"browseType"] caseInsensitiveCompare:@"trends"] == NSOrderedSame) {
            NSMutableArray *videoArr;
            if ([self isNotNull:[browseDict objectForKey:@"trends"]]) {
                videoArr = [browseDict objectForKey:@"trends"];
                [videoArr addObjectsFromArray:[results objectForKey:@"results"]];
            } else {
                videoArr = [NSMutableArray arrayWithArray:[results objectForKey:@"results"]];
            }
            [browseDict setObject:videoArr forKey:@"trends"];
            [browseDict setObject:[results objectForKey:@"pagenumber"] forKey:@"trendsBrowsePgNum"];
        }
        
    }
    if ([self isNotNull:[browseDict objectForKey:browseType]]) {
        displayVideosArray = [NSMutableArray arrayWithArray:[browseDict objectForKey:browseType]];
        pageNum = [[browseDict objectForKey:[NSString stringWithFormat:@"%@BrowsePgNum",browseType]] intValue];
    }
    [browseTableView reloadData];
    TCEND
}
- (void)didFailToGetBrowseDetailsWithError:(NSDictionary *)errorDict {
    TCSTART
    [self dataSourceDidFinishLoadingNewData];
    [appDelegate removeNetworkIndicatorInView:self.view];
    [appDelegate hideNetworkIndicator];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    
    TCEND
}


- (void)makeSearchRequestWithSearchString:(NSString *)searchString  andPageNumber:(NSInteger)pageNumber requestForPagination:(BOOL)requestForPagination {
    TCSTART
    
    if (searchString.length > 0) {
        searchString = [appDelegate removingLastSpecialCharecter:searchString];
    }
    if (searchString.length > 0) {
        reqMadeForSearch = YES;
        [searchDict setObject:searchString forKey:[NSString stringWithFormat:@"%@SearchString",browseType]];
        [appDelegate makeRequestForBrowseSearchWithString:searchString ofBrowseType:browseType pageNumber:pageNumber perPage:50 andCaller:self];
        if (!requestForPagination) {
            [searchDict removeObjectForKey:browseType];
            [appDelegate showActivityIndicatorInView:self.view andText:@""];
        }
        [appDelegate showNetworkIndicator];
    } else {
        [ShowAlert showWarning:@"Please enter search keyword"];
    }
    
    TCEND
}

- (void)didFinishedToGetSearchDetails:(NSDictionary *)results {
    TCSTART
    [displayVideosArray removeAllObjects];
    [appDelegate removeNetworkIndicatorInView:self.view];
    [appDelegate hideNetworkIndicator];
    if ([self isNotNull:results] && [self isNotNull:[results objectForKey:@"results"]]) {
        if ([[results objectForKey:@"browseType"] caseInsensitiveCompare:@"videos"] == NSOrderedSame) {
            NSMutableArray *videoArr;
            if ([self isNotNull:[searchDict objectForKey:@"videos"]]) {
                videoArr = [searchDict objectForKey:@"videos"];
                [videoArr addObjectsFromArray:[results objectForKey:@"results"]];
            } else {
                videoArr = [NSMutableArray arrayWithArray:[results objectForKey:@"results"]];
            }
            [searchDict setObject:videoArr forKey:@"videos"];
            [searchDict setObject:[results objectForKey:@"pagenumber"] forKey:@"videosSearchPgNum"];
        } else if ([[results objectForKey:@"browseType"] caseInsensitiveCompare:@"people"] == NSOrderedSame) {
            NSMutableArray *videoArr;
            if ([self isNotNull:[searchDict objectForKey:@"people"]]) {
                videoArr = [searchDict objectForKey:@"people"];
                [videoArr addObjectsFromArray:[results objectForKey:@"results"]];
            } else {
                videoArr = [NSMutableArray arrayWithArray:[results objectForKey:@"results"]];
            }
            [searchDict setObject:videoArr forKey:@"people"];
            [searchDict setObject:[results objectForKey:@"pagenumber"] forKey:@"peopleSearchPgNum"];
        } else if ([[results objectForKey:@"browseType"] caseInsensitiveCompare:@"tags"] == NSOrderedSame) {
            NSMutableArray *videoArr;
            if ([self isNotNull:[searchDict objectForKey:@"tags"]]) {
                videoArr = [searchDict objectForKey:@"tags"];
                [videoArr addObjectsFromArray:[results objectForKey:@"results"]];
            } else {
                videoArr = [NSMutableArray arrayWithArray:[results objectForKey:@"results"]];
            }
            [searchDict setObject:videoArr forKey:@"tags"];
            [searchDict setObject:[results objectForKey:@"pagenumber"] forKey:@"tagsSearchPgNum"];
        } else if ([[results objectForKey:@"browseType"] caseInsensitiveCompare:@"trends"] == NSOrderedSame) {
            NSMutableArray *videoArr;
            if ([self isNotNull:[searchDict objectForKey:@"trends"]]) {
                videoArr = [searchDict objectForKey:@"trends"];
                [videoArr addObjectsFromArray:[results objectForKey:@"results"]];
            } else {
                videoArr = [NSMutableArray arrayWithArray:[results objectForKey:@"results"]];
            }
            [searchDict setObject:videoArr forKey:@"trends"];
            [searchDict setObject:[results objectForKey:@"pagenumber"] forKey:@"trendsSearchPgNum"];
        }
         pageNum = [[results objectForKey:@"pagenumber"] intValue];
    }
    
    if ([self isNotNull:[searchDict objectForKey:browseType]]) {
        displayVideosArray = [NSMutableArray arrayWithArray:[searchDict objectForKey:browseType]];
        pageNum = [[searchDict objectForKey:[NSString stringWithFormat:@"%@SearchPgNum",browseType]] intValue];
    }
    
    [browseTableView reloadData];
    
    TCEND
}
- (void)didFailToGetSearchDetailsWithError:(NSDictionary *)errorDict {
    TCSTART
    [browseTableView reloadData];
    [appDelegate removeNetworkIndicatorInView:self.view];
    [appDelegate hideNetworkIndicator];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}


- (void)refreshTableViewWithSelectedBrowseType {
    TCSTART
    [displayVideosArray removeAllObjects];
    displayVideosArray = nil;
    if (searchSelected && reqMadeForSearch) {
         displayVideosArray = [NSMutableArray arrayWithArray:[searchDict objectForKey:browseType]];
        pageNum = [[searchDict objectForKey:[NSString stringWithFormat:@"%@SearchPgNum",browseType]] intValue];
        if ([self isNotNull:[searchDict objectForKey:[NSString stringWithFormat:@"%@SearchString",browseType]]]) {
            videosSearchBar.text = [searchDict objectForKey:[NSString stringWithFormat:@"%@SearchString",browseType]];
        } else {
            videosSearchBar.text = @"";
            reqMadeForSearch = NO;
            [self refreshTableViewWithSelectedBrowseType];
        }
        
//        if (reqMadeForSearch) {
//           
//        } else {
//            displayVideosArray = [NSMutableArray arrayWithArray:[searchDict objectForKey:browseType]];
//        }
    } else {
        displayVideosArray = [NSMutableArray arrayWithArray:[browseDict objectForKey:browseType]];
        pageNum = [[browseDict objectForKey:[NSString stringWithFormat:@"%@BrowsePgNum",browseType]] intValue];
        if (([browseType caseInsensitiveCompare:@"videos"] == NSOrderedSame && superVC.isBrowseVideosEnterBg) || ([browseType caseInsensitiveCompare:@"people"] == NSOrderedSame && superVC.isBrowsePeopleEnterBg) || ([browseType caseInsensitiveCompare:@"tags"] == NSOrderedSame  && superVC.isBrowseTagsEnterBg) || ([browseType caseInsensitiveCompare:@"trends"] == NSOrderedSame && superVC.isBrowseTrendsEnterBg)) {
            [self refreshTheScreen];
        } 
    }
    [browseTableView reloadData];
    TCEND
}

- (void)applicationDidEnterForegroundNotificationFromMainVC {
    TCSTART
    if (([browseType caseInsensitiveCompare:@"videos"] == NSOrderedSame && superVC.isBrowseVideosEnterBg) || ([browseType caseInsensitiveCompare:@"people"] == NSOrderedSame && superVC.isBrowsePeopleEnterBg) || ([browseType caseInsensitiveCompare:@"tags"] == NSOrderedSame  && superVC.isBrowseTagsEnterBg) || ([browseType caseInsensitiveCompare:@"trends"] == NSOrderedSame && superVC.isBrowseTrendsEnterBg)) {
        [self refreshTheScreen];
    }
    TCEND
}
- (IBAction)onClickOfVideosTab:(id)sender {
    TCSTART
    browseType = @"videos";
    tabsImgView.image = [UIImage imageNamed:@"BrowseVideos"];
    if (([self isNull:[browseDict objectForKey:@"videos"]] || [[browseDict objectForKey:@"videos"] count] <= 0 ) && !searchSelected) {
        [self makeBrowseRequestforPagination:NO andPageNumber:1 andRequestForRefresh:NO];
    }
    if (searchSelected) {
        reqMadeForSearch = YES;
    }
    [self refreshTableViewWithSelectedBrowseType];
    TCEND
}

- (IBAction)onClickOfPeopleTab:(id)sender {
    TCSTART
    browseType = @"people";
    tabsImgView.image = [UIImage imageNamed:@"BrowsePeople"];
    if (([self isNull:[browseDict objectForKey:@"people"]] || [[browseDict objectForKey:@"people"] count] <= 0) && !searchSelected) {
        [self makeBrowseRequestforPagination:NO andPageNumber:1 andRequestForRefresh:NO];
    }
    if (searchSelected) {
        reqMadeForSearch = YES;
    }
    [self refreshTableViewWithSelectedBrowseType];
    TCEND
}
- (IBAction)onClickOfTagsTab:(id)sender {
    TCSTART
    browseType = @"tags";
    tabsImgView.image = [UIImage imageNamed:@"BrowseTags"];
    if (([self isNull:[browseDict objectForKey:@"tags"]] || [[browseDict objectForKey:@"tags"] count] <= 0) && !searchSelected) {
        [self makeBrowseRequestforPagination:NO andPageNumber:1 andRequestForRefresh:NO];
    }
    if (searchSelected) {
        reqMadeForSearch = YES;
    }
    [self refreshTableViewWithSelectedBrowseType];
    TCEND
}

- (IBAction)onClickOfTrendsTab:(id)sender {
    browseType = @"trends";
    tabsImgView.image = [UIImage imageNamed:@"BrowseTrends"];
    if (([self isNull:[browseDict objectForKey:@"trends"]] || [[browseDict objectForKey:@"trends"] count] <= 0) && !searchSelected) {
        pageNum = 1;
        [self makeTrendsRequestforPagination:NO andPageNumber:pageNum andRequestForRefresh:NO];
    }
    if (searchSelected) {
        reqMadeForSearch = YES;
    }
    [self refreshTableViewWithSelectedBrowseType];
}

//- (IBAction)onClickOfPagesTab:(id)sender {
//    TCSTART
//    browseType = @"pages";
//    tabsImgView.image = [UIImage imageNamed:@"BrowsePages"];
////    if (([self isNull:[browseDict objectForKey:@"pages"]] || [[browseDict objectForKey:@"pages"] count] <= 0) && !searchSelected) {
////        [self makeBrowseRequestforPagination:NO andPageNumber:1];
////    } else {
////        [self refreshTableViewWithSelectedBrowseTypePage:(searchSelected?@"pagesSearchPgNum":@"pagesBrowsePgNum")];
////    }
//    [self refreshTableViewWithSelectedBrowseTypePage:(searchSelected?@"pagesSearchPgNum":@"pagesBrowsePgNum")];
//    TCEND
//}

- (IBAction)onClickOfQuickLinksBtn:(id)sender {
    if ([self isNotNull:superVC] && [superVC respondsToSelector:@selector(onClickOfMenuButton)]) {
        [superVC onClickOfMenuButton];
    }
}

- (IBAction)onClickOfSearchBtn:(id)sender {
    TCSTART
    UIButton *searchBtn = (UIButton *)sender;
    CGFloat searchBarHeight = videosSearchBar.frame.size.height;
    if (searchBtn.tag == 1) {
        [videosSearchBar becomeFirstResponder];
        searchBtn.tag = 123;
        searchSelected = YES;
        //Search
        searchBtn.frame = CGRectMake(250, searchBtn.frame.origin.y, 65, searchBtn.frame.size.height);
        [searchBtn setBackgroundImage:[UIImage imageNamed:@"SearchCancel"] forState:UIControlStateNormal];
        [searchBtn setBackgroundImage:[UIImage imageNamed:@"SearchCancel_f"] forState:UIControlStateHighlighted];
        [searchBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        videosSearchBar.hidden = NO;
        searchBarBg.hidden = NO;
        tabsImgView.frame = CGRectMake(tabsImgView.frame.origin.x, tabsImgView.frame.origin.y + searchBarHeight , tabsImgView.frame.size.width, tabsImgView.frame.size.height);
        videosButton.frame = CGRectMake(videosButton.frame.origin.x, videosButton.frame.origin.y + searchBarHeight, videosButton.frame.size.width, videosButton.frame.size.height);
        peopleButton.frame = CGRectMake(peopleButton.frame.origin.x, peopleButton.frame.origin.y + searchBarHeight, peopleButton.frame.size.width, peopleButton.frame.size.height);
        tagsButton.frame = CGRectMake(tagsButton.frame.origin.x, tagsButton.frame.origin.y + searchBarHeight, tagsButton.frame.size.width, tagsButton.frame.size.height);
        trendsButton.frame = CGRectMake(trendsButton.frame.origin.x, trendsButton.frame.origin.y + searchBarHeight, trendsButton.frame.size.width, trendsButton.frame.size.height);
        browseTableView.frame = CGRectMake(browseTableView.frame.origin.x, browseTableView.frame.origin.y + searchBarHeight, browseTableView.frame.size.width, browseTableView.frame.size.height - searchBarHeight);
    } else {
        reqMadeForSearch = NO;
        [videosSearchBar resignFirstResponder];
        searchBtn.tag = 1;
        //cancel
        searchSelected = NO;
        videosSearchBar.hidden = YES;
        searchBarBg.hidden = YES;
        [searchDict removeAllObjects];
        videosSearchBar.text = @"";
        searchBtn.frame = CGRectMake(285, searchBtn.frame.origin.y, 30, searchBtn.frame.size.height);
        [searchBtn setBackgroundImage:[UIImage imageNamed:@"HomeSearch"] forState:UIControlStateNormal];
        [searchBtn setBackgroundImage:[UIImage imageNamed:@"HomeSearch"] forState:UIControlStateHighlighted];
        [searchBtn setTitle:@"" forState:UIControlStateNormal];
        tabsImgView.frame = CGRectMake(tabsImgView.frame.origin.x, tabsImgView.frame.origin.y - searchBarHeight , tabsImgView.frame.size.width, tabsImgView.frame.size.height);
        videosButton.frame = CGRectMake(videosButton.frame.origin.x, videosButton.frame.origin.y - searchBarHeight, videosButton.frame.size.width, videosButton.frame.size.height);
        peopleButton.frame = CGRectMake(peopleButton.frame.origin.x, peopleButton.frame.origin.y - searchBarHeight, peopleButton.frame.size.width, peopleButton.frame.size.height);
        tagsButton.frame = CGRectMake(tagsButton.frame.origin.x, tagsButton.frame.origin.y - searchBarHeight, tagsButton.frame.size.width, tagsButton.frame.size.height);
        trendsButton.frame = CGRectMake(trendsButton.frame.origin.x, trendsButton.frame.origin.y - searchBarHeight, trendsButton.frame.size.width, trendsButton.frame.size.height);
        browseTableView.frame = CGRectMake(browseTableView.frame.origin.x, browseTableView.frame.origin.y - searchBarHeight, browseTableView.frame.size.width, browseTableView.frame.size.height + searchBarHeight);
        [self refreshTableViewWithSelectedBrowseType];
    }
    
    TCEND
}

- (void)customizeSearchBar {
    @try {
        searchBarBg.backgroundColor = [appDelegate colorWithHexString:@"4f4f51"];
        videosSearchBar.placeholder = @"Search";
        videosSearchBar.keyboardType = UIKeyboardTypeDefault;
        videosSearchBar.barStyle = UIBarStyleDefault;
        videosSearchBar.delegate = self;
        
        [self setBackgroundForSearchBar:videosSearchBar withImagePath:@"SearchBarBg"];
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
            [searchField setBackground: [UIImage imageNamed:imgPath] ];
            
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

#pragma mark
#pragma searchBarDelegate Methods
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    @try {
        //        if (searchBar.tag == -10) {
        //            categorySearchPhrase = searchText;
        //        } else if (searchBar.tag == 10) {
        //            locationSearchPhrase = searchText;
        //        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    @try {
        [self makeSearchRequestWithSearchString:searchBar.text andPageNumber:1 requestForPagination:NO];
        [searchBar resignFirstResponder];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark Tableview Delegate and Datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //    NSLog(@"PageNumber X PageSize : %d \n VideosCount :%d",pageNum * 10,displayVideosArray.count);
    if(([browseType caseInsensitiveCompare:@"videos"] == NSOrderedSame || [browseType caseInsensitiveCompare:@"people"] == NSOrderedSame || [browseType caseInsensitiveCompare:@"tags"] == NSOrderedSame || [browseType caseInsensitiveCompare:@"trends"] == NSOrderedSame) && displayVideosArray.count >= pageNum * 10 && displayVideosArray.count > 0) {
        return displayVideosArray.count + 1;
    } else {
        return displayVideosArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (searchSelected && reqMadeForSearch && displayVideosArray.count <= 0 && videosSearchBar.text.length > 0) {
        return 40;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TCSTART
    if (searchSelected && reqMadeForSearch && displayVideosArray.count <= 0 && section == 0 && videosSearchBar.text.length > 0) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        UILabel *descLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        descLbl.font = [UIFont fontWithName:descriptionTextFontName size:15];
        descLbl.textColor = [UIColor blackColor];
        descLbl.backgroundColor = [UIColor clearColor];
        descLbl.textAlignment = UITextAlignmentCenter;
        descLbl.numberOfLines = 0;
        descLbl.text = @"No search results available, Please try again with different keyword";
        [headerView addSubview:descLbl];
        return headerView;
        //
    }
    
    TCEND
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == displayVideosArray.count) {
        return 40;
    } else if ([browseType caseInsensitiveCompare:@"people"] == NSOrderedSame) {
        return 60;
    } else if ([browseType caseInsensitiveCompare:@"trends"] == NSOrderedSame) {
        return 160 + 30 + 3 + 10; // 10 for gap
    }
    if (displayVideosArray.count > indexPath.row) {
        VideoModal *video = [displayVideosArray objectAtIndex:indexPath.row];
        if ([self isNotNull:video]) {
            if (video.numberOfCmnts.integerValue <= 0 && video.numberOfLikes.integerValue <= 0 && video.numberOfTags.integerValue <= 0) {
                return 160 + 50; // 50 for optionsview
            }
            return 160 + 50 + 30; // 30 for numberoftags/likes/comments view
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    //show the load more activity with text if array count is equal to current row index.
    UITableViewCell *indicatorCell;
    static NSString *loadMoreCellIdentifier = @"loadMoreCellIdentifier";
    if(indexPath.row ==  displayVideosArray.count) {
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
    }
    
    if ([browseType caseInsensitiveCompare:@"people"] == NSOrderedSame) {
        static NSString *cellIdentifier = @"SuggestedUserCellID";
        SuggestedUserCell *cell = (SuggestedUserCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil) {
            cell = [[SuggestedUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        UserModal *user = [displayVideosArray objectAtIndex:indexPath.row];
        if ([self isNotNull:user.photoPath]) {
            [cell.userProfileImgView setImageWithURL:[NSURL URLWithString:user.photoPath] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached];
        } else {
            [cell.userProfileImgView setImage:[UIImage imageNamed:@"OwnerPic"]];
        }
        cell.userProfileImgView.layer.cornerRadius = 22.5f;
        cell.userProfileImgView.layer.borderWidth = 1.5f;
        cell.userProfileImgView.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
        cell.userProfileImgView.layer.masksToBounds = YES;
        
        if ([self isNotNull:user.userName]) {
            cell.userNameLbl.text = user.userName;
        } else {
            cell.userNameLbl.text = @"";
        }
        cell.userNameLbl.textColor = [appDelegate colorWithHexString:@"11a3e7"];

        if ([self isNotNull:user.userDesc]) {
            cell.descLbl.text = user.userDesc;
            cell.userNameLbl.frame = CGRectMake(70, 9, 200, 21);
        } else {
            cell.descLbl.text = @"";
            cell.userNameLbl.frame = CGRectMake(70, 10, 200, 40);
        }
        
        if ([self isNotNull:user.userId] && [appDelegate.loggedInUser.userId intValue] != [user.userId intValue]) {
            cell.addBtn.hidden = NO;
            if (!user.youFollowing) {
                [cell.addBtn setBackgroundImage:[UIImage imageNamed:@"AddSuggestedUser"] forState:UIControlStateNormal];
                [cell.addBtn setBackgroundColor:[UIColor clearColor]];
                //            cell.addBtn.hidden = NO;
            } else {
                //            cell.addBtn.hidden = YES;
                [cell.addBtn setBackgroundImage:[UIImage imageNamed:@"UnfollowSuggestedUser"] forState:UIControlStateNormal];
            }
            [cell.addBtn addTarget:self action:@selector(clickedOnFollowBtn:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            cell.addBtn.hidden = YES;
        }
       
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.inviteBtn.hidden = YES;
        return cell;
    } else {
        static NSString *cellIdentifier = @"BrowseCellID";
        BrowseCell *cell = (BrowseCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil) {
            cell = [[BrowseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell.tagsViewBgLbl.hidden = NO;
        cell.tagsViewsBg.hidden = NO;
        if ([browseType caseInsensitiveCompare:@"trends"] == NSOrderedSame) {
            cell.optionsView.hidden = YES;
            cell.tagsView.hidden = YES;
            cell.likesView.hidden = YES;
            cell.commentsView.hidden = YES;
            cell.videosView.hidden = NO;
            cell.videoPlayBtn.hidden = YES;
            cell.dividerLbl.hidden = NO;
        } else {
            cell.optionsView.hidden = NO;
            cell.tagsView.hidden = NO;
            cell.likesView.hidden = NO;
            cell.commentsView.hidden = NO;
            cell.videosView.hidden = YES;
            cell.videoPlayBtn.hidden = NO;
            cell.dividerLbl.hidden = YES;
        }
        
        cell.tagsViewBgLbl.backgroundColor = [appDelegate colorWithHexString:@"fafafa"];
        cell.dividerLbl.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
        
        [cell.videoPlayBtn addTarget:self action:@selector(playVideo: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        VideoModal *video = [displayVideosArray objectAtIndex:indexPath.row];
        
        //Likes
        [cell.likesBtn addTarget:self action:@selector(onClickOfGetAllVideoUsersLoved: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        cell.numberOfLikesLbl.text =  [NSString stringWithFormat:@"%@ Like%@",[appDelegate getUserStatisticsFormatedString:[video.numberOfLikes longLongValue]],[appDelegate returningPluralFormWithCountForLikes:[video.numberOfLikes integerValue]]];
        
        //Comments
        [cell.commentsBtn addTarget:self action:@selector(seeAllCommentsOfVideo: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        cell.numberofCmntsLbl.text = [NSString stringWithFormat:@"%@ Comment%@",[appDelegate getUserStatisticsFormatedString:[video.numberOfCmnts longLongValue]],[appDelegate returningPluralFormWithCount:[video.numberOfCmnts integerValue]]];
        
        //Tags
        cell.numberOfTagsLbl.text = [NSString stringWithFormat:@"%@ Tag%@",[appDelegate getUserStatisticsFormatedString:[video.numberOfTags longLongValue]],[appDelegate returningPluralFormWithCount:[video.numberOfTags integerValue]]];
        
        cell.numberOfVideosLbl.text = [NSString stringWithFormat:@"%@ Video%@",[appDelegate getUserStatisticsFormatedString:[video.numberOfVideosOfHashTag longLongValue]],[appDelegate returningPluralFormWithCount:[video.numberOfVideosOfHashTag integerValue]]];
        
        if ([browseType caseInsensitiveCompare:@"trends"] == NSOrderedSame) {
            cell.tagsViewsBg.frame = CGRectMake(40, 160, 240, 30);
            cell.videosView.frame = CGRectMake(81, 0, 77, 30);
        } else {
            [self setVisibilityForTagsCommentsAndLovedForCell:cell atVideo:video];
            CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
            cell.optionsView.frame = CGRectMake(cell.optionsView.frame.origin.x, cellRect.size.height - 50, cell.optionsView.frame.size.width, cell.optionsView.frame.size.height);
        }
        
        if ([self isNotNull:video.latestTagExpression]) {
            cell.latestTagLabel.text = video.latestTagExpression;
            cell.tagImg.hidden = NO;
            CGSize size = [video.latestTagExpression sizeWithFont:[UIFont fontWithName:dateFontName size:12] constrainedToSize:CGSizeMake(290, 20)];
            CGFloat width = 20 + size.width;
            cell.latestTagLabel.frame = CGRectMake(20, cell.latestTagLabel.frame.origin.y, size.width, cell.latestTagLabel.frame.size.height);
            cell.latestTagBg.frame = CGRectMake((320 - width)/2, cell.latestTagBg.frame.origin.y, width, cell.latestTagBg.frame.size.height);
        } else {
            cell.latestTagLabel.text = video.title;
            cell.tagImg.hidden = YES;
            CGSize size = [video.title sizeWithFont:[UIFont fontWithName:dateFontName size:12] constrainedToSize:CGSizeMake(310, 20)];
            CGFloat width = size.width;

            cell.latestTagLabel.frame = CGRectMake(0, cell.latestTagLabel.frame.origin.y, size.width, cell.latestTagLabel.frame.size.height);
            cell.latestTagBg.frame = CGRectMake((320 - width)/2, cell.latestTagBg.frame.origin.y, width, cell.latestTagBg.frame.size.height);
        }
        if ([self isNotNull:video.videoThumbPath]) {
            [cell.videoCoverBgImgView setImageWithURL:[NSURL URLWithString:video.videoThumbPath] placeholderImage:[UIImage imageNamed:@"DefaultVideoThumb"] ];
        } else {
            cell.videoCoverBgImgView.image = [UIImage imageNamed:@"DefaultVideoThumb"];
        }
    
        [cell.commentBtn addTarget:self action:@selector(seeAllCommentsOfVideo: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        if (video.hasCommentedOnVideo) {
            [cell.commentBtn setImage:[UIImage imageNamed:@"OptionCmnt"] forState:UIControlStateNormal];
        } else {
            [cell.commentBtn setImage:[UIImage imageNamed:@"OptionUnCmnt"] forState:UIControlStateNormal];
        }
        
        [cell.likeBtn addTarget:self action:@selector(onClickOfLikeBtn: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        if (video.hasLovedVideo) {
            [cell.likeBtn setImage:[UIImage imageNamed:@"OptionLoved"] forState:UIControlStateNormal];
        } else {
            [cell.likeBtn setImage:[UIImage imageNamed:@"OptionUnLoved"] forState:UIControlStateNormal];
        }
        
        [cell.optionsBtn setTitleColor:[appDelegate colorWithHexString:@"11a3e7"] forState:UIControlStateNormal];
        [cell.optionsBtn addTarget:self action:@selector(onClickOfOptionsBtn: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        
        return cell;
    }
    
    TCEND
}

- (void)setVisibilityForTagsCommentsAndLovedForCell:(BrowseCell *)cell atVideo:(VideoModal *)video {
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        if (indexPath.row == displayVideosArray.count) {
            [self performSelector:@selector(loadMoreActivities:) withObject:nil afterDelay:0.001];
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
    if (indexPath.row < displayVideosArray.count) {
        if ([browseType caseInsensitiveCompare:@"videos"] == NSOrderedSame || [browseType caseInsensitiveCompare:@"tags"] == NSOrderedSame) {
//            BrowseDetailViewController *browseDetailVC = [[BrowseDetailViewController alloc] initWithNibName:@"BrowseDetailViewController" bundle:nil withVideosArray:[self getAllVideoDictsArrayToPassToBrowseDetailVC:displayVideosArray] selectedIndex:indexPath.row];
//            [self.navigationController pushViewController:browseDetailVC animated:YES];
        } else if ([browseType caseInsensitiveCompare:@"trends"] == NSOrderedSame ) {
            VideoModal *videoModal = [displayVideosArray objectAtIndex:indexPath.row];
            TrendsDetailsViewController *trendsDetialsVC = [[TrendsDetailsViewController alloc] initWithNibName:@"TrendsDetailsViewController" bundle:nil SelectedTagName:videoModal.latestTagExpression];
            [self.navigationController pushViewController:trendsDetialsVC animated:YES];
        } else {
             UserModal *user = [displayVideosArray objectAtIndex:indexPath.row];
            if ([self isNotNull:user.userId] && user.userId.intValue != [appDelegate.loggedInUser.userId intValue]) {
                OthersPageViewController *otherPageVC = [[OthersPageViewController alloc] initWithNibName:@"OthersPageViewController" bundle:Nil andUser:user.userId];
                [self.navigationController pushViewController:otherPageVC animated:YES];
                otherPageVC.selectedIndexPath = indexPath;
                otherPageVC.caller = self;
            }
        }
    }
    TCEND
}

#pragma mark optionsView
- (void)onClickOfOptionsBtn:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    //    [ShowAlert showAlert:@"In Development"];
    selectedIndexPath = [appDelegate getIndexPathForEvent:event ofTableView:browseTableView];
    VideoModal *video = [displayVideosArray objectAtIndex:selectedIndexPath.row];
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
        VideoModal *video = [displayVideosArray objectAtIndex:selectedIndexPath.row];
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
        VideoModal *video = [displayVideosArray objectAtIndex:indexPath.row];
        if ([self isNotNull:video]) {
            [appDelegate showActivityIndicatorInView:self.view andText:@"Deleting"];
            [appDelegate showNetworkIndicator];
            [appDelegate makeRequestForDeleteVideoWithVideoId:video.videoId andUserId:appDelegate.loggedInUser.userId andCaller:self atIndexpath:indexPath];
        }
    }
    TCEND
}

#pragma mark Report Video Delegate methods
- (void)reportVideoAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [displayVideosArray objectAtIndex:indexPath.row];
        if ([self isNotNull:video]) {
            ReportVideoViewController *reportVC = [[ReportVideoViewController alloc] initWithNibName:@"ReportVideoViewController" bundle:nil forVideo:video.videoId];
            [self presentViewController:reportVC animated:YES completion:nil];
        }
    }
    TCEND
}

#pragma mark Goto Shareviewcontroller
- (void)accessPermissionOfVideoAtIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [displayVideosArray objectAtIndex:indexPath.row];
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
        VideoModal *video = [displayVideosArray objectAtIndex:indexPath.row];
        if ([self isNotNull:video]) {
            ShareViewController *shareVC = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil withSelectedVideo:video andCaller:self];
            [self.navigationController pushViewController:shareVC animated:YES];
        }
    }
    TCEND
}

#pragma mark Video Play
- (void)playVideo:(id)sender withEvent:(UIEvent *)event  {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:browseTableView];
    [self gotoPlayerScreenWithIndexPath:indexPath];
    TCEND
}

- (void)gotoPlayerScreenWithIndexPath:(NSIndexPath *)indexPath {
    TCSTART
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [displayVideosArray objectAtIndex:indexPath.row];
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
            video = [displayVideosArray objectAtIndex:indexPath.row];
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

#pragma mark Get All Likes Delegate Methods
- (void)onClickOfGetAllVideoUsersLoved:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:browseTableView];
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [displayVideosArray objectAtIndex:indexPath.row];
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
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:browseTableView];
    UIButton *likeBtn = (UIButton *)sender;
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [displayVideosArray
                             objectAtIndex:indexPath.row];
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
        VideoModal *video = [displayVideosArray objectAtIndex:indexpath.row];
        NSInteger likesCount = [video.numberOfLikes integerValue];
        likesCount = likesCount + 1;
        video.numberOfLikes = [NSNumber numberWithInteger:likesCount];
        
        NSMutableArray *likeList = [[NSMutableArray alloc] initWithArray:video.likesList];
        [likeList insertObject:[NSDictionary dictionaryWithObjectsAndKeys:appDelegate.loggedInUser.userId,@"user_id",appDelegate.loggedInUser.userName?:@"",@"user_name", nil] atIndex:0];
        video.likesList = likeList;
        video.hasLovedVideo = YES;
        
        [browseTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexpath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
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
        VideoModal *video = [displayVideosArray objectAtIndex:indexpath.row];
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
        
        [browseTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexpath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:browseTableView];
    if ([self isNotNull:indexPath]) {
        VideoModal *video = [displayVideosArray objectAtIndex:indexPath.row];
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
            VideoModal *video = [displayVideosArray objectAtIndex:indexPath.row];
            [appDelegate moveLoggedInUserToTopInLikesListOfVideoModal:video];
        }
        [browseTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    appDelegate.videoFeedVC.mainVC.customTabView.hidden = NO;
    allCmntsVC = nil;
    customMoviePlayerVC = nil;
    TCEND
}


- (NSMutableArray *)getAllVideoDictsArrayToPassToBrowseDetailVC:(NSArray *)array {
    TCSTART
    NSMutableArray *browseDetialsArray = [[NSMutableArray alloc] init];
    for (VideoModal *video in array) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:video.videoId?:@"",@"video_id",video.userId?:@"",@"user_id",[NSNumber numberWithInt:1],@"pgnum", nil];
        [browseDetialsArray addObject:dict];
    }
    return browseDetialsArray;
    TCEND
}

- (void) onClickOfUserProfileImageBtn:(id)sender {
    TCSTART
    UIButton *userNameBtn = (UIButton *)sender;
    if (userNameBtn.tag != [appDelegate.loggedInUser.userId integerValue]) {
        OthersPageViewController *otherPageVC = [[OthersPageViewController alloc] initWithNibName:@"OthersPageViewController" bundle:Nil andUser:[NSString stringWithFormat:@"%d",userNameBtn.tag]];
        [self.navigationController pushViewController:otherPageVC animated:YES];
        otherPageVC.caller = self;
    }
    TCEND
}

- (void)clickedOnFollowBtn:(id)sender withEvent:(UIEvent *)event {
    TCSTART
    NSIndexPath *indexPath = [appDelegate getIndexPathForEvent:event ofTableView:browseTableView];
    UserModal *selectedUser = [displayVideosArray objectAtIndex:indexPath.row];
    if (selectedUser.youFollowing) {
        [appDelegate makeUnFollowUserWithUserId:appDelegate.loggedInUser.userId followerId:selectedUser.userId andCaller:self andIndexPath:indexPath];
    } else {
        [appDelegate makeFollowUserWithUserId:appDelegate.loggedInUser.userId followerId:selectedUser.userId andCaller:self andIndexPath:indexPath];
    }
    TCEND
}

- (void)updateCellWithUnFollowedUserWithIndexPath:(NSIndexPath *)indexpath {
    TCSTART
    UserModal *selectedUser = [displayVideosArray objectAtIndex:indexpath.row];
    selectedUser.youFollowing = NO;
    
    NSInteger totalFollowings = [appDelegate.loggedInUser.totalNoOfFollowings integerValue];
    totalFollowings = totalFollowings - 1;
    appDelegate.loggedInUser.totalNoOfFollowings = [NSNumber numberWithInt:totalFollowings];
    
    SuggestedUserCell *cell = (SuggestedUserCell *)[browseTableView cellForRowAtIndexPath:indexpath];
    [cell.addBtn setBackgroundImage:[UIImage imageNamed:@"AddSuggestedUser"] forState:UIControlStateNormal];
    TCEND
}

- (void)didFinishedToUnFollowUser:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
//    [ShowAlert showAlert:@"Unfollowed successfully"];
    [self updateCellWithUnFollowedUserWithIndexPath:[results objectForKey:@"indexpath"]];
    TCEND
}

- (void)didFailToUnFollowUserWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

- (void)updateCellWithFollowedUserWithIndexPath:(NSIndexPath *)indexpath {
    TCSTART
    UserModal *selectedUser = [displayVideosArray objectAtIndex:indexpath.row];
    if ([self isNotNull:selectedUser]) {
        [displayVideosArray removeObject:selectedUser];
    }
    [browseTableView reloadData];
    
    NSInteger totalFollowings = [appDelegate.loggedInUser.totalNoOfFollowings integerValue];
    totalFollowings = totalFollowings + 1;
    appDelegate.loggedInUser.totalNoOfFollowings = [NSNumber numberWithInt:totalFollowings];
    
    TCEND
}
- (void)didFinishedToFollowUser:(NSDictionary *)results {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
//    [ShowAlert showAlert:@"Followed successfully"];
    [self updateCellWithFollowedUserWithIndexPath:[results objectForKey:@"indexpath"]];
    TCEND
}
- (void)didFailToFollowUserWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:appDelegate.window];
    [ShowAlert showError:[errorDict objectForKey:@"msg"]];
    TCEND
}

- (void)followedUserFromOtherPageViewControllerWithSelectedIndex:(NSIndexPath *)indexPath andUserId:(NSString *)userId {
    TCSTART
    if ([browseType caseInsensitiveCompare:@"people"] == NSOrderedSame) {
        [self updateCellWithFollowedUserWithIndexPath:indexPath];
    } else {
        NSArray *array;
        if (searchSelected && reqMadeForSearch) {
            array = [searchDict objectForKey:@"people"];
        } else {
            array = [browseDict objectForKey:@"people"];
        }
        for (UserModal *user in array) {
            if ([self isNotNull:user.userId] &&  [user.userId intValue] == [userId intValue]) {
                user.youFollowing = YES;
            }
        }
    }
    TCEND
}
- (void)unFollowedUserFromOtherPageViewControllerWithSelectedIndex:(NSIndexPath *)indexPath andUserId:(NSString *)userId {
    TCSTART
    if ([browseType caseInsensitiveCompare:@"people"] == NSOrderedSame) {
        [self updateCellWithUnFollowedUserWithIndexPath:indexPath];
    } else {
        NSArray *array;
        if (searchSelected && reqMadeForSearch) {
            array = [searchDict objectForKey:@"people"];
        } else {
            array = [browseDict objectForKey:@"people"];
        }
        for (UserModal *user in array) {
            if ([self isNotNull:user.userId] && [user.userId intValue] == [userId intValue]) {
                user.youFollowing = NO;
            }
        }
    }
    TCEND
}

#pragma mark LoadMoreActivities ==================================================
- (void)loadMoreActivities:(id)sender {
    
    @try {
        if (searchSelected && reqMadeForSearch) {
            pageNum++;
            [self makeSearchRequestWithSearchString:videosSearchBar.text andPageNumber:pageNum requestForPagination:YES];
        } else {
            pageNum++;
            if ([browseType caseInsensitiveCompare:@"trends"] == NSOrderedSame) {
                [self makeTrendsRequestforPagination:YES andPageNumber:pageNum andRequestForRefresh:NO];
            } else {
                [self makeBrowseRequestforPagination:YES andPageNumber:pageNum andRequestForRefresh:NO];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}


#pragma mark Table ScrollView Methods
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    @try {
        [videosSearchBar resignFirstResponder];
        if (!reloading && !searchSelected) {
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
        if (reloading && !searchSelected) return;
        
        if (checkForRefresh && !searchSelected) {
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
        if (reloading && !searchSelected) return;
        
        if (scrollView.contentOffset.y <= -45.0f) {
            [self showReloadAnimationAnimated:YES];
            [self refreshTheScreen];
        }
        if (!searchSelected) {
            checkForRefresh = NO;
        }
        
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
        if (!searchSelected) {
            reloading = YES;
            [refreshView toggleActivityView:YES];
        }
        
        if (animated && !searchSelected) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.2];
            browseTableView.contentInset = UIEdgeInsetsMake(40.0f, 0.0f, 0.0f, 0.0f);
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
        [browseTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
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

- (void)refreshTheScreen {
    if (!searchSelected) {
        if ([browseType caseInsensitiveCompare:@"trends"] == NSOrderedSame) {
            superVC.isBrowseTrendsEnterBg = NO;
            pageNum = 1;
            [self makeTrendsRequestforPagination:NO andPageNumber:pageNum andRequestForRefresh:YES];
        } else {
            pageNum = 1;
            [self makeBrowseRequestforPagination:NO andPageNumber:pageNum andRequestForRefresh:YES];
        }
    }
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
