//
//  NSObject+PropertyList.h
//  OCOLO
//
//  Created by masashi_tamayama on 2014/07/16.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PropertyList)

// プロパティ情報一覧を取得
@property (nonatomic, readonly) NSArray *propertiesDescription;

- (NSArray *)propertiesDescriptionOfSuper;
- (NSArray *)propertiesDescriptionWithExtendClass:(Class)class;

// プロパティ名一覧を取得
@property (nonatomic, readonly) NSArray *propertyNames;

+ (NSArray *)propertyNames;


@end
