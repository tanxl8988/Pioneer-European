//
//  APKDVRCommand.m
//  Pioneer
//
//  Created by Mac on 17/9/18.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKDVRCommand.h"
#import "APKDVR.h"

@implementation APKDVRCommand

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.timeout = 15;//超时时间限制
        self.resultHandler = [[APKDVRCommandResultHandler alloc] init];
    }
    return self;
}

- (void)dealloc{
    
//    NSLog(@"%s",__func__);
}

#pragma mark - public method

- (void)execute{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    [dvr executeCommand:self];
}

@end
