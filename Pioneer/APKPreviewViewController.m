//
//  APKPreviewViewController.m
//  Pioneer
//
//  Created by Mac on 17/9/12.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKPreviewViewController.h"
#import "APKLiveViewController.h"
#import "APKDVRCommandFactory.h"
#import "APKDVR.h"
#import "APKTabBarController.h"
#import "APKAlertTool.h"
#import "MBProgressHUD.h"
#import "APKGetSettingInfo.h"
#import "sys/utsname.h"
#import "APKPromiseView.h"
#define KIsiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define CAPTURE_DURATION 60.f

@implementation APKLiveStateMathine
{
    dispatch_queue_t _aQueue;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _aQueue = dispatch_queue_create("com.apical.liveStateMathine", NULL);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationState:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationState:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        APKDVR *dvr = [APKDVR sharedInstance];
        [dvr addObserver:self forKeyPath:@"connectState" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    APKDVR *dvr = [APKDVR sharedInstance];
    [dvr removeObserver:self forKeyPath:@"connectState"];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"connectState"]){
        
        APKDVRConnectState connectState = [change[@"new"] unsignedIntegerValue];
        self.isConnectedDVR = connectState == APKDVRConnectStateConnected ? YES : NO;
    }
}

#pragma mark - private method

- (void)handleApplicationState:(NSNotification *)notification{
    
    if ([notification.name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
        
        self.isAPPInBackground = NO;
        
    }else if([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]){
        
        self.isAPPInBackground = YES;
        exit(0);
    }
}

- (void)updateLiveState{
    
    dispatch_block_t block = ^{
      
        if (!self.isAPPInBackground && self.isConnectedDVR && self.isInPreviewPage) {
            
            if (!self.isShouldLive) {
                
                self.isShouldLive = YES;
            }
        }
        else{
            
            if (self.isShouldLive) {
                
                self.isShouldLive = NO;
            }
        }
    };
    dispatch_async(_aQueue, block);
}

#pragma mark - setter

- (void)setIsAPPInBackground:(BOOL)isAPPInBackground{
    
    _isAPPInBackground = isAPPInBackground;
    
    [self updateLiveState];
}

- (void)setIsConnectedDVR:(BOOL)isConnectedDVR{
    
    _isConnectedDVR = isConnectedDVR;
    
    [self updateLiveState];
}

- (void)setIsInPreviewPage:(BOOL)isInPreviewPage{
    
    _isInPreviewPage = isInPreviewPage;
    
    [self updateLiveState];
}


@end

@interface APKPreviewViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *lockButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *lockFlower;
@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *captureFlower;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *liveView;
@property (strong,nonatomic) APKLiveViewController *live;
@property (assign,nonatomic) CGRect liveViewFrame;
@property (strong,nonatomic) NSTimer *captureTimer;
@property (assign,nonatomic) CGFloat captureWaitingTime;//录制时间
@property (strong,nonatomic) MBProgressHUD *captureHUD;
@property (strong,nonatomic) APKLiveStateMathine *liveStateMethine;
@property (nonatomic,retain) UILabel *disConnectedLable;
@property (nonatomic,retain) APKGetSettingInfo *getInfoTool;
@property (nonatomic,retain) UIView *backgroundView;
@property (nonatomic,assign) BOOL isFirstPicture;
@property (nonatomic,retain) UIButton *disConnectedBtn;

@end

@implementation APKPreviewViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        _liveStateMethine = [[APKLiveStateMathine alloc] init];
        [_liveStateMethine addObserver:self forKeyPath:@"isShouldLive" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    APKTabBarController *tabBar = (APKTabBarController *)self.tabBarController;
    self.bottomConstraint.constant = tabBar.tabBarHeight;
    tabBar.customTabBar.hidden = YES;
    
    self.titleLabel.text = NSLocalizedString(@"摄像机", nil);
    [self.connectButton setTitle:@"连接" forState:UIControlStateNormal];
    self.liveView.frame = self.liveViewFrame;
    
    self.isFirstPicture = YES;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"DEVICEWIFIISCLOSE" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        [self sendMessegeToDevice];
        [self.live stopLive];
        [self.live showNoLiveUI];
//        [APKAlertTool showAlertInView:self.view andText:NSLocalizedString(@"关闭了实时流，播放中断", nil)];
    }];

}

-(void)sendMessegeToDevice
{
    [[APKDVRCommandFactory createCommandWithMsgId:134217756 type:nil param:nil success:^(id obj) {
        NSLog(@"");
    } failure:^(int rval) {
        NSLog(@"");
    }]execute] ;
}

- (void)exitApplication {
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [UIView animateWithDuration:1.0f animations:^{
        window.alpha = 0;
        window.frame = CGRectMake(0, window.bounds.size.width, 0, 0);
    } completion:^(BOOL finished) {
        exit(0);
    }];
}

