//
//  BaseSingleton.h
//  OCOLO
//
//  Created by masashi_tamayama on 2014/08/11.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseSingleton : NSObject

+ (instancetype) sharedInstance;
- (instancetype) initSharedInstance;

@end
