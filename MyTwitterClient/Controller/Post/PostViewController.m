//
//  PostViewController.m
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/16.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

//日本語ドキュメント
//https://developer.apple.com/jp/devcenter/ios/library/japanese.html
//Cocoaコーディングガイドライン，Objective-cプログラミング，Iosヒューマンインターフェースガイドライン


#import "PostViewController.h"
#import "TwitterAPI.h"

@interface PostViewController ()

@property (nonatomic, strong) TwitterAPI* twitterApi;
@property (nonatomic, strong) UIView* waitView;
@property (nonatomic, strong) UIActivityIndicatorView* waitAi;
@property (nonatomic, strong) IBOutlet UIButton* postButton;
@property (strong, nonatomic) IBOutlet UIImageView* uploadImageView;

@end

@implementation PostViewController


// TODO: 意味を調べる
//@synthesize postDelegate;

#pragma mark - Initialize
- (void) _initialize
{
    self.postButton.enabled = YES;
    
    self.postText.text = @"";
    
    self.uploadImageView.image = nil;
}

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];


    UITapGestureRecognizer* tapRcg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_imageTapped:)];
    [self.uploadImageView addGestureRecognizer:tapRcg];
    self.uploadImageView.userInteractionEnabled = YES;
    
}

- (void) viewWillAppear:(BOOL)animated
{
    //画面が表示される直前の処理
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

#pragma mark IBAction

- (IBAction) postBtn:(UIButton*)button
{
    if (self.postText.text.length <= 0)
    {
//テクストフィールドに文字列がないとき,アラートを表示
//アラートViewオブジェクトの生成
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                     message:@"ツイートするメッセージがありません"
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];//アラートビューの表示
        return;
    }
//ファーストレスポンダかどうか，
//PostTextをタップしたときキーボード（ユーザの入力）が立ち上がる．
//タップしてPostText以外を選択したときにキーボードを下げる．
    
    if ([self.postText isFirstResponder])
    {
//ファーストレスポンダでなくす
        [self.postText resignFirstResponder];
    }
    
    
    
//ボタンを無効化する
    [button setEnabled:NO];
    
    NSString* str = self.postText.text;
    
    // 画面上部の通信中エフェクト
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // 画面全体のUI操作を禁止する
    //    self.view.userInteractionEnabled = NO;//UI操作禁止を解除する　=YES;
//通信待ちの半透明の画面を被せる
    [self.view addSubview:self.waitView];
    [self.waitAi startAnimating];
  
    /*
     1.投稿ボタンを無効化。
     2.twitterAPIにて投稿。
     3.投稿内容を親のViewControllerへ渡し、セルを生成し、挿入。Delegate使用
     ref. http://www.objectivec-iphone.com/introduction/delegate/delegate.html
     4.APIでエラーが出た場合はUIAlertをだし、投稿ボタンを有効化。
     */
//    [self _postedTweet:str :self.uploadImageView.image];
    
    
    if( self.uploadImageView.image == nil)
    {//TODO:[画像がない場合は文字だけを投稿するよう変更する]
        DLog("画像ないのでデフォルトの画像を使用します");
        self.uploadImageView.image = [UIImage imageNamed:@"female.jpeg"];
    }
    
    [self _postedTweetWithText:str image:self.uploadImageView.image];
}

- (void) _finishOperation:(NSArray*)objs
{
//    ツイート投稿処理終了後の処理　半透明画面の消去，ボタン有効化
    [((UIView*)objs[0]) removeFromSuperview];
    ((UIButton*)objs[1]).enabled = YES;
//    self.view.userInteractionEnabled = YES;
}

- (IBAction) closeBtn:(id)sender
{
    DLog("モーダルを閉じます");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Event

-(void) _imageTapped:(UITapGestureRecognizer*)uiTap
{
    //    フォトライブラリ-を指定
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
//指定したSourceTypeが利用可能かどうか
    if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
    }
    else
    {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    picker.sourceType = sourceType;

    //指定したSourceTypeにより，すでに撮影した写真を選択する画面，もしくは，カメラの画面が起動する。
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - Sub function

-(void) _postedTweetWithText:(NSString*)text image:(UIImage *)uploadImage
{
    CLLocationCoordinate2D OsakaEki = CLLocationCoordinate2DMake(34.701909, 135.494977);
//    画像を読み込まなかった↓
//    UIImage* icon = [[UIImage alloc] initWithContentsOfFile:@"female"];
//    画像をファイル名で指定してUiimage型に格納
    uploadImage = [UIImage imageNamed:@"female.jpeg"];
    
//    ツイート(Text)，画像，位置情報をツイッターに投稿
    [self.twitterApi asyncPostTweetWithBody:text coordinate:OsakaEki image:uploadImage];
}

#pragma mark - Delegate

#pragma mark UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* image = info[@"UIImagePickerControllerOriginalImage"];
    DLog(
         @"\n\timage.size:%@"
         @"\n\tinfo:\n%@"
         , NSStringFromCGSize(image.size)
         , info
         );
    [self.uploadImageView setImage:image];
//画像を選択したらViewを閉じる
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UITextViewController

//Returnを押してもキーボードが下がらない:⇒デリゲートのセットしていなかった．
//UI系の場合はXibファイルでFile's　OwnerにUI部品のDelegateを線でつなぐ

-(BOOL) textFieldShouldReturn:(UITextField *)postText
{
    //  Return Value　YES if the text field should implement its default behavior for the return button; otherwise, NO.　=>返り値について:デフォルトのふるまいでよければYesそうでなければNO
    [self.postText resignFirstResponder];
    
    return NO;
}

#pragma mark TwitterAPIDelegate

- (void) twitterAPI:(TwitterAPI *)twitterAPI
        postedTweet:(TWStatus *)twStatus
{
    DLog(@"isMainThread:%@", [NSThread isMainThread] ? @"YES" : @"NO");//YES
    
    if (self.delegate != nil &&
       [self.delegate respondsToSelector:@selector(postViewController:postedTweet:)])
    {
        [self.delegate postViewController:self postedTweet:twStatus];
    }
    
    self.postButton.enabled = YES;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.waitView removeFromSuperview];

    // 初期化
    [self _initialize];
    
    //completion PostViewCtrが破棄されたあとの処理
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)twitterAPI:(TwitterAPI *)twitterAPI
  errorAtLoadData:(NSError *)error
{
    DLog(@"error:\n%@", error);
    
    self.postButton.enabled = YES;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.waitView removeFromSuperview];
}

#pragma mark - Accessor

-(TwitterAPI *)twitterApi
{
    if(_twitterApi == nil)
    {
        _twitterApi = [[TwitterAPI alloc] init];
        _twitterApi.delegate = self;
    }
    return _twitterApi;
}

- (UIView *) waitView
{
    if (_waitView == nil) {
        //処理待ち時に表示する画面
        _waitView = [[UIView alloc] initWithFrame:self.view.frame];
        [_waitView setBackgroundColor:[UIColor grayColor]];
        _waitView.alpha   = 0.7;
        
        self.waitAi.center = _waitView.center;
        [_waitView addSubview:self.waitAi];
        
        [self.waitAi startAnimating];
    }
    
    return _waitView;
}

- (UIActivityIndicatorView *) waitAi
{
    if (_waitAi == nil) {
        //処理待ち画面中央にActivityIndicatorを表示
        _waitAi
        = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _waitAi.hidesWhenStopped = NO;
    }
    
    return _waitAi;
}

@end
