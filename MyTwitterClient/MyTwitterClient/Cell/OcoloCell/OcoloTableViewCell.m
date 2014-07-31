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

- (IBAction)postedImageTapped:(UIButton *)sender {
//    画像を拡大した画面を写すなど
    DLog("ImageTapped");
}
- (IBAction)postedImage:(id)sender {
}
@end
