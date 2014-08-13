//
//  TwStatus.h
//  OCOLO
//
//  Created by masashi_tamayama on 2014/07/25.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import "Pin.h"

@interface TWStatus : Pin

// REST API
@property (nonatomic) NSString* userName;
@property (nonatomic) NSString* userProfileImageUrl;
@property (nonatomic) CLLocationCoordinate2D geoCoordinates;
@property (nonatomic) NSString* text;
@property (nonatomic) NSDate*   createdAt;


#pragma mark - Initialize

+ (TWStatus*) twStatusFromDic:(NSDictionary*)dic;

#pragma mark - Util

//
+ (NSDate*) dateFromTwitterDateFmtStr:(NSString*)dateStr;

/**
 
 @param dateStr "Fri Jul 18 03:49:07 +0000 2014" 形式のみ可
 */

+ (BOOL) is3HoursAgoTweetWithTwitterDateFormatStr:(NSString*)dateStr;

@property (nonatomic) BOOL is3HoursAgoTweet;


@end
