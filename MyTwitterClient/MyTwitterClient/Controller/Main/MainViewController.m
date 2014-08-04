//
//  MainViewController.m
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/09.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import "MainViewController.h"
//#import "CustomTVC.h"
#import "Tweet.h"
#import "TwitterAPI.h"
#import "PostViewController.h"
#import "AppDelegate.h"
#import "TableViewCell.h"
#import "CellManager.h"
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

//static NSString* const _cellId = @"CustomTVC";
static NSString* const _cellId = @"TableViewCell";
static NSString* const _cellId2 = @"ElectricalCell";
#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.isInitialized = NO;
    
//    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    if([self.navigationController isEqual:appDelegate.navigationController])=>YESを返す

//TableViewの追加と設定
//    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(CustomTVC.class) bundle:nil]
//         forCellReuseIdentifier:_cellId];
    UINib* uinib = [UINib nibWithNibName:@"TableViewCell"
                                  bundle:nil];
    [self.tableView registerNib:uinib
         forCellReuseIdentifier:_cellId];
    
    UINib* uinib2 = [UINib nibWithNibName:@"ElectricalCell"
                                  bundle:nil];
    
    [self.tableView registerNib:uinib2
         forCellReuseIdentifier:_cellId2];
    
//    UINib* uinib2 = [UINib nibWithNibName:@"ElectricalCell"
//                                   bundle:nil];
//    [self.tableView registerNib:uinib2
//         forCellReuseIdentifier:_cellId2];
//    
//
//TableViewのCellの登録と設定
//    id型のもので型が確定するものはその型にしておく
    
    TableViewCell* customTVC = [self.tableView dequeueReusableCellWithIdentifier:_cellId];
    //TODO:[位置情報のTextの高さを加算]
    self.defaultCellBodyFrame = customTVC.body.frame;
    self.defaultCellFrame = customTVC.frame;
    
    [self.tableView addSubview:self.refreshControl];

    
    
//  NavigationBarの設定　（更新中に表示するアイコン）
    self.title = [NSString stringWithFormat:@"%@:%d", NSStringFromClass(self.class), [self.navigationController.viewControllers indexOfObject:self]];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投稿" style:UIBarButtonItemStylePlain  target:self action:@selector(leftBarBtnPushed:)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"削除" style:UIBarButtonItemStylePlain  target:self action:@selector(rightBarBtnPushed:)];
    
//    編集ボタンを追加する.
    [self.editButtonItem setTitle:@"削除"];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

#pragma mark - SubFunction


#pragma mark - Delegate

#pragma mark  OcoloTableViewCellDelegate

-(void) tableViewCell:(TableViewCell *) ocoloCell
               buttonImage:(UIImageView *) image
{
//画像を他クラスへ送信するデリゲート
    DLog("ocoloTableViewCELL DELEGATE");
    
}


#pragma mark  PostViewControllerDelegate

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
    
//    [self.ai stopAnimating];
//    self.ai.hidden = YES;
    
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
    
//    [self.ai stopAnimating];
//    self.ai.hidden = YES;
    
    
    [self.refreshControl endRefreshing];
    
    [self.tableView reloadData];
}

#pragma mark UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 100;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    DLog("FOOOTER_IN_SECTION");
    
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44) ];
    view.backgroundColor = [UIColor clearColor];
    
    //    self.ai.center= CGPointMake(self.tableView.tableFooterView.frame.size.width/2,
    //                                 self.tableView.tableFooterView.frame.size.height/2);
    self.ai.center = view.center;
    
    [view addSubview:self.ai];
    
    if(self.isLoading == YES)
    {
        return view;
    }
    else
    {
        return [[UIView alloc] init];
    }
    
    return view;
}

//TableViewがReloadされたときに呼び出される.Tableの要素数を返す.
//新たにCellが表示される度に呼ばれる.
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.tweetData.count;
}

