//
//  Link.h
//  OCOLO
//
//  Created by masashi_tamayama on 2014/08/12.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum LinkType : NSUInteger
{
    NonLink,
    MentionUserNameLink,
    HashTagLink,
    SymbolTagLink,
    UrlLink,
} LinkType;

@interface Link : NSObject

@property (nonatomic) NSURL*    url;
@property (nonatomic) NSString* text;
@property (nonatomic) NSRange   range;

@property (nonatomic) enum LinkType type;

+(NSArray*) parseLinksInText:(NSString*)text;

+(NSArray*) parseMentionUserNameLinksInText:(NSString*)text;
+(NSArray*) parseHashTagLinksInText:(NSString*)text;
+(NSArray*) parseSymbolTagLinksInText:(NSString*)text;
+(NSArray*) parseUrlLinksInText:(NSString*)text;

+(NSArray *)parseLinksInText:(NSString *)text
                    linkType:(enum LinkType)linkType;

+(NSArray *) regExps;

@end
