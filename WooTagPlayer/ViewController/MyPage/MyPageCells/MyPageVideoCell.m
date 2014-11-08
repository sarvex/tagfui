/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "MyPageVideoCell.h"

@implementation MyPageVideoCell

@synthesize userNameLbel;
@synthesize userProfileImgView;
@synthesize videoPlayBtn;
@synthesize videoBgImgView;
@synthesize userInfoBgImgView;
@synthesize userPicBtn;

@synthesize videoDescView;
@synthesize videoTitleLbl;
@synthesize latestTagLbl;
@synthesize videoCreatedLbl;
@synthesize videoDisplayTimeLbl;
@synthesize viewsLbl;
@synthesize videosViewsLbl;
@synthesize videoFeedCreatedLbl;
@synthesize videoFeedDisplayTimeLbl;

@synthesize tagsViewBgLbl;
@synthesize tagsViewsBg;
@synthesize tagsView;
@synthesize tagsCountImgView;
@synthesize numberOfTagsLbl;
@synthesize tagsBtn;

@synthesize likesView;
@synthesize likesCountImgView;
@synthesize numberOfLikesLbl;
@synthesize likesBtn;

@synthesize commentsView;
@synthesize commentsCountImgView;
@synthesize numberofCmntsLbl;
@synthesize commentsBtn;

@synthesize dividerLbl;

@synthesize lovedPersonsView;
@synthesize lovedPerson1;
@synthesize lovedPerson2;
@synthesize seeAllLovedBtn;

@synthesize allCommentsView;

@synthesize commentor1View;
@synthesize commentor1;
@synthesize commentText1;

@synthesize commentor2View;
@synthesize commentor2;
@synthesize commentText2;
//@synthesize seeAllComments;

@synthesize optionsView;
@synthesize likeBtn;
@synthesize commentBtn;
@synthesize optionsBtn;

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
