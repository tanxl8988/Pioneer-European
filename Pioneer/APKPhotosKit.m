//
//  APKPhotosKit.m
//  Pioneer
//
//  Created by Mac on 17/9/26.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKPhotosKit.h"

#define CUSTOM_COLLECTION_IDENTIFIER @"APKCustomCollectionIdentifier"

@implementation APKPhotosKit

#pragma mark - public method

+ (void)saveFileWithURL:(NSURL *)url mediaType:(PHAssetMediaType)mediaType success:(APKPhotosKitSaveFileSuccessHandler)successHandler failure:(APKPhotosKitSaveFileFailureHandler)failureHandler{
    
    [self getCustomCollection:^(PHAssetCollection *assetCollection) {
        
        __block NSString *localIdentifier = nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            
            PHAssetChangeRequest *createAssetRequest = nil;
            if (mediaType == PHAssetMediaTypeImage) {
                createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:url];
            }else if(mediaType == PHAssetMediaTypeVideo){
                createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
            }
            
            PHObjectPlaceholder *assetPlaceholder =  createAssetRequest.placeholderForCreatedAsset;
            PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
            [collectionChangeRequest addAssets:@[assetPlaceholder]];
            localIdentifier = assetPlaceholder.localIdentifier;
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            
            if (success) {
                successHandler(localIdentifier);
            }else{
                failureHandler(error);
            }
        }];
        
    } failure:failureHandler];
}

+ (void)saveImage:(UIImage *)image success:(APKPhotosKitSaveFileSuccessHandler)successHandler failure:(APKPhotosKitSaveFileFailureHandler)failureHandler{
    
    [self getCustomCollection:^(PHAssetCollection *assetCollection) {
        
        __block NSString *localIdentifier = nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            
            PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            PHObjectPlaceholder *assetPlaceholder =  createAssetRequest.placeholderForCreatedAsset;
            PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
            [collectionChangeRequest addAssets:@[assetPlaceholder]];
            localIdentifier = assetPlaceholder.localIdentifier;
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            
            if (success) {
                successHandler(localIdentifier);
            }else{
                failureHandler(error);
            }
        }];
        
    } failure:failureHandler];
}

#pragma mark - private method

+ (void)getCustomCollection:(void (^)(PHAssetCollection *assetCollection))successHandler failure:(APKPhotosKitSaveFileFailureHandler)failure{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *identifier = [userDefaults stringForKey:CUSTOM_COLLECTION_IDENTIFIER];
    PHFetchResult *results = nil;
    if (identifier) {
        
        results = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[identifier] options:nil];
    }
    if (results.count > 0) {
        
        PHAssetCollection *assetCollection = results.firstObject;
        successHandler(assetCollection);
        
    }else{
        
        __block PHObjectPlaceholder *placeholder = nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            CFShow((__bridge CFTypeRef)(infoDictionary));
            NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
            NSString *title = app_Name ? app_Name : @"DVR";
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
            placeholder = request.placeholderForCreatedAssetCollection;
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            
            if (success) {
                
                NSString *identifier = placeholder.localIdentifier;
                [userDefaults setObject:identifier forKey:CUSTOM_COLLECTION_IDENTIFIER];
                [userDefaults synchronize];
                
                PHFetchResult *results = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[identifier] options:nil];
                if (results.count > 0) {
                    
                    PHAssetCollection *assetCollection = results.firstObject;
                    successHandler(assetCollection);
                    
                }else{
                    
                    failure(error);
                }
                
            }else{
                
                failure(error);
            }
        }];
    }
}

@end
