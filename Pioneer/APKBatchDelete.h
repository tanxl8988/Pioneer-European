//
//  APKBatchDelete.h
//  Pioneer
//
//  Created by Mac on 17/9/25.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APKDVRFile.h"

typedef void(^APKBatchDeleteProgressHandler)(APKDVRFile *file,BOOL isDeleted);
typedef void(^APKBatchDeleteCompletionHandler)(void);

@interface APKBatchDelete : NSObject

- (void)batchDeleteWithFileArray:(NSArray<APKDVRFile *> *)fileArray progress:(APKBatchDeleteProgressHandler)progress completionHandler:(APKBatchDeleteCompletionHandler)completionHandler;

@end
