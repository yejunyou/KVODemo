//
//  NSObject+KVO.h
//  KVODemo
//
//  Created by 叶俊有 on 2018/7/22.
//  Copyright © 2018年 Future Vision. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^YYObservingBlock)(id observedObject, NSString *observedKey, id oldValue, id newValue);

@interface NSObject (KVO)

- (void)yy_addObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
             withBlock:(YYObservingBlock)block;

- (void)yy_removeObserver:(NSObject *)observer forKey:(NSString *)keyPath;

@end
