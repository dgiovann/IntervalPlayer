//
//  IntervalMusicPlayer.h
//  IntervalPlayer
//
//  Created by Daniel Giovannelli.
//  Copyright (c) 2013 IntervalPlayer. All rights reserved.
//
// IntervalMusicPlayer wraps two instances of AVQueuePlayer to switch between them at the defined intervals, and sends messages to update the view controller accordingly.

#import <Foundation/Foundation.h>
#import "AVQueuePlayerPrevious.h"

@class IntervalPlayerMainViewController;

@interface IntervalMusicPlayer : NSObject <AVAudioPlayerDelegate>
{
    // Variables are grouped alphabetically and by type
    
    // A basic AVAudioPlayer used to play the beep heard when an interval switches
    AVAudioPlayer *beepPlayer;
    
    
    // Used to determine if the player is playing or not; some methods react differently in each case
    Boolean intervalRunning;
    // Used to keep track of whether PlayPause is being called for the first time (if it is, it needs to behave slightly differently)
    Boolean justStarted;
    // There is a particular edge case (if a certain timer fires at a particular moment) in which beeping can continue even after the intervals have stopped; this flag prevents this
    Boolean stopBeeping;
    
    // This keeps track of when each interval starts, and resets with each interval. It is used to ensure that if the user pauses mid-interval, the interval will resume correctly (IE if the user pauses two seconds in to a five second interval, after resuming the itnerval will continue for another two seconds rather then re-setting to five).
    NSDate *timeTimerStarted;

    // Which interval is currently being used; keeps track of position in the timesForInterval array
    NSInteger currentIntervalIndex;
    // How often, in seconds, the intervals should switch
    NSInteger switchAfter;
    // How long, in seconds, the music should play before stopping
    NSInteger totalRunTime;
    
    // These arrays keep track of the items for the playlists. Specifically, they contain MPMediaItems generated from the URLs passed in by the flipside view controller
    NSMutableArray *oldItemsForInterval1;
    NSMutableArray *oldItemsForInterval2;
    NSMutableArray *itemsForInterval1;
    NSMutableArray *itemsForInterval2;
    // This array contains the times for the intervals. It is looped over to determine how often the playlists should switch
    NSMutableArray *timesForIntervals;
    
    // Which playlist is currently playing (1 or 2)
    NSNumber *currentInterval;
    
    // The time interval generated from the timeTimerStarted date object
    NSTimeInterval timeSinceStart;

    // This timer is used to switch playlists, it fires every switchAfter seconds
    NSTimer *intervalTimer;
    
    // This timer is used to stop playing and wrap everything up, it fires after totalRunTime seconds
    NSTimer *totalRunTimer;

    // The main view controller for the app
    IntervalPlayerMainViewController *mainController;
}
// The players for the two playlists
@property (nonatomic, strong) AVQueuePlayerPrevious *interval1;
@property (nonatomic, strong) AVQueuePlayerPrevious *interval2;
// The arrays of URLs passed in from the flipside view controller
@property (nonatomic, strong) NSMutableArray *intervalOneFromFlipside;
@property (nonatomic, strong) NSMutableArray *intervalTwoFromFlipside;


// The constructor
- (id)initForViewController:(IntervalPlayerMainViewController*) mainControllerIn;

// This method goes backwards in the current playlist (or to the beginning of the song if the song is more than 3 seconds in)
-(void)playPreviousSong;
// This method goes forwards in the current playlist
-(void)playNextSong;
// This method either starts, plays, or pauses the current playlist depending on the current state. seconds is used to keep track of how long to play for in total, it is assigned to totalRunTime
-(void)beginOrPlayPauseForTime:(NSInteger) seconds;
// This method adds an interval time to the array
-(void)addInterval:(NSNumber*)interval;
// This method clears both interval time arrays
-(void)clearAllIntervals;
// Switch the currently playing interval
-(void)switchInterval;
// Sets the playlists
-(void)setIntervalsWithIntervalOne:(NSMutableArray *)interval1 IntervalTwo:(NSMutableArray *)interval2;
// Terminate playing, wipe the playlists, reset the timers
-(void)endPlaying;
// Used after pausing to keep timers straight
-(void)resumeIntervalTimer;
// Notification posted when a song finishes playing to reset displayed info, etc
-(void)songFinished:(NSNotification *)notification;
// Plays/pauses; called by BeginOrPlayPause
-(void)playPause;
// used to keep interval times straight after a pause completes
-(void)resumeAfterPause;

@end