//IndexPathで指定した要素のCellを返す.
-(UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    
    Tweet* tweet = self.tweetData[indexPath.row];
    NSString * cellID = indexPath.row % 2 == 0 ? _cellId :_cellId2;
    //NSString * cellID = _cellId;
    
//    CELLでわける
    if([cellID isEqualToString:_cellId])
    {
        TableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        cell.delegate = self;
        // セルが作られた時,回り始める
        [cell.spotAi startAnimating];
        [cell.distanceAi startAnimating];
        [cell.postImageAi startAnimating];
        
        
        //  CELLにツイート(文字列)をセット
        //  http://d.hatena.ne.jp/KishikawaKatsumi/20130605/1370370925
        //    http://oropon.hatenablog.com/entry/20120408/p1
        // テクストにリンクをつける　＋リンクをタップしたときに検知
        NSMutableAttributedString *attributeStr =[[NSMutableAttributedString alloc] initWithString:tweet.body];
        //属性をセット
        [attributeStr addAttribute:NSBackgroundColorAttributeName
                             value:[UIColor colorWithRed:1. green:1. blue:.0 alpha:1.]
                             range:NSMakeRange(0, [attributeStr length])];
        [cell.body setAttributedText:attributeStr];
        //cell.body.text = [NSString stringWithFormat:@"%@",tweet.body];
        cell.body.lineBreakMode = NSLineBreakByCharWrapping;
        cell.body.numberOfLines = 0;
        //  Cell中のTextLabelを設定
        //Frameの左上を(origin)原点として,Bodyを配置
        //Bodyの高さがCellの高さに設定されている
        CGFloat cellH = [self _cellHFromText:cell.body.text];
        CGFloat bodyH = cellH - self.defaultCellBodyFrame.origin.y - cell.spot.frame.size.height - 30;
        DLog("cellForRowAtIndexPath");
        //    CustomTVC* cell = [tableView dequeueReusableCellWithIdentifier:_cellId];
        //  CELLにツイート(文字列)をセット
        //  http://d.hatena.ne.jp/KishikawaKatsumi/20130605/1370370925
        //    http://oropon.hatenablog.com/entry/20120408/p1
        // テクストにリンクをつける　＋リンクをタップしたときに検知
    
       
        //  Cell中のTextLabelを設定
        //Frameの左上を(origin)原点として,Bodyを配置
        //Bodyの高さがCellの高さに設定されている
        
        
        
        cell.body.frame = CGRectMake(
                                     cell.body.frame.origin.x,
                                     cell.body.frame.origin.y,
                                     cell.body.frame.size.width,
                                     bodyH
                                     );
        //位置情報のラベルの位置を設定
//        cell.spot.frame = CGRectMake(
//                                     cell.spot.frame.origin.x,
//                                     cell.body.frame.origin.y + cell.body.frame.size.height + 10,
//                                     cell.spot.frame.size.width,
//                                     cell.spot.frame.size.height
//                                     );
        if(tweet.address != nil)
        {
            [cell.spotAi stopAnimating];
            cell.spot.text = [NSString stringWithFormat:@"%@",tweet.address];
        }
        else
        {
            cell.spot.text = [NSString stringWithFormat:@" "];
        }
        //  CELLにアイコン(プロフィール)画像をセット
        if (tweet.profileImage)
        {
            cell.prfImage.image = tweet.profileImage;
        }
        else
        {
            cell.prfImage.image = [UIImage imageNamed:@"noImage"];
        }
        cell.prfImage.layer.cornerRadius  = cell.prfImage.frame.size.width/2;
        cell.prfImage.layer.masksToBounds = YES;
        
        //投稿された画像をセット
        if(tweet.profileImage != nil)
        {
            //TODO:[ツイッターから投稿画像を取得し,画像の有無を判定]
            //[cell.postedImage setImage:[UIImage imageNamed:@"noImage"] forState:0];
            [cell.postImageAi stopAnimating];
        
        }
        else
        {
            [cell.postedImage setImage:[UIImage imageNamed:@"noImage"] forState:0];
        }
        if(nil)
        {
            //TODO:[どのSNSか判定し,画像を選択]
        }
        else
        {
            cell.snsLogo.image = [UIImage imageNamed:@"noImage"];
        }
        //アカウント名をセット
        NSMutableString* head = @"@".mutableCopy;
        if([tweet.accountName length] != 0 )
        {
            [head appendString:tweet.accountName];
            cell.accountName.text = head;
        }
        //投稿時間をセット
        if([tweet.postTime length] != 0)
        {
            cell.postTime.text = tweet.postTime;
        }
        //現在地との距離
        if(tweet.distance > 0 ){
            //cell.spot.text=append
            [cell.distanceAi stopAnimating];
            NSString* meter = [NSString stringWithFormat:@"%d",tweet.distance];
            if([tweet.address length] != 0 ){
                cell.spot.text  = [NSString stringWithFormat:@"%@m %@", meter,tweet.address];
            }
        }
        //    tweet.accountName;
        DLog("acccount%@",tweet.accountName);
        //ボタン位置を設定
        return cell;
    }
    else if([cellID isEqualToString:_cellId2])
    {
        TableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        return cell;
    }
    else{
        DLog("ERROR NO CELL");
        return nil;
    }
    
}


