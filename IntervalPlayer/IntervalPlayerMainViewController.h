//
//  IntervalPlayerMainViewController.h
//  IntervalPlayer
//
//  Created by Daniel Giovannelli on 1/11/13.
//  Copyright (c) 2013 Daniel Giovannelli. All rights reserved.
//

#import "IntervalPlayerFlipsideViewController.h"
#import "AVQueuePlayerPrevious.h"

@interface IntervalPlayerMainViewController : UIViewController <IntervalPlayerFlipsideViewControllerDelegate, MPMediaPickerControllerDelegate, UITextFieldDelegate, AVAudioPlayerDelegate>
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

    // IBOutlets for each UI element that will be changed (text or button images)
    IBOutlet UILabel *albumLabel;
    IBOutlet UILabel *artistLabel;
    IBOutlet UILabel *intervalTimesLabel;
    IBOutlet UIButton *nextButton;
    IBOutlet UIButton *playPauseButton;
    IBOutlet UIButton *previousButton;
    IBOutlet UILabel *titleLabel;

    NSArray *metadataList;

    NSDate *timeTimerStarted;

    NSInteger currentIntervalIndex;
    NSInteger switchAfter;
    NSInteger totalRunTime;

    NSMutableArray *intervalOneFromFlipside;
    NSMutableArray *intervalTwoFromFlipside;
    NSMutableArray *itemsForInterval1;
    NSMutableArray *itemsForInterval2;
    NSMutableArray *timesForIntervals;

    NSNumber *currentInterval;
    NSNumber *totalSecondToPlayFor;
    
    NSString *album;
    NSString *artist;
    NSString *title;
    
    NSTimeInterval timeSinceStart;
    
    NSTimer *intervalTimer;
    NSTimer *totalRunTimer;
    
    UIAlertView *clearAlert;
    UIAlertView *intervalAlert;
    
}

@property (nonatomic, strong) AVQueuePlayerPrevious *interval1;
@property (nonatomic, strong) AVQueuePlayerPrevious *interval2;
@property (weak, nonatomic) IBOutlet UITextField *playForSeconds;
@property (weak, nonatomic) IBOutlet UITextField *playForMinutes;
@property (weak, nonatomic) IBOutlet UISwitch *toneSwitch;



-(IBAction)addInterval:(id)sender;
-(IBAction)clearIntervals:(id)sender;
-(IBAction)showInfo:(id)sender;
-(IBAction)previousSong:(id)sender;
-(IBAction)nextSong:(id)sender;
-(IBAction)beginOrPlayPause:(id)sender;

-(void)switchInterval;
-(void)setIntervalsWithIntervalOne:(NSMutableArray *)interval1 IntervalTwo:(NSMutableArray *)interval2;
-(void)endPlaying;
-(void)setSongInfoForPlayer:(NSNumber *)playerNumber atEnd:(Boolean)atEnd;
-(void)resumeIntervalTimer;
-(void)songFinished:(NSNotification *)notification;
-(void)playPause;

@end