- (void)dealloc
{
    [self.liveStateMethine removeObserver:self forKeyPath:@"isShouldLive"];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];

    APKDVR *dvr = [APKDVR sharedInstance];

    [dvr addObserver:self forKeyPath:@"connectState" options:NSKeyValueObservingOptionNew context:nil];
    
    [self updateUIWithConnectState];
    
    if ([APKDVR sharedInstance].deviceWIfiIsClose == NO)
        self.liveStateMethine.isInPreviewPage = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    APKDVR *dvr = [APKDVR sharedInstance];
    [dvr removeObserver:self forKeyPath:@"connectState"];
    
    self.liveStateMethine.isInPreviewPage = NO;
    [self.live stopLive];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden{
    return self.live.fullScreenMode;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    return UIStatusBarAnimationSlide;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"connectState"]) {
        
        [self updateUIWithConnectState];
    }
    else if ([keyPath isEqualToString:@"isShouldLive"]){
        
        [self updateLiveState];
    }
}

#pragma mark - private method

- (void)quitCapturing{
    
    [self.captureTimer invalidate];
    self.captureTimer = nil;
    
//    [self.captureHUD hideAnimated:YES];
    [self.captureHUD setHidden:YES];
    
    self.lockButton.hidden = NO;
}

- (void)captureTimerMethod:(NSTimer *)timer{
    
    self.captureWaitingTime++;
    int captureLockTime = [APKDVR sharedInstance].deviceNumber == APKDVRDeviceDZ700 ? 23 : 33;
    CGFloat progress = self.captureWaitingTime / captureLockTime;
    self.captureHUD.progress = progress;
    if (progress == 1)
        [self quitCapturing];
}

- (void)updateLiveState{
    
    dispatch_block_t block = ^{
        
        BOOL isShouldLive = self.liveStateMethine.isShouldLive;
        if (isShouldLive) {
            
            [self.live startLive];
            NSLog(@"✅开始实时预览");
        }
        else{
            [self.live stopLive];
            NSLog(@"❌停止实时预览");
        }
    };
    dispatch_async(dispatch_get_main_queue(), block);
}

- (void)updateUIWithConnectState{
    
    dispatch_block_t block = ^{
        
        APKDVRConnectState connectState = [APKDVR sharedInstance].connectState;
        self.connectButton.hidden = connectState == APKDVRConnectStateDisconnected ? NO : YES;
        self.liveView.hidden = connectState == APKDVRConnectStateConnected ? NO : YES;
        self.disConnectedLable.hidden = connectState == APKDVRConnectStateDisconnected ? NO : YES;
        self.disConnectedBtn.hidden = connectState == APKDVRConnectStateDisconnected ? NO : YES;

        [self showPromiseView];
        
        if (connectState == APKDVRConnectStateDisconnected) {
            
            if (self.live.isFullScreenMode) {
                
                [self clickQuitFullScreenButton:self.live.quitFullScreenButton];
            }
            
            if (self.captureTimer) {
                
                [self quitCapturing];
            }
        }
    };
    dispatch_async(dispatch_get_main_queue(), block);
}

-(void)showPromiseView
{
    APKTabBarController *tabBar = (APKTabBarController *)self.tabBarController;
    NSString *promiseValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"promiseValue"];
    if (![promiseValue isEqualToString:@"yes"]) {
        
        APKPromiseView *view = [[NSBundle mainBundle] loadNibNamed:@"APKPromiseView" owner:nil options:nil].firstObject;
        view.center = self.view.center;
        view.frame = CGRectMake(16, 40, CGRectGetWidth(self.backgroundView.frame)-32, CGRectGetHeight(self.backgroundView.frame)-50);
        [view setUpWebView];
        view.wkWebView.frame = CGRectMake(-15,0, self.view.bounds.size.width, CGRectGetHeight(self.backgroundView.frame)-93);
        view.refuseButton.hidden = NO;
        view.sureButton.hidden = NO;
        view.isEULA = NO;
        view.clickActionButton = ^(NSInteger tag) {
            
            if (tag == 100) {
                [self exitApplication];
            }else{
                tabBar.customTabBar.hidden = NO;
                [self.backgroundView removeFromSuperview];
            }
        };
        [self.backgroundView addSubview:view];
    }else
        tabBar.customTabBar.hidden = NO;
}

#pragma mark - event response

- (void)clickQuitFullScreenButton:(UIButton *)sender{
    
    sender.hidden = YES;
    APKTabBarController *tabBar = (APKTabBarController *)self.tabBarController;
    self.live.fullScreenMode = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.liveView.transform = CGAffineTransformIdentity;
        self.liveView.frame = self.liveViewFrame;
        [self setNeedsStatusBarAppearanceUpdate];
        tabBar.hideCustomTabBar = NO;
        
    } completion:^(BOOL finished) {
        
//        if (finished) {
//            
//            self.live.fullScreenMode = NO;
//            [self setNeedsStatusBarAppearanceUpdate];
//        }
    }];
}

