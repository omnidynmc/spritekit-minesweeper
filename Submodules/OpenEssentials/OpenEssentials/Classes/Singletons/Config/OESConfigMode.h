//
//  OESConfigMode.h
//  OESShared
//
//  Created by Gregory Carter on 8/31/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OESConfigObject.h"

@class OESConfigFeature;
@class OESConfigEndpoint;

@interface OESConfigMode : OESConfigObject
@property (nonatomic, strong) NSMutableDictionary *features;
@property (nonatomic, strong) NSMutableDictionary *endpoints;
@property (nonatomic, assign) BOOL inheritFeatures;
@property (nonatomic, assign) BOOL inheritEndpoints;

// Public
// -- Inheritence
- (void)inheritFromConfigMode:(OESConfigMode *)configMode;

// -- Feature Accessors
- (OESConfigFeature *)fetchFeatureByName:(NSString *)name;
- (BOOL)isFeatureEnabled:(NSString *)name default:(BOOL)defaultValue;
- (BOOL)isFeatureEnabled:(NSString *)name;

// -- Endpoint Accessors
- (OESConfigEndpoint *)fetchEndpointByName:(NSString *)name;
- (NSString *)urlForEndpoint:(NSString *)name default:(NSString *)defaultValue;
- (NSTimeInterval)refreshIntervalForEndpoint:(NSString *)name default:(NSTimeInterval)defaultInterval;
- (NSString *)urlForEndpoint:(NSString *)name;
@end
