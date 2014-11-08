/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "TagLabelView.h"
#import "HashButton.h"
#import "PhoneNumberButton.h"

@implementation TagLabelView
@synthesize caller;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setTextToTextLayer:(NSString *)text {
    TCSTART
    textStr = text;
    hashTagsArray = [[NSMutableArray alloc] init];
    [hashTagsArray removeAllObjects];
    
    phoneNumbersArray = [[NSMutableArray alloc] init];
    [phoneNumbersArray removeAllObjects];
    
    [self removeAllHashButtonsFromLabel];
    if (!textLayer) {
        textLayer = [[CATextLayer alloc] init];
        textLayer.backgroundColor = [UIColor clearColor].CGColor;
        [textLayer setForegroundColor:[[UIColor blackColor] CGColor]];
        [textLayer setContentsScale:[[UIScreen mainScreen] scale]];
        textLayer.wrapped = YES;
        [textLayer setAlignmentMode:kCAAlignmentCenter];
        [textLayer setFont:(__bridge CFTypeRef)([UIFont fontWithName:@"Helvetica" size:13])];
        [self.layer addSublayer:textLayer];
    }
    NSMutableAttributedString *mAttrbtdStr = [self getAttributedStringForTagExpression:text];

    textLayer.string = mAttrbtdStr;
    textLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    for (NSString *hasStr in hashTagsArray) {
        [self createHashButtonsForHashTagsWithText:hasStr];
    }
    for (NSString *str in phoneNumbersArray) {
        [self createPhoneNumberBtnWithText:str];
    }
    TCEND
}

- (void)removeAllHashButtonsFromLabel {
    TCSTART
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[HashButton class]] || [view isKindOfClass:[PhoneNumberButton class]]) {
            [view removeFromSuperview];
        }
    }
    TCEND
}

- (NSMutableAttributedString *)getAttributedStringForTagExpression:(NSString *)tagExp {
    TCSTART
    WooTagPlayerAppDelegate *appDelegate = (WooTagPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray* messageWords = [tagExp componentsSeparatedByString: @" "];
    NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:tagExp];
    [attributedMessage addAttribute:(id)kCTForegroundColorAttributeName
                              value:(__bridge id)[UIColor whiteColor].CGColor
                              range:[tagExp rangeOfString:tagExp]];
    CFStringRef _fontName = (__bridge_retained CFStringRef) descriptionTextFontName;
    CTFontRef _font = CTFontCreateWithName(_fontName, 13, NULL);
    [attributedMessage addAttribute:(id)kCTFontAttributeName
                           value:(__bridge id)_font
                           range:[tagExp rangeOfString:tagExp]];
    
    for (NSString *word in messageWords) {
        if ([self isNotNull:word] && word.length > 0) {
            if([word characterAtIndex:0] == '#') {
                [hashTagsArray addObject:word];
                [attributedMessage addAttribute:(id)kCTForegroundColorAttributeName
                                          value:(__bridge id)[appDelegate colorWithHexString:@"11a3e7"].CGColor
                                          range:[tagExp rangeOfString:word]];
            } else if ([self isNumeric:word]) {
                [phoneNumbersArray addObject:word];
                [attributedMessage addAttribute:(id)kCTForegroundColorAttributeName
                                          value:(__bridge id)[appDelegate colorWithHexString:@"007aff"].CGColor
                                          range:[tagExp rangeOfString:word]];
                if (CURRENT_DEVICE_VERSION >= 6.0) {
                    [attributedMessage addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:[tagExp rangeOfString:word]];
                }
            }
        }
    }
    return attributedMessage;
    TCEND
}


- (BOOL)isNumeric:(NSString*)inputString {
    BOOL isValid = NO;
    NSString *numberRegex = @"\\(?([0-9]{3})\\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})";
    NSRange range = [inputString rangeOfString:numberRegex options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        isValid = YES;
    }
    return isValid;
}

- (void)createHashButtonsForHashTagsWithText:(NSString *)hashTag {
    TCSTART

    HashButton *btn = [HashButton buttonWithType:UIButtonTypeCustom];
    btn.hashTagText = hashTag;
    [btn addTarget:self action:@selector(onClickOfHashTagButton:) forControlEvents:UIControlEventTouchUpInside];
   
    NSRange range = [textStr rangeOfString:hashTag];
    
    CGRect rectForString = [self rectForLetterAtIndex:range];
    CGSize textSize = [hashTag sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:13]];
    btn.frame = CGRectMake(rectForString.origin.x, rectForString.origin.y, textSize.width, rectForString.size.height);
    [self addSubview:btn];
    TCEND
}

