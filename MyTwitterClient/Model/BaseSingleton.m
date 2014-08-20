//
//  BaseSingleton.m
//  OCOLO
//
//  Created by masashi_tamayama on 2014/08/11.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import "BaseSingleton.h"

@interface BaseSingleton ()

@end

@implementation BaseSingleton

#pragma mark - Consts

static NSMutableDictionary* _instances;

#pragma mark - Initialize

+ (instancetype) sharedInstance
{
    __block BaseSingleton *obj;
    
    @synchronized(self)
    {
        if ([_instances objectForKey:NSStringFromClass(self)] == nil)
        {
            obj = [[self alloc] initSharedInstance];
        }
    }
    
    obj = [_instances objectForKey:NSStringFromClass(self)];
    
    return obj;
}

+ (id) allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if ([_instances objectForKey:NSStringFromClass(self)] == nil)
        {
            id instance = [super allocWithZone:zone];
            
            if (_instances == nil)
            {
                _instances = @{}.mutableCopy;
            }
            
            [_instances setObject:instance forKey:NSStringFromClass(self)];
            
            return instance;
        }
    }
    
    return nil;
}

- (instancetype) initSharedInstance
{
    self = [super init];
    
    if (self)
    {
        // Initialize
    }
    
    return self;
}

- (instancetype) init
{
    [self doesNotRecognizeSelector:_cmd]; // init を直接呼ぼうとしたらエラーを発生させる
    return nil;
}

@end
