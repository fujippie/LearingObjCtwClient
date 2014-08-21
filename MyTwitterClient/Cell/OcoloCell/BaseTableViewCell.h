//
//  BaseTableViewCell.h
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/28.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SETextView.h"

@class BaseTableViewCell;
@class Pin;
@class Link;

@protocol BaseTableViewCellDelegate <NSObject>

-(void)           tableViewCell:(BaseTableViewCell *)tableViewCell
tappedProfileImageButtonWithPin:(Pin*)pin;

-(void)        tableViewCell:(BaseTableViewCell *)tableviewCell
tappedPostImageButtonWithPin:(Pin*)pin;

-(void) tableViewCell:(BaseTableViewCell *)tableViewCell
           tappedLink:(Link*)link;

-(void)      tableViewCell:(BaseTableViewCell *)tableViewCell
tappedToPlaceButtonWithPin:(Pin*)pin;

@end

@interface BaseTableViewCell : UITableViewCell
<SETextViewDelegate>

#pragma mark - IBOutlet

@property (strong, nonatomic) UIImage *prfImage; // 画像セット用

@property (weak, nonatomic) IBOutlet UIButton *prfImageBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* prfAi;
@property (weak, nonatomic) IBOutlet UILabel* iconLbl;

@property (weak, nonatomic) IBOutlet UILabel* distanceLbl;
@property (weak, nonatomic) IBOutlet UILabel* spotLbl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* spotAi;

@property (weak, nonatomic) IBOutlet SETextView* bodyTv;

@property (strong, nonatomic) UIImage* postedImage; // 画像セット用

@property (weak, nonatomic) IBOutlet UIButton* postedImageBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* postImageAi;

@property (weak, nonatomic) IBOutlet UILabel* postTimeLbl;

@property (weak, nonatomic) IBOutlet UIButton* toPlaceBtn;

#pragma mark -

@property (nonatomic, assign) id <BaseTableViewCellDelegate> delegate;
@property (nonatomic) Pin* pin;

#pragma mark - Default

+(CGFloat) defaultBodyHeight;

#pragma mark -

-(void)setPin:(Pin *)pin currentCoord:(CLLocationCoordinate2D)currentCoord;

@end
