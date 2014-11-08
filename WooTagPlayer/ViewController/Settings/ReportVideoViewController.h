/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"

@interface ReportVideoViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,VideoServiceDelegate> {
    WooTagPlayerAppDelegate *appDelegate;
    UITableView *reportVideoTableView;
    NSArray *reportTypesArray;
    BOOL sentReport;
    NSString *reportVideoId;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forVideo:(NSString *)videoId;
- (IBAction)reportVideoDone;

@end
