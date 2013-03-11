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
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            // iPhone Classic
            [[NSBundle mainBundle] loadNibNamed:@"FlipsideViewSmallScreen" owner:self options:nil];
        }
        if(result.height == 568)
        {
            // iPhone 5
            [[NSBundle mainBundle] loadNibNamed:@"IntervalPlayerFlipsideViewController" owner:self options:nil];
        }
    }
    [songListView1 reloadData];
    [songListView2 reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

-(IBAction)addMusicToPlaylistOne:(id)sender
{
    playlistToAssignTo = 1;
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


- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
    if (mediaItemCollection) {
        if (playlistToAssignTo == 1) {
            for (int i=0; i < [[mediaItemCollection items] count]; i++) {
                MPMediaItem *item = [[mediaItemCollection items] objectAtIndex:i];
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
        }
    }
    [songListView1 reloadData];
    [songListView2 reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

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
