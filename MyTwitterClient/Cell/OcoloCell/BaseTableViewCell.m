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
#import "SnsBase.h"

@implementation BaseTableViewCell

static NSString* const _igLogoNm  = @"instagram";
static NSString* const _gpLogoNm  = @"googlePlus";
static NSString* const _fbLogoNm  = @"facebook";
static NSString* const _oclLogoNm = @"ocolo";
static NSString* const _twLogoNm  = @"twitter";
static NSString* const _pwLogoNm  = @"power";

static CGFloat   const _nonPostImageCellH = 114.0f;

#pragma mark - LifeCycle

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.body.delegate = self;

    DLog("TweetText:%@", self.body.delegate);
}

#pragma mark - Action

#pragma mark IBAction

- (IBAction) tappedPostedImage:(UIButton *)imageButton
{
    //引数のUIボタンの画像をデリゲートでMainViewCTRに渡す.
    DLog("ImageTapped");
    
    if(
       self.delegate
       && [self.delegate respondsToSelector:@selector(tableViewCell:tappedPostImageButtonWithPin:)]
       )
    {
        [self.delegate tableViewCell:self
                         tappedPostImageButtonWithPin:self.pin];
    }
}

- (IBAction) tappedToPlaceButton:(UIButton *)toPlaceButton
{
    DLog("toPlaceButton");
    
//緯度、経度をCell内でデータを持っていないので取れない
//    Mainで呼び出す
    if(
       self.delegate
       && [self.delegate respondsToSelector:@selector(tableViewCell:tappedToPlaceButtonWithPin:)]
       )
    {
        [self.delegate  tableViewCell:self tappedToPlaceButtonWithPin:self.pin];
    }
}

