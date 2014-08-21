//
//  Pin.h
//  OCOLO
//
//  Created by masashi_tamayama on 2014/07/25.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "BaseModel.h"

@class PostData;

/**
 マップのピン用モデル
 */
@interface Pin : BaseModel

// GEO
@property (nonatomic) CLLocationCoordinate2D coordinate;

// 将来実装
//@property (nonatomic) NSString* title;
@property (nonatomic) NSString* body;
@property (nonatomic) NSAttributedString* attributeBody;

// ユーザーサムネイル
@property (nonatomic) NSString* imageUrlStr;
@property (nonatomic) UIImage*  image; // キャッシュ用

// 投稿画像
@property (nonatomic) NSString* postImageUrlStr;
@property (nonatomic) UIImage*  postImage; // キャッシュ用

@property (nonatomic) NSDate*   created;
@property (nonatomic) NSString* createdSuchAsTwitter; // getterでcreatedを変換

// Ocoloの投稿内容の内、音声ファイルのURL
@property (nonatomic) NSString* soundUrlStr;

// 小窓用
@property (nonatomic) enum FAIcon categoryIconId;

// convert
+(instancetype) pinFromPostData:(PostData*)postData;

// init
+(instancetype) pinFromCoordinate:(CLLocationCoordinate2D)coordinate;

#pragma mark - Util

+(enum FAIcon) faIconWithCategoryName:(NSString*)categoryNm;

- (UIImage *)imageFromText:(NSString *)text
                      font:(UIFont*)font
                  rectSize:(CGSize)rectSize;

@end

