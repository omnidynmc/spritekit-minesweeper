//
//  OESConfigParser.h
//  OESShared
//
//  Created by Gregory Carter on 9/4/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import "OESConfigParserAbstract.h"

@class OESConfigApp;
@class OESConfigMode;
@class OESConfigVariableParser;
@class OESConfigDebug;

@interface OESConfigParser : OESConfigParserAbstract
@property (nonatomic, strong) OESConfigApp *app;
@property (nonatomic, strong) NSString *appmode;
@property (nonatomic, strong) OESConfigDebug *debug;
@property (nonatomic, strong) OESConfigMode *currentMode;
@property (nonatomic, strong) OESConfigVariableParser *variables;
@property (nonatomic, strong) NSDictionary *substitutions;
@property (nonatomic, strong) NSMutableDictionary *userInfo;

- (BOOL)loadConfigs:(NSDictionary *)loadFiles error:(NSError **)error;

// Overrides
- (OESConfigMode *)createNewMode:(NSDictionary *)dictionary mode:(NSString *)mode error:(NSError **)error;
- (OESConfigDebug *)createNewDebug:(NSDictionary *)dictionary name:(NSString *)name error:(NSError **)error;
@end
