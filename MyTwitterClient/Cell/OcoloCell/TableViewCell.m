//
//  OcoloTableViewCell.m
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/28.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//
#import "TableViewCell.h"
#import "Link.h"
//TODO:[クラス名は要変更,Base.....など]

@implementation TableViewCell

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
       && [self.delegate respondsToSelector:@selector(tableViewCell:buttonImage:)]
       )
    {
        [self.delegate tableViewCell:self
                         buttonImage:imageButton.imageView];
    }
}


#pragma mark - SETextViewDelegate


- (BOOL)textView:(SETextView *)textView
   clickedOnLink:(SELinkText *)link
         atIndex:(NSUInteger)charIndex
{
    DLog("Called in CELL clickedOnLink");
    
    NSString* clickedText = link.text;
    
    id linkObj = link.object;
    NSString* classNameLinkObj = NSStringFromClass([linkObj class]);
//    DLog("CLASSNAME,OBJECT:%@",classNameLinkObj);//    __NSCFDictionary  OR  __NSCFString

    if([classNameLinkObj isEqualToString:@"__NSCFString"])
    {
        DLog(@"URL:%@",linkObj);
        //http....
    }
    else if([classNameLinkObj isEqualToString:@"__NSCFDictionary"])
    {
        DLog(@"DIC%@",linkObj);
        //@:screen_name
    }
    
        
    
    if ([clickedText hasPrefix:@"http"])
    {
        self.nextURL = [NSURL URLWithString:clickedText];
    }
    ////    TODO:[短縮URLを検出できるように]
    if ([clickedText hasPrefix:@"@"])
    {
        self.nextURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/%@", [clickedText substringFromIndex:1]]];
    }
    
    else if ([clickedText hasPrefix:@"#"])
    {
        self.nextURL = [NSURL URLWithString:
                        [NSString stringWithFormat:@"https://twitter.com/search?q=%@"
                         ,[clickedText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
    
    else
    {
        self.nextURL = [NSURL URLWithString:clickedText];
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
        [self.delegate tableViewCell:(TableViewCell *)self tappedLink:linkInCell];
    }
    
    return YES;
}

@end
