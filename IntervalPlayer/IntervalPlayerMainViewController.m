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
@synthesize itemsForInterval1;
@synthesize itemsForInterval2;
@synthesize toneSwitch = _toneSwitch;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)aBundle
{
    self = [super initWithNibName:(NSString *)nibName bundle:(NSBundle *)aBundle];
    if (self) {
        
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
        if (itemsForInterval1 == nil){
            itemsForInterval1 = [[NSMutableArray alloc] init];
        }
        if (itemsForInterval2 == nil){
            itemsForInterval2 = [[NSMutableArray alloc] init];
        }
        NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"basicbeep"
                                                  withExtension:@"caf"];
        beepPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
        beepPlayer.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)switchInterval
{
    [intervalTimer invalidate];
    intervalTimer = nil;
    if ([currentInterval isEqualToNumber:@1]){
        NSLog(@"Interval 1 ending");
        currentInterval = @2;
        [self.interval1 pause];
        if ([_toneSwitch isOn] == true)
        {
            [beepPlayer performSelector:@selector(play) withObject:nil afterDelay:.25];
        } else {
            [self.interval2 play];
            [self setSongInfoForPlayer:@2];
            [self resumeIntervalTimer];
        }
    } else {
        NSLog(@"Interval 2 ending");
        currentInterval = @1;
        [self.interval2 pause];
        if ([_toneSwitch isOn] == true)
        {
            [beepPlayer performSelector:@selector(play) withObject:nil afterDelay:.25];
        } else {
            [self.interval1 play];
            [self setSongInfoForPlayer:@1];
            [self resumeIntervalTimer];
        }
    }
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (player == beepPlayer)
    {
        if ([currentInterval isEqualToNumber:@1])
        {
            [self.interval1 performSelector:@selector(play) withObject:nil afterDelay:.25];
            [self setSongInfoForPlayer:@1];
            [self resumeIntervalTimer];
        } else {
            [self.interval2 performSelector:@selector(play) withObject:nil afterDelay:.25];
            [self setSongInfoForPlayer:@2];
            [self resumeIntervalTimer];
        }
    }
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
        [itemsForInterval1 addObject:[AVPlayerItem playerItemWithURL:[[firstinterval objectAtIndex:i] valueForProperty:MPMediaItemPropertyAssetURL]]];
    }
    for (int i=0; i < [secondinterval count]; i++) {
        [itemsForInterval2 addObject:[AVPlayerItem playerItemWithURL:[[secondinterval objectAtIndex:i] valueForProperty:MPMediaItemPropertyAssetURL]]];
    }
    if (self.interval1 == nil) {
        self.interval1 = [AVQueuePlayerPrevious queuePlayerWithItems:itemsForInterval1];
    } else {
        [self.interval1 removeAllItems];
        self.interval1 = [AVQueuePlayerPrevious queuePlayerWithItems:itemsForInterval1];
    }
    if (self.interval2 == nil) {
        self.interval2 = [AVQueuePlayerPrevious queuePlayerWithItems:itemsForInterval2];
    } else {
        [self.interval2 removeAllItems];
        self.interval2 = [AVQueuePlayerPrevious queuePlayerWithItems:itemsForInterval2];
    }

}

- (IBAction)playPause:(id)sender
{
    if (intervalRunning == true){
        if ([currentInterval isEqualToNumber:@1]) {
            NSLog(@"playing 1");
            if ([self.interval1 rate] != 0.0) {
                [self.interval1 pause];
                timeSinceStart = [timeTimerStarted timeIntervalSinceNow];
                [intervalTimer invalidate];
                [playPauseButton setImage:[UIImage imageNamed:@"playButton.png"] forState:UIControlStateNormal];
            } else {
                [self.interval1 play];
                [self setSongInfoForPlayer:@1];
                if (justStarted != true) {
                    intervalTimer = [NSTimer scheduledTimerWithTimeInterval:switchAfter + timeSinceStart target:self selector:@selector(resumeIntervalTimer) userInfo:nil repeats:NO];
                } else {
                    justStarted = false;
                }
                [playPauseButton setImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];
            }
        } else {
            NSLog(@"playing 2");
            if ([self.interval2 rate] != 0.0) {
                [self.interval2 pause];
                timeSinceStart = [timeTimerStarted timeIntervalSinceNow];
                [intervalTimer invalidate];
                [playPauseButton setImage:[UIImage imageNamed:@"playButton.png"] forState:UIControlStateNormal];
            } else {
                [self.interval2 play];
                [self setSongInfoForPlayer:@2];
                if (justStarted != true) {
                    intervalTimer = [NSTimer scheduledTimerWithTimeInterval:switchAfter + timeSinceStart target:self selector:@selector(resumeIntervalTimer) userInfo:nil repeats:NO];
                } else {
                    justStarted = false;
                }
                [playPauseButton setImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];
            }
            
        }
    }
}

