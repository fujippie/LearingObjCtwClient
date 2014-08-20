//
//  Instagram.h
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

@interface Instagram : SnsBase
//アカウント名,テキスト,投稿時間,位置,プロフィール画像,投稿画像,動画

@property (nonatomic, strong) UIImage* profileImage;
@property (nonatomic, strong) NSString* profileImageUrl; // プロフィール画像URL
@property (nonatomic, strong) NSString* accountName;     //アカウント名

//電源スポット以外は使用
@property (nonatomic,strong) NSString* postTime;

+(instancetype) getSnsDataWithDictionary:(NSDictionary*)dic;

@end
