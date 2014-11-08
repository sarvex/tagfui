/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "VideoTrimSlider.h"

@interface VideoTrimSlider ()

@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong) UIScrollView *framesScrollView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, strong) UIView *rightThumb;
@property (nonatomic) CGFloat frame_width;
@property (nonatomic) Float64 durationSeconds;

@end

@implementation VideoTrimSlider

#define SLIDER_BORDERS_SIZE 6.0f
#define BG_VIEW_BORDERS_SIZE 1.0f

- (id)initWithFrame:(CGRect)frame videoUrl:(NSURL *)videoUrl withDelegate:(id)delegate_ {
    TCSTART
    self = [super initWithFrame:frame];
    if (self) {
        _delegate = delegate_;
        appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
        _frame_width = frame.size.width;
        _framesScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, frame.size.width, frame.size.height-20)];
        _framesScrollView.layer.borderColor = [appDelegate colorWithHexString:@"11a3e7"].CGColor;
//        _framesScrollView.layer.borderWidth = BG_VIEW_BORDERS_SIZE;
        _framesScrollView.layer.cornerRadius = 5.0;
        _framesScrollView.layer.masksToBounds = YES;
        _framesScrollView.scrollEnabled = YES;
        _framesScrollView.showsHorizontalScrollIndicator = NO;
        _framesScrollView.delegate = self;
        [self addSubview:_framesScrollView];
        
        _rightView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width, 0, 0, frame.size.height-20)];
        _rightView.backgroundColor = [UIColor whiteColor];
        _rightView.alpha = 0.3;
//        [self addSubview:_rightView];
        
        _videoUrl = videoUrl;
        
        _bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 7, frame.size.width, SLIDER_BORDERS_SIZE)];
        [self addSubview:_bottomBorder];
        
        _topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 7, frame.size.width, SLIDER_BORDERS_SIZE)];
        [self addSubview:_topBorder];
        
        _rightThumb = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 15, 18)];
        _rightThumb.userInteractionEnabled = YES;
        CGFloat inset = _rightThumb.frame.size.width / 2;
        _rightThumb.center = CGPointMake(_frame_width - inset, _rightThumb.frame.size.height/2);
        _rightThumb.backgroundColor = [appDelegate colorWithHexString:@"11a3e7"];
        _rightThumb.layer.cornerRadius = 5.0;
        _rightThumb.layer.masksToBounds = YES;
        [self addSubview:_rightThumb];
        
        
        UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightPan:)];
        [_rightThumb addGestureRecognizer:rightPan];
        
        [self getMovieFrame];
    }
    
    return self;
    TCEND
}

#pragma mark
#pragma mark Reset frames
- (void)resetFramesForAllViewsWithWidth:(CGFloat)width {
    TCSTART
    _framesScrollView.frame = CGRectMake(_framesScrollView.frame.origin.x, _framesScrollView.frame.origin.y, width, _framesScrollView.frame.size.height);
    _framesScrollView.contentSize = CGSizeMake(width+1, _framesScrollView.frame.size.height);
//    [_framesScrollView bringSubviewToFront:_rightView];
    if (appDelegate.window.frame.size.height >= width) {
        _frame_width = width;
        CGFloat inset = _rightThumb.frame.size.width / 2;
        _rightThumb.center = CGPointMake(_frame_width - inset, _rightThumb.frame.size.height/2);
    } else {
        CGFloat inset = _rightThumb.frame.size.width / 2;
        _rightThumb.center = CGPointMake(_frame_width - inset, _rightThumb.frame.size.height/2);
    }
    
    [self updateTopBorderAndRightTransParentWhiteViewFramesAsPerRightThumb];
    TCEND
}

- (void)changeScrollViewFrame {
    TCSTART
    _leftPosition = 0 - viewOriginX/picWidth;
    CGRect frame = _framesScrollView.frame;
    frame.origin.x = viewOriginX;
    _framesScrollView.frame = frame;
    [self changeRightThumbFrameWhenScrollViewScrollingEnded];
    TCEND
}

- (void)changeRightThumbFrameByRightPanGestureWithXaxis:(CGFloat)originX {
    TCSTART
    _rightThumb.frame = CGRectMake(originX, _rightThumb.frame.origin.y, _rightThumb.frame.size.width, _rightThumb.frame.size.height);
    [self updateTopBorderAndRightTransParentWhiteViewFramesAsPerRightThumb];
    TCEND
}

- (void)changeRightThumbFrameWhenScrollViewScrollingEnded {
    TCSTART
    if ((_framesScrollView.frame.origin.x + _framesScrollView.frame.size.width) < (_rightThumb.frame.origin.x + _rightThumb.frame.size.width)) {
        CGRect _rightThumbframe = _rightThumb.frame;
        _rightThumbframe.origin.x = ((_framesScrollView.frame.origin.x + _framesScrollView.frame.size.width) - _rightThumb.frame.size.width);
        _rightThumb.frame = _rightThumbframe;
        _rightPosition = _durationSeconds - _leftPosition;
        trimmedDuration = _rightPosition - _leftPosition;
        [self updateTopBorderAndRightTransParentWhiteViewFramesAsPerRightThumb];
    } else {
        _rightPosition = trimmedDuration + _leftPosition;
    }
    NSLog(@"Trimed duration:%f DiffBtRight&Left:%f", trimmedDuration, (_rightPosition - _leftPosition));
    TCEND
}

