//
//  Ocolo.h
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
@interface Ocolo : SnsBase
//投稿時間テキスト,位置,投稿時間,投稿画像,

@property (nonatomic, strong) NSString* postImageURL; //投稿された画像URL

//@property (nonatomic,strong) NSString* postTime;
+(instancetype) getSnsDataWithDictionary:(NSDictionary*)dic;

@end
