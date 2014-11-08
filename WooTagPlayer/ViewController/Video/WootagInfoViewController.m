/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "WootagInfoViewController.h"
#import "BuyerInfoViewController.h"

@interface WootagInfoViewController ()

@end

@implementation WootagInfoViewController
@synthesize customMVPlayer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    productInfoView.layer.cornerRadius = 7.0f;
    productInfoView.layer.masksToBounds = YES;
    
    productImgView.layer.cornerRadius = 7.0f;
    productImgView.layer.masksToBounds = YES;
    
    // Do any additional setup after loading the view.
}

- (void)updateTagDetails:(Tag *)tag_ andVideo:(VideoModal *)video {
    TCSTART
    tag = tag_;
    playingVideo = video;
    
    closeBtn.frame = CGRectMake(((appDelegate.window.frame.size.height > 480)?467:424), 82, 30, 30);
    [self setDataToAllUIObjects];
    TCEND
}

- (void)setDataToAllUIObjects {
    TCSTART
    [productImgView setImageWithURL:[NSURL URLWithString:playingVideo.videoThumbPath] placeholderImage:[UIImage imageNamed:@"DefaultVideoThumb"]];
    productName.text = tag.productName?:@"";
    productDesc.text = tag.productDescription?:@"";
    productPrice.text = tag.productPrice?:@"";
    currencyLabel.text = tag.productCurrencyType?:@"";
    TCEND
}
- (NSString *)getVideoThumbPath:(NSString *)thumbPath {
    NSString *videoThubPath ;
    return videoThubPath;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickOfImInterestedBtn:(id)sender {
    TCSTART
    BuyerInfo *buyerInfo = [[DataManager sharedDataManager] getBuyerInfoByUserId:appDelegate.loggedInUser.userId];
    BuyerInfoViewController *buyerInfoVC = [[BuyerInfoViewController alloc] initWithNibName:@"BuyerInfoViewController" bundle:nil withBuyerInfo:buyerInfo];
    buyerInfoVC.wootagInfoVC = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:buyerInfoVC];
    navController.navigationBarHidden = YES;
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [customMVPlayer presentViewController:navController animated:YES completion:nil];
    TCEND
}

- (void)onClickOfBuyBtnWithDict:(NSMutableDictionary *)parmasDict {
    TCSTART
        NSString *creationTime = [appDelegate formattedGMTDateInString];
        [parmasDict setObject:creationTime forKey:@"requestTime"];
        [parmasDict setObject:appDelegate.loggedInUser.userId?:@"" forKey:@"buyerId"];

        if ([self isNotNull:tag.tagId] && tag.tagId.intValue > 0) {
            [parmasDict setObject:[NSString stringWithFormat:@"%d",tag.tagId.intValue] forKey:@"tagId"];
        } else if ([self isNotNull:tag.clientTagId] && tag.clientTagId.intValue > 0) {
            [parmasDict setObject:[NSString stringWithFormat:@"%d",tag.clientTagId.intValue] forKey:@"clientTagId"];
        }
    
        if ([self isNotNull:playingVideo.userId]) {
            [parmasDict setObject:playingVideo.userId forKey:@"sellerId"];
            [parmasDict setObject:playingVideo.videoId forKey:@"videoId"];
        } else {
            [parmasDict setObject:appDelegate.loggedInUser.userId?:@"" forKey:@"sellerId"];
        }
        
        [[DataManager sharedDataManager] addBuyerInfo:parmasDict];
        if ([self isNotNull:tag.tagId] && tag.tagId.intValue > 0) {
            BuyerInfo *buyerInfo = [[DataManager sharedDataManager] getBuyerInfoByTagIdOrClientTagId:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",tag.tagId.intValue],@"tagId", nil]];
            [appDelegate showActivityIndicatorInView:self.view andText:@"Please Wait"];
            [appDelegate productBuyRequestWithParameters:buyerInfo withCaller:self];
        } else {
            [customMVPlayer onClickOfCloseBtnOfWootagProductInfoVC];
        }
    
    TCEND
}

- (void)didFinishedBuyingProductWithResults:(NSDictionary *)resultsDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:self.view];
    [customMVPlayer onClickOfCloseBtnOfWootagProductInfoVC];
    TCEND
}
- (void)didFailedToBuyProduct:(NSDictionary *)errorDict {
    TCSTART
    [appDelegate hideNetworkIndicator];
    [appDelegate removeNetworkIndicatorInView:self.view];
    [ShowAlert showAlert:[errorDict objectForKey:@"msg"]];
    TCEND
}

- (IBAction)onClickOfCloseBtn:(id)sender {
    TCSTART
    [customMVPlayer onClickOfCloseBtnOfWootagProductInfoVC];
    TCEND
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
