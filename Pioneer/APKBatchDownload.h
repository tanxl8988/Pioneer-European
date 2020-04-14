//
//  APKBatchDownload.h
//  Pioneer
//
//  Created by Mac on 17/9/25.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APKDVRFile.h"

typedef enum : NSUInteger {
    APKBatchDownloadStateFine,
    APKBatchDownloadStateNotEnoughStorageSpace,
    APKBatchDownloadStateDataBaseNotReady,
    APKBatchDownloadStateNoPhotosAuthority,
} APKBatchDownloadState;

typedef void(^APKBatchDownloadCompletionHandler)(void);
typedef void(^APKBatchDownloadProgressHandler)(float progress,NSString *info);
typedef void(^APKBatchDownloadGlobalProgressHandler)(NSString *info);

@interface APKBatchDownload : NSObject

@property (nonatomic) APKBatchDownloadState state;

- (void)batchDownloadWithFileArray:(NSArray<APKDVRFile *> *)fileArray globalProgress:(APKBatchDownloadGlobalProgressHandler)globalProgress progress:(APKBatchDownloadProgressHandler)progress completionHandler:(APKBatchDownloadCompletionHandler)completionHandler;
- (void)cancel;

@end
