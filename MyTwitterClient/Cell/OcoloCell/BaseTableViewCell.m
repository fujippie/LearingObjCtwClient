//
//  BaseTableViewCell.m
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/28.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//
#import "BaseTableViewCell.h"

#import "Link.h"
#import "Pin.h"
#import "TWStatus.h"
#import "IGMedia.h"

@implementation BaseTableViewCell

static NSString* const _oclLogoNm = @"ocolo";
static NSString* const _twLogoNm  = @"twitter";
static NSString* const _igLogoNm  = @"instagram";
static NSString* const _gpLogoNm  = @"googlePlus";
static NSString* const _fbLogoNm  = @"facebook";
static NSString* const _pwLogoNm  = @"power";

#pragma mark - LifeCycle

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.bodyTv.delegate = self;
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
    else if ([clickedText hasPrefix:@"@"])
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

+(CGFloat) defaultBodyHeight
{
    static CGFloat defaultBodyHeight;
    
    if (defaultBodyHeight <= 0.0f)
    {
        BaseTableViewCell* cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                                 owner:nil
                                                               options:nil]
                                   objectAtIndex:0];
        defaultBodyHeight = cell.bodyTv.height;
    }
    
    if (defaultBodyHeight <= 0.0f) return 0.0f;
    
    return defaultBodyHeight;
}

#pragma mark - Accessor

-(void) setPin:(Pin *)pin
{
    [self setPin:pin currentCoord:kCLLocationCoordinate2DInvalid];
}

-(void) setPin:(Pin *)pin
  currentCoord:(CLLocationCoordinate2D)currentCoord;
{
    if (![pin isKindOfClass:[Pin class]])
    {
        DLOG(@"\n\n******* error ********\n%@\n", NSStringFromClass([pin class]));
        _pin = nil;
        
        return;
    }

    _pin = pin;
    
    if (CLLocationCoordinate2DIsValid(currentCoord))
    {
        [self _setupCellWith:pin currentCoord:currentCoord];
    }
    else
    {
        [self _setupCellWith:pin currentCoord:kCLLocationCoordinate2DInvalid];
    }
}

#pragma mark - Setup cell

-(void) _setupCellWith:(Pin*)pin currentCoord:(CLLocationCoordinate2D)currentCoord
{
    //    cell.tweetText.delegate = cell;
    // セルが作られた時,回り始める
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.spotAi startAnimating];
        [self.postImageAi startAnimating];
        [self.prfAi startAnimating];
    });
    
    [self _setProfileImageWithPin:pin];
    [self _setAddressAndDistanceWithPin:pin currentCoord:currentCoord];
    [self _setAttributeBodyWithPin:pin];
    [self _setPostImageWithPin:pin];
    [self _setPostTimeWithPin:pin];
    
    //[self _setPostImageWithSnsBase:(Instagram*)snsBase];
    
    self.iconLbl.font = [UIFont fontAwesomeFontOfSize:self.iconLbl.font.pointSize];
    self.iconLbl.text = [NSString fontAwesomeIconStringForEnum:pin.categoryIconId];
    //  CELLにツイート(文字列)をセット
    // テクストにリンクをつける　＋リンクをタップしたときに検知
}

-(void) _setProfileImageWithPin:(Pin*)pin
{
    //    dispatch_async(dispatch_get_main_queue(), ^{
    
    [self.prfImageBtn setImage:[UIImage imageNamed:@"noImage"] forState:UIControlStateNormal];

    self.prfImageBtn.layer.cornerRadius  = self.prfImageBtn.frame.size.width / 2;
    self.prfImageBtn.layer.masksToBounds = YES;

    /*
    if (pin.image)
    {
        [self.prfImageBtn setImage:pin.image forState:UIControlStateNormal];
        
        [self.prfAi stopAnimating];
        self.prfAi.hidden = YES;
    }
    else if (pin.imageUrl)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
        {
            NSData* imageData = [NSData dataWithContentsOfURL:pin.imageUrl];
            UIImage* image = [UIImage imageWithData:imageData];
            dispatch_async(dispatch_get_main_queue(), ^
            {
                pin.image = image;
                
                [self.prfImageBtn setImage:image forState:UIControlStateNormal];
                
                [self.prfAi stopAnimating];
                self.prfAi.hidden = YES;
                
                [self setNeedsDisplay];
            });
        });
    }
    else
    {
        [self.prfAi stopAnimating];
        self.prfAi.hidden = YES;
    }
     */

}

