//
//  MSWMineView.m
//  MineSweeper
//
//  Created by Gregory Carter on 8/27/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MSWMineView.h"
#import "MSWMineIndex.h"
#import "MSWMineButton.h"

static const CGFloat MSWMineViewDefaultSpacing = 2.0f;
static NSArray *MSWMineViewDetectionMatrix;

@interface MSWMineView ()
@property (nonatomic, assign, getter = isGameOver) BOOL gameOver;
@property (nonatomic, strong) NSArray *mineTileMatrix;
@property (nonatomic, assign) NSTimeInterval minimumBombTossTimeInterval;
@end

@implementation MSWMineView

#pragma mark - Class Methods

+ (void)initialize
{
    MSWMineViewDetectionMatrix = @[
        [MSWMineIndex mineIndexWithRow:-1 column:-1],
        [MSWMineIndex mineIndexWithRow:-1 column:0],
        [MSWMineIndex mineIndexWithRow:-1 column:1],
        [MSWMineIndex mineIndexWithRow:0 column:-1]
    ];
}

#pragma mark - [NSObject Overrides]

- (void)dealloc
{
    [self stopBombTossTimer];
}

#pragma mark - [UIView Overrides]

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }

    return self;
}

#pragma mark - Private
#pragma mark -- Setup

- (void)resetWithNumberOfTilesWide:(NSUInteger)numberOfTilesWide numberOfTilesHigh:(NSUInteger)numberOfTilesHigh maximumMines:(NSUInteger)maximumMines minimumBombToss:(NSTimeInterval)minimumBombToss
{
    [self.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [view removeFromSuperview];
    }];

    NSUInteger columns = numberOfTilesWide;
    NSUInteger rows = numberOfTilesHigh;
    
    NSUInteger totalTiles = rows * columns;
    
    CGFloat widthPerCell = truncf((self.frameWidth - (columns * MSWMineViewDefaultSpacing)) / columns);
    CGFloat heightPerCell = widthPerCell; //truncf((self.frameHeight - (columns * MSWMineViewDefaultSpacing)) / columns);
    
    CGSize cellSize = CGSizeMake(widthPerCell, heightPerCell);

    NSArray *randomNumbers = [self generateRandomMinesWithMaximumMines:maximumMines numberOfTiles:totalTiles];

    NSMutableArray *tileArray = [[NSMutableArray alloc] initWithCapacity:totalTiles];
    for (NSUInteger currentRow = 0; currentRow < rows; ++currentRow) {
        CGFloat offsetY = cellSize.height * currentRow + (MSWMineViewDefaultSpacing * currentRow);
        for(NSUInteger currentColumn = 0; currentColumn < columns; ++currentColumn) {
            NSUInteger index = (currentRow * columns) + currentColumn;
            CGFloat offsetX = cellSize.width * currentColumn + (currentColumn > 0 ? (MSWMineViewDefaultSpacing * currentColumn) : 0);
            
            UIButton *button = [MSWMineButton mswTileButton];

            CGRect frame = CGRectMake(offsetX, offsetY, cellSize.width, cellSize.height);
            button.frame = frame;

            button.tag = index;

            [button addTarget:self action:@selector(didTouchMineTile:) forControlEvents:UIControlEventTouchUpInside];

            [self addGestureRecognizerToButton:button];

            [self addSubview:button];

            BOOL hasMine = ([randomNumbers indexOfObject:@(index)] != NSNotFound);

            MSWMineTile *mineTile = [MSWMineTile mineTileWithButton:button hasMine:hasMine];
            mineTile.delegate = self;
            
            [MSWMineViewDetectionMatrix enumerateObjectsUsingBlock:^(MSWMineIndex *mineIndex, NSUInteger idx, BOOL *stop) {
                
                BOOL isOutY = currentRow == 0 && mineIndex.row < 0;
                if (isOutY)
                    return;
                
                BOOL isOutX = (currentColumn == 0 && mineIndex.column < 0)
                            || (currentColumn == (columns - 1) && mineIndex.column == 1);
                if (isOutX)
                    return;
                
                
                NSUInteger nearByIndex = (currentColumn + mineIndex.column) + ((currentRow + mineIndex.row) * columns);
                
                //NSLog(@"nearBy currentColumn %d, currentRow %d, mineIndex.column %d, mineIndex.row %d, nearByIndex %d, index %d, hasMine %d", currentColumn, currentRow, mineIndex.column, mineIndex.row, nearByIndex, index, hasMine);
                
                MSWMineTile *nearByTile = tileArray[nearByIndex];
                
                [nearByTile addSurroundingTile:mineTile];
                [mineTile addSurroundingTile:nearByTile];
            }];
            
            [tileArray addObject:mineTile];
        }
    }
    
    self.mineTileMatrix = tileArray;
    
    self.gameOver = NO;

    [self startBombTossTimerWithMinimum:minimumBombToss];
}

#pragma mark -- General Game

