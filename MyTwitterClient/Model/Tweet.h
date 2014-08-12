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


@property (nonatomic, assign) unsigned long long id;     // ツイートID
//@property (nonatomic, strong) NSString* simpleBody;            // ツイート内容
//@property (nonatomic, strong) NSAttributedString* attributedBody;
@property (nonatomic, strong) NSString* profileImageUrl; // プロフィール画像URL
//@property (nonatomic, assign) CGFloat   latitude;        // 緯度　スーパクラスへ移動
//@property (nonatomic, assign) CGFloat   longitude;       // 経度　スーパクラスへ移動
//@property (nonatomic, strong) NSString* address;//スーパクラスへ移動
//@property (nonatomic, strong) NSString* accountName;     //アカウント名//スーパクラスへ移動
//@property (nonatomic, strong) time // ツイートした時間(何分前)

@property (nonatomic, strong) NSString* tweetImageURL; //ツイッターで投稿された画像を取得

//TODO:[ リクエスト時に引数を追加"include_entities"=>true //画像などリンクを取得できる]
//現在地と目的地との距離(m)
//@property (nonatomic,assign) NSInteger distance;//meterスーパクラスへ移動
// プロフィール画像をダウンロードしたあとのキャッシュ
//@property (nonatomic, strong) UIImage* profileImage;//スーパクラスへ移動

//投稿してから　何分前　か
//@property (nonatomic,strong) NSString* postTime;//スーパクラスへ移動
//
//@property (nonatomic,strong) CLLocationManager* clMng;//スーパクラスへ移動
//
+(instancetype) getSnsDataWithDictionary:(NSDictionary*)dic;

@end
