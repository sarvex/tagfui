/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "WooTagPlayerAppDelegate.h"
@interface UploadingProgressView : UIView
{
    WooTagPlayerAppDelegate *appDelegate;
}

@property (nonatomic, assign) CGFloat bufferValue;
@property (nonatomic, assign) CGFloat progressValue;


@end
