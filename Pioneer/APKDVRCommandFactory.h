//
//  APKDVRCommandFactory.h
//  Pioneer
//
//  Created by Mac on 17/9/18.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APKDVRCommand.h"

@interface APKDVRCommandFactory : NSObject

+ (APKDVRCommand *)sendHeartBeatCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure;
+ (APKDVRCommand *)deleteFileCommandWithDeletePath:(NSString *)deletePath success:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure;
+ (APKDVRCommand *)getSecurityListCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure;
+ (APKDVRCommand *)getEventListCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure;
+ (APKDVRCommand *)getVideoListCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure;
+ (APKDVRCommand *)getPhotoListCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure;
+ (APKDVRCommand *)modifyWifiWithAccount:(NSString *)account password:(NSString *)password success:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure;
+ (APKDVRCommand *)formatSDCardCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure;
+ (APKDVRCommand *)setCommandWithType:(NSString *)type param:(NSString *)param success:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure;
+ (APKDVRCommand *)getWifiInfoCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure;
+ (APKDVRCommand *)getSettingInfoCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure;
+ (APKDVRCommand *)captureEventCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure;
+ (APKDVRCommand *)captureCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure;
+ (APKDVRCommand *)stopSessionCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure;
+ (APKDVRCommand *)startSessionCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure;

+ (APKDVRCommand *)getDeviceInfoCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure;

+ (APKDVRCommand *)setSwitchCameraCommandWithParam:(NSString*)param success:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure;

+ (APKDVRCommand *)createCommandWithMsgId:(NSInteger)msgId type:(NSString *)type param:(NSString *)param success:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure;

+ (void)setToken:(NSInteger)token;

@end
