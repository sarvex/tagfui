/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#import <UIKit/UIKit.h>

@interface CommentTextView : UITextView {
    NSIndexPath *indexPath;
    NSString *commentText;
    NSString *placeHolderText;
}
@property (nonatomic, strong)NSIndexPath *indexPath;
@property (nonatomic, strong) NSString *commentText;
@property (nonatomic, strong) NSString *placeHolderText;
@end
