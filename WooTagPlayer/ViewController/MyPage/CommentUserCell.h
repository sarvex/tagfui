/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>

@interface CommentUserCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *userPicImgView;
@property (nonatomic, retain) IBOutlet UILabel *userNameLbl;
@property (nonatomic, retain) IBOutlet UIButton *addUserBtn;
@property (nonatomic, retain) IBOutlet UIButton *deleteUserBtn;
@property (nonatomic, retain) IBOutlet UILabel *commentTextLbl;
//@property (nonatomic, retain) IBOutlet UILabel *dividerLbl;
@property (nonatomic, retain) IBOutlet UILabel *cellDividerLbl;

@end
