//
//  OESTwitterAction.m
//  OpenEssentials
//
//  Created by Gregory Carter on 10/13/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import "OESTwitterAction.h"

@implementation OESTwitterAction

#pragma mark - Public

- (NSString *)actionString
{
    switch([self action]) {
        case OESTwitterActionFavorite:
            return @"favorite";
        case OESTwitterActionUnfavorite:
            return @"unfavorite";
        case OESTwitterActionRetweet:
            return @"retweet";
    } // switch
}

#pragma mark - NSObject Overrides

- (NSString *)description
{
    return [NSString stringWithFormat:@"OESTwitterAction twitterId = %@, action = %@, error = %@", self.twitterId, [self actionString], self.error];
}
@end