- (void)clickEnterFullScreenButton:(UIButton *)sender{
    
    sender.hidden = YES;
    APKTabBarController *tabBar = (APKTabBarController *)self.tabBarController;

    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    CGFloat X = screenWidth / 2.f - screenHeight / 2.f;
    CGFloat Y = screenHeight / 2.f - screenWidth / 2.f;
    CGRect frame = CGRectMake(X, Y, screenHeight, screenWidth);
    self.live.fullScreenMode = YES;

    [UIView animateWithDuration:0.3 animations:^{
        
        self.liveView.frame = frame;
        self.liveView.transform = CGAffineTransformMakeRotation(M_PI_2);
        [self setNeedsStatusBarAppearanceUpdate];
        tabBar.hideCustomTabBar = YES;

    } completion:^(BOOL finished) {
       
//        if (finished) {
//            
//            self.live.fullScreenMode = YES;
//            [self setNeedsStatusBarAppearanceUpdate];
//        }
    }];
}

- (IBAction)clickConnectButton:(UIButton *)sender {
    
    [[APKDVR sharedInstance] connect];
}

- (IBAction)clickLockButton:(UIButton *)sender {
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (dvr.connectState != APKDVRConnectStateConnected)
    {
        return;
    }
    
    
    sender.hidden = YES;
    [self.lockFlower startAnimating];
    
//    self.captureButton.enabled = NO;
//    int delayTime = [APKDVR sharedInstance].deviceNumber == APKDVRDeviceDZ700 ? 4 : 2;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.captureButton.enabled = YES;
//    });
    
    [[APKDVRCommandFactory captureEventCommandWithSuccess:^(id obj) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.lockFlower stopAnimating];
            
            self.captureHUD = [MBProgressHUD showHUDAddedTo:sender.superview animated:YES];
//            self.captureHUD.detailsLabel.text = NSLocalizedString(@"正在录制事件...", nil);
            self.captureHUD.detailsLabelText = NSLocalizedString(@"正在录制事件...", nil);
            self.captureHUD.mode = MBProgressHUDModeAnnularDeterminate;
            
            self.captureWaitingTime = 0;
            self.captureTimer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(captureTimerMethod:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.captureTimer forMode:NSRunLoopCommonModes];
            
            self.captureButton.enabled = NO;
            self.isRecordEvent = YES;
//            self.lockButton.enabled = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC * 10)), dispatch_get_main_queue(), ^{
                self.captureButton.enabled = YES;
                self.isRecordEvent = NO;
            });
            
//            int captureLockTime = [APKDVR sharedInstance].deviceNumber == APKDVRDeviceDZ700 ? 23 : 33;
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC * (captureLockTime + 10))), dispatch_get_main_queue(), ^{
//                self.lockButton.enabled = YES;
//                self.isRecordEvent = NO;
//            });
        });
    } failure:^(int rval) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            sender.hidden = NO;
            [self.lockFlower stopAnimating];
            
            if (rval == -31)
                [APKAlertTool showAlertInViewController:self.tabBarController title:nil message:NSLocalizedString(@"紧急录像中，请稍后再试", nil) confirmHandler:nil];
            else
                [APKAlertTool showAlertInViewController:self.tabBarController title:nil message:NSLocalizedString(@"拍摄事件失败",nil) confirmHandler:nil];        });
        
    }] execute];
}


- (IBAction)clickCaptureButton:(UIButton *)sender {
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (dvr.connectState != APKDVRConnectStateConnected)
    {
        return;
    }
    
    sender.enabled = NO;
    sender.hidden = YES;
    [self.captureFlower startAnimating];
    __block int delayTime = [APKDVR sharedInstance].deviceNumber == APKDVRDeviceDZ700 ? 8 : 2;
    
    [[APKDVRCommandFactory captureCommandWithSuccess:^(id obj) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.captureFlower stopAnimating];
            sender.hidden = NO;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                sender.enabled = YES;
            });
        });
    } failure:^(int rval) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.captureFlower stopAnimating];
            sender.hidden = NO;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                sender.enabled = YES;
            });
            
            if (self.isFirstPicture == YES)
            {
                self.isFirstPicture = NO;
                return;
            }
            
            if (rval == -31)
                 [APKAlertTool showAlertInViewController:self.tabBarController title:nil message:NSLocalizedString(@"紧急录像中，请稍后再试", nil) confirmHandler:nil];
            else
                [APKAlertTool showAlertInViewController:self.tabBarController title:nil message:NSLocalizedString(@"拍摄照片失败",nil) confirmHandler:nil];
        });
        
    }] execute];
}



