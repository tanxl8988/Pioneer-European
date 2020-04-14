//
//  APKGetDVRFiles.h
//  Pioneer
//
//  Created by Mac on 17/9/22.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APKDVRFile.h"

typedef void(^APKGetDVRFilesSuccessHandler)(NSArray *fileArray);
typedef void(^APKGetDVRFilesFailureHandler)(void);

@interface APKGetDVRFiles : NSObject

+ (void)getDVRFilesWithType:(APKDVRFileType)type success:(APKGetDVRFilesSuccessHandler)success failure:(APKGetDVRFilesFailureHandler)failure;

@end
