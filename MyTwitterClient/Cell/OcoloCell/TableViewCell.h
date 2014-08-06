//
//  OcoloTableViewCell.h
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/28.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SETextView.h"


@class TableViewCell;
@protocol TableViewCellDelegate <NSObject>
@optional

-(void) tableViewCell:(TableViewCell *) ocoloCell
               buttonImage:(UIImageView *) image;
@end

@interface TableViewCell : UITableViewCell



@property (weak, nonatomic) IBOutlet UILabel *body;//ツイート内容
@property (weak, nonatomic) IBOutlet UIImageView *prfImage;
//iconの画像
@property (weak, nonatomic) IBOutlet UILabel *spot;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *postTime;

@property (weak, nonatomic) IBOutlet UIImageView *snsLogo;

@property (weak, nonatomic) IBOutlet UIButton *postedImage;

@property(nonatomic,assign) id <TableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *postImageAi;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spotAi;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *distanceAi;


@property (weak, nonatomic) IBOutlet UILabel *spotName;


@property (weak, nonatomic) IBOutlet SETextView *tweetText;


- (IBAction)postedImage:(id)sender;

@end
