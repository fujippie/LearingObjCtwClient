//
//  NSString+Extension.h
//  OCOLO
//
//  Created by masashi_tamayama on 2014/08/06.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

-(NSString *) tailtruncateWithMaxLength:(NSInteger)maxLength;
/**
 "dirty" solution
 Because, removes everything between < and >
 */
-(NSString *) stringByStrippingHTML;
/**
 "dirty" solution
 Because, removes everything between < and >
 */
-(NSString *) stringByReplacingHTMLAtString:(NSString*)string;

@end
