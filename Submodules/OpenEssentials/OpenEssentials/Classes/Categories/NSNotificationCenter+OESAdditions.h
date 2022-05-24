//
//  NSNotificationCenter+OESAdditions.h
//  OpenEssentials
//
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (OESAdditions)
- (void)oesAddObserver:(id)observer forKeys:(NSDictionary *)notificationKeys;
- (void)oesRemoveObserver:(id)observer forKeys:(id)notificationKeys;
@end
