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

@synthesize playForMinutes = _playForMinutes;
@synthesize playForSeconds = _playForSeconds;
@synthesize interval1 = _interval1;
@synthesize interval2 = _interval2;
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
        intervalOneFromFlipside = [[NSMutableArray alloc] init];
        intervalTwoFromFlipside = [[NSMutableArray alloc] init];
        stopBeeping = false;
        beepPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
        beepPlayer.delegate = self;
        
        currentIntervalIndex = 0;
        timesForIntervals = [[NSMutableArray alloc] init];
        intervalAlert = [[UIAlertView alloc] initWithTitle:@"New Interval Length" message:@"Please input the new interval length (in seconds)" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
        clearAlert = [[UIAlertView alloc] initWithTitle:@"Clear Interval?" message:@"Are you sure that you want to clear the set intervals? This operation cannot be undone." delegate:self cancelButtonTitle:@"Do Not Clear" otherButtonTitles:@"Clear", nil];
        clearAlert.alertViewStyle = UIAlertViewStyleDefault;
        intervalAlert.alertViewStyle = UIAlertViewStylePlainTextInput;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(IntervalPlayerFlipsideViewController *)controller
{
    intervalOneFromFlipside = [controller intervalOne];
    intervalTwoFromFlipside = [controller intervalTwo];
    [self setIntervalsWithIntervalOne:[controller intervalOne] IntervalTwo:[controller intervalTwo]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showInfo:(id)sender
{
    IntervalPlayerFlipsideViewController *controller = [[IntervalPlayerFlipsideViewController alloc] initWithNibName:@"IntervalPlayerFlipsideViewController" bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    controller.intervalOne = [[NSMutableArray alloc] initWithArray:intervalOneFromFlipside];
    controller.intervalTwo = [[NSMutableArray alloc] initWithArray:intervalTwoFromFlipside];
    [self presentViewController:controller animated:YES completion:nil];
}

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
    [self clearSongInfo];
    [playPauseButton setImage:[UIImage imageNamed:@"begin_button.png"] forState:UIControlStateNormal];

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
    } else {
        [_interval2 play];
    }
}
-(void)songFinished:(NSNotification *)notification
{
    if ([currentInterval isEqualToNumber:@1])
    {
        [self setSongInfoForPlayer:@1 atEnd:YES];
    } else {
        [self setSongInfoForPlayer:@2 atEnd:YES];
    }
}

- (void)switchInterval
{
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
            if ([_toneSwitch isOn] == true)
            {
                if (stopBeeping == false) {
                    [beepPlayer performSelector:@selector(play) withObject:nil afterDelay:.25];
                }
            } else {
                if ([[_interval2 items] count] > 0){
                    [_interval2 play];
                    [self setSongInfoForPlayer:@2 atEnd:NO];
                }
                [self resumeIntervalTimer];
            }
        } else {
            currentInterval = @1;
            [_interval2 pause];
            if ([_toneSwitch isOn] == true){
                [beepPlayer performSelector:@selector(play) withObject:nil afterDelay:.25];
            } else {
                if ([[_interval1 items] count] > 0){
                    [_interval1 play];
                    [self setSongInfoForPlayer:@1 atEnd:NO];
                }
                [self resumeIntervalTimer];
                
            }
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
                    [self setSongInfoForPlayer:@1 atEnd:NO];
                }
                [self resumeIntervalTimer];
            } else {
                if ([[_interval2 items] count] > 0){
                    [_interval2 performSelector:@selector(play) withObject:nil afterDelay:.25];
                    [self setSongInfoForPlayer:@2 atEnd:NO];
                }
                [self resumeIntervalTimer];
            }
        } else {
            if ([currentInterval isEqualToNumber:@1])
            {
                    [self setSongInfoForPlayer:@1 atEnd:NO];
            } else {
                    [self setSongInfoForPlayer:@2 atEnd:NO];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)playPause
{
    if (intervalRunning == true){
        if ([currentInterval isEqualToNumber:@1]) {
            if ([_interval1 rate] != 0.0) {
                [_interval1 pause];
                timeSinceStart = [timeTimerStarted timeIntervalSinceNow];
                [intervalTimer invalidate];
                [playPauseButton setImage:[UIImage imageNamed:@"play_button.png"] forState:UIControlStateNormal];
            } else {
                if ([[_interval1 items] count] > 0) {
                    [_interval1 play];
                    [self setSongInfoForPlayer:@1 atEnd:NO];
                    if (justStarted != true) {
                        if (switchAfter != 0){
                            intervalTimer = [NSTimer scheduledTimerWithTimeInterval:switchAfter + timeSinceStart target:self selector:@selector(resumeIntervalTimer) userInfo:nil repeats:NO];
                        }
                    } else {
                        justStarted = false;
                    }
                    [playPauseButton setImage:[UIImage imageNamed:@"pause_button.png"] forState:    UIControlStateNormal];
                    }
                }
        } else {
            if ([_interval2 rate] != 0.0) {
                [self.interval2 pause];
                timeSinceStart = [timeTimerStarted timeIntervalSinceNow];
                [intervalTimer invalidate];
                [playPauseButton setImage:[UIImage imageNamed:@"play_button.png"] forState:UIControlStateNormal];
            } else {
                if ([_interval2 items] != 0) {
                    [_interval2 play];
                    [self setSongInfoForPlayer:@2 atEnd:NO];
                    if (justStarted != true) {
                        if (switchAfter != 0){
                            intervalTimer = [NSTimer scheduledTimerWithTimeInterval:switchAfter + timeSinceStart target:self selector:@selector(resumeIntervalTimer) userInfo:nil repeats:NO];
                        }
                    } else {
                        justStarted = false;
                    }
                    [playPauseButton setImage:[UIImage imageNamed:@"pause_button.png"] forState:UIControlStateNormal];
                }
            }
        }
    }
}

- (IBAction)previousSong:(id)sender
{
    if (intervalRunning == true){
        if ([currentInterval isEqualToNumber:@1]) {
            if ((CMTimeGetSeconds([_interval1 currentTime]) <= 3) && ([_interval1 isAtBeginning] != YES)) {
                  [_interval1 playPreviousItem];
                [self setSongInfoForPlayer:@1 atEnd:NO];
            } else {
                [_interval1 seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            }
        } else {
            if ((CMTimeGetSeconds([_interval2 currentTime]) <= 3) && ([_interval2 isAtBeginning] != YES)) {
                [_interval2 playPreviousItem];
                [self setSongInfoForPlayer:@2 atEnd:NO];
            } else {
                [_interval2 seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            }
        }
    }
}

- (IBAction)nextSong:(id)sender
{
    if (intervalRunning == true){
        if ([currentInterval isEqualToNumber: @1]) {
            [_interval1 advanceToNextItem];
            if ([[_interval1 items] count] > 0){
                [self setSongInfoForPlayer:@1 atEnd:NO];
            } else {
                [self endPlaying];
            }
        } else {
            [_interval2 advanceToNextItem];
            if ([[_interval2 items] count] > 0){
                [self setSongInfoForPlayer:@2 atEnd:NO];
            } else {
                [self endPlaying];
            }
        }
    }
}

- (void)startIntervals
{
    timeTimerStarted = [[NSDate alloc] init];
    if ([[_interval1 itemsForPlayer] count] != 0) {
        currentInterval = @1;
    } else {
        currentInterval = @2;
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
    totalRunTime = [[_playForSeconds text]integerValue] + ([[_playForMinutes text]integerValue] * 60);
    if (totalRunTime != 0){
        totalRunTimer = [NSTimer scheduledTimerWithTimeInterval:totalRunTime target:self selector:@selector(endPlaying) userInfo:nil repeats:NO];
    }
}

-(void)resumeIntervalTimer{
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
    if (switchAfter != 0){
        intervalTimer = [NSTimer scheduledTimerWithTimeInterval:switchAfter target:self selector:@selector(switchInterval) userInfo:nil repeats:NO];
        timeTimerStarted = nil;
        timeTimerStarted = [[NSDate alloc] init];
    }
}

-(void) endPlaying
{
    [playPauseButton setImage:[UIImage imageNamed:@"begin_button.png"] forState:UIControlStateNormal];
    [intervalTimer invalidate];
    [totalRunTimer invalidate];
    [_interval1 pause];
    [_interval2 pause];
    [self clearSongInfo];
    [_interval1 removeAllItems];
    [_interval2 removeAllItems];
    intervalRunning = false;
    stopBeeping = true;
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
            [self playPause];
        } else if (event.subtype == UIEventSubtypeRemoteControlPause) {
            [self playPause];
        } else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
            [self playPause];
        } else if (event.subtype == UIEventSubtypeRemoteControlNextTrack) {
            [self nextSong:nil];
        } else if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack) {
            [self previousSong:nil];
        }
    }
}