//    
//    
//    
//    cell.body.frame = CGRectMake(
//                                 cell.body.frame.origin.x,
//                                 cell.body.frame.origin.y,
//                                 cell.body.frame.size.width,
//                                 bodyH
//                                 );
//
//    //位置情報のラベルの位置を設定
//    cell.spot.frame = CGRectMake(
//                                 cell.spot.frame.origin.x,
//                                 cell.body.frame.origin.y+cell.body.frame.size.height,
//                                 cell.spot.frame.size.width,
//                                 cell.spot.frame.size.height
//                                 );
//    if(tweet.address != nil)
//    {
//        cell.spot.text = [NSString stringWithFormat:@"%@",tweet.address];
//    }
//    else
//    {
//        cell.spot.text = [NSString stringWithFormat:@" "];
//    }
////  CELLにアイコン(プロフィール)画像をセット
//    if (tweet.profileImage)
//    {
//        cell.prfImage.image = tweet.profileImage;
//    }
//    else
//    {
//        cell.prfImage.image = [UIImage imageNamed:@"noImage"];
//    }
//    cell.prfImage.layer.cornerRadius  = cell.prfImage.frame.size.width/2;
//    cell.prfImage.layer.masksToBounds = YES;
//    
////投稿された画像をセット
//    if(nil)
//    {
////TODO:[ツイッターから投稿画像を取得し,画像の有無を判定]
//    }
//    else
//    {
//        [cell.postedImage setImage:[UIImage imageNamed:@"noImage"] forState:0];
//    }
//    
//    if(nil)
//    {
//        //TODO:[どのSNSか判定し,画像を選択]
//    }
//    else
//    {
//        cell.snsLogo.image = [UIImage imageNamed:@"noImage"];
//    }
//    
////アカウント名をセット
//    NSMutableString* head = @"@".mutableCopy;
//    if([tweet.accountName length] != 0 )
//    {
//        [head appendString:tweet.accountName];
//        cell.accountName.text = head;
//    }
////投稿時間をセット
//    if([tweet.postTime length] != 0)
//    {
//        cell.postTime.text = tweet.postTime;
//    }
////現在地との距離
//    if(tweet.distance > 0 ){
////       cell.spot.text=append
//        NSString* meter = [NSString stringWithFormat:@"%d",tweet.distance];
//        if([tweet.address length] == 0 ){
//            cell.spot.text  = [NSString stringWithFormat:@"%@m %@", meter,tweet.address];
//        }
//    }
//    
////    tweet.accountName;
//    DLog("acccount%@",tweet.accountName);
////ボタン位置を設定
//
//    return cell;


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

#pragma mark UITableViewDelegate

-(CGFloat)    tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//TableViewとそのIndexPathの高さ
    DLog("HeightForRow");
    Tweet* tweet   = self.tweetData[indexPath.row];
    NSString* body = tweet.body;
    return [self _cellHFromText:body];
}

