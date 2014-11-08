/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "GKCropBorderView.h"
#import "GKImageCropOverlayView.h"

typedef struct {
    int widhtMultiplyer;
    int heightMultiplyer;
    int xMultiplyer;
    int yMultiplyer;
}GKResizeableViewBorderMultiplyer;

@interface GKResizeableCropOverlayView : GKImageCropOverlayView

@property (nonatomic, strong) UIView* contentView;
@property (nonatomic, strong, readonly) GKCropBorderView *cropBorderView;

/**
 call this method to create a resizable crop view
 @param frame
 @param initial crop size
 @return crop view instance
 */
-(id)initWithFrame:(CGRect)frame andInitialContentSize:(CGSize)contentSize;

@end
