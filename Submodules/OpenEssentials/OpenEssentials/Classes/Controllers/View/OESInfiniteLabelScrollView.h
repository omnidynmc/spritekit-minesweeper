//
//  OESInfiniteLabelScrollView.h
//  OpenEssentials
//
//  Created by Gregory Carter on 11/21/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OESInfiniteLabelScrollView : UIScrollView <UIScrollViewDelegate>
// Label Properties
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIColor *labelTextColor;
@property (nonatomic, strong) UIFont *labelFont;
@property (nonatomic, strong) UIColor *labelBackgroundColor;
@property (nonatomic, assign) NSTextAlignment textAlignment;

// Carousel
@property (nonatomic, strong) NSArray *carouselViews;
- (CGFloat)stepSizeX;
@end