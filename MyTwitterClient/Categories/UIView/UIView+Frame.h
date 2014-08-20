//
//  UIView+Frame.h
//  OCOLO
//
//  Created by masashi_tamayama on 2014/07/22.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGSize  size;

@end
