//
//  OESActivityIndicatorManager.m
//  OpenEssentials
//
//  Created by Gregory Carter on 3/7/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OESActivityIndicatorManager.h"

@interface OESActivityIndicatorManager ()
@property (nonatomic, assign) NSUInteger activityCounter;
@end

@implementation OESActivityIndicatorManager

OESSHARED_INSTANCE(OESActivityIndicatorManager *)

- (void)networkActivityStarted
{
    @synchronized(self) {
        ++self.activityCounter;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    } // @synchronized
}

- (void)networkActivityStopped
{
    @synchronized(self) {
        if (self.activityCounter < 1)
            return;
    
        --self.activityCounter;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } // @synchronized
}

@end
