//
//  OESFeedManager.h
//  OpenEssentials
//
//  Created by Gregory Carter on 2/11/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OESDataController;

@interface OESFeedManager : NSObject
// Initialization
OESSHARED_INSTANCE_H(OESFeedManager *)

// Public
// -- Local Data Controllers
- (BOOL)registerLocalDataController:(OESDataController *)dataController owner:(id)owner name:(NSString *)name;
- (BOOL)unregisterLocalDataController:(NSString *)name owner:(id)owner;
- (void)unregisterLocalDataControllers:(id)owner;
// -- Global Data Controllers
- (OESDataController *)registerGlobalDataController:(NSString *)controllerId object:(id)object;
- (NSString *)registerGlobalDataController:(OESDataController *)dataController name:(NSString *)name;   // returns
- (NSArray *)registerGlobalDataControllers:(NSDictionary *)dataControllers;
- (BOOL)unregisterGlobalDataController:(NSString *)controllerId;
@end
