//
//  PostViewController.h
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/16.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostViewController : UIViewController
<UITextFieldDelegate>

- (IBAction)postBtn:(id)sender;
- (IBAction)backBtn:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *postText;

@end
