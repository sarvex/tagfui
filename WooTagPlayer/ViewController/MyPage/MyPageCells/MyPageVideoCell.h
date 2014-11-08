/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>
#import "CommentTextView.h"
@interface MyPageVideoCell : UITableViewCell {
  
    IBOutlet UILabel *userNameLbel;
    IBOutlet UIImageView *userProfileImgView;
    IBOutlet UIButton *videoPlayBtn;
    IBOutlet UIImageView *videoBgImgView;
    IBOutlet UIButton *userPicBtn;
    IBOutlet UIImageView *userInfoBgImgView;
    
    // Video Description view
    IBOutlet UIView *videoDescView;
    IBOutlet UILabel *videoTitleLbl;
    IBOutlet UILabel *latestTagLbl;
    IBOutlet UILabel *videoCreatedLbl;
    IBOutlet UILabel *videoDisplayTimeLbl;
    IBOutlet UILabel *videoFeedCreatedLbl;
    IBOutlet UILabel *videoFeedDisplayTimeLbl;
    IBOutlet UILabel *viewsLbl;
    IBOutlet UILabel *videosViewsLbl;
    
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
    
    IBOutlet UILabel *dividerLbl;
    
    
    //Loved
    IBOutlet UIView *lovedPersonsView;
    IBOutlet UIButton *lovedPerson1;
    IBOutlet UIButton *lovedPerson2;
    IBOutlet UIButton *seeAllLovedBtn;
    
    //Comments
    IBOutlet UIView *allCommentsView;
    
    IBOutlet UIView *commentor1View;
    IBOutlet UIButton *commentor1;
    IBOutlet UILabel *commentText1;
    
    IBOutlet UIView *commentor2View;
    IBOutlet UIButton *commentor2;
    IBOutlet UILabel *commentText2;
    
//    IBOutlet UIButton *seeAllComments;
    
    IBOutlet UIView *optionsView;
    IBOutlet UIButton *likeBtn;
    IBOutlet UIButton *commentBtn;
    IBOutlet UIButton *optionsBtn;
}

@property (nonatomic, retain) UILabel *userNameLbel;
@property (nonatomic, retain) UIImageView *userProfileImgView;
@property (nonatomic, retain) UIButton *videoPlayBtn;
@property (nonatomic, retain) UIImageView *videoBgImgView;
@property (nonatomic, retain) UIImageView *userInfoBgImgView;
@property (nonatomic, retain) UIButton *userPicBtn;
@property (nonatomic, retain) UIView *videoDescView;
@property (nonatomic, retain) UILabel *videoTitleLbl;
@property (nonatomic, retain) UILabel *latestTagLbl;
@property (nonatomic, retain) UILabel *videoCreatedLbl;
@property (nonatomic, retain) UILabel *videoDisplayTimeLbl;
@property (nonatomic, retain) UILabel *viewsLbl;
@property (nonatomic, retain) UILabel *videosViewsLbl;
@property (nonatomic, retain) IBOutlet UILabel *videoFeedCreatedLbl;
@property (nonatomic, retain) IBOutlet UILabel *videoFeedDisplayTimeLbl;
@property (nonatomic, retain) UIView *tagsViewsBg;
@property (nonatomic, retain) IBOutlet UILabel *tagsViewBgLbl;
@property (nonatomic, retain) UIView *tagsView;
@property (nonatomic, retain) UIImageView *tagsCountImgView;
@property (nonatomic, retain) UILabel *numberOfTagsLbl;
@property (nonatomic, retain) UIButton *tagsBtn;

@property (nonatomic, retain) UIView *likesView;
@property (nonatomic, retain) UIImageView *likesCountImgView;
@property (nonatomic, retain) UILabel *numberOfLikesLbl;
@property (nonatomic, retain) UIButton *likesBtn;

@property (nonatomic, retain) UIView *commentsView;
@property (nonatomic, retain) UIImageView *commentsCountImgView;
@property (nonatomic, retain) UILabel *numberofCmntsLbl;
@property (nonatomic, retain) UIButton *commentsBtn;

@property (nonatomic, retain) UILabel *dividerLbl;

@property (nonatomic, retain) IBOutlet UIView *lovedPersonsView;
@property (nonatomic, retain) IBOutlet UIButton *lovedPerson1;
@property (nonatomic, retain) IBOutlet UIButton *lovedPerson2;
@property (nonatomic, retain) IBOutlet UIButton *seeAllLovedBtn;

//Comments
@property (nonatomic, retain) IBOutlet UIView *allCommentsView;
@property (nonatomic, retain) IBOutlet UIView *commentor2View;
@property (nonatomic, retain) IBOutlet UIButton *commentor1;
@property (nonatomic, retain) IBOutlet UILabel *commentText1;

@property (nonatomic, retain) UIView *commentor1View;
@property (nonatomic, retain) IBOutlet UIButton *commentor2;
@property (nonatomic, retain) IBOutlet UILabel *commentText2;

//@property (nonatomic, retain) IBOutlet UIButton *seeAllComments;

@property (nonatomic, retain) UIView *optionsView;
@property (nonatomic, retain) UIButton *likeBtn;
@property (nonatomic, retain) UIButton *commentBtn;
@property (nonatomic, retain) UIButton *optionsBtn;
@end
