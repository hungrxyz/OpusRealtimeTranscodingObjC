//
//  RecordingViewController.m
//  OpusEncodingObjC
//
//  Created by Zel Marko on 06/08/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

#import "RecordingViewController.h"

@interface RecordingViewController ()

@end

@implementation RecordingViewController

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

    self.microphone = [EZMicrophone microphoneWithDelegate:self];
    self.player = [EZAudioPlayer audioPlayerWithDelegate:self];
    
    NSLog(@"File written to application sandbox's documents directory: %@",[self testFilePathURL]);
}

- (IBAction)record:(id)sender {
    [self.player pause];
    
    [self.microphone startFetchingAudio];
    self.isRecording = YES;
    
    self.recorder = [EZRecorder recorderWithURL:[self testFilePathURL] clientFormat:[self.microphone audioStreamBasicDescription] fileType:EZRecorderFileTypeAIFF delegate:self];
}

- (IBAction)play:(id)sender {
    [self.microphone stopFetchingAudio];
    self.isRecording = NO;
    
    if (self.recorder) {
        [self.recorder closeAudioFile];
    }
    
    EZAudioFile *audioFile = [EZAudioFile audioFileWithURL:[self testFilePathURL]];
    [self.player playAudioFile:audioFile];
}

- (void)microphone:(EZMicrophone *)microphone hasBufferList:(AudioBufferList *)bufferList withBufferSize:(UInt32)bufferSize withNumberOfChannels:(UInt32)numberOfChannels {
    
    [_opusEncoder encodeBufferList:bufferList completionBlock:^(NSData *data, NSError *error) {
        if (data) {
            [_opusDecoder decodePacket:data completionBlock:^(NSData *pcmData, NSUInteger numDecodedSamples, NSError *error) {
                if (error != nil) {
                    NSLog(@"Decoding fucked up: %@", error);
                }
                else {
                
                    if (self.isRecording) {
                        [self.recorder appendDataFromBufferList:[self getBufferListFromData:pcmData] withBufferSize:bufferSize];
                    }
                }
            }];
        }
    }];

    
    
}

- (AudioBufferList *)getBufferListFromData:(NSData *)data
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


- (void)recorderDidClose:(EZRecorder *)recorder {
    recorder.delegate = nil;
}

#pragma mark - Utility
//------------------------------------------------------------------------------

- (NSArray *)applicationDocuments
{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
}

//------------------------------------------------------------------------------

- (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

//------------------------------------------------------------------------------

- (NSURL *)testFilePathURL
{
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",
                                   [self applicationDocumentsDirectory],
                                   kAudioFilePath]];
}

@end
