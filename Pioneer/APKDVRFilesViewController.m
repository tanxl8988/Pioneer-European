//
//  APKDVRFilesViewController.m
//  Pioneer
//
//  Created by Mac on 17/9/13.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKDVRFilesViewController.h"
#import "APKTabBarController.h"
#import "APKFileCell.h"
#import "APKGetDVRFiles.h"
#import "UIImageView+WebCache.h"
#import "MWPhotoBrowser.h"
#import "MBProgressHUD.h"
#import "APKBatchDelete.h"
#import "APKAlertTool.h"
#import "APKBatchDownload.h"
#import "APKDownloadInfoView.h"
#import "APKPlayBackViewController.h"
#import "MobileVLCKit/VLCMediaPlayer.h"
#import "APKDVRCommandFactory.h"
#import "APKDVR.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVTime.h>

static NSString *cellIdentifier = @"fileCell";

@interface APKDVRFilesViewController ()<UITableViewDataSource,UITableViewDelegate,MWPhotoBrowserDelegate,APKFileCellDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
@property (weak, nonatomic) IBOutlet UIButton *checkAllButton;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBarHeightConstraint;
@property (strong,nonatomic) UIRefreshControl *refreshControl;
@property (strong,nonatomic) NSMutableArray *dataSource;
@property (strong,nonatomic) NSMutableArray *photos;
@property (strong,nonatomic) APKBatchDelete *batchDelete;
@property (strong,nonatomic) APKBatchDownload *batchDownload;
@property (nonatomic,retain) NSIndexPath *lastIndexPath;
@property (nonatomic,assign) BOOL isCheckAll;
@property (nonatomic,assign) BOOL isScrolling;

@end

@implementation APKDVRFilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.editing = NO;
    self.tableView.rowHeight = 80;

    APKTabBarController *tabBar = (APKTabBarController *)self.tabBarController;
    self.tableViewBottomConstraint.constant = tabBar.tabBarHeight;
    self.bottomBarHeightConstraint.constant = tabBar.tabBarHeight;
    
    [self updateTitleWithFileCount:0];
    
    self.filterButton.hidden = YES;
    [self.cancelButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
//    [self.checkAllButton setTitle:NSLocalizedString(@"全选", nil) forState:UIControlStateNormal];
    
    [self.tableView addSubview:self.refreshControl];
    [self.tableView sendSubviewToBack:self.refreshControl];
    
    [self requestDVRFileList];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationState:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    self.tableView.allowsMultipleSelection = NO;
    
    NSString *isDark = [[NSUserDefaults standardUserDefaults] objectForKey:@"DARKMODE"];
    if ([isDark isEqualToString:@"YES"]) {
        self.view.backgroundColor = [UIColor blackColor];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

}

- (void)handleApplicationState:(NSNotification *)notification{
    
    if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        [self startRecordMission];
        [APKDVR sharedInstance];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    //释放照片浏览器占用的内存
    if (self.photos.count != 0)
        [self.photos removeAllObjects];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method

- (void)updateTitleWithFileCount:(NSInteger)count{
    
    NSString *title = nil;
    if (self.fileType == APKDVRFileTypePhoto) {
        title = [NSString stringWithFormat:@"%@(%d)",NSLocalizedString(@"照片", nil),(int)count];
    }
    else if (self.fileType == APKDVRFileTypeVideo) {
        title = [NSString stringWithFormat:@"%@(%d)",NSLocalizedString(@"视频", nil),(int)count];
    }
    else if (self.fileType == APKDVRFileTypeEvent) {
        title = [NSString stringWithFormat:@"%@(%d)",NSLocalizedString(@"事件", nil),(int)count];
    }
    else if (self.fileType == APKDVRFileTypeSecurity) {
        title = [NSString stringWithFormat:@"%@(%d)",NSLocalizedString(@"泊车", nil),(int)count];
    }
    
    self.titleLabel.text = title;
}

- (void)showGetPhotosAuthorityAlert{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"将所记录数据下载到“照片“，请允许访问iPhone的”照片”", nil) preferredStyle:UIAlertControllerStyleAlert];
    
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
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:confirm];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateButtonsEnableState{
    
    if (self.tableView.indexPathsForSelectedRows.count == 0) {
        
        self.deleteButton.enabled = NO;
        self.downloadButton.enabled = NO;
    }
    else{
        
        self.deleteButton.enabled = YES;
        self.downloadButton.enabled = YES;
        
        if ([APKDVR sharedInstance].deviceNumber == APKDVRDeviceDZ700 && self.fileType != APKDVRFileTypePhoto){
            
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3/*延迟执行时间*/ * NSEC_PER_SEC));
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                
                if (self.tableView.indexPathsForSelectedRows.count > 1)
                    self.downloadButton.enabled = NO;
            });
        }
    }
}

