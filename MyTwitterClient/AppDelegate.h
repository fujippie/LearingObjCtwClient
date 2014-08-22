//
//  AppDelegate.h
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/08.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeListViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow               *window;
@property (strong, nonatomic) HomeListViewController *homeListViewController;
@property (strong, nonatomic) UINavigationController *navigationController;
@end
