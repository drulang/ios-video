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

@property (nonatomic)UIView *container1;
@property (nonatomic)UIView *container2;
@property (nonatomic)AVPlayerLayer *layer1;
@property (nonatomic)AVPlayerLayer *layer2;

@property (nonatomic)AVPlayer *activePlayer;

@end

@implementation ViewController

#pragma mark Properties

- (NSURL *)mediaURL {
    if (!_mediaURL) {
        NSString *fileName = [[NSBundle mainBundle] pathForResource:@"JungleWaterfall" ofType:@"mp4"];
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

- (UIView *)container1 {
    if (!_container1) {
        _container1 = [[UIView alloc] initWithFrame:self.view.frame];
        [_container1.layer addSublayer:self.layer1];
    }
    return _container1;
}

- (UIView *)container2 {
    if (!_container2) {
        _container2 = [[UIView alloc] initWithFrame:self.view.frame];
        [_container2.layer addSublayer:self.layer2];
    }
    return _container2;
}

- (AVPlayerLayer *)layer1 {
    if (!_layer1) {
        _layer1 = [[AVPlayerLayer alloc] init];
        _layer1.frame = self.view.frame;
        _layer1.player = self.player1;
        
        CAShapeLayer *shape = [CAShapeLayer layer];
        shape.lineWidth = 1;
        shape.fillColor = [UIColor greenColor].CGColor;
        shape.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(100, 100, 50, 50)].CGPath;
        
        [_layer1 addSublayer:shape];
    }
    return _layer1;
}

- (AVPlayerLayer *)layer2 {
    if (!_layer2) {
        _layer2 = [[AVPlayerLayer alloc] init];
        _layer2.frame = self.view.frame;
        _layer2.player = self.player2;
        
        CAShapeLayer *shape = [CAShapeLayer layer];
        shape.lineWidth = 1;
        shape.fillColor = [UIColor redColor].CGColor;
        shape.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(100, 100, 50, 50)].CGPath;
        
        [_layer2 addSublayer:shape];
    }
    return _layer2;
}

#pragma mark Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.container2];
    [self.view addSubview:self.container1];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.activePlayer = self.player1;
    [self.activePlayer play];
    
    CMTime assetTime = self.player1.currentItem.asset.duration;
    CGFloat totalSeconds = assetTime.value / (CGFloat)assetTime.timescale;
    
    [NSTimer scheduledTimerWithTimeInterval:totalSeconds target:self selector:@selector(switchPlayers:) userInfo:nil repeats:YES];
    
}

#pragma mark Notifications

- (void)switchPlayers:(NSNotification *)note {
    
    if (self.activePlayer == self.player1) {
        NSLog(@"Switching to player 2 RED");
        self.activePlayer = self.player2;
        [self.activePlayer play];

        [self.view bringSubviewToFront:self.container2];
        [self.player1 seekToTime:kCMTimeZero];
    } else {
        NSLog(@"Switching to player 1 GREEN");
        self.activePlayer = self.player1;
        [self.activePlayer play];

        [self.view bringSubviewToFront:self.container1];
        
        [self.player2 seekToTime:kCMTimeZero];
    }
}



@end
