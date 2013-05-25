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
    // Standard constructor for a view controller
    self = [super initWithNibName:(NSString *)nibName bundle:(NSBundle *)aBundle];
    if (self) {
        
        // musicPlayer is an instance of IntervalMusicPlayer; it will handle the audio playing
        musicPlayer = [[IntervalMusicPlayer alloc] initForViewController:self];

        // Setting up alerts (pop-up textboxes) for inputting and clearing intervals
        intervalAlert = [[UIAlertView alloc] initWithTitle:@"New Interval Length" message:@"Please input the new interval length (in seconds)" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
        intervalAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        newIntervalLengthTextField = [intervalAlert textFieldAtIndex:0];
        newIntervalLengthTextField.keyboardType = UIKeyboardTypeNumberPad; // Setting the keyboard for the alert
        clearAlert = [[UIAlertView alloc] initWithTitle:@"Clear Interval?" message:@"Are you sure that you want to clear the set intervals? This operation cannot be undone." delegate:self cancelButtonTitle:@"Do Not Clear" otherButtonTitles:@"Clear", nil];
        clearAlert.alertViewStyle = UIAlertViewStyleDefault;
    }
    return self;
 }

- (void)viewDidLoad
{

    [super viewDidLoad];
    // Allows the mainViewController to act as a remote control receiver, which allows the app to be controlled by the lock screen using the music player buttons
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    // Makes the view controller the first responder, to allow for use of text boxes
    [self becomeFirstResponder];
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(IntervalPlayerFlipsideViewController *)controller
{
    // This method is called when the flipside is dismissed. It sets the two playlists in musicPlayer to be the playlists built in the flipside view controller. Ideally musicPlayer would be a parameter, but since this method is overridden that is not possible
    musicPlayer.intervalOneFromFlipside = [controller intervalOne];
    musicPlayer.intervalTwoFromFlipside = [controller intervalTwo];
    [musicPlayer setIntervalsWithIntervalOne:[controller intervalOne] IntervalTwo:[controller intervalTwo]];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showInfo:(id)sender
{
    // This method is called when the 'create playlists' button is pressed; it presents the flipside view
    IntervalPlayerFlipsideViewController *controller = [[IntervalPlayerFlipsideViewController alloc] initWithNibName:@"IntervalPlayerFlipsideViewController" bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    // This pre-sets the intervals in the flipside to the existing intervals, so intervals are not overwritten when the user opens the flipside view
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

// The following two methods are overridden. By implementing these methods, the text field will lose focus when the user taps somewhere else on the screen
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
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
    // This method sets the info for the currently playing song to display, both on the app itself and on the lock screen
    // First, we grab the song currently playing
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
    // Now we pull the metadata from the current song, and set default values for title, artist, and album
    metadataList = [currentItem.asset commonMetadata];
    title = @"Title";
    artist = @"Artist";
    album = @"Album";
    // The metadatalist now contains key/value pairs for our song metadata. Metadatalist is an array, but the position of each piece of metadata within the list can vary based on the file, so we iterate over the metadata, checking each element and setting the value strings accordingly.
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
    // Now we create a new list of string/value pairs to pass to the MPNowPlayingInfoCenter. This makes the info show up on the lock screen/main screen music player just like the native music player would, as well as in the app itself
    NSArray *keys = [NSArray arrayWithObjects:MPMediaItemPropertyTitle, MPMediaItemPropertyArtist, MPMediaItemPropertyAlbumTitle, nil];
    NSArray *values = [NSArray arrayWithObjects:title, artist, album, nil];
    NSDictionary *mediaInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
    // Set the labels in the app itself
    [titleLabel setText:title];
    [artistLabel setText:artist];
    [albumLabel setText:album];
}

-(void)clearSongInfo
{
    // This method simply resets the displayed song labels to Title, Artist, and Album
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
    // This is a boilerplate method that ensures that only numeric characters can be put in a text field, by iterating over any changes to the text field and checking if each character is numeric. This prevents errors that can be cause by non-numeric input to the interval player.
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
    // This method is called when the begin/play/pause button is tapped. If both playlists are empty, an alert tells the user that he or she must create intervals
    if ([[musicPlayer.interval1 itemsForPlayer] count] == 0 && [[musicPlayer.interval2 itemsForPlayer] count] == 0)
    {
        emptyAlert = [[UIAlertView alloc] initWithTitle:@"No Playlists Created"
                                                        message:@"You have not created any playlists yet. Press the 'Create Playlists' button to do so."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [emptyAlert show];
    } else {
        // Otherwise, let musicPlayer handle playing.pausing
        NSInteger totalRunTime = [[playForSeconds text]integerValue] + ([[playForMinutes text]integerValue] * 60);
        [musicPlayer beginOrPlayPauseForTime:totalRunTime];
    }
}

-(IBAction)addInterval:(id)sender
{
    // Open the intervalAlert alert defined above; called when the 'add interval' button is tapped
    [intervalAlert show];
    
}

-(void)alertView:(UIAlertView*) alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // This is an overridden method that is called when an alert closes.
    // First we check if the alert is the intervalAlert. If it is, we add the interval time to the current list
    if ([alertView isEqual:intervalAlert]) {
        if (buttonIndex == 1) {
            NSNumber *newInterval = [[NSNumber alloc] initWithInt:[[newIntervalLengthTextField text] intValue]];
            [musicPlayer addInterval:newInterval];
            // The next line is a bit hacky; a flag would be better than just checking for the currnt line content. I plan on refactoring this.
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
        // If the clearAlert is pressed, just reset the intervals in the musicPlayer and restore the default text to the list
        if (buttonIndex == 1){
            [musicPlayer clearAllIntervals];
            [intervalTimesLabel setText:@"No Interval Times Set"];
        }
    }
}

-(IBAction)clearIntervals:(id)sender
{
    // Open the clearAlert defined above
    [clearAlert show];
}

-(void)setPlayPauseButton:(NSInteger)setTo {
    // This method is used to set the image of the begin/play/pause button as needed
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
