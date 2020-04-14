//
//  APKPhotosKit.h
//  Pioneer
//
//  Created by Mac on 17/9/26.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef void(^APKPhotosKitSaveFileSuccessHandler)(NSString *identifier);
typedef void(^APKPhotosKitSaveFileFailureHandler)(NSError *error);

@interface APKPhotosKit : NSObject

+ (void)saveFileWithURL:(NSURL *)url mediaType:(PHAssetMediaType)mediaType success:(APKPhotosKitSaveFileSuccessHandler)successHandler failure:(APKPhotosKitSaveFileFailureHandler)failureHandler;
+ (void)saveImage:(UIImage *)image success:(APKPhotosKitSaveFileSuccessHandler)successHandler failure:(APKPhotosKitSaveFileFailureHandler)failureHandler;

@end