-(void) _setAddressAndDistanceWithPin:(Pin*)pin
                         currentCoord:(CLLocationCoordinate2D)currentCoord
{
    DLOG(
         @"\n\tlat:%f"
         @"\n\tlng:%f"
         , currentCoord.latitude
         , currentCoord.longitude
         );
    
    if (CLLocationCoordinate2DIsValid(currentCoord))
    {
        DLOG(@"\n\n*****************\n\n");
        
        //        self.distanceLbl.font = [UIFont fontAwesomeFontOfSize:self.distanceLbl.font.pointSize];
        //        NSString* distanceStr = [NSString fontAwesomeIconStringForEnum:FAFlagCheckered];
        NSInteger meter = [pin distanceFromCurrentCoord:currentCoord];
        //        distanceStr = [distanceStr stringByAppendingFormat:@" %@", [NSString stringIsSummarizedFromMeter:meter]];
        //        self.distanceLbl.text = distanceStr;
        self.distanceLbl.text = [NSString stringIsSummarizedFromMeter:meter];
    }
    
    if (pin.address)
    {
        [self.spotAi stopAnimating];
        self.spotLbl.text  = [NSString stringWithFormat:@"%@", pin.address];
    }
    else
    {
        [pin asyncAddress:^(NSString *address)
         {
             [self.spotAi stopAnimating];
             self.spotLbl.text  = [NSString stringWithFormat:@"%@", address];
         }];
    }
}

-(void) _setAttributeBodyWithPin:(Pin*)pin
{
    self.bodyTv.attributedText = pin.attributeBody;
}

-(void) _setPostImageWithPin:(Pin*)pin
{
    [self.prfImageBtn setImage:[UIImage imageNamed:@"noImage"] forState:UIControlStateNormal];
    
    /*
    if (pin.postImage)
    {
        self.postImageAi.hidden = YES;
        [self.postImageAi stopAnimating];
        [self.postedImageBtn setImage:pin.postImage forState:UIControlStateNormal];
    }
    else if (pin.postImageUrl)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData* imageData = [NSData dataWithContentsOfURL:pin.postImageUrl];
            UIImage* image = [UIImage imageWithData:imageData];
            dispatch_async(dispatch_get_main_queue(), ^{
                pin.image = image;
                self.postImageAi.hidden = YES;
                [self.postImageAi stopAnimating];
                [self.postedImageBtn setImage:image forState:UIControlStateNormal];
            });
        });
    }
    else
    {
        self.postImageAi.hidden = YES;
        [self.postImageAi stopAnimating];
    }
     */
}

-(void) _setAddressAndDistanceWithPin:(Pin*)pin
{
    [self _setAddressAndDistanceWithPin:pin currentCoord:kCLLocationCoordinate2DInvalid];
}

-(void) _setPostTimeWithPin:(Pin*)pin
{
    if (pin.created)
    {
        DLOG(@"\n\tself.postTimeLbl.font.pointSize:%f", self.postTimeLbl.font.pointSize);

//        NSString* distanceStr = [NSString fontAwesomeIconStringForEnum:FAClockO];
//        self.postTimeLbl.text = [distanceStr stringByAppendingFormat:@" %@", [pin.created timeLineFormat]];
//        self.postTimeLbl.font = [UIFont fontAwesomeFontOfSize:self.postTimeLbl.font.pointSize];
        self.postTimeLbl.text = [pin.created timeLineFormat];
        
    }
}

#pragma mark - Accessor

-(UIImage *) prfImage
{
    if (self.pin == nil)
        return nil;
    else
        return self.pin.image;
}

-(void) setPrfImage:(UIImage *)prfImage
{
    if (prfImage)
    {
        self.prfImageBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.prfImageBtn setImage:prfImage forState:UIControlStateNormal];
    }
    else
    {
        [self.prfImageBtn setImage:[UIImage imageNamed:@"noImage"] forState:UIControlStateNormal];
    }

    self.prfAi.hidden = YES;
}

-(UIImage *) postedImage
{
    if (self.pin == nil)
        return nil;
    else
        return self.pin.postImage;
}

-(void) setPostedImage:(UIImage *)postedImage
{
    if (postedImage)
    {
        self.postedImageBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.postedImageBtn setImage:postedImage forState:UIControlStateNormal];
    }
    else
    {
        [self.postedImageBtn setImage:[UIImage imageNamed:@"noImage"] forState:UIControlStateNormal];
    }

    self.postImageAi.hidden = YES;
}

@end


