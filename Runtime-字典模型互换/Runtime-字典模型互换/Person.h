//
//  Person.h
//  Runtime-字典模型互换
//
//  Created by yejunyou on 2018/11/27.
//  Copyright © 2018 FetureVersion. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age; 

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)convertModelToDictionary;

@end

NS_ASSUME_NONNULL_END
