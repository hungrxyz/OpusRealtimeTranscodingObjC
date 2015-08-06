//
//  RecordingViewController.h
//  OpusEncodingObjC
//
//  Created by Zel Marko on 06/08/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZAudio.h"
#import "OpusKit.h"

#define kAudioFilePath @"EZAudioTest.aiff"

@interface RecordingViewController : UIViewController <EZAudioPlayerDelegate, EZMicrophoneDelegate, EZRecorderDelegate>

@property (nonatomic, strong) EZMicrophone *microphone;
@property (nonatomic, strong) EZAudioPlayer *player;
@property (nonatomic, strong) EZRecorder *recorder;
@property (nonatomic, assign) BOOL isRecording;

@property (nonatomic, strong) OKEncoder *opusEncoder;
@property (nonatomic, strong) OKDecoder *opusDecoder;

@end
