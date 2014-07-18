//
//  PostViewController.h
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/16.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
//委譲先で使用するメソッドを記述
@protocol PostViewDelegate <NSObject>
-(void) helloMain;
@end

@interface PostViewController : UIViewController
<UITextFieldDelegate>

- (IBAction)postBtn:(id)sender;
- (IBAction)backBtn:(id)sender;

//デリゲートメソッドを呼ぶためのメソッド.内部で別クラスのメソッドを呼び出す
@property (weak, nonatomic) IBOutlet UITextField *postText;
@property (nonatomic,assign) id<PostViewDelegate> delegate;
@end
