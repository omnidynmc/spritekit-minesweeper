//
//  MSWExplosionSpriteNode.m
//  MineSweeper
//
//  Created by Gregory Carter on 8/30/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import "MSWExplosionSpriteNode.h"

const int MSWExplosionSpriteNodeNumberOfFrames = 37;
const float MSWExplosionsSpriteNodeFramesPerSecond = 1.0f/(float) MSWExplosionSpriteNodeNumberOfFrames;


@interface MSWExplosionSpriteNode ()
@property (nonatomic, strong, readwrite) SKAction *explosionAction;
@end

@implementation MSWExplosionSpriteNode

#pragma mark - [Accessor Overrides]

+ (instancetype)createSprite
{
    MSWExplosionSpriteNode *explosion = [[self class] spriteNodeWithImageNamed:@"MSWExplosion-0001.png"];
    
    explosion.xScale = 0.2f;
    explosion.yScale = 0.2f;
    
    return explosion;
}

- (SKAction *)explosionAction
{
    if (_explosionAction == nil) {
        NSArray *frames = [[self class] animationFramesForImageNamePrefix:@"MSWExplosion-" frameCount:MSWExplosionSpriteNodeNumberOfFrames];
        _explosionAction = [SKAction animateWithTextures:frames timePerFrame:MSWExplosionsSpriteNodeFramesPerSecond resize:YES restore:NO];
    }
    
    return _explosionAction;
}

- (SKEmitterNode *)smokeEmitter
{
    NSString *smokePath = [[NSBundle mainBundle] pathForResource:@"MSWSmokeEmitter" ofType:@"sks"];
    SKEmitterNode *smoke = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];

    smoke.emissionAngle = DEGREES_TO_RADIANS(90.0f);
    smoke.numParticlesToEmit = 10.0f;
    
    return smoke;
}

@end
