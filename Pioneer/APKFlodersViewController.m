//
//  APKFlodersViewController.m
//  Pioneer
//
//  Created by Mac on 17/9/12.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKFlodersViewController.h"
#import "APKTabBarController.h"
#import "APKFlodersView.h"
#import "APKDVRFilesViewController.h"
#import "APKLocalFilesViewController.h"
#import "APKDVR.h"
#import <Photos/Photos.h>
#import "APKAlertTool.h"

@interface APKFlodersViewController ()<APKFlodersViewDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *leftPageView;
@property (weak, nonatomic) IBOutlet UIView *rightPageView;

@property (strong,nonatomic) APKFlodersView *localFlodersView;
@property (strong,nonatomic) APKFlodersView *dvrFlodersView;
@property (strong,nonatomic) NSArray *floders;
@property (nonatomic) BOOL isHavePhotosAuthority;

@end

@implementation APKFlodersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    APKTabBarController *tabBar = (APKTabBarController *)self.tabBarController;
    self.bottomConstraint.constant = tabBar.tabBarHeight;
        
    CGFloat pageWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    self.contentViewWidthConstraint.constant = pageWidth * 2;
    
    [self.segmentControl setTitle:NSLocalizedString(@"摄像机文件", nil) forSegmentAtIndex:0];
    [self.segmentControl setTitle:NSLocalizedString(@"本地文件", nil) forSegmentAtIndex:1];
    
    NSString *isDark = [[NSUserDefaults standardUserDefaults] objectForKey:@"DARKMODE"];
        if ([isDark isEqualToString:@"YES"]) {
            self.segmentControl.backgroundColor = [UIColor blackColor];
        }
    
    self.dvrFlodersView.frame = self.rightPageView.bounds;
    self.dvrFlodersView.delegate = self;
    [self.leftPageView addSubview:self.dvrFlodersView];
    
    self.localFlodersView.frame = self.leftPageView.bounds;
    self.localFlodersView.delegate = self;
    [self.rightPageView addSubview:self.localFlodersView];
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
        }];
    }
}

#pragma mark - private

- (void)showGetPhotosAuthorityAlert{//获得照片权限
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"将所记录数据下载到“照片“，请允许访问iPhone的”照片”", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        UIApplication *app = [UIApplication sharedApplication];
        if ([app canOpenURL:url]) {
            
            NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
            NSInteger iosVersionNumber = [[[iosVersion componentsSeparatedByString:@"."] firstObject] integerValue];
            if (iosVersionNumber >= 10) {
                
                [app openURL:url options:@{} completionHandler:^(BOOL success) { /*do nothing*/ }];
                
            }else{
                [app openURL:url];
            }
        }
    }];

    [alertController addAction:confirm];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - APKFlodersViewDelegate

- (void)APKFlodersView:(APKFlodersView *)flodersView didSelectedFloderAtIndex:(NSInteger)index{
    
    if (flodersView == self.localFlodersView) {
        
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
            [self performSegueWithIdentifier:@"checkLocalFiles" sender:@(index)];//根据场景线推出控制器
        }
        else{
            [self showGetPhotosAuthorityAlert];
        }
    }
    else if (flodersView == self.dvrFlodersView){
        
        APKDVR *dvr = [APKDVR sharedInstance];
        if (dvr.connectState == APKDVRConnectStateConnected) {
            
            [self performSegueWithIdentifier:@"checkDVRFiles" sender:@(index)];
        }
        else{
            
            [APKAlertTool showAlertInViewController:self title:nil message:NSLocalizedString(@"请连接WiFi", nil) confirmHandler:^(UIAlertAction *action) {
                nil;
            }];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (scrollView.contentOffset.x == 0) {
        
        self.segmentControl.selectedSegmentIndex = 0;
    }
    else{
        
        self.segmentControl.selectedSegmentIndex = 1;
    }
}

#pragma mark - event response

- (IBAction)updateSegmentControl:(UISegmentedControl *)sender {

    if (sender.selectedSegmentIndex == 0) {
        
        [UIView animateWithDuration:0.3 animations:^{
           
            self.scrollView.contentOffset = CGPointMake(0, 0);
        }];
    }
    else{
        
        [UIView animateWithDuration:0.3 animations:^{
            
            CGFloat pageWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
            self.scrollView.contentOffset = CGPointMake(pageWidth, 0);
        }];
    }
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"checkDVRFiles"]) {
        
        NSInteger index = [sender integerValue];
        APKDVRFileType fileType;
        if (index == 0) {
            fileType = APKDVRFileTypeVideo;
        }
        else if (index == 1){
            fileType = APKDVRFileTypeEvent;
        }
        else if (index == 2){
            fileType = APKDVRFileTypeSecurity;
        }
        else if (index == 3){
            fileType = APKDVRFileTypePhoto;
        }
        
        APKDVRFilesViewController *vc = segue.destinationViewController;
        vc.fileType = fileType;
    }
    else if ([segue.identifier isEqualToString:@"checkLocalFiles"]){
        
        NSInteger index = [sender integerValue];
        APKDVRFileType fileType;
        if (index == 0) {
            fileType = APKDVRFileTypeVideo;
        }
        else if (index == 1){
            fileType = APKDVRFileTypeEvent;
        }
        else if (index == 2){
            fileType = APKDVRFileTypeSecurity;
        }
        else if (index == 3){
            fileType = APKDVRFileTypePhoto;
        }
        
        APKLocalFilesViewController *vc = segue.destinationViewController;
        vc.fileType = fileType;
    }
}

#pragma mark - getter

- (BOOL)isHavePhotosAuthority{
    
    return [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized;
}

- (APKFlodersView *)dvrFlodersView{
    
    if (!_dvrFlodersView) {
        
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"APKFlodersView" owner:nil options:nil];
        for (id obj in arr) {
            if ([obj isKindOfClass:[APKFlodersView class]]) {
                
                _dvrFlodersView = obj;
                break;
            }
        }
    }
    return _dvrFlodersView;
}

- (APKFlodersView *)localFlodersView{
    
    if (!_localFlodersView) {
        
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"APKFlodersView" owner:nil options:nil];
        for (id obj in arr) {
            if ([obj isKindOfClass:[APKFlodersView class]]) {
                
                _localFlodersView = obj;
                break;
            }
        }
    }
    return _localFlodersView;
}


@end
