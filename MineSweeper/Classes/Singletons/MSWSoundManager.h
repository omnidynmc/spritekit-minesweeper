//
//  MSWSoundManager.h
//  MineSweeper
//
//  Created by Gregory Carter on 8/30/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OESSharedInstance.h>

@interface MSWSoundManager : NSObject
OESSHARED_INSTANCE_H(MSWSoundManager *)
- (void)playExplosion;
- (void)playSoundOnce:(NSString *)sound;
@end