- (void)updateTopBorderAndRightTransParentWhiteViewFramesAsPerRightThumb {
    TCSTART
    _topBorder.frame = CGRectMake(_topBorder.frame.origin.x, _topBorder.frame.origin.y, _rightThumb.frame.origin.x + _rightThumb.frame.size.width, SLIDER_BORDERS_SIZE);
    
    _rightView.frame = CGRectMake(_rightThumb.frame.origin.x + _rightThumb.frame.size.width, 0, _frame_width - (_rightThumb.frame.origin.x + _rightThumb.frame.size.width), _rightView.frame.size.height);
    TCEND
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)delegateNotification {
    TCSTART
    if ([_delegate respondsToSelector:@selector(videoRange:didChangeLeftPosition:rightPosition:)]){
        [_delegate videoRange:self didChangeLeftPosition:self.leftPosition rightPosition:self.rightPosition];
    }
    TCEND
}


#pragma mark - Gestures
- (void)handleRightPan:(UIPanGestureRecognizer *)gesture {
    TCSTART
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture translationInView:self];
        CGFloat thumbPosition = _rightThumb.frame.origin.x;
        thumbPosition += translation.x;
        if ([gesture velocityInView:_rightThumb].x > 0) {
            NSLog(@"Right translatn :%f",thumbPosition);
            if (thumbPosition < _frame_width) {
                if ((_framesScrollView.frame.size.width + _framesScrollView.frame.origin.x) >= _frame_width) {
                    if ((thumbPosition + _rightThumb.frame.size.width) >= _frame_width) {
                        thumbPosition = (_frame_width - _rightThumb.frame.size.width);
                    } else {
                        
                    }
                    [self changeRightPositionWithRightPanWithX:(thumbPosition - _rightThumb.frame.origin.x)];
                    [self changeRightThumbFrameByRightPanGestureWithXaxis:thumbPosition];
                } else {
                    if ((thumbPosition + _rightThumb.frame.size.width) < (_framesScrollView.frame.size.width + _framesScrollView.frame.origin.x)) {
                        [self changeRightPositionWithRightPanWithX:(thumbPosition - _rightThumb.frame.origin.x)];
                        [self changeRightThumbFrameByRightPanGestureWithXaxis:thumbPosition];
                    }
                }
            }
        } else {
            NSLog(@"Left translatn :%f",translation.x);
            if ((thumbPosition + _rightThumb.frame.size.width) > picWidth/2) {
                NSLog(@"Left translatn after:%f",thumbPosition);
                [self changeRightPositionWithLeftPanWithX:(_rightThumb.frame.origin.x-thumbPosition)];
                [self changeRightThumbFrameByRightPanGestureWithXaxis:thumbPosition];
            }
        }
        
        [gesture setTranslation:CGPointZero inView:self];
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self delegateNotification];
    }
    TCEND
}

- (void)changeRightPositionWithRightPanWithX:(float)increasedPostion {
    TCSTART
    _rightPosition = (_rightPosition + increasedPostion/(picWidth/2));
    trimmedDuration = _rightPosition - _leftPosition;
    NSLog(@"LeftPosition:%f and rightposition:%f trimedDuraton:%f diffBTLetAndRight:%f",_leftPosition,_rightPosition,trimmedDuration,(_rightPosition - _leftPosition));
    TCEND
}

- (void)changeRightPositionWithLeftPanWithX:(float)decresdPostion {
    TCSTART
    _rightPosition = (_rightPosition - decresdPostion/(picWidth/2));
    trimmedDuration = _rightPosition - _leftPosition;
    NSLog(@"LeftPosition:%f and rightposition:%f trimedDuraton:%f diffBTLetAndRight:%f",_leftPosition,_rightPosition,trimmedDuration,(_rightPosition - _leftPosition));
    TCEND
}