- (void)showReveal:(BOOL)showReveal
{
    [self.mineTileMatrix enumerateObjectsUsingBlock:^(MSWMineTile *mineTile, NSUInteger idx, BOOL *stop) {
        [mineTile showReveal:showReveal];
    }];
}

- (void)verify
{
    [self endGameAndCalcWinState:YES];
}

- (void)tossRandomBomb
{
    NSUInteger index = [self randomNumberBetweenMin:0 max:self.mineTileMatrix.count];

    MSWMineTile *mineTile = self.mineTileMatrix[index];
    [self.delegate mineView:self wantTossBombAtMineTile:mineTile];
}

- (NSUInteger)randomNumberBetweenMin:(NSUInteger)min max:(NSUInteger)max
{
    if (min >= max)
        return NSNotFound;

    return (arc4random() % (max - min)) + min;
}

#pragma mark - Private

- (NSArray *)generateRandomMinesWithMaximumMines:(NSUInteger)maximumMines numberOfTiles:(NSUInteger)numberOfTiles
{
    NSMutableArray *randomNumbers = [[NSMutableArray alloc] initWithCapacity:maximumMines];
    while(randomNumbers.count < maximumMines) {
        int randomInt = arc4random() % numberOfTiles;
        NSNumber *randomNumber = [NSNumber numberWithInt:randomInt];
        
        NSUInteger index = [randomNumbers indexOfObject:randomNumber];
        if (index != NSNotFound)
            continue;
        
        [randomNumbers addObject:randomNumber];
    }

    return [NSArray arrayWithArray:randomNumbers];
}

- (void)endGameAndCalcWinState:(BOOL)winState
{
    __block BOOL gameWinStatus = winState;
    
    [self.mineTileMatrix enumerateObjectsUsingBlock:^(MSWMineTile *mineTile, NSUInteger idx, BOOL *stop) {
        BOOL isError = [mineTile isErrorCondition];
        if (isError)
            gameWinStatus = NO;
    }];
    
    [self.mineTileMatrix enumerateObjectsUsingBlock:^(MSWMineTile *mineTile, NSUInteger idx, BOOL *stop) {
        // now reveal them all
        if (mineTile.flipped)
            return;
        
        [mineTile touched];
    }];

    BOOL responds = [self.delegate respondsToSelector:@selector(mineView:didFinishGameWithWinStatus:)];
    if (!responds)
        return;
    
    [self.delegate mineView:self didFinishGameWithWinStatus:gameWinStatus];
}

- (void)addGestureRecognizerToButton:(UIButton *)button
{
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didHoldMine:)];
    [longPressGestureRecognizer setMinimumPressDuration:0.5f]; // triggers the action after 2 seconds of press
    [button addGestureRecognizer:longPressGestureRecognizer];
}

- (MSWMineTile *)mineTileForButton:(UIButton *)button
{
    // should never happen but safe guard
    BOOL isOutOfRange = button.tag >= self.mineTileMatrix.count;
    if (isOutOfRange)
        return nil;

    MSWMineTile *mineTile = self.mineTileMatrix[button.tag];

    return [mineTile isKindOfClass:[MSWMineTile class]] ? mineTile : nil;
}

#pragma mark -- Timer

- (void)startBombTossTimerWithMinimum:(NSTimeInterval)minimum
{
    [self stopBombTossTimer];

    _minimumBombTossTimeInterval = minimum;
    
    NSTimeInterval randomTimeInterval = [self randomNumberBetweenMin:minimum max:100];

    [self performSelector:@selector(bombTossTimerDidFire) withObject:nil afterDelay:randomTimeInterval];
}

- (void)stopBombTossTimer
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(bombTossTimerDidFire) object:nil];
}

#pragma mark - Timers

- (void)bombTossTimerDidFire
{
    if (self.isGameOver) {
        [self stopBombTossTimer];
        return;
    }

    [self tossRandomBomb];
    [self startBombTossTimerWithMinimum:self.minimumBombTossTimeInterval];
}

#pragma mark - Actions

- (IBAction)didTouchMineTile:(UIButton *)button
{
    MSWMineTile *mineTile = [self mineTileForButton:button];

    if (mineTile == nil)
        return;

    if (self.flag) {
        [mineTile flag];
        return;
    }

    [mineTile touched];
}

- (void)didHoldMine:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan)
        return;

    UIButton *button = (UIButton *)recognizer.view;
    
    BOOL isButton = [button isKindOfClass:[UIButton class]];
    if (!isButton)
        return;

    MSWMineTile *mineTile = [self mineTileForButton:button];

    if (mineTile == nil)
        return;

    [mineTile flag];
}

#pragma mark - <MSWMineTileDelegate>

- (void)mineTileTrippedMine:(MSWMineTile *)mineTile
{
    [self endGameAndCalcWinState:NO];
    
    BOOL responds = [self.delegate respondsToSelector:@selector(mineView:didTripMineAtTile:)];
    if (!responds || self.gameOver) {
        self.gameOver = YES;
        return;
    }

    [self.delegate mineView:self didTripMineAtTile:mineTile];

    self.gameOver = YES;
}

@end
