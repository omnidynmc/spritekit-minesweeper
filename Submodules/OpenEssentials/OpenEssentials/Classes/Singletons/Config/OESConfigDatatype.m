//
//  OESConfigDatatype.m
//  OESShared
//
//  Created by Gregory Carter on 8/31/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import "OESConfigDatatype.h"

@interface OESConfigDatatype ()
@property (nonatomic, strong) NSRegularExpression *regexCompiled;
// Validate Length
- (BOOL)isWithinMinLength:(NSString *)field;
- (BOOL)isWithinMaxLength:(NSString *)field;
// Validate Value
- (BOOL)isWithinMinValue:(NSNumber *)field;
- (BOOL)isWithinMaxValue:(NSNumber *)field;
// Validate Enum
- (BOOL)isWithinEnum:(NSString *)field;
// Validate Date
- (BOOL)isParsableDate:(NSString *)field;
// Accessors
- (NSDateFormatter *)dateFormatter;
@end

@implementation OESConfigDatatype

// we want one static date formatter to rule them all
static NSDateFormatter *OESConfigDateFormatter;

#pragma mark - Public


// Error codes:
//      - 500   Min length
//      - 501   Max length
//      - 502   Enum value
//      - 503   Date formatter
//      - 504   Regex mismatch
//      - 505   Min value
//      - 506   Max Value
- (BOOL)isValidField:(id)field error:(NSError **)error
{
    BOOL isStringCheckOk = [field isKindOfClass:[NSString class]];
    BOOL isNumberCheckOk = [field isKindOfClass:[NSNumber class]];

    // handle string fields
    if (isStringCheckOk) {
        if (![self isWithinMinLength:field]) {
            if (error != NULL)
                *error = [NSError OESConfigError:500 description:[NSString stringWithFormat:@"'%@' is not within minimum length %@", field, self.minLength]];
            return NO;
        } // if
        
        if (![self isWithinMaxLength:field]) {
            if (error != NULL)
                *error = [NSError OESConfigError:501 description:[NSString stringWithFormat:@"'%@' is not within maximum length %@", field, self.maxLength]];
            return NO;
        } // if
        
        if (![self isWithinEnum:field]) {
            if (error != NULL)
                *error = [NSError OESConfigError:502 description:[NSString stringWithFormat:@"'%@' is not within possible enum values %@", field, self.enumValue]];
            return NO;
        } // if
        
        // do these last for performance reasons
        if (![self isParsableDate:field]) {
            if (error != NULL)
                *error = [NSError OESConfigError:503 description:[NSString stringWithFormat:@"'%@' is not parsable date according to format %@", field, self.dateFormat]];
            return NO;
        } // if

        if (![self isWithinRegex:field]) {
            if (error != NULL)
                *error = [NSError OESConfigError:504 description:[NSString stringWithFormat:@"'%@' is not within regex match %@", field, self.regex]];
            return NO;
        } // if
    } // if

    // try number checks
    if (isNumberCheckOk) {
        if (![self isWithinMinValue:field]) {
            if (error != NULL)
                *error = [NSError OESConfigError:505 description:[NSString stringWithFormat:@"'%@' is not within minimum value %@", field, self.minValue]];
            return NO;
        } // if
        
        if (![self isWithinMaxValue:field]) {
            if (error != NULL)
                *error = [NSError OESConfigError:506 description:[NSString stringWithFormat:@"'%@' is not within maximum value %@", field, self.maxValue]];
            return NO;
        } // if
    } // if
    
    // either we passed our checks or none of them were applicable
    return YES;
}

#pragma mark - Private

#pragma mark -- Validate Length

- (BOOL)isWithinMinLength:(NSString *)field
{
    return self.minLength != nil ? ([field length]) >= [self.minLength intValue] : YES;
}

- (BOOL)isWithinMaxLength:(NSString *)field
{
    return self.maxLength != nil ? ([field length]) <= [self.maxLength intValue] : YES;
}

#pragma mark -- Validate Value

- (BOOL)isWithinMinValue:(NSNumber *)field
{
    NSInteger value = [field intValue];
    BOOL isSaneValue = value != INT_MAX && value != INT_MIN;
    if (!isSaneValue) return NO;
    
    return self.maxValue != nil ? (value >= [self.minValue intValue]) : YES;
}

- (BOOL)isWithinMaxValue:(NSNumber *)field
{
    NSInteger value = [field intValue];
    BOOL isSaneValue = value != INT_MAX && value != INT_MIN;
    if (!isSaneValue) return NO;

    return self.maxValue != nil ? (value <= [self.maxValue intValue]) : YES;
}

#pragma mark -- Validate Enum Against Value

- (BOOL)isWithinEnum:(NSString *)field
{
    if (self.enumValue == nil)
        return YES;

    for(NSString *name in self.enumValue) {
        if ([name isEqualToString:field]) return YES;
    } // for

    return NO;
}

#pragma mark - Validate Regex

- (BOOL)isWithinRegex:(NSString *)field
{
    if (self.regexCompiled == nil)
        return YES;

    NSRange range = [self.regexCompiled rangeOfFirstMatchInString:field options:0 range:NSMakeRange(0, [field length])];
    return range.location != NSNotFound;
}

#pragma mark - Validate Date Fields

- (BOOL)isParsableDate:(NSString *)field;
{
    self.parsedDate = nil;
    if (isEmpty(self.dateFormat))
        return YES;

    if (!isEmpty(self.dateTimezone))
        [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:self.dateTimezone]];
        
    [self.dateFormatter setDateFormat:self.dateFormat];
    self.parsedDate = [self.dateFormatter dateFromString:field];

    return self.parsedDate != nil;
}

#pragma mark - Overrides
#pragma mark -- OESConfigObject

- (NSArray *)authorizedKeys
{
    return @[ @"regex", @"minLength", @"maxLength", @"minValue", @"maxValue", @"enumValue", @"dateFormat", @"dateTimezone", @"caseSensitive" ];
}

#pragma mark -- NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"OESConfigDatatype name = %@, regex = %@, minLength = %@, maxLength = %@, minValue = %@, maxValue = %@, dateFormat = %@, enumValue = %@", self.name, self.regex, self.minLength, self.maxLength, self.minValue, self.maxValue, self.dateFormat, self.enumValue];
}

#pragma mark - Accessor Overrides

- (void)setRegex:(NSString *)regex
{
    self.regexCompiled = [NSRegularExpression
                                regularExpressionWithPattern:regex
                                options:0
                                error:nil];
    _regex = regex;
}

- (NSDateFormatter *)dateFormatter
{
    // since creating date formatter instances is heckof expensive, let's negociate the price down
    return OESConfigDateFormatter != nil ? OESConfigDateFormatter : (OESConfigDateFormatter = [NSDateFormatter new]);
}

@end
