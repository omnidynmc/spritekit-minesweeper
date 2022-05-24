//
//  NSDictionary+OESAdditions.h
//  OpenEssentials
//
//  Created by Gregory Carter on 10/13/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (OESAdditions)
- (NSDictionary *)valueForDotPath:(NSString *)dotPath; // Note - every object along the path must be an NSDictionary / respond to objectForKey:. Not a substitute for valueForKeyPath:
- (NSNumber *)numberForDotPath:(NSString *)keyPath;
- (NSNumber *)numberForKey:(NSString *)key;
- (NSString *)stringForDotPath:(NSString *)keyPath;
- (NSString *)stringForKey:(NSString *)key;
- (NSArray *)arrayForDotPath:(NSString *)keyPath;
- (NSArray *)arrayForKey:(NSString *)key;
- (NSDictionary *)dictionaryForDotPath:(NSString *)keyPath;
- (NSDictionary *)dictionaryForKey:(NSString *)key;
@end
