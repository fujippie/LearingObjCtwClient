//
//  CellManager.m
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/08/04.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import "CellManager.h"
#import "TableViewCell.h"
#import "Tweet.h"
#import "MainViewController.h"
@implementation CellManager

-(TableViewCell*) setViewOcoloCellwithCell:(TableViewCell*)cell
                                      tableView:(UITableView *)tableview
                                          tweet:(Tweet *) tweet
                                           cellH:(CGFloat) cellH
                                          bodyH:(CGFloat)  bodyH
                                 

{
    DLog("cellForRowAtIndexPath");
    //    CustomTVC* cell = [tableView dequeueReusableCellWithIdentifier:_cellId];
    //  CELLにツイート(文字列)をセット
    //  http://d.hatena.ne.jp/KishikawaKatsumi/20130605/1370370925
    //    http://oropon.hatenablog.com/entry/20120408/p1
    // テクストにリンクをつける　＋リンクをタップしたときに検知
    NSMutableAttributedString *attributeStr =[[NSMutableAttributedString alloc] initWithString:tweet.body];
    //属性をセット
    [attributeStr addAttribute:NSBackgroundColorAttributeName
                         value:[UIColor colorWithRed:1. green:1. blue:.0 alpha:1.]
                         range:NSMakeRange(0, [attributeStr length])];
    [cell.body setAttributedText:attributeStr];
    //cell.body.text = [NSString stringWithFormat:@"%@",tweet.body];
    cell.body.lineBreakMode = NSLineBreakByCharWrapping;
    cell.body.numberOfLines = 0;
    //  Cell中のTextLabelを設定
    //Frameの左上を(origin)原点として,Bodyを配置
    //Bodyの高さがCellの高さに設定されている
    cell.body.frame = CGRectMake(
                                 cell.body.frame.origin.x,
                                 cell.body.frame.origin.y,
                                 cell.body.frame.size.width,
                                 bodyH
                                 );
    //位置情報のラベルの位置を設定
    cell.spot.frame = CGRectMake(
                                 cell.spot.frame.origin.x,
                                 cell.body.frame.origin.y+cell.body.frame.size.height,
                                 cell.spot.frame.size.width,
                                 cell.spot.frame.size.height
                                 );
    if(tweet.address != nil)
    {
        cell.spot.text = [NSString stringWithFormat:@"%@",tweet.address];
    }
    else
    {
        cell.spot.text = [NSString stringWithFormat:@" "];
    }
    //  CELLにアイコン(プロフィール)画像をセット
    if (tweet.profileImage)
    {
        cell.prfImage.image = tweet.profileImage;
    }
    else
    {
        cell.prfImage.image = [UIImage imageNamed:@"noImage"];
    }
    cell.prfImage.layer.cornerRadius  = cell.prfImage.frame.size.width/2;
    cell.prfImage.layer.masksToBounds = YES;
    
    //投稿された画像をセット
    if(tweet.profileImage != nil)
    {
        //TODO:[ツイッターから投稿画像を取得し,画像の有無を判定]
        
        [cell.postedImage setImage:tweet.profileImage forState:0];
        DLog("PROFIMAGE");
    }
    else
    {
        [cell.postedImage setImage:[UIImage imageNamed:@"noImage"] forState:0];
    }
    if(nil)
    {
        //TODO:[どのSNSか判定し,画像を選択]
    }
    else
    {
        cell.snsLogo.image = [UIImage imageNamed:@"noImage"];
    }
    //アカウント名をセット
    NSMutableString* head = @"@".mutableCopy;
    if([tweet.accountName length] != 0 )
    {
        [head appendString:tweet.accountName];
        cell.accountName.text = head;
    }
    //投稿時間をセット
    if([tweet.postTime length] != 0)
    {
        cell.postTime.text = tweet.postTime;
    }
    //現在地との距離
    if(tweet.distance > 0 ){
        //       cell.spot.text=append
        NSString* meter = [NSString stringWithFormat:@"%d",tweet.distance];
        if([tweet.address length] == 0 ){
            cell.spot.text  = [NSString stringWithFormat:@"%@m %@", meter,tweet.address];
        }
    }
    //    tweet.accountName;
    DLog("acccount%@",tweet.accountName);
    //ボタン位置を設定
    return cell;

}


@end
