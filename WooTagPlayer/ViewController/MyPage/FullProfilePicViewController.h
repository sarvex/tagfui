/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>

@interface FullProfilePicViewController : UIViewController {
    IBOutlet UIImageView *profilePic;
    NSString *imageUrl;
    id caller;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withImageUrlStr:(NSString *)imageURL andCaller:(id)callerVC;
@end
