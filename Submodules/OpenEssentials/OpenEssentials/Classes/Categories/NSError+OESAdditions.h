//
//  NSError+OESAdditions.h
//  OpenEssentials
//
//  Created by Gregory Carter on 10/13/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (OESAdditions)
+ (id)OESConfigError:(NSInteger)code description:(NSString *)description;
+ (id)OESError:(NSInteger)code description:(NSString *)description;
@end
