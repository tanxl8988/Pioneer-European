//
//  APKSettingsViewController.m
//  Pioneer
//
//  Created by Mac on 17/9/13.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKSettingsViewController.h"
#import "APKTabBarController.h"
#import "APKDVR.h"
#import "APKDVRCommandFactory.h"
#import "APKAlertTool.h"
#import "MBProgressHUD.h"
#import "APKGetSettingInfo.h"
#import "APKInitializeConnect.h"
#import "APKSettingsContentController.h"
#import "APKPromiseView.h"
#import "APKPreviewViewController.h"

#define WIFI_NAME_TEXT_FIELD 1000
#define WIFI_PASSWORD_TEXT_FIELD 1001


@interface APKSettingsViewController ()<UITextFieldDelegate,UITableViewDelegate,APKSettingsContentDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (strong,nonatomic) APKSettingsContentController *content;
@property (nonatomic) BOOL isVisible;
@property (nonatomic) BOOL isLoadingSettingInfo;
@property (strong,nonatomic) APKGetSettingInfo *getSettingInfo;
@property (strong,nonatomic) APKDVRSettingInfo *settingInfo;
@property (strong,nonatomic) APKDVRWifiInfo *wifiInfo;
@property (weak,nonatomic) UIAlertAction *confirmButton;
@property (weak,nonatomic) UITextField *wifiInfoTextField;
@property (nonatomic) BOOL isSettable;
@property (nonatomic,retain) UIView *maskView;
@property (nonatomic,retain) UISegmentedControl *currentSC;

@end

