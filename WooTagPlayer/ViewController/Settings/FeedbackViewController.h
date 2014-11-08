/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"

@interface FeedbackViewController : UIViewController <UITextViewDelegate,UserServiceDelegate> {
    IBOutlet UITextView *feedbackTxtView;
    IBOutlet UIButton *submitBtn;
    WooTagPlayerAppDelegate *appDelegate;
}

- (IBAction)onClickOfCancelBtn:(id)sender;
- (IBAction)onClickOfSendBtn:(id)sender;
@end
