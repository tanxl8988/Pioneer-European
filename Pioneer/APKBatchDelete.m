//
//  APKBatchDelete.m
//  Pioneer
//
//  Created by Mac on 17/9/25.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKBatchDelete.h"
#import "APKDVRCommandFactory.h"

@interface APKBatchDelete ()

@property (strong,nonatomic) NSMutableArray *fileArray;
@property (copy,nonatomic) APKBatchDeleteProgressHandler progress;
@property (copy,nonatomic) APKBatchDeleteCompletionHandler completionHandler;

@end

@implementation APKBatchDelete

#pragma mark - private method

- (void)executeDeleteCommand{
    
    if (self.fileArray.count == 0) {
        
        self.completionHandler();
        self.completionHandler = nil;
        self.progress = nil;
        return;
    }
    
    APKDVRFile *file = [self.fileArray objectAtIndex:0];
    __weak typeof(self)weakSelf = self;
    APKDVRCommand *command = [APKDVRCommandFactory deleteFileCommandWithDeletePath:file.deletePath success:^(id obj) {
        
        weakSelf.progress(file,YES);
        [weakSelf.fileArray removeObjectAtIndex:0];
        [weakSelf executeDeleteCommand];
        
    } failure:^(int rval) {
        
        weakSelf.progress(file,NO);
        [weakSelf.fileArray removeObjectAtIndex:0];
        [weakSelf executeDeleteCommand];
    }];
    [command execute];
}

#pragma mark - public method

- (void)batchDeleteWithFileArray:(NSArray<APKDVRFile *> *)fileArray progress:(APKBatchDeleteProgressHandler)progress completionHandler:(APKBatchDeleteCompletionHandler)completionHandler{
    
    [self.fileArray setArray:fileArray];
    self.progress = progress;
    self.completionHandler = completionHandler;
    
    [self executeDeleteCommand];
}

#pragma mark - getter

- (NSMutableArray *)fileArray{
    
    if (!_fileArray) {
        
        _fileArray = [[NSMutableArray alloc] init];
    }
    return _fileArray;
}

@end
