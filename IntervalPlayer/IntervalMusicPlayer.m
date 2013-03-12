//
//  IntervalMusicPlayer.m
//  IntervalPlayer
//
//  Created by Alicia Harder on 3/11/13.
//  Copyright (c) 2013 IntervalPlayer. All rights reserved.
//

#import "IntervalMusicPlayer.h"
#import "IntervalPlayerMainViewController.h"

@implementation IntervalMusicPlayer

@synthesize interval1 = _interval1;
@synthesize interval2 = _interval2;

- (id)initForViewController:(IntervalPlayerMainViewController*) mainControllerIn
{
    self = [super init];
    if (self) {
        
        mainController = mainControllerIn;

        [[AVAudioSession sharedInstance] setDelegate: self];
        
        NSError *setCategoryError = nil;
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryError];
        
        if (setCategoryError) {
            NSLog(@"Error setting category! %@", [setCategoryError localizedDescription]);
        }
        
        NSError *activationError = nil;
        [[AVAudioSession sharedInstance] setActive: YES error: &activationError];
        if (activationError) {
            NSLog(@"Could not activate audio session. %@", [activationError localizedDescription]);
        }
        
        intervalRunning = false;
        if (!itemsForInterval1){
            itemsForInterval1 = [[NSMutableArray alloc] init];
        }
        if (!itemsForInterval2){
            itemsForInterval2 = [[NSMutableArray alloc] init];
        }
        NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"basicbeep"
                                                  withExtension:@"caf"];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(songFinished:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];
        _intervalOneFromFlipside = [[NSMutableArray alloc] init];
        _intervalTwoFromFlipside = [[NSMutableArray alloc] init];
        stopBeeping = false;
        beepPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
        beepPlayer.delegate = self;
        
        currentIntervalIndex = 0;
        timesForIntervals = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Flipside View

- (void)setIntervalsWithIntervalOne:(NSMutableArray *)firstinterval IntervalTwo:(NSMutableArray *)secondinterval
{
    intervalRunning = false;
    [itemsForInterval1 removeAllObjects];
    [itemsForInterval2 removeAllObjects];
    if (_interval1) {
        [_interval1 pause];
        [_interval1 removeAllItems];
    }
    if (_interval2) {
        [_interval2 pause];
        [_interval2 removeAllItems];
    }
    for (int i=0; i < [firstinterval count]; i++) {
        if([AVPlayerItem playerItemWithURL:[[firstinterval objectAtIndex:i] valueForProperty:MPMediaItemPropertyAssetURL]]){
            [itemsForInterval1 addObject:[AVPlayerItem playerItemWithURL:[[firstinterval objectAtIndex:i] valueForProperty:MPMediaItemPropertyAssetURL]]];
        }
    }
    for (int i=0; i < [secondinterval count]; i++) {
        if([AVPlayerItem playerItemWithURL:[[secondinterval objectAtIndex:i] valueForProperty:MPMediaItemPropertyAssetURL]]){
            [itemsForInterval2 addObject:[AVPlayerItem playerItemWithURL:[[secondinterval objectAtIndex:i] valueForProperty:MPMediaItemPropertyAssetURL]]];
        }
    }
    if (!_interval1) {
        _interval1 = [AVQueuePlayerPrevious queuePlayerWithItems:itemsForInterval1];
    } else {
        for (int x=0; x < [itemsForInterval1 count]; x++) {
            [_interval1 insertItem:[itemsForInterval1 objectAtIndex:x] afterItem:nil];
        }
    }
    if (!_interval2) {
        _interval2 = [AVQueuePlayerPrevious queuePlayerWithItems:itemsForInterval2];
    } else {
        for (int x=0; x < [itemsForInterval2 count]; x++) {
            [_interval2 insertItem:[itemsForInterval2 objectAtIndex:x] afterItem:nil];
        }
    }
    [mainController clearSongInfo];
    [mainController setPlayPauseButton:0];
    
}

-(void)beginInterruption
{
    if ([currentInterval isEqualToNumber:@1]) {
        if ([_interval1 rate] != 0.0) {
            [_interval1 pause];
        }
    }
    if ([currentInterval isEqualToNumber:@2]) {
        if ([_interval2 rate] != 0.0) {
            [_interval2 pause];
        }
    }
}

-(void)endInterruption
{
    if ([currentInterval isEqualToNumber:@1]) {
        [_interval1 play];
    } else if ([currentInterval isEqualToNumber:@2]) {
        [_interval2 play];
    } else {
        NSLog(@"currentInterval error in EndInterruption");
    }
}
-(void)songFinished:(NSNotification *)notification
{
    if ([currentInterval isEqualToNumber:@1])
    {
        [mainController setSongInfoForPlayer:@1 atEnd:YES];
    } else if ([currentInterval isEqualToNumber:@2]) {
        [mainController setSongInfoForPlayer:@2 atEnd:YES];
    } else {
        NSLog(@"currentInterval error in songFinished:");
    }
}

