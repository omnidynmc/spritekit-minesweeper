//
//  OESConfigObject.h
//  OESShared
//
//  Created by Gregory Carter on 8/31/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OESConfigVariable;

typedef enum {
    OESConfigObjectEnabledOff = 0,
    OESConfigObjectEnabledOn = 1,
    OESConfigObjectEnabledAuto = 2
} OESConfigFeatureEnabledType;

typedef enum {
    OESConfigObjectValidateInvalid = 0,
    OESConfigObjectValidateOk = 1,
    OESConfigObjectValidateNotFound = 2,
} OESConfigObjectValidateType;

typedef void (^OESConfigObjectValidHandler)(OESConfigVariable *);

@interface OESConfigObject : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, assign) NSTimeInterval startTimeInterval;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, assign) NSTimeInterval endTimeInterval;
@property (nonatomic, strong) NSArray *forDevices;
@property (nonatomic, strong) NSMutableDictionary *userInfo;
@property (nonatomic, assign) OESConfigFeatureEnabledType enabled;

// Factory Methods
+ (id)initWithDictionary:(NSDictionary *)dictionary name:(NSString *)name error:(NSError **)error;

// Support Methods
- (OESConfigObjectValidateType)validateVariableForSection:(NSString *)section key:(NSString *)key value:(NSString *)value error:(NSError **)error validHandler:(OESConfigObjectValidHandler)validHandler;
- (BOOL)trySetterForKey:(NSString *)key value:(id)value error:(NSError **)error;
+ (NSString *)removeSubcategoryFromObjectName:(NSString *)name;

// Abstract
- (BOOL)initWithDictionaryDidComplete:(NSDictionary *)dictionary error:(NSError **)error;
- (BOOL)processUnauthorizedKey:(NSString *)key value:(id)value error:(NSError **)error;
- (NSArray *)authorizedKeys;
- (BOOL)storeUnauthorizedKeysInUserInfo;
- (NSString *)validator;

// Public
- (BOOL)isBetweenDateRange;
- (BOOL)isEnabled;
- (NSString *)isEnabledString;
- (NSString *)enabledString;
- (void)overrideDatesWithConfigObject:(OESConfigObject *)configObject;
- (BOOL)isForDevicesMatch;
- (NSString *)nameWithoutSubcategory;
@end
