/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"

/** This is for to change video permisions(private, follower or public)
 */
@interface AccessPermissionsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,VideoServiceDelegate> {
    IBOutlet UITableView *accessTableView;
    IBOutlet UIImageView *videoThumbImgView;
    WooTagPlayerAppDelegate *appDelegate;
    VideoModal *selectedVideo;
    NSMutableArray *accessDetailsArray;
    
    int sharingType;
    id caller;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withSelectedVideo:(VideoModal *)video andCaller:(id)caller_;
- (IBAction)goBack:(id)sender;

@end
