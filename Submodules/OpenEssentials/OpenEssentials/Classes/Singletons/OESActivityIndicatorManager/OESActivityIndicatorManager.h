//
//  OESActivityIndicatorManager.h
//  OpenEssentials
//
//  Created by Gregory Carter on 3/7/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OESActivityIndicatorManager : NSObject
// Initialization
OESSHARED_INSTANCE_H(OESActivityIndicatorManager *)
- (void)networkActivityStarted;
- (void)networkActivityStopped;
@end
