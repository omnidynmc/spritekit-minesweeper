//
//  OESInfiniteCarouselView.m
//  OpenEssentials
//
//  Created by Gregory Carter on 11/7/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "OESInfiniteCarouselView.h"
#import "UIView+OESView.h"

static const NSUInteger OESInfiniteCarouselMaxViews = 100;

@interface OESInfiniteCarouselView ()
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *scrollViewCollection;
@property (nonatomic, assign) NSUInteger carouselViewRotateCount;
@property (nonatomic, assign) NSUInteger currentWindow;
@property (nonatomic, assign, readonly) NSUInteger currentCarouselViewIndex;
@property (nonatomic, assign, getter=isRecentering) BOOL recentering;
@end

@implementation OESInfiniteCarouselView

@synthesize carouselRotationInterval = _carouselRotationInterval;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupViewContentSize];
        self.delegate = self;
    } // if
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupViewContentSize];
        self.delegate = self;
    } // if
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //self.carouselViews = self.carouselViews;
}

- (void)dealloc
{
    [self stopCarouselRotation];
}

#pragma mark - Private
#pragma mark -- View Setup

- (void)setupViewContentSize
{
    self.recentering = NO;
    
    // reset the content size according to the number of views
    CGFloat contentWidthX = self.stepSizeX * OESInfiniteCarouselMaxViews;
    self.contentSize = CGSizeMake(contentWidthX, self.bounds.size.height);
}

#pragma mark -- Carousel Page Changes

- (void)rotateCarouselViews
{
    if (self.carouselViews.count < 2)
        return;

    [self pushNextViewInWindow:self.currentWindow + 1];
    
    self.recentering = YES;
    CGFloat offsetX = self.stepSizeX * (self.currentWindow + 1);
    [self setContentOffset:CGPointMake(offsetX, 0.0f) animated:YES];
    self.recentering = NO;

    [self startCarouselRotation];
}

- (NSUInteger)incrementPage
{
    if (self.carouselViewRotateCount == (self.carouselViews.count - 1))
        self.carouselViewRotateCount = 0;
    else
        ++self.carouselViewRotateCount;
    
    return [self currentCarouselViewIndex];
}

- (NSUInteger)deincrementPage
{
    if (self.carouselViewRotateCount == 0)
        self.carouselViewRotateCount = self.carouselViews.count - 1;
    else
        --self.carouselViewRotateCount;
    
    return [self currentCarouselViewIndex];
}

- (NSUInteger)currentCarouselViewIndex
{
    return self.carouselViewRotateCount % self.carouselViews.count;
}

- (UIView *)viewForPage:(NSUInteger)page
{
    UIView *view = [self.carouselViews objectAtIndex:page];
    
    [self deselectViewBugfix:view];
    
    return view;
}

- (void)deselectViewBugfix:(UIView *)view
{
    if ([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        button.highlighted = NO;
        button.selected = NO;
    } // if
    else if ([view isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)view;
        imageView.highlighted = NO;
    } // if
}

- (void)pushNextViewInWindow:(NSUInteger)window
{
    if (self.carouselViews.count < 1)
        return;

    UIView *view = [self.carouselViews objectAtIndex:self.incrementPage];
    view.frameLeft = window * self.stepSizeX;
    [self addToScrollView:view];
    [self deincrementPage];
}

- (void)pushPreviousViewInWindow:(NSUInteger)window
{
    if (self.carouselViews.count < 1)
        return;

    UIView *view =  [self.carouselViews objectAtIndex:self.deincrementPage];
    view.frameLeft = window * self.stepSizeX;
    [self addToScrollView:view];
    [self incrementPage];
}

- (void)addToScrollView:(UIView *)view
{
    [self deselectViewBugfix:view];
    BOOL isAlreadyInScrollView = [self.scrollViewCollection containsObject:view];
    if (!isAlreadyInScrollView) {
        [self addSubview:view];
        [self.scrollViewCollection addObject:view];
    } // if
}

- (void)recenterScrollView
{
    self.recentering = YES;

     // clear the scrollview
    for(UIView *view in self.scrollViewCollection) {
        [view removeFromSuperview];
    } // for

    if (self.carouselViews.count < 1) {
        self.recentering = NO;
        return;
    } // if

    NSUInteger currentPage = self.currentCarouselViewIndex;

    // grab views for the page we're on
    UIView *view = [self viewForPage:currentPage];
    
    CGFloat centerOffsetX = self.stepSizeX * truncf(OESInfiniteCarouselMaxViews / 2);

    view.frameLeft = centerOffsetX;
    [self addSubview:view];

    // store what's currently in the scrollView
    self.scrollViewCollection = [NSMutableArray arrayWithArray:@[ view ]];

    [self setContentOffset:CGPointMake(centerOffsetX, 0.0f) animated:NO];

    self.currentWindow = truncf(centerOffsetX / self.stepSizeX);
    
    self.recentering = NO;
}

- (CGFloat)stepSizeX
{
    return self.bounds.size.width;
}

#pragma mark -- Carousel Timer

- (void)startCarouselRotation
{
    if (self.carouselRotationInterval < 1.0f)
        return;

    [self stopCarouselRotation];
    [self performSelector:@selector(rotateCarouselViews) withObject:nil afterDelay:self.carouselRotationInterval];
}

- (void)stopCarouselRotation
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rotateCarouselViews) object:nil];
}

