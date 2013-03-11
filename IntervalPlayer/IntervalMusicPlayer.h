//
//  IntervalMusicPlayer.h
//  IntervalPlayer
//
//  Created by Alicia Harder on 3/11/13.
//  Copyright (c) 2013 IntervalPlayer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IntervalPlayerMainViewController.h"

@interface IntervalMusicPlayer : NSObject
{
    // Variables are grouped alphabetically by type
    
    // A basic AVAudioPlayer used to play the beep heard when an interval switches
    AVAudioPlayer *beepPlayer;
    
    // A reference to the currently playing item. This is used to populate the song info labels
    AVPlayerItem *currentItem;
    
    // Used to determine if the player is playing or not; some methods react differently in each case
    Boolean intervalRunning;
    // Used to keep track of whether PlayPause is being called for the first time (if it is, it needs to behave slightly differently)
    Boolean justStarted;
    // There is a particular edge case (if a certain timer fires at a particular moment) in which beeping can continue even after the intervals have stopped; this flag prevents this
    Boolean stopBeeping;
}
@end
