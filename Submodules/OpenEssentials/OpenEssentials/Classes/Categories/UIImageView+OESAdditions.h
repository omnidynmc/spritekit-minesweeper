//
//  UIImageView+OESAdditions.h
//  OpenEssentials
//
//  Created by Gregory Carter on 11/12/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (OESAdditions)
+ (void)rotateImage:(UIImageView *)image duration:(NSTimeInterval)duration
       curve:(int)curve degrees:(CGFloat)degrees;
- (void)rotateWithDuration:(NSTimeInterval)duration
       curve:(int)curve degrees:(CGFloat)degrees;
@end
