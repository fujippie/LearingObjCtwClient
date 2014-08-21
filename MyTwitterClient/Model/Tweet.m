//
//  Tweet.m
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/15.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//
//[TODO:距離]
#import "Tweet.h"
#import <CoreLocation/CoreLocation.h>
#import "SETwitterHelper.h"
#import <Foundation/NSFormatter.h>
static CLLocation* currentLocation;//現在地

@implementation Tweet

static NSString* const _twitter = @"twitter";

+(instancetype) getSnsDataWithDictionary:(NSDictionary*)dic
{
    DLog("GETSNSDATA TWEET");
    Tweet* tweet = [[Tweet alloc] init];
    //allKeys Dictionary が持つ全ての値を取得
    
    tweet.snsLogoImageFileName = _twitter;
    
    tweet.attributedBody = [[SETwitterHelper sharedInstance] attributedStringWithTweet:dic];
    
    DLog(@"ATTRIBUTEEEE%@",tweet.attributedBody);
    if ([dic.allKeys containsObject:@"id"])
    {
        tweet.id = [dic[@"id"] unsignedLongLongValue];
    }
    
    if ([dic.allKeys containsObject:@"text"])//ツイート本文
    {
        tweet.simpleBody = dic[@"text"];
    }
    
    if([dic.allKeys containsObject:@"created_at"])
    {
//        tweet.postTime = [tweet _formatTimeString:dic[@"created_at"]];
        DLog("TWEET:%@",tweet.simpleBody);
    }
    
    if ([dic.allKeys containsObject:@"user"])
    {
        NSDictionary* userDic = dic[@"user"];
        
        if([userDic.allKeys containsObject:@"screen_name"])//アカウント名 @hoge
        {
            tweet.accountName = userDic[@"screen_name"];
        }
        
        if (//アイコン画像
            [userDic.allKeys containsObject:@"profile_image_url"]
            && userDic[@"profile_image_url"]
            && ![userDic[@"profile_image_url"] isEqual:[NSNull null]]
            )
        {
//For Debug
            tweet.profileImageUrl = userDic[@"profile_image_url"];
            
            __weak Tweet* weakTweet = tweet;
//            別スレッドで非同期実行
            
 ////////////遅延実行/////////////
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                           {//別スレッドで処理
                               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                               {
                                   
                                   if (weakTweet == nil)
                                   {
                                       return ;
                                   }
                                   
                                   NSData* profileImageData = [NSData dataWithContentsOfURL:
                                                               [NSURL URLWithString:weakTweet.profileImageUrl]];
                                   dispatch_sync(dispatch_get_main_queue(), ^{
                                       weakTweet.profileImage = [UIImage imageWithData:profileImageData];
                                   });
                               });
                           });
//////////元/////////////

//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^
//            {//別スレッドで処理
//            
//                if (weakTweet == nil) {
//                    return ;
//                }
//            
//                NSData* profileImageData = [NSData dataWithContentsOfURL:
//                                            [NSURL URLWithString:weakTweet.profileImageUrl]];
//            
//                weakTweet.profileImage = [UIImage imageWithData:profileImageData];
//            });
            
//////////元/////////////
        }
    }
    
    if ([dic.allKeys containsObject:@"geo"])
    {
        NSDictionary* geoDic = dic[@"geo"];
        if ([[NSNull null] isEqual:geoDic] == NO)
        {
            if ([geoDic.allKeys containsObject:@"coordinates"])
            {
                NSArray* coorinates = geoDic[@"coordinates"];
                if (coorinates.count == 2)
                {
                    tweet.latitude = [[coorinates objectAtIndex:0] floatValue];
                    tweet.longitude = [[coorinates objectAtIndex:1] floatValue];
                    DLog("location tweet:::%f %f",tweet.latitude,tweet.longitude);
// 現在地との距離を代入
//                    tweet.distance = [tweet _distanceWithLatitude: tweet.latitude Longitude: tweet.longitude];
                    
//                    [tweet.locationAtTweet distanceToCurrentLocation];
                    
//(緯度，経度)　=> 住所
                    CLLocation* location =[[CLLocation alloc] initWithLatitude:tweet.latitude longitude:tweet.longitude];
                    CLGeocoder* clg = [[CLGeocoder alloc] init];

//緯度経度から住所の情報を取得するところが非同期でメインスレッド
//住所をTweet型に格納するところは非同期で別スレッド　Cellに反映されるまで、時間がかかる
//
//                    DLog("MainThread:%hhd",[NSThread isMainThread]);//Main
                    [clg reverseGeocodeLocation:(CLLocation *)location
                              completionHandler:^(NSArray* placemarks, NSError* error)
                     {
//                         DLog("MainThread:%hhd",[NSThread isMainThread]);//Main
//                         DLog(@"count:%d obj:%@", placemarks.count, placemarks[0]);
                         for (CLPlacemark *placemark in placemarks)
                         {
                             // それぞれの結果（場所）の情報
                             NSMutableString* address = [NSMutableString stringWithFormat:@""];
                             [address appendString:@""];
                             BOOL isStateNull = ([placemark.addressDictionary[@"State"] length] ==0)     ? YES : NO;
                             BOOL isLocalNull = ([placemark.locality length] ==0)                        ? YES : NO;
                             BOOL isThoroNull = ([placemark.thoroughfare length] ==0)                    ? YES : NO;
                             BOOL isSubThoroNull = ([placemark.subThoroughfare length] ==0)              ? YES : NO;
                            
//                             DLog(@"\n\t%@\n",tweet.body);
//                             DLog(@"locality        : %@ BOOL : %hhd", placemark.locality,isLocalNull);
                             
//                             DLog(@"state           : %@ BOOL : %hhd", placemark.addressDictionary[@"State"],isThoroNull);
                                [address appendString:
                                 (isStateNull)? @"":placemark.addressDictionary[@"State"]];
                            
//                             DLog(@"thoroughfare    : %@ BOOL : %hhd", placemark.locality,isThoroNull);
                                [address appendString:
                                 (isStateNull || isLocalNull)? @"":placemark.locality];
                             
//                             DLog(@"thoroughfare    : %@ BOOL : %hhd", placemark.thoroughfare,isThoroNull);
                                [address appendString:
                                 (isStateNull || isLocalNull || isThoroNull)? @"":placemark.thoroughfare];
                             
//                             DLog(@"subThoroughfare : %@ BOOL : %hhd", placemark.subThoroughfare,isSubThoroNull);
                                [address appendString:
                                 (isStateNull || isLocalNull || isThoroNull || isSubThoroNull)? @"":placemark.subThoroughfare];
//                             DLog(@"ERROR:%@",error.domain);
//                             DLog("MainThread:%hhd",[NSThread isMainThread]);
//                             DLog("\n\tAddress      : %@", address);
                             __weak Tweet* wt =tweet;
                             //非同期で別スレッドで処理  //dispach_get_main_queue()
                           dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^(void)
                           {
                               //dispatch_async(dispatch_get_main_queue(),^(void){
//                                 DLog("ISMainThread？？？:%hhd",[NSThread isMainThread]);
                                 wt.address = address;
//                               DLog("ADDRESS::%@",wt.address);
                             });
                         }
                     }];
                }
                
            }
            
        }
    }
    return tweet;
}


