/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import "BrowseCell.h"

@implementation BrowseCell
@synthesize videoCoverBgImgView;
@synthesize latestTagLabel;
@synthesize latestTagBg;
@synthesize tagImg;

@synthesize videoPlayBtn;

@synthesize tagsViewsBg;
@synthesize tagsViewBgLbl;

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

@synthesize videosView;
@synthesize videosCountImgView;
@synthesize numberOfVideosLbl;
@synthesize videosBtn;

@synthesize optionsView;
@synthesize likeBtn;
@synthesize commentBtn;
@synthesize optionsBtn;

@synthesize dividerLbl;

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
