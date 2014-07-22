//
//  PostViewController.h
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/16.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitterAPI.h"
#import "Tweet.h"
//委譲先で使用するメソッドを記述
@class PostViewController;
@protocol PostViewControllerDelegate <NSObject>

-(void) postViewController:(PostViewController*)postViewController
               postedTweet:(Tweet*)tweet;
@end

@interface PostViewController : UIViewController
<UITextFieldDelegate, TwitterAPIDelegate>

//デリゲートメソッドを呼ぶためのメソッド.内部で別クラスのメソッドを呼び出す
@property (weak, nonatomic) IBOutlet UITextField *postText;
@property (nonatomic,assign) id<PostViewControllerDelegate> delegate;

@end
