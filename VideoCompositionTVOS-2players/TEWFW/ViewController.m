//
//  ViewController.m
//  TEWFW
//
//  Created by Dru Lang on 1/18/16.
//  Copyright © 2016 drulang. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"

@interface ViewController ()

@property (nonatomic)NSURL *mediaURL;

@property (nonatomic)AVPlayer *player1;
@property (nonatomic)AVPlayer *player2;

@property (nonatomic)AVPlayerLayer *layer1;
@property (nonatomic)AVPlayerLayer *layer2;

@property (nonatomic)AVPlayer *activePlayer;

@end

@implementation ViewController

#pragma mark Properties

- (NSURL *)mediaURL {
    if (!_mediaURL) {
        NSString *fileName = [[NSBundle mainBundle] pathForResource:@"output" ofType:@"mp4"];
        _mediaURL = [NSURL fileURLWithPath:fileName];
    }
    return _mediaURL;
}

- (AVPlayer *)player1 {
    if (!_player1) {
        _player1 = [[AVPlayer alloc] initWithURL:self.mediaURL];
    }
    return _player1;
}

- (AVPlayer *)player2 {
    if (!_player2) {
        _player2 = [[AVPlayer alloc] initWithURL:self.mediaURL];
    }
    return _player2;
}

- (AVPlayerLayer *)layer1 {
    if (!_layer1) {
        _layer1 = [[AVPlayerLayer alloc] init];
        _layer1.frame = self.view.frame;
        _layer1.player = self.player1;
    }
    return _layer1;
}

- (AVPlayerLayer *)layer2 {
    if (!_layer2) {
        _layer2 = [[AVPlayerLayer alloc] init];
        _layer2.frame = self.view.frame;
        _layer2.player = self.player2;
    }
    return _layer2;
}

- (void)setActivePlayer:(AVPlayer *)activePlayer {
    _activePlayer = activePlayer;
    [_activePlayer play];
    
    if (activePlayer == self.player1) {
        self.layer1.hidden = NO;
        self.layer2.hidden = YES;
        [self.player2 seekToTime:kCMTimeZero];
    } else {
        self.layer1.hidden = YES;
        self.layer2.hidden = NO;

        [self.player1 seekToTime:kCMTimeZero];
    }
}

#pragma mark Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view.layer addSublayer:self.layer1];
    [self.view.layer addSublayer:self.layer2];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.activePlayer = self.player1;
    
    [self.player1 play];
}

#pragma mark Notifications

- (void)playerDidFinishPlaying:(NSNotification *)note {
    if (self.activePlayer == self.player1) {
        NSLog(@"Switching to player 2");
        self.activePlayer = self.player2;
    } else {
        NSLog(@"Switching to player 1");
        self.activePlayer = self.player1;
    }
}


@end
