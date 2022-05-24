//
//  MSWExplosionSpriteNode.h
//  MineSweeper
//
//  Created by Gregory Carter on 8/30/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import "MSWSpriteNode.h"

@interface MSWExplosionSpriteNode : MSWSpriteNode
@property (nonatomic, strong, readonly) SKAction *explosionAction;
+ (instancetype)createSprite;
- (SKEmitterNode *)smokeEmitter;
@end
