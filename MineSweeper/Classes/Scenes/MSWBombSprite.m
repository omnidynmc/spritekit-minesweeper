//
//  MSWBombSprite.m
//  MineSweeper
//
//  Created by Gregory Carter on 8/31/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import "MSWBombSprite.h"

@implementation MSWBombSprite

#pragma mark - Class Methods

+ (instancetype)createSprite
{
    MSWBombSprite *sprite = [[self class] spriteNodeWithImageNamed:@"MSWTileBombOverlay"];

    SKEmitterNode *smokeEmitter = [[self class] smokEmitter];
    [sprite addChild:smokeEmitter];

    return sprite;
}

+ (CGPathRef)createArcPathFromPoint:(CGPoint)point
{
    //UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:point radius:75 startAngle:0 endAngle:DEGREES_TO_RADIANS(135) clockwise:YES];

    CGMutablePathRef pathRef = CGPathCreateMutable();
    
//    CGPathAddEllipseInRect(pathRef, NULL, CGRectMake(50.0f, 50.0f, 100.0f, 100.0f));
    CGPathMoveToPoint(pathRef, NULL, point.x, point.y);
    //CGPathAddArcToPoint(pathRef, NULL, point.x, point.y, 100.0f, 100.0f, 10.0f);
    CGPathAddQuadCurveToPoint(pathRef, NULL, point.x + 10.0f, point.y+20.0f, 100.0f, 100.0f);

    // Set the starting point of the shape.
    //[bezierPath moveToPoint:point];

    // Draw the lines.
//    [bezierPath addLineToPoint:CGPointMake(200.0, 40.0)];
//    [bezierPath addLineToPoint:CGPointMake(160, 140)];
//    [bezierPath addLineToPoint:CGPointMake(40.0, 140)];
//    [bezierPath addLineToPoint:CGPointMake(0.0, 40.0)];
//    [bezierPath closePath];

    return pathRef;
}

+ (SKEmitterNode *)smokEmitter
{
    NSString *smokePath = [[NSBundle mainBundle] pathForResource:@"MSWSmokeEmitter" ofType:@"sks"];
    SKEmitterNode *smoke = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];

    smoke.emissionAngle = DEGREES_TO_RADIANS(90.0f);
    smoke.particleLifetime = 5.0f;
    smoke.particleSpeed = 200.0f;
    smoke.numParticlesToEmit = 30.0f;
    
    return smoke;
}

@end
