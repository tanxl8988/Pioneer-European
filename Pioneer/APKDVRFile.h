//
//  APKDVRFile.h
//  Pioneer
//
//  Created by Mac on 17/9/25.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : int16_t {
    APKDVRFileTypePhoto,
    APKDVRFileTypeVideo,
    APKDVRFileTypeEvent,
    APKDVRFileTypeSecurity,
} APKDVRFileType;

@interface APKDVRFile : NSObject

@property (strong,nonatomic) NSString *name;
@property (nonatomic) APKDVRFileType type;
@property (strong,nonatomic) NSDate *date;
@property (strong,nonatomic) NSURL *url;
@property (strong,nonatomic) NSURL *thumbnailUrl;
@property (strong,nonatomic) NSString *deletePath;
@property (nonatomic) BOOL isDownloaded;
@property (nonatomic,assign) BOOL isHDRFile;
@property (nonatomic,strong) UIImage *image;

@end
