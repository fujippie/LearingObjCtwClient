//
//  OcoloTableViewCell.h
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/28.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SETextView.h"


@class BaseTableViewCell;
@class Link;

@protocol TableViewCellDelegate <NSObject>

-(void) tableViewCell:(BaseTableViewCell *) tableviewCell
          postImageButton:(UIImageView *) image;

-(void) tableViewCell:(BaseTableViewCell *)tableViewCell
           tappedLink:(Link*)link;

-(void) tableViewCell:(BaseTableViewCell *) tableViewCell
              naviButtonWithAddress:(NSString*)address
             latitude:(CGFloat) latitude
           longtitude:(CGFloat)longtitude;

-(void) tableViewCell:(BaseTableViewCell *) tableViewCell
   accountImageButtonWith:(NSString*)accountName;

@end


@interface BaseTableViewCell : UITableViewCell
<SETextViewDelegate>

//@property (weak, nonatomic) IBOutlet UILabel *body;//ツイート内容
@property (weak, nonatomic) IBOutlet UIButton *prfImage;
//iconの画像
@property (weak, nonatomic) IBOutlet UILabel *spot;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *postTime;

@property (weak, nonatomic) IBOutlet UIImageView *snsLogo;

@property (weak, nonatomic) IBOutlet UIButton *postedImage;

@property(nonatomic,assign) id <TableViewCellDelegate> delegate;
//ActivityIndicator
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *postImageAi;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spotAi;
//@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *distanceAi;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *plfAi;

@property (weak, nonatomic) IBOutlet UIButton *naviButton;

@property (weak, nonatomic) IBOutlet UILabel *spotName;

@property (weak, nonatomic) IBOutlet SETextView *tweetText;


@property (strong, nonatomic) NSURL *nextURL;
@property (nonatomic, assign) CGFloat   latitude;        // 緯度
@property (nonatomic, assign) CGFloat   longitude;       // 経度






- (IBAction)postedImage:(id)sender;

@end