#pragma mark - Public

- (void)moveToPageIndex:(NSUInteger)pageIndex
{
    BOOL isAlreadyAtIndex = self.currentCarouselViewIndex == pageIndex;
    if (isAlreadyAtIndex)
        return;
    
    CGFloat offsetX = self.stepSizeX * (self.currentWindow + pageIndex);
    [self setContentOffset:CGPointMake(offsetX, 0.0f) animated:YES];

    self.carouselViewRotateCount = pageIndex;

    [self recenterScrollView];
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopCarouselRotation];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [self startCarouselRotation];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    BOOL isExactPage = page == floor(page);

    if (isExactPage) {
        [self recenterScrollView];
        [self startCarouselRotation];

        if ([self.carouselDelegate respondsToSelector:@selector(carouselPageChangedToIndex:)])
            [self.carouselDelegate carouselPageChangedToIndex:self.currentCarouselViewIndex];

        return;
    } // if

    CGFloat stepSizeX = self.bounds.size.width;
    CGFloat offsetX = self.currentWindow * stepSizeX;

    [self setContentOffset:CGPointMake(offsetX, 0.0f) animated:YES];
    
    [self startCarouselRotation];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.recentering)
        return;
    
    CGFloat page = scrollView.contentOffset.x / self.stepSizeX;
    BOOL isExactPage = page == truncf(page);
    
    if (isExactPage) {
        if (page != self.currentWindow)
            [self recenterScrollView];
        
        return;
    } // if

    // push pages on the begining or end if needed
    if (page > self.currentWindow)
        [self pushNextViewInWindow:ceil(page)];
    else if (page < self.currentWindow)
        [self pushPreviousViewInWindow:floor(page)];

    // update our internal window reference
    if (page > self.currentWindow + 0.5f) {
        self.currentWindow = ceil(page);
        [self incrementPage];
    } // if
    else if (page < self.currentWindow - 0.5f) {
        self.currentWindow = floor(page);
        [self deincrementPage];
    } // else if

    // update pageControl bullets
    self.pageControl.currentPage = self.currentCarouselViewIndex;
}

#pragma mark - [Accessor Overrides]

- (void)setCarouselViews:(NSArray *)carouselViews
{
    // save page we were on
    NSUInteger currentPage = !isNil(self.pageControl) ? self.pageControl.currentPage : 0;
    
    _carouselViews = carouselViews;
    self.pageControl.numberOfPages = [carouselViews count];

    self.scrollEnabled = carouselViews.count != 1;
    self.pageControl.hidden = carouselViews.count == 1;
    
    self.carouselViewRotateCount = (currentPage < carouselViews.count) ? currentPage : 0;

    [self recenterScrollView];
    [self startCarouselRotation];
}

- (void)setCarouselRotationInterval:(NSTimeInterval)carouselRotationInterval
{
    _carouselRotationInterval = carouselRotationInterval;
    [self startCarouselRotation];
}

- (NSMutableArray *)scrollViewCollection
{
    return !isNil(_scrollViewCollection) ? _scrollViewCollection : (_scrollViewCollection = [NSMutableArray new]);
}

@end
