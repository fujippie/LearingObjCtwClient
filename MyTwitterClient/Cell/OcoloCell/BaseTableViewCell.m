//
//  BaseTableViewCell.m
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/28.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//
#import "BaseTableViewCell.h"
#import "Link.h"
#import "Tweet.h"
//TODO:[クラス名は要変更,Base.....など]

@implementation BaseTableViewCell

static NSString* const _instagram = @"instagram";
static NSString* const _googlePlus = @"googlePlus";
static NSString* const _facebook = @"facebook";
static NSString* const _ocolo = @"ocolo";
static NSString* const _twitter = @"twitter";

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
          accountImageButtonWith:self.name.currentTitle];
    }
}

- (IBAction)accountNameButton:(UIButton*)sender {
    if(
       self.delegate
       && [self.delegate respondsToSelector:@selector(
                                                      tableViewCell:
                                                      accountImageButtonWith:
                                                      )]
       )
    {
    [self.delegate tableViewCell:(BaseTableViewCell *) self
            accountName:self.name.currentTitle];
    }
}




#pragma mark - setData
-(void) setPostDataWithTweet:(SnsBase*)tweet snsLogoImageFileName:(NSString*)snsLogoImageFileName
{
    //    cell.tweetText.delegate = cell;
    // セルが作られた時,回り始める
    [self.spotAi startAnimating];
    [self.postImageAi startAnimating];
    [self.plfAi startAnimating];
    //  CELLにツイート(文字列)をセット
    
    // テクストにリンクをつける　＋リンクをタップしたときに検知
   
    self.tweetText.attributedText = tweet.attributedBody;

    
    
    
    
    
    if (tweet.profileImage)
    {
        [self.prfImage setImage:tweet.profileImage forState:0];
        //        [cell.prfImage setImage:[UIImage imageNamed:@"female.jpeg"] forState:0];
        [self.plfAi stopAnimating];
    }
    else
    {
        [self.prfImage setImage:[UIImage imageNamed:@"noImage"] forState:0];
    }
        self.prfImage.layer.cornerRadius  = self.prfImage.frame.size.width / 2;
        self.prfImage.layer.masksToBounds = YES;
    
    
    
    
    
    
    //投稿された画像をセット
    
    if([snsLogoImageFileName isEqualToString:_instagram] )
    {
        //        [遅延実行で確認]
        self.postedImage.hidden = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{//[遅延実行で確認]
            [self.postImageAi stopAnimating];
            
            DLog("this is InstaCell. set Image");
            [self.postedImage setImage:[UIImage imageNamed:@"female.jpeg"] forState:0];
        });//[遅延実行で確認]
    }
    else
    {//投稿画像ない場合
        [self.postedImage setImage:[UIImage imageNamed:@"noImage.jpeg"] forState:0];
        self.postedImage.hidden = YES;
        [self.postImageAi stopAnimating];
    }
    
    
    
    self.snsLogo.image = [UIImage imageNamed:snsLogoImageFileName];
    
    
    
    //APPLEは.pngを奨励　JPEGは拡張子が必要
    //cell.snsLogo.image = [UIImage imageNamed:@"twitter.jpeg"];
    
    
    
    
    //アカウント名をセット
    NSMutableString* head = @"@".mutableCopy;
    if([tweet.accountName length] != 0 )
    {
        [head appendString:tweet.accountName];
        [self.name setTitle:head forState:0];
    }
    
    
    
    
    //投稿時間をセット
    if([tweet.postTime length] != 0)
    {
        self.postTime.text = tweet.postTime;
    }
    
    
    
    //現在地との距離と住所
    
    DLog("Address:%d Distance:%d",[tweet.address length],tweet.distance);
    DLog("ISMainThread1111？？？:%hhd",[NSThread isMainThread]);
    
    if(([tweet.address length] > 0) && (tweet.distance > 0))
    {
        [self.spotAi stopAnimating];
        //        [postloc meterToKilo:tweet.distance];
        //        NSString* meter = [NSString stringWithFormat:@"%d", tweet.distance];
        self.spot.text  = [NSString stringWithFormat:@"%@ %@", [self _meterToKilo:tweet.distance], tweet.address];
        DLog("ISMainThread22222？？？:%hhd",[NSThread isMainThread]);
        
        self.longitude = tweet.longitude;
        self.latitude  = tweet.latitude;
    }
    else
    {
        self.spot.text = [NSString stringWithFormat:@" "];
    }
    
}



-(void)setProfileImage
{
    

}






-(NSString*) _meterToKilo:(NSInteger) meter{
    if(meter > 1000){
        return [NSString stringWithFormat:@"%dKm",meter/1000];
    }
    else{
        return [NSString stringWithFormat:@"%dm",meter];
    }
}



#pragma mark - SETextViewDelegate

- (BOOL)textView:(SETextView *)textView
   clickedOnLink:(SELinkText *)link
         atIndex:(NSUInteger)charIndex
{
    DLog("Called in CELL clickedOnLink%@",link.text);
    
    NSString* clickedText = link.text;
    
    id linkObj = link.object;

    NSString*     linkURLStr = @"";
    NSDictionary* linkDic    = @{};
    DLog(@"LinkObjectCLASSNAME:%@",NSStringFromClass([linkObj class]));
    //__NSCFString or __NSCFDictionary
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
        DLog("linkObjの方がNSString,NSDictionaryではない");
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
    DLog(@"\n\tLinkIncell%@",linkInCell.url);
    if(
       self.delegate
       && [self.delegate respondsToSelector:@selector(tableViewCell:tappedLink:)]
       )
    {
        DLog("CELLLL");
        [self.delegate tableViewCell:self tappedLink:linkInCell.url.description];
    }
    
    return YES;
}

@end
