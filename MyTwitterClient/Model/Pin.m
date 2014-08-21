//
//  Pin.m
//  OCOLO
//
//  Created by masashi_tamayama on 2014/07/25.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import "Pin.h"

#import "LinkHelper.h"

@implementation Pin

#pragma mark - Initialize

+(instancetype) pinFromCoordinate:(CLLocationCoordinate2D)coordinate;
{
    Pin* pin = [[Pin alloc] init];
    pin.coordinate = coordinate;
    
    return pin;
}
/*
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
*/

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

-(NSInteger) distanceFromCurrentCoord:(CLLocationCoordinate2D)currentCoord
{
    if (CLLocationCoordinate2DIsValid(self.coordinate))
    {
        CLLocation* sLoc = [[CLLocation alloc] initWithLatitude:currentCoord.latitude
                                                      longitude:currentCoord.longitude];
        CLLocation* dLoc = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude
                                                      longitude:self.coordinate.longitude];
        // 距離を取得
        // TODO:[現在地は取得待ちする必要あり]
//        CLLocation* oosaka = [[ CLLocation alloc] initWithLatitude:34.701909 longitude:135.494977];
        
        CLLocationDistance distance = [sLoc distanceFromLocation:dLoc];

        return (NSInteger)distance;
    }
    
    return NSNotFound;
}

-(void)asyncAddress:(void (^)(NSString *))addressBlock
{
    if (self.address && self.address.length)
    {
        addressBlock(self.address);
        
        return ;
    }
    
    if (!CLLocationCoordinate2DIsValid(self.coordinate))
    {
        addressBlock(nil);
        return;
    }
    
    //(緯度，経度)　=> 住所
    CLLocation* location = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    
    //緯度経度から住所の情報を取得するところが非同期でメインスレッド
    //住所をTweet型に格納するところは非同期で別スレッド　Cellに反映されるまで、時間がかかる
    //
    //                    DLog("MainThread:%hhd",[NSThread isMainThread]);//Main
    CLGeocoder* clg = [[CLGeocoder alloc] init];
    [clg reverseGeocodeLocation:(CLLocation *)location
              completionHandler:^(NSArray* placemarks, NSError* error)
     {
         if (error)
         {
             DLOG(@"error:\n%@", error);
             
             self.address = nil;
             addressBlock(nil);
             
             return ;
         }
         
//         DLog("MainThread:%hhd",[NSThread isMainThread]);//Main
//         DLog(@"count:%d obj:%@", placemarks.count, placemarks[0]);
         
         NSMutableString* address = [NSMutableString stringWithString:@""];
         for (CLPlacemark *placemark in placemarks)
         {
             // それぞれの結果（場所）の情報
             BOOL isStateNull    = ([placemark.addressDictionary[@"State"] length] == 0) ? YES : NO;
             BOOL isLocalNull    = ([placemark.locality length] == 0)                    ? YES : NO;
             BOOL isThoroNull    = ([placemark.thoroughfare length] == 0)                ? YES : NO;
             BOOL isSubThoroNull = ([placemark.subThoroughfare length] == 0)             ? YES : NO;
             
//             DLog(@"\n\t%@\n",tweet.body);
//             DLog(@"locality        : %@ BOOL : %hhd", placemark.locality,isLocalNull);
//             DLog(@"state           : %@ BOOL : %hhd", placemark.addressDictionary[@"State"],isThoroNull);

             [address appendString:
              (isStateNull) ? @"" : placemark.addressDictionary[@"State"]];
             
//             DLog(@"thoroughfare    : %@ BOOL : %hhd", placemark.locality,isThoroNull);
             
             [address appendString:
              (isStateNull || isLocalNull) ? @"" : placemark.locality];
             
//             DLog(@"thoroughfare    : %@ BOOL : %hhd", placemark.thoroughfare,isThoroNull);
             
             [address appendString:
              (isStateNull || isLocalNull || isThoroNull) ? @"" : placemark.thoroughfare];
             
//             DLog(@"subThoroughfare : %@ BOOL : %hhd", placemark.subThoroughfare,isSubThoroNull);
             
             [address appendString:
              (isStateNull || isLocalNull || isThoroNull || isSubThoroNull) ? @"" : placemark.subThoroughfare];
         }

         /*
         DLog(
              "\n\tMainThread : %hhd"
              "\n\tAddress    : %@"
              , [NSThread isMainThread]
              , address
              );
          */

         if (address.length == 0)
         {
             address = nil;
         }

         self.address = address;
         addressBlock(address);
     }];
}

#pragma mark - Accessor

#pragma mark Public

-(NSAttributedString *) attributeBody
{
    if (_attributeBody == nil && self.body)
    {
        _attributeBody = [[LinkHelper sharedInstance] attributedStringWithText:self.body fontSize:12.0f];
    }
    
    return _attributeBody;
}

-(NSURL *)imageUrl
{
    if (_imageUrl == nil && self.imageUrlStr != nil && self.imageUrlStr.length)
    {
        _imageUrl = [NSURL URLWithString:self.imageUrlStr];
    }
    else
    {
        _imageUrl = nil;
    }
    
    return _imageUrl;
}

-(NSURL *) postImageUrl
{
    if (_postImageUrl == nil && self.postImageUrlStr != nil && self.postImageUrlStr.length)
    {
        _postImageUrl = [NSURL URLWithString:self.postImageUrlStr];
    }
    else
    {
        _postImageUrl = nil;
    }
    
    return _postImageUrl;
}

@end