#pragma mark - getter


- (CGRect)liveViewFrame{
    
    if (_liveViewFrame.size.width == 0) {
        
        CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat height = width / 16.f * 9.f;
        CGFloat Y = CGRectGetMaxY(self.headerView.frame)+26;
        
        NSString *iphone = [self iphoneType];
        if ([iphone isEqualToString:@"iPhone X"] || [iphone isEqualToString:@"iPhone XR"] || [iphone isEqualToString:@"iPhone XS"] || [iphone isEqualToString:@"iPhone XS Max"] || [iphone isEqualToString:@"iPhone 11"] || [iphone isEqualToString:@"iPhone 11 Pro"] || [iphone isEqualToString:@"iPhone 11 Pro Max"]) {
            Y = CGRectGetMaxY(self.headerView.frame) + 50;
        }
        
        _liveViewFrame = CGRectMake(0, Y, width, height);
    }
    return _liveViewFrame;
}

- (NSString*)iphoneType {
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];

    if([platform isEqualToString:@"iPhone10,3"]) return @"iPhone X";
    if([platform isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    if([platform isEqualToString:@"iPhone11,8"]) return @"iPhone XR";
    if([platform isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
    if([platform isEqualToString:@"iPhone11,6"]) return @"iPhone XS Max";
    if([platform isEqualToString:@"iPhone12,1"]) return @"iPhone 11";
    if([platform isEqualToString:@"iPhone12,3"]) return @"iPhone 11 Pro";
    if([platform isEqualToString:@"iPhone12,5"]) return @"iPhone 11 Pro Max";

    return platform;
}

- (APKLiveViewController *)live{
    
    if (!_live) {
        
        for (id obj in self.childViewControllers) {
            
            if ([obj isKindOfClass:[APKLiveViewController class]]) {
                
                _live = obj;
                [_live.enterFullScreenButton addTarget:self action:@selector(clickEnterFullScreenButton:) forControlEvents:UIControlEventTouchUpInside];
                [_live.quitFullScreenButton addTarget:self action:@selector(clickQuitFullScreenButton:) forControlEvents:UIControlEventTouchUpInside];
                break;
            }
        }
    }
    return _live;
}

-(UILabel *)disConnectedLable
{
    if (!_disConnectedLable) {
        _disConnectedLable = [[UILabel alloc] initWithFrame:self.view.bounds];
        _disConnectedLable.backgroundColor = [UIColor whiteColor];
        _disConnectedLable.textAlignment = NSTextAlignmentCenter;
        _disConnectedLable.text = NSLocalizedString(@"未连接", nil);
        _disConnectedLable.hidden = YES;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x - 50, self.view.center.y + 100, 100, 40)];
        btn.backgroundColor = [UIColor grayColor];
        [btn setTitle:NSLocalizedString(@"重新连接", nil) forState:UIControlStateNormal];
        NSString *content = btn.titleLabel.text;
        UIFont *font = btn.titleLabel.font;
        CGSize size = CGSizeMake(MAXFLOAT, 40);
        CGSize buttonSize = [content boundingRectWithSize:size
                                                  options:NSStringDrawingTruncatesLastVisibleLine  | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               attributes:@{ NSFontAttributeName:font}
                                                  context:nil].size;
        btn.frame = CGRectMake(self.view.center.x - buttonSize.width/2 - 10, self.view.center.y + 100,buttonSize.width + 20, 40);
        [btn addTarget:self action:@selector(clickReconnectBtn) forControlEvents:UIControlEventTouchUpInside];
        self.disConnectedBtn = btn;
        [self.view addSubview:_disConnectedLable];
        
        NSString *isDark = [[NSUserDefaults standardUserDefaults] objectForKey:@"DARKMODE"];
        if ([isDark isEqualToString:@"YES"]) {
            _disConnectedLable.backgroundColor = [UIColor blackColor];
            _disConnectedLable.textColor = [UIColor whiteColor];
        }
//        [self.view addSubview:btn];
        
    }
    return _disConnectedLable;
}

-(void)clickReconnectBtn
{
//    NSString *urlString = @"App-Prefs:root=WIFI";
//    NSURL *url = [NSURL URLWithString:urlString];
//    if ([[UIApplication sharedApplication] canOpenURL:url]) {
//        if (@available(iOS 10.0, *)) {
//            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
//        } else {
//            [[UIApplication sharedApplication] openURL:url];
//        }
//    }
    
}

-(APKGetSettingInfo *)getInfoTool
{
    if (!_getInfoTool) {
        _getInfoTool = [[APKGetSettingInfo alloc] init];
    }
    return _getInfoTool;
}

-(UIView *)backgroundView
{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.userInteractionEnabled = YES;
        [self.view addSubview:_backgroundView];
    }
    return _backgroundView;
}

@end
