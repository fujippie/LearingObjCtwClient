//
//  UIAlertView+Extension.m
//  OCOLO
//
//  Created by masashi_tamayama on 2014/07/07.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import "UIAlertView+Extension.h"

@implementation UIAlertView (Extension)

+(void)showWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

+(void)showWithTitle:(NSString *)title
{
    [UIAlertView showWithTitle:title message:nil];
}

+(void)showWithMessage:(NSString *)message
{
    [UIAlertView showWithTitle:nil message:message];
}

@end
