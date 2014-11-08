/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "WooTagPlayerAppDelegate.h"

@protocol VideoTrimSliderDelegate;

@interface VideoTrimSlider : UIView<UIScrollViewDelegate> {
    WooTagPlayerAppDelegate *appDelegate;
    CGFloat viewOriginX;
    int picWidth;
    CGFloat trimmedDuration;
}


@property (nonatomic, weak) id <VideoTrimSliderDelegate> delegate;
@property (nonatomic) CGFloat leftPosition;
@property (nonatomic) CGFloat rightPosition;
@property (nonatomic, strong) UIView *topBorder;
@property (nonatomic, strong) UIView *bottomBorder;

- (id)initWithFrame:(CGRect)frame videoUrl:(NSURL *)videoUrl withDelegate:(id)delegate_ ;

@end


@protocol VideoTrimSliderDelegate <NSObject>

@optional

- (void)videoRange:(VideoTrimSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition;

- (void)videoRange:(VideoTrimSlider *)videoRange didGestureStateEndedLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition;
@end




