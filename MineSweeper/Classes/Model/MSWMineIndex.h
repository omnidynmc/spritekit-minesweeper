//
//  MSWMineIndex.h
//  MineSweeper
//
//  Created by Gregory Carter on 8/27/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSWMineIndex : NSObject
@property (nonatomic, assign, readonly) NSInteger row;
@property (nonatomic, assign, readonly) NSInteger column;
+ (instancetype)mineIndexWithRow:(NSInteger)row column:(NSInteger)column;
@end
