//
//  OESDynamicObject.m
//  OpenEssentials
//
//  Created by Gregory Carter on 10/13/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import "OESDynamicObject.h"

#import "NSObject+PropertyTypes.h"

// we want one static date formatter to rule them all
static NSDateFormatter *OESDynamicObjectDateFormatter;
static NSMutableDictionary *OESDynamicObjectTypesCache;

@interface OESDynamicObject ()

@end

@implementation OESDynamicObject

// We're going to run through the dictionary and attempt to do something with all of the keys.
// All subclasses must implement "authorizedKeys" which is what tells this parser what keys
// to attempt to store automatically (as a safeguard) into class instance variables. Everything else gets placed
// in the userInfo dictionary that is not processed by subclass's processUnauthorizedKey.
+ (id)initWithDictionary:(NSDictionary *)dictionary name:(NSString *)name error:(NSError **)error
{
    // handle empty dictionary
    if (!isDictionary(dictionary)) {
        if (error != NULL)
            *error = [NSError OESError:500 description:@"dictionary is empty"];
        return nil;
    } // if

    OESDynamicObject *object = [self new];

    object.name = name;

    [object initWithDictionaryWillBegin:dictionary];
 
    // evil, stupid or awesome, you be the judge; handles basic values
    for(NSString *key in dictionary) {
        id value = [dictionary objectForKey:key];

        // don't allow unauthorized keys to be set with KVC
        NSDictionary *authorizedKey = [object deriveAuthorizedKey:key];
        if (isNil(authorizedKey)) {
            BOOL wasHandled = [object processUnauthorizedKey:key value:value error:error];

            if (!isDerefNil(error))
                return nil;
                
            // we couldn't process it so add it as a userInfo record
            if (!wasHandled)
                [object.userInfo setObject:value forKey:key];

            continue;
        } //if

        BOOL wasDictionaryHandled = [object handleDictionaryIfRequestedForKey:key value:value authorizedKey:authorizedKey];
        if (wasDictionaryHandled)
            continue;
        
        BOOL wasArrayHandled = [object handleArrayIfRequestedForKey:key value:value authorizedKey:authorizedKey];
        if (wasArrayHandled)
            continue;
        
        BOOL wasClassHandled = [object handleClassIfRequestedForKey:key value:value authorizedKey:authorizedKey];
        if (wasClassHandled)
            continue;
        
        NSString *mappedTo = [authorizedKey objectForKey:@"mapTo"];
        NSString *mappedName = !isNil(mappedTo) ? mappedTo : key;

        NSString *dateFormat = [authorizedKey objectForKey:@"dateFormat"];
        if (!isNil(dateFormat))
            value = [object tryParsingDate:value format:dateFormat timezone:nil];

        BOOL wasSet = [object trySetterForKey:mappedName value:value error:error];

        if (!wasSet) {
            if (error != nil)
                *error = [NSError OESError:501 description:[NSString stringWithFormat:@"could not set '%@' for key '%@'", mappedName, key]];
            return (object = nil);
        } // if
    } // for
    
    BOOL isObjectOk = [object initWithDictionaryDidComplete:dictionary error:error];
    
    return !isObjectOk ? (object = nil) : object;
}

+ (NSArray *)createObjectsFromArray:(NSArray *)array objectClass:(Class)objectClass
{
    NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:array.count];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (!isDictionary(obj))
            return;
        
        NSError *error = nil;
        id object = [objectClass initWithDictionary:obj name:NSStringFromClass(objectClass) error:&error];
        
        if (isNil(object)) {
            OESLogWarn(@"Could not parse %@ object: %@, %@", NSStringFromClass(objectClass), object, error);
            return;
        } // if
        
        OESLogDebug(@"Adding object: %@", object);

        [objects addObject:object];
    }];
    
    return [NSArray arrayWithArray:objects];
}

+ (NSArray *)collapseDoubleDictionaryArray:(NSArray *)array forKey:(NSString *)key
{
    if (!isArray(array))
        return nil;
    
    NSMutableArray *collapsedArray = [[NSMutableArray alloc] initWithCapacity:array.count];
    [array enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger idx, BOOL *stop) {
        NSDictionary *event = [dictionary objectForKey:key];
        if (isNil(event))
            return;
        
        [collapsedArray addObject:event];
    }];
    
    return [NSArray arrayWithArray:collapsedArray];
}

