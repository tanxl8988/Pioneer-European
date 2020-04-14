//
//  APKLoadShareItems.h
//  Pioneer
//
//  Created by Mac on 17/9/26.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef void(^APKLoadShareItemsCompletionHandler)(BOOL success,NSArray *items);

@interface APKLoadShareItems : NSObject

+ (void)loadShareItemsWithLocalPhotoAssets:(NSArray *)assets completionHandler:(APKLoadShareItemsCompletionHandler)completionHandler;
+ (void)loadShareItemsWithLocalVideoAsset:(PHAsset *)asset completionHandler:(APKLoadShareItemsCompletionHandler)completionHandler;

@end
