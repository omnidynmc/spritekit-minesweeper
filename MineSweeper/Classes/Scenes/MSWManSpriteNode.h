//
//  MSWManWalkingRightScene.h
//  MineSweeper
//
//  Created by Gregory Carter on 8/29/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import "MSWSpriteNode.h"

typedef void(^MSWManSpriteNodeCompletion)();

@interface MSWManSpriteNode : MSWSpriteNode
@property (nonatomic, strong, readonly) SKAction *animateManWalkingRight;
@property (nonatomic, strong, readonly) SKAction *animateManWalkingLeft;
// Class Methods
+ (instancetype)createWalkingMan;
// Public
- (SKEmitterNode *)emitSmokeFromRight:(BOOL)fromRight;
- (void)walkToX:(CGFloat)x duration:(NSTimeInterval)duration completion:(MSWManSpriteNodeCompletion)completion;
@end
