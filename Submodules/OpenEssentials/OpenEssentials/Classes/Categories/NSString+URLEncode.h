//
//  NSString+URLEncode.h
//  OpenEssentials
//
//  Created by Gregory Carter on 11/24/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLEncode)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
@end
