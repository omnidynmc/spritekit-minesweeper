//
//  NSObject+OESStatefulObjects.h
//  OpenEssentials
//
//  Created by Gregory Carter on 6/21/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^OESStatefulObjectHandler)(__weak id);

@interface NSObject (OESStatefulObjects)
@property (copy, nonatomic) NSString    *shiftState;
- (void)on:(NSString *)state do:(OESStatefulObjectHandler)block;
- (void)before:(NSString *)state do:(OESStatefulObjectHandler)block;
- (void)after:(NSString *)state do:(OESStatefulObjectHandler)block;
- (void)when:(NSString *)state transitionsTo:(NSString *)toState do:(OESStatefulObjectHandler)block;
- (void)when:(NSString *)state transitionsFrom:(NSString *)fromState do:(OESStatefulObjectHandler)block;
@end
