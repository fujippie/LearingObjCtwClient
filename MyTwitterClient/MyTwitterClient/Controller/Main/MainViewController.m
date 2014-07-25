//
//  MainViewController.m
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/09.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import "MainViewController.h"
#import "CustomTVC.h"
#import "Tweet.h"
#import "TwitterAPI.h"
#import "PostViewController.h"
#import "AppDelegate.h"


@interface MainViewController  ()
<UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray*   tweetData;
@property (nonatomic, assign) CGRect            defaultCellBodyFrame;
@property (nonatomic, assign) CGRect            defaultCellFrame;
@property (nonatomic, strong) UIRefreshControl* refreshControl;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, strong) UIActivityIndicatorView* ai ;
@property (nonatomic, strong) PostViewController* postViewController;
@property (nonatomic, strong) TwitterAPI* twitterApi;

@property (nonatomic, assign) BOOL isInitialized;

@end

@implementation MainViewController
// TODO: synthesizeの意味を理解する。
//@synthesize isLoading;


#pragma mark - Consts

static NSString* const _cellId = @"CustomTVC";

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.isInitialized = NO;
    
//    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    if([self.navigationController isEqual:appDelegate.navigationController])=>YESを返す

//TableViewの追加と設定
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(CustomTVC.class) bundle:nil]
         forCellReuseIdentifier:_cellId];
    
//TableViewのCellの登録と設定
//    id型のもので型が確定するものはその型にしておく
    CustomTVC* customTVC = [self.tableView dequeueReusableCellWithIdentifier:_cellId];
    self.defaultCellBodyFrame = customTVC.body.frame;
    self.defaultCellFrame = customTVC.frame;
    
    [self.tableView addSubview:self.refreshControl];

//  NavigationBarの設定　（更新中に表示するアイコン）
    self.title = [NSString stringWithFormat:@"%@:%d", NSStringFromClass(self.class), [self.navigationController.viewControllers indexOfObject:self]];
    
    //
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投稿" style:UIBarButtonItemStylePlain  target:self action:@selector(leftBarBtnPushed:)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"削除" style:UIBarButtonItemStylePlain  target:self action:@selector(rightBarBtnPushed:)];
    
//    編集ボタンを追加する.
    [self.editButtonItem setTitle:@"削除"];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
// 確認事項   [self.btn addTarget:self action:@selector(btnPushed) forControlEvents:UIControlEventTouchDown];
//    [self.tableView addSubview:self.btn];
    
    
    [self.view addSubview:self.ai];
    [self.view bringSubviewToFront:self.ai];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.isInitialized = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Delegate

#pragma mark  PostViewController

-(void) postViewController:(PostViewController *)postViewController postedTweet:(Tweet*)tweet
{
    [self.tweetData insertObject:tweet atIndex:0];
//    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:0 inSection:0];//先頭に追加
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];//先頭に追加
    // インサート 指定したIndexPathの要素に対してだけデリゲートが呼ばれる
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    // アップデート
//    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark TwitterAPIDelegate

//TwitterAPI.mから,取得時に呼び出される.ツイート配列を引数とするデリゲートメソッド,
-(void)twitterAPI:(TwitterAPI *)twitterAPI tweetData:(NSArray *)tweetData
{
//    DLog(@"tweetData:\n%@", tweetData);
    
    self.isLoading = NO;
    [self.ai stopAnimating];
    [self.refreshControl endRefreshing];
    
    [self.tweetData addObjectsFromArray:tweetData.mutableCopy];
    [self.tableView reloadData];
}

-(void)twitterAPI:(TwitterAPI *)twitterAPI errorAtLoadData:(NSError *)error
{
    [self.refreshControl endRefreshing];

    NSDictionary* dic = error.userInfo;
//    NSString* erSt = dic[@"NSLocalizedDescription"];
    DLog(@"\n___________error:\n%@", dic[@"NSLocalizedDescription"]);
    DLog("%@", error.domain);
    DLog("%d", error.code);
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"タイムアウト"
                                                        message:@"ツイート取得失敗"
                                                       delegate:self
                                              cancelButtonTitle:@"閉じる"
                                              otherButtonTitles:nil];
        [alert show];

    
}

#pragma mark UIAlertViewDelegate

- (void)   alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.isLoading = NO;
    [self.ai stopAnimating];
    [self.refreshControl endRefreshing];
}

#pragma mark UITableViewDataSource

