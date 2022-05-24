//
//  OESRect.h
//  OpenEssentials
//
//  Created by Gregory Carter on 12/7/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef OpenEssentials_OESRect_h
#define OpenEssentials_OESRect_h

static CGFloat OESRectExpandToY(const CGRect frame, const CGFloat y)
{
    return y - frame.origin.y;
}

static CGFloat OESRectExpandToX(const CGRect frame, const CGFloat x)
{
    return x - frame.origin.x;
}

#endif
