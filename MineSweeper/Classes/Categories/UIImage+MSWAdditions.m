//
//  UIImage+MSWAdditions.m
//  MineSweeper
//
//  Created by Gregory Carter on 8/29/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import "UIImage+MSWAdditions.h"

@implementation UIImage (MSWAdditions)

#pragma mark - Tiles

+ (UIImage *)mswImageForTileNormal
{
    return [UIImage imageNamed:@"MSWTileNormal"];
}

+ (UIImage *)mswImageForTileMine
{
    return [UIImage imageNamed:@"MSWTileMineNormal"];
}

+ (UIImage *)mswImageForTileFound
{
    return [UIImage imageNamed:@"MSWTileMineFound"];
}

+ (UIImage *)mswImageForTileHighlighted
{
    return [UIImage imageNamed:@"MSWTileHighlighted"];
}

+ (UIImage *)mswImageForFreeTile
{
    return [UIImage imageNamed:@"MSWTileFreeNormal"];
}

#pragma mark - Overlays

+ (UIImage *)mswImageForFlagOverlay
{
    return [UIImage imageNamed:@"MSWTileFlagOverlay"];
}

+ (UIImage *)mswImageForBombOverlay
{
    return [UIImage imageNamed:@"MSWTileBombOverlay"];
}

+ (UIImage *)mswImageForRevealOverlay
{
    return [UIImage imageNamed:@"MSWTileRevealOverlay"];
}

@end
