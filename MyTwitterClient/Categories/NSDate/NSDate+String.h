//
//  NSDate+String.h
//  OCOLO
//
//  Created by masashi_tamayama on 2014/07/29.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (String)

/**
 ex.yyyy/MM/dd HH:mm:ss
 */
-(NSString*) stringWithDateFormat:(NSString*)fmtStr;

-(NSString*)timeLineFormat;

@end
