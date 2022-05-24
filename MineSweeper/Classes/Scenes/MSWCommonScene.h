//
//  MSWCommonScene.h
//  MineSweeper
//
//  Created by Gregory Carter on 8/29/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@interface MSWCommonScene : SKScene

/**
 Override this method in subclases to load the contents of the scene as appropriate.
 */
- (void)createSceneContents;


/*
 Normally you might not redeclare a method overridden from a superclass, but do so here to note that the behavior has been customized.
 */
- (void)didMoveToView:(SKView *)view;
@end
