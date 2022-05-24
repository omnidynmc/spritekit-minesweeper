//
//  OESButton.m
//  OpenEssentials
//
//  Created by Gregory Carter on 11/22/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import "OESButton.h"

@implementation OESButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return CGRectContainsPoint(self.touchBounds, point);
}

- (CGRect)touchBounds
{
    CGFloat widthExtension = 44.0f - self.bounds.size.width;
    widthExtension = MAX(0.0f, widthExtension);

    CGFloat heightExtension = 44.0f - self.bounds.size.height;
    heightExtension = MAX(0.0f, heightExtension);

    CGRect touchBounds = CGRectInset(self.bounds, -(widthExtension / 2), -(heightExtension / 2));
    return touchBounds;
}

@end
