//
//  BaseTableViewCell.h
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/28.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SETextView.h"
#import "Tweet.h"
#import "Instagram.h"

@class BaseTableViewCell;
@class SnsBase;
@class Link;

@protocol BaseTableViewCellDelegate <NSObject>

-(void)           tableViewCell:(BaseTableViewCell *)tableViewCell
tappedProfileImageButtonWithPin:(SnsBase*)pin;

-(void)        tableViewCell:(BaseTableViewCell *)tableviewCell
tappedPostImageButtonWithPin:(SnsBase*)pin;

-(void) tableViewCell:(BaseTableViewCell *)tableViewCell
           tappedLink:(Link*)link;

-(void)      tableViewCell:(BaseTableViewCell *)tableViewCell
tappedToPlaceButtonWithPin:(SnsBase*)pin;

@end

@interface BaseTableViewCell : UITableViewCell
<SETextViewDelegate>

#pragma mark - IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *prfImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* prfAi;

//iconの画像
@property (weak, nonatomic) IBOutlet UILabel* postTime;

@property (weak, nonatomic) IBOutlet UIImageView* snsLogo;

@property (weak, nonatomic) IBOutlet UIButton* postedImageButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* postImageAi;

@property (weak, nonatomic) IBOutlet SETextView* body;

@property (weak, nonatomic) IBOutlet UILabel* spot;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* spotAi;

@property (weak, nonatomic) IBOutlet UIButton* toPlaceButton;

#pragma mark -

@property (nonatomic, assign) id <BaseTableViewCellDelegate> delegate;
@property (nonatomic) SnsBase* pin;

#pragma mark - Caluculating

+(CGFloat) defaultHeightIsPostImage:(BOOL)isPostImage;

@end
