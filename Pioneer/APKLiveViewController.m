//
//  APKLiveViewController.m
//  万能AIT
//
//  Created by Mac on 17/3/21.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKLiveViewController.h"
#import "MobileVLCKit/VLCMediaPlayer.h"
#import "APKDVRCommandFactory.h"
#import "APKDVR.h"

@interface APKLiveViewController ()<VLCMediaPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *flower;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UIButton *changeCameraButton;
@property (strong,nonatomic) UIView *liveView;
@property (strong,nonatomic) VLCMediaPlayer *mediaPlayer;
@property (assign) NSInteger timeCount;
@property (nonatomic,assign) int numberOfRefleshPlayer;

@end

@implementation APKLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mediaPlayer.drawable = self.liveView;
    self.fullScreenMode = NO;
    
}

#pragma mark - private method

- (IBAction)clickSwitchCameraButton:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    NSString *camera = sender.selected ? @"Apk_vin0" : @"Apk_vin1";
    
    __weak typeof  (self) weakSelf = self;
 
    [[APKDVRCommandFactory setSwitchCameraCommandWithParam:camera success:^(id obj) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0/*延迟执行时间*/ * NSEC_PER_SEC)); dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                [weakSelf startLive];
            });
        });
    } failure:^(int rval) {
        NSLog(@"");
    }]execute];
    
}
- (void)loadLiveUI{
    
    self.maskView.hidden = NO;
    self.playButton.hidden = YES;
    [self.flower startAnimating];
}

- (void)showLiveUI{
    
    [self.flower stopAnimating];
    [UIView animateWithDuration:1.f animations:^{
        
        self.maskView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        self.maskView.hidden = YES;
        self.maskView.alpha = 1;
    }];
}

- (void)noLiveUI{

    __weak typeof (self) weakSelf = self;
    
    if (self.numberOfRefleshPlayer == 0 && [APKDVR sharedInstance].deviceWIfiIsClose == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([APKDVR sharedInstance].connectState == APKDVRConnectStateConnected) {
                [weakSelf startLive];
                self.numberOfRefleshPlayer++;
            }
        });
    }else{
        weakSelf.maskView.hidden = NO;
        weakSelf.playButton.hidden = [APKDVR sharedInstance].deviceWIfiIsClose == YES ? YES : NO;
        [weakSelf.flower stopAnimating];
    }
}

- (void)showNoLiveUI{
    
    self.maskView.hidden = NO;
    self.playButton.hidden = YES;
    [self.flower stopAnimating];
}


#pragma mark - public method

- (void)startLive{
    
    [self loadLiveUI];
    self.timeCount = 0;
    self.isLoading = YES;
    
    NSURL *url = [NSURL URLWithString:@"rtsp://192.168.42.1/live"];
    VLCMedia *media = [VLCMedia mediaWithURL:url];
    [self.mediaPlayer setMedia:media];
    [self.mediaPlayer play];
    
    self.changeCameraButton.hidden = [APKDVR sharedInstance].deviceNumber == APKDVRDeviceDZ700 ? NO : YES;
}

- (void)stopLive{
    
    [self.mediaPlayer stop];
}

#pragma mark - VLCMediaPlayerDelegate

- (void)mediaPlayerStateChanged:(NSNotification *)aNotification{
    
    switch (self.mediaPlayer.state) {
        case VLCMediaPlayerStateEnded:
        case VLCMediaPlayerStateStopped:
        case VLCMediaPlayerStateError:
            [self noLiveUI];
            self.isLoading = NO;
            break;
        case VLCMediaPlayerStatePlaying:
            
            break;
        case VLCMediaPlayerStateBuffering:
            
            break;
        default:
            break;
    }
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification{
    
    if (self.timeCount < 3) {
        
        self.timeCount += 1;
        if (self.timeCount == 2){
            [self showLiveUI];
            self.numberOfRefleshPlayer = 0;
            self.isLoading = NO;
        }
    }
}

#pragma mark - event response

- (IBAction)play:(UIButton *)sender {
    
    [self startLive];
}

#pragma mark - getter

- (UIView *)liveView{
    
    if (!_liveView) {
        
        UIViewController *controller = [[UIViewController alloc] init];
        controller.view.frame = self.view.bounds;
        controller.view.backgroundColor = [UIColor blackColor];
        controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addChildViewController:controller];
        [self.view addSubview:controller.view];
        [self.view sendSubviewToBack:controller.view];
        
        _liveView = controller.view;
    }
    return _liveView;
}

- (VLCMediaPlayer *)mediaPlayer{
    
    if (!_mediaPlayer) {
        
        NSString *caching = [NSString stringWithFormat:@"--network-caching=%d",1000];
        NSString *jitter = [NSString stringWithFormat:@"--clock-jitter=%d",1000];
        NSArray *options = @[caching,jitter/*,@"--extraintf="*/,@"--gain=0",@"--rtsp-tcp"];
        _mediaPlayer = [[VLCMediaPlayer alloc] initWithOptions:options];
        _mediaPlayer.delegate = self;
        
    }
    return _mediaPlayer;
}

#pragma mark - setter

- (void)setFullScreenMode:(BOOL)fullScreenMode{
    
    _fullScreenMode = fullScreenMode;
    
    self.quitFullScreenButton.hidden = !fullScreenMode;
    self.enterFullScreenButton.hidden = fullScreenMode;
}

@end
