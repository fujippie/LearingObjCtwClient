//
//  LinkHelper.m
//  OCOLO
//
//  Created by masashi_tamayama on 2014/08/12.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import "LinkHelper.h"

#import "SECompatibility.h"
#import "Link.h"

@interface LinkHelper ()

@property (nonatomic) NSCache *attributedStringCache;

@end

@implementation LinkHelper

#pragma mark - Convert

- (NSAttributedString *)attributedStringWithText:(NSString*)text
                                        fontSize:(CGFloat)fontSize
{
    //
    if (!text)
    {
        return [[NSAttributedString alloc] init];
    }
    //
    if ([self.attributedStringCache objectForKey:text])
    {
        return [self.attributedStringCache objectForKey:text];
    }
    
    NSArray* links = [Link parseLinksInText:text];
    
    NSFont* font = [NSFont systemFontOfSize:fontSize];
    CTFontRef tweetfont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    
    NSColor* tweetColor     = [NSColor blackColor];
    NSColor* hashTagColor   = [NSColor grayColor];
    NSColor* symbolTagColor = [NSColor grayColor];
    NSColor* linkColor      = [NSColor blueColor];
    
    NSDictionary *attributes = @{
                                 (id)kCTForegroundColorAttributeName: (id)tweetColor.CGColor,
                                 (id)kCTFontAttributeName           : (__bridge id)tweetfont
                                 };
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text
                                                                                         attributes:attributes];
    CFRelease(tweetfont);
    
    for (Link* link in links)
    {
        CGColorRef cgColor = nil;
        switch (link.type)
        {
            case MentionUserNameLink:
            {
                cgColor = linkColor.CGColor;
                break;
            }
            case HashTagLink:
            {
                cgColor = hashTagColor.CGColor;
                break;
            }
            case SymbolTagLink:
            {
                cgColor = symbolTagColor.CGColor;
                break;
            }
            case UrlLink:
            {
                cgColor = linkColor.CGColor;
                break;
            }
                
            default:
                break;
        }
        
        if (cgColor)
        {
            [attributedString addAttributes:@{
                                              NSLinkAttributeName                : link.text,
                                              (id)kCTForegroundColorAttributeName: (__bridge id)cgColor
                                              }
                                      range:link.range];
        }
    }
    
    NSDictionary *refs = @{
                           @"&amp;" :@"&",
                           @"&lt;"  :@"<",
                           @"&gt;"  :@">",
                           @"&quot;":@"\"",
                           @"&apos;":@"'"
                           };
    for (NSString *key in refs.allKeys.reverseObjectEnumerator) {
        NSRange range = [attributedString.string rangeOfString:key];
        while (range.location != NSNotFound) {
            [attributedString replaceCharactersInRange:range withString:refs[key]];
            range = [attributedString.string rangeOfString:key];
        }
    }
    
    [_attributedStringCache setObject:attributedString forKey:text];
    
    return attributedString;
}

#pragma mark - Accessor

#pragma mark private

-(NSCache *)attributedStringCache
{
    if (_attributedStringCache)
    {
        _attributedStringCache = [[NSCache alloc] init];
    }
    
    return _attributedStringCache;
}

@end
