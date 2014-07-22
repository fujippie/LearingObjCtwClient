//
//  MainViewController.h
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/09.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "PostViewController.h"
#import "TwitterAPI.h"
@interface MainViewController : BaseViewController
// デリゲートプロトコル参照定義
<
UITableViewDataSource
, UITableViewDelegate
, PostViewControllerDelegate
, TwitterAPIDelegate
>


@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) ACAccountStore* accountStore;
//@property(weak, nonatomic) UIRefreshControl *uiRefreshControl;



@end
