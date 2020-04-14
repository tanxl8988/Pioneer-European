//
//  APKGetSettingInfo.h
//  Pioneer
//
//  Created by Mac on 17/9/19.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APKDVRSettingInfo : NSObject

@property (nonatomic) NSInteger clipDuration;
@property (nonatomic) NSInteger videoResolution;
@property (nonatomic) BOOL timeAsync;
@property (strong,nonatomic) NSString *firmwareVersion;

- (NSArray *)clipDurationMap;
- (NSArray *)videoResolutionMap;
- (NSArray *)timeAsyncMap;

@end

@interface APKDVRWifiInfo : NSObject

@property (strong,nonatomic) NSString *account;
@property (strong,nonatomic) NSString *password;

@end


typedef void(^APKGetSettingInfoSuccessHandler)(APKDVRSettingInfo *settingInfo,APKDVRWifiInfo *wifiInfo);
typedef void(^APKGetSettingInfoFailureHandler)(void);

@interface APKGetSettingInfo : NSObject

- (void)getSettingInfoSuccess:(APKGetSettingInfoSuccessHandler)success failure:(APKGetSettingInfoFailureHandler)failure;

@end
