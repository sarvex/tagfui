/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "UserModal.h"
#import "WooTagPlayerAppDelegate.h"
#import "ProfileService.h"
#import "MainViewController.h"
#import "GKImagePicker.h"

@interface AccountSettingsviewController : UIViewController<UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,GPPSignInDelegate,ProfileServiceDelegate,GKImagePickerDelegate,UIPickerViewDataSource,UIPickerViewDelegate> {
    
    IBOutlet UIView *genderView;
    IBOutlet UIPickerView *genderPickerView;
    NSArray *genderArray;
    
    IBOutlet UIView *headerView;
    IBOutlet UIImageView *userProfilePic;
    IBOutlet UILabel *usernameLbl;
    IBOutlet UILabel *usernameLblDivider;

    IBOutlet UILabel *bioDivider;
    
    IBOutlet UITextField *websiteTxtField;
    IBOutlet UITextField *bioTextField;
    IBOutlet UILabel *websiteDivider;
    
    IBOutlet UITableView *editTableView;
    
    UIImage *newAvatar;
    NSString *newAvatarDataBase64;
    UIImage *newBanner;
    NSString *newBannerDataBase64;

//    NSString *googlePlusEmailAddr;
    
    WooTagPlayerAppDelegate *appDelegate;
    
    BOOL isActionSheetOpenedForBanner;
    BOOL isImgSourceTypeCamera;
    
    BOOL firstTime;
    
}

@property (nonatomic, strong) GKImagePicker *imagePicker;
@property (nonatomic, retain) UserModal *userDataModal;
@property (nonatomic, retain) MainViewController *mainVC;

- (void)getTwitterLoggedInUserEmailAddress;
- (IBAction)onClickOfPhotoEditButton:(id)sender;

- (IBAction)onClickOfCancelBtn:(id)sender;
- (IBAction)onclickOfSaveBtn:(id)sender;

- (IBAction)genderPickerDoneClick;

@end
