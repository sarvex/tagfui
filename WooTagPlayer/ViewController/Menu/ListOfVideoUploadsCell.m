/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "ListOfVideoUploadsCell.h"

@implementation ListOfVideoUploadsCell

@synthesize videoTitleLbl;
@synthesize videoCreatedTimeLbl;
//@synthesize videoUploadProgress;
@synthesize uploadingLbl;
@synthesize percentageLbl;
@synthesize titleView;
@synthesize deleteBtn;
@synthesize retryBtn;

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

@end
