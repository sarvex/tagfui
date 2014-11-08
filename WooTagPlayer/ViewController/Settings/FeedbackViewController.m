/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "FeedbackViewController.h"

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        // Custom initialization
//        efeff4
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height - 20);
    self.view.backgroundColor = [appDelegate colorWithHexString:@"efeff4"];
    [feedbackTxtView becomeFirstResponder];
//    submitBtn.enabled = NO;
}

- (IBAction)onClickOfCancelBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onClickOfSendBtn:(id)sender {
    TCSTART
    if (feedbackTxtView.text.length > 0) {
        feedbackTxtView.text = [appDelegate removingLastSpecialCharecter:feedbackTxtView.text];
        if (feedbackTxtView.text.length > 0) {
            [appDelegate makeRequestToSendFeedBack:feedbackTxtView.text andCaller:self];
        }
    }
    TCEND
}
- (void)didFinishedToSendFeedback:(NSDictionary *)results {
    [appDelegate hideNetworkIndicator];
    [self onClickOfCancelBtn:nil];
}
- (void)didFailedToSendFeedbackWithError:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    TCEND
}
- (void) viewDidLayoutSubviews {
    if (CURRENT_DEVICE_VERSION >= 7.0  && self.view.frame.size.height == appDelegate.window.frame.size.height) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.size.height = viewBounds.size.height - topBarOffset;
        self.view.frame = CGRectMake(viewBounds.origin.x, topBarOffset, viewBounds.size.width, viewBounds.size.height);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
