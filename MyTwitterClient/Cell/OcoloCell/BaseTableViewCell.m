//
//  OcoloTableViewCell.m
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/28.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//
#import "BaseTableViewCell.h"
#import "Link.h"
//TODO:[クラス名は要変更,Base.....など]

@implementation BaseTableViewCell

#pragma mark - LifeCycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Initialization code
    self.tweetText.delegate = self;
    DLog("TweetText:%@", self.tweetText.delegate);
}

#pragma mark - Action

- (IBAction)postedImage:(UIButton *)imageButton
{
    //引数のUIボタンの画像をデリゲートでMainViewCTRに渡す.
    DLog("ImageTapped");
    if(
       self.delegate
       && [self.delegate respondsToSelector:@selector(tableViewCell:postImageButton:)]
       )
    {
        [self.delegate tableViewCell:self
                         postImageButton:imageButton.imageView];
    }
}

- (IBAction)naviButton:(UIButton *) naviButton{
    DLog("naviButton");
//緯度、経度をCell内でデータを持っていないので取れない
//    Mainで呼び出す
    if(
       self.delegate
       && [self.delegate respondsToSelector:@selector(tableViewCell:
                                                      naviButtonWithAddress:
                                                      latitude:
                                                      longtitude:)]
       )
    {
        if(self.latitude != 0  && self.longitude != 0){
            [self.delegate  tableViewCell:self
                    naviButtonWithAddress:self.spot.text
                                 latitude:self.latitude
                               longtitude:self.longitude];
        }
    }
}

- (IBAction)plfImageButton:(id)sender {
    DLog("PLFImageButton");
    
    if(
       self.delegate
       && [self.delegate respondsToSelector:@selector(
                                                      tableViewCell:
                                                      accountImageButtonWith:
                                                      )]
       )
    {
    [self.delegate tableViewCell:(BaseTableViewCell *) self
          accountImageButtonWith:self.name.text];
    }
    
}


#pragma mark - setData
-(void) setPostData
{


}


#pragma mark - SETextViewDelegate

- (BOOL)textView:(SETextView *)textView
   clickedOnLink:(SELinkText *)link
         atIndex:(NSUInteger)charIndex
{
    DLog("Called in CELL clickedOnLink");
    
    NSString* clickedText = link.text;
    
    id linkObj = link.object;

    NSString*     linkURLStr = @"";
    NSDictionary* linkDic    = @{};
    
    if ([linkObj isMemberOfClass:[NSString class]])
    {
        linkURLStr = (NSString*)linkObj;//http....
    }
    else if ([linkObj isMemberOfClass:[NSDictionary class]])
    {
        linkDic = (NSDictionary*)linkObj;
        //@:   screen_name
        //#:   text
    }
    else
    {
        if(
           self.delegate
           && [self.delegate respondsToSelector:@selector(tableViewCell:tappedLink:)]
           )
        {
            [self.delegate tableViewCell:self tappedLink:nil];
        }
        
        return NO;
    }
    
    if ([linkURLStr hasPrefix:@"http"])
    {
        self.nextURL = [NSURL URLWithString: linkURLStr];
    }

    if ([clickedText hasPrefix:@"@"])
    {
        self.nextURL = [NSURL URLWithString:
                        [NSString stringWithFormat:
                         @"https://twitter.com/%@", [linkDic[@"screen_name"] substringFromIndex:1]]];
    }
    
    else if ([clickedText hasPrefix:@"#"])
    {
        self.nextURL = [NSURL URLWithString:
                        [NSString stringWithFormat:@"https://twitter.com/search?q=%@"
                         ,[linkDic[@"text"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }

    if (self.nextURL)
    {
        //        [self performSegueWithIdentifier:@"WebView" sender:self];
        DLog("URL_TAPPED\tURL:%@", self.nextURL);
    }
    
    Link* linkInCell = [[Link alloc] init];
    linkInCell.text = link.text;
    linkInCell.url  = self.nextURL;
    
    if(
       self.delegate
       && [self.delegate respondsToSelector:@selector(tableViewCell:tappedLink:)]
       )
    {
        [self.delegate tableViewCell:self tappedLink:linkInCell];
    }
    
    return YES;
}

@end
