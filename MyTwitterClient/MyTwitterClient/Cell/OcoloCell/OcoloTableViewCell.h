//
//  OcoloTableViewCell.h
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/28.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OcoloTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *body;//ツイート内容
@property (weak, nonatomic) IBOutlet UIImageView *prfImage;
//iconの画像
@property (weak, nonatomic) IBOutlet UILabel *spot;
@property (weak, nonatomic) IBOutlet UILabel *accountName;
@property (weak, nonatomic) IBOutlet UILabel *postTime;

@end
