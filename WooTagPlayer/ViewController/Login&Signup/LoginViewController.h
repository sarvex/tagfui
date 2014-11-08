/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>

@class WooTagPlayerAppDelegate;

@interface LoginViewController : UIViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource> {
    
    /** loginButton is an instance of UIButton created through Interface Builder and linked using FilesOwner in IB.
     On touchUpInside login action triggers
     */
    IBOutlet UIButton *loginButton;
    
    /** signUpButton is an instance of UIButton created through Interface Builder and linked using FilesOwner in IB.
     On touchUpInside sign-up action triggers, and loads the sign-up page.
     */
    IBOutlet UIButton *signUpButton;
    
    /** forgotPasswordButton is an instance of UIButton created through Interface Builder and linked using FilesOwner in IB.
     On touchUpInside forgotPassword action triggers.
     */
    IBOutlet UIButton *forgotPasswordButton;
    
    /** backgroundImageView is an instance of UIImageView created through interface builder and linked using filesowner in IB. This is used to set the background image LoginBG.png to login screen.
     */
    IBOutlet UIImageView *backgroundImageView;
    
    /** appDelegate is a AppDelegate instance which is a controller for the app. Required to get the more comments(Plugs & Replies).
     */
    WooTagPlayerAppDelegate *appDelegate;
    
    /** set to YES when view goes up and NO when view is down.
     */
//    BOOL isViewModeUp;
    
    IBOutlet UIButton *faceBookButton;
    IBOutlet UIButton *googlePlusButton;
    
    IBOutlet UITableView *loginTableView;
    NSMutableDictionary *loginDetailsDict;
//    IBOutlet UIButton *rememberBtn;
    
}

/** pushed to forgotpassword screen from login viewcontroller
 */
-(IBAction)btnForgotPasswordTouched:(id)sender;

/** validates the username/emial and password text and call the loginuser method which is in AppDelegate.
 */
-(IBAction)btnLogInTouched:(id)sender;

/** pushed to sign-up page to register the user 
 */
-(IBAction)btnSignUpTouched:(id)sender;
- (void)signUpViewControllerNeedToHideCancelButton:(BOOL)hide;

/** validates the user entered email/username and password fields with the following conditions and sends True/False
 1.Checks whether user entered any character or not.
 2.Checks for password minimum characters limit-8.
 */
-(BOOL) validateInput;

/** 
 1. moves the view's origin up so that the text field that will be hidden come above the keyboard 
 2. increases the size of the view so that the area behind the keyboard is covered up.
 */
//-(void)setViewMovedUp:(BOOL)movedUp;
//-(void)setViewMovedUp:(BOOL)movedUp andFieldTag:(int)fieldTag;


-(IBAction)btnFaceBookTouched:(id)sender;
-(IBAction)btnGooglePlusTouched:(id)sender;
//- (IBAction)btnTwitterTouched:(id)sender;

//- (IBAction)onClickOfRemembermeButton:(id)sender;

@end
