//
//  UIImage+OESAdditions.h
//  OpenEssentials
//
//  Created by Gregory Carter on 10/13/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (OESAdditions)
- (UIImage *)imageWithOverlayedImage:(UIImage *)image;
- (UIImage *)imageWithOverlayColor:(UIColor *)color;
- (UIImage *)imageByAppendingImage:(UIImage *)image;
- (UIImage *)scaledToSize:(CGSize)newSize;
- (UIImage *)resizeToSize:(CGSize)newSize thenCropWithRect:(CGRect)cropRect;
@end
