//
//  MSWScene.h
//  MineSweeper
//
//  Created by Gregory Carter on 8/29/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import "MSWCommonScene.h"

@interface MSWScene : MSWCommonScene
- (void)tossMineAtPoint:(CGPoint)point completion:(dispatch_block_t)completion;
- (void)explodeMineAtPoint:(CGPoint)point;
@end
