//
//  MSWSpriteNode.h
//  MineSweeper
//
//  Created by Gregory Carter on 8/30/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MSWSpriteNode : SKSpriteNode
+ (NSArray *)animationFramesForImageNamePrefix:(NSString *)baseImageName frameCount:(NSInteger)count;
@end
