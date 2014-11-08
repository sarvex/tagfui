/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "PlayerProgressView.h"

@implementation PlayerProgressView

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
    [[UIColor whiteColor] set];
    CGFloat ins = 2.0;
    CGRect r = CGRectInset(self.bounds, ins, ins);
    r.size.height = r.size.height - 20;
    // r.origin.y = r.origin.y + 20;
    CGFloat radius = r.size.height / 2.0;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, CGRectGetMaxX(r) - radius, ins);
    CGPathAddArc(path, NULL, radius+ins, radius+ins, radius, -M_PI/2.0, M_PI/2.0, true);
    CGPathAddArc(path, NULL, CGRectGetMaxX(r) - radius, radius+ins, radius, M_PI/2.0, -M_PI/2.0, true);
    
    CGPathCloseSubpath(path);
    CGContextAddPath(c, path);
    CGContextSetLineWidth(c, 2);
    CGContextStrokePath(c);
    CGContextAddPath(c, path);
//    CGContextClip(c);
    if ( !CGPathIsEmpty(path) ) {
        CGContextClip(c);
    }
    CGContextSetFillColorWithColor(c, [UIColor whiteColor].CGColor);
    CGContextFillRect(c, CGRectMake(r.origin.x, r.origin.y, r.size.width * self.bufferValue, r.size.height));

    //NSLog(@"buffer value %f, progress value %f",self.bufferValue,self.progressValue);
    c = UIGraphicsGetCurrentContext();
    [[appDelegate colorWithHexString:@"11a3e7"] set];
    ins = 2.0;
    r = CGRectInset(self.bounds, ins, ins);
    r.size.height = r.size.height - 20;
    // r.origin.y = r.origin.y + 20;
    radius = r.size.height / 2.0;
    path = CGPathCreateMutable();
    CGContextStrokePath(c);
//    CGContextClip(c);
    if ( !CGPathIsEmpty(path) ) {
        CGContextClip(c);
    }
    CGContextFillRect(c, CGRectMake(r.origin.x, r.origin.y, r.size.width * self.progressValue, r.size.height));
}

@end
