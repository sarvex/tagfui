/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@protocol CustomLabelDelegate <NSObject>

- (void)hashTagButtonTouchedWithText:(NSString *)text;
- (void)phoneNumberTouchedWithText:(NSString *)text;
@end

@interface TagLabelView : UIView {
    CATextLayer *textLayer;
    NSMutableArray *hashTagsArray;
    NSMutableArray *phoneNumbersArray;
    NSString *textStr;
    id caller;
}
@property (nonatomic, strong) id caller;
- (void)setTextToTextLayer:(NSString *)text;
@end
