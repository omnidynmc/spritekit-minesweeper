//
//  OESAdManager.m
//  OpenEssentials
//
//  Created by Gregory Carter on 2/12/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import "OESAdManager.h"

@implementation OESAdManager
#pragma mark - Initialization

OESSHARED_INSTANCE(OESAdManager *)

#pragma mark - [Accessor Overides]

- (ADBannerView *)adBannerView
{
    if (!isNil(_adBannerView))
        return _adBannerView;
    
    // On iOS 6 ADBannerView introduces a new initializer, use it when available.
    if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)])
        return _adBannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    else
        return _adBannerView = [ADBannerView new];
}

@end
