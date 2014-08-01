//
//  OcoloTableViewCell.h
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/28.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OcoloTableViewCell;
@protocol OcoloTableViewCellDelegate <NSObject>
@optional

-(void) ocoloTableViewCell:(OcoloTableViewCell *) ocoloCell
               buttonImage:(UIImageView *) image;
@end


@interface OcoloTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *body;//ツイート内容
@property (weak, nonatomic) IBOutlet UIImageView *prfImage;
//iconの画像
@property (weak, nonatomic) IBOutlet UILabel *spot;
@property (weak, nonatomic) IBOutlet UILabel *accountName;
@property (weak, nonatomic) IBOutlet UILabel *postTime;

@property (weak, nonatomic) IBOutlet UIImageView *snsLogo;

@property (weak, nonatomic) IBOutlet UIButton *postedImage;

@property(nonatomic,assign) id <OcoloTableViewCellDelegate> delegate;

- (IBAction)postedImage:(id)sender;

@end
