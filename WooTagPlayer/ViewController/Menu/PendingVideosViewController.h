/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"
#import "RefreshView.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface PendingVideosViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
    WooTagPlayerAppDelegate *appDelegate;
    IBOutlet UITableView *videosTableView;
    NSMutableArray *pendingVideosArray;
    
    BOOL checkForRefresh;
	BOOL reloading;
    RefreshView *refreshView;
    BOOL isExporting;
    
    ALAssetsLibrary *library;
}

- (void)refreshScreenByFetchingPendingVideos;
- (IBAction)onClickOfBackButton:(id)sender;
- (void)uploadPercentage:(NSInteger)percent ofVideo:(NSString *)clientVideoId completed:(BOOL)completed;
@end
