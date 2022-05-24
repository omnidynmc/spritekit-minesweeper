//
//  MSWSpriteNode.m
//  MineSweeper
//
//  Created by Gregory Carter on 8/30/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import "MSWSpriteNode.h"

@implementation MSWSpriteNode

#pragma mark - Class Methods

+ (NSArray *)animationFramesForImageNamePrefix:(NSString *)baseImageName frameCount:(NSInteger)count
{
    // Loads a series of frames from files stored in the app bundle, returning them in an array.
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger index = 1; index <= count; ++index) {
        NSString *imageName = [NSString stringWithFormat:@"%@%04d.png", baseImageName, index];
        
        SKTexture *texture = [SKTexture textureWithImageNamed:imageName];
        
        OESLogInfo(@"imageName %@, texture %@", imageName, texture);
        
        [array addObject:texture];
    }
    
    return [NSArray arrayWithArray:array];
}

@end
