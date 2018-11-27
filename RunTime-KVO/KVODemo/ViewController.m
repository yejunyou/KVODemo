//
//  ViewController.m
//  KVODemo
//
//  Created by 叶俊有 on 2018/7/22.
//  Copyright © 2018年 Future Vision. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"

@interface ViewController ()
@property (nonatomic, strong) Person *p;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _p = [[Person alloc] init];
    
    // 控制器观察person的name
    [_p addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    _p.name = @"yy";
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"%@",keyPath);
    NSLog(@"%@",object);
    NSLog(@"%@",change);
    
    if ([keyPath isEqualToString:@"name"]) {
        // todo xxx
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"----华丽的分割线----");
//    _p.name = @"xx";
    [_p setValue:@"zz" forKey:@"name"];
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    static NSInteger i = 0;
//    if (i++ % 2 == 0) {
//        [self presentViewController:[[ViewController alloc] init] animated:YES completion:nil];
//    }else{
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
//}

@end
