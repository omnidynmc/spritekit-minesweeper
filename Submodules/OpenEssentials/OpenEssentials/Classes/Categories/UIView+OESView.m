//
//  UIView+OESView.m
//  OpenEssentials
//
//  Created by Gregory Carter on 9/28/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "UIView+OESView.h"

@implementation UIView (OESView)

- (void)oesLoadViewFromNib
{
   NSArray *topLevelElements =[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    UIView *contentView = topLevelElements[0];
    contentView.frame = self.bounds;
    [self addSubview:contentView];
}

- (void)oesDrawPath:(CGPathRef)path
{
    CAShapeLayer *myLayer = [[CAShapeLayer alloc] init];
    myLayer.strokeColor = [[UIColor greenColor] CGColor];
    myLayer.lineWidth = 2.0;
    myLayer.fillColor = nil;
    myLayer.lineJoin = kCALineJoinBevel;
    myLayer.path = path;
    [self.layer addSublayer:myLayer];
}

- (UIEdgeInsets)edgeInsetsWithinSuperview
{
    UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
    edgeInsets.bottom = self.superview.frameHeight - self.frameBottom;
    edgeInsets.left = self.frameLeft;
    edgeInsets.right = self.superview.frameWidth - self.frameRight;
    edgeInsets.top = self.frameTop;
    return edgeInsets;
}

- (CGFloat)frameLeft
{
    return self.frame.origin.x;
}

- (void)setFrameLeft:(CGFloat)frameLeft
{
    CGRect frame = self.frame;
    frame.origin.x = frameLeft;
    self.frame = frame;
}

- (CGFloat)frameRight
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setFrameRight:(CGFloat)frameRight
{
    CGRect frame = self.frame;
    frame.origin.x = frameRight - self.frame.size.width;
    self.frame = frame;
}

- (CGFloat)frameWidth
{
    return self.frame.size.width;
}

- (void) setFrameWidth:(CGFloat)frameWidth
{
    CGRect frame = self.frame;
    frame.size.width = frameWidth;
    self.frame = frame;
}

- (CGFloat)frameHeight
{
    return self.frame.size.height;
}

- (void)setFrameHeight:(CGFloat)frameHeight
{
    CGRect frame = self.frame;
    frame.size.height = frameHeight;
    self.frame = frame;
}

- (CGFloat)frameTop
{
    return self.frame.origin.y;
}

- (void)setFrameTop:(CGFloat)frameTop
{
    CGRect frame = self.frame;
    frame.origin.y = frameTop;
    self.frame = frame;
}

- (CGFloat)frameBottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setFrameBottom:(CGFloat)frameBottom
{
    CGRect frame = self.frame;
    frame.origin.y = frameBottom - self.frame.size.height;
    self.frame = frame;
}

- (CGSize)frameSize
{
    return self.frame.size;
}

- (void)setFrameSize:(CGSize)frameSize
{
    CGRect frame = self.frame;
    frame.size = frameSize;
    self.frame = frame;
}

- (CGPoint)frameOrigin
{
    return self.frame.origin;
}

- (void)setFrameOrigin:(CGPoint)frameOrigin
{
    CGRect frame = self.frame;
    frame.origin = frameOrigin;
    self.frame = frame;
}

- (CGFloat)boundsLeft
{
    return self.bounds.origin.x;
}

- (void)setBoundsLeft:(CGFloat)boundsLeft
{
    CGRect bounds = self.bounds;
    bounds.origin.x = boundsLeft;
    self.bounds = bounds;
}

- (CGFloat)boundsRight
{
    return self.bounds.origin.x + self.bounds.size.width;
}

- (void)setBoundsRight:(CGFloat)boundsRight
{
    CGRect bounds = self.bounds;
    bounds.origin.x = boundsRight - self.bounds.size.width;
    self.bounds = bounds;
}

- (CGFloat)boundsWidth
{
    return self.bounds.size.width;
}

- (void) setBoundsWidth:(CGFloat)boundsWidth
{
    CGRect bounds = self.bounds;
    bounds.size.width = boundsWidth;
    self.bounds = bounds;
}

- (CGFloat)boundsHeight
{
    return self.bounds.size.height;
}

- (void)setBoundsHeight:(CGFloat)boundsHeight
{
    CGRect bounds = self.frame;
    bounds.size.height = boundsHeight;
    self.bounds = bounds;
}

- (CGFloat)boundsTop
{
    return self.bounds.origin.y;
}

- (void)setBoundsTop:(CGFloat)boundsTop
{
    CGRect bounds = self.frame;
    bounds.origin.y = boundsTop;
    self.bounds = bounds;
}

- (CGFloat)boundsBottom
{
    return self.bounds.origin.y + self.bounds.size.height;
}

- (void)setBoundsBottom:(CGFloat)boundsBottom
{
    CGRect bounds = self.bounds;
    bounds.origin.y = boundsBottom - self.bounds.size.height;
    self.bounds = bounds;
}

- (void)expandWidthToX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.size.width = x - frame.origin.x;
    self.frame = frame;
}

- (void)expandHeightToY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.size.height = y - frame.origin.y;
    self.frame = frame;
}

- (UIImage *)renderViewAsImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *bitmapImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return bitmapImage;
}

@end
