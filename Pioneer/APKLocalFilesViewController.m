//
//  APKLocalFilesViewController.m
//  Pioneer
//
//  Created by Mac on 17/9/13.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKLocalFilesViewController.h"
#import "APKTabBarController.h"
#import "APKFileCell.h"
#import <CoreData/CoreData.h>
#import "APKCoreDataStack.h"
#import "APKLocalFile.h"
#import "APKCachingAssetThumbnail.h"
#import "APKLoadShareItems.h"
#import "MBProgressHUD.h"
#import "MWPhotoBrowser.h"
#import "APKMWPhoto.h"
#import "APKPlayBackViewController.h"

static NSString *cellIdentifier = @"fileCell";

@interface APKLocalFilesViewController ()<UITableViewDataSource,UITableViewDelegate,APKFileCellDelegate,NSFetchedResultsControllerDelegate,MWPhotoBrowserDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
@property (weak, nonatomic) IBOutlet UIButton *checkAllButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBarHeightConstraint;
@property (strong,nonatomic) NSManagedObjectContext *context;
@property (strong,nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong,nonatomic) APKCachingAssetThumbnail *cachingThumbnail;
@property (strong,nonatomic) NSMutableArray *photos;

@end

@implementation APKLocalFilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.editing = NO;
    self.tableView.rowHeight = 90;
    
    APKTabBarController *tabBar = (APKTabBarController *)self.tabBarController;
    self.tableViewBottomConstraint.constant = tabBar.tabBarHeight;
    self.bottomBarHeightConstraint.constant = tabBar.tabBarHeight;

    [self updateTitleWithFileCount:0];
    
    self.filterButton.hidden = YES;
    [self.cancelButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
//    [self.checkAllButton setTitle:NSLocalizedString(@"全选", nil) forState:UIControlStateNormal];
    
    [self reuqestLocalFileList];
    
    NSString *isDark = [[NSUserDefaults standardUserDefaults] objectForKey:@"DARKMODE"];
    if ([isDark isEqualToString:@"YES"]) {
        self.view.backgroundColor = [UIColor blackColor];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    if (self.photos.count > 0) {
        
        [self.photos removeAllObjects];
    }
}

- (void)dealloc{
    
    NSLog(@"%s",__func__);
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

- (void)updateButtonsEnableState{
    
    NSInteger count = self.tableView.indexPathsForSelectedRows.count;
    if (count == 0) {
        
        self.deleteButton.enabled = NO;
        self.shareButton.enabled = NO;
    }
    else{
        
        self.deleteButton.enabled = YES;
        if (self.fileType == APKDVRFileTypePhoto) {
            self.shareButton.enabled = count <= 9 ? YES : NO;
        }
        else{
            self.shareButton.enabled = count == 1;
        }
    }
}

- (void)reuqestLocalFileList{
    
    NSError *error = nil;
    if ([self.fetchedResultsController performFetch:&error]) {
        
        [self.context performBlock:^{
            
            NSMutableArray *assets = [[NSMutableArray alloc] init];
            NSArray *arr = [self sortFileWithDate:self.fetchedResultsController.fetchedObjects];
            for (APKLocalFile *file in arr) {
                
                PHFetchResult *res = [PHAsset fetchAssetsWithLocalIdentifiers:@[file.localIdentifier] options:nil];
                if (res.count == 0) {
                    [self.context deleteObject:file];/*删除坏视频*/
                }
                else{
                    PHAsset *asset = res.firstObject;
                    file.asset = asset;
                    [assets addObject:asset];
                }
            }
            
            NSError *error = nil;
            [self.context save:&error];
            
            NSManagedObjectContext *mainContext = self.context.parentContext;
            [mainContext performBlockAndWait:^{
                
                NSError *error = nil;
                [mainContext save:&error];
                
                [self.cachingThumbnail cachingThumbnailForAssets:assets];//预缓存图片
                
                [self updateTitleWithFileCount:assets.count];
                
                APKFileCell *cell = self.tableView.visibleCells.firstObject;
                if (!cell.imagev.image) {
                    [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }];
        }];
    }
}

-(NSArray *)sortFileWithDate:(NSArray *)fileArr
{
    if (fileArr.count < 2) return fileArr;
        
    
    NSArray *sortArr = [fileArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        APKDVRFile *file1 = obj1;
        APKDVRFile *file2 = obj2;
        return [file2.date compare:file1.date];
    }];
    
    return sortArr;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.fetchedResultsController.sections[section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    APKFileCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    APKLocalFile *file = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.label.text = file.name;
    if (file.asset) {
        
        [self.cachingThumbnail requestThumbnailForAsset:file.asset completionHandler:^(UIImage *thumbnail) {
            
            cell.imagev.image = thumbnail;
        }];
    }
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
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.fileType == APKDVRFileTypePhoto) {
        
        for (APKLocalFile *file in self.fetchedResultsController.fetchedObjects) {
            
            APKMWPhoto *photo = [APKMWPhoto photoWithAsset:file.asset targetSize:CGSizeMake(file.asset.pixelWidth, file.asset.pixelHeight)];
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
        
        [self performSegueWithIdentifier:@"playback" sender:indexPath];
//        UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//                      UIViewController *specificationVC = [mainSB instantiateViewControllerWithIdentifier:@"playBackVC"];
//                      specificationVC.modalPresentationStyle = UIModalPresentationFullScreen;
//                      [self presentViewController:specificationVC animated:NO completion:^{
//                          nil;
//                      }];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.isEditing) {
        
        [self updateButtonsEnableState];
    }
}

#pragma mark - APKFileCellDelegate

- (void)didBeganLongPress:(APKFileCell *)cell{
    
    self.editing = YES;
}

- (void)didEndedLongPress:(APKFileCell *)cell{
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    [self updateButtonsEnableState];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        switch (type) {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeUpdate:
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeMove:
                
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            default:
                break;
        }
    });
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        switch (type) {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeUpdate:
            case NSFetchedResultsChangeMove:
                break;
            default:
                break;
        }
    });
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView beginUpdates];
    });
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView endUpdates];
    });
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

