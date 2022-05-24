//
//  MSWSoundManager.m
//  MineSweeper
//
//  Created by Gregory Carter on 8/30/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "MSWSoundManager.h"

@interface MSWSoundManager ()
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@end

@implementation MSWSoundManager

OESSHARED_INSTANCE(MSWSoundManager *)

#pragma mark - Public

- (void)playExplosion
{
    [self playSoundOnce:@"explosion.wav"];
}

- (void)playSoundOnce:(NSString *)sound
{
//    SystemSoundID soundID;
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
//    AudioServicesPlaySystemSound(soundID);

    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], sound]];


    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.audioPlayer.numberOfLoops = 0;

    [self.audioPlayer play];
}

@end
