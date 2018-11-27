//
//  ViewController.m
//  RunTime-消息转发
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
    
    [[Person new] yy_sendMessage:@"yy_msg"];
}


@end