- (IBAction) tappedPlfImageButton:(UIButton*)sender
{
    DLog("PLFImageButton");
    
    if(
       self.delegate
       && [self.delegate respondsToSelector:@selector(tableViewCell:tappedProfileImageButtonWithPin:)]
       )
    {
        [self.delegate tableViewCell:self tappedProfileImageButtonWithPin:self.pin];
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
    
    NSURL* url = nil;
    if ([linkURLStr hasPrefix:@"http"])
    {
        url = [NSURL URLWithString: linkURLStr];
    }

    if ([clickedText hasPrefix:@"@"])
    {
        url = [NSURL URLWithString:
                        [NSString stringWithFormat:
                         @"https://twitter.com/%@", [linkDic[@"screen_name"] substringFromIndex:1]]];
    }
    
    else if ([clickedText hasPrefix:@"#"])
    {
        url = [NSURL URLWithString:
                        [NSString stringWithFormat:@"https://twitter.com/search?q=%@"
                         ,[linkDic[@"text"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }

    if (url)
    {
        //        [self performSegueWithIdentifier:@"WebView" sender:self];
        DLog("URL_TAPPED\tURL:%@", url);
    }
    
    Link* linkInCell = [[Link alloc] init];
    linkInCell.text = link.text;
    linkInCell.url  = url;
    DLog(@"\n\tLinkIncell%@",linkInCell.url);
    if(
       self.delegate
       && [self.delegate respondsToSelector:@selector(tableViewCell:tappedLink:)]
       )
    {
        DLog("CELLLL");
        [self.delegate tableViewCell:self tappedLink:linkInCell];
    }
    
    return YES;
}

#pragma mark - Caluculating

+(CGFloat) defaultHeightIsPostImage:(BOOL)isPostImage
{
    static BaseTableViewCell* cell = nil;
    
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] objectAtIndex:0];
    }
    
    if (cell == nil) return 0.0f;

    CGFloat height;
    
    if (isPostImage)
    {
        height = cell.bounds.size.height;
    }
    else
    {
        height = _nonPostImageCellH;
    }
    
    return height;
}

#pragma mark - Accessor

-(void)setPin:(SnsBase *)pin
{
    if (![pin isKindOfClass:[SnsBase class]])
    {
        _pin = nil;
    }
    else
    {
        _pin = pin;
    }
    
    if ([pin isMemberOfClass:[Tweet class]])
    {
        [self _setupTweetData:(Tweet*)pin];
    }
    else if ([pin isMemberOfClass:[Instagram class]])
    {
        [self _setupInstagramData:(Instagram *)pin];
    }
}

#pragma mark - Set data

-(void) _setupTweetData:(Tweet*)tweet
{
    //    cell.tweetText.delegate = cell;
    // セルが作られた時,回り始める
    [self.spotAi startAnimating];
    [self.postImageAi startAnimating];
    [self.prfAi startAnimating];
    
    [self _setAttributeBodyWithSnsBase:tweet];
    [self _setProfileImageWithSnsBase:tweet];
    [self _setAddressAndDistanceWithSnsBase:tweet];
    [self _setPostTime:tweet];
    
    [self _setNoPostImage];
    //[self _setPostImageWithSnsBase:(Instagram*)snsBase];
    
    self.snsLogo.image = [UIImage imageNamed:_twLogoNm];
    //  CELLにツイート(文字列)をセット
    // テクストにリンクをつける　＋リンクをタップしたときに検知
}

-(void) _setupInstagramData:(Instagram*)instagram
{
    //    cell.tweetText.delegate = cell;
    // セルが作られた時,回り始める
    [self.spotAi startAnimating];
    [self.postImageAi startAnimating];
    [self.prfAi startAnimating];
    
    [self _setAttributeBodyWithSnsBase:instagram];
    [self _setProfileImageWithSnsBase:instagram];
    [self _setAddressAndDistanceWithSnsBase:instagram];
    [self _setPostTime:instagram];
    [self _setPostImage:instagram];
    //[self _setPostImageWithSnsBase:(Instagram*)snsBase];
    
    self.snsLogo.image = [UIImage imageNamed:_igLogoNm];
    //  CELLにツイート(文字列)をセット
    // テクストにリンクをつける　＋リンクをタップしたときに検知
}

-(void) _setAttributeBodyWithSnsBase:(SnsBase*)snsBase
{
    self.body.attributedText = snsBase.attributedBody;
}

-(void) _setProfileImageWithSnsBase:(SnsBase*)snsBase
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
        [self.prfAi stopAnimating];
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

-(void) _setAddressAndDistanceWithSnsBase:(SnsBase*)snsBase
{
    DLog("Address:%d Distance:%d",[snsBase.address length],snsBase.distance);
    DLog("ISMainThread1111？？？:%hhd",[NSThread isMainThread]);
    
    if(([snsBase.address length] > 0) && (snsBase.distance > 0))
    {
        [self.spotAi stopAnimating];
        self.spot.text  = [NSString stringWithFormat:@"%@ %@", [self _kilometerFromMeter:snsBase.distance], snsBase.address];
        DLog("ISMainThread22222？？？:%hhd",[NSThread isMainThread]);
        //        self.longitude = snsBase.longitude;
        //        self.latitude  = snsBase.latitude;
    }
    else
    {
        self.spot.text = [NSString stringWithFormat:@" "];
    }
}

-(void) _setPostTime:(SnsBase*)snsBase
{
    if([snsBase.postTime length] != 0)
    {
        self.postTime.text = snsBase.postTime;
    }
}

-(void) _setPostImage:(Instagram*)instagram
{
    //APPLEは.pngを奨励　JPEGは拡張子が必要//cell.snsLogo.image = [UIImage imageNamed:@"twitter.jpeg"];
    self.postedImageButton.hidden = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        //       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{//[遅延実行で確認]
        [self.postImageAi stopAnimating];
        [self.postedImageButton setImage:[UIImage imageNamed:@"female.jpeg"] forState:0];
        if(self.postedImageButton != nil)
        {
            [self.postedImageButton setImage:[UIImage imageNamed:@"female.jpeg"]
                                    forState:0];
            self.postImageAi.hidden = YES;
            [self.postImageAi removeFromSuperview];
        }
        //        });
    });
}

-(void) _setNoPostImage
{
    [self.postedImageButton setImage:[UIImage imageNamed:@"noImage.jpeg"] forState:0];
    self.postedImageButton.hidden = YES;
    [self.postImageAi stopAnimating];
}

-(NSString*) _kilometerFromMeter:(NSInteger)meter
{
    if(meter > 1000)
    {
        return [NSString stringWithFormat:@"%dKm",meter/1000];
    }
    else
    {
        return [NSString stringWithFormat:@"%dm",meter];
    }
}


@end


