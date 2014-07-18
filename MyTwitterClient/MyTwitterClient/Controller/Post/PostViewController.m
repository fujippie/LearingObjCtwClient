//
//  PostViewController.m
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/16.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import "PostViewController.h"
#import "TwitterAPI.h"
@interface PostViewController ()

@end

@implementation PostViewController

// TODO: 意味を調べる
//@synthesize postDelegate;

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

- (IBAction)postBtn:(UIButton*)button
{
    [button setEnabled:NO];
    
    NSString* str = self.postText.text;
    DLog(@"投稿内容:%@",str);
    
    // 画面上部の通信中エフェクト
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // 画面全体のUI操作を禁止する
    //    self.view.userInteractionEnabled = NO;
    
    //処理待ち時に表示する画面
    UIView *waitView = [[UIView alloc] initWithFrame:self.view.frame];
    [waitView setBackgroundColor:[UIColor grayColor]];
    waitView.alpha   = 0.7;
    
    //処理待ち画面中央にActivityIndicatorを表示
    UIActivityIndicatorView *waitAi = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [waitAi setCenter:self.view.center];
    [waitView addSubview:waitAi];
    [self.view addSubview:waitView];
    [waitAi startAnimating];
    //遅延実行　waitViewにremoveIndicatorメッセージが送られ実行される.
    [self performSelector:@selector(_finishOperation:) withObject:@[waitView, button] afterDelay:2.0f];
    
    //[waitView removeFromSuperview];
    
    /*
     1.投稿ボタンを無効化。
     2.twitterAPIにて投稿。
     3.投稿内容を親のViewControllerへ渡し、セルを生成し、挿入。Delegate使用
     ref. http://www.objectivec-iphone.com/introduction/delegate/delegate.html
     4.APIでエラーが出た場合はUIAlertをだし、投稿ボタンを有効化。
     */
    
    //UI操作禁止を解除する
    //    self.view.userInteractionEnabled=YES;
    
    [self postedTweet:str];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // delegate実行のパターン
    if (self.delegate && [self.delegate respondsToSelector:@selector(helloMain)])
    {
        [self.delegate helloMain];
    }
    
    //    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) _finishOperation:(NSArray*)objs
{
    [((UIView*)objs[0]) removeFromSuperview];
    ((UIButton*)objs[1]).enabled = YES;
    //    self.view.userInteractionEnabled = YES;
}

- (IBAction)backBtn:(id)sender {
    DLog("モーダルを閉じます");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SubFunction
-(void) postedTweet:(NSString*)text
{
    
    CLLocationCoordinate2D OsakaEki = CLLocationCoordinate2DMake(34.701909, 135.494977);
    TwitterAPI* twApi = [[TwitterAPI alloc] init];
    UIImage* icon = [[UIImage alloc] initWithContentsOfFile:@"femail"];
    BOOL flag=[twApi postTweetWithBody:text coordinate:OsakaEki image:icon];
    DLog("flag:%hhd",flag);
}
@end
