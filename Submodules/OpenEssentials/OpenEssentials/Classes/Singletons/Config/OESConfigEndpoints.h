//
//  OESConfigEndpoints.h
//  OESShared
//
//  Created by Gregory Carter on 9/10/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OESConfigFramework.h"

@interface OESConfigEndpoints : OESConfigObject
@property (nonatomic, strong) NSString *gameDetails;
@property (nonatomic, strong) NSString *playByPlay;
@property (nonatomic, strong) NSString *shortPlayByPlay;
@property (nonatomic, strong) NSString *dailyScores;
@property (nonatomic, strong) NSString *roster;
@property (nonatomic, strong) NSString *teamScores;
@property (nonatomic, strong) NSString *leadersIPAD;
@property (nonatomic, strong) NSString *leadersIPHONE;
@property (nonatomic, strong) NSString *players;
@property (nonatomic, strong) NSString *teamLeaders;
@property (nonatomic, strong) NSString *teamLeadersByStat;
@property (nonatomic, strong) NSString *standings;
@property (nonatomic, strong) NSString *playerCard;
@property (nonatomic, strong) NSString *playerHeadshot;
@property (nonatomic, strong) NSString *teamLogo;
@end
