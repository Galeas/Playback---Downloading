//
//  PDViewController.m
//  PlaybackWDownloading
//
//  Created by Евгений Кратько on 24.04.13.
//  Copyright (c) 2013 Akki. All rights reserved.
//

#import "PDViewController.h"
#import "LBYouTube.h"
#import "PDProgressView.h"
#import "PDSlider.h"

#define kPlayTag 999
#define kPauseTag 998

@interface PDViewController () <LBYouTubePlayerControllerDelegate>
{
    NSTimer *playbackTimer;
}
@end

@implementation PDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self addYoutubeView];
    [self addProgressView];
    [self addSlider];
    
    NSTimer *download = [NSTimer scheduledTimerWithTimeInterval:.1f target:self selector:@selector(trackDownloadProgress:) userInfo:nil repeats:YES];
#pragma unused (download)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidChangeState:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
}

- (void)addYoutubeView
{
    LBYouTubePlayerController *yController = [[LBYouTubePlayerController alloc] initWithYouTubeURL:[NSURL URLWithString:@"http://www.youtube.com/watch?v=aphx5H4m__M"] quality:LBYouTubeVideoQualityLarge];
    [yController setDelegate:self];
    [yController.view setFrame:CGRectMake(8, 110, 300, 200)];
    [yController setShouldAutoplay:NO];
    [yController.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [yController setFullscreen:YES];
    [yController setControlStyle:MPMovieControlStyleNone];
    [yController prepareToPlay];
    [self.view addSubview:yController.view];
    
    self.youtube = yController;
}

- (void)addProgressView
{
    self.progress = [[PDProgressView alloc] initWithFrame:CGRectMake(8, 40, 300, 20)];
    [self.progress setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.progress setProgressBackColor:[UIColor darkGrayColor]];
    [self.progress setProgressMainColor:[UIColor colorWithRed:.72 green:.03 blue:.03 alpha:1]];
    [self.view addSubview:self.progress];
}

- (void)addSlider
{
    self.slider = [[PDSlider alloc] initWithFrame:CGRectMake(8, 65, 300, 20)];
    [self.view addSubview:self.slider];
    [self.slider setBackProgressColor:[UIColor darkGrayColor]];
    [self.slider setBorderColor:[UIColor whiteColor]];
    [self.slider setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.slider setPlaybackColor:[UIColor colorWithRed:.72 green:.03 blue:.03 alpha:1]];
    [self.slider addTarget:self action:@selector(searchVideo:) forControlEvents:UIControlEventValueChanged];
}

- (void)searchVideo:(id)sender
{
    PDSlider *slider = (PDSlider*)sender;
    CGFloat currentPosition = slider.value * self.youtube.duration;
    [self.youtube pause];
    [self.youtube setCurrentPlaybackTime:(NSTimeInterval)currentPosition];
    if ([self.youtube playbackState] != MPMoviePlaybackStatePlaying) {
        [self.youtube play];
    }
    //[self.youtube play];
}

- (void)trackDownloadProgress:(NSTimer*)timer
{
    NSTimeInterval total = self.youtube.duration;
    NSTimeInterval available = self.youtube.playableDuration;
    float result = available/total;
    if (result >= 0) {
        [self.slider setLoaded:result];
        [self.progress setValueBack:result animated:YES];
    }
    if (result == 1) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)playerDidChangeState:(NSNotification*)notification
{
    MPMoviePlaybackState state = self.youtube.playbackState;
    switch (state) {
        case MPMoviePlaybackStatePlaying: {
            [self playbackTimerStart];
            break;
        }
        case MPMoviePlaybackStatePaused:
        case MPMoviePlaybackStateStopped: {
            [self playbackTimerStop];
            break;
        }
        case MPMoviePlaybackStateSeekingBackward:
        case MPMoviePlaybackStateSeekingForward: {
            [self.youtube play];
            break;
        }
        default:break;
    }
}


- (void)playbackTimerStart
{
    if (playbackTimer) [self playbackTimerStop];
    playbackTimer = [NSTimer scheduledTimerWithTimeInterval:.5f target:self selector:@selector(trackPlaybackProgress:) userInfo:nil repeats:YES];
}

- (void)playbackTimerStop
{
    if (playbackTimer) {
        [playbackTimer invalidate];
        playbackTimer = nil;
    }
}

- (void)trackPlaybackProgress:(NSTimer*)timer
{
    if (self.youtube.playbackState == MPMoviePlaybackStatePlaying) {
        NSTimeInterval total = self.youtube.duration;
        NSTimeInterval current = self.youtube.currentPlaybackTime;
        float value = current / total;
        [self.slider setValue:value animated:YES];
        [self.progress setValueMain:value animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)youTubePlayerViewController:(LBYouTubePlayerController *)controller didSuccessfullyExtractYouTubeURL:(NSURL *)videoURL{}
- (void)youTubePlayerViewController:(LBYouTubePlayerController *)controller failedExtractingYouTubeURLWithError:(NSError *)error {}

- (void)viewDidUnload {
    [super viewDidUnload];
}
- (IBAction)playPause:(id)sender
{
    switch ([sender tag]) {
        case kPlayTag: {
            [self.youtube play];
            [(UIButton*)sender setTitle:@"Pause" forState:UIControlStateNormal];
            [sender setTag:kPauseTag];
            break;
        }
        case kPauseTag: {
            [self.youtube pause];
            [(UIButton*)sender setTitle:@"Play" forState:UIControlStateNormal];
            [sender setTag:kPlayTag];
            break;
        }
        default:break;
    }
}

- (IBAction)stop:(id)sender
{
    [self.youtube stop];
    UIButton *btn = (UIButton*)[self.view viewWithTag:kPauseTag];
    if (btn) {
        [btn setTag:kPlayTag];
        [btn setTitle:@"Play" forState:UIControlStateNormal];
    }
}
@end
