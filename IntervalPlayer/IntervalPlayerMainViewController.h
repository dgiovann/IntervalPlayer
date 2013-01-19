//
//  IntervalPlayerMainViewController.h
//  IntervalPlayer
//
//  Created by Daniel Giovannelli on 1/11/13.
//  Copyright (c) 2013 Daniel Giovannelli. All rights reserved.
//

#import "IntervalPlayerFlipsideViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface IntervalPlayerMainViewController : UIViewController <IntervalPlayerFlipsideViewControllerDelegate, MPMediaPickerControllerDelegate>
{
    IBOutlet UIButton *playPauseButton;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *artistLabel;
    IBOutlet UILabel *albumLabel;
    NSNumber *currentInterval;
    NSTimer *intervalTimer;
    NSTimer *totalRunTimer;
    Boolean intervalRunning;
    NSNumber *totalSecondToPlayFor;
}

@property (weak, nonatomic) IBOutlet UITextField *intervalTime;
@property (nonatomic, retain) NSMutableArray *itemsForInterval1;
@property (nonatomic, retain) NSMutableArray *itemsForInterval2;
@property (nonatomic, retain) AVQueuePlayer *interval1;
@property (nonatomic, retain) AVQueuePlayer *interval2;
@property (weak, nonatomic) IBOutlet UITextField *playForSeconds;
@property (weak, nonatomic) IBOutlet UITextField *playForMinutes;
@property (nonatomic, retain) AVQueuePlayer *temp;

-(NSNumber*)switchInterval;
-(void)setIntervalsWithIntervalOne:(NSMutableArray *)interval1 IntervalTwo:(NSMutableArray *)interval2;
-(IBAction)showInfo:(id)sender;
-(IBAction)previousSong:(id)sender;
-(IBAction)playPause:(id)sender;
-(IBAction)nextSong:(id)sender;
-(void)endPlaying;
-(IBAction) startIntervals;

// Move this elsewhere, maybe?

-(NSMutableArray*)arrayWithTitleArtistAndAlbumForTrack:(AVPlayerItem*)track;

@end
