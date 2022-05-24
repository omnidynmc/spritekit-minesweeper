//
//  NSDate+OESAdditions.m
//  OpenEssentials
//
//  Created by Gregory Carter on 2/28/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import "NSDate+OESAdditions.h"

@implementation NSDate (OESAdditions)

- (NSString *)dateElapsedFromNow
{
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];

    // Create the NSDates
    NSDate *dateNow = [[NSDate alloc] init];

    // Get conversion to months, days, hours, minutes
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSSecondCalendarUnit;

    NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:self  toDate:dateNow  options:0];

    //DNSLog(@"Conversion: %dsecond %dmin %dhours %ddays %dmonths", [conversionInfo second], [conversionInfo minute], [conversionInfo hour], [conversionInfo day], [conversionInfo month]);

    NSMutableString *elapsed = [NSMutableString new];

    if ([conversionInfo month] || [conversionInfo day]) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"d MMM"];

        elapsed = [NSMutableString stringWithString:[dateFormatter stringFromDate:self]];
    } // else if
    else if ([conversionInfo hour]) {
        [elapsed appendFormat:@"%dh ", [conversionInfo hour]];
    } // else if
    else if ([conversionInfo minute]) {
        [elapsed appendFormat:@"%dm ", [conversionInfo minute]];
    } // else if
    else if ([conversionInfo second]) {
        [elapsed appendFormat:@"%ds ", [conversionInfo second]];
    } // else if

    //[elapsed appendFormat:@"ago"];
    return elapsed;
}

+ (NSString *)oesTimeSinceUnixtime:(NSTimeInterval)unixtime fromNow:(BOOL)fromNow limit:(NSUInteger)limit
{
    NSArray *chunks = @[
        @[ @(60 * 60 * 24 * 365), @"Year" ],
        @[ @(60 * 60 * 24 * 30), @"Month" ],
        @[ @(60 * 60 * 24 * 7), @"Week" ],
        @[ @(60 * 60 * 24), @"Day" ],
        @[ @(60 * 60), @"Hour" ],
        @[ @(60), @"Minute" ],
        @[ @(1), @"Second" ]
    ];
    
    NSTimeInterval now = [[NSDate new] timeIntervalSince1970];
    NSTimeInterval since = fromNow ? (now - unixtime) : unixtime;


    NSMutableString *sinceString = [NSMutableString new];
    
    // j saves performing the count function each time around the loop
    NSUInteger k = 0;
    for (NSUInteger i = 0; i < chunks.count; ++i) {
        NSTimeInterval seconds = [chunks[i][0] integerValue];
        NSString *name = chunks[i][1];

        NSUInteger count = floor(since / seconds);
        if (count != 0) {
          since -= count * seconds;
          if (k > 0)
            [sinceString appendString:@" "];
            
          [sinceString appendFormat:@"%d %@%@", count, name, count > 1 ? @"s" : @""];
          ++k;

            if (limit != 0 && k > limit - 1)
                break;
        } // if
        

      } // for
      
    return sinceString;
}

@end
