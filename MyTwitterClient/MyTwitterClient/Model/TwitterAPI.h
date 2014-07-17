//
//  TwitterAPI.h
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/16.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

#import "Tweet.h"

@interface TwitterAPI : NSObject

/**
 近辺のTweet一覧を取得
 @param (CLLocationCoordinate2D) coordinate 緯度,経度
 @param (CGFloat) radius 半径
 @param  (NSInteger) count 取得する件数
 @param  (unsigned long long) maxTweetID 最後に取得したTweetID
 @return (NSArray*) Tweet型配列
 */
- (NSMutableArray*) tweetsInNeighborWithCoordinate:(CLLocationCoordinate2D)coordinate
                                     radius:(CGFloat)radius
                                      count:(NSInteger)count
                                      maxId:(unsigned long long)maxTweetID;

/**
 Tweetする
 @param (NSString*) body
 @param (CLLocationCoordinate2D) coordinate 緯度,経度
 @param (UIImage*) image
 */
- (BOOL) postTweetWithBody:(NSString*)body coordinate:(CLLocationCoordinate2D)coordinate image:(UIImage*)image;

/**
 Tweetの削除
 @param (unsigned long long) tweetId 削除するツイートID
 */
- (BOOL) deleteTweetWithTweetId:(unsigned long long)tweetId;

/**
 Tweetの編集
 @param
 */
@property(strong, nonatomic) ACAccountStore* accountStore;

@end
