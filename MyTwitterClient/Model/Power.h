//
//  Power.h
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/08/12.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//
#import "Tweet.h"
#import <CoreLocation/CoreLocation.h>
#import "SETwitterHelper.h"


#import <Foundation/Foundation.h>
#import "SnsBase.h"
@interface Power : SnsBase
//店名,営業時間,定休日
//住所，

@property (nonatomic,strong) NSString* shopName;
@property (nonatomic,strong) NSString* openningHours;
@property (nonatomic,strong) NSString* regularHoliday;
+(instancetype) getSnsDataWithDictionary:(NSDictionary*)dic;

@end
