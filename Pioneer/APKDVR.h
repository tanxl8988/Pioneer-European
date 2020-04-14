//
//  APKDVR.h
//  Pioneer
//
//  Created by Mac on 17/9/15.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APKDVRCommand.h"

typedef enum : NSUInteger {
    APKDVRConnectStateDisconnected,
    APKDVRConnectStateConnecting,
    APKDVRConnectStateConnected,
    APKDVRConnectStateDisconnecting,
} APKDVRConnectState;

typedef enum : NSUInteger {
    APKDVRDeviceDZ700,
    APKDVRDeviceDZ600,
    APKDVRDeviceDZ500,
} APKDVRDeviceNumber;

@interface APKDVR : NSObject

@property (assign,nonatomic) APKDVRConnectState connectState;
@property (assign,nonatomic) APKDVRDeviceNumber deviceNumber;
@property (nonatomic,assign) BOOL isRearCamera;
@property (nonatomic,assign) BOOL deviceWIfiIsClose;

+ (instancetype)sharedInstance;
- (void)connect;
- (void)disConnect;
- (void)executeCommand:(APKDVRCommand *)command;
-(void)exitApp;

@end
