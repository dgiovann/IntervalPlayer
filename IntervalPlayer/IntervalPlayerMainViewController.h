//
//  IntervalPlayerMainViewController.h
//  IntervalPlayer
//
//  Created by Daniel Giovannelli on 1/11/13.
//  Copyright (c) 2013 Daniel Giovannelli. All rights reserved.
//

#import "IntervalPlayerFlipsideViewController.h"
#import "IntervalMusicPlayer.h"


@interface IntervalPlayerMainViewController : UIViewController <IntervalPlayerFlipsideViewControllerDelegate, MPMediaPickerControllerDelegate, UITextFieldDelegate, AVAudioPlayerDelegate>
{
    // Variables are grouped alphabetically by type
    
    // A reference to the currently playing item. This is used to populate the song info labels
    AVPlayerItem *currentItem;

    
    // IBOutlets for each UI element that will be changed (text or button images)


    __weak IBOutlet UIButton *playOrPauseButton;
    
    IBOutlet UILabel *albumLabel;
    IBOutlet UILabel *artistLabel;
    IBOutlet UILabel *intervalTimesLabel;
    IBOutlet UILabel *titleLabel;

    // A pointer to the musicPlayer object which controls playing all music
    IntervalMusicPlayer *musicPlayer;
    
    // A temporary array which is used to populate the song information labels
    
    NSArray *metadataList;

    // Strings to hold the song's metadata
    NSString *album;
    NSString *artist;
    NSString *title;

    // This app uses two alerts, one to confirm clearing the intervals and one if you try to start the playlists without creating any playlists
    UIAlertView *clearAlert;
    UIAlertView *intervalAlert;
    
    // The text boxes used to determine the total play time
    IBOutlet UITextField *playForSeconds;
    IBOutlet UITextField *playForMinutes;
    UITextField *newIntervalLengthTextField;
}

// Properties for any object called from another class, which in this case is only the UI switch
@property (weak, nonatomic) IBOutlet UISwitch *toneSwitch;

// Methods for each button. Most of them only call methods on IntervalMusicPlayer.
-(IBAction)addInterval:(id)sender;
-(IBAction)clearIntervals:(id)sender;
-(IBAction)showInfo:(id)sender;
-(IBAction)previousSong:(id)sender;
-(IBAction)nextSong:(id)sender;
-(IBAction)beginOrPlayPause:(id)sender;

// This method sets the song info labels which display in the view controllers to whatever is currently playing on the IntervalMusicPlayer player at playerNumber. This is a bit more tightly-coupled then I would like; I plan to fix this if/when I refactor the app.
-(void)setSongInfoForPlayer:(NSNumber *)playerNumber atEnd:(Boolean)atEnd;
// This method changes the image of the play/pause button: 0 is begin, 1 is play, and 2 is pause
-(void)setPlayPauseButton:(NSInteger)setTo;
// This method clears the song info labels, replacing them with "Title" "Artist" and "Album"
-(void)clearSongInfo;

@end
