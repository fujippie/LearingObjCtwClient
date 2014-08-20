//
//  UIView+Frame.m
//  OCOLO
//
//  Created by masashi_tamayama on 2014/07/22.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

- (CGFloat)width
{
    return self.frame.size.width;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void) setHeight:(CGFloat)newHeight {
    CGRect frame = self.frame;
    frame.size.height = newHeight;
    self.frame = frame;
}

- (void) setWidth:(CGFloat)newWidth {
    CGRect frame = self.frame;
    frame.size.width = newWidth;
    self.frame = frame;
}

- (void) setX:(CGFloat)newX {
    CGRect frame = self.frame;
    frame.origin.x = newX;
    self.frame = frame;
}

- (void) setY:(CGFloat)newY {
    CGRect frame = self.frame;
    frame.origin.y = newY;
    self.frame = frame;
}

- (CGSize)size
{
    return self.bounds.size;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

@end
