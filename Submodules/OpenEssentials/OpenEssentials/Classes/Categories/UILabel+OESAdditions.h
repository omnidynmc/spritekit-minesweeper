//
//  UILabel+OESAdditions.h
//  OpenEssentials
//
//  Created by Gregory Carter on 2/28/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (OESAdditions)
- (void)setTextWithFade:(NSString *)text;
- (void)setTextWithFade:(NSString *)text duration:(CGFloat)duration;
@end
