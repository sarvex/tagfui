/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "UINavigationController+Rotation_iOS6.h"

@implementation UINavigationController (Rotation_iOS6)


-(BOOL)shouldAutorotate
{
    BOOL shouldRotate = [[self.viewControllers lastObject] shouldAutorotate];
    
    return shouldRotate;
}

- (NSUInteger)supportedInterfaceOrientations
{
    NSUInteger supportedOrientation =  [[self.viewControllers lastObject] supportedInterfaceOrientations];
    return supportedOrientation;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    NSLog(@"Viewcontrollers last object :%@",[self.viewControllers lastObject]);
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

@end