-(void)setSongInfoForPlayer:(NSNumber *)playerNumber atEnd:(Boolean)atEnd
{
    if (atEnd == NO) {
        if([playerNumber isEqualToNumber:@1]){
            currentItem = _interval1.currentItem;
        } else {
            currentItem = _interval2.currentItem;
        }
    } else {
        if([playerNumber isEqualToNumber:@1]){
            currentItem = [_interval1.itemsForPlayer objectAtIndex:[_interval1 getIndex] + 1];
        } else {
            currentItem = [_interval2.itemsForPlayer objectAtIndex:[_interval2 getIndex] + 1];
        }
    }
    metadataList = [currentItem.asset commonMetadata];
    title = @"Title";
    artist = @"Artist";
    album = @"Album";
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

-(void)clearSongInfo
{
    NSArray *keys = [NSArray arrayWithObjects:MPMediaItemPropertyTitle, MPMediaItemPropertyArtist, MPMediaItemPropertyAlbumTitle, nil];
    NSArray *values = [NSArray arrayWithObjects:@"Title", @"Artist", @"Album", nil];
    NSDictionary *mediaInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
    [titleLabel setText:@"Title"];
    [artistLabel setText:@"Artist"];
    [albumLabel setText:@"Album"];
}

- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0) {
        return YES;
    }
    NSCharacterSet *forbiddenCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if ([forbiddenCharSet characterIsMember:c]) {
            return YES;
        }
    }
    return NO;
}