- (IBAction)previousSong:(id)sender
{
    if (intervalRunning == true){
        if ([currentInterval isEqualToNumber:@1]) {
            if ((CMTimeGetSeconds([interval1 currentTime]) <= 3) && (![interval1 isAtBeginning])) {
                [self.interval1 playPreviousItem];
                [self setSongInfoForPlayer:@1];
            } else {
                [self.interval1 seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            }
        } else {
            if ((CMTimeGetSeconds([interval2 currentTime]) <= 3) && (![interval2 isAtBeginning])) {
                [self.interval2 playPreviousItem];
                [self setSongInfoForPlayer:@2];
            } else {
                [self.interval2 seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            }
        }
    }
}

- (IBAction)nextSong:(id)sender
{
    if (intervalRunning == true){
        if ([currentInterval isEqualToNumber: @1]) {
            [self.interval1 advanceToNextItem];
            [self setSongInfoForPlayer:@1];
        } else {
            [self.interval2 advanceToNextItem];
            [self setSongInfoForPlayer:@2];
        }
    }
}


- (IBAction) startIntervals
{
    timeTimerStarted = [[NSDate alloc] init];
    currentInterval = @1;
    intervalRunning = true;
    justStarted = true;
    [self playPause:nil];
    switchAfter = [[intervalTime text]integerValue];
    if (switchAfter != 0) {
        intervalTimer = [NSTimer scheduledTimerWithTimeInterval:switchAfter target:self selector:@selector(switchInterval) userInfo:nil repeats:YES];
    }
    totalRunTime = [[playForSeconds text]integerValue] + ([[playForMinutes text]integerValue] * 60);
    if (totalRunTime != 0){
        totalRunTimer = [NSTimer scheduledTimerWithTimeInterval:totalRunTime target:self selector:@selector(endPlaying) userInfo:nil repeats:NO];
    }
}

-(void)resumeIntervalTimer{
    intervalTimer = [NSTimer scheduledTimerWithTimeInterval:switchAfter target:self selector:@selector(switchInterval) userInfo:nil repeats:YES];
    timeTimerStarted = nil;
    timeTimerStarted = [[NSDate alloc] init];
}

-(void) endPlaying
{
    [intervalTimer invalidate];
    [totalRunTimer invalidate];
    [self.interval1 pause];
    [self.interval2 pause];
    // Remove all items?
    intervalRunning = false;
    [playPauseButton setImage:[UIImage imageNamed:@"playButton.png"] forState:UIControlStateNormal];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldFinished:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


//Make sure we can recieve remote control events
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    //if it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlPlay) {
            [self playPause:nil];
        } else if (event.subtype == UIEventSubtypeRemoteControlPause) {
            [self playPause:nil];
        } else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
            [self playPause:nil];
        }
    }
}

-(void)setSongInfoForPlayer:(NSNumber *)playerNumber
{
    NSLog(@"Reached 2a");
    if([playerNumber isEqualToNumber:@1]){
        currentItem = self.interval1.currentItem;
    } else {
        currentItem = self.interval2.currentItem;
    }
    NSLog(@"Reached 2b");
    metadataList = [currentItem.asset commonMetadata];
    title = @"";
    artist = @"";
    album = @"";
    for (AVMetadataItem *metaItem in metadataList) {
        if ([[metaItem commonKey] isEqual: @"title"])
        {
            title = [metaItem stringValue];
        } else if ([[metaItem commonKey] isEqual: @"artist"]) {
            artist = [metaItem stringValue];
        } else if ([[metaItem commonKey] isEqual: @"albumName"]) {
            album = [metaItem stringValue];
        }
    }
    NSArray *keys = [NSArray arrayWithObjects:MPMediaItemPropertyTitle, MPMediaItemPropertyArtist, MPMediaItemPropertyAlbumTitle, nil];
    NSArray *values = [NSArray arrayWithObjects:title, artist, album, nil];
    NSDictionary *mediaInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
    [titleLabel setText:title];
    [artistLabel setText:artist];
    [albumLabel setText:album];
}

// ADD SHUFFLE MODE?

@end
