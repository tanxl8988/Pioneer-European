//
//  APKGetDVRFiles.m
//  Pioneer
//
//  Created by Mac on 17/9/22.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKGetDVRFiles.h"
#import "APKDVRCommandFactory.h"
#import "APKCoreDataStack.h"
#import "APKLocalFile.h"
#import "APKDVR.h"

@implementation APKGetDVRFiles

#pragma mark - private method

+ (void)getLocalFilesWithType:(APKDVRFileType)type completionHandler:(void(^)(NSArray *localFiles))completionHandler{
    
    if (![APKCoreDataStack sharedInstance].context) {
        completionHandler(nil);
    }
    else{
        
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [context setParentContext:[APKCoreDataStack sharedInstance].context];
        [context performBlock:^{
           
            NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %d",type];
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"APKLocalFile"];
            request.sortDescriptors = @[dateSort];
            request.predicate = predicate;
            NSError *error = nil;
            NSArray *arr = [context executeFetchRequest:request error:&error];
            completionHandler(arr);
        }];
    }
}

//从数据库中localFiles中查找是否存在文件file，存在则该文件已下载
+ (BOOL)getDownloadStateForFile:(APKDVRFile *)file withLocalFiles:(NSArray *)localFiles{
    
    //localFiles中的文件是有序的（按照date从小到大排序），可以使用二分搜索
    NSInteger l = 0,r = localFiles.count - 1;//l是索引的左边界，r是右边界
    while (1) {
    
        if (l > r) {
            break;
        }
        
        NSInteger mid = l + (r - l) / 2;//区间[l..r]的中间索引
        APKLocalFile *localFile = localFiles[mid];
        NSComparisonResult res = [file.date compare:localFile.date];
        if (res == NSOrderedAscending){
            r = mid - 1;
        }
        else if (res == NSOrderedDescending){
            l = mid + 1;
        }
        else{//NSOrderedSame
            
            if ([file.name isEqualToString:localFile.name]) {
                return YES;
            }
            else{
                //还需要看看该localfile旁边是否有和它同date的文件
                NSInteger nearIndex = mid + 1;
                while (nearIndex < localFiles.count) {
                    APKLocalFile *lf = localFiles[nearIndex];
                    if ([lf.date compare:file.date] == NSOrderedSame) {
                        if ([lf.name isEqualToString:file.name]) {
                            return YES;
                        }
                        nearIndex++;
                        continue;
                    }
                    break;
                }
                nearIndex = mid - 1;
                while (nearIndex >= 0) {
                    APKLocalFile *lf = localFiles[nearIndex];
                    if ([lf.date compare:file.date] == NSOrderedSame) {
                        if ([lf.name isEqualToString:file.name]) {
                            return YES;
                        }
                        nearIndex--;
                        continue;
                    }
                    break;
                }
                break;
            }
        }
    }
    
    return NO;
}

#pragma mark - public method

