//
//  ViewController.m
//  Runtime-字典模型互换
//
//  Created by yejunyou on 2018/11/27.
//  Copyright © 2018 FetureVersion. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *dic = @{@"name": @"iO骨灰级菜鸟", @"age": @(18)};
    Person *p = [[Person alloc] initWithDictionary:dic];
    
    NSLog(@"name: %@  age:%@",p.name, p.age);
    
    NSDictionary *dic2 = [p convertModelToDictionary];
    NSLog(@"dic2:%@",dic2);
}


@end
