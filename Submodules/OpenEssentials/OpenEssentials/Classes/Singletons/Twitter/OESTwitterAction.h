//
//  OESTwitterAction.h
//  OpenEssentials
//
//  Created by Gregory Carter on 10/13/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    OESTwitterActionFavorite = 0,
    OESTwitterActionUnfavorite = 1,
    OESTwitterActionRetweet = 2
} OESTwitterActionType;

@interface OESTwitterAction : NSObject
// Who's property are you?
@property (nonatomic, strong) NSString *twitterId;
@property (nonatomic, assign) OESTwitterActionType action;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, weak) id object;

// Public
- (NSString *)actionString;
@end