#pragma mark - Video
- (void)getMovieFrame {
    TCSTART
    AVAsset *myAsset = [[AVURLAsset alloc] initWithURL:_videoUrl options:nil];
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:myAsset];
    self.imageGenerator.appliesPreferredTrackTransform = YES;
    if ([self isRetina]){
        self.imageGenerator.maximumSize = CGSizeMake(320, _framesScrollView.frame.size.height*2);
    } else {
        self.imageGenerator.maximumSize = CGSizeMake(_framesScrollView.frame.size.width, _framesScrollView.frame.size.height);
    }
    
    if (_frame_width > 480) {
        picWidth = 37.8;
    } else {
        picWidth = 32;
    }

    NSError *error;
    CMTime actualTime;

    _durationSeconds = CMTimeGetSeconds([myAsset duration]);
    
    int picsCnt;
    if (_durationSeconds < 30.0) {
        picsCnt = ceil(_durationSeconds/2.0);
    } else {
        picsCnt = floor(_durationSeconds/2.0);
    }
    
    _leftPosition = 0;
    if (_durationSeconds > 30) {
        _rightPosition = 30;
    } else {
        _rightPosition = _durationSeconds;
    }
    
    if ([_delegate respondsToSelector:@selector(videoRange:didChangeLeftPosition:rightPosition:)]){
        [_delegate videoRange:self didChangeLeftPosition:self.leftPosition rightPosition:self.rightPosition];
    }
    
    trimmedDuration = _rightPosition - _leftPosition;
    
    NSMutableArray *allTimes = [[NSMutableArray alloc] init];
    
    int originX = 0;
    
    if (CURRENT_DEVICE_VERSION >= 7.0) {
        // Bug iOS7 - generateCGImagesAsynchronouslyForTimes
        
        for (int i=0; i<picsCnt; i++) {
        
            CMTime timeFrame = CMTimeMakeWithSeconds((_durationSeconds/picsCnt)*i, 600);
            NSLog(@"%f", (_durationSeconds/picsCnt)*i);
            
            [allTimes addObject:[NSValue valueWithCMTime:timeFrame]];
            
            CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:timeFrame actualTime:&actualTime error:&error];
            
            UIImage *videoScreen;
            if ([self isRetina]){
                videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
            } else {
                videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
            }
            
            UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
            if (i == 0) {
                [appDelegate setMaskTo:tmp byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft withRadii:CGSizeMake(5.0, 5.0)];
            }
            
            CGRect currentFrame = tmp.frame;
            currentFrame.origin.x = originX;
            currentFrame.size.height = 50;
            currentFrame.size.width = picWidth;
            tmp.frame = currentFrame;
            originX = originX + tmp.frame.size.width;
            _framesScrollView.frame = CGRectMake(_framesScrollView.frame.origin.x, _framesScrollView.frame.origin.y, originX, _framesScrollView.frame.size.height);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_framesScrollView addSubview:tmp];
                if (i == picsCnt - 1) {
//                    _frame_width = originX;
                    [appDelegate setMaskTo:tmp byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight withRadii:CGSizeMake(5.0, 5.0)];
                    [self resetFramesForAllViewsWithWidth:originX];
                }
            });
     
            CGImageRelease(halfWayImage);
        }

        return;
    }
    
    for (int i=0; i<picsCnt; i++) {
       CMTime timeFrame = CMTimeMakeWithSeconds((_durationSeconds/picsCnt)*i, 600);
        [allTimes addObject:[NSValue valueWithCMTime:timeFrame]];
    }
    
    NSArray *times = allTimes;
    
    __block int i = 0;
    
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times
                                              completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime,
AVAssetImageGeneratorResult result, NSError *error) {
                                                  
                                                  if (result == AVAssetImageGeneratorSucceeded) {
                                                      UIImage *videoScreen;
                                                      if ([self isRetina]){
                                                          videoScreen = [[UIImage alloc] initWithCGImage:image scale:2.0 orientation:UIImageOrientationUp];
                                                      } else {
                                                          videoScreen = [[UIImage alloc] initWithCGImage:image];
                                                      }
                                                      
                                                      UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];

                                                      CGRect currentFrame = tmp.frame;
                                                      currentFrame.origin.x = i*picWidth;
                                                      currentFrame.size.height = 50;
                                                      currentFrame.size.width = picWidth;
                                                      
                                                      tmp.frame = currentFrame;
                                        
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [_framesScrollView addSubview:tmp];

                                                          [self resetFramesForAllViewsWithWidth:(tmp.frame.origin.x + tmp.frame.size.width)];

                                                      });
                                                      i++;
                                                  }
                                                  
                                                  if (result == AVAssetImageGeneratorFailed) {
                                                      NSLog(@"Failed with error: %@", [error localizedDescription]);
                                                  }
                                                  if (result == AVAssetImageGeneratorCancelled) {
                                                      NSLog(@"Canceled");
                                                  }
                                              }];
    TCEND
}

- (BOOL)isRetina {
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            
            ([UIScreen mainScreen].scale == 2.0));
}


#pragma mark Scrollview Delegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    TCSTART
    
    TCEND
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    [self delegateNotification];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    TCSTART
    
    viewOriginX = _framesScrollView.frame.origin.x;
    viewOriginX -= scrollView.contentOffset.x;
    
    if ([_framesScrollView.panGestureRecognizer velocityInView:scrollView].x > 0) {
        if (viewOriginX > 0) {
            viewOriginX = 0;
        }
        [self changeScrollViewFrame];
        [self delegateNotification];
    } else {
        if ((_framesScrollView.frame.size.width + viewOriginX) > picWidth/2) {
            [self changeScrollViewFrame];
            [self delegateNotification];
        } else {
            viewOriginX = _framesScrollView.frame.origin.x;
        }
    }
    TCEND
}

@end
