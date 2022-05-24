//
//  OESDynamicObject.h
//  OpenEssentials
//
//  Created by Gregory Carter on 10/13/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OESDynamicObject;
typedef OESDynamicObject *(^OESDynamicObjectHandler)(NSDictionary *dictionary, NSString *name, NSError **error);

@interface OESDynamicObject : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableDictionary *userInfo;

// Factory Methods
+ (id)initWithDictionary:(NSDictionary *)dictionary name:(NSString *)name error:(NSError **)error;
+ (NSArray *)createObjectsFromArray:(NSArray *)array objectClass:(Class)objectClass;
+ (id)processObjectsFromDictionary:(id)object storeAsDictionary:(BOOL)storeAsDictionary objectHandler:(OESDynamicObjectHandler)objectHandler;
+ (NSArray *)collapseDoubleDictionaryArray:(NSArray *)array forKey:(NSString *)key;

// Abstract Methods
- (void)initWithDictionaryWillBegin:(NSDictionary *)dictionary;
- (BOOL)initWithDictionaryDidComplete:(NSDictionary *)dictionary error:(NSError **)error;
- (BOOL)processUnauthorizedKey:(NSString *)key value:(id)value error:(NSError **)error;
- (NSDictionary *)authorizedKeys;
- (NSDate *)tryParsingDate:(NSString *)dateString format:(NSString *)dateFormat timezone:(NSString *)timezone;
@end
