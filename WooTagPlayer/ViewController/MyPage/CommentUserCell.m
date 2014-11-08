/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "CommentUserCell.h"

@implementation CommentUserCell

@synthesize userPicImgView;
@synthesize userNameLbl;
@synthesize addUserBtn;
@synthesize deleteUserBtn;
@synthesize commentTextLbl;
//@synthesize dividerLbl;
@synthesize cellDividerLbl;

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

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    [super willTransitionToState:state];
    if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask)
    {
        for (UIView *subview in self.subviews)
        {
            if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"])
            {
//                UIButton *deleteBtn1 = (UIButton *)subview;
//                [deleteBtn1 setBackgroundImage:[UIImage imageNamed:@"CommentDelete"] forState:UIControlStateNormal];
//                NSLog(@"Delete button :%@",deleteBtn1);
//                UIImageView *deleteBtnImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
//                [deleteBtnImg setImage:[UIImage imageNamed:@"CommentDelete"]];
//                [[subview.subviews objectAtIndex:0] addSubview:deleteBtnImg];
            }
        }
    }
}


@end
