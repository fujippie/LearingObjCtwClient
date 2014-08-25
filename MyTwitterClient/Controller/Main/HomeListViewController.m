//
//  HomeListViewController.m
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/09.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import "HomeListViewController.h"

#import "TwitterAPI.h"
#import "TWStatus.h"
#import "IGMedia.h"

#import "PostViewController.h"
#import "AppDelegate.h"
#import "Link.h"

@interface HomeListViewController  ()
<CLLocationManagerDelegate, UIAlertViewDelegate, SETextViewDelegate>

@property (nonatomic, assign) BOOL isInitialized;
@property (nonatomic, assign) BOOL isLoading;

@property (nonatomic) CLLocationManager* locManager;
@property (nonatomic) CLLocationCoordinate2D currentCoord;

@property (nonatomic, strong) NSMutableArray* pins;

@property (nonatomic, assign) CGFloat defaultCellH;
@property (nonatomic, assign) CGFloat defaultCellBodyH;
@property (nonatomic, assign) CGFloat defaultToPlaceBtnY;
@property (nonatomic, assign) CGFloat defaultPostTimeLblY;

@property (nonatomic, strong) UIRefreshControl* refreshControl;
@property (nonatomic, strong) UIActivityIndicatorView* footerAi;

@property (nonatomic, strong) PostViewController* postViewController;
@property (nonatomic, strong) TwitterAPI* twitterApi;

@property (nonatomic, strong) UIView*                  shadeView;
@property (nonatomic, strong) UIActivityIndicatorView* shadeAi;

@end

@implementation HomeListViewController
// TODO: synthesizeの意味を理解する。
//@synthesize isLoading;

#pragma mark - Consts

static NSString* const _cellId = @"OCLTableViewCell";

static CGFloat   const _fontSize = 12.0f;

static CGFloat   const _footerPadding = 20.0f;

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.isInitialized = NO;
    
    _retryCount = 3;
    [self.locManager startUpdatingLocation];
    [self _onShade];
    
    //　TableViewの追加と設定
    self.tableView.allowsSelection = NO;
    UINib* uinib = [UINib nibWithNibName:NSStringFromClass([OCLTableViewCell class])
                                  bundle:nil];
    [self.tableView registerNib:uinib
         forCellReuseIdentifier:_cellId];
    
    // セルの高さ計算用にデフォルトサイズをストック
    OCLTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:_cellId];
    self.defaultCellH = cell.height;
    self.defaultCellBodyH = cell.bodyTv.height;
    self.defaultPostTimeLblY = cell.postTimeLbl.y;
    self.defaultToPlaceBtnY = cell.toPlaceBtn.y;
    
    [self.tableView addSubview:self.refreshControl];
  
    //  NavigationBarの設定　（更新中に表示するアイコン）
    self.title
    = [NSString stringWithFormat:@"%@:%d"
       , NSStringFromClass(self.class)
       , [self.navigationController.viewControllers indexOfObject:self]];
    
    /*
    // 投稿ボタン
    self.navigationItem.leftBarButtonItem
    = [[UIBarButtonItem alloc] initWithTitle:@"投稿"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(_leftBarBtnPushed:)];
    // 削除ボタン.
    [self.editButtonItem setTitle:@"削除"];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
     */
    
    // データのダウンロード
    [self.pins removeAllObjects];
    self.isLoading = YES;
    [self.twitterApi tweetsInNeighborWithCoordinate:self.currentCoord
                                             radius:1
                                              count:30
                                              maxId:0];
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

#pragma mark TwitterAPIDelegate

-(void)twitterAPI:(TwitterAPI *)twitterAPI
        tweetData:(NSArray *)tweetData
{
    self.isLoading = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.footerAi stopAnimating];
        self.footerAi.hidden = YES;
    });

    [self.refreshControl endRefreshing];
    
    [self.pins addObjectsFromArray:tweetData.mutableCopy];
    [self.tableView reloadData];
}

