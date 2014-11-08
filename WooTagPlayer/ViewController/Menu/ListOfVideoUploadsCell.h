/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>

@interface ListOfVideoUploadsCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *videoTitleLbl;
@property (nonatomic, retain) IBOutlet UILabel *videoCreatedTimeLbl;
//@property (nonatomic, retain) IBOutlet UIProgressView *videoUploadProgress;
@property (nonatomic, retain) IBOutlet UILabel *uploadingLbl;
@property (nonatomic, retain) IBOutlet UILabel *percentageLbl;
@property (nonatomic, retain) IBOutlet UIView *titleView;
@property (nonatomic, retain) IBOutlet UIButton *deleteBtn;
@property (nonatomic, retain) IBOutlet UIButton *retryBtn;
@end
