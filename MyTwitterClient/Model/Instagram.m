//
//  Instagram.m
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/08/12.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import "Instagram.h"

@implementation Instagram

+(instancetype) getSnsDataWithDictionary:(NSDictionary*)dic
{
    DLog("GETSNSDATA______INSTA");
    Instagram* instagram = [[Instagram alloc] init];
    //allKeys Dictionary が持つ全ての値を取得
    ////////////遅延実行/////////////
    DLog("WEAKTEET0");
                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{//[遅延実行で確認]
                           if (instagram.postImage) {
                               DLog("WEAKTEET1");
                           
                           }
                              instagram.postImage = [UIImage imageNamed:@"female.jpeg"];
                           DLog("WEAKTEET2");
                       });
    
    instagram.postImage = [UIImage imageNamed:@"female.jpeg"];

    instagram.snsLogoImageFileName = @"instagram";
    
    instagram.attributedBody = [[SETwitterHelper sharedInstance] attributedStringWithTweet:dic];
    
    DLog(@"ATTRIBUTEEEE%@",instagram.attributedBody);
    if ([dic.allKeys containsObject:@"id"])
    {
        instagram.id = [dic[@"id"] unsignedLongLongValue];
    }
    
    if ([dic.allKeys containsObject:@"text"])//ツイート本文
    {
        instagram.simpleBody = dic[@"text"];
    }
    
    if([dic.allKeys containsObject:@"created_at"])
    {
        instagram.postTime=[instagram _formatTimeString:dic[@"created_at"]];
        DLog("TWEET:%@",instagram.simpleBody);
    }
    
    if ([dic.allKeys containsObject:@"user"])
    {
        NSDictionary* userDic = dic[@"user"];
        
        if([userDic.allKeys containsObject:@"screen_name"])//アカウント名 @hoge
        {
            instagram.accountName = userDic[@"screen_name"];
        }
        
        if (//アイコン画像
            [userDic.allKeys containsObject:@"profile_image_url"]
            && userDic[@"profile_image_url"]
            && ![userDic[@"profile_image_url"] isEqual:[NSNull null]]
            )
        {
            //For Debug
            instagram.profileImageUrl = userDic[@"profile_image_url"];
            
            __weak Instagram* weakInstagram = instagram;
            //            別スレッドで非同期実行

            ////////////遅延実行/////////////
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^
                           {//別スレッドで処理
                               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                   if (weakInstagram == nil) {
                                       DLog("WEAKTEET NIL");
                                       return ;
                                   }
                                   NSData* profileImageData = [NSData dataWithContentsOfURL:
                                                               [NSURL URLWithString:weakInstagram.profileImageUrl]];
                                   weakInstagram.profileImage = [UIImage imageWithData:profileImageData];
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
                    instagram.latitude = [[coorinates objectAtIndex:0] floatValue];
                    instagram.longitude = [[coorinates objectAtIndex:1] floatValue];
                    // 現在地との距離を代入
                    instagram.distance = [instagram _distanceWithLatitude: instagram.latitude Longitude: instagram.longitude];
                    //                    [tweet.locationAtTweet distanceToCurrentLocation];
                    
                    //(緯度，経度)　=> 住所
                    CLLocation* location =[[CLLocation alloc] initWithLatitude:instagram.latitude longitude:instagram.longitude];
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
                             __weak Instagram* wInsta =instagram;
                             //非同期で別スレッドで処理  //dispach_get_main_queue()
                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^(void)
                                            {
                                                //dispatch_async(dispatch_get_main_queue(),^(void){
                                                //                                 DLog("ISMainThread？？？:%hhd",[NSThread isMainThread]);
                                                wInsta.address = address;
                                            });
                         }
                     }];
                }
                
            }
            
        }
    }
    return instagram;


}
@end