-(void)twitterAPI:(TwitterAPI *)twitterAPI
  errorAtLoadData:(NSError *)error
{
    [self.refreshControl endRefreshing];
    
    NSDictionary* dic = error.userInfo;
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

#pragma mark  OCLTableViewCellDelegate

-(void)        oclTableViewCell:(OCLTableViewCell *) tableViewCell
tappedProfileImageButtonWithPin:(Pin *)pin
{
    DLOG(
         @"\n\tprfImage"
         @"\n\tsize:%@"
         @"\n\turl :%@"
         @"\n\tisMainThread:%d"
         , NSStringFromCGSize(pin.image.size)
         , pin.imageUrlStr
         , [NSThread isMainThread]
         );
}

-(void)     oclTableViewCell:(OCLTableViewCell *)tableViewCell
tappedPostImageButtonWithPin:(Pin *)pin
{
    DLOG(
         @"\n\tprfImage"
         @"\n\tsize:%@"
         @"\n\turl :%@"
         @"\n\tisMainThread:%d"
         , NSStringFromCGSize(pin.postImage.size)
         , pin.postImageUrlStr
         , [NSThread isMainThread]
         );
}

-(void) oclTableViewCell:(OCLTableViewCell *)tableViewCell
              tappedLink:(Link *)link
{
    DLog(@"Called In Main : %@ ", link.description);
}

-(void)   oclTableViewCell:(OCLTableViewCell *) tableViewCell
tappedToPlaceButtonWithPin:(Pin *)pin
{
    DLog(@"CalledINMAIN : %@, lati:%f, longti:%f"
         , pin.address, pin.coordinate.latitude, pin.coordinate.longitude);
}

#pragma mark  PostViewControllerDelegate

-(void) postViewController:(PostViewController *)postViewController
               postedTweet:(TWStatus*)twStatus
{
    [self.pins insertObject:twStatus atIndex:0];
//    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:0 inSection:0];//先頭に追加
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];//先頭に追加
    // インサート 指定したIndexPathの要素に対してだけデリゲートが呼ばれる
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark UIAlertViewDelegate

- (void)   alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.isLoading = NO;
    
    [self.footerAi stopAnimating];
    self.footerAi.hidden = YES;
    
    [self.refreshControl endRefreshing];
    
    [self.tableView reloadData];
}

#pragma mark UITableViewDataSource

//TableViewがReloadされたときに呼び出される.Tableの要素数を返す.
//新たにCellが表示される度に呼ばれる.
- (NSInteger) tableView:(UITableView *)tableView
  numberOfRowsInSection:(NSInteger)section
{
    return self.pins.count;
}

//IndexPathで指定した要素のCellを返す.//テーブルの行を表示する必要が生じるたびに呼び出される
-(UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TWStatus* tweet = self.pins[indexPath.row];

    return [self _setupCellWithPin:tweet indexPath:indexPath];
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
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        DLog("DELETEButtonPushed");
        [self.pins removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark UITableViewDelegate

- (CGFloat)    tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section
{
    return self.footerAi.width + _footerPadding;
}

- (UIView *) tableView:(UITableView *)tableView
viewForFooterInSection:(NSInteger)section
{
    if (self.isLoading == NO && self.pins.count == 0)
    {
        return [[UIView alloc] init];
    }

    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                            0,
                                                            self.tableView.width,
                                                            self.footerAi.height + _footerPadding
                                                            )
                    ];
    view.backgroundColor = [UIColor clearColor];
    
    self.footerAi.center = view.center;
    
    [view addSubview:self.footerAi];
    
    return view;
}

-(CGFloat)    tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//TableViewとそのIndexPathの高さ
    TWStatus* twStatus = self.pins[indexPath.row];
    
    CGFloat cellH = [self _cellHFromPin:twStatus];
    
    return cellH;
}

//セルが選択されたときに呼び出される.
-(void)       tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGSize  contentSize   = self.tableView.contentSize;
    CGPoint contentOffset = self.tableView.contentOffset;
    
    CGFloat remain = contentSize.height - contentOffset.y;
    
    if(
       remain < self.tableView.frame.size.height * 1
       && self.isLoading == NO
       && self.isInitialized
       && self.pins.count
       )
    {
        self.isLoading = YES;
        
        self.footerAi.hidden = NO;
        [self.footerAi startAnimating];

        TWStatus* lastTwStatus = self.pins.lastObject;

        unsigned long long maxId = lastTwStatus.id ? strtoull([lastTwStatus.id UTF8String], NULL, 0) : 0;
        [self.twitterApi tweetsInNeighborWithCoordinate:self.currentCoord
                                                 radius:1
                                                  count:30
                                                  maxId:maxId
         ];
    }

}

#pragma mark CLLocationManagerDelegate

-(void) locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    [self _offShade];
}

