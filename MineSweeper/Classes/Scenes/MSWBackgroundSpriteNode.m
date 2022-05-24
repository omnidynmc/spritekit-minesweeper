//
//  MSWBackgroundSpriteNode.m
//  MineSweeper
//
//  Created by Gregory Carter on 9/7/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import "MSWBackgroundSpriteNode.h"

@implementation MSWBackgroundSpriteNode

+ (instancetype)createSpriteNode
{
    MSWBackgroundSpriteNode *sprite = [[self class] spriteNodeWithImageNamed:@"MSWBackground"];

    return sprite;
}

@end
