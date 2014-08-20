//
//  Instagrum.h
//  OCOLO
//
//  Created by masashi_tamayama on 2014/07/29.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import "Pin.h"

@class InstagramMedia;

@interface IGMedia : Pin

// REST API
@property (nonatomic) NSString* userName;
@property (nonatomic) NSString* userProfilePicture;
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic) NSString* captionText;
@property (nonatomic) NSDate*   createdTime;
@property (nonatomic) NSString* imageStandardResolution; // 投稿画像URL


#pragma mark - Initialize

+ (IGMedia*) igMediaFromInstagramMedia:(InstagramMedia*)instagramMedia;



@end
