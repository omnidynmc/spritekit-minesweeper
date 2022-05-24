//
//  OESURLConnection.h
//  OpenEssentials
//
//  Created by Gregory Carter on 11/26/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OESURLConnection : NSURLConnection <NSURLConnectionDelegate>
@property (nonatomic, strong) NSArray *trustedHosts;
@end
