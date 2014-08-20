//
//  BaseModel.m
//  OCOLO
//
//  Created by masashi_tamayama on 2014/07/25.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel

-(id)assignValueFromDic:(NSDictionary*)dic
                    key:(NSString*)key
{
    if (
        dic
        && [dic.allKeys containsObject:key]
        && dic[key]
        && ![dic[key] isEqual:[NSNull null]]
        )
    {
        if ([dic[key] isKindOfClass:[NSString class]])
        {
            NSString* tmpStr = dic[key];
            if (tmpStr == nil || tmpStr.length <= 0 || [tmpStr isEqualToString:@"<null>"])
            {
                return nil;
            }
        }
        
        return dic[key];
    }
    
    return nil;
}

@end
