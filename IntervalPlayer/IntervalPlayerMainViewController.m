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

@synthesize toneSwitch = _toneSwitch;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)aBundle
{
    self = [super initWithNibName:(NSString *)nibName bundle:(NSBundle *)aBundle];
    if (self) {
        
        musicPlayer = [[IntervalMusicPlayer alloc] initForViewController:self];

        intervalAlert = [[UIAlertView alloc] initWithTitle:@"New Interval Length" message:@"Please input the new interval length (in seconds)" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
        clearAlert = [[UIAlertView alloc] initWithTitle:@"Clear Interval?" message:@"Are you sure that you want to clear the set intervals? This operation cannot be undone." delegate:self cancelButtonTitle:@"Do Not Clear" otherButtonTitles:@"Clear", nil];
        clearAlert.alertViewStyle = UIAlertViewStyleDefault;
        intervalAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        newIntervalLengthTextField = [intervalAlert textFieldAtIndex:0];
        newIntervalLengthTextField.keyboardType = UIKeyboardTypeNumberPad;
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
    musicPlayer.intervalOneFromFlipside = [controller intervalOne];
    musicPlayer.intervalTwoFromFlipside = [controller intervalTwo];
    [musicPlayer setIntervalsWithIntervalOne:[controller intervalOne] IntervalTwo:[controller intervalTwo]];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showInfo:(id)sender
{
    IntervalPlayerFlipsideViewController *controller = [[IntervalPlayerFlipsideViewController alloc] initWithNibName:@"IntervalPlayerFlipsideViewController" bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    controller.intervalOne = [[NSMutableArray alloc] initWithArray:musicPlayer.intervalOneFromFlipside];
    controller.intervalTwo = [[NSMutableArray alloc] initWithArray:musicPlayer.intervalTwoFromFlipside];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)previousSong:(id)sender
{
    [musicPlayer playPreviousSong];
}

- (IBAction)nextSong:(id)sender
{
    [musicPlayer playNextSong];
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

-(void)setSongInfoForPlayer:(NSNumber *)playerNumber atEnd:(Boolean)atEnd
{
    if (atEnd == NO) {
        if ([playerNumber isEqualToNumber:@1]){
            currentItem = musicPlayer.interval1.currentItem;
        } else if ([playerNumber isEqualToNumber:@2]) {
            currentItem = musicPlayer.interval2.currentItem;
        } else {
            NSLog(@"PlayerNumber error in setSongInfoForPlayer");
        }
    } else {
        if([playerNumber isEqualToNumber:@1]){
            currentItem = [musicPlayer.interval1.itemsForPlayer objectAtIndex:[musicPlayer.interval1 getIndex] + 1];
        } else if ([playerNumber isEqualToNumber:@2]) {
            currentItem = [musicPlayer.interval2.itemsForPlayer objectAtIndex:[musicPlayer.interval2 getIndex] + 1];
        } else {
            NSLog(@"PlayerNumber error in setSongInfoForPlayer");
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
    if ([[musicPlayer.interval1 itemsForPlayer] count] == 0 && [[musicPlayer.interval2 itemsForPlayer] count] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Playlists Created"
                                                        message:@"You have not created any playlists yet. Press the 'Create Playlists' button to do so."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        NSInteger totalRunTime = [[playForSeconds text]integerValue] + ([[playForMinutes text]integerValue] * 60);
        [musicPlayer beginOrPlayPauseForTime:totalRunTime];
    }
}

-(IBAction)addInterval:(id)sender
{
    [intervalAlert show];
    
}

-(void)alertView:(UIAlertView*) alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:intervalAlert]) {
        if (buttonIndex == 1) {
            NSNumber *newInterval = [[NSNumber alloc] initWithInt:[[newIntervalLengthTextField text] intValue]];
            [musicPlayer addInterval:newInterval];
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
            [musicPlayer clearAllIntervals];
            [intervalTimesLabel setText:@"No Interval Times Set"];
        }
    }
}

-(IBAction)clearIntervals:(id)sender
{
    [clearAlert show];
}

-(void)setPlayPauseButton:(NSInteger)setTo {
    
    if (setTo == 0) {
        [playOrPauseButton setImage:[UIImage imageNamed:@"begin_button.png"] forState:UIControlStateNormal];
    } else if (setTo == 1) {
        [playOrPauseButton setImage:[UIImage imageNamed:@"play_button.png"] forState:UIControlStateNormal];
    } else if (setTo == 2) {
        [playOrPauseButton setImage:[UIImage imageNamed:@"pause_button.png"] forState:UIControlStateNormal];
    } else {
        NSLog(@"setPlayPauseButton error");
    }
  
}

- (void)viewDidUnload {
    playOrPauseButton = nil;
    [super viewDidUnload];
}

@end
