//
//  UITableView+YYDefaultDisplayView.h
//  RunTime-Method Swizzling
//
//  Created by yejunyou on 2018/11/27.
//  Copyright © 2018 FetureVersion. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (YYDefaultDisplayView)
@property (nonatomic, strong) UILabel *nodataTipsView; 
@end

NS_ASSUME_NONNULL_END
