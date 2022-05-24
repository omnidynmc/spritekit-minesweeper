//
//  MSWMineView.h
//  MineSweeper
//
//  Created by Gregory Carter on 8/27/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MSWMineTile.h"

@class MSWMineView;
@class MSWMineTile;

@protocol MSWMineViewDelegate <NSObject>
@optional
- (void)mineView:(MSWMineView *)mineView didFinishGameWithWinStatus:(BOOL)winStatus;
- (void)mineView:(MSWMineView *)mineView didTripMineAtTile:(MSWMineTile *)mineTile;
- (void)mineView:(MSWMineView *)mineView wantTossBombAtMineTile:(MSWMineTile *)mineTile;
@end

@interface MSWMineView : UIView <MSWMineTileDelegate>
@property (nonatomic, assign) BOOL flag;
@property (nonatomic, weak) IBOutlet id<MSWMineViewDelegate> delegate;
- (void)resetWithNumberOfTilesWide:(NSUInteger)numberOfTilesWide numberOfTilesHigh:(NSUInteger)numberOfTilesHigh maximumMines:(NSUInteger)maximumMines minimumBombToss:(NSTimeInterval)minimumBombToss;
- (void)showReveal:(BOOL)showReveal;
- (void)verify;
- (void)tossRandomBomb;
@end
