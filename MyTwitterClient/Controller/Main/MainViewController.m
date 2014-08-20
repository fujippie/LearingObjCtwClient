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
#import "Instagram.h"

#import "TwitterAPI.h"
#import "PostViewController.h"
#import "AppDelegate.h"
#import "Link.h"

@interface MainViewController  ()
<UIAlertViewDelegate, SETextViewDelegate>

@property (nonatomic, strong) NSMutableArray*   tweetData;
@property (nonatomic, assign) CGRect            defaultCellBodyFrame;
@property (nonatomic, assign) CGRect            defaultCellFrame;
@property (nonatomic, strong) UIRefreshControl* refreshControl;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, strong) UIActivityIndicatorView* ai ;
@property (nonatomic, strong) PostViewController* postViewController;
@property (nonatomic, strong) TwitterAPI* twitterApi;
@property (nonatomic, assign) BOOL isInitialized;

@property (nonatomic, assign) CGFloat cellBodyChangedHeight;

@end

@implementation MainViewController
// TODO: synthesizeの意味を理解する。
//@synthesize isLoading;

#pragma mark - Consts

//static NSString* const _cellId = @"CustomTVC";
static NSString* const _cellId = @"BaseTableViewCell";
static NSString* const _cellId2 = @"PowerCell";

static NSString* const _instagram = @"instagram";
static NSString* const _googlePlus = @"googlePlus";
static NSString* const _facebook = @"facebook";
static NSString* const _ocolo = @"ocolo";
static NSString* const _twitter = @"twitter";

static const CGFloat FONT_SIZE = 13.0f;

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
    self.tableView.allowsSelection = NO;
    UINib* uinib = [UINib nibWithNibName:NSStringFromClass([BaseTableViewCell class])
                                  bundle:nil];
    [self.tableView registerNib:uinib
         forCellReuseIdentifier:_cellId];
    
    UINib* uinib2 = [UINib nibWithNibName:@"PowerCell"
                                  bundle:nil];
    
    [self.tableView registerNib:uinib2
         forCellReuseIdentifier:_cellId2];
    

//TableViewのCellの登録と設定
//id型のもので型が確定するものはその型にしておく
    
    BaseTableViewCell* customTVC = [self.tableView dequeueReusableCellWithIdentifier:_cellId];
    
    //TODO:[位置情報のTextの高さを加算]
    self.defaultCellBodyFrame = customTVC.body.frame;
    self.defaultCellFrame = customTVC.frame;
    
    [self.tableView addSubview:self.refreshControl];
  
//  NavigationBarの設定　（更新中に表示するアイコン）
    self.title = [NSString stringWithFormat:@"%@:%lu", NSStringFromClass(self.class), (unsigned long)[self.navigationController.viewControllers indexOfObject:self]];
    
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

#pragma mark  BaseTableViewCellDelegate

-(void) tableViewCell:(BaseTableViewCell *) ocoloCell
               postImageButtonTapped:(UIImageView *) image
{
//画像を他クラスへ送信するデリゲート
    DLog("BaseTableViewCELL DELEGATE%@",image.description);

}

-(void) tableViewCell:(BaseTableViewCell *)tableViewCell
           tappedLink:(NSString*)link
{
    DLog(@"Called In Main %@ ",link);
}

-(void) tableViewCell:(BaseTableViewCell *) tableViewCell
naviButtonTappedWithAddress:(NSString*)address
             latitude:(CGFloat) latitude
           longtitude:(CGFloat)longtitude
{
    DLog(@"CalledINMAIN%@,lati:%f,longti:%f",address,latitude,longtitude);

}

-(void) tableViewCell:(BaseTableViewCell *) tableViewCell
accountImageButtonTappedWith:(NSString*)accountName
{
    DLog(@"CalledinMAin%@",accountName);

}

-(void) tableViewCell:(BaseTableViewCell *) tableViewCell
          accountNameTapped:(NSString *)accountName
{
    DLog(@"CalledinMAin%@",accountName);

}

#pragma mark  PostViewControllerDelegate

-(void) postViewController:(PostViewController *)postViewController postedTweet:(Tweet*)tweet
{
    [self.tweetData insertObject:tweet atIndex:0];
//    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:0 inSection:0];//先頭に追加
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];//先頭に追加
    // インサート 指定したIndexPathの要素に対してだけデリゲートが呼ばれる
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark TwitterAPIDelegate

