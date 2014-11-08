/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIWebViewDelegate, UIActionSheetDelegate> {
    IBOutlet UIWebView *contentWebView;
    IBOutlet UIButton *backBtn;
    IBOutlet UIButton *forwardBtn;
    IBOutlet UIButton *reloadBtn;
    NSString *loadUrl;
    BOOL isNetworkIndicator;
    WooTagPlayerAppDelegate *appDelegate;
    IBOutlet UIActivityIndicatorView *activityIndicator;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withWebUrl:(NSString *)weburl;
- (IBAction)onClickOfBackBtn:(id)sender;
- (IBAction)onClickOfReloadBtn:(id)sender;
- (IBAction)onClickOfWebviewBackBtn:(id)sender;
- (IBAction)onClickOfForwardBtn:(id)sender;
- (IBAction)onClickOfOpenInSafariButton:(id)sender;
@end
