//
//  NSDate+String.m
//  OCOLO
//
//  Created by masashi_tamayama on 2014/07/29.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import "NSDate+String.h"

@implementation NSDate (String)

-(NSString*) stringWithDateFormat:(NSString*)fmtStr
{
    
    NSDateFormatter* dateFmt = [[NSDateFormatter alloc] init];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [dateFmt setLocale:[NSLocale systemLocale]];
    [dateFmt setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFmt setCalendar:calendar];
    [dateFmt setDateFormat:fmtStr];
    
    return [dateFmt stringFromDate:self];
}

- (NSString *)timeLineFormat
{
    NSTimeInterval timeDiff = [[NSDate date] timeIntervalSinceDate:self];
    int minutte = floor(timeDiff / 60);
    int hour    = floor(timeDiff / (60*60));
    int day     = floor(timeDiff / (60*60*24));
    int week    = floor(timeDiff / (60*60*24*7));
    int month   = floor(timeDiff / (60*60*24*7*4));
    int year    = floor(timeDiff / (60*60*24*7*4*12));
    
    if(minutte < 1) {
        return @"たった今";
    }
    else if(minutte < 60)
        return [NSString stringWithFormat:@"%d分前", minutte];
    else if(hour < 24)
        return [NSString stringWithFormat:@"%d時間前", hour];
    else if(day < 7)
        return [NSString stringWithFormat:@"%d日前", day];
    else if(week < 4)
        return [NSString stringWithFormat:@"%d週間前", week];
    else if(month < 12)
        return [NSString stringWithFormat:@"%dヶ月前", month];
    else
        return [NSString stringWithFormat:@"%d年前", year];
    
    return @"";
}

@end
