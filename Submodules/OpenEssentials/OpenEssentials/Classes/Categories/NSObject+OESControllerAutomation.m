//
//  NSObject+OESControllerAutomation.m
//  OpenEssentials
//
//  Created by Gregory Carter on 5/10/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import <objc/runtime.h>

#import "NSObject+OESControllerAutomation.h"
#import "NSNotificationCenter+OESAdditions.h"
#import "OESFeedManager.h"

static char *const OESControllerAutomationForwardInvokedControllersKey = "OESControllerAutomationForwardInvokedControllersKey";

@implementation NSObject (OESControllerAutomation)

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
    NSDictionary *notificationKeys = [self notificationListenerKeys];

    if (notificationKeys == nil) {
        return;
    }

    [[NSNotificationCenter defaultCenter] oesAddObserver:self forKeys:notificationKeys];
}

- (void)stopListeningForNotifications
{
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

#pragma mark - [Accessor Overrides]

- (NSArray *)forwardInvokedControllers
{
    NSArray *forwardInvokedControllers = [self forwardInvokedControllers];
    if (forwardInvokedControllers != nil) {
        return forwardInvokedControllers;
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

        id controller = [controllerClass new];

        @try {
            id delegate = [self valueForKey:@"delegate"];
            [controller setValue:delegate forKey:@"delegate"];
        }
        @catch(NSException *exception) {
            // ignore exception if delegate doesn't exist or can't be set
        }

        [controllers addObject:controller];
    }

    [self setForwardInvokedControllers:[NSArray arrayWithArray:controllers]];
    
    return [self forwardInvokedControllers];
}

#pragma mark - [Mutator Overrides]

- (void)setForwardInvokedControllers:(NSArray *)forwardInvokedControllers
{
    objc_setAssociatedObject(self, OESControllerAutomationForwardInvokedControllersKey, forwardInvokedControllers, OBJC_ASSOCIATION_COPY);
}

@end