//
//  IntervalMusicPlayer.m
//  IntervalPlayer
//
//  Created by Daniel Giovannelli.
//  Copyright (c) 2013 IntervalPlayer. All rights reserved.
//

#import "IntervalMusicPlayer.h"
#import "IntervalPlayerMainViewController.h"

@implementation IntervalMusicPlayer

@synthesize interval1 = _interval1;
@synthesize interval2 = _interval2;

- (id)initForViewController:(IntervalPlayerMainViewController*) mainControllerIn
{
    // Constructor - takes a view controller to send messages to on various events which require updating the UI (song paused, song playing, etc). In this case, it's just the main view controller.
    self = [super init];
    if (self) {
        
        mainController = mainControllerIn;

        // The following ten or so lines of code set the AVAudioSession category to 'Playback'. This allows the app to continue to play music in the backgorund if the user opens another app or the phone goes to sleep
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
        
        // Allocate and initialize arrays that will be used in the class
        intervalRunning = false;
        if (!itemsForInterval1){
            itemsForInterval1 = [[NSMutableArray alloc] init];
        }
        if (!itemsForInterval2){
            itemsForInterval2 = [[NSMutableArray alloc] init];
        }
        oldItemsForInterval1 = [[NSMutableArray alloc] init];
        oldItemsForInterval2 = [[NSMutableArray alloc] init];
 
        _intervalOneFromFlipside = [[NSMutableArray alloc] init];
        _intervalTwoFromFlipside = [[NSMutableArray alloc] init];
        
        // Load the beep sound file that will be played when the music switches
        NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"basicbeep"
                                                  withExtension:@"caf"];
        // Variables used along with the beep sound
        stopBeeping = false;
        beepPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
        beepPlayer.delegate = self;

        // Sign up to receive notifcations when a song finishes playing (used to start the next song)
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(songFinished:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];
        
        // Where the player is in the list of intervals being used to switch
        currentIntervalIndex = 0;
        timesForIntervals = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setIntervalsWithIntervalOne:(NSMutableArray *)firstinterval IntervalTwo:(NSMutableArray *)secondinterval
{
    // This method sets the intervals switched between to the NSMutableArrays being passed in (it assumes two NSMutableArrays of NSURLs pointing to AV items
    intervalRunning = false; // We're not currently running, so flag as such
    // We keep the lists of URLs used to initially populate the players. This is done because AVQueuePlayer (and thus AVQueuePlayerPrevious) pops items as they are played. These are used to re-create the playlists if the user wants to re-play them after they are done (since they only contain NSURLs instead of the AV items themselves, memory overhead is minimal)
    oldItemsForInterval1 = [firstinterval copyWithZone:nil];
    oldItemsForInterval2 = [secondinterval copyWithZone:nil];
    // Clear the old lists
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
    // generate new lists from the provided NSURLs
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
    // If new intervals have been populated, we don't want the info from the old intervals to be showing. This clears the info and resets the play/pause button to 'play' (as opposed to 'pause', which is visible when audio is playing)
    [mainController clearSongInfo];
    [mainController setPlayPauseButton:0];
    
}

-(void)beginInterruption
{
    // Called if an audio interruption (e.g. a phone call) arrives. If a player is playing, it is paused
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
    // Same as above, but plays the player
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
    // Called when a song finioshed playing, notifies MainViewController to update the song metadata to the next song. MainViewController then queries the IntervalMusicPlayer class for song info. This is more tightly-coupled then I'd like; I plan to refactor it apart when I have a chance.
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
    // Called after a time interval completes to switch between the two players
    // Increment (or reset) the current time interval
    if (currentIntervalIndex < [timesForIntervals count] - 1){
        currentIntervalIndex++;
    } else {
        currentIntervalIndex = 0;
    }

    // Set how long to play the player for to the next interval
    if ([timesForIntervals count] != 0){
        switchAfter = [[timesForIntervals objectAtIndex:currentIntervalIndex] intValue];
    } else {
        switchAfter = 0;
    }

    // Kill the old timer, 
    [intervalTimer invalidate];
    intervalTimer = nil;
    
    if (intervalRunning){
        if ([[_interval1 items] count] == 0 && [[_interval2 items] count] == 0)
        {
            // Stop the player if we're at the end of the playlist
            [self endPlaying];
        }
        if ([currentInterval isEqualToNumber:@1]){
            currentInterval = @2;
            // Stop the currently running interval
            [_interval1 pause];
            // The following if statement plays the other interval player if the tone switch is off. If the tone switch is on, the beep player is played, and the callback from the beep player then plays the other interval player. This is ugly, but necessary to keep the beep player from overlapping the music player
            if ([mainController.toneSwitch isOn] == true)
            {
                if (stopBeeping == false) {
                    // stopBeeping is flagged at the beginning and unflaggged at the end. This prevents a certain rare corner case in which the beep plays repeatedly, depending on the timing of when a song ends vs when the interval ends
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
            // Same as above, but with the interval values reversed
            currentInterval = @1;
            [_interval2 pause];
            if ([mainController.toneSwitch isOn] == true){
                if (stopBeeping == false) {
                    [beepPlayer performSelector:@selector(play) withObject:nil afterDelay:.25];
                }
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
    // This method is a callback triggered when an AVAudioPlayer finishes playing. It's triggered by both the beep player and the music players, and handles each differently
    if (intervalRunning) {
        if (player == beepPlayer)
        {
            // As described in the comments for switchInterval, the callback from beepPlayer switches the playing interval. This is necessary to keep the players from overlapping.
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
            // Each AVPlayer in the AVQueuePlayer triggers this method when it ends. This method is then switches the song metadata being displayed.
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
    // Called whenever the play/pause button is tapped
    if (intervalRunning == true){
        if ([currentInterval isEqualToNumber:@1]) {
            // Check if the music player is current playing
            if ([_interval1 rate] != 0.0) {
                // Pauses the music player
                [_interval1 pause];
                // NSTimers can't be paused. Thus, to ensure that pausing the music doesn't throw off the timing, the current timer must be destroyed, and then recreated with the remaining time when the music is played again.
                // This lime keeps track of how long the current item has been playing so that the timer can be reset from it
                timeSinceStart = [timeTimerStarted timeIntervalSinceNow];
                [intervalTimer invalidate]; // Stop the timer
                [mainController setPlayPauseButton:1]; // Change the visible button from pause to play
            } else {
                if ([[_interval1 items] count] > 0) {
                    // The player is paused, so check if we're not at the end of the queue. If so, play the player
                    [_interval1 play];
                    [mainController setSongInfoForPlayer:@1 atEnd:NO];
                    if (justStarted != true) {
                        if (switchAfter != 0) {
                            // Re-set the timer with the remaining time saved earlier
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
            // Same as before but with intervals reversed
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
                // If the current player is more than three seconds in to the song and we're not at the first song, we play the previous item. Otherwise, we seek to the start of the current song. This is consistent with common media player behavior
                [_interval1 playPreviousItem];
                [mainController setSongInfoForPlayer:@1 atEnd:NO];
            } else {
                // Jump to start of current song.
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
            // Jump to next song. If the last song is currently playing, this causes the music to stop
            [_interval1 advanceToNextItem];
            // See if we're at the end of the playlist (IE if there's 0 items left). If so, call the endplaying cleanup routine. If not, change the song metadata being displayed
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
    // This method is called at the beginning of playing intervals to set up everything
    // This is used to keep track of how long the intervals have been playing
    timeTimerStarted = [[NSDate alloc] init];
    // Sets starting interval - 1 by default, 2 if 1 is empty.
    if ([[_interval1 itemsForPlayer] count] != 0) {
        currentInterval = @1;
    } else if ([[_interval2 itemsForPlayer] count] != 0) {
        currentInterval = @2;
    } else {
        // This should never happen, as MainViewController will not let the start method be called if at least one interval is not present
        NSLog(@"Error in startIntervals");
    }
    intervalRunning = true;
    stopBeeping = false;
    justStarted = true;
    // Sets the first switch after value to the first interval time if interval times are present. If not, switchAfter is set to 0, which means the music will never switch
    if ([timesForIntervals count] != 0){
        switchAfter = [[timesForIntervals objectAtIndex:currentIntervalIndex] intValue];
    } else {
        switchAfter = 0;
    }
    // Call playPause to start playinh
    [self playPause];
    // Set up two timers - one to control when to switch which player is playing, the other to control when to stop the intervals altogether
    if (switchAfter != 0) {
        intervalTimer = [NSTimer scheduledTimerWithTimeInterval:switchAfter target:self selector:@selector(switchInterval) userInfo:nil repeats:NO];
    }
    if (totalRunTime != 0){
        totalRunTimer = [NSTimer scheduledTimerWithTimeInterval:totalRunTime target:self selector:@selector(endPlaying) userInfo:nil repeats:NO];
    }
}

-(void)resumeIntervalTimer{
    // Used to create a new timer with the remaining time on it after a paused element is played again.
    if (switchAfter != 0){
        intervalTimer = [NSTimer scheduledTimerWithTimeInterval:switchAfter target:self selector:@selector(switchInterval) userInfo:nil repeats:NO];
        timeTimerStarted = nil;
        timeTimerStarted = [[NSDate alloc] init];
    }
}

-(void) endPlaying
{
    // Pauses, zeroes out, and resets everything
    [mainController setPlayPauseButton:0];
    [intervalTimer invalidate];
    [totalRunTimer invalidate];
    [_interval1 pause];
    [_interval2 pause];
    [mainController clearSongInfo];
    [_interval1 removeAllItems];
    [_interval2 removeAllItems];
    [self setIntervalsWithIntervalOne:oldItemsForInterval1 IntervalTwo:oldItemsForInterval2];
    intervalRunning = false;
    stopBeeping = true;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    // This method handles commands coming in from the lock screen, triggering the appropriate methods
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
    // Wipe the interval times that have been set
    [timesForIntervals removeAllObjects];
    currentIntervalIndex = 0;
}
    
-(void)addInterval:(NSNumber*)interval
{
    // Add another interval time to the list at the end
    [timesForIntervals addObject:interval];
}

-(void)beginOrPlayPauseForTime:(NSInteger) seconds
{
    // This method is called by the begin/play/pause button in MainViewController
    if (intervalRunning == true)
    {
        // If we're already going, trigger play/pause
        [self playPause];
    } else {
        // Otherwise, start the run for the given amount of time
        totalRunTime = seconds;
        [self startIntervals];
    }
}

-(void)resumeAfterPause
{
    // This method is involved with resetting the timer after a pause
    timeTimerStarted = nil;
    timeTimerStarted = [[NSDate alloc] init];
    [self switchInterval];
}

@end