-(UIImage*)_getPlfImageWithURL:(NSString*)url
{
    __weak UIImage* ui;
    DLog("GETPLFIMAGE1");
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^
//                {//別スレッドで処理
    DLog("GETPLFIMAGE2");
                    if ([url length]) {
                        DLog("GETPLFIMAGE3");//3が実行されるため,画像が格納されない
                        return nil;

                    }
                    NSData* profileImageData = [NSData dataWithContentsOfURL:
                                                [NSURL URLWithString:url]];
    
//                    weakTweet.profileImage = [UIImage imageWithData:profileImageData];
                    ui=[UIImage imageWithData:profileImageData];
    DLog("GETPLFIMAGE4");
//                });
    

    DLog("GETPLFIMAGE5%@",ui);
    
    
    return ui;
}



-(NSString*)_getAddressWithLocation:(CLLocation*)location
{
    
    return nil;
}


//TODO:[現在時刻はすぐに取れるが,ツイートの時刻は取得に時間がかかる.ツイート取得できたときに現在時刻を取得する必要がある]
//-(NSString *) _formatTimeString:(NSString*) postDateStr
//{
//    DLog("%@",postDateStr);
//    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];//入力用
//    
////MonやDecを解釈するため
//    NSLocale* locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
//    [dateFormatter setLocale:locale];
//    
//    
////Mon Dec 23 0:08:27 +0000 2013 APIの日付フォーマット
//    
//    [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
//    
//    NSDate* postDate =[dateFormatter dateFromString:postDateStr];
//    
//    
//    NSDate* currentDate =[NSDate date];//現在時刻
//    
////debug 現在時刻を一日後にする//currentDate = [currentDate dateByAddingTimeInterval:(60*60)*23.5];
//    
//    NSTimeInterval interval = [currentDate timeIntervalSinceDate:postDate];
//    
////分に変換後，文字列に変換
//    DLog("Interval:%f",interval);
//    
//    NSString* intervalStr = @"";
//    
//    
//    if (interval < 0)
//    {
//        interval = 0;
//        intervalStr = @"現在";
//    
//    }
//    else if(interval >0 && interval < 4){
//        
//        intervalStr = @"現在";
//    }
//
//    else if(interval >= 4 && interval < 60){
//        
//        intervalStr = [NSString stringWithFormat:@"%d秒",(int)(interval)];
//    }
//    
//    else if(interval >= 60 && interval < 60 * 60){
//        
//        intervalStr = [NSString stringWithFormat:@"%d分",(int)(interval/60)];
//    }
//    else if(interval >= 60 * 60 && interval < 60 * 60 * 24 ){
//        
//        intervalStr = [NSString stringWithFormat:@"%d時間",(int)(interval/(60*60)) ];
//    }
//    else if(interval >= 60 * 60 * 24 ){
//        
//        NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];//出力用
//        NSLocale* locale2 = [NSLocale currentLocale];
//        [dateFormatter2 setLocale:locale2];
//        //Mon Dec 23 0:08:27 +0000 2013 APIの日付フォーマット
//        [dateFormatter2 setDateFormat:@" MM月 dd日 "];
//        intervalStr= [dateFormatter2 stringFromDate:postDate];
//    }
//    
//    DLog("CURRENTTIME:%@",currentDate);
//    DLog("POSTDATE   :%@",postDate);
//    DLog("INTERVAL%@",intervalStr);
////    NSMutableString* str = [[NSMutableString alloc] initWithFormat:@"分前に投稿"];
////    [str insertString:intervalStr atIndex:0];
////    DLog(@"%@",str);
//    
////    DLog("CURRENTTIME:%@",currentDate);
////    DLog("POST:%@",postDate);
//    return intervalStr;
//}
//
//-(NSInteger) _distanceWithLatitude:(CGFloat) latitude
//                                  Longitude:(CGFloat) longitude
//{
//    DLog("IS MAIN THREAD %hhd",[NSThread isMainThread]);
//    //    GPSは有効か？
//    if([CLLocationManager locationServicesEnabled])
//    {//現在地を取得開始
//        [self.clMng startUpdatingLocation];
//    }
//    //デリゲートで現在地がSetされる
////    CLLocationDegrees double型
//    CLLocation* tweetAt =[[CLLocation alloc]
//                            initWithLatitude:((double)latitude)//latitude
//                                   longitude:((double)longitude)];
////　距離を取得
////    TODO:[現在地は取得待ちする必要あり]
//    
//    //////FOR TEST CLLocation* oosaka = [[ CLLocation alloc] initWithLatitude:34.701909 longitude:135.494977];
//
//    CLLocationDistance distance = [[Tweet getCurrentLocation] distanceFromLocation:tweetAt];
//    
//    
////  CLLocationDistanceは(meterで値が変える
//    
//    return (NSInteger)distance;
//}




#pragma mark - Delegate
#pragma  mark CLLocationManager
//-(void)locationManager:(CLLocationManager *)manager
//    didUpdateLocations:(NSArray *)locations//    GPSで取得した最新の現在地(locations[0])
//{
////ツイートごとに現在地を取得することになる　現在地をクラス変数にする
////現在地取得をやめる
//    [self.clMng stopUpdatingLocation];
//    if([Tweet getCurrentLocation]== nil){
//        [Tweet setCurrentLocation:locations[0]];
//    }
////Tweetの緯度経度　Tweetとの距離をセット
////    CLLocationDistance distance = [locations[0] distanceFromLocation:locationB];
//   
//}

#pragma mark - Accessor
//-(CLLocationManager*)clMng
//{
//    if(_clMng ==nil){
//        _clMng = [[CLLocationManager alloc] init];
//        _clMng.delegate = self;
//    }
//    return _clMng;
//}
//
//+(CLLocation *) getCurrentLocation
//{
//    return currentLocation;
//}
//
//+(void) setCurrentLocation:(CLLocation*) cl
//{
//    
//    currentLocation = cl;
////    DLog("SETCURRENT%@",currentLocation);//ok
//    return;
//}
//
//



@end
