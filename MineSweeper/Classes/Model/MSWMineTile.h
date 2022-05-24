//
//  MSWMineCell.h
//  MineSweeper
//
//  Created by Gregory Carter on 8/27/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MSWMineTile;

@protocol MSWMineTileDelegate <NSObject>
- (void)mineTileTrippedMine:(MSWMineTile *)mineTile;
@end

@interface MSWMineTile : NSObject
@property (nonatomic, assign, readonly, getter = isErrorCondition) BOOL isErrorCondition;
@property (nonatomic, assign, readonly, getter = hasMine) BOOL mine;
@property (nonatomic, assign, readonly, getter = isFlipped) BOOL flipped;
@property (nonatomic, assign, readonly, getter = isFlagged) BOOL flagged;
@property (nonatomic, weak, readonly) UIButton *button;
@property (nonatomic, weak) id<MSWMineTileDelegate> delegate;
+ (instancetype)mineTileWithButton:(UIButton *)button hasMine:(BOOL)hasMine;
- (void)addSurroundingTile:(MSWMineTile *)surroundingTile;
- (void)flag;
- (void)touched;
- (void)showReveal:(BOOL)showReveal;
@end