@implementation APKSettingsViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        APKDVR *dvr = [APKDVR sharedInstance];
        [dvr addObserver:self forKeyPath:@"connectState" options:NSKeyValueObservingOptionNew context:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkoutWIFI:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    [dvr removeObserver:self forKeyPath:@"connectState"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    APKTabBarController *tabBar = (APKTabBarController *)self.tabBarController;
    self.bottomConstraint.constant = tabBar.tabBarHeight;
    
    self.content.delegate = self;
    self.content.clipDurationLabel.text = NSLocalizedString(@"录制时长", nil);
    [self.content.clipDurationSC removeAllSegments];
    [self.content.clipDurationSC insertSegmentWithTitle:NSLocalizedString(@"1分钟", nil) atIndex:0 animated:NO];
    [self.content.clipDurationSC insertSegmentWithTitle:NSLocalizedString(@"3分钟", nil) atIndex:1 animated:NO];
    [self.content.clipDurationSC insertSegmentWithTitle:NSLocalizedString(@"5分钟", nil) atIndex:2 animated:NO];
    self.content.videoFormatLabel.text = NSLocalizedString(@"视频格式", nil);
    self.content.syncTimeLabel.text = NSLocalizedString(@"时间同步", nil);
    self.content.wifiNameLabel.text = @"SSID";
    self.content.wifiPasswordLabel.text = NSLocalizedString(@"WiFi密码", nil);
    self.content.formatSDCardLabel.text = NSLocalizedString(@"格式化SD卡", nil);
    self.content.factoryResetLabel.text = NSLocalizedString(@"恢复出厂设置", nil);
    self.content.firmwareVersionLabel.text = NSLocalizedString(@"软件信息", nil);
    self.content.specificationL.text = @"使い方";;
    self.content.passwordTipLabel.text = NSLocalizedString(@"初始值：88888888", nil);
    self.content.versionL.text = NSLocalizedString(@"版本号", nil);
    self.content.sourceCodeL.text = NSLocalizedString(@"开放源代码许可", nil);
    self.content.instructionL.text = NSLocalizedString(@"说明书", nil);
    self.content.EULALabel.text = NSLocalizedString(@"EULA", nil);
    self.content.clipDurationSC.layer.borderColor = [UIColor colorWithRed:183/255.f green:23/255.f blue:66/255.f alpha:1].CGColor;
    self.content.videoFormatSC.layer.borderColor = [UIColor colorWithRed:183/255.f green:23/255.f blue:66/255.f alpha:1].CGColor;

    
    [self.content.clipDurationSC addTarget:self action:@selector(updateClipDurationSC:) forControlEvents:UIControlEventValueChanged];//录制时长
    [self.content.videoFormatSC addTarget:self action:@selector(updateVideoFormatSC:) forControlEvents:UIControlEventValueChanged];//视频格式
    [self.content.syncTimeSwitch addTarget:self action:@selector(toggleSyncTimeSwitch:) forControlEvents:UIControlEventValueChanged];//同步时间
    
    if ([APKDVR sharedInstance].deviceNumber == APKDVRDeviceDZ600) {
        
        [self.content.videoFormatSC setTitle:@"1080P" forSegmentAtIndex:0];
        [self.content.videoFormatSC setTitle:@"1080P HDR" forSegmentAtIndex:1];
        [self.content.videoFormatSC setTitle:@"720P" forSegmentAtIndex:2];
        [self.content.videoFormatSC setTitle:@"720P HDR" forSegmentAtIndex:3];
    }else if ([APKDVR sharedInstance].deviceNumber == APKDVRDeviceDZ700){
        
        [self.content.videoFormatSC setTitle:@"1080P" forSegmentAtIndex:0];
        [self.content.videoFormatSC setTitle:@"720P" forSegmentAtIndex:1];
        [self.content.videoFormatSC removeSegmentAtIndex:2 animated:NO];
        [self.content.videoFormatSC removeSegmentAtIndex:2 animated:NO];
    }else{
        
        [self.content.videoFormatSC setTitle:@"720P" forSegmentAtIndex:0];
        [self.content.videoFormatSC setTitle:@"960P" forSegmentAtIndex:1];
        [self.content.videoFormatSC setTitle:@"720P HDR" forSegmentAtIndex:2];
        [self.content.videoFormatSC removeSegmentAtIndex:3 animated:NO];
    }
    
    
    APKPreviewViewController *previewVC = self.tabBarController.viewControllers.firstObject;
    [previewVC addObserver:self forKeyPath:@"isRecordEvent" options:NSKeyValueObservingOptionNew context:nil];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    self.content.appVersionL.text = [NSString stringWithFormat:@"v%@",app_Version];
    
    self.content.tableView.tableFooterView = [UIView new];
    
    
//    self.content.wifiPasswordInfoLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:KWifiPassword];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.isVisible = YES;
    
    if ([APKDVR sharedInstance].connectState == APKDVRConnectStateConnected) {
   
        if (!self.settingInfo && !self.isLoadingSettingInfo) {
            
            [self loadSettingInfo];
        }
    }else if([APKDVR sharedInstance].connectState == APKDVRConnectStateDisconnected)
    {
        self.content.wifiPasswordInfoLabel.text = NSLocalizedString(@"初始值：88888888", nil);
        self.content.wifiPasswordInfoLabel.frame = CGRectMake(self.view.bounds.size.width - 275, 12,240 , 40);
        self.content.wifiNameInfoLabel.text = NSLocalizedString(@"初始值：Pioneer_DVR", nil);
        self.content.wifiNameInfoLabel.frame = CGRectMake(self.view.bounds.size.width - 275, 12,240 , 40);
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    self.isVisible = NO;
}



#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"connectState"]) {
        
        APKDVRConnectState connectState = [change[@"new"] integerValue];
        
        if (connectState == APKDVRConnectStateDisconnected) {
            
            self.settingInfo = nil;
            self.wifiInfo = nil;
            
            [self resetPage];
        }
        else if (connectState == APKDVRConnectStateConnected){
            
            if (self.isVisible) {
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self loadSettingInfo];
                });
            }
        }
    }
    if ([keyPath isEqualToString:@"isRecordEvent"]) {
        
        BOOL isRecordEvent = [change[@"new"] integerValue];

        if (isRecordEvent) {
            self.content.clipDurationSC.enabled = NO;
            self.content.videoFormatSC.enabled = NO;
        }else{
            self.content.clipDurationSC.enabled = YES;
            self.content.videoFormatSC.enabled = YES;

        }
    }
}

#pragma mark - private method

- (void)updateSyncTimeUserDefaults:(BOOL)isShouldSyncTime{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *state = [userDefaults stringForKey:APKAutoSyncTime];
    if (isShouldSyncTime && (!state || [state isEqualToString:APKAutoSyncTimeClose])) {
        [userDefaults setObject:APKAutoSyncTimeOpen forKey:APKAutoSyncTime];
        [userDefaults synchronize];
    }
    else if (!isShouldSyncTime && [state isEqualToString:APKAutoSyncTimeOpen]){
        [userDefaults setObject:APKAutoSyncTimeClose forKey:APKAutoSyncTime];
        [userDefaults synchronize];
    }
}

