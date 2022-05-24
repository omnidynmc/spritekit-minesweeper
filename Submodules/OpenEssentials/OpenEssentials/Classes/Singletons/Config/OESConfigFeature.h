//
//  OESConfigFeature.h
//  OESShared
//
//  Created by Gregory Carter on 9/5/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OESConfigObject.h"

@interface OESConfigFeature : OESConfigObject
+ (id)initWithString:(NSString *)enabled name:(NSString *)name error:(NSError **)error;
+ (id)initWithNumber:(NSNumber *)enabled name:(NSString *)name error:(NSError **)error;
@end