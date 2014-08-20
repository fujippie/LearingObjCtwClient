//
//  UIBarButtonItem+Extension.m
//  OCOLO
//
//  Created by masashi_tamayama on 2014/07/23.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import "UIBarButtonItem+Extension.h"

@implementation UIBarButtonItem (Extension)

+(UIBarButtonItem*)flexibleSpace
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

+(UIBarButtonItem*)fixedSpace:(CGFloat)width
{
    //固定幅のスペーサ
    UIBarButtonItem* fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = width; // 負の値を指定すると間隔が詰まる
    
    return fixedSpace;
}

@end
