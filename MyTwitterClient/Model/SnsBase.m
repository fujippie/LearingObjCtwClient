//
//  SnsBase.m
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/08/12.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import "SnsBase.h"

static CLLocation* currentLocation;

@implementation SnsBase
+(instancetype) getSnsDataWithDictionary:(NSDictionary*)dic
    {
        return nil;
    }

//TODO:[現在時刻はすぐに取れるが,ツイートの時刻は取得に時間がかかる.ツイート取得できたときに現在時刻を取得する必要がある]
-(NSString *) _formatTimeString:(NSString*) postDateStr
{
    DLog("%@",postDateStr);
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];//入力用
    
    //MonやDecを解釈するため
    NSLocale* locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    
    
    //Mon Dec 23 0:08:27 +0000 2013 APIの日付フォーマット
    
    [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    
    NSDate* postDate =[dateFormatter dateFromString:postDateStr];
    
    
    NSDate* currentDate =[NSDate date];//現在時刻
    
    //debug 現在時刻を一日後にする//currentDate = [currentDate dateByAddingTimeInterval:(60*60)*23.5];
    
    NSTimeInterval interval = [currentDate timeIntervalSinceDate:postDate];
    
    //分に変換後，文字列に変換
    DLog("Interval:%f",interval);
    
    NSString* intervalStr = @"";
    
    
    if (interval < 0)
    {
        interval = 0;
        intervalStr = @"現在";
        
    }
    else if(interval >0 && interval < 4){
        
        intervalStr = @"現在";
    }
    
    else if(interval >= 4 && interval < 60){
        
        intervalStr = [NSString stringWithFormat:@"%d秒",(int)(interval)];
    }
    
    else if(interval >= 60 && interval < 60 * 60){
        
        intervalStr = [NSString stringWithFormat:@"%d分",(int)(interval/60)];
    }
    else if(interval >= 60 * 60 && interval < 60 * 60 * 24 ){
        
        intervalStr = [NSString stringWithFormat:@"%d時間",(int)(interval/(60*60)) ];
    }
    else if(interval >= 60 * 60 * 24 ){
        
        NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];//出力用
        NSLocale* locale2 = [NSLocale currentLocale];
        [dateFormatter2 setLocale:locale2];
        //Mon Dec 23 0:08:27 +0000 2013 APIの日付フォーマット
        [dateFormatter2 setDateFormat:@" MM月 dd日 "];
        intervalStr= [dateFormatter2 stringFromDate:postDate];
    }
    
    DLog("CURRENTTIME:%@",currentDate);
    DLog("POSTDATE   :%@",postDate);
    DLog("INTERVAL%@",intervalStr);
    //    NSMutableString* str = [[NSMutableString alloc] initWithFormat:@"分前に投稿"];
    //    [str insertString:intervalStr atIndex:0];
    //    DLog(@"%@",str);
    
    //    DLog("CURRENTTIME:%@",currentDate);
    //    DLog("POST:%@",postDate);
    return intervalStr;
}

 -(NSInteger) _distanceWithLatitude:(CGFloat) latitude
 Longitude:(CGFloat) longitude
 {
 DLog("IS MAIN THREAD %hhd",[NSThread isMainThread]);
 //    GPSは有効か？
 if([CLLocationManager locationServicesEnabled])
 {//現在地を取得開始
 [self.clMng startUpdatingLocation];
 }
 //デリゲートで現在地がSetされる
 //    CLLocationDegrees double型
 CLLocation* cLLocation =[[CLLocation alloc]
 initWithLatitude:((double)latitude)//latitude
 longitude:((double)longitude)];
 //　距離を取得
 //    TODO:[現在地は取得待ちする必要あり]
 
 //////FOR TEST CLLocation* oosaka = [[ CLLocation alloc] initWithLatitude:34.701909 longitude:135.494977];
 
 CLLocationDistance distance = [[SnsBase getCurrentLocation] distanceFromLocation:cLLocation];
 //  CLLocationDistanceは(meterで値が変える

 return (NSInteger)distance;
 }
 #pragma mark - Delegate
 #pragma  mark CLLocationManager
 -(void)locationManager:(CLLocationManager *)manager
 didUpdateLocations:(NSArray *)locations//    GPSで取得した最新の現在地(locations[0])
 {
 //ツイートごとに現在地を取得することになる　現在地をクラス変数にする
 //現在地取得をやめる
 [self.clMng stopUpdatingLocation];
 if([SnsBase  getCurrentLocation]== nil){
 [SnsBase  setCurrentLocation:locations[0]];
 }
 //Tweetの緯度経度　Tweetとの距離をセット
 //    CLLocationDistance distance = [locations[0] distanceFromLocation:locationB];
 
 }
 
 #pragma mark - Accessor
 -(CLLocationManager*)clMng
 {
 if(_clMng ==nil){
 _clMng = [[CLLocationManager alloc] init];
 _clMng.delegate = self;
 }
 return _clMng;
 }
 
 +(CLLocation *) getCurrentLocation
 {
 return currentLocation;
 }
 
 +(void) setCurrentLocation:(CLLocation*) cl
 {
 
 currentLocation = cl;
 //    DLog("SETCURRENT%@",currentLocation);//ok
 return;
 }
 


@end
