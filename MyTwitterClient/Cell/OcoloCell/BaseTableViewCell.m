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
#import "Instagram.h"
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
       && [self.delegate respondsToSelector:@selector(tableViewCell:postImageButtonTapped:)]
       )
    {
        [self.delegate tableViewCell:self
                         postImageButtonTapped:imageButton.imageView];
    }
}

- (IBAction)naviButton:(UIButton *) naviButton{
    DLog("naviButton");
//緯度、経度をCell内でデータを持っていないので取れない
//    Mainで呼び出す
    if(
       self.delegate
       && [self.delegate respondsToSelector:@selector(tableViewCell:
                                                      naviButtonTappedWithAddress:
                                                      latitude:
                                                      longtitude:)]
       )
    {
        if(self.latitude != 0  && self.longitude != 0){
            [self.delegate  tableViewCell:self
                    naviButtonTappedWithAddress:self.spot.text
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
                                                      accountImageButtonTappedWith:
                                                      )]
       )
    {
    [self.delegate tableViewCell:(BaseTableViewCell *) self
          accountImageButtonTappedWith:self.name.currentTitle];
    }
}

- (IBAction)accountNameButton:(UIButton*)sender {
    if(
       self.delegate
       && [self.delegate respondsToSelector:@selector(
                                                      tableViewCell:
                                                      accountImageButtonTappedWith:
                                                      )]
       )
    {
    [self.delegate tableViewCell:(BaseTableViewCell *) self
            accountNameTapped:self.name.currentTitle];
    }
}

#pragma mark - setData
-(void) setTweetData:(Tweet*)tweet snsLogoImageFileName:(NSString*)snsLogoImageFileName
{
    //    cell.tweetText.delegate = cell;
    // セルが作られた時,回り始める
    [self.spotAi startAnimating];
    [self.postImageAi startAnimating];
    [self.plfAi startAnimating];
    
    [self _setAttributeBodyWithSnsBase:tweet];
    [self _setProfileImageWithSnsBase:tweet];
    [self _setAddressAndDistanceWithSnsBase:tweet];
    [self _setAccountNameWithSnsBase:tweet];
    [self _setPostTime:tweet];
    
    [self _setNoPostImage];
    //[self _setPostImageWithSnsBase:(Instagram*)snsBase];
    
    self.snsLogo.image = [UIImage imageNamed:snsLogoImageFileName];
    //  CELLにツイート(文字列)をセット
    // テクストにリンクをつける　＋リンクをタップしたときに検知
}

-(void) setInstagramData:(Instagram*)instagram snsLogoImageFileName:(NSString*)snsLogoImageFileName
{
    //    cell.tweetText.delegate = cell;
    // セルが作られた時,回り始める
    [self.spotAi startAnimating];
    [self.postImageAi startAnimating];
    [self.plfAi startAnimating];
    
    [self _setAttributeBodyWithSnsBase:instagram];
    [self _setProfileImageWithSnsBase:instagram];
    [self _setAddressAndDistanceWithSnsBase:instagram];
    [self _setAccountNameWithSnsBase:instagram];
    [self _setPostTime:instagram];
    [self _setPostImage:instagram];
    //[self _setPostImageWithSnsBase:(Instagram*)snsBase];
    
    self.snsLogo.image = [UIImage imageNamed:snsLogoImageFileName];
    //  CELLにツイート(文字列)をセット
    // テクストにリンクをつける　＋リンクをタップしたときに検知
}

-(void)_setAttributeBodyWithSnsBase:(SnsBase*)snsBase
{
    self.tweetText.attributedText = snsBase.attributedBody;
}

-(void)_setAccountNameWithSnsBase:(SnsBase*)snsBase
{
    NSMutableString* head = @"@".mutableCopy;
    if([snsBase.accountName length] != 0 )
    {
        [head appendString:snsBase.accountName];
        [self.name setTitle:head forState:0];
    }
}

-(void)_setProfileImageWithSnsBase:(SnsBase*)snsBase
{
//    dispatch_async(dispatch_get_main_queue(), ^{
    
    __block UIImage* img=[[UIImage alloc] init];
//     dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^                         {
            img= snsBase.profileImage;
            DLog("PRFEELIMG%@",img);
         
//         dispatch_async(dispatch_get_main_queue(), ^{
             if (snsBase.profileImage)
             {
//                 dispatch_async(dispatch_get_main_queue(), ^{//効果なし
                     [self.prfImage setImage:snsBase.profileImage forState:0];
                     [self.plfAi stopAnimating];
//                 });
             }
             else
             {
                 [self.prfImage setImage:[UIImage imageNamed:@"noImage"] forState:0];
             }
             self.prfImage.layer.cornerRadius  = self.prfImage.frame.size.width / 2;
             self.prfImage.layer.masksToBounds = YES;
    
//    DLog("PRFEELIMG%@",img);//null
        self.prfImage.layer.cornerRadius  = self.prfImage.frame.size.width / 2;
        self.prfImage.layer.masksToBounds = YES;
}

-(void)_setAddressAndDistanceWithSnsBase:(SnsBase*)snsBase
{
    DLog("Address:%d Distance:%d",[snsBase.address length],snsBase.distance);
    DLog("ISMainThread1111？？？:%hhd",[NSThread isMainThread]);
    
    if(([snsBase.address length] > 0) && (snsBase.distance > 0))
    {
        [self.spotAi stopAnimating];
        self.spot.text  = [NSString stringWithFormat:@"%@ %@", [self _meterToKilo:snsBase.distance], snsBase.address];
        DLog("ISMainThread22222？？？:%hhd",[NSThread isMainThread]);
        self.longitude = snsBase.longitude;
        self.latitude  = snsBase.latitude;
    }
    else
    {
        self.spot.text = [NSString stringWithFormat:@" "];
    }
}

-(void)_setPostTime:(SnsBase*)snsBase
{
    if([snsBase.postTime length] != 0)
    {
        self.postTime.text = snsBase.postTime;
    }
}

-(void)_setPostImage:(Instagram*)instagram
{
 //APPLEは.pngを奨励　JPEGは拡張子が必要//cell.snsLogo.image = [UIImage imageNamed:@"twitter.jpeg"];
    self.postedImage.hidden = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
//       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{//[遅延実行で確認]
            [self.postImageAi stopAnimating];
//          [self.postedImage setImage:[UIImage imageNamed:@"female.jpeg"] forState:0];
            if(self.postedImage != nil)
            {
                [self.postedImage setImage:[UIImage imageNamed:@"female.jpeg"]
                                  forState:0];
                self.postImageAi.hidden = YES;
//                [self.postImageAi removeFromSuperview];
            }
//        });
    });
}

-(void)_setNoPostImage
{
    [self.postedImage setImage:[UIImage imageNamed:@"noImage.jpeg"] forState:0];
    self.postedImage.hidden = YES;
    [self.postImageAi stopAnimating];
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
    DLog(@"LinkObjectCLASSNAME:%@",NSStringFromClass([link.object class]));
    
    

//    継承関係が同じか？isKindOfClass そのクラスかisMemberOfClass
    if ([linkObj isKindOfClass:[NSString class]])
    {
         DLog("linkObjIs....:NSString");
        linkURLStr = (NSString*)linkObj;//http....
    }
    else if ([linkObj isKindOfClass:[NSDictionary class]])
    {
        linkDic = (NSDictionary*)linkObj;
        //@:   screen_name
        //#:   text
    }
    else
    {
        DLog("linkObjがNSString,NSDictionaryではない%@",linkObj);
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