- (void)switchInterval
{
    if (currentIntervalIndex < [timesForIntervals count] - 1){
        currentIntervalIndex++;
    } else {
        currentIntervalIndex = 0;
    }
    if ([timesForIntervals count] != 0){
        switchAfter = [[timesForIntervals objectAtIndex:currentIntervalIndex] intValue];
    } else {
        switchAfter = 0;
    }

    [intervalTimer invalidate];
    intervalTimer = nil;
    if (intervalRunning){
        if ([[_interval1 items] count] == 0 && [[_interval2 items] count] == 0)
        {
            [self endPlaying];
        }
        if ([currentInterval isEqualToNumber:@1]){
            currentInterval = @2;
            [_interval1 pause];
            if ([mainController.toneSwitch isOn] == true)
            {
                if (stopBeeping == false) {
                    [beepPlayer performSelector:@selector(play) withObject:nil afterDelay:.25];
                }
            } else {
                if ([[_interval2 items] count] > 0){
                    [_interval2 play];
                    [mainController setSongInfoForPlayer:@2 atEnd:NO];
                }
                [self resumeIntervalTimer];
            }
        } else if ([currentInterval isEqualToNumber:@2]) {
            currentInterval = @1;
            [_interval2 pause];
            if ([mainController.toneSwitch isOn] == true){
                [beepPlayer performSelector:@selector(play) withObject:nil afterDelay:.25];
            } else {
                if ([[_interval1 items] count] > 0){
                    [_interval1 play];
                    [mainController setSongInfoForPlayer:@1 atEnd:NO];
                }
                [self resumeIntervalTimer];
            }
        } else {
            NSLog(@"currentInterval error in switchInterval");
        }
    }
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (intervalRunning) {
        if (player == beepPlayer)
        {
            if ([currentInterval isEqualToNumber:@1])
            {
                if ([[_interval1 items] count] > 0){
                    [_interval1 performSelector:@selector(play) withObject:nil afterDelay:.25];
                    [mainController setSongInfoForPlayer:@1 atEnd:NO];
                }
                [self resumeIntervalTimer];
            } else if ([currentInterval isEqualToNumber:@2]) {
                if ([[_interval2 items] count] > 0){
                    [_interval2 performSelector:@selector(play) withObject:nil afterDelay:.25];
                    [mainController setSongInfoForPlayer:@2 atEnd:NO];
                }
                [self resumeIntervalTimer];
            } else {
                NSLog(@"currentInterval error in audioPlayerDidFinishPlaying:");
            }
        } else {
            if ([currentInterval isEqualToNumber:@1])
            {
                [mainController setSongInfoForPlayer:@1 atEnd:NO];
            } else if ([currentInterval isEqualToNumber:@2]) {
                [mainController setSongInfoForPlayer:@2 atEnd:NO];
            } else {
                NSLog(@"currentInterval error in audioPlayerDidFinishPlaying: 2");
            }
        }
    }
}


- (void)playPause
{
    if (intervalRunning == true){
        if ([currentInterval isEqualToNumber:@1]) {
            if ([_interval1 rate] != 0.0) {
                [_interval1 pause];
                timeSinceStart = [timeTimerStarted timeIntervalSinceNow];
                [intervalTimer invalidate];
                [mainController setPlayPauseButton:1];
            } else {
                if ([[_interval1 items] count] > 0) {
                    [_interval1 play];
                    [mainController setSongInfoForPlayer:@1 atEnd:NO];
                    if (justStarted != true) {
                        if (switchAfter != 0) {
                            float switchTime = switchAfter + timeSinceStart;
                            intervalTimer = [NSTimer scheduledTimerWithTimeInterval:switchTime target:self selector:@selector(resumeAfterPause) userInfo:nil repeats:NO];
                        }
                    } else {
                        justStarted = false;
                    }
                    [mainController setPlayPauseButton:2];
                }
            }
        } else if ([currentInterval isEqualToNumber:@2]) {
            if ([_interval2 rate] != 0.0) {
                [_interval2 pause];
                timeSinceStart = [timeTimerStarted timeIntervalSinceNow];
                [intervalTimer invalidate];
                [mainController setPlayPauseButton:1];
            } else {
                if ([_interval2 items] != 0) {
                    [_interval2 play];
                    [mainController setSongInfoForPlayer:@2 atEnd:NO];
                    if (justStarted != true) {
                        if (switchAfter != 0){
                            float switchTime = switchAfter + timeSinceStart;
                            intervalTimer = [NSTimer scheduledTimerWithTimeInterval:switchTime target:self selector:@selector(resumeAfterPause) userInfo:nil repeats:NO];
                        }
                    } else {
                        justStarted = false;
                    }
                    [mainController setPlayPauseButton:2];
                }
            }
        } else {
            NSLog(@"currentInterval error in playPause");
        }
    }
}

