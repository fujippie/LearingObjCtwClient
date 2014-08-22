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

/**
 @param dic 検索対象の辞書
 @param path KVCの仕様に準拠
 */
-(id)assignValueFromDic:(NSDictionary*)dic
                   path:(NSString*)path;

@end
