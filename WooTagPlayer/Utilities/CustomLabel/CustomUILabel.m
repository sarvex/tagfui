/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */
#import "CustomUILabel.h"
#import <CoreText/CoreText.h>

@implementation CustomUILabel

@synthesize characterSpacing;

- (void)drawTextInRect:(CGRect)rect
{
    if (characterSpacing)
    {
        // Drawing code
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSelectFont (context, [self.font.fontName cStringUsingEncoding:NSASCIIStringEncoding], self.font.pointSize, kCGEncodingMacRoman);
        CGContextSetCharacterSpacing(context, characterSpacing);
        CGContextSetFillColorWithColor(context, [self.textColor CGColor]);
        CGAffineTransform myTextTransform = CGAffineTransformScale(CGAffineTransformIdentity, 1.f, -1.f );
        CGContextSetTextMatrix (context, myTextTransform);

        CGGlyph glyphs[self.text.length];
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)self.font.fontName, self.font.pointSize, NULL);
        CTFontGetGlyphsForCharacters(fontRef, (const unichar*)[self.text cStringUsingEncoding:NSUnicodeStringEncoding], glyphs, self.text.length);
        float centeredY = (self.font.pointSize + (self.frame.size.height- self.font.pointSize)/2)-2;
        CGContextShowGlyphsAtPoint(context, rect.origin.x, centeredY, (const CGGlyph *)glyphs, self.text.length);
        CFRelease(fontRef);
    }
    else
    {
        // no character spacing provided so do normal drawing
        [super drawTextInRect:rect];
    }
}   

@end