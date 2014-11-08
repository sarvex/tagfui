/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "TagMarkerView.h"
#import "NSObject+PE.h"
#import "WooTagPlayerAppDelegate.h"
#import "CustomMoviePlayerViewController.h"

@implementation TagMarkerView

@synthesize markernameTxtView;
@synthesize markerImageView;
@synthesize markerLinkBtn;
@synthesize fbBtn;
@synthesize twBtn;
@synthesize gPlusBtn;
@synthesize wtBtn;
@synthesize editBtn;
@synthesize caller;
@synthesize deleteBtn;
@synthesize weblinkBtn;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(IBAction)onClickOfOpenLink:(CustomButton *)sender {
    TCSTART
    if ([self isNotNull:caller] && [caller respondsToSelector:@selector(onClickOfOpenLink:)]) {
        [caller onClickOfOpenLink:sender];
    }
    TCEND
}

-(IBAction)onClickOfFBTag:(id)sender {
    if ([self isNotNull:caller] && [caller respondsToSelector:@selector(onClickOfTagMarkerViewFacebookBtn:)]) {
        [caller onClickOfTagMarkerViewFacebookBtn:sender];
    }
}

-(IBAction)onClickOfTWTag:(id)sender {
    if ([self isNotNull:caller] && [caller respondsToSelector:@selector(onClickOfTagMarkerViewTwitterBtn:)]) {
        [caller onClickOfTagMarkerViewTwitterBtn:sender];
    }
}

-(IBAction)onClickOfGPlusTag:(id)sender {
    if ([self isNotNull:caller] && [caller respondsToSelector:@selector(onClickOfTagMarkerViewGPlusBtn:)]) {
        [caller onClickOfTagMarkerViewGPlusBtn:sender];
    }
}

-(IBAction)onClickOfWTTag:(id)sender {
    if ([self isNotNull:caller] && [caller respondsToSelector:@selector(onClickOfTagMarkerViewWTBtn:)]) {
        [caller onClickOfTagMarkerViewWTBtn:sender];
    }
}

-(IBAction)onClickOfEditTag:(CustomButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TAG_EDIT object:sender];
}

-(IBAction)onClickOfDeleteTag:(id)sender {
    if ([caller isNotNull:caller] && [caller respondsToSelector:@selector(onClickOfDeleteTag:)]) {
        [caller onClickOfDeleteTag:sender];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
