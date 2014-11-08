/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withWebUrl:(NSString *)weburl
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        loadUrl = weburl;
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad
{
    TCSTART
    [super viewDidLoad];
    [[UIActivityIndicatorView appearance] setColor:[UIColor whiteColor]];
    activityIndicator.hidden = YES;
    reloadBtn.hidden = YES;
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height - 20);
    [contentWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[loadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    contentWebView.scalesPageToFit = YES;
    if ([contentWebView canGoBack]) {
        backBtn.enabled = YES;
    } else {
        backBtn.enabled = NO;
    }
    
    if ([contentWebView canGoForward]) {
        forwardBtn.enabled = YES;
    } else {
        forwardBtn.enabled = NO;
    }
    TCEND
    // Do any additional setup after loading the view from its nib.
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

- (IBAction)onClickOfBackBtn:(id)sender {
    TCSTART
    [contentWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
    [contentWebView stopLoading];
    [contentWebView removeFromSuperview];
    contentWebView = nil;
    [self.navigationController popViewControllerAnimated:YES];
    TCEND
}
- (IBAction)onClickOfReloadBtn:(id)sender {
    [contentWebView reload];
}
- (IBAction)onClickOfWebviewBackBtn:(id)sender {
    [contentWebView goBack];
}
- (IBAction)onClickOfForwardBtn:(id)sender {
    [contentWebView goForward];
}
- (IBAction)onClickOfOpenInSafariButton:(id)sender {
    TCSTART
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Open Safari", nil];
    actionSheet.backgroundColor = [UIColor whiteColor];
    [actionSheet showInView:appDelegate.window];
    TCEND
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	TCSTART
	NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle caseInsensitiveCompare:@"Open Safari"] == NSOrderedSame) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:loadUrl]];
    }
	TCEND
}
#pragma mark WebView Delegate Methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView_ {
    @try {
        reloadBtn.hidden = YES;
        activityIndicator.hidden = NO;
        [activityIndicator startAnimating];
//        if (!isNetworkIndicator) {
//            isNetworkIndicator = YES;
//            [appDelegate showNetworkIndicator];
//            [appDelegate showActivityIndicatorInView:webView_ andText:@"Loading"];
//        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView_ {
    @try {
//        isNetworkIndicator = NO;
//        [appDelegate hideNetworkIndicator];
//        [appDelegate removeNetworkIndicatorInView:webView_];
        reloadBtn.hidden = NO;
        activityIndicator.hidden = YES;
        [activityIndicator stopAnimating];
        if ([webView_ canGoBack]) {
            backBtn.enabled = YES;
        } else {
            backBtn.enabled = NO;
        }
        
        if ([webView_ canGoForward]) {
            forwardBtn.enabled = YES;
        } else {
            forwardBtn.enabled = NO;
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)webView:(UIWebView *)webView_ didFailLoadWithError:(NSError *)error {
    
    @try {
        reloadBtn.hidden = NO;
        activityIndicator.hidden = YES;
        [activityIndicator stopAnimating];
        [ShowAlert showError:[error localizedDescription]];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIActivityIndicatorView appearance] setColor:[appDelegate colorWithHexString:@"11a3e7"]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
