/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"

@interface IntroZonesViewController : UIViewController <UIScrollViewDelegate> {
    IBOutlet UIScrollView *pagingScrollView;
    IBOutlet UIPageControl *pageContl;
    WooTagPlayerAppDelegate *appDelegate;
    NSArray *contentsArray;
    CGFloat intialTouchPoint;
    int currentPage;
}

- (IBAction)onClickOfLoginBtn:(id)sender;
- (IBAction)onClickOfSignUpBtn:(id)sender;
- (IBAction)pageChanged:(id)sender;
@end