NSInteger _retryCount = 3;

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error
{
    DLOG(@"locaiton error:\n%@", error);

    if (_retryCount != 0)
    {
        [UIAlertView showWithMessage:@"GPSが無効"];
        [NSThread sleepForTimeInterval:1];
        [manager startUpdatingLocation];
        _retryCount--;
    }
    else
    {
        [UIAlertView showWithMessage:@"GPSが無効"];
        
        [self _offShade];
    }
}

#pragma mark - Setup cell

-(CGFloat) _cellHFromPin:(Pin*)pin
{
    if (pin == nil || pin.body == nil || pin.body.length <= 0)
    {
        return self.defaultCellH;
    }
    
    OCLTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:_cellId];
    
    //画像の有無で幅を変える
    CGFloat bodyH = [SETextView frameRectWithAttributtedString:pin.attributeBody
                                                constraintSize:CGSizeMake(cell.bodyTv.width, CGFLOAT_MAX)
                                                   lineSpacing:0.0f
                                                          font:[UIFont systemFontOfSize:_fontSize]].size.height;
    CGFloat diffH = bodyH - self.defaultCellBodyH;
    
    CGFloat cellH = diffH <= 0.0f ? self.defaultCellH: self.defaultCellH + diffH;
    
    /*
     DLOG(
     @"\n\tdiffH           :%f"
     @"\n\tbodyH           :%f"
     @"\n\tdefaultCellBodyH:%f"
     @"\n\tcellH           :%f"
     , diffH
     , bodyH
     , self.defaultCellBodyH
     , cellH
     );
     */
    
    return cellH;
}

-(OCLTableViewCell *) _setupCellWithPin:(Pin*)pin
                               indexPath:(NSIndexPath *)indexPath
{
    OCLTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:_cellId];
    cell.delegate = self;

    [cell setPin:pin currentCoord:self.currentCoord];
    
    CGFloat diffH = [self _cellHFromPin:pin] - self.defaultCellH;
    if (diffH <= 0.0f)
    {
        diffH = 0;
    }

    cell.height = self.defaultCellH + diffH;
    cell.bodyTv.height = self.defaultCellBodyH + diffH;
    cell.postTimeLbl.y = self.defaultPostTimeLblY + diffH;
    cell.toPlaceBtn.y = self.defaultToPlaceBtnY + diffH;

    // ユーザーサムネイル、投稿画像
    [self _setImagesToCell:cell pin:pin indexPath:indexPath];
    
    // 住所
    cell.spotLbl.text  = @"取得中...";
    [pin addressToSynchronously:^(NSString *address)
     {
         if (address)
         {
             cell.spotLbl.text  = address;
         }
         else
         {
             cell.spotLbl.text = @"―";
         }
     }];


    return cell;
}

-(void) _setImagesToCell:(OCLTableViewCell*)cell
                     pin:(Pin*)pin
               indexPath:(NSIndexPath *)indexPath
{
    cell.prfImage = nil;
    cell.prfAi.hidden = NO;
    [cell.prfAi startAnimating];
    cell.postedImage = nil;
    cell.postImageAi.hidden = NO;
    [cell.postImageAi startAnimating];
    
    // プロフィール画像
    if (pin.image)
    {
        cell.prfImage = pin.image;
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.prfAi.hidden = YES;
        });
    }
    else if (pin.imageUrl)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL* url = [[NSURL alloc] initWithString:pin.imageUrlStr];
            NSData* imageData = [NSData dataWithContentsOfURL:url];
            UIImage* image = [UIImage imageWithData:imageData];

            dispatch_async(dispatch_get_main_queue(), ^{
                pin.image = image;
                
                OCLTableViewCell* tmpCell = (id)[self.tableView cellForRowAtIndexPath:indexPath];
                tmpCell.prfImage = pin.image;
                tmpCell.prfAi.hidden = YES;
            });
        });
    }
    else
    {
        cell.prfImage = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.prfAi.hidden = YES;
        });
    }
    
    // 投稿画像
    if (pin.postImage)
    {
        cell.postedImage = pin.postImage;
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.postImageAi.hidden = YES;
        });
    }
    else if (pin.postImageUrl)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
