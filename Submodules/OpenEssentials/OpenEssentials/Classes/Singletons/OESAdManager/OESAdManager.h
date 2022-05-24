//
//  OESAdManager.h
//  OpenEssentials
//
//  Created by Gregory Carter on 2/12/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>

@interface OESAdManager : NSObject
@property (nonatomic, strong) ADBannerView *adBannerView;

// Initialization
OESSHARED_INSTANCE_H(OESAdManager *)
@end
