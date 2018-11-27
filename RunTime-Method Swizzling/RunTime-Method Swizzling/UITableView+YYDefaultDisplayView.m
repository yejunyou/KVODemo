//
//  UITableView+YYDefaultDisplayView.m
//  RunTime-Method Swizzling
//
//  Created by yejunyou on 2018/11/27.
//  Copyright © 2018 FetureVersion. All rights reserved.
//

#import "UITableView+YYDefaultDisplayView.h"
#import <objc/runtime.h>

@implementation UITableView (YYDefaultDisplayView)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originMethod = class_getInstanceMethod(self, @selector(reloadData));
        Method swizzlingMethod = class_getInstanceMethod(self, @selector(yy_reloadData));
        
        method_exchangeImplementations(originMethod, swizzlingMethod);
    });
}

- (void)yy_reloadData{
    // yy_reloadData实际指向reloadData，相当于先i调用一下系统的方法
    [self yy_reloadData];
    
    // 这里添加我们想要做的事情
    [self showDefaultVeiw];
}

- (void)showDefaultVeiw{
    id<UITableViewDataSource> dataSource = self.dataSource;
    NSInteger section = [dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)] ? [dataSource numberOfSectionsInTableView:self] : 1;
    NSInteger row = 0;
    for (NSInteger i= 0; i < section; i ++) {
        row = [dataSource tableView:self numberOfRowsInSection:section];
    }
    
    if (row == 0) {
        self.nodataTipsView = [[UILabel alloc] init];
        self.nodataTipsView.text  = @"暂时无数据，再刷新试试？";
        self.nodataTipsView.backgroundColor = UIColor.yellowColor;
        self.nodataTipsView.textAlignment = NSTextAlignmentCenter;
        self.nodataTipsView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:self.nodataTipsView];
    }else{
        self.nodataTipsView.hidden = YES;
    }
}

#pragma mark - getting && setting
- (void)setNodataTipsView:(UILabel *)nodataTipsView
{
    objc_setAssociatedObject(self, @selector(nodataTipsView), nodataTipsView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UILabel *)nodataTipsView
{
    return objc_getAssociatedObject(self, _cmd);
}

@end
