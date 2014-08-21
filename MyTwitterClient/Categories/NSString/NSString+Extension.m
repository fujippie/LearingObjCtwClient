//
//  NSString+Extension.m
//  OCOLO
//
//  Created by masashi_tamayama on 2014/08/06.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

-(NSString *)tailtruncateWithMaxLength:(NSInteger)maxLength
{
    if (self.length <= maxLength)
    {
        return self;
    }

    NSInteger sufixCount = 3;
    NSString* str = [self substringWithRange:(NSRange){0, maxLength - sufixCount}];
    str = [str stringByAppendingString:@"..."];
    
    return str;
}

-(NSString *) stringByStrippingHTML
{
    return [self stringByAppendingString:@""];
}

/**
 "dirty" solution
 Because, removes everything between < and >
 */
-(NSString *) stringByReplacingHTMLAtString:(NSString*)string
{
    NSRange r;
    NSString *s = [NSString stringWithString:self];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:string];
    return s;
}

+(NSString *)stringIsSummarizedFromMeter:(NSInteger)meter
{
    NSInteger kmMeter = meter / 1000;
    
    if(kmMeter < 1)
        return [NSString stringWithFormat:@"%dm", meter];
    else
        return [NSString stringWithFormat:@"%dkm", meter];
}

@end
