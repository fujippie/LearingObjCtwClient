//
//  MainViewController.m
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/09.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import "MainViewController.h"
#import "CustomTVC.h"

@interface MainViewController  ()

@property (nonatomic, strong) NSMutableArray* sampleData;
@property (nonatomic, assign) CGRect  defaultCellBodyFrame;
@property (nonatomic, assign) CGRect  defaultCellFrame;
@property (nonatomic, strong) UIRefreshControl* refreshControl;

@end

@implementation MainViewController

#pragma mark - Consts

static NSString* const _cellId = @"CustomTVC";

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(CustomTVC.class) bundle:nil]
         forCellReuseIdentifier:_cellId];
    
    self.defaultCellBodyFrame = [[[self.tableView dequeueReusableCellWithIdentifier:_cellId] body] frame];
    self.defaultCellFrame = [[self.tableView dequeueReusableCellWithIdentifier:_cellId] frame];
    
    [self.tableView addSubview:self.refreshControl];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Delegate

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.sampleData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    CustomTVC* cell = [tableView dequeueReusableCellWithIdentifier:_cellId];
    
    cell.body.text = [NSString stringWithFormat:@"%@", self.sampleData[indexPath.row]];
//    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.sampleData[indexPath.row]];
    cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    cell.textLabel.numberOfLines = 0;
    
    cell.body.frame = CGRectMake(
                                 cell.body.frame.origin.x,
                                 cell.body.frame.origin.y,
                                 cell.body.frame.size.width,
                                 cell.frame.size.height
                                 );
    [cell.body sizeToFit];
    
    /*
    DLog(
         @"%d"
         @"\n\tcell.body.text      :%@"
         @"\n\tcell.frame          :%@"
         @"\n\tcell.body.frame     :%@"
         @"\n\tdefaultCellBodyFrame:%@"
         , indexPath.row
         , cell.body.text
         , NSStringFromCGRect(cell.frame)
         , NSStringFromCGRect(cell.body.frame)
         , NSStringFromCGRect(self.defaultCellBodyFrame)
         );
     */
    
    return cell;
}

#pragma mark UITableViewDelegate

-(CGFloat)    tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* body = self.sampleData[indexPath.row];
    UIFont*   font = ((CustomTVC*)[self.tableView dequeueReusableCellWithIdentifier:_cellId]).body.font;
    
    CGFloat cellBodyH = [body boundingRectWithSize:CGSizeMake(self.defaultCellBodyFrame.size.width, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                        attributes:@{NSFontAttributeName:font}
                                           context:nil
                         ].size.height;
    CGFloat cellH = self.defaultCellFrame.size.height + (cellBodyH - self.defaultCellBodyFrame.size.height);
    /*
    DLog(
         @"\n\tbody                :%@"
         @"\n\tdefaultCellFrame    :%@"
         @"\n\tdefaultCellBodyFrame:%@"
         @"\n\tcellBodyH           :%f"
         @"\n\tcellH               :%f"
         , body
         , NSStringFromCGRect(self.defaultCellFrame)
         , NSStringFromCGRect(self.defaultCellBodyFrame)
         , cellBodyH
         , cellH
         );
     */
    
    return cellH < self.defaultCellFrame.size.height ? self.defaultCellFrame.size.height : cellH;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark ScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    DLog(@"scrolling....\n\tpoint:%@", NSStringFromCGPoint(scrollView.contentOffset));
}

#pragma mark - Event

-(void) _refreshData:(UIRefreshControl *) refreshControl
{
    DLog(@"___REFRESH___");
    [self requestTweets:0];
    DLog(@"END___REFRESH___");
}

-(void) _refresh
{
    [self.tableView reloadData];
    if (self.refreshControl.refreshing == NO) {
        [self.refreshControl endRefreshing];
    }
}

- (void)requestTweets:(NSInteger)maxId
{
//    Twiitter
//    DLog(@"NSThred isMainThread:%@", [NSThread isMainThread] ? @"YES" : @"NO");

    ACAccountType* accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [self.accountStore
     requestAccessToAccountsWithType:accountType
     options:NULL
     completion:^void (BOOL granted, NSError* error)
     {
         // アカウント取得失敗時
         if (error) {
             DLog(@"error :%@", error);
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.refreshControl endRefreshing];
             });
             
             return;
         }
         
         // titterアカウント取得（複数あるかも。。）
         NSArray* accounts = [self.accountStore accountsWithAccountType:accountType];
         if (accounts.count == 0) {
             DLog(@"account 0");
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.refreshControl endRefreshing];
             });
             
             return;
         }
         
         // リクエストを出すAPIを指定
         NSURL* url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
//         [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
         // リクエストのパラメータを設定
         NSMutableDictionary* params = @{
//                                  @"screen_name" : [accounts.firstObject username],
                                  @"count"       : @(30).description,
                                  @"q"           : @"",
                                  @"geocode"     : @"34.701909,135.494977,1km"
                                  }.mutableCopy;
         // ロードモア時に使用
         if (maxId != 0) {
             [params setObject:@(maxId).description forKey:@"max_id"];
         }
         
         // リクエストを作成
         SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                 requestMethod:SLRequestMethodGET
                                                           URL:url
                                                    parameters:params];
         // 1つ目のアカウントを指定
         request.account = accounts.firstObject;
         
         // リクエストを投げる
         [request
          performRequestWithHandler:^ void
          (NSData* responseData,
           NSHTTPURLResponse* urlResponse,
           NSError* error)
          {
              dispatch_async(dispatch_get_main_queue(), ^{
                  [self.refreshControl endRefreshing];
              });

//              DLog(@"responsData\n%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
              // エラー処理
              if (error) {
                  DLog(@"urlResponse:%@, error:%@", urlResponse, error);
                  return;
              }
              
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
                      return;
                  }
                  
                  // データ取得成功時
                  if (jsonDic.count > 0) {
                      /*
                       NSDictionary* jsonDic;
                       jsonDic[@"apple"]
                       jsonDic objectForKey:@"apple"]
                       */
                      
                      // 見つかったツイート配列を格納
                      NSArray* twAr = [jsonDic objectForKey:@"statuses"];
                      
                      // 初期化
                      self.sampleData = @[].mutableCopy;
                      
                      // ツイート配列からテキストのみを抽出
                      for(int index = 0; index < [twAr count]; index++)
                      {
                          NSDictionary* status = [twAr objectAtIndex:index];
                          
                          [self.sampleData addObject:status[@"text"]];
                      }
                      
                      // メインスレッドで実行(GCD)
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [self _refresh];
                      });
                      
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
              }
              // 通信失敗時
              else {
                  DLog(@"request error:%@", urlResponse);
              }
          }];
     }];
    //
}

#pragma mark - Accessor

- (NSMutableArray *) sampleData
{
    if (_sampleData == nil) {
        NSBundle* bundle = [NSBundle mainBundle];
        NSString* path = [bundle pathForResource:@"sampleData" ofType:@"plist"];
        _sampleData = [NSMutableArray arrayWithContentsOfFile:path];
    }
    
    return  _sampleData;
}

-(ACAccountStore *)accountStore
{
    if(_accountStore == nil) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    
    return _accountStore;
}

-(UIRefreshControl *)refreshControl
{
    if (_refreshControl == nil) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self
                            action:@selector(_refreshData:)
                  forControlEvents:UIControlEventValueChanged];
    }
    
    return _refreshControl;
}

@end
