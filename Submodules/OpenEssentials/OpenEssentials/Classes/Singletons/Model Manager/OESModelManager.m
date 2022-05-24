//
//  OESModelManager.m
//  OpenEssentials
//
//  Created by Gregory Carter on 10/13/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import "OESModelManager.h"

NSString *const OESModelManagerPersistentStoreCoordinatorCreatedNotification = @"OESModelManagerPersistentStoreCoordinatorCreatedNotification";
NSString *const OESModelManagerDidMergeiCloudChangesNotification = @"OESModelManagerDidMergeiCloudChangesNotification";

@interface OESModelManager ()
@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *concurrentManagedObjectContext;
@property (nonatomic, strong, readwrite) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation OESModelManager

#pragma mark - Shared Instance Setup

OESSHARED_INSTANCE(OESModelManager *)

- (void)dealloc
{
    [self stopListeningForNotifications];
}

#pragma mark - Public

- (BOOL)saveContext
{
    BOOL isPersistentStoreSetup = self.persistentStoreCoordinator.persistentStores.count > 0;
    if (!isPersistentStoreSetup)
        return NO;

    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
    if (isNil(managedObjectContext))
        return NO;
    
    BOOL shouldSave = [managedObjectContext hasChanges];
    if (shouldSave == NO)
        return NO;
    
    NSError *error = nil;
    BOOL wasSavedOK = [managedObjectContext save:&error];
    if (wasSavedOK == NO) {
        OESLogError(@"Could not save managedObjectContext: %@", error);
        return NO;
    } // if

    OESLogInfo(@"Saved in context: %@", managedObjectContext);

    return YES;
}

#pragma mark - Private

- (void)startListeningForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self.managedObjectContext selector:@selector(mergeChangesFromContextDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeiCloudChanges:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:self.persistentStoreCoordinator];
}

- (void)stopListeningForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.managedObjectContext];
}

- (NSString *)persistentStoreContainerDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

- (BOOL)createDirectoryWithPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL doesDirectoryExist = [fileManager fileExistsAtPath:path];
    
    OESLogInfo(@"Does directory '%@' exist? %@", path, boolAsString(doesDirectoryExist));
    
    if (!doesDirectoryExist) {
        OESLogInfo(@"Creating directory: %@", path);
        
        NSError *error = nil;
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];

        if (error != nil) {
            OESLogError(@"Error creating directory '%@': %@", path, error);
            return NO;
        }
    }

    return YES;
}

- (BOOL)addLocalPersistentStoreToPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    NSURL *storeURL = [[NSURL fileURLWithPath:[self persistentStoreContainerDirectory]] URLByAppendingPathComponent:[self modelFile]];

    [persistentStoreCoordinator lock];
    NSError *error = nil;
    BOOL wasPersistentStoreAdded = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error] != nil ? YES : NO;
    [persistentStoreCoordinator unlock];
    
    if (!wasPersistentStoreAdded) {
        persistentStoreCoordinator = nil;
        OESLogError(@"Could not create persistent store coordinator: %@", error);
        return NO;
    } // if
    
    return YES;
}

- (BOOL)addCloudPersistentStoreToPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator url:(NSURL *)url
{
    BOOL isDataDirectoryValid = [self createDirectoryWithPath:[[url path] stringByAppendingPathComponent:self.iCloudDataDirectory]];
    if (!isDataDirectoryValid)
        return NO;

    BOOL isLogsDirectoryValid = [self createDirectoryWithPath:[[url path] stringByAppendingPathComponent:self.iCloudLogDirectory]];
    if (!isLogsDirectoryValid)
        return NO;
 
    NSString *iCloudData = [[[url path] stringByAppendingPathComponent:self.iCloudDataDirectory] stringByAppendingPathComponent:self.modelFile];
 
    OESLogInfo(@"iCloudData = %@", iCloudData);

    NSURL *iCloudLogsPath = [NSURL fileURLWithPath:[[url path] stringByAppendingPathComponent:self.iCloudLogDirectory]];
 
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    [options setObject:@(YES) forKey:NSMigratePersistentStoresAutomaticallyOption];
    [options setObject:@(YES) forKey:NSInferMappingModelAutomaticallyOption];
    [options setObject:self.iCloudAppId forKey:NSPersistentStoreUbiquitousContentNameKey];
    [options setObject:iCloudLogsPath forKey:NSPersistentStoreUbiquitousContentURLKey];
 
    [persistentStoreCoordinator lock];
    [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:iCloudData] options:options error:nil];
    [persistentStoreCoordinator unlock];

    return YES;
}

