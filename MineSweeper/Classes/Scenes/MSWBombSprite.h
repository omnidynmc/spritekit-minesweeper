//
//  MSWBombSprite.h
//  MineSweeper
//
//  Created by Gregory Carter on 8/31/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import "MSWSpriteNode.h"

@interface MSWBombSprite : MSWSpriteNode
+ (instancetype)createSprite;
+ (CGPathRef)createArcPathFromPoint:(CGPoint)point;
@end
