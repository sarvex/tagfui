//
//  MyPageVideoDetailsCell.m
//  WooTagPlayer
//
//  Created by Aruna on 23/09/13.
//  Copyright (c) 2013 Ayansys Solutions Pvt. Ltd. All rights reserved.
//

#import "MyPageVideoDetailsCell.h"

@implementation MyPageVideoDetailsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void) awakeFromNib
{
    [super awakeFromNib];
    NSLog(@"Awake from nib");
}
@end
