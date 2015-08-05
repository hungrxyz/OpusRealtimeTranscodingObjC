//
//  ViewController.m
//  OpusEncodingObjC
//
//  Created by Zel Marko on 25/07/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.audioController = [[CMBAudioController alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.audioController = [[CMBAudioController alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
