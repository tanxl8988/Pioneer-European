//
//  APKLiveViewController.h
//  万能AIT
//
//  Created by Mac on 17/3/21.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APKLiveViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *quitFullScreenButton;
@property (weak, nonatomic) IBOutlet UIButton *enterFullScreenButton;
@property (nonatomic,getter=isFullScreenMode) BOOL fullScreenMode;
@property (nonatomic) BOOL isLoading;

- (void)startLive;
- (void)stopLive;
- (void)showNoLiveUI;

@end
