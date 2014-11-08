/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "CustomButton.h"
#import "TagLabelView.h"

@interface TagMarkerView : UIView {
    IBOutlet TagLabelView *markernameTxtView;
    IBOutlet UIImageView  *markerImageView;
    IBOutlet CustomButton *markerLinkBtn;
    IBOutlet CustomButton *fbBtn;
    IBOutlet CustomButton *twBtn;
    IBOutlet CustomButton *gPlusBtn;
    IBOutlet CustomButton *wtBtn;
    IBOutlet CustomButton *weblinkBtn;
    IBOutlet CustomButton *editBtn;
    IBOutlet CustomButton *deleteBtn;
    id caller;
}

@property (nonatomic, retain) IBOutlet TagLabelView *markernameTxtView;
@property (nonatomic, retain) IBOutlet UIImageView  *markerImageView;
@property (nonatomic, retain) IBOutlet CustomButton *markerLinkBtn;
@property (nonatomic, retain) IBOutlet CustomButton *fbBtn;
@property (nonatomic, retain) IBOutlet CustomButton *twBtn;
@property (nonatomic, retain) IBOutlet CustomButton *gPlusBtn;
@property (nonatomic, retain) IBOutlet CustomButton *wtBtn;
@property (nonatomic, retain) IBOutlet CustomButton *editBtn;
@property (nonatomic, retain) IBOutlet CustomButton *deleteBtn;
@property (nonatomic, retain) IBOutlet CustomButton *weblinkBtn;

@property (nonatomic, retain) id caller;
-(IBAction)onClickOfOpenLink:(CustomButton *)sender;
-(IBAction)onClickOfFBTag:(id)sender;
-(IBAction)onClickOfTWTag:(id)sender;
-(IBAction)onClickOfGPlusTag:(id)sender;
-(IBAction)onClickOfEditTag:(id)sender;
-(IBAction)onClickOfDeleteTag:(id)sender;
@end