// returns either an NSDictionary or NSArray
+ (id)processObjectsFromDictionary:(id)object storeAsDictionary:(BOOL)storeAsDictionary objectHandler:(OESDynamicObjectHandler)objectHandler
{
    if (!isDictionary(object))
        return nil;
    
    NSDictionary *dictionary = object;
    
    NSMutableDictionary *objectDictionary = [NSMutableDictionary new];
    NSMutableArray *objectArray = [NSMutableArray new];
    for(NSString *key in dictionary) {
        NSDictionary *toParseDictionary = dictionaryInDictionary(key, dictionary);
        
        if (isNil(toParseDictionary))
            continue;

        NSError *error = nil;
        OESDynamicObject *dynamicObject = objectHandler(toParseDictionary, key, &error);

        if (isNil(dynamicObject)) {
            OESLogError(@"Could not create dynamic object '%@': %@", key, error);
            continue;
        } // if
        
        OESLogDebug(@"Adding dynamic object: %@", dynamicObject);
        
        if (storeAsDictionary)
            [objectDictionary setObject:dynamicObject forKey:key];
        else
            [objectArray addObject:dynamicObject];
    } // for

    return storeAsDictionary ? [NSDictionary dictionaryWithDictionary:objectDictionary] : [NSArray arrayWithArray:objectArray];
}

#pragma mark - Private

- (BOOL)handleDictionaryIfRequestedForKey:(NSString *)key value:(id)value authorizedKey:(NSDictionary *)authorizedKey
{
    // handle dictionary of objects if requested
    NSString *dictionaryClass = stringInDictionary(@"dictionaryClass", authorizedKey);
    if (dictionaryClass == nil)
        return NO;
    
    if (NSClassFromString(dictionaryClass) == nil) {
        OESLogWarn(@"Specified dictionaryClass but could not find class: %@", dictionaryClass);
        return YES;
    } // if
    
    if (!isDictionary(value)) {
        OESLogWarn(@"Expected to get dictionary for key: %@", key);
        return YES;
    } // if

    NSDictionary *handleDictionary = [OESDynamicObject processObjectsFromDictionary:value storeAsDictionary:YES objectHandler:^OESDynamicObject *(NSDictionary *dictionary, NSString *name, NSError *__autoreleasing *error) {
        return [NSClassFromString(dictionaryClass) initWithDictionary:dictionary name:name error:error];
    }];

    NSString *mappedTo = [authorizedKey objectForKey:@"mapTo"];
    NSString *mappedName = !isNil(mappedTo) ? mappedTo : key;

    NSError *error = nil;
    BOOL wasSet = [self trySetterForKey:mappedName value:handleDictionary error:&error];
    
    if (!wasSet) {
        if (error != NULL)            
            OESLogWarn(@"could not set '%@' for key '%@': %@", mappedName, key, error);
    } // if

    return YES;
}

- (BOOL)handleArrayIfRequestedForKey:(NSString *)key value:(id)value authorizedKey:(NSDictionary *)authorizedKey
{
    // handle dictionary of objects if requested
    NSString *arrayClass = stringInDictionary(@"arrayClass", authorizedKey);
    if (arrayClass == nil)
        return NO;
    
    if (NSClassFromString(arrayClass) == nil) {
        OESLogWarn(@"Specified dictionaryClass but could not find class: %@", arrayClass);
        return YES;
    } // if
    
    if (!isArray(value)) {
        OESLogWarn(@"Expected to get dictionary for key: %@", key);
        return YES;
    } // if

    NSArray *handleArray = [OESDynamicObject processObjectsFromDictionary:value storeAsDictionary:NO objectHandler:^OESDynamicObject *(NSDictionary *dictionary, NSString *name, NSError *__autoreleasing *error) {
        return [NSClassFromString(arrayClass) initWithDictionary:dictionary name:name error:error];
    }];

    NSString *mappedTo = [authorizedKey objectForKey:@"mapTo"];
    NSString *mappedName = !isNil(mappedTo) ? mappedTo : key;

    NSError *error = nil;
    BOOL wasSet = [self trySetterForKey:mappedName value:handleArray error:&error];
    
    if (!wasSet) {
        if (error != NULL)            
            OESLogWarn(@"could not set '%@' for key '%@': %@", mappedName, key, error);
    } // if

    return YES;
}

