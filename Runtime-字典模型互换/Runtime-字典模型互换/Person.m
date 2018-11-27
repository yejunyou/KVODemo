//
//  Person.m
//  Runtime-字典模型互换
//
//  Created by yejunyou on 2018/11/27.
//  Copyright © 2018 FetureVersion. All rights reserved.
//

#import "Person.h"
#import <objc/message.h>

@implementation Person

- (instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        for (NSString *key in dictionary.allKeys) {
            
            // 通过key构建set方法
            NSString *methodName = [NSString stringWithFormat:@"set%@:",key.capitalizedString];
            SEL sel = NSSelectorFromString(methodName);
            if (sel) {
                /*
                 指针函数的形式：
                 returnType (*functionName) (param1, param2, ...)
                 void (*)(id, SEL, id)
                 
                 使用指针调用函数：
                 (returnType (*functionName) (param1, param2, ...))
                 */
                
                NSString *value = dictionary[key];
                ((void (*)(id, SEL, id))objc_msgSend)(self, sel, value);
            }
        }
    }
    return self;
}


- (NSDictionary *)convertModelToDictionary{
    
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(self.class, &count);
    
    if (count == 0) {
        free(properties);
        return nil;
    }
    
    NSMutableDictionary *dic = NSMutableDictionary.dictionary;
    for (int i = 0; i < count; i ++) {
        const char *propertyName = property_getName(properties[i]);
        NSString *name = [NSString stringWithUTF8String:propertyName];
        SEL sel = NSSelectorFromString(name);
        if (sel) {
            // 通过get方法获取value
            NSString *value =  ((id (*)(id, SEL))objc_msgSend)(self, sel);
            
            if (value) {
                dic[name] = value;
            }else{
                dic[name] = @"";
            }
        }
    }
    
    // 释放
    free(properties);
    return dic;
}
@end
