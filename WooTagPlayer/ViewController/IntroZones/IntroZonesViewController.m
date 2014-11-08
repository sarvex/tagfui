/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "IntroZonesViewController.h"
#import "SignUpViewController.h"

@interface IntroZonesViewController ()

@end

@implementation IntroZonesViewController

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
    self.view.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.view.frame = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height-20);
    
    contentsArray = [[NSArray alloc] initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:(appDelegate.window.frame.size.height > 480)?@"Intro1iPhone5":@"Intro1",@"imagename",@"Make your videos alive & interactive",@"title", nil],[NSDictionary dictionaryWithObjectsAndKeys:(appDelegate.window.frame.size.height > 480)?@"Intro2iPhone5":@"Intro2",@"imagename",@"Record your favourite moment",@"title", nil],[NSDictionary dictionaryWithObjectsAndKeys:(appDelegate.window.frame.size.height > 480)?@"Intro3iPhone5":@"Intro3",@"imagename",@"Express and tag people, place, product inside your videos",@"title", nil],[NSDictionary dictionaryWithObjectsAndKeys:(appDelegate.window.frame.size.height > 480)?@"Intro4iPhone5":@"Intro4",@"imagename",@"Let your connections interact with your videos",@"title", nil],[NSDictionary dictionaryWithObjectsAndKeys:(appDelegate.window.frame.size.height > 480)?@"Intro5iPhone5":@"Intro5",@"imagename",@"Share your moments",@"title", nil],[NSDictionary dictionaryWithObjectsAndKeys:(appDelegate.window.frame.size.height > 480)?@"Intro6iPhone5":@"Intro6",@"imagename",@"Connect and share videos with everyone.\nHave some private videos?\nForm your own private group",@"title", nil], nil];
    pageContl.currentPage = 0;
    currentPage = 0;
//    backgroundImage.image = [UIImage imageNamed:[[contentsArray objectAtIndex:0] objectForKey:@"imagename"]];

    [self addContentLabelToTheScrollView];
    TCEND
}

- (IBAction)onClickOfLoginBtn:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IntroZonesDisplayed"];
    NSLog(@"%d",[[NSUserDefaults standardUserDefaults] boolForKey:@"IntroZonesDisplayed"]);
    [appDelegate createAndSetLogingViewControllerToWindow];
}

- (IBAction)onClickOfSignUpBtn:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IntroZonesDisplayed"];
    NSLog(@"%d",[[NSUserDefaults standardUserDefaults] boolForKey:@"IntroZonesDisplayed"]);
    [appDelegate pushToRegistrationViewController];
}

- (void)addContentLabelToTheScrollView {
    TCSTART
    pagingScrollView.backgroundColor = [UIColor clearColor];
    pagingScrollView.contentSize = CGSizeMake(320*6, appDelegate.window.frame.size.height - 20);
    CGFloat originX = 15;
    for (int i = 0; i < 6; i ++) {
        NSDictionary *dict = [contentsArray objectAtIndex:i];
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(i*self.view.frame.size.width, 0, pagingScrollView.frame.size.width, appDelegate.window.frame.size.height)];
        bgImgView.image = [UIImage imageNamed:[[contentsArray objectAtIndex:i] objectForKey:@"imagename"]];
        [pagingScrollView addSubview:bgImgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(originX, ((appDelegate.window.frame.size.height > 480)?412:324), 290, 64)];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:titleFontName size:14];
        label.text = [dict objectForKey:@"title"];
        label.numberOfLines = 0;
        [pagingScrollView addSubview:label];
        originX = originX + label.frame.size.width + 30;
    }
    TCEND
}


#pragma mark Scrolling Overrides

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    TCSTART
    CGFloat x = pagingScrollView.contentOffset.x;
    CGFloat pageWidth = pagingScrollView.frame.size.width;
    int page = floor((x - pageWidth/2) / pageWidth) + 1;
    if (currentPage != page) {
        pageContl.currentPage = page;
        currentPage = page;
    }
    TCEND
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {

}

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    TCSTART
    
    TCEND
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
   
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  
}

- (IBAction)pageChanged:(id)sender {
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = pagingScrollView.frame.size.width * pageContl.currentPage;
    frame.origin.y = 0;
    frame.size = pagingScrollView.frame.size;
    [pagingScrollView scrollRectToVisible:frame animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//For iOS 6
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        return YES;
    } else {
        return NO;
    }
}
@end
