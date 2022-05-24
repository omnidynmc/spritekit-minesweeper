//
//  OESParallaxImage.m
//  OpenEssentials
//
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//



#import "OESParallaxImage.h"

@interface OESParallaxImage ()
@property (nonatomic, copy, readwrite) UIImage *image;
@property (nonatomic, assign, readwrite) CGFloat movementRatio;
@property (nonatomic, assign, readwrite) CGPoint origin;
@end

@implementation OESParallaxImage


#pragma mark - Class Methods


+ (OESParallaxImage *)parallaxWithImage:(UIImage *)image movementRatio:(CGFloat)movementRatio origin:(CGPoint)origin
{
    OESParallaxImage *parallax = [[self class] new];
    
    parallax.image = image;
    parallax.movementRatio = movementRatio;
    parallax.origin = origin;

    return parallax;
}


#pragma mark - Public


- (CGFloat)offsetForX:(CGFloat)x
{
    return truncf((self.origin.x + x) * self.movementRatio);
}


#pragma mark - <NSCopying>


- (id)copyWithZone:(NSZone *)zone
{
    OESParallaxImage *parallax = [[self class] new];
    
    parallax.image = self.image;
    parallax.movementRatio = self.movementRatio;
    parallax.origin = self.origin;
    
    return parallax;
}

@end