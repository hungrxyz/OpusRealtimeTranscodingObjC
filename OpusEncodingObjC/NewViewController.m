//
//  NewViewController.m
//  OpusEncodingObjC
//
//  Created by Zel Marko on 30/07/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

#import "NewViewController.h"
#import "EZAudio.h"

@interface NewViewController ()

@property (nonatomic) AudioBufferList *outputBufferList;
@property (nonatomic) AudioStreamBasicDescription audioStreamDescription;

@end

@implementation NewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
    [session setActive:YES error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
    }

    
    
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:true];
    
    [self setupMicrophone];
    [self setupOutput];
    [self setupOpusEncoder];
    [self setupOpusDecoder];
    
    
    
    [_microphone startFetchingAudio];
//    [_audioOutput startPlayback];
}

- (void)setupMicrophone {
    NSError *error = nil;
    int preferredSampleRate = kOpusKitSampleRate_48000;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setPreferredSampleRate:preferredSampleRate error:&error];
    if (error) {
        NSLog(@"Error setting preferred sample rate to %d: %@", preferredSampleRate, error);
    }
    
    _microphone = [[EZMicrophone alloc] initWithMicrophoneDelegate:self];
    self.audioStreamDescription = [_microphone audioStreamBasicDescription];
}

- (void)setupOutput {
    _audioOutput = [[EZOutput alloc] initWithDataSource:self];
}

- (void)setupOpusEncoder {
    NSError *error;
    _opusEncoder = [OKEncoder encoderForASBD:self.audioStreamDescription application:kOpusKitApplicationVoIP error:&error];
    if (error) {
        NSLog(@"Error setting up Opus Encoder: %@", error);
    }
}

- (void)setupOpusDecoder {
    _opusDecoder = [[OKDecoder alloc] initWithSampleRate:_opusEncoder.sampleRate numberOfChannels:_opusEncoder.numberOfChannels];
    NSError *error = nil;
    if (![self.opusDecoder setupDecoderWithError:&error]) {
        NSLog(@"Error setting up opus decoder: %@", error);
    }

}

- (void)microphone:(EZMicrophone *)microphone hasAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription {
//    [EZAudio printASBD:audioStreamBasicDescription];
    NSLog(@"rate: %fl", audioStreamBasicDescription.mSampleRate);
}

- (void)microphone:(EZMicrophone *)microphone hasBufferList:(AudioBufferList *)bufferList withBufferSize:(UInt32)bufferSize withNumberOfChannels:(UInt32)numberOfChannels {
    
    [_opusEncoder encodeBufferList:bufferList completionBlock:^(NSData *data, NSError *error) {
        if (data) {
            [_opusDecoder decodePacket:data completionBlock:^(NSData *pcmData, NSUInteger numDecodedSamples, NSError *error) {
                if (error != nil) {
                    NSLog(@"Decoding fucked up: %@", error);
                }
                else {
                    if (!_audioOutput.isPlaying) {
                        [_audioOutput startPlayback];
                    }
                    
                    NSLog(@"data: %lu", (unsigned long)numDecodedSamples);
                    
                    _outputBufferList = [self getBufferListFromData:pcmData];
                }
            }];
        }
    }];
    
//    NSLog(@"Microphone buffers %u", numberOfChannels);
}

- (OSStatus)output:(EZOutput *)output shouldFillAudioBufferList:(AudioBufferList *)audioBufferList withNumberOfFrames:(UInt32)frames timestamp:(const AudioTimeStamp *)timestamp {
    
    memcpy(audioBufferList, self.outputBufferList, sizeof(AudioBufferList) + (self.outputBufferList->mNumberBuffers - 1) * sizeof(AudioBuffer));
    
    return noErr;
}

-(AudioBufferList *) getBufferListFromData: (NSData *) data
{
    if (data.length > 0)
    {
        NSUInteger len = [data length];
        //I guess you can use Byte*, void* or Float32*. I am not sure if that makes any difference.
        Byte * byteData = (Byte*) malloc (len);
        memcpy (byteData, [data bytes], len);
        if (byteData)
        {
            AudioBufferList * theDataBuffer =(AudioBufferList*)malloc(sizeof(AudioBufferList) * 1);
            theDataBuffer->mNumberBuffers = 1;
            theDataBuffer->mBuffers[0].mDataByteSize = len;
            theDataBuffer->mBuffers[0].mNumberChannels = 1;
            theDataBuffer->mBuffers[0].mData = byteData;
            // Read the data into an AudioBufferList
            return theDataBuffer;
        }
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
