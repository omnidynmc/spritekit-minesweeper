//
//  OESConfigParser.h
//  OESShared
//
//  Created by Gregory Carter on 8/31/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OESConfigParserDelegate.h"

@interface OESConfigParserAbstract : NSObject
@property (nonatomic, strong) NSMutableDictionary *objects;
@property (nonatomic, weak) id <OESConfigParserDelegate> delegate;

// Load Methods
- (BOOL)loadConfigFromURL:(NSURL *)url error:(NSError **)error;
- (BOOL)loadConfigFromURL:(NSURL *)url section:(NSString *)section error:(NSError **)error;
- (BOOL)loadConfigFromData:(NSData *)data error:(NSError **)error;
- (BOOL)loadConfigFromData:(NSData *)data section:(NSString *)section error:(NSError **)error;

// Abstract Methods
- (BOOL)processDictionaryFromConfig:(NSDictionary *)dictionary;
- (void)postFinishedParsing:(BOOL)loaded error:(NSError *)error;
@end
