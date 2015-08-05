//
//  NewViewController.h
//  OpusEncodingObjC
//
//  Created by Zel Marko on 30/07/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZAudio.h"
#import "OpusKit.h"
#import "TPCircularBuffer.h"

@interface NewViewController : UIViewController <EZMicrophoneDelegate, EZOutputDataSource>

@property (nonatomic, strong) EZMicrophone *microphone;
@property (nonatomic, strong) EZOutput *audioOutput;
@property (nonatomic, strong) OKEncoder *opusEncoder;
@property (nonatomic, strong) OKDecoder *opusDecoder;
@property (nonatomic) TPCircularBuffer *encodingBuffer;
@property (nonatomic) TPCircularBuffer *decodingBuffer;

@end
