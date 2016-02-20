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
    AVMutableCompositionTrack *mutableCompositionAudio1Track = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *mutableCompositionAudio2Track = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    
    // Assets
    AVAsset *videoAsset = [AVAsset assetWithURL:url];

    // Get the  video tracks
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVAssetTrack *audioAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];

    // Add them to the composition
    [mutableCompositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration) ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];
    [mutableCompositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration) ofTrack:videoAssetTrack atTime:videoAssetTrack.timeRange.duration error:nil];

    // Add audio to composition
    [mutableCompositionAudio1Track insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAssetTrack.timeRange.duration) ofTrack:audioAssetTrack atTime:kCMTimeZero error:nil];
    
    // second track time
    CMTime time = audioAssetTrack.timeRange.duration;
    time.value -= 200;
    
    [mutableCompositionAudio2Track insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAssetTrack.timeRange.duration) ofTrack:audioAssetTrack atTime:time error:nil];
    
    //
    // Fade when from the first audio track to the second audio track
    //
    AVMutableAudioMix *mutableAudioMix = [AVMutableAudioMix audioMix];

    // Fade out the first track
    CMTime firstTrackStartTime = audioAssetTrack.timeRange.duration;
    firstTrackStartTime.value -= 500;
    
    AVMutableAudioMixInputParameters *fadeOutFirstTrack = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:mutableCompositionAudio1Track];
    [fadeOutFirstTrack setVolumeRampFromStartVolume:1.0 toEndVolume:0.0f timeRange:CMTimeRangeMake(time, CMTimeMake(2, 1))];
    
    // Fade in the second track
    CMTime secondTrackStartTime = audioAssetTrack.timeRange.duration;
    secondTrackStartTime.value -= 500;
    
    AVMutableAudioMixInputParameters *fadeInSecondTrack = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:mutableCompositionAudio2Track];
    [fadeInSecondTrack setVolumeRampFromStartVolume:0 toEndVolume:1.0f timeRange:CMTimeRangeMake(secondTrackStartTime, CMTimeMake(2, 1))];
    
    
    mutableAudioMix.inputParameters = @[fadeOutFirstTrack, fadeInSecondTrack];
    
    
    //
    // Export
    //
    NSLog(@"Supported assets");
    NSLog(@"%@", [AVAssetExportSession exportPresetsCompatibleWithAsset:mutableComposition]);

    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mutableComposition presetName:AVAssetExportPresetHighestQuality];
    exporter.audioMix = mutableAudioMix;

    exporter.outputURL = [[[[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:@YES error:nil] URLByAppendingPathComponent:[NSDate date].description] URLByAppendingPathExtension:CFBridgingRelease(UTTypeCopyPreferredTagWithClass((CFStringRef)AVFileTypeQuickTimeMovie, kUTTagClassFilenameExtension))];
    
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = NO;
 
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"DONE");
    }];
    
}



@end
