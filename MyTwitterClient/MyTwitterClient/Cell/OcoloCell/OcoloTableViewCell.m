//
//  OcoloTableViewCell.m
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/28.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import "OcoloTableViewCell.h"

@implementation OcoloTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)postedImage:(UIButton *)imageButton {
    //引数のUIボタンの画像をデリゲートでMainViewCTRに渡す.
    DLog("ImageTapped");
    [self.delegate ocoloTableViewCell:(OcoloTableViewCell *) self
                      buttonImage:(UIImageView *) imageButton.imageView];
}


@end
