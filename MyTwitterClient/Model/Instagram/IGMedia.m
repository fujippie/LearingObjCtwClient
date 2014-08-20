//
//  Instagrum.m
//  OCOLO
//
//  Created by masashi_tamayama on 2014/07/29.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//
#import "IGMedia.h"
#import "InstagramMedia.h"

@implementation IGMedia

#pragma mark - Initialize

+ (IGMedia*) igMediaFromInstagramMedia:(InstagramMedia*)instagramMedia
{
    // 空チェック
    if (instagramMedia == nil || [instagramMedia isEqual:[NSNull null]]) return nil;
    
    // パース処理
    IGMedia* obj = [[IGMedia alloc] init];
    obj.captionText = instagramMedia.caption.text;
    obj.location = instagramMedia.location;
    obj.createdTime = instagramMedia.createdDate;
    obj.userProfilePicture = instagramMedia.user.profilePictureURL.absoluteString;
    /*
    if (obj.userProfilePicture)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:obj.userProfilePicture]];
            dispatch_sync(dispatch_get_main_queue(), ^{
                obj.image = [UIImage imageWithData:imageData];
            });
        });
    }
     */
    
    // 投稿画像
    obj.imageStandardResolution = instagramMedia.standardResolutionImageURL.absoluteString;
    /*
    if (obj.imageStandardResolution) {
        NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:obj.imageStandardResolution]];
        obj.postImage = [UIImage imageWithData:imageData];
    }
     */
    
    // 投稿ユーザー名
    obj.userName = instagramMedia.user.username;
    
    return obj;
}

#pragma mark - Accessor

#pragma mark Override

- (enum FAIcon)categoryIconId
{
    return FAInstagram;
}

-(NSString *)body
{
    return self.captionText;
}

-(NSString *)imageUrlStr
{
    return self.userProfilePicture;
}

-(NSString *)postImageUrlStr
{
    return self.imageStandardResolution;
}

-(CLLocationCoordinate2D)coordinate
{
    return self.location;
}

-(NSDate *)created
{
    return self.createdTime;
}

@end