- (void)checkoutWIFI:(NSNotification *)notification{
    
    if ([notification.name isEqualToString:UITextFieldTextDidChangeNotification]) {
        
        if (self.wifiInfoTextField.tag == WIFI_NAME_TEXT_FIELD) {
            
            if (self.wifiInfoTextField.text.length == 0 || [self.wifiInfoTextField.text isEqualToString:self.wifiInfo.account] || self.wifiInfoTextField.text.length > 11) {
                
                self.confirmButton.enabled = NO;
            }
            else{
                
                self.confirmButton.enabled = YES;
            }
        }
        else if (self.wifiInfoTextField.tag == WIFI_PASSWORD_TEXT_FIELD){
            
            if (self.wifiInfoTextField.text.length != 8 || [self.wifiInfoTextField.text isEqualToString:self.wifiInfo.password]) {
                
                self.confirmButton.enabled = NO;
            }
            else{
                
                self.confirmButton.enabled = YES;
            }
        }
    }
}

- (void)showModifyWifiPasswordAlert{
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *account = self.wifiInfo.account;
        NSString *password = self.wifiInfoTextField.text;
        [self modifyWifiWithAccount:account password:password];
    }];
    confirm.enabled = NO;
    self.confirmButton = confirm;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"WiFi密码", nil) message:NSLocalizedString(@"请输入8位Wi-Fi密码：", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:cancel];
    [alert addAction:confirm];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        textField.delegate = self;
        textField.keyboardType = UIKeyboardTypeASCIICapable;
        textField.text = self.wifiInfo.password;
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.tag = WIFI_PASSWORD_TEXT_FIELD;
        self.wifiInfoTextField = textField;
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showModifyWifiAccountAlert{
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *account = self.wifiInfoTextField.text;
        NSString *password = self.wifiInfo.password;
        [self modifyWifiWithAccount:account password:password];
    }];
    confirm.enabled = NO;
    self.confirmButton = confirm;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"WiFi名称", nil) message:NSLocalizedString(@"请输入1-11位Wi-Fi名称：", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:cancel];
    [alert addAction:confirm];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        textField.delegate = self;
        textField.keyboardType = UIKeyboardTypeASCIICapable;
        textField.text = self.wifiInfo.account;
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.tag = WIFI_NAME_TEXT_FIELD;
        self.wifiInfoTextField = textField;
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)modifyWifiWithAccount:(NSString *)account password:(NSString *)password{
    
    __weak typeof(self)weakSelf = self;
    if ([self isEventRecord]) {
        [APKAlertTool showAlertInViewController:self title:nil message:NSLocalizedString(@"紧急录像中，无法设置", nil) confirmHandler:^(UIAlertAction *action) {
        }];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
    [[APKDVRCommandFactory modifyWifiWithAccount:account password:password success:^(id obj) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            weakSelf.wifiInfo.account = account;
            weakSelf.wifiInfo.password = password;
            
            weakSelf.content.wifiNameInfoLabel.text = weakSelf.wifiInfo.account;
            weakSelf.content.wifiPasswordInfoLabel.text = weakSelf.wifiInfo.password;
            [hud hide:YES];
            [APKAlertTool showAlertInViewController:weakSelf title:NSLocalizedString(@"设置成功", nil) message:NSLocalizedString(@"修改WiFi成功提示", nil) confirmHandler:nil];
            
//            [[NSUserDefaults standardUserDefaults] setObject:password forKey:KWifiPassword];
//            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[APKDVR sharedInstance] disConnect];
        });
        
    } failure:^(int rval) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            weakSelf.content.wifiNameInfoLabel.text = weakSelf.wifiInfo.account;
            weakSelf.content.wifiPasswordInfoLabel.text = weakSelf.wifiInfo.password;
            [hud hide:YES];
            [APKAlertTool showAlertInViewController:weakSelf title:nil message:NSLocalizedString(@"设置失败", nil) confirmHandler:nil];
        });
        
    }]execute];
}

