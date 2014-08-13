//
//  Pin.m
//  OCOLO
//
//  Created by masashi_tamayama on 2014/07/25.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import "Pin.h"
#import "PostData.h"

@implementation Pin

#pragma mark - Initialize

+(instancetype) pinFromCoordinate:(CLLocationCoordinate2D)coordinate;
{
    Pin* pin = [[Pin alloc] init];
    pin.coordinate = coordinate;
    
    return pin;
}

+(instancetype) pinFromPostData:(PostData *)postData
{
    Pin* pin = [[Pin alloc] init];
    
    pin.coordinate = [postData.coord getCoord];
    
    pin.imageUrlStr = postData.faceImageThumbURL;
    
    if (postData.faceImageThumbURL)
    {
        NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:postData.faceImageThumbURL]];
        pin.image = [UIImage imageWithData:imageData];
    }
    else
    {
        pin.image = [UIImage imageNamed:@"no_face_image"];
    }
    
    pin.body = postData.comment;
    
    pin.categoryIconId = [Pin faIconWithCategoryName:postData.category];
    
    pin.soundUrlStr = postData.soundUrlStr;
    
    return pin;
}


#pragma mark - Util

+(enum FAIcon) faIconWithCategoryName:(NSString*)categoryNm
{
    NSString*     plist          = [[NSBundle mainBundle] pathForResource:@"category" ofType:@"plist"];
    NSDictionary* dicPlist       = [NSDictionary dictionaryWithContentsOfFile:plist];
    NSDictionary* dictionaryIcon = [dicPlist objectForKey:@"dic_icon"];
    
    NSString* stringIcon = [dictionaryIcon objectForKey:categoryNm];
    if(stringIcon == nil)
    {
        stringIcon = @"fa-comments-o";
    }

    return [NSString fontAwesomeEnumForIconIdentifier:stringIcon];
}

- (UIImage *)imageFromText:(NSString *)text
                      font:(UIFont*)font
                  rectSize:(CGSize)rectSize
{
    // オフスクリーン描画のためのグラフィックスコンテキストを作る。
    if (UIGraphicsBeginImageContextWithOptions != NULL)
    {
        UIGraphicsBeginImageContextWithOptions(rectSize, NO, 0.0f);
    }
    else
    {
        UIGraphicsBeginImageContext(rectSize);
    }
    
    /* Shadowを付ける場合は追加でこの部分の処理を行う。
     CGContextRef ctx = UIGraphicsGetCurrentContext();
     CGContextSetShadowWithColor(ctx, CGSizeMake(1.0f, 1.0f), 5.0f, [[UIColor grayColor] CGColor]);
     */
    
    // 文字列の描画領域のサイズをあらかじめ算出しておく。
    CGSize textAreaSize
    = [text boundingRectWithSize:rectSize
                           options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{NSFontAttributeName:font}
                           context:nil].size;

    // パラグラフで文字の描画位置などを指定する
    NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode            = NSLineBreakByWordWrapping;
    style.alignment                = NSTextAlignmentCenter;
    
    // text の描画する際の設定(属性)を指定する
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName:[UIColor blackColor],
                                 NSFontAttributeName           :font,
                                 NSParagraphStyleAttributeName :style
                                 };

    // 描画対象領域の中央に文字列を描画する。
    [text drawInRect:CGRectMake((rectSize.width - textAreaSize.width)  * 0.5f,
                               (rectSize.height - textAreaSize.height) * 0.5f,
                               textAreaSize.width,
                               textAreaSize.height)
      withAttributes:attributes];
    
    // コンテキストから画像オブジェクトを作成する。
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end