-(CGFloat)_cellHFromText:(NSString*)text
{
    //Cell内の文字列のフォントを取得
//    UIFont*   font = ((CustomTVC*)[self.tableView dequeueReusableCellWithIdentifier:_cellId]).body.font;
    TableViewCell* ocCell= [self.tableView dequeueReusableCellWithIdentifier:_cellId];
    UIFont*   font = ocCell.body.font;
    DLog(@"font:%@", font);
    
//  Textに応じたBodyの高さを返す
    CGFloat cellBodyH = [text boundingRectWithSize:CGSizeMake(self.defaultCellBodyFrame.size.width, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin //| NSStringDrawingUsesFontLeading
                                        attributes:@{NSFontAttributeName:font}
                                           context:nil
                         ].size.height;
//    デフォルト　＋（増分）
    CGFloat cellH = self.defaultCellFrame.size.height
    + (cellBodyH - self.defaultCellBodyFrame.size.height  );
//    デフォルト　−　(減少分)
    CGFloat cellHm = self.defaultCellFrame.size.height
    - (self.defaultCellBodyFrame.size.height - cellBodyH);
//    デフォルトよりも高さが低い場合,Cellを縮める
    cellH = cellH < self.defaultCellFrame.size.height ? cellHm : cellH;
    //三項演算子構文↑↑
//    DLog("CELLH : %f", cellH);
    return cellH+ocCell.spot.frame.size.height;//cell.spotの高さを加算
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

#pragma mark UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    DLog(@"scrolling....\n\tpoint:%@", NSStringFromCGPoint(scrollView.contentOffset));
    CGSize  contentSize   = self.tableView.contentSize;
    CGPoint contentOffset = self.tableView.contentOffset;
    
    CGFloat remain = contentSize.height - contentOffset.y;
    
    if(remain < self.tableView.frame.size.height * 1 && self.isLoading == NO && self.isInitialized && self.tweetData.count
//       // FIXME : for debug
//       && self.tweetData.count < 100
       )
    {
        self.isLoading = YES;
        
        self.ai.hidden = NO;
        [self.ai startAnimating];
    
        Tweet* lastTweet = self.tweetData.lastObject;

        CLLocationCoordinate2D OsakaEki = CLLocationCoordinate2DMake(34.701909, 135.494977);
        
//        DLog(@"lastTweet.id:%llu", lastTweet.id);
//        DLog(@"self.twieetApi:%@", self.twitterApi);
        
        [self.twitterApi tweetsInNeighborWithCoordinate:OsakaEki
                                                 radius:1
                                                  count:30
                                                  maxId:lastTweet.id];
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
        for (NSIndexPath* indexPath in selectedCells)
        {
            [indexSet addIndex:indexPath.row];
        }
        
        [self.tweetData removeObjectsAtIndexes:indexSet];
        [self.tableView deleteRowsAtIndexPaths:selectedCells withRowAnimation:UITableViewRowAnimationFade];
        
        [self.tableView endUpdates];
    }
    else
    {
        [self.editButtonItem setTitle:@"確定"];
    }
    //複数選択を可能にするフラグ
    self.tableView.allowsMultipleSelectionDuringEditing = editing;
    
    [self.tableView setEditing:editing animated:animated];
}

#pragma mark - Event
- (IBAction)postedImage:(id)sender{
    DLog("");
}
-(void) _refreshData:(UIRefreshControl *) refreshControl
{
    DLog("REFRESH");
    
    if (self.isLoading)
    {
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
    if (self.refreshControl.refreshing == NO)
    {
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
        
        for (NSString* tmpSampleData in sampleData){
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

- (UIActivityIndicatorView*) ai
{
    if(_ai == nil)
    {
        _ai =[[UIActivityIndicatorView alloc] init];
        _ai.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _ai.hidesWhenStopped = YES; // ActivityIndicatorを残すときNo
    }
    
    return _ai;
}



@end
