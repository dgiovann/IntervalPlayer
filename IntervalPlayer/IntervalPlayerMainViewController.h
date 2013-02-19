//
//  IntervalPlayerMainViewController.h
//  IntervalPlayer
//
//  Created by Daniel Giovannelli on 1/11/13.
//  Copyright (c) 2013 Daniel Giovannelli. All rights reserved.
//

#import "IntervalPlayerFlipsideViewController.h"
#import "AVQueuePlayerPrevious.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface IntervalPlayerMainViewController : UIViewController <IntervalPlayerFlipsideViewControllerDelegate, MPMediaPickerControllerDelegate, UITextFieldDelegate, AVAudioPlayerDelegate>
{
    
    IBOutlet UIButton *playPauseButton;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *artistLabel;
    IBOutlet UILabel *albumLabel;
    
    int switchAfter;
    int totalRunTime;
    
    NSTimeInterval timeSinceStart;
    
    NSNumber *currentInterval;
    NSTimer *intervalTimer;
    NSTimer *totalRunTimer;

    Boolean intervalRunning;
    Boolean justStarted; 
    NSNumber *totalSecondToPlayFor;
    AVAudioPlayer *beepPlayer;

    NSDate *timeTimerStarted;
    
    NSString *title;
    NSString *artist;
    NSString *album;
    
    NSArray *metadataList;
    AVPlayerItem *currentItem;
}

@property (weak, nonatomic) IBOutlet UITextField *intervalTime;
@property (nonatomic, strong) NSMutableArray *itemsForInterval1;
@property (nonatomic, strong) NSMutableArray *itemsForInterval2;
@property (nonatomic, strong) AVQueuePlayerPrevious *interval1;
@property (nonatomic, strong) AVQueuePlayerPrevious *interval2;
@property (weak, nonatomic) IBOutlet UITextField *playForSeconds;
@property (weak, nonatomic) IBOutlet UITextField *playForMinutes;
@property (weak, nonatomic) IBOutlet UISwitch *toneSwitch;




-(IBAction)showInfo:(id)sender;
-(IBAction)previousSong:(id)sender;
-(IBAction)playPause:(id)sender;
-(IBAction)nextSong:(id)sender;
-(IBAction)startIntervals;

-(void)switchInterval;
-(void)setIntervalsWithIntervalOne:(NSMutableArray *)interval1 IntervalTwo:(NSMutableArray *)interval2;
-(void)endPlaying;
-(void)setSongInfoForPlayer:(NSNumber *)playerNumber;
-(void)resumeIntervalTimer;

@end
