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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Do any additional setup after loading the view, typically from a nib.
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"output" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:fileName];
    
    
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    
    // Create the video composition track
    AVMutableCompositionTrack *mutableCompositionVideoTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *mutableCompositionAudioTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    int numberOfLoops = 5;
    int audioOffsetAmount = 200;
    
    // Assets
    AVAsset *videoAsset = [AVAsset assetWithURL:url];

    // Get the  video tracks
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVAssetTrack *audioAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];

    // Add tracks to the composition
    CMTimeValue durationAmount = videoAssetTrack.timeRange.duration.value;
    CMTime currentVideoTimeMark = videoAssetTrack.timeRange.duration;
    currentVideoTimeMark.value = 0;

    CMTime currentAudioTimeMark = audioAssetTrack.timeRange.duration;
    currentAudioTimeMark.value = 0;

    currentAudioTimeMark.value = currentAudioTimeMark.value - audioOffsetAmount;

    for (int i = 0; i < numberOfLoops; i++) {
        NSLog(@"Inserted");
        [mutableCompositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration) ofTrack:videoAssetTrack atTime:currentVideoTimeMark error:nil];
        [mutableCompositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAssetTrack.timeRange.duration) ofTrack:audioAssetTrack atTime:currentAudioTimeMark error:nil];

        currentVideoTimeMark.value += durationAmount;
        currentAudioTimeMark.value += (durationAmount - audioOffsetAmount);
    }
    
    //
    // Export
    //
    [self exportComposition:mutableComposition];
}

- (void)exportComposition:(AVMutableComposition *)composition {
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *cacheFile = [cachesPath stringByAppendingPathComponent:@"newfile.mov"];
    NSURL *outputURL = [NSURL fileURLWithPath:cacheFile];
    
    // Remove old file
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:outputURL error:&error];
    
    if (error)
        NSLog(@"Error removing previous file: %@", error.localizedDescription);

    exporter.outputURL = outputURL;
    
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = NO;
    
    NSLog(@"Exports: %@", [AVAssetExportSession exportPresetsCompatibleWithAsset:composition]);
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        switch (exporter.status) {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"FAILED: %@", exporter.error.localizedDescription);
                break;
                
            default:
                break;
        }
        
        [self playFileWithURL:exporter.outputURL];
    }];
}

- (void)playFileWithURL:(NSURL *)url {
    NSLog(@"Playing file: %@", url);
    
    AVPlayer *player = [[AVPlayer alloc] initWithURL:url];
    
    AVPlayerLayer *layer = [[AVPlayerLayer alloc] init];
    layer.frame = self.view.frame;
    layer.player = player;
    layer.borderColor = [UIColor redColor].CGColor;
    layer.borderWidth = 5;
    
    [self.view.layer addSublayer:layer];
    
    [player play];
    
    
}

@end
