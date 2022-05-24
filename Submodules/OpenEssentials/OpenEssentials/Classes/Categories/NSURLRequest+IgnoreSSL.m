//
//  NSURLRequest+IgnoreSSL.m
//  OpenEssentials
//
//  Created by Gregory Carter on 12/12/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import "NSURLRequest+IgnoreSSL.h"

@implementation NSURLRequest (IgnoreSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}

@end
