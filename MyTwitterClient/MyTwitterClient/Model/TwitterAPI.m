//
//  TwitterAPI.m
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/16.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import "TwitterAPI.h"

@interface TwitterAPI ()

@property(strong, nonatomic) ACAccountStore* accountStore;

@end

@implementation TwitterAPI

#pragma mark - API request

- (void) tweetsInNeighborWithCoordinate:(CLLocationCoordinate2D)coordinate
                                     radius:(NSInteger)radius
                                      count:(NSInteger)count
                                      maxId:(unsigned long long)maxTweetID
{
    DLog("start");

   // printf("RequestTweet_Called %ld ¥n",(long)maxTweetID);
    /*
    //TwitterAPI
//すでにロード中であればReturn
    if([self.delegate isLoading])
    {
        DLog("TW1");
        return tweetData;
        
    }
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(setIsLoading:)]
        && [self.delegate respondsToSelector:@selector(animateAi:)])
    {
        [self.delegate setIsLoading:YES];
        [self.delegate animateAi:YES];
        DLog("TW2");
    }
    */
    
    //    Twiitter
    //    DLog(@"NSThred isMainThread:%@", [NSThread isMainThread] ? @"YES" : @"NO");
//    DLog("TW3");//passed
    ACAccountType* accountType = [self.accountStore
                                  accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [self.accountStore
     requestAccessToAccountsWithType:accountType
     options:nil
     completion:^void (BOOL granted, NSError* error)
     {
         DLog(@"");
         
         // アカウント取得失敗時
         if (error) {
             DLog(@"error :%@", error);
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 /*
                 if(self.delegate
                    && [self.delegate respondsToSelector:@selector(endRefresh)]){
                     [self.delegate endRefresh];
                 }
                  */
                 if(
                    self.delegate
                    && [self.delegate respondsToSelector:@selector(twitterAPI:errorAtLoadData:)]
                    )
                 {
                     [self.delegate twitterAPI:self errorAtLoadData:error];
                 }
             });
              DLog(@"TW1.1");
             return ;
         }
         
         // titterアカウント取得（複数あるかも。。）
         NSArray* accounts = [self.accountStore accountsWithAccountType:accountType];
         if (accounts.count == 0)
         {
             DLog(@"account 0");
             
             dispatch_async(dispatch_get_main_queue(), ^
             {
                 /*
                 if(self.delegate
                    &&[self.delegate respondsToSelector:@selector(endRefresh)]){
                     [self.delegate endRefresh];
                 }
                  */
                 if(
                    self.delegate
                    && [self.delegate respondsToSelector:@selector(twitterAPI:errorAtLoadData:)]
                    )
                 {
                     [self.delegate twitterAPI:self errorAtLoadData:nil];
                 }

             });
             DLog(@"TW1.1");
             return ;
         }
         
         DLog("TW4");//DontPass
         
         // リクエストを出すAPIを指定
         NSURL* url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
         //         [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
         // リクエストのパラメータを設定
         NSMutableDictionary* params = @{
                                         //                                  @"screen_name" : [accounts.firstObject username],
                                         @"count"       : @(count).description,
                                         @"q"           : @"",
                                         @"geocode"     : @"34.701909,135.494977,1km"
                                         }.mutableCopy;
         // ロードモア時に使用
         if (maxTweetID != 0) {
             [params setObject:@(maxTweetID - 1).description forKey:@"max_id"];
         }
         
         // リクエストを作成
         SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                 requestMethod:SLRequestMethodGET
                                                           URL:url
                                                    parameters:params];
         // 1つ目のアカウントを指定
         request.account = accounts.firstObject;
         
         DLog("TW5");
         
         // リクエストを投げる
         [request
          performRequestWithHandler:^ void
          (NSData* responseData,
           NSHTTPURLResponse* urlResponse,
           NSError* error)
          {
//              [self.delegate setIsLoading:YES];
//              [self.delegate animateAi:YES];
//              dispatch_async(dispatch_get_main_queue(), ^{
//                  [self.delegate endRefresh];
//              });
              
              //              DLog(@"responsData\n%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
              
              // エラー処理
              if (error) {
//                  [self.delegate setIsLoading:NO];
//                  [self.delegate animateAi:NO];
                  DLog(@"urlResponse:%@, error:%@", urlResponse, error);
                  if(
                     self.delegate
                     && [self.delegate respondsToSelector:@selector(twitterAPI:errorAtLoadData:)]
                     )
                  {
                      [self.delegate twitterAPI:self errorAtLoadData:error];
                  }
                  return;
              }
              
              NSMutableArray* tweetData = @[].mutableCopy;

              // 通信成功時(200系)
              if (200 <= urlResponse.statusCode && urlResponse.statusCode < 300) {
                  DLog(@"通信成功時(200系)");
                  NSError* e = nil;
                  NSDictionary* jsonDic = [NSJSONSerialization
                                           JSONObjectWithData:responseData
                                           options:NSJSONReadingAllowFragments
                                           error:&e
                                           ];
                  // エラー処理
                  if (e) {
                      DLog(@"e:%@", e);
//                      [self.delegate setIsLoading:NO];
//                      [self.delegate animateAi:NO];
                      if(
                         self.delegate
                         && [self.delegate respondsToSelector:@selector(twitterAPI:errorAtLoadData:)]
                         )
                      {
                          [self.delegate twitterAPI:self errorAtLoadData:error];
                      }
                      return;
                  }
                  
                  // データ取得成功時
                  if (jsonDic.count > 0)
                  {
//                      [self.delegate setIsLoading:NO];
//                      [self.delegate animateAi:NO];
                      /*
                       NSDictionary* jsonDic;
                       jsonDic[@"apple"]
                       jsonDic objectForKey:@"apple"]
                       */
                      
                      // 見つかったツイート配列を格納
                      NSArray* twAr = jsonDic[@"statuses"];
                      DLog("\n\tJSON.count:%d", twAr.count);
                      // ツイート配列からテキストのみを抽出
                      //ツイート内容,緯度経度,IDを取得
                      
                      for(int index = 0; index < [twAr count]; index++)
                      {
                          DLog("TW6 index:%d", index);
                          
                          NSDictionary* status = [twAr objectAtIndex:index];
                          Tweet* tweet = [Tweet tweetWithDic:status];
                          
                          //  tweet.latitude
                          //                          DLog(@"body:%@",tweet.body);
                          //                          DLog(@"profileImageUrl:%@",tweet.profileImageUrl);
                          //                          DLog(@"lati %f , long%f",tweet.latitude,tweet.longitude);
                          
                          [tweetData addObject:tweet];
                      }
                      // メインスレッドで実行(NSThread)
                      //                      [self performSelectorOnMainThread:@selector(_refresh)
                      //                                             withObject:nil
                      //                                          waitUntilDone:NO];
                      
                      /*
                       Tweet
                       id
                       user.profile_image_url
                       text
                       geo.coordinates
                       */
                      
                      /*
                       34.683015999977,135.477230003533
                       34.683015999977,135.527178003877
                       34.7177310034282,135.527178003877
                       34.7177310034282,135.477230003533
                       */
                      //                      DLog(@"jsonArr:\n%@", jsonDic);
                  }
                  else {
                      DLog(@"json なし");
                  }
                  
                  // メインスレッドで実行(GCD)
                  dispatch_async(dispatch_get_main_queue(), ^{
//                          [self.delegate _refresh];
                      DLog(@"delegate:%@", self.delegate);
                      if(
                         self.delegate
                         && [self.delegate respondsToSelector:@selector(twitterAPI:tweetData:)]
                         )
                      {
                          DLog(@"");
                          [self.delegate twitterAPI:self tweetData:tweetData];
                      }
                      
                  });
              }
              // 通信失敗時
              else {
                  DLog(@"request error:%@", urlResponse);
//                  [self.delegate setIsLoading:NO];
//                  [self.delegate animateAi:NO];
                  
                  if(
                     self.delegate
                     && [self.delegate respondsToSelector:@selector(twitterAPI:errorAtLoadData:)]
                     )
                  {
                      [self.delegate twitterAPI:self errorAtLoadData:nil];
                  }
              }
              
//              [self.delegate setIsLoading:NO];
//              [self.delegate animateAi:NO];
          }];
     }];
    //
    DLog("TWLast");//passed
    
//    return tweetData;
    
}

- (BOOL) postTweetWithBody:(NSString*)body coordinate:(CLLocationCoordinate2D)coordinate image:(UIImage*)image{
    
    
    
    
    return NO;
}

- (BOOL) deleteTweetWithTweetId:(unsigned long long)tweetId
{
    return NO;
}


#pragma mark - Accessor

- (ACAccountStore *) accountStore
{
    if(_accountStore == nil) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    
    return _accountStore;
}


@end
