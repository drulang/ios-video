//
//  ViewController.m
//  LadybugZap
//
//  Created by Moses DeJong on 6/17/13.
//  Copyright (c) 2013 HelpURock. All rights reserved.
//

#import "ViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "AVFileUtil.h"

#import "AVAnimatorView.h"
#import "AVAnimatorLayer.h"
#import "AVAnimatorMedia.h"
#import "AVAssetFrameDecoder.h"

#import "AVGIF89A2MvidResourceLoader.h"
#import "AV7zAppResourceLoader.h"
#import "AVAsset2MvidResourceLoader.h"
#import "AVMvidFrameDecoder.h"

#define FRAMERATE 0.1

@interface ViewController ()



@property (nonatomic)AVAsset2MvidResourceLoader *videoLoader;
@property (nonatomic)AVAnimatorMedia *videoMedia;

@property (nonatomic)UIView *videoContainer;
@property (nonatomic)AVAnimatorView *videoAnimatorView;

@end

@implementation ViewController

#pragma mark Properties

- (AVAsset2MvidResourceLoader *)videoLoader {
    if (!_videoLoader) {
        NSString *resourceFilename = @"output.mp4";
        NSString *outputFilename = @"output.mvid";
        
        _videoLoader = [AVAsset2MvidResourceLoader aVAsset2MvidResourceLoader];
        _videoLoader.movieFilename = resourceFilename;
        _videoLoader.outPath = [AVFileUtil getTmpDirPath:outputFilename];
    }
    return _videoLoader;
}

- (AVAnimatorMedia *)videoMedia {
    if (!_videoMedia) {
        _videoMedia = [AVAnimatorMedia aVAnimatorMedia];
        _videoMedia.resourceLoader = self.videoLoader;
        _videoMedia.frameDecoder = [AVMvidFrameDecoder aVMvidFrameDecoder];
        _videoMedia.animatorRepeatCount = 0xFFFF;
    }
    return _videoMedia;
}

- (UIView *)videoContainer {
    if (!_videoContainer) {
        _videoContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 210)];
        _videoContainer.layer.borderColor = [UIColor greenColor].CGColor;
        _videoContainer.layer.borderWidth = 1;
        
        [self.videoContainer addSubview:self.videoAnimatorView];
    }
    return _videoContainer;
}

- (AVAnimatorView *)videoAnimatorView {
    if (!_videoAnimatorView) {
        _videoAnimatorView = [AVAnimatorView aVAnimatorViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 250)];
    }
    return _videoAnimatorView;
}

#pragma mark Overrides

- (void)viewDidLoad {
  [super viewDidLoad];
    
    [self.view addSubview:self.videoContainer];
    
    [self.videoAnimatorView attachMedia:self.videoMedia];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.videoMedia startAnimator];
}


@end
