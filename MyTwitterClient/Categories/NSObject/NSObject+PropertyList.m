//
//  NSObject+PropertyList.m
//  OCOLO
//
//  Created by masashi_tamayama on 2014/07/16.
//  Copyright (c) 2014年 LOCKON CO.,LTD. All rights reserved.
//

#import "NSObject+PropertyList.h"

#import "NSObject+PropertyList.h"
#import <objc/runtime.h>

@implementation NSObject (PropertyList)

static const char *_getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL)
    {
        if (attribute[0] == 'T' && attribute[1] != '@')
        {
            NSString *name = [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) - 1 encoding:NSASCIIStringEncoding];
            
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) > 4) {
            // it's another ObjC object type:
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            return "????";
        }
    }
    
    return "";
}

#pragma mark - Public method

// プロパティ情報一覧を取得
- (NSArray *)propertiesDescriptionOfSuper
{
    Class superClass = nil;
    if([self isMemberOfClass:[NSObject class]]) {
        superClass = self.class;
    } else {
        superClass = self.superclass;
    }
    return [self propertiesDescriptionWithExtendClass:superClass];
}

// プロパティ情報一覧を取得
- (NSArray *)propertiesDescriptionWithExtendClass:(Class)class
{
    // 継承チェック
    if(![self isKindOfClass:class]) return nil;
    
    NSMutableArray *propertyList = @[].mutableCopy;
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    for(i = 0; i < outCount; i++) {
    	objc_property_t property = properties[i];
    	const char *propName = property_getName(property);
    	if(propName) {
    		const char *propType = _getPropertyType(property);
    		NSString *propertyName = [NSString stringWithUTF8String:propName];
    		NSString *propertyType = [NSString stringWithUTF8String:propType];
            if(propertyType == nil) propertyType = @"";
            [propertyList addObject:@{
                                      @"type" :propertyType,
                                      @"name" :propertyName,
                                      @"value":[self valueForKey:propertyName] ? [self valueForKey:propertyName] : [NSNull null]
                                      }];
    	}
    }
    free(properties);
    
    return propertyList;
}

// プロパティ名一覧を取得
+ (NSArray *)propertyNames
{
    NSMutableArray *propertyNames = [[NSMutableArray alloc] init];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(self.class, &outCount);
    for(i = 0; i < outCount; i++) {
    	objc_property_t property = properties[i];
    	const char *propName = property_getName(property);
    	if(propName) {
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            [propertyNames addObject:propertyName];
    	}
    }
    free(properties);
    
    return propertyNames;
}

#pragma mark - Accessor

// プロパティ情報一覧を取得
- (NSArray *)propertiesDescription
{
    return [self propertiesDescriptionWithExtendClass:self.class];
}

// プロパティ名一覧を取得
- (NSArray *)propertyNames
{
    return [self.class propertyNames];
}

@end
