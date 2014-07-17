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
@synthesize delegate;

#pragma mark - testDelegate
-(void) helloPostDel
{
    DLog("デリゲートでHelloMainを呼びます");
    [self.delegate helloMain];

}

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

- (IBAction)postBtn:(id)sender
{
    NSString* str = self.postText.text;
    DLog(@"投稿内容:%@",str);
    [self helloPostDel];
//    画面上部の通信中エフェクト
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    /* 
     1.投稿ボタンを無効化。
     2.twitterAPIにて投稿。
     3.投稿内容を親のViewControllerへ渡し、セルを生成し、挿入。Delegate使用
       ref. http://www.objectivec-iphone.com/introduction/delegate/delegate.html
     4.APIでエラーが出た場合はUIAlertをだし、投稿ボタンを有効化。
     */
    
    [self postedTweet:str];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    
//    [self dismissViewControllerAnimated:YES completion:nil];
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
