//
//  MSWMineCell.m
//  MineSweeper
//
//  Created by Gregory Carter on 8/27/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import "MSWMineTile.h"

#import "UIImage+MSWAdditions.h"
#import "UIColor+MSWAdditions.h"

@interface MSWMineTile ()
@property (nonatomic, assign, readwrite) BOOL mine;
@property (nonatomic, assign, readwrite) BOOL flipped;
@property (nonatomic, assign, readwrite) NSUInteger numberOfMines;
@property (nonatomic, weak, readwrite) UIButton *button;
@property (nonatomic, strong) NSMutableArray *surroundingTiles;
@property (nonatomic, strong) UILabel *revealLabel;
@property (nonatomic, strong) UIImageView *revealImageView;
@end

@implementation MSWMineTile

+ (instancetype)mineTileWithButton:(UIButton *)button hasMine:(BOOL)hasMine
{
    MSWMineTile *mineTile = [[self class] new];
    
    mineTile.button = button;
    mineTile.mine = hasMine;

    return mineTile;
}

#pragma mark - Public

- (void)addSurroundingTile:(MSWMineTile *)surroundingTile
{
    if (surroundingTile.hasMine)
        ++self.numberOfMines;

    [self.surroundingTiles addObject:surroundingTile];
}

- (void)flag
{
    [self animateFlagIn:!self.button.selected];
    
    if (self.revealLabel.superview) {
        [self.button bringSubviewToFront:self.revealLabel];
    }
}

- (void)touched
{
    [self touchedIterative];
}

- (void)touchedRecursive
{
    self.button.enabled = NO;
    self.flipped = YES;
    
    if (self.hasMine) {
        [UIView transitionWithView:self.button duration:0.5f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self.button setBackgroundImage:[UIImage mswImageForBombOverlay] forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
            [self.delegate mineTileTrippedMine:self];
        }];
    
        return;
    }

    [self.button setBackgroundImage:[UIImage mswImageForFreeTile] forState:UIControlStateNormal];

    BOOL isZero = self.numberOfMines == 0;
    if (!isZero) {
        NSString *surroundingMines = [NSString stringWithFormat:@"%@", @(self.numberOfMines)];
        
        [UIView transitionWithView:self.button duration:0.5f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self.button setTitleColor:[UIColor mswColorForTileNumber] forState:UIControlStateNormal];
            [self.button setTitle:surroundingMines forState:UIControlStateNormal];
        } completion:nil];

        return;
    }

    [self.button setTitle:nil forState:UIControlStateNormal];

    [self.surroundingTiles enumerateObjectsUsingBlock:^(MSWMineTile *mineTile, NSUInteger idx, BOOL *stop) {
        if (mineTile.isFlipped)
            return;

        CGFloat delay =  (arc4random() % 10) / 100.0f;
        [mineTile performSelector:@selector(touched) withObject:nil afterDelay:delay];
    }];

}

- (BOOL)touchedIterativeAction
{
    self.button.enabled = NO;
    self.flipped = YES;
    
    if (self.hasMine) {
        [UIView transitionWithView:self.button duration:0.5f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self.button setBackgroundImage:[UIImage mswImageForBombOverlay] forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
            [self.delegate mineTileTrippedMine:self];
        }];
    
        return NO;
    }

    CGFloat delay =  (arc4random() % 10) / 100.0f;

    BOOL isZero = self.numberOfMines == 0;
    if (!isZero) {
        [self performSelector:@selector(flipSurroundingMines) withObject:nil afterDelay:delay];
        return NO;
    }

    [self performSelector:@selector(flipFree) withObject:nil afterDelay:delay];
    
    return YES;
}

- (void)flipFree
{
    [self.button setBackgroundImage:[UIImage mswImageForFreeTile] forState:UIControlStateNormal];
    [self.button setTitle:nil forState:UIControlStateNormal];
}

- (void)flipSurroundingMines
{
    [self.button setBackgroundImage:[UIImage mswImageForFreeTile] forState:UIControlStateNormal];
    
    NSString *surroundingMines = [NSString stringWithFormat:@"%@", @(self.numberOfMines)];
    
    [UIView transitionWithView:self.button duration:0.5f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.button setTitleColor:[UIColor mswColorForTileNumber] forState:UIControlStateNormal];
        [self.button setTitle:surroundingMines forState:UIControlStateNormal];
    } completion:nil];
}