- (void)requestDVRFileList{
    
    MBProgressHUD *hud = nil;
    
    if (self.refreshControl.isRefreshing) {
        
        [self.dataSource removeAllObjects];
        [self.tableView reloadData];
        
        [self updateTitleWithFileCount:0];
        [self updateButtonsEnableState];
    }
    else{
        
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    __weak typeof(self)weakSelf = self;
    [APKGetDVRFiles getDVRFilesWithType:self.fileType success:^(NSArray *fileArray) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (fileArray.count > 0) {
                [weakSelf.dataSource setArray:fileArray];
                [weakSelf.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                [weakSelf updateTitleWithFileCount:weakSelf.dataSource.count];
            }
            
            if (weakSelf.refreshControl.isRefreshing)
                [weakSelf.refreshControl endRefreshing];
            if (hud)
                [hud hide:YES];
        });
        
    } failure:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (weakSelf.refreshControl.isRefreshing)
                [weakSelf.refreshControl endRefreshing];
            if (hud)
                [hud hide:YES];
        });
    }];
}

- (UIImage*) getVideoPreViewImage:(NSURL *)path
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.dataSource.count == 0 ? 0 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    APKFileCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    APKDVRFile *file = self.dataSource[indexPath.row];
    cell.label.text = file.name;
    cell.downloadedMark.hidden = !file.isDownloaded;
    [cell.imagev setImageWithURL:file.thumbnailUrl placeholderImage:nil];

    cell.delegate = self;
    return cell;
}


#pragma mark - UITableViewDelegate

//解决编辑模式下cellEditingStyle错乱的问题
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    //编辑模式下，返回多选模式
    if (tableView.isEditing) {
        return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.isEditing){
        
        [self updateButtonsEnableState];
        
        if ([APKDVR sharedInstance].deviceNumber == APKDVRDeviceDZ700 && self.fileType != APKDVRFileTypePhoto) {
          
            if (_lastIndexPath) {
                [tableView deselectRowAtIndexPath:_lastIndexPath animated:YES];
            }
            self.lastIndexPath = indexPath;
        }
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.fileType == APKDVRFileTypePhoto) {
        
        for (APKDVRFile *file in self.dataSource) {
            
            MWPhoto *photo = [MWPhoto photoWithURL:file.url];
            [self.photos addObject:photo];
        }
        
        MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        photoBrowser.enableGrid = NO;
        photoBrowser.displayActionButton = NO;
        photoBrowser.alwaysShowControls = YES;
        [photoBrowser setCurrentPhotoIndex:indexPath.row];
        
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:photoBrowser];
        nc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:nc animated:YES completion:nil];
    }
    else{
    
//        [self performSegueWithIdentifier:@"playback" sender:indexPath];
        APKDVRFile *file = self.dataSource[indexPath.row];
        
        if (file.isHDRFile == YES || [file.name containsString:@"FILEE"]){
            [APKAlertTool showAlertInViewController:self title:nil message:NSLocalizedString(@"文件码流过大，请下载到本地播放", nil) confirmHandler:^(UIAlertAction *action) {
                nil;
            }];
        }
        else{
            [self performSegueWithIdentifier:@"playback" sender:indexPath];
//            UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//                  UIViewController *specificationVC = [mainSB instantiateViewControllerWithIdentifier:@"playBackVC"];
//                  specificationVC.modalPresentationStyle = UIModalPresentationFullScreen;
//                  [self presentViewController:specificationVC animated:NO completion:^{
//                      nil;
//                  }];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (tableView.isEditing) {
        
        if ([APKDVR sharedInstance].deviceNumber == APKDVRDeviceDZ700 && self.fileType != APKDVRFileTypePhoto)
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        
        [self updateButtonsEnableState];
    }
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    
    return self.photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    
    if (index < self.photos.count)
        return [self.photos objectAtIndex:index];
    return nil;
}

