/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>

@class WooTagPlayerAppDelegate;

@interface SignUpViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource, UITableViewDataSource> {
    
    /** signUpButton is an instance of UIButton created through Interface Builder and linked using FilesOwner in IB.
     On touchUpInside sign-up action triggers.
     */
    IBOutlet UIButton *signUpButton;
    
    /** cancelButton is an instance of UIButton created through Interface Builder and linked using FilesOwner in IB.
     On touchUpInside cancelSignUpPage action triggers.
     */
    IBOutlet UIButton *cancelButton;
    
    /** appDelegate is a AppDelegate instance which is a controller for the app. Required to get the more comments(Plugs & Replies).
     */
    WooTagPlayerAppDelegate *appDelegate;
    
    IBOutlet UIImageView *backgroundImgView;
   
    NSMutableDictionary *signUpDetailsDict;
    BOOL hideCancelBtn;
    
    IBOutlet UITableView *signUpTableView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

/** pops the sign up page to login view controller page.
 */
-(IBAction)btnCancelTouched:(id)sender;

/** calls appDelegate signup request method by passing fullname,email address & password fields.
 */
-(IBAction)btnSignUpTouched:(id)sender;

/** validates the user entered email/username and password fields with the following conditions and sends True/False
 1.Checks whether full name is null or not.
 2.Checks for password minimum characters limit-8.
 3.Checks email adress is valid or not.
 */
-(BOOL) validateInput;

@end
