//
//  CellManager.h
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/08/04.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableViewCell.h"
#import "Tweet.h"
#import "MainViewController.h"
@interface CellManager : NSObject
-(TableViewCell*) setViewOcoloCellwithCell:(TableViewCell*)cell
                                      tableView:(UITableView *)tableview
                                          tweet:(Tweet *) tweet
                                          cellH:(CGFloat) cellH
                                          bodyH:(CGFloat)  bodyH;
@end
