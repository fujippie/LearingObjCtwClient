//
//  Tweet.m
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/15.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import "Tweet.h"
#import <CoreLocation/CoreLocation.h>
@implementation Tweet
//+(instancetype) tweetWithPost{}
+(instancetype) tweetWithDic:(NSDictionary*)dic
{
    Tweet* tweet = [[Tweet alloc] init];
    
    if ([dic.allKeys containsObject:@"id"])
    {
        tweet.id = [dic[@"id"] unsignedLongLongValue];
    }
    
    if ([dic.allKeys containsObject:@"text"])
    {
        tweet.body = dic[@"text"];
    }
    
    if ([dic.allKeys containsObject:@"user"])
    {
        NSDictionary* userDic = dic[@"user"];
        
        if (
            [userDic.allKeys containsObject:@"profile_image_url"]
            && userDic[@"profile_image_url"]
            && ![userDic[@"profile_image_url"] isEqual:[NSNull null]]
            )
        {
            tweet.profileImageUrl = userDic[@"profile_image_url"];

            __weak Tweet* weakTweet = tweet;
//            別スレッドで実行
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^
            {
                if (weakTweet == nil) {
                    return ;
                }
                
                NSData* profileImageData = [NSData dataWithContentsOfURL:
                                            [NSURL URLWithString:weakTweet.profileImageUrl]];
                weakTweet.profileImage = [UIImage imageWithData:profileImageData];
            });
        }
    }
    
    if ([dic.allKeys containsObject:@"geo"])
    {
        NSDictionary* geoDic = dic[@"geo"];
        if ([[NSNull null] isEqual:geoDic] != YES)
        {
            if ([geoDic.allKeys containsObject:@"coordinates"])
            {
                NSArray* coorinates = geoDic[@"coordinates"];
                if (coorinates.count == 2)
                {
                    tweet.latitude = [[coorinates objectAtIndex:0] floatValue];
                    tweet.longitude = [[coorinates objectAtIndex:1] floatValue];
                    
                    
                    
                    
//                    TODO:[住所取得]
                   
                    CLLocation* location =[[CLLocation alloc] initWithLatitude:tweet.latitude longitude:tweet.longitude];
                    CLGeocoder* clg = [[CLGeocoder alloc] init];
                    
                    
                    
                    [clg reverseGeocodeLocation:(CLLocation *)location
                                 completionHandler:^(NSArray* placemarks, NSError* error)
                                {
                                    for (CLPlacemark *placemark in placemarks) {
                                        // それぞれの結果（場所）の情報
                                        DLog(@"addressDictionary : %@", [placemark.addressDictionary description]);
                                        
                                        
                                        tweet.address = [NSMutableString stringWithFormat:@""];
//                                        [tweet.address appendString:placemark.country];
                                        [tweet.address appendString:placemark.locality];
                                        [tweet.address appendString:placemark.thoroughfare];
                                        [tweet.address appendString:placemark.subThoroughfare];
                                        
//                                        DLog(@"country         : %@", placemark.country);
                                        DLog(@"locality        : %@", placemark.locality);
                                        DLog(@"thoroughfare : %@", placemark.thoroughfare);
                                        DLog(@"subThoroughfare : %@", placemark.subThoroughfare);
                                 
                                        
                                        DLog("\n\tAddress: %@",tweet.address);

                                    }
                    }];
                    
                }
                
            }
            
        }
    }
    
    return tweet;
}

#pragma mark - Accessor


@end
