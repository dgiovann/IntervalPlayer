//
//  IntervalPlayerFlipsideViewController.h
//  IntervalPlayer
//
//  Created by Daniel Giovannelli on 1/11/13.
//  Copyright (c) 2013 Daniel Giovannelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class IntervalPlayerFlipsideViewController;

@protocol IntervalPlayerFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(IntervalPlayerFlipsideViewController *)controller;
@end

@interface IntervalPlayerFlipsideViewController : UIViewController <MPMediaPickerControllerDelegate>
{
    int playlistToAssignTo;
}

@property (weak, nonatomic) id <IntervalPlayerFlipsideViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *songListView1;
@property (weak, nonatomic) IBOutlet UITableView *songListView2;

@property (nonatomic, retain) NSMutableArray *intervalOne; // SHOULD BE AN ARRAY OF NSURLs
@property (nonatomic, retain) NSMutableArray *intervalTwo; // SHOULD BE AN ARRAY OF NSURLs

-(IBAction)done:(id)sender;
-(IBAction)addMusicToPlaylistOne:(id)sender;
-(IBAction)addMusicToPlaylistTwo:(id)sender;
-(IBAction)clearPlaylistOne:(id)sender;
-(IBAction)clearPlaylistTwo:(id)sender;

@end
