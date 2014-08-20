//
//  Link.m
//  OCOLO
//
//  Created by masashi_tamayama on 2014/08/12.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import "Link.h"

@interface Link ()

@end

@implementation Link

#pragma mark - Consts

/**
 ユーザー名の文字数制限
 https://support.twitter.com/articles/249172-
 */
static NSString* const _mentionUserNameRegExp =
@"(?<![0-9a-zA-Z'\"#@=:;])@([0-9a-zA-Z_]{1,15})";

static NSString* const _hashTagRegExp =
@"(^| |\\n|　)#(\\w*[一-龠ぁ-んァ-ヴー]+|[a-zA-Z0-9]+|[a-zA-Z0-9]\\w*)(\\n|　| |$)";

static NSString* const _symbolTagRegExp =
@"(^| |\\n|　)\\$(\\w*[一-龠ぁ-んァ-ヴー]+|[a-zA-Z0-9]+|[a-zA-Z0-9]\\w*)(\\n|　| |$)";

static NSString* const _urlRegExp =
@"https?://[\\w/:%#\\$&\?\(\\)~\\.=\\+\\-]+";

#pragma mark - Parse

+(NSArray *)parseLinksInText:(NSString *)text
{
    NSMutableArray* links = @[].mutableCopy;
    
    links = [links arrayByAddingObjectsFromArray:[Link parseMentionUserNameLinksInText:text]].mutableCopy;
    links = [links arrayByAddingObjectsFromArray:[Link parseHashTagLinksInText:text]].mutableCopy;
    links = [links arrayByAddingObjectsFromArray:[Link parseSymbolTagLinksInText:text]].mutableCopy;
    links = [links arrayByAddingObjectsFromArray:[Link parseUrlLinksInText:text]].mutableCopy;
    
    links = [links sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
    {
        Link* link1 = obj1;
        Link* link2 = obj2;
        
        if (link1.range.location < link2.range.location)
        {
            return NSOrderedAscending;
        }
        else if (link1.range.location > link2.range.location)
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedSame;
        }
    }].mutableCopy;
    
    /*
    TLog(
         @"\n\tlink"
         @"\n\ttext      :%@"
         , text
         );
    for (Link* link in links)
    {
        printf(
             "\n\tlink.text :%s"
             "\n\tlocation  :%d"
             , link.text.UTF8String
             , link.range.location
             );
    }
    printf("\n");
     */
    
    return links;
}

+(NSArray *)parseMentionUserNameLinksInText:(NSString *)text
{
    return [Link parseLinksInText:text linkType:MentionUserNameLink];
}

+(NSArray *)parseHashTagLinksInText:(NSString *)text
{
    return [Link parseLinksInText:text linkType:HashTagLink];
}

+(NSArray *)parseSymbolTagLinksInText:(NSString *)text
{
    return [Link parseLinksInText:text linkType:SymbolTagLink];
}

+(NSArray *)parseUrlLinksInText:(NSString *)text
{
    return [Link parseLinksInText:text linkType:UrlLink];
}

+(NSArray *)parseLinksInText:(NSString *)text
                    linkType:(enum LinkType)linkType
{
    if (linkType == NonLink)
    {
        return @[];
    }
    
    NSMutableArray* links = @[].mutableCopy;
    NSString* tmpText = [NSString stringWithString:text];
    
    NSStringCompareOptions options = NSCaseInsensitiveSearch | NSRegularExpressionSearch;
    
    NSString* regExp = [Link regExps][linkType];
    
    NSRange range = [tmpText rangeOfString:regExp options:options];
    NSInteger location = 0;
    
    while (range.location != NSNotFound)
    {
//        TLog(@"Match!\n\t%@", [tmpText substringWithRange:range]);
        
        // 始まり文字チェック
        if (
            [[tmpText substringWithRange:range] hasPrefix:@" "]
            || [[tmpText substringWithRange:range] hasPrefix:@"　"]
            || [[tmpText substringWithRange:range] hasPrefix:@"\\n"]
            )
        {
            range = (NSRange){range.location + 1, range.length - 1};
        }
        
        // 終わり文字チェック
        if (
            [[tmpText substringWithRange:range] hasSuffix:@" "]
            || [[tmpText substringWithRange:range] hasSuffix:@"　"]
            || [[tmpText substringWithRange:range] hasSuffix:@"\\n"]
            )
        {
            range = (NSRange){range.location, range.length - 1};
        }

        Link* link = Link.new;
        link.text = [tmpText substringWithRange:range];
        if (linkType == UrlLink)
        {
            link.url = [NSURL URLWithString:link.text];
        }
        link.range = (NSRange){location + range.location, range.length};
        link.type = linkType;
        
        [links addObject:link];
        
        location = location + range.location - 1 + range.length;
        tmpText = [tmpText substringFromIndex:range.location + range.length - 1];
        range = [tmpText rangeOfString:regExp options:options];
    }
    
    return links;
}

#pragma mark - Accessor

#pragma mark Private

+(NSArray *) regExps
{
    static NSArray* _regExps = nil;
    
    if (_regExps == nil)
    {
        _regExps = @[
                     @"",
                     _mentionUserNameRegExp,
                     _hashTagRegExp,
                     _symbolTagRegExp,
                     _urlRegExp
                     ];
    }
    
    return _regExps;
}

@end
