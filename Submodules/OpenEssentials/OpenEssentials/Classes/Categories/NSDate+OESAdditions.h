//
//  NSDate+OESAdditions.h
//  OpenEssentials
//
//  Created by Gregory Carter on 2/28/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (OESAdditions)
- (NSString *)dateElapsedFromNow;
+ (NSString *)oesTimeSinceUnixtime:(NSTimeInterval)unixtime fromNow:(BOOL)fromNow limit:(NSUInteger)limit;
@end
