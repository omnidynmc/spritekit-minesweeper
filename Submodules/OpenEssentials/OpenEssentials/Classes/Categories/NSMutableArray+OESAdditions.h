//
//  NSMutableArray+OESAdditions.h
//  OpenEssentials
//
//  Created by Gregory Carter on 3/7/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (OESAdditions)
- (BOOL)oesContainsString:(NSString *)string;
- (BOOL)oesContainsNumber:(NSNumber *)number;
@end
