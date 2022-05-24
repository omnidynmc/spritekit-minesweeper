//
//  NSString+URLEncode.m
//  OpenEssentials
//
//  Created by Gregory Carter on 11/24/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import "NSString+URLEncode.h"

@implementation NSString (URLEncode)

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
			   (CFStringRef)self,
			   NULL,
			   (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
			   CFStringConvertNSStringEncodingToEncoding(encoding));
}

@end
