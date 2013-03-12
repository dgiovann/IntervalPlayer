//
//  IntervalMusicPlayer.h
//  IntervalPlayer
//
//  Created by Alicia Harder on 3/11/13.
//  Copyright (c) 2013 IntervalPlayer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVQueuePlayerPrevious.h"

@class IntervalPlayerMainViewController;

@interface IntervalMusicPlayer : NSObject <AVAudioPlayerDelegate>
{
    // Variables are grouped alphabetically by type
    
    // A basic AVAudioPlayer used to play the beep heard when an interval switches
    AVAudioPlayer *beepPlayer;
    
    
    // Used to determine if the player is playing or not; some methods react differently in each case
    Boolean intervalRunning;
    // Used to keep track of whether PlayPause is being called for the first time (if it is, it needs to behave slightly differently)
    Boolean justStarted;
    // There is a particular edge case (if a certain timer fires at a particular moment) in which beeping can continue even after the intervals have stopped; this flag prevents this
    Boolean stopBeeping;
    
    NSDate *timeTimerStarted;
    
    NSInteger currentIntervalIndex;
    NSInteger switchAfter;
    
    NSInteger totalRunTime;
    
    NSMutableArray *itemsForInterval1;
    NSMutableArray *itemsForInterval2;
    NSMutableArray *timesForIntervals;
    
    NSNumber *currentInterval;
    NSNumber *totalSecondToPlayFor;
    
    NSTimeInterval timeSinceStart;

    NSTimer *intervalTimer;
    NSTimer *totalRunTimer;

    IntervalPlayerMainViewController *mainController;
}

@property (nonatomic, strong) AVQueuePlayerPrevious *interval1;
@property (nonatomic, strong) AVQueuePlayerPrevious *interval2;
@property (nonatomic, strong) NSMutableArray *intervalOneFromFlipside;
@property (nonatomic, strong) NSMutableArray *intervalTwoFromFlipside;

-(void)playPreviousSong;
-(void)playNextSong;
-(void)beginOrPlayPauseForTime:(NSInteger) seconds;

-(void)addInterval:(NSNumber*)interval;
-(void)clearAllIntervals;

- (id)initForViewController:(IntervalPlayerMainViewController*) mainControllerIn;

-(void)switchInterval;
-(void)setIntervalsWithIntervalOne:(NSMutableArray *)interval1 IntervalTwo:(NSMutableArray *)interval2;
-(void)endPlaying;
-(void)resumeIntervalTimer;
-(void)songFinished:(NSNotification *)notification;
-(void)playPause;

-(void)resumeAfterPause;

@end
