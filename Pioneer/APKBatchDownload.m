//
//  APKBatchDownload.m
//  Pioneer
//
//  Created by Mac on 17/9/25.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKBatchDownload.h"
#import "AFNetworking.h"
#import "APKPhotosKit.h"
#import "APKCoreDataStack.h"
#import "APKLocalFile.h"
#include <sys/param.h>
#include <sys/mount.h>
#import <Photos/Photos.h>

@interface APKBatchDownload ()

@property (strong,nonatomic) NSMutableArray *fileArray;
@property (copy,nonatomic) APKBatchDownloadProgressHandler progress;
@property (copy,nonatomic) APKBatchDownloadGlobalProgressHandler globalProgress;
@property (copy,nonatomic) APKBatchDownloadCompletionHandler completionHandler;
@property (strong,nonatomic) AFURLSessionManager *sessionManager;
@property (weak,nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (strong,nonatomic) NSMutableDictionary *urls;//已下载的文件的沙盒链接
@property (strong,nonatomic) NSMutableArray *downloadedFiles;
@property (nonatomic) BOOL isCanceled;
@property (nonatomic) NSInteger fileSum;//下载文件总数
@property (nonatomic) BOOL isHaveEnoughStorageSpace;
@property (nonatomic) BOOL isHavePhotosAuthority;

@end

@implementation APKBatchDownload

#pragma mark - private method

- (void)executeDownloadTask{//批量下载文件
    
    if (self.fileArray.count == 0 || self.isCanceled) {
        
        [self saveDownloadedFiles];
        return;
    }
    
    APKDVRFile *file = [self.fileArray objectAtIndex:0];
    
    NSString *globalProgressInfo = [NSString stringWithFormat:@"%@(%d/%d)",file.name,(int)(self.fileSum - self.fileArray.count + 1),(int)self.fileSum];
    self.globalProgress(globalProgressInfo);
    
    __weak typeof(self)weakSelf = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:file.url];
    self.downloadTask = [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        NSString *info = nil;
        if (downloadProgress.totalUnitCount >= 1000000) {
            info = [NSString stringWithFormat:@"%.2fM/%.2fM",(CGFloat)downloadProgress.completedUnitCount/1000000,(CGFloat)downloadProgress.totalUnitCount/1000000];
        }
        else{
            info = [NSString stringWithFormat:@"%.fk/%.fk",(CGFloat)downloadProgress.completedUnitCount/1000,(CGFloat)downloadProgress.totalUnitCount/1000];
        }
        weakSelf.progress(downloadProgress.fractionCompleted,info);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:response.suggestedFilename];
        NSURL *url = [NSURL fileURLWithPath:filePath];
        return url;
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        if (!error) {
            [weakSelf.downloadedFiles addObject:file];
            [weakSelf.urls setObject:filePath forKey:file.name];
        }
        [weakSelf.fileArray removeObjectAtIndex:0];
        [weakSelf executeDownloadTask];
    }];
    [self.downloadTask resume];
}

- (void)saveDownloadedFiles{//保存到系统相册
    
    if (self.downloadedFiles.count == 0) {
        
        self.completionHandler();
        return;
    }
    
    APKDVRFile *file = [self.downloadedFiles objectAtIndex:0];
    file.date = [NSDate date];
    NSURL *url = [self.urls objectForKey:file.name];
    PHAssetMediaType mediaType = file.type == APKDVRFileTypePhoto ? PHAssetMediaTypeImage : PHAssetMediaTypeVideo;
    __weak typeof(self)weakSelf = self;
    [APKPhotosKit saveFileWithURL:url mediaType:mediaType success:^(NSString *identifier) {
        
        NSManagedObjectContext *context = [APKCoreDataStack sharedInstance].context;
        [context performBlock:^{
           
            //保存到数据库
            [APKLocalFile createLocalFileWithName:file.name type:file.type date:file.date localIdentifier:identifier context:context];
            NSError *error = nil;
            [context save:&error];
            NSAssert(!error, @"保存下载文件信息到数据库失败");
            
            //更新当前文件状态
            file.isDownloaded = YES;
            
            [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
            [weakSelf.urls removeObjectForKey:file.name];
            [weakSelf.downloadedFiles removeObjectAtIndex:0];
            [weakSelf saveDownloadedFiles];
        }];
        
    } failure:^(NSError *error) {
        
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        [weakSelf.urls removeObjectForKey:file.name];
        [weakSelf.downloadedFiles removeObjectAtIndex:0];
        [weakSelf saveDownloadedFiles];
    }];
}

#pragma mark - public method

- (void)cancel{
    
    self.isCanceled = YES;
    [self.downloadTask cancel];
}

- (void)batchDownloadWithFileArray:(NSArray<APKDVRFile *> *)fileArray globalProgress:(APKBatchDownloadGlobalProgressHandler)globalProgress progress:(APKBatchDownloadProgressHandler)progress completionHandler:(APKBatchDownloadCompletionHandler)completionHandler{
    
    [self.fileArray setArray:fileArray];
    self.globalProgress = globalProgress;
    self.progress = progress;
    self.completionHandler = completionHandler;
    self.isCanceled = NO;
    self.fileSum = fileArray.count;
    
    [self executeDownloadTask];
}

#pragma mark - getter

- (APKBatchDownloadState)state{
    
    if (![APKCoreDataStack sharedInstance].context) {
        
        return APKBatchDownloadStateDataBaseNotReady;
    }
    if (!self.isHaveEnoughStorageSpace) {
        
        return APKBatchDownloadStateNotEnoughStorageSpace;
    }
    if (!self.isHavePhotosAuthority) {
        
        return APKBatchDownloadStateNoPhotosAuthority;
    }
    
    return APKBatchDownloadStateFine;
}

- (BOOL)isHavePhotosAuthority{
    
    return [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized;
}

- (BOOL)isHaveEnoughStorageSpace{
    
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0) {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_bavail);
    }
    unsigned long long minimumSpace = 1024 * 1024 * 5;//下载需要的最小空间
    BOOL isHaveEnoughStorageSpace = freeSpace > minimumSpace;
    return isHaveEnoughStorageSpace;
}

- (NSMutableDictionary *)urls{
    
    if (!_urls) {
        
        _urls = [[NSMutableDictionary alloc] init];
    }
    return _urls;
}

- (NSMutableArray *)downloadedFiles{
    
    if (!_downloadedFiles) {
        
        _downloadedFiles = [[NSMutableArray alloc] init];
    }
    return _downloadedFiles;
}

- (AFURLSessionManager *)sessionManager{
    
    if (!_sessionManager) {
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    return _sessionManager;
}
                                  
- (NSMutableArray *)fileArray{
    
    if (!_fileArray) {
        
        _fileArray = [[NSMutableArray alloc] init];
    }
    return _fileArray;
}

@end
