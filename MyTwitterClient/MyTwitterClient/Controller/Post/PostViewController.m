//
//  PostViewController.m
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/16.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import "PostViewController.h"

@interface PostViewController ()

@end

@implementation PostViewController

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
    DLog(@"投稿内容:%@",self.postText.text);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    /* 
     1.投稿ボタンを無効化。
     2.twitterAPIにて投稿。
     3.投稿内容を親のViewControllerへ渡し、セルを生成し、挿入。Delegate使用
       ref. http://www.objectivec-iphone.com/introduction/delegate/delegate.html
     4.APIでエラーが出た場合はUIAlertをだし、投稿ボタンを有効化。
     */
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
@end
