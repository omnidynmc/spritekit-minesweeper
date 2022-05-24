//
//  MSWManWalkingRightScene.m
//  MineSweeper
//
//  Created by Gregory Carter on 8/29/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#import "MSWManSpriteNode.h"

#define deg2rad(deg) M_PI / 180.0f * deg

const int kDefaultNumberOfWalkFrames = 4;
const float showCharacterFramesOverOneSecond = 1.0f/(float) kDefaultNumberOfWalkFrames;

@interface MSWManSpriteNode ()
@property (nonatomic, strong, readwrite) SKAction *animateManWalkingRight;
@property (nonatomic, strong, readwrite) SKAction *animateManWalkingLeft;
@property (nonatomic, strong) NSArray *walkFramesRight;
@property (nonatomic, strong) NSArray *walkFramesLeft;
@end

@implementation MSWManSpriteNode

+ (instancetype)createWalkingMan
{
    MSWManSpriteNode *manWalking = [[self class] spriteNodeWithImageNamed:@"MSWWalkRight-0001.png"];

    return manWalking;
}

#pragma mark - Public

- (void)walkToX:(CGFloat)x duration:(NSTimeInterval)duration completion:(MSWManSpriteNodeCompletion)completion
{
    SKAction *walk = self.position.x > x ? self.animateManWalkingRight : self.animateManWalkingLeft;
    SKAction *animateWalk = [SKAction repeatActionForever:walk];
    
    [self runAction:animateWalk withKey:@"walk"];
    SKAction *animateRightGroup = [SKAction group:@[
        [SKAction moveToX:x duration:duration],
    ]];

    [self runAction:animateRightGroup completion:^{
        [self removeActionForKey:@"walk"];

        if (completion)
            completion();
    }];
}

- (SKEmitterNode *)emitSmokeFromRight:(BOOL)fromRight
{
    NSString *smokePath = [[NSBundle mainBundle] pathForResource:@"MSWSmokeEmitter" ofType:@"sks"];
    SKEmitterNode *smoke = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];

    smoke.emissionAngle = fromRight ? deg2rad(170.0f) : smoke.emissionAngle;
    smoke.numParticlesToEmit = 2.0f;
    
    return smoke;
}

#pragma mark - [Accessor Overrides]

- (SKAction *)animateManWalkingRight
{
    if (_animateManWalkingRight == nil) {
        self.walkFramesRight = [[self class] animationFramesForImageNamePrefix:@"MSWWalkRight-" frameCount:kDefaultNumberOfWalkFrames];
        _animateManWalkingRight = [SKAction animateWithTextures:self.walkFramesRight timePerFrame:showCharacterFramesOverOneSecond resize:YES restore:NO];
    }
    
    return _animateManWalkingRight;
}

- (SKAction *)animateManWalkingLeft
{
    if (_animateManWalkingLeft == nil) {
        self.walkFramesLeft = [[self class] animationFramesForImageNamePrefix:@"MSWWalkLeft-" frameCount:kDefaultNumberOfWalkFrames];
        _animateManWalkingLeft = [SKAction animateWithTextures:self.walkFramesLeft timePerFrame:showCharacterFramesOverOneSecond resize:YES restore:NO];
    }
    
    return _animateManWalkingLeft;
}

@end