+ (void)getDVRFilesWithType:(APKDVRFileType)type success:(APKGetDVRFilesSuccessHandler)success failure:(APKGetDVRFilesFailureHandler)failure{
    
    APKDVRCommandSuccessHandler commandSuccess = ^(id obj){
        
        [self getLocalFilesWithType:type completionHandler:^(NSArray *localFiles) {
           
            NSMutableArray *fileArray = [[NSMutableArray alloc] init];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
            [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
            
            NSString *pathTemplate = nil,*thumbnailPathTemplate = nil,*deletePathTemplate = nil;
            if ([APKDVR sharedInstance].deviceNumber != APKDVRDeviceDZ500) {
                
                if (type == APKDVRFileTypePhoto) {
                    pathTemplate = @"http://192.168.42.1/Photo/%@";//下载路径
                    thumbnailPathTemplate = @"http://192.168.42.1/Photo/Thumb/%@";//小预览图
                    deletePathTemplate = @"/tmp/SD0/Photo/%@";//删除路径
                }
                else if (type == APKDVRFileTypeEvent){
                    pathTemplate = @"http://192.168.42.1/Event/%@";
                    thumbnailPathTemplate = @"http://192.168.42.1/Event/Thumb/%@.JPG";
                    deletePathTemplate = @"/tmp/SD0/Event/%@";
                }
                else if (type == APKDVRFileTypeVideo){
                    pathTemplate = @"http://192.168.42.1/Video/%@";
                    thumbnailPathTemplate = @"http://192.168.42.1/Video/Thumb/%@.JPG";
                    deletePathTemplate = @"/tmp/SD0/Video/%@";
                }
                else if (type == APKDVRFileTypeSecurity){
                    pathTemplate = @"http://192.168.42.1/Parking/%@";
                    thumbnailPathTemplate = @"http://192.168.42.1/Parking/Thumb/%@.JPG";
                    deletePathTemplate = @"/tmp/SD0/Parking/%@";
                }
                
                NSArray *fileInfos = obj[AMBAKeyListing];
                for (NSInteger i = fileInfos.count - 1; i >= 0; i--) {//实现文件从最新到最旧的排序
                    
                    NSDictionary *info = fileInfos[i];
                    NSString *name = info[APKKeyFileName];//PIONEER_20170922_105743A.JPG
                    NSArray *components = [name componentsSeparatedByString:@"A."];
                    NSString *nameInfo = components.firstObject;
                    
                    components = [components.firstObject componentsSeparatedByString:@"_"];
                    if (components.count != 3)
                        continue;
                    NSString *dateString = [components[1] stringByAppendingString:components[2]];
                    NSDate *date = [dateFormatter dateFromString:dateString];
                    
                    APKDVRFile *file = [[APKDVRFile alloc] init];
                    file.name = name;
                    file.type = type;
                    file.date = date;
                    NSString *url = [[NSString stringWithFormat:pathTemplate,name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    file.url = [NSURL URLWithString:url];
                    nameInfo = [nameInfo stringByReplacingOccurrencesOfString:@".MP4" withString:@""];
                    NSString *urlStr = [NSString stringWithFormat:thumbnailPathTemplate,nameInfo];
                    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSURL *thumbnaulUrl = [NSURL URLWithString:urlStr];
                    file.thumbnailUrl = thumbnaulUrl;
                    NSString *width = info[@"height"];
                    file.isHDRFile = [width isEqualToString:@"1080"] ? YES : NO;
                    file.deletePath = [NSString stringWithFormat:deletePathTemplate,name];
                    if (localFiles && localFiles.count > 0)
                        file.isDownloaded = [self getDownloadStateForFile:file withLocalFiles:localFiles];
                    [fileArray addObject:file];
                }
            }else
            {
   
                if (type == APKDVRFileTypePhoto) {
                    pathTemplate = @"http://192.168.42.1/SD0/Photo/M_photo/%@";//下载路径
                    thumbnailPathTemplate = @"http://192.168.42.1/SD0/Photo/Thumb/%@T.JPG";//小预览图
                    deletePathTemplate = @"/tmp/SD0/Photo/M_photo/%@";//删除路径
                }
                else if (type == APKDVRFileTypeEvent){
                    pathTemplate = @"http://192.168.42.1/SD0/Event/M_video/%@";
                    thumbnailPathTemplate = @"http://192.168.42.1/SD0/Event/Thumb/%@T.JPG";
                    deletePathTemplate = @"/tmp/SD0/Event/M_video/%@";
                }
                else if (type == APKDVRFileTypeVideo){
                    pathTemplate = @"http://192.168.42.1/SD0/Video/M_video/%@";
                    thumbnailPathTemplate = @"http://192.168.42.1/SD0/Video/Thumb/%@T.JPG";
                    deletePathTemplate = @"/tmp/SD0/Video/M_video/%@";
                }
                else if (type == APKDVRFileTypeSecurity){
                    pathTemplate = @"http://192.168.42.1/SD0/Parking/M_video/%@";
                    thumbnailPathTemplate = @"http://192.168.42.1/SD0/Parking/Thumb/%@T.JPG";
                    deletePathTemplate = @"/tmp/SD0/Parking/M_video/%@";
                }
                
                NSArray *fileInfos = obj[AMBAKeyListing];
                for (NSInteger i = fileInfos.count - 1; i >= 0; i--) {//实现文件从最新到最旧的排序
                    
                    NSDictionary *info = fileInfos[i];
                    NSString *name = info[APKKeyFileName];//PIONEER_20170922_105743A.JPG
                    NSArray *components = [name componentsSeparatedByString:@"A."];
                    NSString *nameInfo = components.firstObject;
                    
                    components = [components.firstObject componentsSeparatedByString:@"_"];
                    if (components.count != 3)
                        continue;
                    NSString *dateString = [components[1] stringByAppendingString:components[2]];
                    NSDate *date = [dateFormatter dateFromString:dateString];
                    
                    APKDVRFile *file = [[APKDVRFile alloc] init];
                    file.name = name;
                    file.type = type;
                    file.date = date;
                    file.url = [NSURL URLWithString:[NSString stringWithFormat:pathTemplate,name]];
                    file.thumbnailUrl = [NSURL URLWithString:[NSString stringWithFormat:thumbnailPathTemplate,nameInfo]];
                    file.deletePath = [NSString stringWithFormat:deletePathTemplate,name];
                    if (localFiles && localFiles.count > 0)
                        file.isDownloaded = [self getDownloadStateForFile:file withLocalFiles:localFiles];
                    [fileArray addObject:file];
                }
            }
   
            
            success(fileArray);
        }];
    };
    APKDVRCommandFailureHandler commandFailure = ^(int rval){
        
        failure();
    };
    
    if (type == APKDVRFileTypePhoto) {
        
        [[APKDVRCommandFactory getPhotoListCommandWithSuccess:commandSuccess failure:commandFailure] execute];
    }
    else if (type == APKDVRFileTypeVideo){
        
        [[APKDVRCommandFactory getVideoListCommandWithSuccess:commandSuccess failure:commandFailure] execute];
    }
    else if (type == APKDVRFileTypeEvent){
        
        [[APKDVRCommandFactory getEventListCommandWithSuccess:commandSuccess failure:commandFailure] execute];
    }
    else if (type == APKDVRFileTypeSecurity){
        
        [[APKDVRCommandFactory getSecurityListCommandWithSuccess:commandSuccess failure:commandFailure]execute];
    }
}

@end
