/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "FullProfilePicViewController.h"
#import "MyPageViewController.h"
#import "OthersPageViewController.h"

@interface FullProfilePicViewController ()

@end

@implementation FullProfilePicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withImageUrlStr:(NSString *)imageURL andCaller:(id)callerVC
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        imageUrl = imageURL;
        caller = callerVC;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    profilePic.contentMode = UIViewContentModeScaleAspectFit;
    [profilePic setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"OwnerPic"] options:SDWebImageRefreshCached];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isNotNull:caller] && [caller respondsToSelector:@selector(removeFullProfilePicVC)]) {
        [caller performSelector:@selector(removeFullProfilePicVC) withObject:nil afterDelay:0.6];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
