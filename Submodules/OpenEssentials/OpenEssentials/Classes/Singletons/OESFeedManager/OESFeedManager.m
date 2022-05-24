//
//  OESFeedManager.m
//  OpenEssentials
//
//  Created by Gregory Carter on 2/11/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import "OESFeedManager.h"
#import "OESDataController.h"

@interface OESFeedManager ()
@property (nonatomic, strong) NSMutableDictionary *localDataControllers;
@property (nonatomic, strong) NSMutableDictionary *globalDataControllers;
@end

@implementation OESFeedManager

#pragma mark - Class Methods

+ (NSString *)namespacedNameWithDataController:(OESDataController *)dataController name:(NSString *)name
{
    return [NSString stringWithFormat:@"%@:%@", NSStringFromClass([dataController class]), name];
}

#pragma mark - Initialization

OESSHARED_INSTANCE(OESFeedManager *)

#pragma mark - [NSObject Overrides]

- (void)dealloc
{
    self.localDataControllers = nil;
    self.globalDataControllers = nil;
}

#pragma mark - Pricate

- (NSString *)classNameForObject:(id)object
{
    return NSStringFromClass([object class]);
}

#pragma mark - Public
#pragma mark -- Local Data Controllers

- (BOOL)registerLocalDataController:(OESDataController *)dataController owner:(id)owner name:(NSString *)name
{
    NSMutableDictionary *dictionary = mutableDictionaryInDictionary([self classNameForObject:owner], self.localDataControllers);
   
    if (isNil(dictionary)) {
        NSMutableDictionary *dictionary = [NSMutableDictionary new];
        [dictionary setObject:dataController forKey:name];
        
        [self.localDataControllers setObject:dictionary forKey:[self classNameForObject:owner]];
        return YES;
    } // if

    OESDataController *foundDataController = [dictionary objectForKey:name];
    
    if (!isNil(foundDataController)) {
        OESLogWarn(@"DataController '%@' with name '%@' already exists for class '%@'", foundDataController, name, owner);
        return NO;
    } // if

    [dictionary setObject:dataController forKey:name];
    
    [dataController startLoadingFeed];
    
    return YES;
}

- (BOOL)unregisterLocalDataController:(NSString *)name owner:(id)owner
{
    NSMutableDictionary *dictionary = mutableDictionaryInDictionary([self classNameForObject:owner], self.localDataControllers);
    
    if (isNil(dictionary)) {
        OESLogWarn(@"Possible memory leak '%@' doesn't exist but tried to remove itself.", owner);
        return NO;
    } // if
    
    [dictionary removeObjectForKey:name];
    
    if (isEmpty(dictionary))
        [self unregisterLocalDataControllers:owner];

    return YES;
}

- (void)unregisterLocalDataControllers:(id)owner
{
    NSMutableDictionary *dictionary = mutableDictionaryInDictionary([self classNameForObject:owner], self.localDataControllers);
    
    if (isNil(dictionary)) {
        OESLogWarn(@"Possible memory leak '%@' doesn't exist but tried to remove itself.", owner);
        return;
    } // if

    [self.localDataControllers removeObjectForKey:[self classNameForObject:owner]];
}

#pragma mark -- Global Data Controllers

- (OESDataController *)registerGlobalDataController:(NSString *)controllerId object:(id)object;
{
    if (controllerId == nil) {
        OESLogWarn(@"Missing DataController");
        return nil;
    }
    
    NSArray *components = [controllerId componentsSeparatedByString:@":"];
    if ([components count] != 2) {
        OESLogWarn(@"Unable to parse controllerId: %@", controllerId);
        return nil;
    }
    
    NSString *className = components[0];
    Class dataControllerClass = NSClassFromString(className);
    if (dataControllerClass == nil) {
        OESLogWarn(@"Could not find DataController with id: %@", controllerId);
        return nil;
    }

    if (![dataControllerClass isSubclassOfClass:[OESDataController class]]) {
        OESLogWarn(@"DataController with id '%@' is not a subclass of %@", controllerId, NSStringFromClass([OESDataController class]));
        return nil;
    }

    OESDataController *dataController = [[dataControllerClass alloc] initWithObject:object];

    [self registerGlobalDataController:dataController name:components[1]];

    return dataController;
}


- (NSString *)registerGlobalDataController:(OESDataController *)dataController name:(NSString *)name
{
    NSString *controllerId = [OESFeedManager namespacedNameWithDataController:dataController name:name];
    OESDataController *foundDataController = [self.globalDataControllers objectForKey:controllerId];
    
    if (!isNil(foundDataController)) {
        OESLogWarn(@"Already have '%@' named '%@'", foundDataController, name);
        return nil;
    } // if

    [self.globalDataControllers setObject:dataController forKey:controllerId];

    [dataController startLoadingFeed];

    return controllerId;
}

- (BOOL)unregisterGlobalDataController:(NSString *)controllerId
{
    OESDataController *foundDataController = [self.globalDataControllers objectForKey:controllerId];

    if (isNil(foundDataController)) {
        OESLogWarn(@"DataController '%@' not found.", controllerId);
        return NO;
    } // if

    [self.globalDataControllers removeObjectForKey:controllerId];

    [foundDataController stopLoadingFeed];

    return YES;
}

- (NSArray *)registerGlobalDataControllers:(NSDictionary *)dataControllers
{
    if (dataControllers == nil) {
        return nil;
    }

    NSMutableArray *returnControllers = [NSMutableArray new];
    for(NSString *key in dataControllers) {
        id object = [dataControllers objectForKey:key];
        
        if ([object isEqual:[NSNull null]]) {
            object = nil;
        }
        
        OESDataController *dataController = [self registerGlobalDataController:key object:object];
        
        [returnControllers addObject:dataController];
    }

    return [NSArray arrayWithArray:returnControllers];
}

#pragma mark - [Accessor Overrides]

- (NSMutableDictionary *)localDataControllers
{
    return !isNil(_localDataControllers) ? _localDataControllers : (_localDataControllers = [NSMutableDictionary new]);
}

- (NSMutableDictionary *)globalDataControllers
{
    return !isNil(_globalDataControllers) ? _globalDataControllers : (_globalDataControllers = [NSMutableDictionary new]);
}

@end
