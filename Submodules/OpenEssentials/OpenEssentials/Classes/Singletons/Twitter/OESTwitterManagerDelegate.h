//
//  OESTwitterManagerDelegate.h
//  OpenEssentials
//
//  Created by Gregory Carter on 10/13/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OESTwitterAction;

@protocol OESTwitterManagerDelegate <NSObject>
- (void)twitterFoundMultipleAccounts;
- (void)twitterPostDidSucceed:(NSDictionary *)response twitterAction:(OESTwitterAction *)twitterAction;
- (void)twitterPostDidFail:(NSDictionary *)response twitterAction:(OESTwitterAction *)twitterAction;
@end