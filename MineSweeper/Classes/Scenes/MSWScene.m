//
//  MSWScene.m
//  MineSweeper
//
//  Created by Gregory Carter on 8/29/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import "MSWScene.h"
#import "MSWManSpriteNode.h"
#import "MSWExplosionSpriteNode.h"
#import "MSWBombSprite.h"
#import "MSWBackgroundSpriteNode.h"

@interface MSWScene ()
@property (nonatomic, strong) MSWManSpriteNode *manWalking;
@property (nonatomic, strong) MSWExplosionSpriteNode *explosion;
@end

@implementation MSWScene

- (void)createSceneContents
{
    self.backgroundColor = [SKColor whiteColor];
    
    //self.anchorPoint = CGPointMake(0.5f, 0.5f);
    
    MSWBackgroundSpriteNode *background = [MSWBackgroundSpriteNode createSpriteNode];
    background.position = CGPointMake(truncf(self.size.width / 2), truncf(self.size.height / 2));
    [self addChild:background];
    
    [self.explosion explosionAction];
}

#pragma mark - Private
#pragma mark -- Walking Man

- (void)createWalkingManFromRight:(BOOL)fromRight
{
    self.manWalking = [MSWManSpriteNode createWalkingMan];

    // start him out left just off screen
    CGFloat y = self.size.height - (self.manWalking.frame.size.height / 2) - 10.0f; // 5 px padding
    CGFloat x = fromRight ? (self.size.width + 16.0f) : -16.f;

    self.manWalking.position = CGPointMake(x, y);

    [self addChild:self.manWalking];
}

#pragma mark - Public

- (void)tossMineAtPoint:(CGPoint)point completion:(dispatch_block_t)completion
{
    static BOOL tossing = NO;
    
    if (tossing)
        return;
    
    tossing = YES;

    BOOL fromRight = (point.x < self.view.frame.size.width / 2);
    [self createWalkingManFromRight:fromRight];
    
    // figure out where walking man needs to go
    CGPoint mineToHitPoint = [self convertPointFromView:point];
    CGPoint walkToPoint = CGPointMake(point.x + (fromRight ? 100.0f : -100.0f), 16.0f);
    CGPoint walkToScenePoint = [self convertPointFromView:walkToPoint];
    //CGPoint walkToCurvePoint = CGPointMake(walkToPoint.x + (fromRight ? -50.0f : 50.0f), walkToPoint.y + -50.0f);
    //CGPoint walkToCurveScenePoint = [self convertPointFromView:walkToCurvePoint];

    CGFloat halfWidth = 0.0f;
    CGPoint tangentPoint1 = CGPointMake(walkToPoint.x + (fromRight ? -(100.0f + halfWidth) : (100.0f + halfWidth)), walkToPoint.y);
    CGPoint tangentPoint2 = CGPointMake(tangentPoint1.x, walkToPoint.y + 100.0f);
    
    [self.manWalking walkToX:walkToScenePoint.x duration:5.0f completion:^{
        [self.manWalking addChild:[self.manWalking emitSmokeFromRight:fromRight]];
        
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGPathMoveToPoint(pathRef, NULL, walkToScenePoint.x, walkToScenePoint.y);
                
        CGPoint tangentScenePoint1 = [self convertPointFromView:tangentPoint1];
        CGPoint tangentScenePoint2 = [self convertPointFromView:tangentPoint2];
        
        CGPathAddArcToPoint(pathRef, NULL, tangentScenePoint1.x, tangentScenePoint1.y, tangentScenePoint2.x, tangentScenePoint2.y, 50.0f);
        CGPathAddLineToPoint(pathRef, NULL, mineToHitPoint.x, mineToHitPoint.y);
        
        MSWBombSprite *bombSprite = [MSWBombSprite createSprite];
        bombSprite.position = walkToScenePoint;
        [self addChild:bombSprite];

        [bombSprite setScale:0.1f];

        SKAction *group = [SKAction group:@[
            [SKAction scaleBy:5.0f duration:1.0f],
            [SKAction followPath:pathRef asOffset:NO orientToPath:NO duration:1.0f]
        ]];

        [bombSprite runAction:group completion:^{
            [bombSprite runAction:[SKAction fadeOutWithDuration:2.0f]];
            [self explodeMineAtPoint:point];
            CGPathRelease(pathRef);
            
            [self.manWalking walkToX:fromRight ? -16.0f : (self.size.width + 16.0f) duration:2.0f completion:^{
                [self.manWalking removeFromParent];
                tossing = NO;
            }];
            
            [bombSprite removeFromParent];
            
            if (completion)
                completion();

        }];
    }];
}

- (void)tempWalkingManCode
{
    self.manWalking = [MSWManSpriteNode createWalkingMan];
    
    //CGFloat y = self.size.height - truncf(self.manWalking.frame.size.height / 2);
    //self.manWalking.position = CGPointMake(self.view.frame.size.width + 16.0f, y);
    self.manWalking.position = [self convertPointFromView:CGPointMake(self.view.frame.size.width, 0.0f)];


    [self addChild:self.manWalking];

    SKAction *animateWalkRight = [SKAction repeatActionForever:[self.manWalking animateManWalkingRight]];
    SKAction *animateWalkLeft = [SKAction repeatActionForever:[self.manWalking animateManWalkingLeft]];

    SKAction *animateRightGroup = [SKAction group:@[
        [SKAction runBlock:^{
            [self.manWalking removeActionForKey:@"meh"];
            [self.manWalking runAction:animateWalkRight withKey:@"meh"];
        }],
        [SKAction moveByX:-self.view.frameWidth y:0.0f duration:10.0f]
    ]];

    SKAction *animateLeftGroup = [SKAction group:@[
        [SKAction runBlock:^{
            [self.manWalking removeActionForKey:@"meh"];
            [self.manWalking runAction:animateWalkLeft withKey:@"meh"];
        }],
        [SKAction moveByX:self.view.frameWidth y:0.0f duration:10.0f]
    ]];

    SKAction *sequence = [SKAction sequence:@[
        animateRightGroup,
        animateLeftGroup
    ]];

    [self.manWalking runAction:
        [SKAction repeatActionForever:sequence]
    ];
    
    MSWBombSprite *bombSprite = [MSWBombSprite createSprite];
    [self addChild:bombSprite];
    
    CGPathRef bombPath = [MSWBombSprite createArcPathFromPoint:CGPointMake(100.0f, 0.0f)];
    [bombSprite runAction:[SKAction followPath:bombPath duration:10.0f]];
}

- (void)explodeMineAtPoint:(CGPoint)point
{
    static BOOL exploding = NO;

    if (exploding)
        return;

    exploding = YES;

    MSWExplosionSpriteNode *explosion = self.explosion;

    explosion.position = [self convertPointFromView:point];
    [self addChild:explosion];
    
    NSString *explosionSoundPath = @"explosion.wav";
    
    SKAction *group = [SKAction group:@[
        [SKAction playSoundFileNamed:explosionSoundPath waitForCompletion:NO],
        [explosion explosionAction]
    ]];

    [explosion runAction:group completion:^{
        [explosion removeAllChildren];
        [explosion removeFromParent];
        exploding = NO;
    }];
}

- (MSWExplosionSpriteNode *)explosion
{
    if (_explosion == nil) {
        _explosion = [MSWExplosionSpriteNode createSprite];

        // pre populate
        [_explosion explosionAction];
    }

    return _explosion;
}

@end
