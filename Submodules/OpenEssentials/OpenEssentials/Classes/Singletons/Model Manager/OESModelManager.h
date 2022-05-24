//
//  OESModelManager.h
//  OpenEssentials
//
//  Created by Gregory Carter on 10/13/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "OESSharedInstance.h"

extern NSString *const OESModelManagerPersistentStoreCoordinatorCreatedNotification;
extern NSString *const OESModelManagerDidMergeiCloudChangesNotification;

@interface OESModelManager : NSObject
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectContext *concurrentManagedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// Initializers
OESSHARED_INSTANCE_H(OESModelManager *)
//Public
- (BOOL)saveContext;

// Abstract Methods
- (NSString *)modelFile;
- (NSURL *)modelUrl;
- (void)persistentStoreCoordinatorCreated;
// -- iCloud
- (NSString *)iCloudDataDirectory;
- (NSString *)iCloudLogDirectory;
- (NSString *)iCloudAppId;
- (void)didMergeiCloudChanges;
@end
