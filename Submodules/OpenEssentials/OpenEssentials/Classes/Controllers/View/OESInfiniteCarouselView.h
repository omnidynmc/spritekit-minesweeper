//
//  OESInfiniteCarouselView.h
//  OpenEssentials
//
//  Created by Gregory Carter on 11/7/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OESInfiniteCarouselViewDelegate <NSObject>
@optional
- (void)carouselPageChangedToIndex:(NSUInteger)index;
@end

@interface OESInfiniteCarouselView : UIScrollView <UIScrollViewDelegate>
@property (nonatomic, assign) NSTimeInterval carouselRotationInterval;
@property (nonatomic, strong) NSArray *carouselViews;
@property (nonatomic, weak) id<OESInfiniteCarouselViewDelegate> carouselDelegate;
- (CGFloat)stepSizeX;
- (void)moveToPageIndex:(NSUInteger)pageIndex;
@end
