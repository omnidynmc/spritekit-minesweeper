//
//  OESConfigVariable.h
//  OESShared
//
//  Created by Gregory Carter on 8/31/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OESConfigObject.h"

@class OESConfigDatatype;

@interface OESConfigVariable : OESConfigObject
@property (nonatomic, weak) OESConfigDatatype *validator;    // we don't own this but it will exist as long as we do
@property (nonatomic, strong) NSString *datatype;
@property (nonatomic, assign) BOOL required;
// Public
- (BOOL)isValidField:(id)field error:(NSError **)error;
- (NSDate *)parseDate;
@end
