//
//  NSObject+OESAdditions.h
//  OpenEssentials
//
//  Created by Gregory Carter on 10/14/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (OESAdditions)
- (BOOL)isArray;
- (BOOL)isDictionary;
- (BOOL)isString;
- (BOOL)isNumber;
@end