- (void)syncTime{
    
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *currentDate = [date  dateByAddingTimeInterval: interval];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *currentTime = [formatter stringFromDate:currentDate];
    
    [[APKDVRCommandFactory setCommandWithType:AMBATypeCameraClock param:currentTime success:^(id obj) {
        
        
    } failure:^(int rval) {
        
        
    }]execute];
}

- (void)formatSDCard{
    
    NSString *title = [NSString stringWithFormat:@"%@?",NSLocalizedString(@"格式化SD卡", nil)];
    NSString *message = [NSString stringWithFormat:@"%@?",NSLocalizedString(@"格式化SD卡详情", nil)];
    [APKAlertTool showAlertInViewController:self title:title message:message cancelHandler:nil confirmHandler:^(UIAlertAction *action) {
        
        __weak typeof(self)weakSelf = self;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
        APKDVRCommand *command = [APKDVRCommandFactory formatSDCardCommandWithSuccess:^(id obj) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:YES];
                [APKAlertTool showAlertInViewController:weakSelf title:NSLocalizedString(@"格式化SD卡成功", nil) message:NSLocalizedString(@"格式化成功提示", nil) confirmHandler:nil];
            });
            
        } failure:^(int rval) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [hud hide:YES];
                [APKAlertTool showAlertInViewController:weakSelf title:nil message:NSLocalizedString(@"格式化SD卡失败", nil) confirmHandler:nil];
            });
        }];
        [[APKDVR sharedInstance] executeCommand:command];
    }];
}

- (void)factoryReset{
    
    NSString *title = [NSString stringWithFormat:@"%@?",NSLocalizedString(@"恢复出厂设置", nil)];
    NSString *message = [NSString stringWithFormat:@"%@?",NSLocalizedString(@"恢复出厂设置详情", nil)];
    [APKAlertTool showAlertInViewController:self title:title message:message cancelHandler:nil confirmHandler:^(UIAlertAction *action) {
        
        __weak typeof(self)weakSelf = self;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
        APKDVRCommand *command = [APKDVRCommandFactory setCommandWithType:@"Apk_default" param:@"yes" success:^(id obj) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [hud hide:YES];
                [APKAlertTool showAlertInViewController:weakSelf title:nil message:NSLocalizedString(@"恢复出厂设置成功", nil) confirmHandler:nil];
            });
            
        } failure:^(int rval) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [hud hide:YES];
                [APKAlertTool showAlertInViewController:weakSelf title:nil message:NSLocalizedString(@"格式化SD卡失败", nil) confirmHandler:nil];
            });
        }];
        [[APKDVR sharedInstance] executeCommand:command];
    }];
}

- (void)resetPage{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.content.clipDurationSC.selectedSegmentIndex = UISegmentedControlNoSegment;
        self.content.videoFormatSC.selectedSegmentIndex = UISegmentedControlNoSegment;
        self.content.syncTimeSwitch.on = NO;
        self.content.wifiPasswordInfoLabel.text = NSLocalizedString(@"初始值：88888888", nil);
        self.content.wifiNameInfoLabel.text = NSLocalizedString(@"初始值：Pioneer_DVR", nil);
        self.content.firmwareVersionInfoLabel.text = @"--";
        self.content.wifiNameInfoLabel.frame = CGRectMake(self.view.bounds.size.width - 275, 12,240 , 40);
        self.content.wifiPasswordInfoLabel.frame = CGRectMake(self.view.bounds.size.width - 275, 12,240 , 40);
    });
}