//スワイプすると横にDeleteボタンが出るようにするメッソド
//セルが作られると呼ばれる
- (BOOL)    tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//編集モード時でDeleteかInsertされた時に呼び出される
-(void)  tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    editingStyleはUITableViewCellEditingStyleInsert,UITableViewCellEditingStyleDeleteのどちらかをとる
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        DLog("DELETEButtonPushed");
        [self.tweetData removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

//TableViewがReloadされたときに呼び出される.Tableの要素数を返す.
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.tweetData.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTVC* cell = [tableView dequeueReusableCellWithIdentifier:_cellId];
    
    Tweet* tweet = self.tweetData[indexPath.row];
//  CELLにツイート(文字列)をセット
    
    
    
    //

    
    
    cell.body.text = [NSString stringWithFormat:@"%@",tweet.body];
//    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.sampleData[indexPath.row]];
    
//    
//    cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
//    cell.textLabel.numberOfLines = 0;
    

    
    cell.body.lineBreakMode = NSLineBreakByCharWrapping;
    cell.body.numberOfLines = 0;
    
    
    
    
    cell.body.frame = CGRectMake(
                                 cell.body.frame.origin.x,
                                 cell.body.frame.origin.y,
                                 cell.body.frame.size.width,
                                 cell.frame.size.height
                                 );
//    DLog("\n\t1BodyHeight:%f",cell.body.frame.size.height);
    [cell.body sizeToFit];
//    DLog("\n\t2BodyHeight%f",cell.body.frame.size.height);
//  CELLにアイコン(プロフィール)画像をセット
//    [cell.prfImage setImage:Twitter型からImageを取得];
    if (tweet.profileImage)
    {
        cell.prfImage.image = tweet.profileImage;
    }
    else
    {
        cell.prfImage.image = [UIImage imageNamed:@"noImage"];
    }
    
    DLog("\n\t1BodyHeight:%f",cell.frame.size.height);
    
  
    cell.frame = CGRectMake(
                                 cell.body.frame.origin.x,
                                 cell.body.frame.origin.y,
                                 cell.body.frame.size.width,
                                 cell.body.frame.size.height
                                 );
    [cell sizeToFit];
    DLog("\n\t2BodyHeight%f",cell.frame.size.height);
    
    
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
    
    
//    [cell sizeToFit];
    return cell;
}



#pragma mark UITableViewDelegate

//
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    
//    return 50.0;
//}
//-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UIView* ui= [[UIView alloc] init];
//    ui.backgroundColor = [UIColor blackColor];
//    [ui addSubview:self.ai];
//    [ui center];
//    return ui;
//
//}


-(CGFloat)    tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Tweet* tweet = self.tweetData[indexPath.row];
    NSString* body = tweet.body;
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
//三項演算子構文↑↑
}

//セルが選択されたときに呼び出される.
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.editing)
    {
    }
    else
    {
//       編集モードでなければ,CELLの選択を外す.
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark ScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    DLog(@"scrolling....\n\tpoint:%@", NSStringFromCGPoint(scrollView.contentOffset));
    CGSize  contentSize   = self.tableView.contentSize;
    CGPoint contentOffset = self.tableView.contentOffset;
    
    CGFloat remain = contentSize.height - contentOffset.y;
    
    if(remain < self.tableView.frame.size.height * 1 && self.isLoading == NO && self.isInitialized && self.tweetData.count)
    {
        self.isLoading = YES;
        [self.ai startAnimating];
        Tweet* lastTweet = self.tweetData.lastObject;
        
        //[self _requestTweets:lastTweet.id];
//        TwitterAPI* tweetApi= [[TwitterAPI alloc] init];
        CLLocationCoordinate2D OsakaEki = CLLocationCoordinate2DMake(34.701909, 135.494977);
        
        DLog(@"lastTweet.id:%llu", lastTweet.id);
        DLog(@"self.twieetApi:%@", self.twitterApi);
        
        [self.twitterApi tweetsInNeighborWithCoordinate:OsakaEki radius:1 count:30 maxId:lastTweet.id];
    }

}

#pragma mark - Override

//編集モードにするEdit/Doneボタンを押したときに呼び出される
-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    //    DLog("SETEDIT");
    [super setEditing:editing animated:animated];