- (void)playPreviousSong
{
    if (intervalRunning == true){
        if ([currentInterval isEqualToNumber:@1]) {
            if ((CMTimeGetSeconds([_interval1 currentTime]) <= 3) && ([_interval1 isAtBeginning] != YES)) {
                [_interval1 playPreviousItem];
                [mainController setSongInfoForPlayer:@1 atEnd:NO];
            } else {
                [_interval1 seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            }
        } else if ([currentInterval isEqualToNumber:@2]) {
            if ((CMTimeGetSeconds([_interval2 currentTime]) <= 3) && ([_interval2 isAtBeginning] != YES)) {
                [_interval2 playPreviousItem];
                [mainController setSongInfoForPlayer:@2 atEnd:NO];
            } else {
                [_interval2 seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            }
        } else {
            NSLog(@"currentInterval playPreviousSong");
        }
    }
}

- (void)playNextSong
{
    if (intervalRunning == true){
        if ([currentInterval isEqualToNumber: @1]) {
            [_interval1 advanceToNextItem];
            if ([[_interval1 items] count] > 0){
                [mainController setSongInfoForPlayer:@1 atEnd:NO];
            } else {
                [self endPlaying];
            }
        } else if ([currentInterval isEqualToNumber:@2]) {
            [_interval2 advanceToNextItem];
            if ([[_interval2 items] count] > 0){
                [mainController setSongInfoForPlayer:@2 atEnd:NO];
            } else {
                [self endPlaying];
            }
        } else {
            NSLog(@"currentInterval error in playNextSong");
        }
    }
}

- (void)startIntervals
{
    timeTimerStarted = [[NSDate alloc] init];
    if ([[_interval1 itemsForPlayer] count] != 0) {
        currentInterval = @1;
    } else if ([[_interval2 itemsForPlayer] count] != 0) {
        currentInterval = @2;
    } else {
        NSLog(@"Error in startIntervals");
    }
    intervalRunning = true;
    stopBeeping = false;
    justStarted = true;
    if ([timesForIntervals count] != 0){
        switchAfter = [[timesForIntervals objectAtIndex:currentIntervalIndex] intValue];
    } else {
        switchAfter = 0;
    }
    [self playPause];
    if (switchAfter != 0) {
        intervalTimer = [NSTimer scheduledTimerWithTimeInterval:switchAfter target:self selector:@selector(switchInterval) userInfo:nil repeats:NO];
    }
    if (totalRunTime != 0){
        totalRunTimer = [NSTimer scheduledTimerWithTimeInterval:totalRunTime target:self selector:@selector(endPlaying) userInfo:nil repeats:NO];
    }
}

-(void)resumeIntervalTimer{
    if (switchAfter != 0){
        intervalTimer = [NSTimer scheduledTimerWithTimeInterval:switchAfter target:self selector:@selector(switchInterval) userInfo:nil repeats:NO];
        timeTimerStarted = nil;
        timeTimerStarted = [[NSDate alloc] init];
    }
}

-(void) endPlaying
{
    [mainController setPlayPauseButton:0];
    [intervalTimer invalidate];
    [totalRunTimer invalidate];
    [_interval1 pause];
    [_interval2 pause];
    [mainController clearSongInfo];
    [_interval1 removeAllItems];
    [_interval2 removeAllItems];
    intervalRunning = false;
    stopBeeping = true;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    //if it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlPlay) {
            [self playPause];
        } else if (event.subtype == UIEventSubtypeRemoteControlPause) {
            [self playPause];
        } else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
            [self playPause];
        } else if (event.subtype == UIEventSubtypeRemoteControlNextTrack) {
            [self playNextSong];
        } else if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack) {
            [self playPreviousSong];
        }
    }
}

-(void)clearAllIntervals
{
    [timesForIntervals removeAllObjects];
    currentIntervalIndex = 0;
}
    
-(void)addInterval:(NSNumber*)interval
{
    [timesForIntervals addObject:interval];
}

-(void)beginOrPlayPauseForTime:(NSInteger) seconds
{
    if (intervalRunning == true)
    {
        [self playPause];
    } else {
        totalRunTime = seconds;
        [self startIntervals];
    }
}

-(void)resumeAfterPause
{
    timeTimerStarted = nil;
    timeTimerStarted = [[NSDate alloc] init];
    [self switchInterval];
}

@end