-(IBAction)beginOrPlayPause:(id)sender
{
    if ([[_interval1 itemsForPlayer] count] == 0 && [[_interval2 itemsForPlayer] count] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Playlists Created"
                                                        message:@"You have not created any playlists yet. Press the 'Create Playlists' button to do so."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        if (intervalRunning == true)
        {
            [self playPause];
        } else {
            [self startIntervals];
        }
    }
}

-(IBAction)addInterval:(id)sender
{
    [intervalAlert show];
    // Pop-up a box, have the user input a number, set newInterval to that number.
}

-(void)alertView:(UIAlertView*) alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:intervalAlert]) {
        if (buttonIndex == 1) {
            UITextField *newIntervalLengthTextField = [intervalAlert textFieldAtIndex:0];
            NSNumber *newInterval = [[NSNumber alloc] initWithInt:[[newIntervalLengthTextField text] intValue]];
            [timesForIntervals addObject:newInterval];
            if ([[intervalTimesLabel text] isEqualToString:@"No Interval Times Set"]){
                [intervalTimesLabel setText:[newInterval stringValue]];
                [newIntervalLengthTextField setText:@""];
            } else {
                NSString *currentText = [intervalTimesLabel text];
                currentText = [currentText stringByAppendingString:@", "];
                currentText = [currentText stringByAppendingString:[newInterval stringValue]];
                [intervalTimesLabel setText:currentText];
                [newIntervalLengthTextField setText:@""];
            }
        }
        
    } else if ([alertView isEqual:clearAlert]){
        if (buttonIndex == 1){
            [timesForIntervals removeAllObjects];
            currentIntervalIndex = 0;
            [intervalTimesLabel setText:@"No Interval Times Set"];
        }
    }
}

-(IBAction)clearIntervals:(id)sender
{
    [clearAlert show];
}

@end
