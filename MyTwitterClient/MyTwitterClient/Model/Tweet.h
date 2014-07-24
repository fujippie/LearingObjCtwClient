//
//  Tweet.h
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/15.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tweet : NSObject

@property (nonatomic, assign) unsigned long long id;     // ツイートID
@property (nonatomic, strong) NSString* body;            // ツイート内容
@property (nonatomic, strong) NSString* profileImageUrl; // プロフィール画像URL
@property (nonatomic, assign) CGFloat   latitude;        // 緯度
@property (nonatomic, assign) CGFloat   longitude;       // 経度

// プロフィール画像をダウンロードしたあとのキャッシュ
@property (nonatomic, strong) UIImage* profileImage;

+(instancetype) tweetWithDic:(NSDictionary*)dic;


@end
