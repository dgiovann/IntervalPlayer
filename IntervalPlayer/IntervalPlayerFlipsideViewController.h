//
//  IntervalPlayerFlipsideViewController.h
//  IntervalPlayer
//
//  Created by Daniel Giovannelli on 1/11/13.
//  Copyright (c) 2013 Daniel Giovannelli. All rights reserved.
//
// This is a flipside view controller; a view controller designed to be tightly integrated with the main view controller. Data can be easily shared between the two.

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>


@class IntervalPlayerFlipsideViewController;


@protocol IntervalPlayerFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(IntervalPlayerFlipsideViewController *)controller;
@end

@interface IntervalPlayerFlipsideViewController : UIViewController <MPMediaPickerControllerDelegate>
{
    // This keeps track of which playlist is currently being assigned to. it is used in the delegate for the media picker to decide which playlist to assign to, since only one method can be implemented as the media picker's delegate.
    int playlistToAssignTo;
}
// This property will point to the MainViewController
@property (weak, nonatomic) id <IntervalPlayerFlipsideViewControllerDelegate> delegate;
// These are tableviews used to list the currently selected songs.
@property (weak, nonatomic) IBOutlet UITableView *songListView1;
@property (weak, nonatomic) IBOutlet UITableView *songListView2;

// These are arrays of NSURLs pointing to media items. These arrays will be passed, via the MainViewController, to IntervalMusicPlayer to populate the intervals.
@property (nonatomic, retain) NSMutableArray *intervalOne;
@property (nonatomic, retain) NSMutableArray *intervalTwo;

// This method returns to the mainViewController
-(IBAction)done:(id)sender;
// These methods are linked up to the buttons. They just set playListToAssignTo and open up the MPMediaPicker to pick songs
-(IBAction)addMusicToPlaylistOne:(id)sender;
-(IBAction)addMusicToPlaylistTwo:(id)sender;
// These methods are linked up the clear buttons. They just wipe the relevant TableView and clear the array
-(IBAction)clearPlaylistOne:(id)sender;
-(IBAction)clearPlaylistTwo:(id)sender;

@end
