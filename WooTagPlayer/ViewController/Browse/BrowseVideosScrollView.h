//
//  ScrollView.h
//  VideoPlayer
//
//  Created by Aruna on 01/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowseVideosScrollView : UIView <UIScrollViewDelegate>
{
    UIScrollView *videoScrollView;
    NSMutableArray *button_Array;
}

- (id)initWithFrameColorAndButtonArray:(CGRect)frame backgroundColor:(UIColor *)color button:(NSMutableArray *)btnsArray;
@end
