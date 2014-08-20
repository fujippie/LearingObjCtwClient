//
//  UIAlertView+Extension.h
//  OCOLO
//
//  Created by masashi_tamayama on 2014/07/07.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Extension)

+(void)showWithTitle:(NSString*)title message:(NSString*)message;
+(void)showWithTitle:(NSString*)title;
+(void)showWithMessage:(NSString*)message;

@end