#pragma mark - APKFileCellDelegate

- (void)didBeganLongPress:(APKFileCell *)cell{
    
    self.editing = YES;
}

- (void)didEndedLongPress:(APKFileCell *)cell{
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    _lastIndexPath = indexPath;
    
    [self updateButtonsEnableState];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.isScrolling = YES;
}

#pragma mark - event response

- (IBAction)clickDeleteButton:(UIButton *)sender {
    
    NSMutableArray *fileArray = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        
        APKDVRFile *file = self.dataSource[indexPath.row];
        [fileArray addObject:file];
    }
    self.editing = NO;
    
    NSString *message = NSLocalizedString(@"删除%d个文件？", nil);
//    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"删除%d个文件？", nil),(int)fileArray.count];
    [APKAlertTool showAlertInViewController:self title:nil message:message cancelHandler:nil confirmHandler:^(UIAlertAction *action) {
       
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
        
        __weak typeof(self)weakSelf = self;
        [self.batchDelete batchDeleteWithFileArray:fileArray progress:^(APKDVRFile *file, BOOL isDeleted) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (isDeleted) {
                    
                    NSInteger row = [weakSelf.dataSource indexOfObject:file];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                    
                    [weakSelf.dataSource removeObject:file];
                    if (weakSelf.dataSource.count > 0)
                        [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    else
                        [weakSelf.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                    
                    [weakSelf updateTitleWithFileCount:weakSelf.dataSource.count];
                }
            });
            
        } completionHandler:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [hud hide:YES];
            });
        }];
    }];
}

- (IBAction)clickDownloadButton:(UIButton *)sender {
    
    if (self.batchDownload.state != APKBatchDownloadStateFine) {
        
        if (self.batchDownload.state == APKBatchDownloadStateNotEnoughStorageSpace){
            
            [APKAlertTool showAlertInViewController:self title:nil message:NSLocalizedString(@"手机存储空间不足", nil) confirmHandler:nil];
        }
        else if (self.batchDownload.state == APKBatchDownloadStateNoPhotosAuthority){
            
            [self showGetPhotosAuthorityAlert];
        }
        
        self.editing = NO;
        
        return;
    }
    
    NSMutableArray *fileArray = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        
        APKDVRFile *file = self.dataSource[indexPath.row];
        if (!file.isDownloaded)
            [fileArray addObject:file];
    }
    self.editing = NO;
    if (fileArray.count == 0) {
        return;
    }
    
    if ([APKDVR sharedInstance].deviceNumber == APKDVRDeviceDZ700 && self.fileType != APKDVRFileTypePhoto){
        
        __weak typeof (self) weakSelf = self;
        [APKAlertTool showAlertInViewController:self title:nil message:NSLocalizedString(@"执行下载将停止录像", nil) cancelHandler:nil confirmHandler:^(UIAlertAction *action) {
            
            [[APKDVRCommandFactory createCommandWithMsgId:MSGID_AMBA_RECORD_STOP type:nil param:nil success:^(id obj) {
                
                [weakSelf beginDownloadTaskWithFiles:fileArray];
            } failure:^(int rval) {
                [weakSelf beginDownloadTaskWithFiles:fileArray];
            }]execute] ;
        }];
    }
    else
      [self beginDownloadTaskWithFiles:fileArray];
}

