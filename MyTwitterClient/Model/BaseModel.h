//
//  BaseModel.h
//  OCOLO
//
//  Created by masashi_tamayama on 2014/07/25.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseModel : NSObject


// @protected
/**
 */
-(id) assignValueFromDic:(NSDictionary*)dic
                     key:(NSString*)key;

@end
