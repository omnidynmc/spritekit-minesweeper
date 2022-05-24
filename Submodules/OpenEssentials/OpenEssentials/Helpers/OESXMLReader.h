//
//  OESXMLReader.h
//  OpenEssentials
//
//  Created by Gregory Carter on 11/9/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OESXMLReader : NSObject <NSXMLParserDelegate>
+ (NSDictionary *)objectWithData:(NSData *)data error:(NSError **)error;
@end