#pragma mark - event response

- (IBAction)clickDeleteButton:(UIButton *)sender {
    
    NSMutableArray *fileArray = [[NSMutableArray alloc] init];
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        
        APKLocalFile *file = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [fileArray addObject:file];
        [assets addObject:file.asset];
    }
    self.editing = NO;
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        [PHAssetChangeRequest deleteAssets:assets];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        if (success) {
            
            [self.context performBlock:^{
               
                for (APKLocalFile *file in fileArray)
                    [self.context deleteObject:file];
                
                NSError *error = nil;
                [self.context save:&error];
                
                NSManagedObjectContext *mainContext = self.context.parentContext;
                [mainContext performBlockAndWait:^{
                    
                    NSError *error = nil;
                    [mainContext save:&error];
                    
                    [self updateTitleWithFileCount:self.fetchedResultsController.fetchedObjects.count];
                }];
            }];
        }
    }];
}

- (IBAction)clickShareButton:(UIButton *)sender {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self)weakSelf = self;
    APKLoadShareItemsCompletionHandler completionHandler = ^(BOOL success, NSArray *items){
        
        [hud hide:YES];
        if (success) {
            UIActivityViewController *avc = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
            avc.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeAddToReadingList,UIActivityTypePostToTencentWeibo];
            [weakSelf presentViewController:avc animated:YES completion:nil];
        }
    };

    if (self.fileType == APKDVRFileTypePhoto) {
        
        NSMutableArray *assets = [[NSMutableArray alloc] init];
        for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
            APKLocalFile *file = [self.fetchedResultsController objectAtIndexPath:indexPath];
            [assets addObject:file.asset];
        }
        [APKLoadShareItems loadShareItemsWithLocalPhotoAssets:assets completionHandler:completionHandler];
    }
    else{
        
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        APKLocalFile *file = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [APKLoadShareItems loadShareItemsWithLocalVideoAsset:file.asset completionHandler:completionHandler];
    }
    
    self.editing = NO;
}

- (IBAction)clickCheckAllButton:(UIButton *)sender {
    
    if (self.tableView.indexPathsForSelectedRows.count != self.fetchedResultsController.fetchedObjects.count) {
        
        for (NSInteger row = 0; row < self.fetchedResultsController.fetchedObjects.count; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    else{
        
        [self.tableView reloadData];
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
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        vc.currentIndex = indexPath.row;
        [vc.dataSource setArray:self.fetchedResultsController.fetchedObjects];
    }
}

#pragma mark - getter

- (NSMutableArray *)photos{
    
    if (!_photos) {
        
        _photos = [[NSMutableArray alloc] init];
    }
    return _photos;
}

- (APKCachingAssetThumbnail *)cachingThumbnail{
    
    if (!_cachingThumbnail) {
        
        CGFloat standardBorderWidth = 20;
        CGFloat height = self.tableView.rowHeight - standardBorderWidth * 2;
        CGFloat width = height / 9.f * 16.f;
        CGSize size = CGSizeMake(width, height);
        _cachingThumbnail = [[APKCachingAssetThumbnail alloc] initWithSize:size contentMode:PHImageContentModeAspectFill options:nil];
    }
    return _cachingThumbnail;
}

- (NSFetchedResultsController *)fetchedResultsController{//coredata控制器
    
    if (!_fetchedResultsController) {
        
        NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %d",self.fileType];
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"APKLocalFile"];
        request.sortDescriptors = @[dateSort];
        request.predicate = predicate;
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}

- (NSManagedObjectContext *)context{
    
    if (!_context) {
        
        _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_context setParentContext:[APKCoreDataStack sharedInstance].context];
    }
    return _context;
}

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


@end
