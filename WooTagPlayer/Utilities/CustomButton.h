/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>


@interface CustomButton : UIButton {

	NSString *buttonId;
    NSUInteger custumbtnid;

	int tagId;
    int clientTagId;
	NSString *tagLink;
	NSString *fbTagId;
	NSString *twTagId;
	NSString *gPlusTagId;
}

@property (nonatomic,readwrite) NSUInteger custumbtnid;
@property (nonatomic,strong) NSString *buttonId;

//Tag marker
@property (nonatomic,readwrite) int tagId;
@property (nonatomic, readwrite) int clientTagId;
@property (nonatomic,strong) NSString *tagLink;
@property (nonatomic,strong) NSString *fbTagId;
@property (nonatomic,strong) NSString *twTagId;
@property (nonatomic,strong) NSString *gPlusTagId;

@end
