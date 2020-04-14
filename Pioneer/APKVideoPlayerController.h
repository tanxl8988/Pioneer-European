//
//  APKVideoPlayerController.h
//  Pioneer
//
//  Created by Mac on 17/9/28.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APKVideoPlayerController;

@protocol APKVideoPlayerControllerDelegate <NSObject>

- (void)APKVideoPlayerController:(APKVideoPlayerController *)vc didClickFullScreenButton:(UIButton *)sender;

@end

@interface APKVideoPlayerController : UIViewController

@property (weak,nonatomic) id<APKVideoPlayerControllerDelegate>delegate;

- (void)playWithAssets:(NSArray *)assets assetNames:(NSArray *)assetNames currentIndex:(NSInteger)currentIndex;

@end
