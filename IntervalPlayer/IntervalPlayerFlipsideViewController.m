//
//  IntervalPlayerFlipsideViewController.m
//  IntervalPlayer
//
//  Created by Daniel Giovannelli on 1/11/13.
//  Copyright (c) 2013 Daniel Giovannelli. All rights reserved.
//

#import "IntervalPlayerFlipsideViewController.h"

@interface IntervalPlayerFlipsideViewController ()

@end

@implementation IntervalPlayerFlipsideViewController
@synthesize intervalOne;
@synthesize intervalTwo;
@synthesize songListView1;
@synthesize songListView2;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // This checks the screen size of the phone. The FlipsideViewController nib does not auto resize well, so we use two different custom ones instead depending on the size of the screen
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            // This loads the smaller nib for older iPhone models. 
            [[NSBundle mainBundle] loadNibNamed:@"FlipsideViewSmallScreen" owner:self options:nil];
        }
        if(result.height == 568)
        {
            // Larger nib for iPhone 5/larger screen
            [[NSBundle mainBundle] loadNibNamed:@"IntervalPlayerFlipsideViewController" owner:self options:nil];
        }
    }
    // Reload the contents of the tableView which displays the current songs, in case they have been changed
    [songListView1 reloadData];
    [songListView2 reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    // Finishes the flipside controller, sending back to the main view controller
    [self.delegate flipsideViewControllerDidFinish:self];
}

// The following two methods add music to their respective playlists
-(IBAction)addMusicToPlaylistOne:(id)sender
{
    playlistToAssignTo = 1;
    // Opens the 'media picker', which shows the list of songs for the user to select
    MPMediaPickerController *mediaPicker1 = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAny];
    mediaPicker1.delegate = self;
    mediaPicker1.allowsPickingMultipleItems = YES;
    mediaPicker1.prompt = @"Select songs for Playlist 1";
    [self presentViewController:mediaPicker1 animated:YES completion:nil];
}

-(IBAction)addMusicToPlaylistTwo:(id)sender
{
    playlistToAssignTo = 2;
    MPMediaPickerController *mediaPicker2 = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAny];
    mediaPicker2.delegate = self;
    mediaPicker2.allowsPickingMultipleItems = YES;
    mediaPicker2.prompt = @"Select songs for Playlist 2";
    [self presentViewController:mediaPicker2 animated:YES completion:nil];
}

// This method is called when the mediapicker is finished
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
    // MediaItemColleciton is the colelciton of media items returned by the picker.
    if (mediaItemCollection) {
        if (playlistToAssignTo == 1) {
            // Iterate over the collection, creating the AVPlayerItem lists as it goes.
            // This is more tightly-coupled then I'd like; it shouldn't be in a view controller. I plan to refactor this out soon
            for (int i=0; i < [[mediaItemCollection items] count]; i++) {
                MPMediaItem *item = [[mediaItemCollection items] objectAtIndex:i];
                // Check to ensure that the AV player item is valid
                if ([AVPlayerItem playerItemWithURL:[item valueForProperty:MPMediaItemPropertyAssetURL]]) {
                    [intervalOne addObject:item];
                }
            }
       } else if (playlistToAssignTo == 2) {
            for (int i=0; i < [[mediaItemCollection items] count]; i++) {
                MPMediaItem *item = [[mediaItemCollection items] objectAtIndex:i];
                if ([AVPlayerItem playerItemWithURL:[item valueForProperty:MPMediaItemPropertyAssetURL]]) {
                    [intervalTwo addObject:item];
                }
            }
       } else {
           NSLog(@"Error in mediaPicker");
       }
    }
    // Reload the lists with the new song data
    [songListView1 reloadData];
    [songListView2 reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    // This just gets rid of the mediapicker without updating the playlists if the picker is cancelled
    [self dismissViewControllerAnimated:YES completion:nil];
}

// These two methods just empty the respective playlists and then clear the listviews
-(IBAction)clearPlaylistOne:(id)sender
{
    [intervalOne removeAllObjects];
    [songListView1 reloadData];
}
-(IBAction)clearPlaylistTwo:(id)sender
{
    [intervalTwo removeAllObjects];
    [songListView2 reloadData];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

// Standard methods to determine what displays in the tableview rows used to display media info
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.songListView1) {
        return [[self intervalOne] count];
    } else {
        return [[self intervalTwo] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    NSString *contentForThisRow;
    if (tableView == self.songListView1) {
        contentForThisRow = [[intervalOne objectAtIndex:[indexPath row]] valueForProperty:MPMediaItemPropertyTitle];
    } else {
        contentForThisRow = [[intervalTwo objectAtIndex:[indexPath row]] valueForProperty:  MPMediaItemPropertyTitle];
    }
    [[cell textLabel] setText:contentForThisRow];
    return cell;
}
@end
