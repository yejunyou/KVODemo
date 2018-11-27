//
//  NSObject+KVO.m
//  KVODemo
//
//  Created by 叶俊有 on 2018/7/22.
//  Copyright © 2018年 Future Vision. All rights reserved.
//

#import "NSObject+KVO.h"
#import <objc/runtime.h>
#import <objc/message.h>


NSString *const _kYYKVONotifiying = @"YYKVONotifiying_";
NSString *const _kYYKVOAssociatedObservers = @"PGKVOAssociatedObservers";

#pragma mark - _YYObserverManager
@interface _YYObserverManager: NSObject
@property (nonatomic, weak) NSObject *observer; // 注意是weak
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) YYObservingBlock block;
@end

@implementation _YYObserverManager
- (instancetype)initWithObserver:(NSObject *)observer keyPath:(NSString *)keyPath block:(YYObservingBlock)block
{
    self = [super init];
    if (self) {
        _observer = observer;
        _keyPath = keyPath;
        _block = block;
    }
    return self;
}
@end

#pragma mark - NSObject (KVO)
@implementation NSObject (KVO)

// 从getter方法，获取setting方法
static NSString *setterForGetter(NSString *getter)
{
    if (getter.length <= 0) {
        return nil;
    }
    
    // 首字母转成大写
    NSString *upperLetter = [[getter substringToIndex:1] uppercaseString];
    NSString *lowerLetter = [getter substringFromIndex:1];
    NSString *setter = [NSString stringWithFormat:@"set%@%@:", upperLetter,lowerLetter];
    return setter;
}

// 从setting方法，获取getter方法
static NSString *getterForSetter(NSString *setter)
{
    if (setter.length <= 0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) {
        return nil;
    }

    // 获取 ‘set‘ 到 ’：‘之间的字符串(例如：setName: -> Name)
    NSRange range = NSMakeRange(3, setter.length - 4);
    NSString *getter = [setter substringWithRange:range];

    NSString *lowerLetter = [[getter substringToIndex:1] lowercaseString];
    NSString *leftLetter = [getter substringFromIndex:1];
    return [NSString stringWithFormat:@"%@%@",lowerLetter, leftLetter];
}


#pragma mark - Overridden Methods
/*
 这个方法完成了‘self’类的华丽转身：
 从 ‘self’ 转变成 ‘_kYYKVONotifiying_self’
 
 并且，当外界执行setter方法的时候，执行block回调
 */
static void kvo_setter(id self, SEL _cmd, id newValue)
{
    NSString *setterName = NSStringFromSelector(_cmd);
    NSString *getterName = getterForSetter(setterName);
    
    if (getterName == nil) {
        NSString *reason = [NSString stringWithFormat:@"%@ 木有 %@ 这个setter方法",self, setterName];
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:reason
                                     userInfo:nil];
    }
 
    
    id oldValue = [self valueForKey:getterName];
    
    struct objc_super super_clazz = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self)) // 注意区分：objc_getClass()
    };
    
    // cast our pointer so the compiler won't complain
    void (*objc_msgSendSuperCasted)(void *, SEL, id) = (void *)objc_msgSendSuper;
    
    // call super's setter, which is original class's setter method
    objc_msgSendSuperCasted(&super_clazz, _cmd, newValue);
    
    // 执行回调
    NSMutableArray *observers = objc_getAssociatedObject(self, (__bridge const void *)_kYYKVOAssociatedObservers);
    for (_YYObserverManager *mgr in observers){
        if ([mgr.keyPath isEqualToString:getterName]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                if (![oldValue isEqualToString:newValue]){
                    mgr.block(self, getterName, oldValue, newValue);
//                }
            });
        }
    }
}

static Class kvo_class(id self, SEL _cmd)
{
    return class_getSuperclass(object_getClass(self));
}

