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

- (void)viewDidLoad
{
    [super viewDidLoad];
    intervalOne = [[NSMutableArray alloc] init];
    intervalTwo = [[NSMutableArray alloc] init];
        // Do any additional setup after loading the view, typically from a nib.
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
                [intervalOne addObject:[item valueForProperty:MPMediaItemPropertyAssetURL]];
                }
       } else if (playlistToAssignTo == 2) {
            for (int i=0; i < [[mediaItemCollection items] count]; i++) {
                MPMediaItem *item = [[mediaItemCollection items] objectAtIndex:i];
                [intervalTwo addObject:[item valueForProperty:MPMediaItemPropertyAssetURL]];
                }
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)clearPlaylistOne:(id)sender
{
    // WIPE INTERVALONE
    // BLANK UISCROLLVIEW
}
-(IBAction)clearPlaylistTwo:(id)sender
{
    // WIPE INTERVALTWO
    // BLANK UISCROLLVIEW
}
@end
