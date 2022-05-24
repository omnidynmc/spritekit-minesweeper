//
//  OESAutomatedController.h
//  OpenEssentials
//
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OESAutomatedFowardInvokedController <NSObject>
@optional
- (id)delegateForFowardInvokedController;
- (void)setDelegateForFowardInvokedController:(id)delegate;
@end

@interface OESAutomatedController : NSObject
// Abstract
- (void)start;
- (void)stop;

// -- Notifications
- (void)startListeningForNotifications;
- (void)stopListeningForNotifications;
- (NSDictionary *)notificationListenerKeys;

// -- Data Controllers
- (void)startDataControllers;
- (void)stopDataControllers;
- (NSDictionary *)dataControllerKeys;

// -- Forward Invoked Controllers
- (NSArray *)forwardInvokedControllerKeys;              // override to list controllers to be started up with 'new' automatically
- (NSArray *)forwardInvokedControllers;                 // override to provide your own initialized controller array
- (id)forwardInvokedControllerNamed:(NSString *)name;   // find a forward invoked controller by class name
- (id)delegateForFowardInvokedController;
@end
