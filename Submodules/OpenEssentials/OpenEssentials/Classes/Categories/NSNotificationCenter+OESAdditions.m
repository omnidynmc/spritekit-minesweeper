//
//  OESAdditions.m
//  OpenEssentials
//
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import "NSNotificationCenter+OESAdditions.h"
#import "NSDictionary+OESAdditions.h"

@implementation NSNotificationCenter (OESAdditions)

// NSDictionary format <keyString>: <selectorString>
- (void)oesAddObserver:(id)observer forKeys:(NSDictionary *)notificationKeys
{
    BOOL isValidKey = notificationKeys != nil && [notificationKeys isKindOfClass:[NSDictionary class]];

    if (!isValidKey) {
        return;
    }

    for(NSString *key in notificationKeys) {
        NSString *selectorString = [notificationKeys stringForKey:key];
        
        BOOL isValidSelector = selectorString == nil;
        if (isValidSelector) {
            OESLogError(@"Could not find selector '%@' from string for notificationKey '%@'", selectorString, key);
            continue;
        }

        SEL selector = NSSelectorFromString(selectorString);

        if (![observer respondsToSelector:selector]) {
            OESLogError(@"Model controller %@ does not respond to selector %@", NSStringFromClass([observer class]), selectorString);
            continue;
        }

        [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:key object:nil];
    }
}

- (void)oesRemoveObserver:(id)observer forKeys:(id)notificationKeys
{
    if (notificationKeys == nil)
        return;

    NSArray *keys;

    BOOL isDictionary = [notificationKeys isKindOfClass:[NSDictionary class]];
    BOOL isArray = [notificationKeys isKindOfClass:[NSDictionary class]];

    if (isDictionary)
        keys = [notificationKeys allKeys];
    else if (isArray)
        keys = notificationKeys;
    else
        return;

    for(NSString *key in keys) {
        if (![key isKindOfClass:[NSString class]])
            continue;

        [[NSNotificationCenter defaultCenter] removeObserver:observer name:key object:nil];
    }
}

@end
