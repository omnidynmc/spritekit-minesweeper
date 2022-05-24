//
//  OESInfiniteLabelScrollView.m
//  OpenEssentials
//
//  Created by Gregory Carter on 11/21/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "OESInfiniteLabelScrollView.h"

#import "UIView+OESView.h"


static const NSUInteger OESInfiniteLabelScrollViewMaxViews = 100;

@interface OESInfiniteLabelScrollView ()
@property (nonatomic, strong) UIView *view1;
@property (nonatomic, strong) UIView *view2;
@property (nonatomic, strong) UILabel *label1;
@property (nonatomic, strong) UILabel *label2;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) CGRect lastFrame;
@end

@implementation OESInfiniteLabelScrollView

#pragma mark - Class Methods

+ (CGFloat)widthForLabelWithString:(NSString *)string height:(CGFloat)height font:(UIFont *)font
{
    CGSize labelSize = [string sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, height)];

    return labelSize.width;
}

#pragma mark - [UIView Overrides]

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupDefaults];
        self.delegate = self;
    } // if
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self setupDefaults];
        self.delegate = self;
    } // if
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    BOOL shouldResetText = _text != nil && (self.frame.size.width != self.lastFrame.size.width || self.lastFrame.size.height != self.frame.size.height);

    if (shouldResetText)
        self.text = _text;

    self.lastFrame = self.frame;
}

#pragma mark - [Accessor Overrides]

- (void)setText:(NSString *)text
{
    CGFloat width = [OESInfiniteLabelScrollView widthForLabelWithString:text height:self.bounds.size.height font:self.labelFont];

    static CGFloat insetX = 0.0f;
    CGFloat padding = floor(self.boundsWidth / 2.0f);

    CGRect viewFrame = CGRectMake(0.0f, 0.0f, width + insetX + padding, self.boundsHeight);

    UIView *view1 = [[UIView alloc] initWithFrame:viewFrame];
    UIView *view2 = [[UIView alloc] initWithFrame:viewFrame];

    UILabel *label1 = [[UILabel alloc] initWithFrame:self.bounds];
    UILabel *label2 = [[UILabel alloc] initWithFrame:self.bounds];

    label1.frameLeft = insetX;
    label2.frameLeft = insetX;
    label1.frameWidth = width;
    label2.frameWidth = width;

    label1.text = label2.text = text;

    label1.textColor = label2.textColor = self.labelTextColor;
    label1.font = label2.font = self.labelFont;
    label1.backgroundColor = label2.backgroundColor =  self.labelBackgroundColor;
    label1.textAlignment = label1.textAlignment = self.textAlignment;

    self.label1 = label1;
    self.label2 = label2;

    self.view1 = view1;
    self.view2 = view2;

    [view1 addSubview:label1];
    [view2 addSubview:label2];

    if (width <= self.bounds.size.width)
        self.carouselViews = @[ view1 ];
    else
        self.carouselViews = @[ view1, view2 ];

    _text = text;
}

#pragma mark - Private
#pragma mark -- Defaults

- (void)setupDefaults
{
    self.labelTextColor = [UIColor whiteColor];
    self.labelFont = [UIFont boldSystemFontOfSize:14.0f];
    self.labelBackgroundColor = [UIColor clearColor];
    self.isAnimating = NO;
}

#pragma mark -- Carousel Page Changes

- (void)recenterScrollView
{
    if (self.carouselViews.count < 1)
        return;

   [self setContentOffset:CGPointMake(0.0f, 0.0f) animated:NO];
}

- (CGFloat)stepSizeX
{
    return MAX(self.bounds.size.width, self.view1.frameWidth);
}

#pragma mark -- Carousel Timer

- (void)startCarouselRotation
{
    if (self.isAnimating || self.carouselViews.count < 2)
        return;

    self.isAnimating = YES;

    [UIView animateWithDuration:self.stepSizeX / self.scrollPixelsPerSecond delay:1.0f options:UIViewAnimationOptionCurveLinear animations:^{
        CGPoint contentOffset = self.contentOffset;
        contentOffset.x += self.stepSizeX;
        self.contentOffset = contentOffset;
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
        [self recenterScrollView];
        [self startCarouselRotation];
    }];

}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

}

#pragma mark - [Accessor Overrides]

- (void)setCarouselViews:(NSArray *)carouselViews
{
     // clear the scrollview
    for(UIView *view in self.carouselViews) {
        [view removeFromSuperview];
    } // for
    
    _carouselViews = carouselViews;


    // reset the content size according to the number of views
    CGFloat contentWidthX = self.stepSizeX * carouselViews.count;
    self.contentSize = CGSizeMake(contentWidthX, self.boundsHeight);

    CGFloat offsetX = 0.0f;
    for(UIView *view in carouselViews) {
        view.frameLeft = offsetX;
        [self addSubview:view];
        offsetX += self.stepSizeX;
    } // for

    self.scrollEnabled = carouselViews.count != 1;
    
    [self recenterScrollView];
    [self startCarouselRotation];
}

- (NSUInteger)scrollPixelsPerSecond
{
    return 100;
}

@end
