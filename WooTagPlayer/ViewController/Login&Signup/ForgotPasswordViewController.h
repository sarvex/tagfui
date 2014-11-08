/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "ProfileService.h"

@class WooTagPlayerAppDelegate;

@interface ForgotPasswordViewController : UIViewController<UITextFieldDelegate,ProfileServiceDelegate> {
    
    /** backButton is an instance of UIButton created through Interface Builder and linked using FilesOwner in IB.
     On touchUpInside popup's the ForgotPassword to loginViewController page
     */
    IBOutlet UIButton *backButton;
    
    /** emailNewPasswordButton is an instance of UIButton created through Interface Builder and linked using FilesOwner in IB.
     On touchUpInside triggers an action method emialNewPassword.
     */
    IBOutlet UIButton *emailNewPasswordButton;
    
    /** emailAddressTextField is an instance of UITextField created through Interface Builder and linked using FilesOwner in IB. Have given the background color & keyboard return type is set to Done by default it calls the keyboard by setting an texfield.becomefristresponder to YES.
     */
    IBOutlet UITextField *emailAddressTextField;
    
    /** appDelegate is a AppDelegate instance which is a controller for the app. Required to get the more comments(Plugs & Replies).
     */
    WooTagPlayerAppDelegate *appDelegate;
    
    IBOutlet UIImageView *emailIconImgView;
    IBOutlet UIImageView *backgroundImgView; 
}

/** pops the ForgotPassword screen to loginscreen by calling an API "[self.navigationController popViewControllerAnimated:YES]"
 */
-(IBAction)popToLoginScreen:(id)sender;

/** sends the email address to appdelegate to make a forgotpassword request, server will post the new password to mentioned email-id
 */
-(IBAction)emailNewPassword:(id)sender;

@end
