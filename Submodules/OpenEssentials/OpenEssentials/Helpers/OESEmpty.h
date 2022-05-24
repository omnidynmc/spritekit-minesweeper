//
//  OESEmpty.h
//  OpenEssentials
//
//  Created by Gregory Carter on 9/28/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#ifndef OpenEssentials_OESEmpty_h
#define OpenEssentials_OESEmpty_h

#define OES_THROW_PUREABSTRACT \
@throw [NSException exceptionWithName:NSInternalInconsistencyException \
                                             reason:[NSString stringWithFormat:@"Pure abstract method '%s' on line %d", __PRETTY_FUNCTION__, __LINE__] \
                                           userInfo:nil];

static inline BOOL isNil(id thing) {
    return thing == nil || [thing isKindOfClass:[NSNull class]];
} // isNil

static inline BOOL isDerefNil(NSObject **thing) {
    return thing == NULL || *thing == nil || [*thing isKindOfClass:[NSNull class]];
} // isDrefNil

static inline BOOL isEmpty(id thing) {
    return isNil(thing)
            || ([thing respondsToSelector:@selector(length)]
                && [(NSData *)thing length] == 0)
                || ([thing respondsToSelector:@selector(count)]
                && [(NSArray *)thing count] == 0);
} // isEmpty

static inline BOOL isString(id thing) {
    return !isNil(thing) && [thing isKindOfClass:[NSString class]];
} // isString

static inline BOOL isNumber(id thing) {
    return !isNil(thing) && [thing isKindOfClass:[NSNumber class]];
} // isNumber

static inline BOOL isDictionary(id thing) {
    return !isNil(thing) && [thing isKindOfClass:[NSDictionary class]];
} // isDictionary

static inline BOOL isMutableDictionary(id thing) {
    return !isNil(thing) && [thing isKindOfClass:[NSMutableDictionary class]];
} // isMutableDictionary

static inline BOOL isArray(id thing) {
    return !isNil(thing) && [thing isKindOfClass:[NSArray class]];
} // isArray

static inline BOOL isMutableArray(id thing) {
    return !isNil(thing) && [thing isKindOfClass:[NSMutableArray class]];
} // isMutableArray

static inline BOOL isDate(id thing) {
    return !isNil(thing) && [thing isKindOfClass:[NSDate class]];
} // isDate

static inline BOOL isUrl(id thing) {
    return !isNil(thing) && [thing isKindOfClass:[NSURL class]];
} // isUrl

static inline BOOL isData(id thing) {
    return !isNil(thing) && [thing isKindOfClass:[NSData class]];
} // isData

static inline NSString *stringInDictionary(NSString *key, NSDictionary *dictionary) {
    id object = [dictionary objectForKey:key];
    return isString(object) ? object : nil;
} // stringInDictionary

static inline NSNumber *numberInDictionary(NSString *key, NSDictionary *dictionary) {
    id object = [dictionary objectForKey:key];
    return isNumber(object) ? object : nil;
} // numberInDictionary

static inline NSDictionary *dictionaryInDictionary(NSString *key, NSDictionary *dictionary) {
    id object = [dictionary valueForKeyPath:key];
    return isDictionary(object) ? object : nil;
} // dictionaryInDictionary

static inline NSMutableDictionary *mutableDictionaryInDictionary(NSString *key, NSDictionary *dictionary) {
    id object = [dictionary valueForKeyPath:key];
    return isMutableDictionary(object) ? object : nil;
} // mutableDictionaryInDictionary

static inline NSArray *arrayInDictionary(NSString *key, NSDictionary *dictionary) {
    id object = [dictionary valueForKeyPath:key];
    return isArray(object) ? object : nil;
} // arrayInDictionary

static inline NSString *boolAsString(BOOL thing) {
    return thing ? @"YES" : @"NO";
} // boolAsString

static inline NSString *nilAsString(id object, NSString *defaultValue) {
    if (!isString(object))
        return defaultValue;
    
    return object;
} // nilAsString

#endif
