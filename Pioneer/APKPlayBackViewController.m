//
//  APKPlayBackViewController.m
//  Pioneer
//
//  Created by Mac on 17/9/28.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKPlayBackViewController.h"
#import "APKTabBarController.h"
#import "APKLocalFile.h"
#import "APKDVRFile.h"

@interface APKPlayBackViewController ()<APKVideoPlayerControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (strong,nonatomic) APKVideoPlayerController *videoPlayer;
@property (assign,nonatomic) BOOL isFullSreenMode;
@property (assign,nonatomic) CGRect portraitFrame;
@property (assign,nonatomic) CGRect fullScreenFrame;


@end

@implementation APKPlayBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = nil;
    self.playerView.frame = self.portraitFrame;
    
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    NSMutableArray *assetNames = [[NSMutableArray alloc] init];
    
    id obj = self.dataSource.firstObject;
    if ([obj isKindOfClass:[APKLocalFile class]]) {
        
        for (APKLocalFile *file in self.dataSource) {
            
            [assets addObject:file.asset];
            [assetNames addObject:file.name];
        }
    }
    else if ([obj isKindOfClass:[APKDVRFile class]]){
        
        for (APKDVRFile *file in self.dataSource) {
            
            AVURLAsset *asset = [AVURLAsset assetWithURL:file.url];
            [assets addObject:asset];
            [assetNames addObject:file.name];
        }
    }
    
    NSString *isDark = [[NSUserDefaults standardUserDefaults] objectForKey:@"DARKMODE"];
         if ([isDark isEqualToString:@"YES"]) {
             self.view.backgroundColor = [UIColor blackColor];
         }
    
    self.videoPlayer.delegate = self;
    [self.videoPlayer playWithAssets:assets assetNames:assetNames currentIndex:self.currentIndex];
}

- (BOOL)prefersStatusBarHidden{
    
    return self.isFullSreenMode;
}

#pragma mark - APKVideoPlayerControllerDelegate

- (void)APKVideoPlayerController:(APKVideoPlayerController *)vc didClickFullScreenButton:(UIButton *)sender{
    
    self.isFullSreenMode = !self.isFullSreenMode;
    
    APKTabBarController *tabBar = (APKTabBarController *)self.tabBarController;
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (self.isFullSreenMode) {
        
        [UIView animateWithDuration:0.3 animations:^{
           
            self.playerView.frame = self.fullScreenFrame;
            self.playerView.transform = CGAffineTransformMakeRotation(M_PI_2);
            tabBar.hideCustomTabBar = self.isFullSreenMode;
        }];
    }
    
    else{
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.playerView.transform = CGAffineTransformIdentity;
            self.playerView.frame = self.portraitFrame;
            tabBar.hideCustomTabBar = self.isFullSreenMode;
        }];
    }
}

#pragma mark - event response

- (IBAction)clickExitButton:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - getter

- (CGRect)fullScreenFrame{
    
    if (_fullScreenFrame.size.width == 0) {
        
        CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
        CGFloat X = screenWidth / 2.f - screenHeight / 2.f;
        CGFloat Y = screenHeight / 2.f - screenWidth / 2.f;
        _fullScreenFrame = CGRectMake(X, Y, screenHeight, screenWidth);
    }
    return _fullScreenFrame;
}

- (CGRect)portraitFrame{
    
    if (_portraitFrame.size.width == 0) {
        
        APKTabBarController *tabBar = (APKTabBarController *)self.tabBarController;
        CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat height = width / 16.f * 9.f;
        CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
        CGFloat spaceHeight = (screenHeight - CGRectGetMaxY(self.topBar.frame) - tabBar.tabBarHeight - height) / 2;
        CGFloat Y = CGRectGetMaxY(self.topBar.frame) + spaceHeight;
        _portraitFrame = CGRectMake(0, Y, width, height);
    }
    
    return _portraitFrame;
}

- (APKVideoPlayerController *)videoPlayer{
    
    if (!_videoPlayer) {
        
        for (id obj in self.childViewControllers) {
            
            if ([obj isKindOfClass:[APKVideoPlayerController class]]) {
                
                _videoPlayer = obj;
                break;
            }
        }
    }
    return _videoPlayer;
}

- (NSMutableArray *)dataSource{
    
    if (!_dataSource) {
        
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

@end