- (Class)makeKVOClassFromOriginalClassName:(NSString *)OriginClassName{
    NSString *kvoClassName = [_kYYKVONotifiying stringByAppendingString:OriginClassName];
    Class clazz = NSClassFromString(kvoClassName);
    
    if (clazz) return clazz;
    
    // clazz还没有创建，需要造一个
    Class originClazz = object_getClass(self);
    Class kvoClazz = objc_allocateClassPair(originClazz, kvoClassName.UTF8String, 0);
    
    // 获取类方法的签名
    Method clazzMethod = class_getInstanceMethod(originClazz, @selector(class));
    const char * types = method_getTypeEncoding(clazzMethod);
    class_addMethod(kvoClazz, @selector(class), (IMP)kvo_class, types);
    
    objc_registerClassPair(kvoClazz);
    
    return kvoClazz;
}

- (BOOL)_hasSelector:(SEL)selector
{   Class clazz = object_getClass(self);
    unsigned int methodCount = 0;
    Method *methodLists = class_copyMethodList(clazz, &methodCount);
    for (NSInteger i = 0; i < methodCount; i ++) {
        SEL thisSelector = method_getName(methodLists[i]);
        if (thisSelector == selector) {
            free(methodLists);
            return YES;
        }
    }
    free(methodLists);
    return NO;
}

#pragma mark - implementation
/*
 逻辑：
 检查对象的类有没有相应的 setter 方法。如果没有抛出异常；
 检查对象 isa 指向的类是不是一个 KVO 类。如果不是，新建一个继承原来类的子类，并把 isa 指向这个新建的子类；
 检查对象的 KVO 类重写过没有这个 setter 方法。如果没有，添加重写的 setter 方法；
 添加这个观察者
 */
- (void)yy_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath withBlock:(YYObservingBlock)block
{
    // 1: 检查对象的类有没有相应的 setter 方法，如果没有抛出异常
    SEL setterSelector = NSSelectorFromString(setterForGetter(keyPath));
    Method setterMethod = class_getInstanceMethod(self.class, setterSelector);
    if (!setterMethod) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"%@对象没有%@的setting方法！",self,keyPath]
                                     userInfo:nil];
    }
    
    Class clazz = object_getClass(self);
    NSString *clazzName = NSStringFromClass(clazz);
    
    // 2: 检查对象 isa 指向的类是不是一个 KVO 类
    if (![clazzName hasPrefix:_kYYKVONotifiying]) {
        // 如果不是，新建一个继承原来类的子类，并把 isa 指向这个新建的子类
        clazz = [self makeKVOClassFromOriginalClassName:clazzName];
        // 为儿子重新安排一个爹
        object_setClass(self, clazz);
    }
    
    // Step 3: 是否实现setter方法
    if (![self _hasSelector:setterSelector]) {
        const char *types = method_getTypeEncoding(setterMethod);
//        class_addMethod([self class], setterSelector, (IMP)kvo_setter, "v@:");
        class_addMethod(clazz, setterSelector, (IMP)kvo_setter, types);
    }
    
    // Step 4: 保存 key path 相关的观察者信息

    // objc_getAssociatedObject(self, &_kYYKVOAssociatedObservers);
    NSMutableArray *observers = objc_getAssociatedObject(self, (__bridge const void *)_kYYKVOAssociatedObservers);
    if (observers == nil) {
        observers = [NSMutableArray array];
        objc_setAssociatedObject(self, (__bridge const void *)_kYYKVOAssociatedObservers, observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    _YYObserverManager *mgr = [[_YYObserverManager alloc] initWithObserver:self keyPath:keyPath block:block];
    [observers addObject:mgr];
}

- (void)yy_removeObserver:(NSObject *)observer forKey:(id)keyPath
{
    _YYObserverManager *toBeRemoveMgr = nil;
    
    NSMutableArray *observers = objc_getAssociatedObject(self, (__bridge const void *)_kYYKVOAssociatedObservers);
    for (_YYObserverManager *mgr in observers) {
        if (mgr.observer == observer && [mgr.keyPath isEqualToString:keyPath]) {
            toBeRemoveMgr = mgr;
            break;
        }
    }
    
    [observers removeObject:toBeRemoveMgr];
}
@end
