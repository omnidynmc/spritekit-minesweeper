//
//  OESConfigDatatype.h
//  OESShared
//
//  Created by Gregory Carter on 8/31/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OESConfigObject.h"

@interface OESConfigDatatype : OESConfigObject
- (BOOL)isValidField:(NSString *)field error:(NSError **)error;
// Supported Validations
@property (nonatomic, strong) NSString *regex;
@property (nonatomic, strong) NSNumber *minLength;
@property (nonatomic, strong) NSNumber *maxLength;
@property (nonatomic, strong) NSNumber *minValue;
@property (nonatomic, strong) NSNumber *maxValue;
@property (nonatomic, strong) NSArray *enumValue;
@property (nonatomic, strong) NSString *dateFormat;
@property (nonatomic, strong) NSString *dateTimezone;
@property (nonatomic, assign) BOOL caseSensitive;
@property (nonatomic, strong) NSDate *parsedDate;
@end
