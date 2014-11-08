/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>

@interface BrowseCell : UITableViewCell {
    IBOutlet UIImageView *videoCoverBgImgView;
    IBOutlet UILabel *latestTagLabel;
    IBOutlet UIView *latestTagBg;
    IBOutlet UIImageView *tagImg;
    
    IBOutlet UIButton *videoPlayBtn;
    
    IBOutlet UIView *tagsViewsBg;
    IBOutlet UILabel *tagsViewBgLbl;
    
    //TagsView
    IBOutlet UIView *tagsView;
    IBOutlet UIImageView *tagsCountImgView;
    IBOutlet UILabel *numberOfTagsLbl;
    IBOutlet UIButton *tagsBtn;
    
    //Likes Views
    IBOutlet UIView *likesView;
    IBOutlet UIImageView *likesCountImgView;
    IBOutlet UILabel *numberOfLikesLbl;
    IBOutlet UIButton *likesBtn;
    
    //Comments view
    IBOutlet UIView *commentsView;
    IBOutlet UIImageView *commentsCountImgView;
    IBOutlet UILabel *numberofCmntsLbl;
    IBOutlet UIButton *commentsBtn;
    
    //Videos view
    IBOutlet UIView *videosView;
    IBOutlet UIImageView *videosCountImgView;
    IBOutlet UILabel *numberOfVideosLbl;
    IBOutlet UIButton *videosBtn;
    
    IBOutlet UIView *optionsView;
    IBOutlet UIButton *likeBtn;
    IBOutlet UIButton *commentBtn;
    IBOutlet UIButton *optionsBtn;
    
    IBOutlet UILabel *dividerLbl;
}

@property (nonatomic, retain) UIImageView *videoCoverBgImgView;
@property (nonatomic, retain) UILabel *latestTagLabel;
@property (nonatomic, retain) UIView *latestTagBg;
@property (nonatomic, retain) IBOutlet UIImageView *tagImg;

@property (nonatomic, retain) IBOutlet UIButton *videoPlayBtn;

@property (nonatomic, retain) IBOutlet UIView *tagsViewsBg;
@property (nonatomic, retain) IBOutlet UILabel *tagsViewBgLbl;

@property (nonatomic, retain) IBOutlet UIView *tagsView;
@property (nonatomic, retain) IBOutlet UIImageView *tagsCountImgView;
@property (nonatomic, retain) IBOutlet UILabel *numberOfTagsLbl;
@property (nonatomic, retain) IBOutlet UIButton *tagsBtn;

@property (nonatomic, retain) IBOutlet UIView *likesView;
@property (nonatomic, retain) IBOutlet UIImageView *likesCountImgView;
@property (nonatomic, retain) IBOutlet UILabel *numberOfLikesLbl;
@property (nonatomic, retain) IBOutlet UIButton *likesBtn;

@property (nonatomic, retain) IBOutlet UIView *commentsView;
@property (nonatomic, retain) IBOutlet UIImageView *commentsCountImgView;
@property (nonatomic, retain) IBOutlet UILabel *numberofCmntsLbl;
@property (nonatomic, retain) IBOutlet UIButton *commentsBtn;

@property (nonatomic, retain) IBOutlet UIView *videosView;
@property (nonatomic, retain) IBOutlet UIImageView *videosCountImgView;
@property (nonatomic, retain) IBOutlet UILabel *numberOfVideosLbl;
@property (nonatomic, retain) IBOutlet UIButton *videosBtn;

@property (nonatomic, retain) IBOutlet UIView *optionsView;
@property (nonatomic, retain) IBOutlet UIButton *likeBtn;
@property (nonatomic, retain) IBOutlet UIButton *commentBtn;
@property (nonatomic, retain) IBOutlet UIButton *optionsBtn;

@property (nonatomic, retain) IBOutlet UILabel *dividerLbl;

@end