//TwitterAPI.mから,取得時に呼び出される.ツイート配列を引数とするデリゲートメソッド,
-(void)twitterAPI:(TwitterAPI *)twitterAPI tweetData:(NSArray *)tweetData
{
    DLog("TWETTERAPIDELEGATE:::%d",[tweetData count]);
    Tweet* tw=tweetData.firstObject;
    DLog(@"tw%@ %@",tw.attributedBody,tw.address);
    
    self.isLoading = NO;
    
    [self.ai stopAnimating];
    self.ai.hidden = YES;
    
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
    return 10;
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

//IndexPathで指定した要素のCellを返す.//テーブルの行を表示する必要が生じるたびに呼び出される
-(UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tweet* tweet         = self.tweetData[indexPath.row];
    Instagram* instagram = self.tweetData[indexPath.row];

    //NSString * cellID = _cellId;
    
    DLog("cellForRow%@",[self.tweetData[indexPath.row] simpleBody]);
    
//    CELLでわける
    DLog("TWEET TEXT%@",tweet.attributedBody);
    if(indexPath.row % 2 == 0)
    {
        return [self _makeTweetCellwith:tweet];
        
    }

    else if(indexPath.row % 2 == 1)
    {
        return [self _makeInstagramCellwith:instagram];
    }
//    else if(indexPath.row % 6 == 5)
//    {
//        return [self makeElCellwith:tweet];
//    }
    else
    {
        DLog("ERROR NO CELL");
        return nil;
    }
}

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
    Tweet* tweet   = self.tweetData[indexPath.row];
    NSAttributedString* body = tweet.attributedBody;
    BOOL isImageExist = ((int)indexPath.row % 2 == 0) ? NO : YES;
    
//    return (indexPath.row % 6 == 5 )?  self.defaultCellFrame.size.height:[self _cellHFromText:body];
    DLog("idpath:%d  imgEX%hhd",indexPath.row,isImageExist);
    return [self _cellHFromSnsBase:tweet];
}

-(CGFloat)_cellHFromSnsBase:(SnsBase*)snsBase
{
    //Cell内の文字列のフォントを取得
//    UIFont*   font = ((CustomTVC*)[self.tableView dequeueReusableCellWithIdentifier:_cellId]).body.font;
//TableViewCell* ocCell= [self.tableView dequeueReusableCellWithIdentifier:_cellId];
//    UIFont*   font = ocCell.tweetText.font;
//    UIFont* font = [UIFont systemFontOfSize:FONT_SIZE];
//    UIFont font = ocCell.tweetText.font;
//    DLog(@"font:%@", font);
    
//    CGFloat CellBodyWidth =
    //画像の有無で幅を変える
    CGFloat bodyWidth
    = (snsBase.postImageURL)
    ? [BaseTableViewCell defaultHeightIsPostImage:YES]
    : [BaseTableViewCell defaultHeightIsPostImage:NO];
    
    CGRect frameRect = [SETextView frameRectWithAttributtedString:snsBase.attributedBody
                                                   constraintSize:CGSizeMake(bodyWidth, CGFLOAT_MAX)
                                                      lineSpacing:0.0f
                                                             font:[UIFont systemFontOfSize:FONT_SIZE]];
    
    CGFloat cellBodyH = frameRect.size.height;
    self.cellBodyChangedHeight = cellBodyH;
//    DLog(@"\n\n\nATTTRIBUTETEXT%@", atrText.string);
//
//    DLog(@"CELLBODYH>>>>>:%f", cellBodyH);
//    
//    DLog(@"CELLdefoBODYH>>>>>:%f", self.defaultCellBodyFrame.size.height);
//
    
//    デフォルト　＋（増分）
    CGFloat cellH
    = self.defaultCellFrame.size.height
    + (cellBodyH - self.defaultCellBodyFrame.size.height);
//    デフォルト　-（減分）
//    CGFloat cellHm  = self.defaultCellFrame.size.height
//    - (self.defaultCellBodyFrame.size.height - cellBodyH );
    
//    デフォルトよりも高さが低い場合,Cellを縮める
//    cellH = cellH < self.defaultCellFrame.size.height ? cellHm : cellH;
    
 
    cellH = cellH < self.defaultCellFrame.size.height ? self.defaultCellFrame.size.height : cellH;
    
    //三項演算子構文↑↑
//    DLog("CELLH : %f", cellH);
    
//    DLog("Default\n\tBODY:%f FRAME:%f",self.defaultCellBodyFrame.size.height,self.defaultCellFrame.size.height);
    
//    DLog("\n\tCell H         %f", cellH);
//    DLog("\n\tCell BodyH     %f", cellBodyH);
//    DLog("\n\tCell BodyDefoH %f", self.defaultCellBodyFrame.size.height);
//    DLog("\n\tCell FrameDefoH %f", self.defaultCellFrame.size.height);
////    DLog("\n\tReturned:%f",cellH+ocCell.spot.frame.size.height);
    
    return cellH;//+ocCell.spot.frame.size.height;//cell.spotの高さを加算
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

#pragma mark Create cell

-(BaseTableViewCell *) _makeElCellwith:(Tweet*) tweet
{
    BaseTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:_cellId2];
    //    DLog(@"classNm: %@", NSStringFromClass(((NSObject*)cell).class));
    
    //    cell.body.lineBreakMode = NSLineBreakByCharWrapping;
    //    cell.body.numberOfLines = 0;
    
    [cell.spotAi startAnimating];
    
    //  Cell中のTextLabelを設定
    //Frameの左上を(origin)原点として,Bodyを配置
    //Bodyの高さがCellの高さに設定されている
    
    cell.body.text = @"＿＿店名等＿＿";
    
    DLog("Address:%d Distance:%d", [tweet.address length],tweet.distance);
    
    if(([tweet.address length] > 0) && (tweet.distance > 0))
    {
        [cell.spotAi stopAnimating];
        NSString* meter = [NSString stringWithFormat:@"%d", tweet.distance];
        cell.spot.text  = [NSString stringWithFormat:@"%@m %@", meter, tweet.address];
    }
    else
    {
        cell.spot.text = [NSString stringWithFormat:@" "];
    }

    return cell;
}

