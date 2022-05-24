//
//  OESPageControl.m
//  OpenEssentials
//
//  Created by Gregory Carter on 3/12/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import "OESPageControl.h"

@interface OESPageControl ()
@end

@implementation OESPageControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dotSpacing = 10.0f;
    } // if

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.dotSpacing = 10.0f;
    } // if
    
    return self;
}

// This assumes you're creating the control from a nib.  Depending on your
// usage you might do this step in initWithFrame:
- (void) awakeFromNib {
    // make sure the view is redrawn not scaled when the device is rotated
    self.contentMode = UIViewContentModeRedraw;
}

- (void) drawRect:(CGRect)rect
{
    rect = self.bounds;

    if (self.opaque) {
        [self.backgroundColor set];
        UIRectFill(rect);
    } // if

    if (self.hidesForSinglePage && self.numberOfPages == 1)
        return;

    CGRect drawRect = CGRectZero;
    drawRect.size.height = self.oesCurrentPageImage.size.height;
    drawRect.size.width = self.numberOfPages * self.oesCurrentPageImage.size.width + ( self.numberOfPages - 1 ) * self.dotSpacing;
    drawRect.origin.x = floorf( ( rect.size.width - drawRect.size.width ) / 2.0 );
    drawRect.origin.y = floorf( ( rect.size.height - drawRect.size.height ) / 2.0 );
    drawRect.size.width = self.oesCurrentPageImage.size.width;

    for (NSUInteger i = 0; i < self.numberOfPages; ++i ) {
        UIImage *image = i == self.currentPage ? self.oesCurrentPageImage : self.inactivePageImage;

        if (i == 0 && self.firstPageImage)
            image = i == self.currentPage ? self.firstPageImage : self.inactiveFirstPageImage;

        [image drawInRect:drawRect];
        drawRect.origin.x += self.oesCurrentPageImage.size.width + self.dotSpacing;
    } // for
}


// you must override the setCurrentPage: and setNumberOfPages:
// methods to ensure that your control is redrawn when its values change
- (void) setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
    [self setNeedsDisplay];
}


- (void) setNumberOfPages:(NSInteger)numberOfPages
{
    _numberOfPages = numberOfPages;
    [self setNeedsDisplay];
}

#pragma mark - [Accessor Overrides]


- (void)setDotSpacing:(CGFloat)dotSpacing
{
    _dotSpacing = dotSpacing;
    [self setNeedsDisplay];
}

@end