- (void)loadSettingInfo{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.isLoadingSettingInfo = YES;
    __weak typeof(self)weakSelf = self;
    [self.getSettingInfo getSettingInfoSuccess:^(APKDVRSettingInfo *settingInfo, APKDVRWifiInfo *wifiInfo) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            weakSelf.settingInfo = settingInfo;
            weakSelf.wifiInfo = wifiInfo;
            weakSelf.isLoadingSettingInfo = NO;
            
            [weakSelf updateSyncTimeUserDefaults:settingInfo.timeAsync];
            
            weakSelf.content.clipDurationSC.selectedSegmentIndex = weakSelf.settingInfo.clipDuration;
            weakSelf.content.videoFormatSC.selectedSegmentIndex = weakSelf.settingInfo.videoResolution;
            if (weakSelf.settingInfo.videoResolution > 3)
                weakSelf.content.videoFormatSC.selectedSegmentIndex = 1;
            
            weakSelf.content.syncTimeSwitch.on = weakSelf.settingInfo.timeAsync;
            weakSelf.content.firmwareVersionInfoLabel.text = weakSelf.settingInfo.firmwareVersion;
            
            weakSelf.content.wifiNameInfoLabel.text = weakSelf.wifiInfo.account;
            weakSelf.content.wifiPasswordInfoLabel.text = weakSelf.wifiInfo.password;
            self.content.wifiNameInfoLabel.frame = CGRectMake(self.view.bounds.size.width - 120, 12,90 , 40);
            self.content.wifiPasswordInfoLabel.frame = CGRectMake(self.view.bounds.size.width - 120, 12,90 , 40);
//            [[NSUserDefaults standardUserDefaults] setObject:weakSelf.wifiInfo.password forKey:KWifiPassword];
//            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [hud hide:YES];
        });
        
    } failure:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            weakSelf.isLoadingSettingInfo = NO;
            [hud hide:YES];
        });
    }];
}

#pragma mark -  APKSettingsContentDelegate（cell设置）

- (void)didSelectctedCell:(UITableViewCell *)cell{
    
    if(cell == self.content.infoCell){
        
        UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *specificationVC = [mainSB instantiateViewControllerWithIdentifier:@"APKPrecificationViewController"];
        specificationVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:specificationVC animated:NO completion:^{
            nil;
        }];
    }
    
    if (!self.isSettable && (cell != self.content.specificationCell && cell != self.content.EULACell)) {
        
        [APKAlertTool showAlertInViewController:self title:nil message:NSLocalizedString(@"请连接WiFi", nil) confirmHandler:^(UIAlertAction *action) {
            nil;
        }];
        return;
    }
    
    if (cell == self.content.factoryResetCell) {//恢复出厂设置
        
        [self factoryReset];
    }
    else if (cell == self.content.formatSDCardCell){//格式化sd卡
        
        [self formatSDCard];
    }
    else if (cell == self.content.wifiNameCell){//wifi名称
        
        [self showModifyWifiAccountAlert];
    }
    else if (cell == self.content.wifiPasswordCell){//wifi密码
        
        [self showModifyWifiPasswordAlert];
    }
    else if (cell == self.content.specificationCell){//说明书
        
        [self goToSpecificationViewController];
    }else if(cell == self.content.EULACell){
    
        __weak APKPromiseView *view = [[NSBundle mainBundle] loadNibNamed:@"APKPromiseView" owner:nil options:nil].firstObject;
        view.center = self.view.center;
        view.setSureButton.hidden = NO;
        view.frame = CGRectMake(40, 40, CGRectGetWidth(self.maskView.frame)-80, CGRectGetHeight(self.maskView.frame)-50);
        view.clickActionButton = ^(NSInteger tag) {
            
            [self.maskView removeFromSuperview];
            [view removeFromSuperview];
        };
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow addSubview:self.maskView];
        [keyWindow addSubview:view];
    }
}

