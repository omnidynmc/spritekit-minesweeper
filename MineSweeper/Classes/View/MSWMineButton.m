//
//  MSWMineButton.m
//  MineSweeper
//
//  Created by Gregory Carter on 8/29/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import "MSWMineButton.h"

#import "UIImage+MSWAdditions.h"

@implementation MSWMineButton

#pragma mark - Class Methods

+ (instancetype)mswTileButton
{
    MSWMineButton *button = [[self class] buttonWithType:UIButtonTypeCustom];
    
    //button.layer.borderColor = [UIColor blackColor].CGColor;
    //button.layer.borderWidth = 3.0f;
    button.backgroundColor = [UIColor clearColor];

    [button setBackgroundImage:[UIImage mswImageForTileNormal] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage mswImageForTileHighlighted] forState:UIControlStateHighlighted];
    
    [button setImage:[UIImage mswImageForFlagOverlay] forState:UIControlStateSelected];
    [button setBackgroundImage:nil forState:UIControlStateSelected];

    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];

    button.imageEdgeInsets = UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f);

    return button;
}

#pragma mark - [Mutator Overrides]

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    self.alpha = enabled ? 1.0f : 0.9f;
}

@end
