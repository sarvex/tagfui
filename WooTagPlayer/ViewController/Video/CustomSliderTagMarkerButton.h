/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "Tag.h"

@interface CustomSliderTagMarkerButton : UIButton {
    Tag *tagRef;
    int sliderValue;
    
}
@property (nonatomic, retain) Tag *tagRef;
@property (nonatomic, readwrite) int sliderValue;
@end
