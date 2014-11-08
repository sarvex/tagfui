/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "TagAndLaterViewController.h"

@interface TagAndLaterViewController ()

@end

@implementation TagAndLaterViewController
@synthesize filePath;
@synthesize superVC;
@synthesize recordedPath;
@synthesize thumbImg;
@synthesize coverFrameValue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];

    }
    return self;
}

- (void)viewDidLoad
{
    TCSTART
    [super viewDidLoad];
    appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication]delegate];
    self.view.frame = CGRectMake(0, 0, appDelegate.window.frame.size.height, appDelegate.window.frame.size.width - 20);

    tagLbl.layer.borderColor = [UIColor whiteColor].CGColor;
    tagLbl.layer.borderWidth = 1.0;
    tagLbl.layer.cornerRadius = 4.0f;
    tagLbl.layer.masksToBounds = YES;
    clientVideoId = [appDelegate generateUniqueId];
    TCEND
}

- (void) viewDidLayoutSubviews {
    if (CURRENT_DEVICE_VERSION >= 7.0  && self.view.frame.size.height == appDelegate.window.frame.size.width) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.origin.y = -topBarOffset;
        self.view.bounds = viewBounds;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    TCSTART
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if (![appDelegate.ftue.tagged boolValue]) {
        tagLbl.text = kTagExpr;
    } else {
        tagLbl.text = kTouchToTag;
    }
    
    if ([self isNotNull:thumbImg]) {
        tagRLaterViewBgView.image = thumbImg;
    }
    TCEND
}


-(IBAction)tag:(id)sender {
    TCSTART
    BOOL showInstruntnScreen = ![self tagsAreCreatedToThisVideo];
    CustomMoviePlayerViewController *customMoviePlayerVC = [[CustomMoviePlayerViewController alloc]initWithNibName:@"CustomMoviePlayerViewController" bundle:nil video:nil videoFilePath:filePath andClientVideoId:[NSString stringWithFormat:@"%d",clientVideoId] showInstrcutnScreen:showInstruntnScreen];
    customMoviePlayerVC.caller = self;
    [self presentViewController:customMoviePlayerVC animated:YES completion:nil];
    TCEND
}

- (BOOL)tagsAreCreatedToThisVideo {
    TCSTART
    NSLog(@"ClientVideoId :%d",clientVideoId);
    NSArray *array = [[DataManager sharedDataManager] getAllTagsByVideoIdAndClientVideoId:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",clientVideoId],@"clientVideoId", nil]];
    if ([self isNotNull:array] && array.count > 0) {
        return YES;
    } else {
        return NO;
    }
    TCEND
}

- (void)playerScreenDismissed {
    TCSTART
//    tagRLaterView.hidden = YES;
    if (![self tagsAreCreatedToThisVideo]) {
        [ShowAlert showAlert:@"Remember to tag your video anytime after the video is uploaded"];
    }
    [self onClickOfNext:nil];
    TCEND
}
- (void)clickedOnPlayerScreenBackButton {
    TCSTART
//    [self back:Nil];
    TCEND
}
- (IBAction)onClickOfNext:(id)sender {
    TCSTART
    if ([self isNull:videoInfoVC]) {
        videoInfoVC = [[VideoInfoViewController alloc]initWithNibName:@"VideoInfoViewController" bundle:nil clientVideoId:clientVideoId];
    }
    videoInfoVC.filePath = filePath;
    videoInfoVC.recordedPath = recordedPath;
    videoInfoVC.superVC = superVC;
    videoInfoVC.thumbImg = thumbImg;
    videoInfoVC.coverFrameValue = coverFrameValue;
    [self.navigationController pushViewController:videoInfoVC animated:YES];
    TCEND
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if((interfaceOrientation == UIInterfaceOrientationLandscapeRight)||(interfaceOrientation == UIInterfaceOrientationLandscapeLeft))
	{
		return YES;
	}
	else
        return NO;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
    
}

@end
