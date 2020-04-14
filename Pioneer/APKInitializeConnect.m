//
//  APKInitializeConnect.m
//  Pioneer
//
//  Created by Mac on 17/9/21.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKInitializeConnect.h"
#import "APKDVRCommandFactory.h"
#import "APKDVR.h"

@implementation APKInitializeConnect

#pragma mark - public method

- (void)initializeConnect:(void (^)(BOOL))completionHandler{
    
    [[APKDVRCommandFactory startSessionCommandWithSuccess:^(id obj) {//开始会话请求
        
        NSInteger token = [obj[AMBAKeyParam] integerValue];//获取tokenID
        [APKDVRCommandFactory setToken:token];
        
        NSString *state = [[NSUserDefaults standardUserDefaults] objectForKey:APKAutoSyncTime];//自动同步时间
        if (!state || [state isEqualToString:APKAutoSyncTimeClose]) {
            
            completionHandler(YES);
        }
        else{
            
            NSString *param = [self currentTime];
            [[APKDVRCommandFactory setCommandWithType:AMBATypeCameraClock param:param success:^(id obj) {
                
                completionHandler(YES);
                
            } failure:^(int rval) {
                
                completionHandler(NO);
                
            }]execute];
        }
        
    } failure:^(int rval) {
    
        completionHandler(NO);
        
    }] execute];
}

#pragma mark - private method

- (NSString *)currentTime{
    
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *currentDate = [date  dateByAddingTimeInterval: interval];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *currentTime = [formatter stringFromDate:currentDate];
    
    return currentTime;
}

@end
