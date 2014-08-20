//
//  LinkHelper.h
//  OCOLO
//
//  Created by masashi_tamayama on 2014/08/12.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

#import "BaseSingleton.h"

@interface LinkHelper : BaseSingleton

- (NSAttributedString *)attributedStringWithText:(NSString*)text
                                        fontSize:(CGFloat)fontSize;

@end
