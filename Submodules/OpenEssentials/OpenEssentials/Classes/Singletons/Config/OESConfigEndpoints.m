//
//  OESConfigEndpoints.m
//  OESShared
//
//  Created by Gregory Carter on 9/10/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import "OESConfigEndpoints.h"

@implementation OESConfigEndpoints
- (BOOL)processUnauthorizedKey:(NSString *)key value:(id)value error:(NSError **)error
{
    // we'll handle everything
    if (![value isKindOfClass:[OESConfigEndpoint class]])
        return NO;
        
    OESConfigEndpoint *endpoint = value;
    NSString *url = [endpoint url];
    
    return [self trySetterForKey:key value:url error:error];
}

- (NSArray *)authorizedKeys
{
    return nil;
}

#pragma mark - NSObject Overrides

- (NSString *)description
{
    return [NSString stringWithFormat:@"OESConfigEndpoints gameDetails = %@, playByPlay = %@, shortPlayByPlay = %@, dailyScores = %@, roster = %@, teamScores = %@, leadersIPAD = %@, leadersIPHONE = %@, players = %@, teamLeaders = %@, teamLeadersByStat = %@, standings = %@, playerCard = %@, playerHeadshot = %@, teamLogo = %@", self.gameDetails, self.playByPlay, self.shortPlayByPlay, self.dailyScores, self.roster, self.teamScores, self.leadersIPAD, self.leadersIPHONE, self.players, self.teamLeaders, self.teamLeadersByStat, self.standings, self.playerCard, self.playerHeadshot, self.teamLogo];
}

@end
