/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "RefreshView.h"
#import <QuartzCore/QuartzCore.h>
#import "WooTagPlayerAppDelegate.h"

#define kReleaseToReloadStatus	0
#define kPullToReloadStatus		1
#define kLoadingStatus			2

#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
//#define BORDER_COLOR [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define BORDER_COLOR [UIColor clearColor]



@implementation RefreshView

@synthesize isFlipped, lastUpdatedDate;

- (id)initWithFrame:(CGRect)frame 
{
    @try {
        if (self = [super initWithFrame:frame]) {            
           
            self.backgroundColor = [UIColor clearColor];
            lastUpdatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 40.0f, 768.0f, 40.0f)];
            lastUpdatedLabel.font = [UIFont fontWithName:descriptionTextFontName size:descriptionTextFontSize];
            lastUpdatedLabel.textColor = [UIColor lightGrayColor];
            lastUpdatedLabel.shadowColor = [UIColor blackColor];
            lastUpdatedLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
            lastUpdatedLabel.backgroundColor = self.backgroundColor;
            lastUpdatedLabel.opaque = YES;
            lastUpdatedLabel.textAlignment = UITextAlignmentCenter;
            [self addSubview:lastUpdatedLabel];
            
            statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, 320.0f, 20.0f)];
            statusLabel.font = [UIFont fontWithName:tabTitlesFontName size:13];
            statusLabel.textColor = [UIColor blackColor];
           // statusLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
           // statusLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
            statusLabel.backgroundColor = self.backgroundColor;
            statusLabel.opaque = YES;
            statusLabel.textAlignment = UITextAlignmentCenter;
            [self setStatus:kPullToReloadStatus];
            [self addSubview:statusLabel];
            
             arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(40.0f, frame.size.height - 45.0f, 30.0f, 35.0f)];
            arrowImage.contentMode = UIViewContentModeScaleAspectFit;
            arrowImage.image = [UIImage imageNamed:@"blueArrow"];
            [arrowImage layer].transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
            [self addSubview:arrowImage];
            
            activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
             activityView.frame = CGRectMake(150, frame.size.height - 30.0f, 20.0f, 20.0f);
            activityView.hidesWhenStopped = YES;
            [self addSubview:activityView];
            
            isFlipped = NO;
            
        }
        return self;
    }
    @catch (NSException *exception) {
         NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)drawRect:(CGRect)rect
{
    @try {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawPath(context,  kCGPathFillStroke);
        [BORDER_COLOR setStroke];
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0.0f, self.bounds.size.height - 1);
        CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height - 1);
        CGContextStrokePath(context);
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)flipImageAnimated:(BOOL)animated
{
	@try {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animated ? .18 : 0.0];
        [arrowImage layer].transform = isFlipped ? CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f) : CATransform3DMakeRotation(M_PI * 2, 0.0f, 0.0f, 1.0f);
        [UIView commitAnimations];
        
        isFlipped = !isFlipped;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)setLastUpdatedDate:(NSDate *)newDate 
{
    @try {
        if (newDate)
        {
            lastUpdatedDate = newDate;
            
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterShortStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            lastUpdatedLabel.text = [NSString stringWithFormat:@"Last Updated: %@", [formatter stringFromDate:lastUpdatedDate]];
        }
        else
        {
            lastUpdatedDate = nil;
            lastUpdatedLabel.text = @"Last Updated: Never";
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)setStatus:(int)status
{
    @try {
        switch (status) {
            case kReleaseToReloadStatus:
                statusLabel.text = @"Release to refresh...";
                break;
            case kPullToReloadStatus:
                statusLabel.text = @"Pull down to refresh...";
                break;
            case kLoadingStatus:
                statusLabel.text = @"Loading...";
                break;
            default:
                break;
        }
    }
    @catch (NSException *exception) {
         NSLog(@"Exception At: %s %d %s %s %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__,exception);
    }
    @finally {
    }
}

- (void)toggleActivityView:(BOOL)isON {
    TCSTART
    if (!isON) {
        [activityView stopAnimating];
        arrowImage.hidden = NO;
        statusLabel.hidden = NO;
    } else {
        [activityView startAnimating];
        arrowImage.hidden = YES;
        statusLabel.hidden = YES;
        [self setStatus:kLoadingStatus];
    }
    TCEND
}

- (void)dealloc 
{
	activityView = nil;
	statusLabel = nil;
	arrowImage = nil;
	lastUpdatedLabel = nil;
}


@end
