//
//  OESParallaxImage.h
//  OpenEssentials
//
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OESParallaxImage : NSObject
@property (nonatomic, copy, readonly) UIImage *image;
@property (nonatomic, assign, readonly) CGFloat movementRatio;
@property (nonatomic, assign, readonly) CGPoint origin;
// Class Methods
+ (OESParallaxImage *)parallaxWithImage:(UIImage *)image movementRatio:(CGFloat)movementRatio origin:(CGPoint)origin;
// Public
- (CGFloat)offsetForX:(CGFloat)x;
@end
