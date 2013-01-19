//
//  IntervalPlayerMainViewController.m
//  IntervalPlayer
//
//  Created by Daniel Giovannelli on 1/11/13.
//  Copyright (c) 2013 Daniel Giovannelli. All rights reserved.
//

#import "IntervalPlayerMainViewController.h"

@interface IntervalPlayerMainViewController ()

@end

@implementation IntervalPlayerMainViewController
@synthesize intervalTime;
@synthesize playForMinutes;
@synthesize playForSeconds;
@synthesize interval1;
@synthesize interval2;
@synthesize temp;
@synthesize itemsForInterval1;
@synthesize itemsForInterval2;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)aBundle
{
        self = [super initWithNibName:(NSString *)nibName bundle:(NSBundle *)aBundle];
        if (self) {
            intervalRunning = false;
            if (itemsForInterval1 == nil){
                itemsForInterval1 = [[NSMutableArray alloc] init];
            }
            if (itemsForInterval2 == nil){
                itemsForInterval2 = [[NSMutableArray alloc] init];
            }
        }
        return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (NSNumber*)switchInterval
{
    if (currentInterval == @1){
        NSLog(@"Interval 1 ending");
        currentInterval = @2;
        [interval1 pause];
        [interval2 play];
    } else {
        NSLog(@"Interval 2 ending");
        currentInterval = @1;
        [interval2 pause];
        [interval1 play];
    }
    return currentInterval;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(IntervalPlayerFlipsideViewController *)controller
{
    [self setIntervalsWithIntervalOne:[controller intervalOne] IntervalTwo:[controller intervalTwo]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showInfo:(id)sender
{    
    IntervalPlayerFlipsideViewController *controller = [[IntervalPlayerFlipsideViewController alloc] initWithNibName:@"IntervalPlayerFlipsideViewController" bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)setIntervalsWithIntervalOne:(NSMutableArray *)firstinterval IntervalTwo:(NSMutableArray *)secondinterval
{
    for (int i=0; i < [firstinterval count]; i++) {
        [itemsForInterval1 addObject:[AVPlayerItem playerItemWithURL:[firstinterval objectAtIndex:i]]];
    }
    for (int i=0; i < [secondinterval count]; i++) {
        [itemsForInterval2 addObject:[AVPlayerItem playerItemWithURL:[secondinterval objectAtIndex:i]]];
    }
    interval1 = [AVQueuePlayer queuePlayerWithItems:itemsForInterval1];
    interval2 = [AVQueuePlayer queuePlayerWithItems:itemsForInterval2];

}

- (IBAction)playPause:(id)sender
{
    if (intervalRunning == true){
        if (currentInterval == @1) {
            NSLog(@"playing 1");
            if ([interval1 rate] != 0.0) {
                [interval1 pause];
                [playPauseButton setImage:[UIImage imageNamed:@"playButton.png"] forState:UIControlStateNormal];
            } else {
                [interval1 play];
                [self arrayWithTitleArtistAndAlbumForTrack:interval1.currentItem];
                [playPauseButton setImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];
            }
        } else {
            NSLog(@"playing 2");
            if ([interval2 rate] != 0.0) {
                [interval2 pause];
                [playPauseButton setImage:[UIImage imageNamed:@"playButton.png"] forState:UIControlStateNormal];
            } else {
                [interval2 play];
                [self arrayWithTitleArtistAndAlbumForTrack:interval2.currentItem];
                [playPauseButton setImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];
            }
            
        }
    }
}

- (IBAction)previousSong:(id)sender
{
    if (intervalRunning == true){
        if (currentInterval == @1) {
            [interval1 seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        } else {
            [interval2 seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        }
    }
}

- (IBAction)nextSong:(id)sender
{
    if (intervalRunning == true){
        if (currentInterval == @1) {
            [interval1 advanceToNextItem];
        } else {
            [interval2 advanceToNextItem];
        }
    }
}

- (IBAction) startIntervals
{
    currentInterval = @1;
    intervalRunning = true;
    [self playPause:nil];
    intervalTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(switchInterval) userInfo:nil repeats:YES];
    #warning Commented out for debugging - put these back in!
//    intervalTimer = [NSTimer scheduledTimerWithTimeInterval:[[intervalTime text]integerValue] target:self selector:@selector(switchInterval) userInfo:nil repeats:YES];
//    int totalRunTime = [[playForSeconds text]integerValue] + ([[playForMinutes text]integerValue] * 60);
    int totalRunTime = 1000;
    totalRunTimer = [NSTimer scheduledTimerWithTimeInterval:totalRunTime target:self selector:@selector(endPlaying) userInfo:nil repeats:NO];
}

-(void) endPlaying
{
    [intervalTimer invalidate];
    [totalRunTimer invalidate];
    [interval1 pause];
    [interval2 pause];
    // Remove all items?
    intervalRunning = false;
    [playPauseButton setImage:[UIImage imageNamed:@"playButton.png"] forState:UIControlStateNormal];
}

-(NSMutableArray*)arrayWithTitleArtistAndAlbumForTrack:(AVPlayerItem*)track
{
    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:3];
    NSArray *metadataList = [track.asset commonMetadata];
    for (AVMetadataItem *metaItem in metadataList) {
        
    }
    return returnArray;
}

// ADD SHUFFLE MODE?

@end
