//
//  Tweet.m
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/15.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import "Tweet.h"

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

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                NSData* profileImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:tweet.profileImageUrl]];
                tweet.profileImage = [UIImage imageWithData:profileImageData];
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
                }
            }
        }
    }
    
    return tweet;
}

#pragma mark - Accessor


@end
