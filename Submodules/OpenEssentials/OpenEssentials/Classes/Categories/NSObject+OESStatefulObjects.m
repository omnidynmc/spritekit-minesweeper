//
//  NSObject+OESStatefulObjects.m
//  OpenEssentials
//
//  Created by Gregory Carter on 6/21/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import <objc/runtime.h>

#import "NSObject+OESStatefulObjects.h"

@interface NSObject ()
@property (strong, nonatomic) NSMutableDictionary *stateBlocks;
@end

@implementation NSObject (OESStatefulObjects)

static const char *ShiftStateIdentifier         = "shift_state_identifier";
static const char *ShiftStateBlocksIdentifier   = "shift_state_blocks_identifier";

static NSString *const ShiftOnKey       = @"ShiftOnKey";
static NSString *const ShiftBeforeKey   = @"ShiftBeforeKey";
static NSString *const ShiftAfterKey    = @"ShiftAfterKey";
static NSString *const ShiftToKey       = @"ShiftToKey";
static NSString *const ShiftFromKey     = @"ShiftFromKey";

- (void)setShiftState:(NSString *)shiftState
{
    __weak typeof(self) this = self;
    
    NSString *selfState = (NSString *)objc_getAssociatedObject(self, ShiftStateIdentifier);

    if(self.stateBlocks[ShiftToKey])
    {
        NSString *toState       = self.stateBlocks[ShiftToKey][@"to"];
        NSString *fromState     = self.stateBlocks[ShiftToKey][@"from"];
        OESStatefulObjectHandler block        = self.stateBlocks[ShiftToKey][@"block"];
        
        if([fromState isEqualToString:selfState] && [shiftState isEqualToString:toState])
            block(this);
    }
    
    if(self.stateBlocks[ShiftBeforeKey])
        ((OESStatefulObjectHandler)self.stateBlocks[ShiftBeforeKey])(this);
    
    objc_setAssociatedObject(self, ShiftStateIdentifier, shiftState, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if(self.stateBlocks[ShiftOnKey])
        ((OESStatefulObjectHandler)self.stateBlocks[ShiftOnKey])(this);

    if(self.stateBlocks[ShiftAfterKey])
        ((OESStatefulObjectHandler)self.stateBlocks[ShiftAfterKey])(this);

    if(self.stateBlocks[ShiftFromKey])
    {
        NSString *toState = self.stateBlocks[ShiftToKey][@"to"];
        NSString *fromState = self.stateBlocks[ShiftToKey][@"from"];
        OESStatefulObjectHandler block = self.stateBlocks[ShiftToKey][@"block"];
        
        if([toState isEqualToString:selfState] && [shiftState isEqualToString:fromState])
            block(this);
    }
}

- (NSString *)shiftState
{
    return (NSString *)objc_getAssociatedObject(self, ShiftStateIdentifier);
}

- (void)setStateBlocks:(NSMutableDictionary *)stateBlocks
{
    objc_setAssociatedObject(self, ShiftStateBlocksIdentifier, stateBlocks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)stateBlocks
{
    NSMutableDictionary *dict = (NSMutableDictionary *)objc_getAssociatedObject(self, ShiftStateBlocksIdentifier);

    if(dict)
        return dict;
    
    dict = [[NSMutableDictionary alloc] init];
    [self setStateBlocks:dict];
    
    return self.stateBlocks;
}

- (void)on:(NSString *)state do:(OESStatefulObjectHandler)block
{
    self.stateBlocks[ShiftOnKey] = block;
}

- (void)before:(NSString *)state do:(OESStatefulObjectHandler)block
{
    self.stateBlocks[ShiftBeforeKey] = block;
}

- (void)after:(NSString *)state do:(OESStatefulObjectHandler)block
{
    self.stateBlocks[ShiftBeforeKey] = block;
}

- (void)when:(NSString *)state transitionsTo:(NSString *)toState do:(OESStatefulObjectHandler)block
{
    self.stateBlocks[ShiftToKey] = @{@"to": toState, @"from": state, @"block": block};
}

- (void)when:(NSString *)state transitionsFrom:(NSString *)fromState do:(OESStatefulObjectHandler)block
{
    self.stateBlocks[ShiftFromKey] = @{@"to": state, @"from": fromState, @"block": block};
}

@end
