//
//  UILabel+OESAdditions.m
//  OpenEssentials
//
//  Created by Gregory Carter on 2/28/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import "UILabel+OESAdditions.h"
#import "UIView+OESView.h"

@implementation UILabel (OESAdditions)

- (void)setTextWithFade:(NSString *)text
{
    [self setTextWithFade:text duration:0.3f];
}

- (void)setTextWithFade:(NSString *)text duration:(CGFloat)duration
{
    if (self.text == text)
        return;
    
    UIImage *labelImage = [self renderViewAsImage];
    UIImageView *fadeImageView = [[UIImageView alloc] initWithImage:labelImage];
    fadeImageView.frame = self.frame;
    [self.superview insertSubview:fadeImageView aboveSubview:self];
    
    self.alpha = 0.0f;
    self.text = text;
    
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 1.0f;
        fadeImageView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [fadeImageView removeFromSuperview];
    }];
}

@end
