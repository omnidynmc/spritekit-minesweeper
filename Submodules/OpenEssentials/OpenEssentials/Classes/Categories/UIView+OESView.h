//
//  UIView+OESView.h
//  OpenEssentials
//
//  Created by Gregory Carter on 9/28/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (OESView)
@property (nonatomic, assign) CGFloat frameWidth;
@property (nonatomic, assign) CGFloat frameHeight;
@property (nonatomic, assign) CGFloat frameTop;
@property (nonatomic, assign) CGFloat frameRight;
@property (nonatomic, assign) CGFloat frameLeft;
@property (nonatomic, assign) CGFloat frameBottom;
@property (nonatomic, assign) CGSize frameSize;
@property (nonatomic, assign) CGPoint frameOrigin;
@property (nonatomic, assign) CGFloat boundsWidth;
@property (nonatomic, assign) CGFloat boundsHeight;
@property (nonatomic, assign) CGFloat boundsTop;
@property (nonatomic, assign) CGFloat boundsRight;
@property (nonatomic, assign) CGFloat boundsLeft;
@property (nonatomic, assign) CGFloat boundsBottom;
- (void)oesLoadViewFromNib;
- (void)oesDrawPath:(CGPathRef)path;
- (UIEdgeInsets)edgeInsetsWithinSuperview;
- (void)expandWidthToX:(CGFloat)x;
- (void)expandHeightToY:(CGFloat)y;
- (UIImage *)renderViewAsImage;
@end
