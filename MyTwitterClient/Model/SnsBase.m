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
    DLog("SNSBASE_GetSNSDATA");
    return nil;
}

-(NSInteger) _distanceWithLatitude:(CGFloat) latitude
                         Longitude:(CGFloat) longitude
{
    
    
    DLog("IS MAIN THREAD %hhd", [NSThread isMainThread]);
    //    GPSは有効か？
    if([CLLocationManager locationServicesEnabled])
    {//現在地を取得開始
        //startは一回で良いはず　変更する
        if([SnsBase getCurrentLocation] == nil)
        {
            DLog("LOACATIONMANAGER DIDUPDATE");
            [self.clMng startUpdatingLocation];
        }
    }
    //デリゲートで現在地がSetされる
    //    CLLocationDegrees double型
    CLLocation* cLLocation =[[CLLocation alloc]
                             initWithLatitude:((double)latitude)//latitude
                             longitude:((double)longitude)];
    //　距離を取得
    //    TODO:[現在地は取得待ちする必要あり]
    //     CLLocation* oosaka = [[ CLLocation alloc] initWithLatitude:34.701909 longitude:135.494977];
    //     DLog("CURRENTLOCCATION%@",[SnsBase getCurrentLocation]);
    
    //     dispatch_async(
    //                    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
    
    CLLocationDistance distance = [[SnsBase getCurrentLocation] distanceFromLocation:cLLocation];
    
    //                    });
    return (NSInteger)distance;
}

#pragma mark - Delegate
#pragma  mark CLLocationManager

-(void)locationManager:(CLLocationManager *)manager
    didUpdateLocations:(NSArray *)locations
{
    //    GPSで取得した最新の現在地(locations[0])//非同期
    //ツイートごとに現在地を取得することになる　現在地をクラス変数にする
    //現在地取得をやめる
    
    DLog("MainThread:%hhd",[NSThread isMainThread]);
    if([SnsBase  getCurrentLocation] == nil)
    {
        DLog("LOCATION UPDATED SETStart:%@", locations[0]);
        [SnsBase  setCurrentLocation:locations[0]];
    }
    
    [self.clMng stopUpdatingLocation];
    //Tweetの緯度経度　Tweetとの距離をセット
    //    CLLocationDistance distance = [locations[0] distanceFromLocation:locationB];
}

#pragma mark - Accessor
-(CLLocationManager*) clMng
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
