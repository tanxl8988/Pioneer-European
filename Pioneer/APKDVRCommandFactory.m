//
//  APKDVRCommandFactory.m
//  Pioneer
//
//  Created by Mac on 17/9/18.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKDVRCommandFactory.h"
#import "APKDVRInterface.h"

static NSInteger tokenId;

@implementation APKDVRCommandFactory

+ (APKDVRCommand *)sendHeartBeatCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure{
    
    APKDVRCommand *command = [APKDVRCommandFactory createCommandWithMsgId:APK_AMBA_HEART_NOTIFY type:nil param:nil success:success failure:failure];
    return command;
}

+ (APKDVRCommand *)deleteFileCommandWithDeletePath:(NSString *)deletePath success:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure{
    
    APKDVRCommand *command = [APKDVRCommandFactory createCommandWithMsgId:MSGID_AMBA_DEL_FILE type:nil param:deletePath success:success failure:failure];
    return command;
}

+ (APKDVRCommand *)getSecurityListCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure{
    
    APKDVRCommand *command = [APKDVRCommandFactory createCommandWithMsgId:APK_AMBA_GET_FILE_LIST type:APKKeySecurityFile param:nil success:success failure:failure];
    return command;
}

+ (APKDVRCommand *)getEventListCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure{
    
    APKDVRCommand *command = [APKDVRCommandFactory createCommandWithMsgId:APK_AMBA_GET_FILE_LIST type:APKKeyEventFile param:nil success:success failure:failure];
    return command;
}

+ (APKDVRCommand *)getVideoListCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure{
    
    APKDVRCommand *command = [APKDVRCommandFactory createCommandWithMsgId:APK_AMBA_GET_FILE_LIST type:APKKeyVideoFile param:nil success:success failure:failure];
    return command;
}

+ (APKDVRCommand *)getPhotoListCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure{
    
    APKDVRCommand *command = [APKDVRCommandFactory createCommandWithMsgId:APK_AMBA_GET_FILE_LIST type:APKKeyPhotoFile param:nil success:success failure:failure];
    return command;
}

+ (APKDVRCommand *)modifyWifiWithAccount:(NSString *)account password:(NSString *)password success:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure{
    
    NSString *param = [NSString stringWithFormat:@"AP_SSID=%@\nAP_PASSWD=%@",account,password];
    APKDVRCommand *command = [APKDVRCommandFactory createCommandWithMsgId:MSGID_AMBA_MODIFY_WIFI_SETTING type:nil param:param success:success failure:failure];
    return command;
}

+ (APKDVRCommand *)formatSDCardCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure{
    
    APKDVRCommand *command = [APKDVRCommandFactory createCommandWithMsgId:MSGID_AMBA_FORMAT type:nil param:@"C:" success:success failure:failure];
    return command;
}

+ (APKDVRCommand *)setCommandWithType:(NSString *)type param:(NSString *)param success:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure{
    
    APKDVRCommand *command = [APKDVRCommandFactory createCommandWithMsgId:MSGID_AMBA_SET_SETTING type:type param:param success:success failure:failure];
    return command;
}

+ (APKDVRCommand *)setSwitchCameraCommandWithParam:(NSString*)param success:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure{

    APKDVRCommand *command = [APKDVRCommandFactory createCommandWithMsgId:MSGID_AMBA_SET_SETTING type:@"Apk_streamSrc" param:param success:success failure:failure];
    return command;
}

+ (APKDVRCommand *)getWifiInfoCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure{
    
    APKDVRCommand *command = [APKDVRCommandFactory createCommandWithMsgId:MSGID_AMBA_GET_WIFI_SETTING type:nil param:nil success:success failure:failure];
    return command;
}


+ (APKDVRCommand *)getSettingInfoCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure{
    
    APKDVRCommand *command = [APKDVRCommandFactory createCommandWithMsgId:MSGID_AMBA_GET_ALL_CURRENT_SETTINGS type:nil param:nil success:success failure:failure];
    return command;
}

+ (APKDVRCommand *)getDeviceInfoCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure{
    
    APKDVRCommand *command = [APKDVRCommandFactory createCommandWithMsgId:MSGID_AMBA_GET_DEVICEINFO type:nil param:nil success:success failure:failure];
    return command;
}

+ (APKDVRCommand *)captureEventCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure{
    
    APKDVRCommand *command = [APKDVRCommandFactory createCommandWithMsgId:APK_AMBA_CAPTURE_EVENT type:nil param:nil success:success failure:failure];
    return command;
}

+ (APKDVRCommand *)captureCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure{
    
    APKDVRCommand *command = [APKDVRCommandFactory createCommandWithMsgId:MSGID_AMBA_TAKE_PHOTO type:nil param:nil success:success failure:failure];
    return command;
}

+ (APKDVRCommand *)stopSessionCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure{
    
    APKDVRCommand *command = [APKDVRCommandFactory createCommandWithMsgId:MSGID_AMBA_STOP_SESSION type:nil param:nil success:success failure:failure];
    return command;
}

+ (APKDVRCommand *)startSessionCommandWithSuccess:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure{
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:[NSNumber numberWithInteger:0] forKey:AMBAKeyToken];
    [dictionary setObject:[NSNumber numberWithInteger:MSGID_AMBA_START_SESSION] forKey:AMBAKeyMSGID];
    NSData *data = [self convertDictionaryToJSONData:dictionary];//字典转data
    
    APKDVRCommand *command = [[APKDVRCommand alloc] init];
    command.commandData = data;
    command.commandId = MSGID_AMBA_START_SESSION;
    command.successHandler = success;
    command.failureHandler = failure;
    return command;
}

+ (void)setToken:(NSInteger)token{
    
    tokenId = token;
}

#pragma mark - private method

+ (APKDVRCommand *)createCommandWithMsgId:(NSInteger)msgId type:(NSString *)type param:(NSString *)param success:(APKDVRCommandSuccessHandler)success failure:(APKDVRCommandFailureHandler)failure{
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:[NSNumber numberWithInteger:tokenId] forKey:AMBAKeyToken];
    [dictionary setObject:[NSNumber numberWithInteger:msgId] forKey:AMBAKeyMSGID];
    if (type)
        [dictionary setObject:type forKey:AMBAKeyType];
    if (param)
        [dictionary setObject:param forKey:AMBAKeyParam];
    NSData *data = [self convertDictionaryToJSONData:dictionary];
    
    APKDVRCommand *command = [[APKDVRCommand alloc] init];
    command.commandData = data;
    command.commandId = msgId;
    command.successHandler = success;
    command.failureHandler = failure;
    return command;
}


+ (NSData *)convertDictionaryToJSONData:(NSDictionary *)dictionary{
    
    if ([NSJSONSerialization isValidJSONObject:dictionary]) {
        
        NSError *error;
        
        /* ⚠️dataWithJSONObject: options: error:方法中，options参数必须设置为0，才能收到正确的服务器返回值；
         * 不能设置为NSJSONWritingPrettyPrinted（指定生成的JSON数据应使用空格旨在使输出更加可读。如果这个选项是
         * 没有设置,最紧凑的可能生成JSON表示）。
         */
        NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
        return data;
    }
    else{
        
        return nil;
    }
}

@end
