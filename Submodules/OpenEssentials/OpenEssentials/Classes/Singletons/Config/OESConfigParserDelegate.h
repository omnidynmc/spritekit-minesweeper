//
//  OESConfigParserDelegate.h
//  OESShared
//
//  Created by Gregory Carter on 9/11/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OESConfigParserDelegate <NSObject>
- (void)configParserDidFinishParsing:(BOOL)loaded error:(NSError *)error;
@end
