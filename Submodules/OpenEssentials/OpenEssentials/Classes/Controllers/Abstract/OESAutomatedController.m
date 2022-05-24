//
//  OESAutomatedController.m
//  OpenEssentials
//
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import "OESAutomatedController.h"
#import "OESFeedManager.h"

@interface OESAutomatedController ()
@property (nonatomic, strong) NSArray *forwardInvokedControllers;
@property (nonatomic, assign, getter = isAlreadyListeningToNotifications) BOOL alreadyListeningToNotifications;
@end

@implementation OESAutomatedController

#pragma mark - Public
#pragma mark -- Abstract


- (void)start
{
    OES_THROW_PUREABSTRACT
}

- (void)stop
{
    OES_THROW_PUREABSTRACT
}

- (id)delegateForFowardInvokedController
{
    OES_THROW_PUREABSTRACT
}

#pragma mark -- Forward Invoked Controllers

- (NSArray *)forwardInvokedControllerKeys
{
    return nil;
}

- (id)forwardInvokedControllerNamed:(NSString *)name
{
    __block id foundController =  nil;
    
    [self.forwardInvokedControllers enumerateObjectsUsingBlock:^(id controller, NSUInteger idx, BOOL *stop) {
        NSString *controllerName = NSStringFromClass([controller class]);
        
        BOOL isMatch = [name isEqualToString:controllerName];
        if (!isMatch) {
            return;
        }
        
        foundController = controller;
        *stop = YES;
    }];
    
    return foundController;
}

#pragma mark -- Notifications

- (NSDictionary *)notificationListenerKeys
{
    // Dictionary format: <notificationName>: <selectorString>
    return nil;
}

- (void)startListeningForNotifications
{
    if (self.isAlreadyListeningToNotifications)
        return;

    self.alreadyListeningToNotifications = YES;

    NSDictionary *notificationKeys = [self notificationListenerKeys];

    if (notificationKeys == nil) {
        return;
    }

    [[NSNotificationCenter defaultCenter] oesAddObserver:self forKeys:notificationKeys];
}

- (void)stopListeningForNotifications
{
    self.alreadyListeningToNotifications = NO;
    
    NSDictionary *notificationKeys = [self notificationListenerKeys];

    if (notificationKeys == nil) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] oesRemoveObserver:self forKeys:notificationKeys];
}

#pragma mark -- Data Controllers

- (NSDictionary *)dataControllerKeys
{
    return nil;
}

- (void)startDataControllers
{
    NSDictionary *dataControllerKeys = [self dataControllerKeys];
    
    if (dataControllerKeys == nil) {
        return;
    }

        
    [[OESFeedManager sharedInstance] registerGlobalDataControllers:dataControllerKeys];
}

- (void)stopDataControllers
{
    NSDictionary *dataControllerKeys = [self dataControllerKeys];
    
    if (dataControllerKeys == nil) {
        return;
    }

    for(NSString *key in dataControllerKeys) {
        [[OESFeedManager sharedInstance] unregisterGlobalDataController:key];
    }
}

#pragma mark - Private
#pragma mark -- Forward Invoked Controllers

- (id)forwardInvokedControllerWithSelector:(SEL)selector
{
    for (id object in self.forwardInvokedControllers) {
        BOOL respondsToSelector = [object respondsToSelector:selector];
        if (!respondsToSelector) {
            continue;
        }

        return object;
    }

    return nil;
}

#pragma mark - [NSObject Overrides]

- (void)dealloc
{
    [self stop];
}

#pragma mark -- Forward Invocations

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    id object = [self forwardInvokedControllerWithSelector:anInvocation.selector];
    
    if (object != nil) {
        [anInvocation invokeWithTarget:object];
        return;
    }
    
    [super forwardInvocation:anInvocation];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    id object = [self forwardInvokedControllerWithSelector:aSelector];
    
    if (object != nil) {
        return YES;
    }

    return [super respondsToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];

    if (!signature) {
        id object = [self forwardInvokedControllerWithSelector:selector];
    
        if (object != nil) {
            signature = [object methodSignatureForSelector:selector];
        }
    }
   
    return signature;
}

- (BOOL)conformsToProtocol:(Protocol *)protocol
{
    for (id object in self.forwardInvokedControllers) {
        BOOL conformsToProtocol = [object conformsToProtocol:protocol];
        if (!conformsToProtocol) {
            continue;
        }

        return YES;
    }

    return [super conformsToProtocol:protocol];
}

#pragma mark - [Accessor Overrides]

- (NSArray *)forwardInvokedControllers
{
    if (_forwardInvokedControllers != nil) {
        return _forwardInvokedControllers;
    }

    NSArray *controllerNames = [self forwardInvokedControllerKeys];

    if (controllerNames == nil) {
        return nil;
    }

    NSMutableArray *controllers = [NSMutableArray new];
    for (NSString *controllerName in controllerNames) {
        BOOL isValid = isString(controllerName);
        if (!isValid) {
            OESLogEmerg(@"Controller name is not a string: %@", controllerName);
            continue;
        }

        Class controllerClass = NSClassFromString(controllerName);
        if (controllerClass == nil) {
            OESLogEmerg(@"Controller class does not exist: %@", controllerName);
            continue;
        }

        BOOL conformsToProtocol = [controllerClass conformsToProtocol:@protocol(OESAutomatedFowardInvokedController)];
        if (!conformsToProtocol) {
            OESLogEmerg(@"Controller class does not conform to forward invoked controller exist: %@", controllerName);
            continue;
        }

        id controller = [controllerClass new];
        id delegate = [self delegateForFowardInvokedController];
        
        BOOL respondsToSelector = [controller respondsToSelector:@selector(setDelegateForFowardInvokedController:)];
        if (!respondsToSelector) {
            OESLogEmerg(@"Controller class does not respond to setDelegateForFowardInvokedController method: %@", controllerName);
            continue;
        }

        [controller setDelegateForFowardInvokedController:delegate];

        [controllers addObject:controller];
    }

    return _forwardInvokedControllers = [NSArray arrayWithArray:controllers];
}

@end
