//
//  MSWMineIndex.m
//  MineSweeper
//
//  Created by Gregory Carter on 8/27/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import "MSWMineIndex.h"

@interface MSWMineIndex ()
@property (nonatomic, assign, readwrite) NSInteger row;
@property (nonatomic, assign, readwrite) NSInteger column;
@end

@implementation MSWMineIndex

+ (instancetype)mineIndexWithRow:(NSInteger)row column:(NSInteger)column
{
    MSWMineIndex *mineIndex = [[self class] new];

    mineIndex.row = row;
    mineIndex.column = column;
    
    return mineIndex;
}

@end
