//
//  UIImageView+OESAdditions.m
//  OpenEssentials
//
//  Created by Gregory Carter on 11/12/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

// Our conversion definition
#define OES_DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)

#import "UIImageView+OESAdditions.h"

@implementation UIImageView (OESAdditions)
+ (void)rotateImage:(UIImageView *)image duration:(NSTimeInterval)duration
       curve:(int)curve degrees:(CGFloat)degrees
{
  // Setup the animation
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:duration];
  [UIView setAnimationCurve:curve];
  [UIView setAnimationBeginsFromCurrentState:YES];
  
  // The transform matrix
  CGAffineTransform transform = 
      CGAffineTransformMakeRotation(OES_DEGREES_TO_RADIANS(degrees));
  image.transform = transform;
 
  // Commit the changes
  [UIView commitAnimations];
}

- (void)rotateWithDuration:(NSTimeInterval)duration
       curve:(int)curve degrees:(CGFloat)degrees
{
    [UIImageView rotateImage:self duration:duration curve:curve degrees:degrees];
}
@end
