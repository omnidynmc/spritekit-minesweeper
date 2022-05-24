//
//  OESConfigVariable.m
//  DEToolsConfig
//
//  Created by Gregory Carter on 8/31/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import "OESConfigVariable.h"
#import "OESConfigDatatype.h"

@implementation OESConfigVariable

#pragma mark - OESConfigObject Overrides

- (NSArray *)authorizedKeys
{
    return @[ @"datatype", @"required" ];
}

#pragma mark - Public

- (BOOL)isValidField:(id)field error:(NSError **)error
{
    return [self.validator isValidField:field error:error];
}

- (NSDate *)parseDate
{
    return self.validator.parsedDate;
}

#pragma mark - NSObject Overrides

- (NSString *)description
{
    return [NSString stringWithFormat:@"OESConfigVariable name = %@, datatype = %@, required = %d, validator = %@", self.name, self.datatype, self.required, self.validator];
}

@end
