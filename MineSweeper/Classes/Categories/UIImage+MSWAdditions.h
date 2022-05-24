//
//  UIImage+MSWAdditions.h
//  MineSweeper
//
//  Created by Gregory Carter on 8/29/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MSWAdditions)
// Tile
+ (UIImage *)mswImageForTileNormal;
+ (UIImage *)mswImageForTileMine;
+ (UIImage *)mswImageForTileFound;
+ (UIImage *)mswImageForTileHighlighted;
+ (UIImage *)mswImageForFreeTile;
// Overlays
+ (UIImage *)mswImageForFlagOverlay;
+ (UIImage *)mswImageForBombOverlay;
+ (UIImage *)mswImageForRevealOverlay;
@end
