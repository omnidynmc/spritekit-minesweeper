//
//  MSWCommonScene.m
//  MineSweeper
//
//  Created by Gregory Carter on 8/29/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import "MSWCommonScene.h"

@implementation MSWCommonScene

/*
    This sample always recreates the scenes before presenting them, so this code only runs once. If you move to
    an architecture where a scene may be presented more than once, you need to ensure that the scene's contents
    are only created once.
 */
- (void)didMoveToView:(SKView *)view
{
    [self createSceneContents];
}

/**
 Override this method in subclases to load the contents of the scene as appropriate.
 */
- (void)createSceneContents
{
}

@end
