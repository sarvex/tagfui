/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>

@interface SuggestedUserCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *userProfileImgView;
@property (nonatomic, strong) IBOutlet UILabel *userNameLbl;
@property (nonatomic, strong) IBOutlet UILabel *descLbl;
@property (nonatomic, strong) IBOutlet UIButton *addBtn;
@property (nonatomic, strong) IBOutlet UIButton *inviteBtn;
@end
