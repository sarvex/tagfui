/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */
/* This UILabel subclass supports custom character spacing for all unicode symbols. Its draws letters as glyphs. */

@interface CustomUILabel : UILabel
{
    CGFloat characterSpacing;
}

@property CGFloat characterSpacing;

@end