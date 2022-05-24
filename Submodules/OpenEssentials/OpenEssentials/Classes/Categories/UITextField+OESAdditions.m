//
//  UITextField+OESAdditions.m
//  OpenEssentials
//
//  Created by Gregory Carter on 9/20/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//
#import <objc/runtime.h>

#import "UITextField+OESAdditions.h"

static char inProgressKey;

@implementation UITextField (OESAdditions)

- (void)oesFlashInvalidField
{
    NSNumber *inProgressNumber = objc_getAssociatedObject(self, &inProgressKey);

    if (inProgressNumber != nil && [inProgressNumber integerValue] == 1)
        return;
    
    inProgressNumber = @(1);
    
    objc_setAssociatedObject(self, &inProgressKey, inProgressNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    UIView *overlay = [[UIView alloc] initWithFrame:self.frame];
    
    overlay.backgroundColor = [UIColor redColor];
    overlay.alpha = 0.0f;
    
    [self.superview addSubview:overlay];
    
    [UIView animateWithDuration:0.25f animations:^{
            overlay.alpha = 0.45f;
    } completion:^(BOOL finished) {
       [UIView animateWithDuration:0.75f delay:0.5f options:UIViewAnimationOptionCurveEaseInOut animations:^{
           overlay.alpha = 0.0f;
       } completion:^(BOOL finished) {
           [overlay removeFromSuperview];
           objc_setAssociatedObject(self, &inProgressKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
       }];
    }];
}

@end
