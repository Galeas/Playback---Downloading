//
//  PDViewController.h
//  PlaybackWDownloading
//
//  Created by Евгений Кратько on 24.04.13.
//  Copyright (c) 2013 Akki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LBYouTubePlayerController;
@class PDProgressView;
@class PDSlider;
@interface PDViewController : UIViewController

@property (nonatomic, strong) IBOutlet PDProgressView *progress;
@property (nonatomic, strong) IBOutlet PDSlider *slider;
@property (nonatomic, strong) LBYouTubePlayerController *youtube;

- (IBAction)playPause:(id)sender;
- (IBAction)stop:(id)sender;
@end
