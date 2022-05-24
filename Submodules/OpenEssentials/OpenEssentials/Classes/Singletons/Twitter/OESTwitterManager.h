//
//  OESTwitterManager.h
//  OpenEssentials
//
//  Created by Gregory Carter on 10/13/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OESTwitterManagerDelegate.h"

@interface OESTwitterManager : NSObject <UIActionSheetDelegate>
@property (nonatomic, assign, getter=isAllowAccountChoice) BOOL allowAccountChoice;
@property (nonatomic, strong) NSArray *delegates;

// Initializers
OESSHARED_INSTANCE_H(OESTwitterManager *)

- (BOOL)registerDelegate:(id <OESTwitterManagerDelegate>)delegate;
- (BOOL)unregisterDelegate:(id <OESTwitterManagerDelegate>)delegate;

- (void)postRetweet:(NSString *)idStr object:(id)object;
- (void)postFavorite:(NSString *)idStr object:(id)object;
- (void)postUnfavorite:(NSString *)idStr object:(id)object;
- (void)postToTwitterApi:(NSString *)urlString twitterAction:(OESTwitterAction *)twitterAction;

@end
