//
//  UIViewController+Extensions.m
//  MyTwitterClient
//
//  Created by masashi_tamayama on 2014/07/10.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import "UIViewController+Extensions.h"

@implementation UIViewController (Extensions)

# pragma mark - LifeCycle
+(id)newBindNib
{
    NSString *nibNameOrNil = NSStringFromClass([self class]);
    return [[[self class] alloc] initWithNibName:nibNameOrNil bundle:nil];
}

@end