-(void)beginDownloadTaskWithFiles:(NSMutableArray *)fileArray
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        __weak typeof(self)weakSelf = self;
        APKDownloadInfoView *infoView = [APKDownloadInfoView showInView:self.view cancelHandler:^{
            
            [weakSelf.batchDownload cancel];
            [weakSelf startRecordMission];
        }];
        
        [self.batchDownload batchDownloadWithFileArray:fileArray globalProgress:^(NSString *info) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                infoView.downloadInfoLabel.text = info;
            });
            
        } progress:^(float progress, NSString *info) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                infoView.progressView.progress = progress;
                NSString *progressInfo = [NSString stringWithFormat:@"%.1f%%",progress * 100.f];
                infoView.progressLabel.text = progressInfo;
                infoView.progressLabel2.text = info;
            });
            
        } completionHandler:^(void){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].idleTimerDisabled = NO;
                [infoView dismiss];
                [weakSelf.tableView reloadData];
                
                if ([APKDVR sharedInstance].deviceNumber == APKDVRDeviceDZ700 && self.fileType != APKDVRFileTypePhoto)
                    [weakSelf startRecordMission];
            });
        }];
    });
}


-(void)startRecordMission
{
    [[APKDVRCommandFactory createCommandWithMsgId:MSGID_AMBA_RECORD_START type:nil param:nil success:^(id obj) {
    } failure:^(int rval) {
    }]execute] ;
}

- (IBAction)clickCheckAllButton:(UIButton *)sender {
    
    if (self.tableView.indexPathsForSelectedRows.count != self.dataSource.count) {
        
        for (NSInteger row = 0; row < self.dataSource.count; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        self.isCheckAll = YES;
    }
    else{
        
        [self.tableView reloadData];
        _lastIndexPath = nil;
        self.isCheckAll = NO;
    }
    [self updateButtonsEnableState];
}

- (IBAction)clickExitButton:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickCancelButton:(UIButton *)sender {
    
    self.editing = NO;
}

- (IBAction)clickFilterButton:(UIButton *)sender {
    
    
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"playback"]) {
    
        NSIndexPath *indexPath = sender;
        APKPlayBackViewController *vc = segue.destinationViewController;
        vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        vc.currentIndex = indexPath.row;
        [vc.dataSource setArray:self.dataSource];
    }
}

#pragma mark - setter

- (void)setEditing:(BOOL)editing{
    
    [super setEditing:editing];
    
    self.tableView.editing = editing;
    
    self.exitButton.hidden = editing;
//    self.filterButton.hidden = editing;
    self.cancelButton.hidden = !editing;
    self.checkAllButton.hidden = !editing;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = !editing;
    }
    
    APKTabBarController *tabBar = (APKTabBarController *)self.tabBarController;
    tabBar.hideCustomTabBar = editing;
    
    self.bottomBar.hidden = !editing;
    
    [self updateButtonsEnableState];
}

#pragma mark - getter

- (APKBatchDownload *)batchDownload{
    
    if (!_batchDownload) {
        
        _batchDownload = [[APKBatchDownload alloc] init];
    }
    return _batchDownload;
}

- (APKBatchDelete *)batchDelete{
    
    if (!_batchDelete) {
        
        _batchDelete = [[APKBatchDelete alloc] init];
    }
    return _batchDelete;
}

- (UIRefreshControl *)refreshControl{
    
    if (!_refreshControl) {
        
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(requestDVRFileList) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

- (NSMutableArray *)photos{
    
    if (!_photos) {
        
        _photos = [[NSMutableArray alloc] init];
    }
    return _photos;
}

- (NSMutableArray *)dataSource{
    
    if (!_dataSource) {
        
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

@end