//  allowsMultipleSelec....が先に呼ばれると以下のIF文は複数選択のフラグが解除された状態で呼ばれる.
    if(editing == NO)
    {
        [self.editButtonItem setTitle:@"削除"];
        DLog("DONE Pushed");
        DLog("ここで一括削除処理を記述");
        NSArray* selectedCells = [self.tableView indexPathsForSelectedRows];
        DLog("%@",selectedCells);
        DLog("SelectedCount%d",selectedCells.count);
        
//配列をindex.path.row順にソート
        [self.tableView beginUpdates];
        
       
        NSMutableIndexSet* indexSet=[[NSMutableIndexSet alloc] init];
        for (NSIndexPath* indexPath in selectedCells) {
            [indexSet addIndex:indexPath.row];
        }
        
        [self.tweetData removeObjectsAtIndexes:indexSet];
        [self.tableView deleteRowsAtIndexPaths:selectedCells withRowAnimation:UITableViewRowAnimationFade];
        
        [self.tableView endUpdates];

    }
    else{
        [self.editButtonItem setTitle:@"確定"];
    }
    //複数選択を可能にするフラグ
    self.tableView.allowsMultipleSelectionDuringEditing = editing;
    
    [self.tableView setEditing:editing animated:animated];
}

#pragma mark - Event

-(void) _refreshData:(UIRefreshControl *) refreshControl
{
    DLog("REFRESH");
    
    if (self.isLoading) {
        return;
    }
    
    self.isLoading = YES;
    
    [self.tweetData removeAllObjects];
    [self.tableView reloadData];
    
    //[self _requestTweets:0];
    
    CLLocationCoordinate2D OsakaEki = CLLocationCoordinate2DMake(34.701909, 135.494977);
    
    [self.twitterApi tweetsInNeighborWithCoordinate:OsakaEki radius:10.0 count:30 maxId:0];

    // [self.tweetData addObjectsFromArray:tmpTWar];
}

-(void) _refresh
{
    [self.tableView reloadData];
    if (self.refreshControl.refreshing == NO) {
        [self.refreshControl endRefreshing];
    }
//    
//    for (Tweet* tweet in self.tweetData) {
//        printf("_REFRESH_CALLED_%d: %llu\n", [self.tweetData indexOfObject:tweet], tweet.id);// [[tweet.body substringToIndex:5] UTF8String]);
//    }
}

-(IBAction) rightBarBtnPushed:(id)sender
{
    DLog("\n編集モードに変更.");
    
    
}
-(IBAction)leftBarBtnPushed:(id)sender
{
    DLog("\n左上のボタンが押されました.");
    [self presentViewController:self.postViewController animated:YES completion:nil];
//    [postView helloPostDel];
    
}

#pragma mark - Accessor
-(PostViewController *) postViewController
{
    
    if(_postViewController == nil)
    {
        _postViewController = [[PostViewController alloc] init];
        _postViewController.delegate = self;
    }
    
    return _postViewController;
}

-(TwitterAPI *)twitterApi
{
    if(_twitterApi == nil)
    {
        _twitterApi = [[TwitterAPI alloc] init];
        //デリゲートを使う場合は必ず必要
        _twitterApi.delegate = self;
    }
    return _twitterApi;
}

- (NSMutableArray *) tweetData
{
    if(_tweetData == nil)
    {
        _tweetData = @[].mutableCopy;
        
        NSBundle* bundle = [NSBundle mainBundle];
        NSString* path = [bundle pathForResource:@"sampleData" ofType:@"plist"];
        NSArray* sampleData = [NSMutableArray arrayWithContentsOfFile:path];
        
        for (NSString* tmpSampleData in sampleData) {
            Tweet* tweet =[[Tweet alloc] init];
            tweet.body = tmpSampleData;
            [_tweetData addObject:tweet];
        }
    }
    
    return _tweetData;
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

-(UIActivityIndicatorView*) ai
{
//TODO:[位置の調整]
//    CGFloat h = self.view.frame.size.height;
//    CGFloat w = self.view.frame.size.width;
//    self.ai.frame = CGRectMake(w/2,h,0,30);

    if(_ai == nil){
        _ai =[[UIActivityIndicatorView alloc] init];
        _ai.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _ai.hidesWhenStopped = YES;//ActivityIndicatorを残すとき
        [_ai setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height+50)];
    }
    return _ai;
}

//-(BOOL)isLoading
//{
////更新中にUIActivityIndicatorViewのアニメーションをスタートさせる.
//    if(_isLoading == YES){
//        
//        //DLog("StartAi");
//        //[self.ai startAnimating];
//    }
//    else{
//        DLog("StopAi");
//        [self.ai stopAnimating];
//    }
//    return _isLoading;
//}


@end