- (void)createPhoneNumberBtnWithText:(NSString *)phoneNumberTag {
    TCSTART
    PhoneNumberButton *btn = [PhoneNumberButton buttonWithType:UIButtonTypeCustom];
    btn.numberTagText = phoneNumberTag;
    [btn addTarget:self action:@selector(onClickOfPhoneNumberButton:) forControlEvents:UIControlEventTouchUpInside];

    NSRange range = [textStr rangeOfString:phoneNumberTag];
    
    CGRect rectForString = [self rectForLetterAtIndex:range];
    CGSize textSize = [phoneNumberTag sizeWithFont:[UIFont fontWithName:descriptionTextFontName size:13]];
   
    btn.frame = CGRectMake(rectForString.origin.x, rectForString.origin.y, textSize.width, rectForString.size.height);
    [self addSubview:btn];
    TCEND
}

- (CGRect)rectForLetterAtIndex:(NSRange)substringRange {
    TCSTART
    UIFont *font = [UIFont fontWithName:descriptionTextFontName size:13];
    CGFloat lineHeight;
    CGFloat y;
    CGFloat x;
    if ( [font respondsToSelector:@selector(lineHeight)])
        lineHeight = font.lineHeight;
    else
        lineHeight = font.leading;
    
    /** First deciding number of words those can fit in lines
     */
    NSMutableArray *linesArray = [[NSMutableArray alloc] init];
    NSString *newString = @"";
    NSString *oldString = @"";
    NSArray *wordsArray = [textStr componentsSeparatedByString:@" "];
    for (int i = 0; i < wordsArray.count ; i ++ ) {
        NSString *word = [wordsArray objectAtIndex:i];
        if ([self isNotNull:newString] && newString.length > 0) {
            newString = [NSString stringWithFormat:@"%@ %@",newString,word];
        } else {
            newString = [NSString stringWithFormat:@"%@",word];
        }
        
        CGSize newStrSize = [newString sizeWithFont:font];
        if (newStrSize.width < self.frame.size.width) {
            oldString = newString;
            if (i == (wordsArray.count - 1)) {
                [linesArray addObject:oldString];
            }
        } else {
            [linesArray addObject:[NSString stringWithFormat:@"%@",oldString]];
            newString = @"";
            oldString = @"";
            if (wordsArray.count == 1) {
                break;
            } else {
                i --;
            }
        }
    }
    
    /** In each line comparing required substring is there are or not. if it is there then getting position
     */
    NSString *highlightedStr = [textStr substringWithRange:substringRange];
    for (int i = 0; i < linesArray.count; i ++) {
        NSString *lineStr = [linesArray objectAtIndex:i];
        if ([lineStr rangeOfString:highlightedStr options:NSCaseInsensitiveSearch].location != NSNotFound) {
            CGSize lineStrSize = [lineStr sizeWithFont:font];
            y = i * lineHeight;
            NSRange beforeTextRange = [lineStr rangeOfString:highlightedStr];
            CGSize beforeStrSize;
            if (beforeTextRange.location > 0) {
                beforeStrSize = [[lineStr substringWithRange:NSMakeRange(0, beforeTextRange.location - 1)] sizeWithFont:font];
            } else {
                beforeStrSize = [[lineStr substringWithRange:NSMakeRange(0, 0)] sizeWithFont:font];
            }

            x = beforeStrSize.width + (self.frame.size.width - lineStrSize.width)/2;
            break;
        }
    }
   
    CGSize highlightedStrSize = [highlightedStr sizeWithFont:font];
    return CGRectMake(x, y, highlightedStrSize.width, highlightedStrSize.height);
    TCEND
}

- (void)onClickOfHashTagButton:(HashButton *)btn {
    TCSTART
    if (caller && [caller conformsToProtocol:@protocol(CustomLabelDelegate)] && [caller respondsToSelector:@selector(hashTagButtonTouchedWithText:)]) {
        [caller hashTagButtonTouchedWithText:btn.hashTagText];
    }
    TCEND
}

- (void)onClickOfPhoneNumberButton:(PhoneNumberButton *)btn {
    TCSTART
    if (caller && [caller conformsToProtocol:@protocol(CustomLabelDelegate)] && [caller respondsToSelector:@selector(phoneNumberTouchedWithText:)]) {
        [caller phoneNumberTouchedWithText:btn.numberTagText];
    }
    TCEND
}
@end
