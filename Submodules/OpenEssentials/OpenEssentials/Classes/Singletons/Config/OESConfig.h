//
//  OESConfig.h
//  OESShared
//
//  Created by Gregory Carter on 9/10/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OESConfigParserDelegate.h"
#import "OESSharedInstance.h"

@class OESConfigParser;
@class OESConfigVariableParser;
@class OESConfigMode;
@class OESConfigApp;
@class OESConfigEndpoint;
@class OESConfigManager;
@class OESConfigFeature;

@interface OESConfig : NSObject <OESConfigParserDelegate>

@property (nonatomic, strong) OESConfigParser *configParser;
@property (nonatomic, strong) OESConfigParser *incomingConfigParser;
@property (nonatomic, strong) NSArray *forDevices;

// Initializers
OESSHARED_INSTANCE_H(id)

// Load
- (BOOL)loadConfigs:(NSDictionary *)loadFiles enqueue:(BOOL)enqueue error:(NSError **)error;
- (OESConfigVariableParser *)validators;
- (void)loadConfigsDidFinish:(BOOL)wasLoaded;
- (void)updateInternalConfig;

// Abstract
- (OESConfigParser *)createNewConfigParser;

// ConfigApp Accessors
- (NSNumber *)minimumVersion;
- (NSNumber *)latestVersion;
- (BOOL)isAppMinimumVersion;
- (BOOL)isAppLatestVersion;

// ConfigParser Accessors
- (OESConfigMode *)currentMode;
- (OESConfigApp *)currentApp;
- (NSString *)currentAppmode;

// ConfigMode Accessors
- (OESConfigFeature *)fetchFeatureByName:(NSString *)name;
- (OESConfigEndpoint *)fetchEndpointByName:(NSString *)name;
- (NSString *)fetchEndpointUrlStringByName:(NSString *)name;
- (NSURL *)fetchEndpointUrlByName:(NSString *)name;
- (NSURL *)fetchEndpointUrlByName:(NSString *)name substitutions:(NSDictionary *)substitutions;
- (NSURL *)performSubstitutionsOnUrlString:(NSString *)urlString substitutions:(NSDictionary *)substitutions;

- (NSDate *)currentDate;

@end
