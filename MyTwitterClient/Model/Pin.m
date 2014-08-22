//
//  Pin.m
//  OCOLO
//
//  Created by masashi_tamayama on 2014/07/25.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import "Pin.h"

#import "LinkHelper.h"

@interface Pin ()

@property (nonatomic) NSArray* prefectures;

@end

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

-(void)addressToSynchronously:(void (^)(NSString *))addressBlock
{
    if (self.address && self.address.length)
    {
        addressBlock(self.address);
        
        return ;
    }
    
    if (!CLLocationCoordinate2DIsValid(self.coordinate))
    {
        self.address = @"―";
        addressBlock(self.address);
        return;
    }
    
    CLLocation* location = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    CLGeocoder* clg = [[CLGeocoder alloc] init];
    
    // ベンチマーク用
    __block NSDate* sDate = [NSDate date];
    
    [clg reverseGeocodeLocation:(CLLocation *)location
              completionHandler:^(NSArray* placemarks, NSError* error)
     {
         // ベンチマーク用
         NSDate* dDate = [NSDate date];
         DLOG(
            @"\n\t経過時間 : %.2f秒"
              ,[dDate timeIntervalSinceDate:sDate]
              );
         
         if (error)
         {
             DLOG(
                  @"\n\terror      : %@"
                  @"\n\tcoordinates: %@"
                  , error
                  , NSStringFromCLLocationCoordinate2D(self.coordinate)
                  );
             
             self.address = @"―";
             addressBlock(self.address);
             
             return ;
         }
         
//         DLog("MainThread:%hhd",[NSThread isMainThread]);//Main
         
         NSMutableString* address = [[NSMutableString alloc] initWithString:@""];
         for (CLPlacemark *placemark in placemarks)
         {
             /*
             LOG_COORD(self.coordinate);
             DLOG(
                  @"\n\ttweetId               :%@"
                  @"\n\tcount                 :%d"
                  @"\n\tindex                 :%d"
                  @"\n\tstate                 :%@"
                  @"\n\tname                  :%@"
                  @"\n\tthoroughfare          :%@"
                  @"\n\tsubThoroughfare       :%@"
                  @"\n\tlocality              :%@"
                  @"\n\tsubLocality           :%@"
                  @"\n\tadministrativeArea    :%@"
                  @"\n\tsubAdministrativeArea :%@"
                  @"\n\tpostalCode            :%@"
                  @"\n\tISOcountryCode        :%@"
                  @"\n\tcountry               :%@"
                  @"\n\tinlandWater           :%@"
                  @"\n\tocean                 :%@"
                  @"\n\tareasOfInterest       :%@"
                  , self.id
                  , placemarks.count
                  , [placemarks indexOfObject:placemark]
                  , placemark.addressDictionary[@"State"]
                  , placemark.name,
                  placemark.thoroughfare,
                  placemark.subThoroughfare,
                  placemark.locality,
                  placemark.subLocality,
                  placemark.administrativeArea,
                  placemark.subAdministrativeArea,
                  placemark.postalCode,
                  placemark.ISOcountryCode,
                  placemark.country,
                  placemark.inlandWater,
                  placemark.ocean,
                  placemark.areasOfInterest
                  );
              */

             // それぞれの結果（場所）の情報
             BOOL isStateNull    = ([placemark.administrativeArea length] == 0) ? YES : NO;
             BOOL isLocalNull    = ([placemark.locality length]           == 0) ? YES : NO;
             BOOL isThoroNull    = ([placemark.thoroughfare length]       == 0) ? YES : NO;
             BOOL isSubThoroNull = ([placemark.subThoroughfare length]    == 0) ? YES : NO;
             
             // 都道府県
             [address appendString:
              (isStateNull) ? @"" : placemark.administrativeArea];

             // 市区
             [address appendString:
              (isStateNull || isLocalNull) ? @"" : placemark.locality];
             
             // 町村丁目
             [address appendString:
              (isStateNull || isLocalNull || isThoroNull) ? @"" : placemark.thoroughfare];
             
             // 番地以下
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
         address = [address stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].mutableCopy;
         if (address.length == 0)
         {
             address = nil;
         }
         else
         {
             NSString* halfWhiteSpace = @" ";
             NSRange spaceRange;
             NSString* tmpAddress = [[NSString alloc] initWithString:address];
             while ((spaceRange = [tmpAddress rangeOfString:halfWhiteSpace options:NSWidthInsensitiveSearch]).location != NSNotFound)
             {
                 tmpAddress = [tmpAddress stringByReplacingOccurrencesOfString:halfWhiteSpace
                                                                    withString:@""
                                                                       options:NSWidthInsensitiveSearch
                                                                         range:spaceRange];
             }
             
             for (NSString* pref in self.prefectures)
             {
                 NSRange prefRange = [tmpAddress rangeOfString:pref options:NSWidthInsensitiveSearch];
                 if (prefRange.location != NSNotFound)
                 {
//                     DLOG(@"pref:%@ loc:%d address:%@", pref, prefRange.location, tmpAddress);
                     tmpAddress = [tmpAddress stringByReplacingOccurrencesOfString:pref
                                                                        withString:@""
                                                                           options:NSWidthInsensitiveSearch
                                                                             range:prefRange];
                     break;
                 }
             }
             
             address = tmpAddress.mutableCopy;
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

#pragma mark Private

-(NSArray *)prefectures
{
    static NSArray* prefs = nil;
    
    if (prefs == nil)
    {
        prefs
        = @[
            @"北海道", @"青森県", @"岩手県", @"宮城県", @"秋田県", @"山形県", @"福島県", @"茨城県", @"栃木県", @"群馬県", @"埼玉県", @"千葉県", @"東京都", @"神奈川県", @"新潟県", @"富山県", @"石川県", @"福井県", @"山梨県", @"長野県", @"岐阜県", @"静岡県", @"愛知県", @"三重県", @"滋賀県", @"京都府", @"大阪府", @"兵庫県", @"奈良県", @"和歌山県", @"鳥取県", @"島根県", @"岡山県", @"広島県", @"山口県", @"徳島県", @"香川県", @"愛媛県", @"高知県", @"福岡県", @"佐賀県", @"長崎県", @"熊本県", @"大分県", @"宮崎県", @"鹿児島県", @"沖縄県"
            ];
    }
    
    return prefs;
}

@end





