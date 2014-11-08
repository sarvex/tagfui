/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>

@interface UnderLineLabel : UILabel {
	BOOL shouldStrikeOut;
    
    BOOL shouldUnderline;
    
    int underLineOffset;
}

@property (nonatomic) BOOL shouldStrikeOut;

@property (nonatomic) BOOL shouldUnderline;

@property (nonatomic) int underLineOffset;

@end