-(BaseTableViewCell *) _makeTweetCellwith:(Tweet*)tweet
{
    BaseTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:_cellId];
    
    cell.delegate = self;
    
//   cellクラス内のメソッドでデータをセット
    cell.pin = tweet;
//ツイート内容を表示するテキストラベルの大きさを設定
    CGFloat imageWidth = cell.postedImageButton.frame.size.width;
    //    instagram.postImage.size.width;
    
    CGFloat cellH = [self _cellHFromSnsBase:tweet];
//    CGFloat bodyH = cellH - cell.prfImage.frame.size.height - cell.spot.frame.size.height -50;
    
//    DLog("\n\t CellH:%f bodyH:%f", cellH, self.cellBodyChangedHeight);
    CGFloat incrementWidth = 0.0;
    if(cell.postedImageButton.hidden)
    {
        incrementWidth = cell.postedImageButton.frame.size.width;
        DLog("tweetImage  incrementWidth%f",incrementWidth);
    }
    DLog("after ifincrementWidth%f",incrementWidth);
    cell.body.frame = CGRectMake(
                                 cell.body.frame.origin.x,
                                 cell.body.frame.origin.y,
                                 cell.body.frame.size.width + incrementWidth,
                                 self.cellBodyChangedHeight//bodyH
                                 );
    return cell;
}

-(BaseTableViewCell *) _makeInstagramCellwith:(Instagram*)instagram
{
    //    DLog("MAKE INSTAGRAMECELLLL");//celled
    BaseTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:_cellId];
    cell.delegate = self;
    
    //   cellクラス内のメソッドでデータをセット
    cell.pin = instagram;
    
    //ツイート内容を表示するテキストラベルの大きさを設定
    CGFloat imageWidth = cell.postedImageButton.frame.size.width;
    //    instagram.postImage.size.width;
    DLog("instaImageWidth%f", imageWidth);
    CGFloat cellH = [self _cellHFromSnsBase:instagram];
    
    
    CGFloat bodyH = cellH - cell.prfImage.frame.size.height - cell.spot.frame.size.height - 50;
    //    DLog("\n\t CellH:%f bodyH:%f", cellH, bodyH);cscscs
    cell.body.frame = CGRectMake(
                                 cell.body.frame.origin.x,
                                 cell.body.frame.origin.y,
                                 self.defaultCellBodyFrame.size.width,
                                 self.cellBodyChangedHeight
                                 );
    return cell;
}

-(NSString*) _meterToKilo:(NSInteger) meter
{
    if(meter > 1000)
    {
        return [NSString stringWithFormat:@"%dKm", meter / 1000];
    }
    else
    {
        return [NSString stringWithFormat:@"%dm", meter];
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
        DLog("%@", selectedCells);
        DLog("SelectedCount%d", selectedCells.count);
        
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

- (IBAction)postedImage:(id)sender
{
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
    
    //初期では,
    if(_tweetData == nil)
    {
        _tweetData = @[].mutableCopy;

        NSBundle* bundle = [NSBundle mainBundle];
        NSString* path = [bundle pathForResource:@"sampleData" ofType:@"plist"];
        NSArray*  sampleData = [NSMutableArray arrayWithContentsOfFile:path];
        
        for (NSString* tmpSampleData in sampleData){
           Tweet* tweet =[[Tweet alloc] init];
            tweet.simpleBody = tmpSampleData;
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
-(CGFloat) cellBodyChangedHeight
{
    if(_cellBodyChangedHeight == 0){
        _cellBodyChangedHeight = 10;
    }
    return _cellBodyChangedHeight;
}



@end
