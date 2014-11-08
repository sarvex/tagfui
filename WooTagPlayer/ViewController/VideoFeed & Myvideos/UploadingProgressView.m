/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "UploadingProgressView.h"

@implementation UploadingProgressView

@synthesize bufferValue;
@synthesize progressValue;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGContextRef c = UIGraphicsGetCurrentContext();
    [[appDelegate colorWithHexString:@"959595"] set];
    CGFloat ins = 0.0;
    CGRect r = CGRectInset(self.bounds, ins, ins);
    r.size.height = 30;

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, CGRectGetMaxX(r), ins);
    CGPathAddArc(path, NULL, ins, ins, r.size.height - 2, -M_PI/2.0, M_PI/2.0, true);
    CGPathAddArc(path, NULL, CGRectGetMaxX(r), ins, r.size.height - 2, M_PI/2.0, -M_PI/2.0, true);
    CGPathCloseSubpath(path);
    CGContextAddPath(c, path);
    CGContextSetLineWidth(c, 2);
    CGContextStrokePath(c);
    CGContextAddPath(c, path);
    if (!CGPathIsEmpty(path) ) {
        CGContextClip(c);
    }

    CGContextSetFillColorWithColor(c, [appDelegate colorWithHexString:@"959595"].CGColor);
    CGContextFillRect(c, CGRectMake(r.origin.x, r.origin.y, r.size.width * self.bufferValue, r.size.height));

    c = UIGraphicsGetCurrentContext();
    [[appDelegate colorWithHexString:@"c9e378"] set];
    ins = 0.0;
    r = CGRectInset(self.bounds, ins, ins);
    r.size.height = r.size.height;
    
    path = CGPathCreateMutable();
    CGContextStrokePath(c);
    if ( !CGPathIsEmpty(path) ) {
        CGContextClip(c);
    }
    CGContextFillRect(c, CGRectMake(r.origin.x, r.origin.y, r.size.width * self.progressValue, r.size.height));
}

@end
