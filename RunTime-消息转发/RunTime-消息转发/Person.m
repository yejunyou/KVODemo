//
//  Person.m
//  RunTime-消息转发
//
//  Created by yejunyou on 2018/11/27.
//  Copyright © 2018 FetureVersion. All rights reserved.
//

#import "Person.h"
#import "Car.h"
#import <objc/runtime.h>

@implementation Person

void yy_sendMessage(id self, SEL _cmd, NSString *msg)
{
    NSLog(@"Person--%@",msg);
}

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    NSString *methodName = NSStringFromSelector(sel);
    if ([methodName isEqualToString:@"yy_sendMessage:"]) {
        BOOL flag = class_addMethod(self, sel, (IMP)yy_sendMessage, "v@:@");
        return flag;
    }
    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSString *methodName = NSStringFromSelector(aSelector);
    if ([methodName isEqualToString:@"yy_sendMessage:"]) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    }
    return [super methodSignatureForSelector:aSelector];
}
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return nil;
}



- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    SEL sel = anInvocation.selector;
    Car *car = [Car new];
    if ([car respondsToSelector:sel]) {
        [anInvocation invokeWithTarget:car];
    }else{
        [super forwardInvocation:anInvocation];
    }
}

- (void)doesNotRecognizeSelector:(SEL)aSelector
{
    NSLog(@"找不到方法，app继续运行");
}
@end
