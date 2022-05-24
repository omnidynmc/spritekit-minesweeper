//
//  OESSharedInstance.h
//  OpenEssentials
//
//  Created by Gregory Carter on 10/13/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#ifndef OpenEssentials_OESSharedInstance_h
#define OpenEssentials_OESSharedInstance_h

// too many variations out there to create shared instances, use this macro
// to keep it consistent
#ifndef OESSHARED_INSTANCE
#   define OESSHARED_INSTANCE(type) \
+ (type)sharedInstance \
{ \
    static dispatch_once_t p = 0; \
    __strong static id _sharedObject = nil; \
    dispatch_once(&p, ^{ \
        _sharedObject = [[self alloc] init]; \
    }); \
    return _sharedObject; \
}
#endif

#ifndef OESSHARED_INSTANCE_H
#   define OESSHARED_INSTANCE_H(type) + (type)sharedInstance;
#endif

#endif