//            NSData* imageData = [NSData dataWithContentsOfURL:pin.postImageUrl];
            NSURL* url = [[NSURL alloc] initWithString:pin.postImageUrlStr];
            NSData* imageData = [NSData dataWithContentsOfURL:url];
            UIImage* image = [UIImage imageWithData:imageData];

            dispatch_async(dispatch_get_main_queue(), ^{
                pin.postImage = image;
                
                OCLTableViewCell* tmpCell = (id)[self.tableView cellForRowAtIndexPath:indexPath];
                tmpCell.postedImage = pin.postImage;
                tmpCell.postImageAi.hidden = YES;
            });
        });
    }
    else
    {
        cell.postedImage = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.postImageAi.hidden = YES;
        });
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
        
        [self.pins removeObjectsAtIndexes:indexSet];
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

#pragma mark - Action

#pragma mark IBAction

#pragma mark Event

-(void) _leftBarBtnPushed:(id)sender
{
    DLog("");
    
    [self presentViewController:self.postViewController animated:YES completion:nil];
}

-(void) _refreshData:(UIRefreshControl *) refreshControl
{
    DLog("REFRESH");
    
    if (self.isLoading)
    {
        return;
    }
    
    self.isLoading = YES;
    
    [self.pins removeAllObjects];
    [self.tableView reloadData];
    
    [self.twitterApi tweetsInNeighborWithCoordinate:self.locManager.location.coordinate
                                             radius:1
                                              count:30
                                              maxId:0];
}

-(void) _refresh
{
    [self.tableView reloadData];
    if (self.refreshControl.refreshing == NO)
    {
        [self.refreshControl endRefreshing];
    }
}

#pragma mark - Util

-(void) _onShade
{
    if (!self.shadeView.superview)
    {
        [self.view addSubview:self.shadeView];
    }

    self.shadeAi.hidden = NO;
    [self.shadeAi startAnimating];
}

-(void) _offShade
{
    [self.shadeView removeFromSuperview];
}

#pragma mark - Accessor

#pragma mark Private

-(PostViewController *) postViewController
{
    if(_postViewController == nil)
    {
        _postViewController = [[PostViewController alloc] init];
        _postViewController.delegate = self;
    }
    return _postViewController;
}

-(TwitterAPI *) twitterApi
{
    if (_twitterApi == nil)
    {
        _twitterApi = [[TwitterAPI alloc] init];
        //デリゲートを使う場合は必ず必要
        _twitterApi.delegate = self;
    }
    return _twitterApi;
}

- (NSMutableArray *) pins
{
    if (_pins == nil)
    {
        _pins = @[].mutableCopy;

        NSBundle* bundle     = [NSBundle mainBundle];
        NSString* path       = [bundle pathForResource:@"sampleData" ofType:@"plist"];
        NSArray*  sampleData = [NSMutableArray arrayWithContentsOfFile:path];
        
        for (NSString* tmpSampleData in sampleData)
        {
            TWStatus* twStatus = TWStatus.new;
            twStatus.body = tmpSampleData;
            [_pins addObject:twStatus];
        }
    }
    
    return _pins;
}

-(UIRefreshControl *) refreshControl
{
    if (_refreshControl == nil)
    {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self
                            action:@selector(_refreshData:)
                  forControlEvents:UIControlEventValueChanged];
    }
    
    return _refreshControl;
}

- (UIActivityIndicatorView*) footerAi
{
    if (_footerAi == nil)
    {
        _footerAi = [[UIActivityIndicatorView alloc] init];
        _footerAi.frame = CGRectMake(0, 0, 10, 10);
        _footerAi.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        _footerAi.color = [UIColor darkGrayColor];
        _footerAi.hidesWhenStopped = YES; // ActivityIndicatorを残すときNo
    }
    
    return _footerAi;
}

-(CLLocationCoordinate2D) currentCoord
{
    CLLocationCoordinate2D coord = self.locManager.location.coordinate;
    
    if (CLLocationCoordinate2DIsValid(coord))
    {
        return coord;
    }
    else
    {
        return kCLLocationCoordinate2DInvalid;
    }
}

-(CLLocationManager *) locManager
{
    if (_locManager == nil)
    {
        _locManager = [[CLLocationManager alloc] init];
        _locManager.delegate = self;
    }
    
    return _locManager;
}

-(UIView *)shadeView
{
    if (_shadeView == nil)
    {
        _shadeView = [[UIView alloc] initWithFrame:self.view.frame];
        _shadeView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.7];
        
        self.shadeAi = [[UIActivityIndicatorView alloc] initWithFrame:_shadeView.frame];
        self.shadeAi.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        self.shadeAi.hidesWhenStopped = YES;
        
        [_shadeView addSubview:self.shadeAi];
        [self.shadeAi startAnimating];
    }
    
    return _shadeView;
}

@end
