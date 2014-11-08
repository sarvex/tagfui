//
//  ScrollView.m
//  VideoPlayer
//
//  Created by Aruna on 01/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BrowseVideosScrollView.h"

@implementation BrowseVideosScrollView

- (id)initWithFrameColorAndButtonArray:(CGRect)frame backgroundColor:(UIColor *)color button:(NSMutableArray *)btnsArray
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        videoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        
		// Set behaviour for the scrollview
		videoScrollView.backgroundColor = color;
		videoScrollView.showsHorizontalScrollIndicator = FALSE;
		videoScrollView.showsVerticalScrollIndicator = FALSE;
		///videoScrollView.scrollEnabled = YES;
		
		
		// Add ourselves as delegate receiver so we can detect when the user is scrolling.
		videoScrollView.delegate = self;
		
		// Add the buttons to the scrollview
		button_Array = btnsArray;
		
		float totalButtonWidth = 0.0f;
		
		for(int i = 0; i < [button_Array count]; i++)
            
		{
            NSLog(@"%i",[button_Array count]);
			UIButton *btn = [button_Array objectAtIndex:i];
			
            [btn setFrame:CGRectMake(totalButtonWidth, 0, 100, 70)];
            NSLog(@"%f",totalButtonWidth);
            
			
			[videoScrollView addSubview:btn];
			
			totalButtonWidth += btn.frame.size.width+10;
		}
		
		// Update the scrollview content rect, which is the combined width of the buttons
		[videoScrollView setContentSize:CGSizeMake(totalButtonWidth, self.frame.size.height)];
		
		[self addSubview:videoScrollView];

        
    }
    return self;
}



@end