- (void)touchedIterative
{
    NSMutableArray *stackArray = [NSMutableArray new];

    [stackArray addObject:self];

    while(stackArray.count) {
        MSWMineTile *tile = stackArray[0];
        [stackArray removeObjectAtIndex:0];

        BOOL revealSurrounding = [tile touchedIterativeAction];
        if (!revealSurrounding)
            continue;

        [tile.surroundingTiles enumerateObjectsUsingBlock:^(MSWMineTile *mineTile, NSUInteger idx, BOOL *stop) {
            if (mineTile.isFlipped || mineTile.mine)
                return;

            [stackArray addObject:mineTile];
        }];
    }
}

- (void)showReveal:(BOOL)showReveal
{
    if (!self.hasMine)
        return;

    static CGFloat duration = 0.25f;
    static CGFloat minimumDelay = 1.25f;
    
    CGFloat delay =  (arc4random() % 50) / 100.0f;
    NSLog(@"delay: %f", delay);
    if (!showReveal) {
        [UIView animateWithDuration:duration delay:delay + minimumDelay options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.revealImageView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self.revealImageView removeFromSuperview];
        }];

        return;
    }

    self.revealImageView.alpha = 0.0f;
    [self.button addSubview:self.revealImageView];
    
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.revealImageView.alpha = 1.0f;
    } completion:nil];

}

#pragma mark -- Flag Animation

- (void)animateFlagIn:(BOOL)animateIn
{
    UIImage *image = [UIImage imageNamed:@"MSWTileFlagOverlay"];
    UIImageView *flagImageView = [[UIImageView alloc] initWithImage:image];

    flagImageView.contentMode = UIViewContentModeScaleAspectFit;

    flagImageView.frameWidth = 30.0f;
    flagImageView.frameHeight = 30.0f;
    
    CGFloat offScreenY = self.button.superview.bounds.origin.x - flagImageView.frameHeight;
    
    CGFloat centerDifferenceX = truncf(flagImageView.frameWidth / 2) - truncf(self.button.frameWidth / 2 );
    CGFloat centerDifferenceY = truncf(flagImageView.frameHeight /2 ) - truncf(self.button.frameHeight / 2);
    CGPoint alignCenterButtonPoint = CGPointMake(self.button.frameLeft - centerDifferenceX, self.button.frameTop - centerDifferenceY);
    
    if (animateIn) {
        flagImageView.frameTop = offScreenY;
        flagImageView.frameLeft = alignCenterButtonPoint.x;
        [self.button.superview addSubview:flagImageView];
        
        CGRect frame = flagImageView.frame;
        frame.origin = alignCenterButtonPoint;
        
        [self animateFlag:flagImageView toFrame:frame];
        return;
    }

    flagImageView.center = self.button.center;
    flagImageView.alpha = 0.0f;
    [self.button.superview addSubview:flagImageView];
    
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        flagImageView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        CGRect frame = flagImageView.frame;
        frame.origin.y = offScreenY;
        [self animateFlag:flagImageView toFrame:frame];
    }];
}

- (void)animateFlag:(UIImageView *)flagImageView toFrame:(CGRect)frame
{
    [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:0.75f initialSpringVelocity:0.25f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        flagImageView.frame = frame;
    } completion:^(BOOL finished) {
        [UIView transitionWithView:self.button duration:0.5f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.button.selected = !self.button.selected;
        } completion:nil];
        
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            flagImageView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [flagImageView removeFromSuperview];
        }];
    }];
}

#pragma mark - [Accessor Overrides]

- (BOOL)isErrorCondition
{
    return !self.flipped && !self.hasMine;
}

- (NSMutableArray *)surroundingTiles
{
    return _surroundingTiles != nil ? _surroundingTiles : (_surroundingTiles = [NSMutableArray new]);
}

- (UILabel *)revealLabel
{
    if (_revealLabel == nil) {
        _revealLabel = [[UILabel alloc] initWithFrame:self.button.bounds];
        _revealLabel.backgroundColor = [UIColor redColor];
        _revealLabel.textColor = [UIColor whiteColor];
        _revealLabel.text = @"X";
        _revealLabel.textAlignment = NSTextAlignmentCenter;
    }

    return _revealLabel;
}

- (UIImageView *)revealImageView
{
    if (_revealImageView == nil) {
        _revealImageView = [[UIImageView alloc] initWithImage:[UIImage mswImageForRevealOverlay]];
        _revealImageView.backgroundColor = [UIColor whiteColor];
        _revealImageView.frame = self.button.bounds;
    }

    return _revealImageView;
}

- (BOOL)isFlagged
{
    return self.button.selected;
}

@end
