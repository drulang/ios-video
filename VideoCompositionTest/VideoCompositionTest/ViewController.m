//
//  ViewController.m
//  VideoCompositionTest
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
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"output" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:fileName];
    
    
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    
    // Create the video composition track
    AVMutableCompositionTrack *mutableCompositionVideoTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *mutableCompositionAudioTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // Assets
    AVAsset *videoAsset = [AVAsset assetWithURL:url];
    AVAsset *video2Asset = [AVAsset assetWithURL:url];
    
    // Get the  video tracks
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVAssetTrack *video2AssetTrack = [[video2Asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    AVAssetTrack *audioAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    AVAssetTrack *audio2AssetTrack = [[video2Asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    
    // Add them to the composition
    [mutableCompositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration) ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];
    [mutableCompositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, video2AssetTrack.timeRange.duration) ofTrack:video2AssetTrack atTime:videoAssetTrack.timeRange.duration error:nil];

    // Add audio to composition
    [mutableCompositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAssetTrack.timeRange.duration) ofTrack:audioAssetTrack atTime:kCMTimeZero error:nil];
    
    // second track time
    CMTime time = audioAssetTrack.timeRange.duration;
    time.value -= 200;
    
    [mutableCompositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audio2AssetTrack.timeRange.duration) ofTrack:audio2AssetTrack atTime:time error:nil];
    
    //
    // Fade
    //
    AVMutableAudioMix *mutableAudioMix = [AVMutableAudioMix audioMix];

//    AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:mutableCompositionAudioTrack];
//    [mixParameters setVolumeRampFromStartVolume:1.0 toEndVolume:0.0f timeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(5, 1))];
//    
//    mutableAudioMix.inputParameters = @[mixParameters];
    
    
    //
    // Export
    //
    NSLog(@"Supported assets");
    NSLog(@"%@", [AVAssetExportSession exportPresetsCompatibleWithAsset:mutableComposition]);

    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:videoAsset presetName:AVAssetExportPresetHighestQuality];
    exporter.audioMix = mutableAudioMix;

    exporter.outputURL = [[[[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:@YES error:nil] URLByAppendingPathComponent:[kDateFormatter stringFromDate:[NSDate date]]] URLByAppendingPathExtension:CFBridgingRelease(UTTypeCopyPreferredTagWithClass((CFStringRef)AVFileTypeQuickTimeMovie, kUTTagClassFilenameExtension))];
    
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = NO;
 
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"DONE");
    }];
    
}



@end
