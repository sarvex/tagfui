/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>

@interface TrendsDetailsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UserServiceDelegate,BrowseServiceDelegate,UIActionSheetDelegate,VideoServiceDelegate> {
    IBOutlet UITableView *trendsTableView;
    IBOutlet UILabel *titleLabel;
    WooTagPlayerAppDelegate *appDelegate;
    AllCommentsViewController *allCmntsVC;
    NSMutableArray *displayTrendsArray;
    NSInteger pageNumber;
    NSIndexPath *selectedIndexPath;
    
    NSString *tagName;
    
    id caller;
}

@property (nonatomic, retain) id caller;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil SelectedTagName:(NSString *)tagName_;

- (IBAction)goBack:(id)sender;
- (void)allCommentsScreenDismissCalledSelectedIndexPath:(NSIndexPath *)indexPath andViewType:(NSString *)viewType;

- (void)playBackResponse:(NSDictionary *)results;
@end
