//
//  APKInitializeConnect.h
//  Pioneer
//
//  Created by Mac on 17/9/21.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APKAutoSyncTime @"APKAutoSyncTime"
#define APKAutoSyncTimeOpen @"autoSyncTimeOpen"//自动同步时间开启
#define APKAutoSyncTimeClose @"autoSyncTimeClose"


@interface APKInitializeConnect : NSObject

- (void)initializeConnect:(void (^)(BOOL success))completionHandler;

@end