-(void)goToSpecificationViewController
{
    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *specificationVC = [mainSB instantiateViewControllerWithIdentifier:@"nihao"];
    specificationVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:specificationVC animated:NO completion:^{
        nil;
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    BOOL isShouldChangeCharacters = YES;
    
    for (NSUInteger index = 0; index < string.length;index++) {
        
        char ch = [string characterAtIndex:index];
        if ((ch >= '0' && ch <= '9') || ch == '_' || (ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z'))
            continue;
        
        isShouldChangeCharacters = NO;
        break;
    }
    
    return isShouldChangeCharacters;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - event response

- (void)toggleSyncTimeSwitch:(UISwitch *)sender {
    
    if (!self.isSettable) {
        
        sender.on = NO;
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    NSString *param = [self.settingInfo timeAsyncMap][sender.isOn];
    [[APKDVRCommandFactory setCommandWithType:APKKeyTimeAsync param:param success:^(id obj) {
        
        weakSelf.settingInfo.timeAsync = sender.isOn;
        
        //更新数据库
        NSString *syncTimeState = sender.isOn ? APKAutoSyncTimeOpen : APKAutoSyncTimeClose;
        [[NSUserDefaults standardUserDefaults] setObject:syncTimeState forKey:APKAutoSyncTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (sender.isOn) {
            
            [weakSelf syncTime];
        }
        
    } failure:^(int rval) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            sender.on = weakSelf.settingInfo.timeAsync;
        });
        
    }] execute];
}

- (void)updateVideoFormatSC:(UISegmentedControl *)sender {
    
    if (!self.isSettable) {
        
        sender.selectedSegmentIndex = UISegmentedControlNoSegment;
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    if ([self isEventRecord]) {
        [APKAlertTool showAlertInViewController:self title:nil message:NSLocalizedString(@"紧急录像中，无法设置", nil) confirmHandler:^(UIAlertAction *action) {
            sender.selectedSegmentIndex = weakSelf.settingInfo.videoResolution;
            
        }];
        return;
    }
    
    NSString *param = [self.settingInfo videoResolutionMap][sender.selectedSegmentIndex];
    [[APKDVRCommandFactory setCommandWithType:APKKeyVideoRes param:param success:^(id obj) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.settingInfo.videoResolution = sender.selectedSegmentIndex;
            sender.enabled = NO;
            int delayTime = [APKDVR sharedInstance].deviceNumber == APKDVRDeviceDZ600 ? 8 : 5;
            [weakSelf performSelector:@selector(enableVideoFormatSC) withObject:nil afterDelay:delayTime];
        });

        
    } failure:^(int rval) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            sender.selectedSegmentIndex = weakSelf.settingInfo.videoResolution;
        });
        
    }] execute];
}

-(void)enableVideoFormatSC
{
    self.content.videoFormatSC.enabled = YES;
}

- (void)updateClipDurationSC:(UISegmentedControl *)sender {
    
    if (!self.isSettable) {
        
        sender.selectedSegmentIndex = UISegmentedControlNoSegment;
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    if ([self isEventRecord]) {
        [APKAlertTool showAlertInViewController:self title:nil message:NSLocalizedString(@"紧急录像中，无法设置", nil) confirmHandler:^(UIAlertAction *action) {
            sender.selectedSegmentIndex = weakSelf.settingInfo.videoResolution;
            
        }];
        return;
    }

    NSString *param = [self.settingInfo clipDurationMap][sender.selectedSegmentIndex];
    [[APKDVRCommandFactory setCommandWithType:APKKeyClipDuration param:param success:^(id obj) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.settingInfo.clipDuration = sender.selectedSegmentIndex;
            sender.enabled = NO;
            int delayTime = [APKDVR sharedInstance].deviceNumber == APKDVRDeviceDZ600 ? 8 : 5;
            [self performSelector:@selector(enableClipDurationSC) withObject:sender afterDelay:delayTime];
        });
        
    } failure:^(int rval) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            sender.selectedSegmentIndex = weakSelf.settingInfo.clipDuration;
        });
        
    }] execute];
}

-(BOOL)isEventRecord
{
    APKTabBarController *tabBar = (APKTabBarController *)self.tabBarController;
    APKPreviewViewController *previewVC = tabBar.viewControllers.firstObject;
    return previewVC.isRecordEvent;
}

-(void)enableClipDurationSC
{
    
    self.content.clipDurationSC.enabled = YES;
}

#pragma mark - getter

- (BOOL)isSettable{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (dvr.connectState != APKDVRConnectStateConnected) {
        
        return NO;
    }
    else{
        
        if (!self.settingInfo) {
            
            if (!self.isLoadingSettingInfo) {
                
                [self loadSettingInfo];
            }
            return NO;
        }
    }
    return YES;
}

- (APKSettingsContentController *)content{
    
    if (!_content) {
        
        for (id obj in self.childViewControllers) {
            if ([obj isKindOfClass:[APKSettingsContentController class]]) {
                _content = obj;
                break;
            }
        }
    }
    return _content;
}

- (APKGetSettingInfo *)getSettingInfo{
    
    if (!_getSettingInfo) {
        
        _getSettingInfo = [[APKGetSettingInfo alloc] init];
    }
    return _getSettingInfo;
}

-(UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.view.bounds];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = 0.8;
    }
    return _maskView;
}


@end