- (BOOL)handleClassIfRequestedForKey:(NSString *)key value:(id)value authorizedKey:(NSDictionary *)authorizedKey
{
    // handle dictionary of objects if requested
    NSString *classString = stringInDictionary(@"class", authorizedKey);
    if (classString == nil)
        return NO;
    
    if (NSClassFromString(classString) == nil) {
        OESLogWarn(@"Specified class but could not find class: %@", classString);
        return YES;
    } // if
    
    if (!isDictionary(value)) {
        OESLogWarn(@"Expected to get dictionary for key: %@", key);
        return YES;
    } // if

    NSError *error = nil;
    OESDynamicObject *dynamicObject = [NSClassFromString(classString) initWithDictionary:value name:nil error:&error];

    if (isNil(dynamicObject)) {
        OESLogError(@"Could not create dynamic object '%@': %@", key, error);
        return YES;
    } // if

    NSString *mappedTo = [authorizedKey objectForKey:@"mapTo"];
    NSString *mappedName = !isNil(mappedTo) ? mappedTo : key;

    BOOL wasSet = [self trySetterForKey:mappedName value:dynamicObject error:&error];
    
    if (!wasSet) {
        if (error != NULL)            
            OESLogWarn(@"could not set '%@' for key '%@': %@", mappedName, key, error);
    } // if

    return YES;
}

- (BOOL)trySetterForKey:(NSString *)key value:(id)value error:(NSError **)error
{
    SEL setterSelector = NSSelectorFromString(key);
    if ([self respondsToSelector:setterSelector]) {
        // type match
        Class propertyClass = [self.typesCache objectForKey:key];

        BOOL isTypeMatch = !isNil(propertyClass) && ([value isKindOfClass:propertyClass] || [value isKindOfClass:[NSNull class]]);
        if (!isTypeMatch) {
            OESLogInfo(@"Type mismatch for key '%@' value = %@", key, NSStringFromClass([value class]))
            return NO;
        } // if
        
        BOOL isValid =  [self validateValue:&value forKey:key error:error];
        if (!isValid) {
            *error = [NSError OESError:501 description:[NSString stringWithFormat:@"value for '%@' doesn't match type", key]];
            return NO;
        } // if

        [self setValue:value forKey:key];
        
        return YES;
    } // if

    return NO;
}

- (NSDictionary *)deriveAuthorizedKey:(NSString *)key
{
    return [[self authorizedKeys] objectForKey:key];
}

#pragma mark - Abstract Methods

- (NSDictionary *)authorizedKeys
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                            reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                             userInfo:nil];
}

- (BOOL)processUnauthorizedKey:(NSString *)key value:(id)value error:(NSError **)error
{
    // abstract default method
    return NO;
}

- (void)initWithDictionaryWillBegin:(NSDictionary *)dictionary
{
}

- (BOOL)initWithDictionaryDidComplete:(NSDictionary *)dictionary error:(NSError **)error
{
    return YES;
}

- (NSDate *)tryParsingDate:(NSString *)dateString format:(NSString *)dateFormat timezone:(NSString *)timezone;
{
    if (isEmpty(dateString) || isEmpty(dateFormat))
        return nil;

    NSDate *date;
    @synchronized(self.dateFormatter) {
        if (!isEmpty(timezone))
            [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:timezone]];
        
        [self.dateFormatter setDateFormat:dateFormat];
        date = [self.dateFormatter dateFromString:dateString];
    } // @synchornized
    
    return date;
}

#pragma mark - [NSObject Overrides]

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ name = %@", NSStringFromClass([self class]), self.name];
}

#pragma mark - [Accessor Overrides]

- (NSMutableDictionary *)userInfo
{
    return !isNil(_userInfo) ? _userInfo : (_userInfo = [NSMutableDictionary new]);
}

- (NSDateFormatter *)dateFormatter
{
    // since creating date formatter instances is heckof expensive, let's negociate the price down
    return OESDynamicObjectDateFormatter != nil ? OESDynamicObjectDateFormatter : (OESDynamicObjectDateFormatter = [NSDateFormatter new]);
}

- (NSDictionary *)typesCache
{
    @synchronized(OESDynamicObjectTypesCache) {
        if (OESDynamicObjectTypesCache == nil)
            OESDynamicObjectTypesCache = [NSMutableDictionary new];

        NSDictionary *typesCache = dictionaryInDictionary(NSStringFromClass([self class]), OESDynamicObjectTypesCache);
        if (typesCache == nil) {
            typesCache = [self typesForProperties];
            [OESDynamicObjectTypesCache setObject:typesCache forKey:NSStringFromClass([self class])];
        } // if

        return typesCache;
    } // @Synchronize
}

@end
