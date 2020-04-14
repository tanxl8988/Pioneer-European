//
//  APKGetSettingInfo.m
//  Pioneer
//
//  Created by Mac on 17/9/19.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKGetSettingInfo.h"
#import "APKDVR.h"
#import "APKDVRCommandFactory.h"
#import "APKDVRInterface.h"

@implementation APKDVRSettingInfo

- (NSArray *)clipDurationMap{
    
    return @[@"1min",@"3min",@"5min"];
}
- (NSArray *)videoResolutionMap{
    
    if ([APKDVR sharedInstance].deviceNumber == APKDVRDeviceDZ700) {
        return @[@"1080P",@"720P"];
    }else if ([APKDVR sharedInstance].deviceNumber == APKDVRDeviceDZ600)
        return @[@"1080P",@"1080P HDR",@"720P",@"720P HDR"];
    else
        return @[@"720P",@"960P",@"720P HDR"];
}
- (NSArray *)timeAsyncMap{
    
    return @[@"Off",@"On"];
}

@end

@implementation APKDVRWifiInfo

@end

@interface APKGetSettingInfo ()

@property (copy,nonatomic) APKGetSettingInfoSuccessHandler success;
@property (copy,nonatomic) APKGetSettingInfoFailureHandler failure;
@property (strong,nonatomic) APKDVRSettingInfo *settingInfo;

@end

@implementation APKGetSettingInfo

#pragma mark - private method

- (void)getWifiInfo{
    
    __weak typeof(self)weakSelf = self;
    [[APKDVRCommandFactory getWifiInfoCommandWithSuccess:^(id obj) {
        
        APKDVRWifiInfo *wifiInfo = [[APKDVRWifiInfo alloc] init];
        NSArray *params = [obj[AMBAKeyParam] componentsSeparatedByString:@"\n"];
        for (NSString *str in params) {
            
            if ([str hasPrefix:@"AP_SSID"]) {
                
                wifiInfo.account = [str componentsSeparatedByString:@"="].lastObject;
            }
            else if ([str hasPrefix:@"AP_PASSWD"]){
                
                wifiInfo.password = [str componentsSeparatedByString:@"="].lastObject;
            }
        }
        
        weakSelf.success(weakSelf.settingInfo,wifiInfo);
        weakSelf.settingInfo = nil;
        
    } failure:^(int rval) {
        
        weakSelf.failure();
        weakSelf.settingInfo = nil;
        
    }] execute];
}

- (void)getSettingInfo{
    
    __weak typeof(self)weakSelf = self;
    [[APKDVRCommandFactory getSettingInfoCommandWithSuccess:^(id obj) {
        
        NSArray *params = obj[AMBAKeyParam];
        NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
        for (NSDictionary *dict in params) {
            [info setValue:dict.allValues.firstObject forKey:dict.allKeys.firstObject];
        }
        APKDVRSettingInfo *settingInfo = [[APKDVRSettingInfo alloc] init];
        settingInfo.clipDuration = [[settingInfo clipDurationMap] indexOfObject:info[APKKeyClipDuration]];
        settingInfo.videoResolution = [[settingInfo videoResolutionMap] indexOfObject:info[APKKeyVideoRes]];
        settingInfo.timeAsync = [[settingInfo timeAsyncMap] indexOfObject:info[APKKeyTimeAsync]];
        settingInfo.firmwareVersion = info[APKKeyFW];
        weakSelf.settingInfo = settingInfo;
        
        [weakSelf getWifiInfo];
        
    } failure:^(int rval) {
        
        weakSelf.failure();
        
    }] execute];
}

#pragma mark - public method

- (void)getSettingInfoSuccess:(APKGetSettingInfoSuccessHandler)success failure:(APKGetSettingInfoFailureHandler)failure{
    
    self.success = success;
    self.failure = failure;
    
    [self getSettingInfo];
}

@end