#pragma mark - Accessor Overrides

- (NSManagedObjectContext *)managedObjectContext
{
    if (!isNil(_managedObjectContext))
        return _managedObjectContext;
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (!isNil(coordinator)) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        [_managedObjectContext performBlockAndWait:^{
            _managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
            _managedObjectContext.persistentStoreCoordinator = coordinator;

            // won't cause loop back because we've already created the managedObjectContext prior
            [self startListeningForNotifications];
        }];

    } // if

    return _managedObjectContext;
}

- (NSManagedObjectContext *)concurrentManagedObjectContext
{
    if (!isNil(_concurrentManagedObjectContext))
        return _concurrentManagedObjectContext;
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (!isNil(coordinator)) {
        _concurrentManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _concurrentManagedObjectContext.persistentStoreCoordinator = coordinator;
    } // if

    return _concurrentManagedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (!isNil(_managedObjectModel))
        return _managedObjectModel;

    NSURL *modelURL = [self modelUrl];
    
    if (isNil(modelURL))
        OESLogError(@"Could not find model URL");
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!isNil(_persistentStoreCoordinator))
        return _persistentStoreCoordinator;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *iCloudUrl = [fileManager URLForUbiquityContainerIdentifier:nil];
    
    if (iCloudUrl && 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self addCloudPersistentStoreToPersistentStoreCoordinator:_persistentStoreCoordinator url:iCloudUrl];

            OESLogNotice(@"iCloud Enabled: iCloudAppId %@, iCloudDataDirectory %@, iCloudLogDirectory %@, modelFile %@, iCloudUrl %@", self.iCloudAppId, self.iCloudDataDirectory, self.iCloudLogDirectory, self.modelFile, iCloudUrl);

            dispatch_async(dispatch_get_main_queue(), ^{
                [self persistentStoreCoordinatorCreated];
            });
            
        });
    }
    else {
        OESLogNotice(@"iCloud not enabled, using local store.");
        [self addLocalPersistentStoreToPersistentStoreCoordinator:_persistentStoreCoordinator];
    }

    return _persistentStoreCoordinator;
}

#pragma mark - Abstract Methods
#pragma mark -- Model

- (NSString *)modelFile
{
    return nil;
}

- (NSURL *)modelUrl
{
    //return [OESSharedResources URLForResource:@"OESSharedModel" withExtension:@"momd"];
    
    return nil;
}

#pragma mark -- iCloud

- (NSString *)iCloudDataDirectory
{
    return @"iCloudCoreData.nosync";
}

- (NSString *)iCloudLogDirectory
{
    return @"iCloudLogs";
}

- (NSString *)iCloudAppId
{
    return nil;
}

- (void)persistentStoreCoordinatorCreated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:OESModelManagerPersistentStoreCoordinatorCreatedNotification object:nil];
}

- (void)didMergeiCloudChanges
{
}

#pragma mark - Notifications

- (void)mergeiCloudChanges:(NSNotification *)notification forContext:(NSManagedObjectContext *)managedObjectContext {
    [managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
 
    NSNotification *refreshNotification = [NSNotification notificationWithName:OESModelManagerDidMergeiCloudChangesNotification object:self  userInfo:notification.userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];

    [self didMergeiCloudChanges];
}
 
// NSNotifications are posted synchronously on the caller's thread
// make sure to vector this back to the thread we want, in this case
// the main thread for our views & controller
- (void)mergeiCloudChanges:(NSNotification *)notification {
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
 
    // this only works if you used NSMainQueueConcurrencyType
    // otherwise use a dispatch_async back to the main thread yourself
    [managedObjectContext performBlock:^{
        [self mergeiCloudChanges:notification forContext:managedObjectContext];
    }];
}

@end
