//
//  OESConfigEndpoint.h
//  OESShared
//
//  Created by Gregory Carter on 9/5/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import "OESConfigFeature.h"

@interface OESConfigEndpoint : OESConfigFeature
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSNumber *serial;
@property (nonatomic, strong) NSNumber *refreshInterval;
+ (id)initWithString:(NSString *)urlString name:(NSString *)name error:(NSError **)error;
@end
