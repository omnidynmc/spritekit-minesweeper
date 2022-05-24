//
//  OESParallaxView.m
//  OpenEssentials
//
//  Created by Gregory Carter on 6/5/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import "OESParallaxView.h"
#import "OESParallaxImage.h"

#import "UIView+OESView.h"

@interface OESParallaxView ()
@property (nonatomic, strong) NSArray *imageViews;
@end

@implementation OESParallaxView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


#pragma mark - [Mutator Overrides]


- (void)setOffsetX:(CGFloat)offsetX
{
    _offsetX = offsetX;
    
    // if these aren't equal something is very wrong
    BOOL isValid = [self.imageViews count] == [self.parallaxImages count];

    if (!isValid) {
        return;
    }

    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView *imageView, NSUInteger idx, BOOL *stop) {
        OESParallaxImage *parallaxImage = self.parallaxImages[idx];

        imageView.frameLeft = [parallaxImage offsetForX:offsetX];
    }];
}


- (void)setParallaxImages:(NSArray *)parallaxImages
{
    _parallaxImages = parallaxImages;
    
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView *imageView, NSUInteger idx, BOOL *stop) {
        [imageView removeFromSuperview];
    }];
    
    
    __block NSMutableArray *imageViews = [[NSMutableArray alloc] initWithCapacity:[parallaxImages count]];
    [parallaxImages enumerateObjectsUsingBlock:^(OESParallaxImage *parallaxImage, NSUInteger idx, BOOL *stop) {
        BOOL isValid = [parallaxImage isKindOfClass:[OESParallaxImage class]];
        
        if (!isValid) {
            return;
        }

        UIImageView *imageView = [[UIImageView alloc] initWithImage:parallaxImage.image];
        imageView.frameLeft = [parallaxImage offsetForX:self.offsetX];
        imageView.frameTop = parallaxImage.origin.y;

        [imageViews addObject:imageView];

        [self addSubview:imageView];
    }];
    
    _imageViews = imageViews;
}

@end
