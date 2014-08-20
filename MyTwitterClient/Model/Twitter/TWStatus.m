//
//  TwStatus.m
//  OCOLO
//
//  Created by masashi_tamayama on 2014/07/25.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import "TWStatus.h"

@implementation TWStatus

#pragma mark - Initialize

+ (TWStatus*) twStatusFromDic:(NSDictionary*)dic
{
    if (dic.count <= 0) return nil;
    
    //
    TWStatus* twStatus = [[TWStatus alloc] init];
    
    twStatus.text = dic[@"text"];

    if (![dic[@"geo"] isEqual:[NSNull null]])
    {
        NSArray* coordinates = dic[@"geo"][@"coordinates"];
        double lat = [coordinates[0] doubleValue];
        double lon = [coordinates[1] doubleValue];
        twStatus.geoCoordinates = (CLLocationCoordinate2D){lat, lon};
    }
    
    if (![dic[@"user"][@"profile_image_url"] isEqual:[NSNull null]])
    {
        twStatus.userProfileImageUrl = dic[@"user"][@"profile_image_url"];
        /*
        if (twStatus.userProfileImageUrl)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:twStatus.userProfileImageUrl]];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    twStatus.image = [UIImage imageWithData:imageData];
                });
            });
        }
         */
    }
    
    if (![dic[@"user"][@"name"] isEqual:[NSNull null]])
    {
        twStatus.userName = dic[@"user"][@"name"];
    }
    
    twStatus.createdAt = [TWStatus dateFromTwitterDateFmtStr:dic[@"created_at"]];
    
    // 投稿画像
    NSArray* mediaArr = [dic valueForKeyPath:@"entities.media"];
    if (mediaArr && mediaArr.count)
    {
        NSDictionary* mediaDic = mediaArr[0];
        twStatus.mediaUrl = [twStatus assignValueFromDic:mediaDic key:@"media_url"];
        
        //
        if (twStatus.mediaUrl)
        {
            NSString* needle = [twStatus assignValueFromDic:mediaDic key:@"url"];
            if (needle)
            {
                twStatus.text = [twStatus.text stringByReplacingOccurrencesOfString:needle withString:@""];
                twStatus.text = [twStatus.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
        }
    }
    
    return twStatus;
}

#pragma mark - Util

+ (NSDate*) dateFromTwitterDateFmtStr:(NSString*)dateStr
{
    // "created_at" = "Fri Jul 18 03:49:07 +0000 2014";
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [df setLocale:locale];
    [df setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    NSDate *tweetDate = [df dateFromString:dateStr];
    
    return tweetDate;
}

+ (BOOL) is3HoursAgoTweetWithTwitterDateFormatStr:(NSString*)dateStr
{
    NSDate *tweetDate = [TWStatus dateFromTwitterDateFmtStr:dateStr];
    
    // 3時間前
    NSDate *threeHoursAgoDate = [NSDate dateWithTimeIntervalSinceNow:-3 * 60 * 60];
    
    NSComparisonResult compResult = [tweetDate compare:threeHoursAgoDate];
    
    return compResult != NSOrderedDescending ? NO : YES;
}


#pragma mark - Accessor

-(BOOL)is3HoursAgoTweet
{
    // 3時間前
    NSDate *threeHoursAgoDate = [NSDate dateWithTimeIntervalSinceNow:-3 * 60 * 60];
    
    NSComparisonResult compResult = [self.created compare:threeHoursAgoDate];
    
    return compResult != NSOrderedDescending ? NO : YES;
}

#pragma mark Override

- (enum FAIcon)categoryIconId
{
    return FATwitter;
}

-(NSString *)body
{
    return self.text;
}

-(NSString *)imageUrlStr
{
    return self.userProfileImageUrl;
}

-(NSString *)postImageUrlStr
{
    return self.mediaUrl;
}

-(CLLocationCoordinate2D)coordinate
{
    return self.geoCoordinates;
}

-(NSDate *)created
{
    return self.createdAt;
}

@end
