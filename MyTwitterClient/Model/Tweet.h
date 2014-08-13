//
//  Tweet.h
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/15.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SnsBase.h"
@interface Tweet : SnsBase
@property (nonatomic, strong) UIImage* profileImage;
@property (nonatomic, strong) NSString* profileImageUrl; // プロフィール画像URL
@property (nonatomic, strong) NSString* accountName;     //アカウント名

//電源スポット以外は使用
@property (nonatomic,strong) NSString* postTime;
+(instancetype) getSnsDataWithDictionary:(NSDictionary*)dic;

@end
