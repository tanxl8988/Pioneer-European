//
//  APKTabBar.m
//  Pioneer
//
//  Created by Mac on 17/9/12.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKTabBar.h"
#import "APKTabBarCell.h"

@implementation APKTabBarItem


@end

static NSString *cellIdentifier = @"tabBarCell";

@interface APKTabBar ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;
@property (strong,nonatomic) NSMutableArray *dataSource;

@end

@implementation APKTabBar

- (void)awakeFromNib{
    
    [super awakeFromNib];
    
    
    UINib *nib = [UINib nibWithNibName:@"APKTabBarCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:cellIdentifier];
    
    self.collectionView.scrollsToTop = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.collectionView.scrollEnabled = NO;//禁止滚动
}

#pragma mark - public method

- (void)setupWithItems:(NSArray<APKTabBarItem *> *)items{
    
    [self.dataSource setArray:items];
    
    CGFloat itemHeight = CGRectGetHeight(self.frame);
    CGFloat itemWidth = CGRectGetWidth(self.frame) / self.dataSource.count;
    self.layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    [self.collectionView reloadData];
}

- (void)setupWithImageNames:(NSArray *)imageNames{
    
    [self.dataSource setArray:imageNames];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    APKTabBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    APKTabBarItem *item = self.dataSource[indexPath.row];
    cell.imagev.image = [UIImage imageNamed:item.imageName];
    NSString *isDark = [[NSUserDefaults standardUserDefaults] objectForKey:@"DARKMODE"];
        if ([isDark isEqualToString:@"YES"]) {
            cell.backgroundColor = [UIColor blackColor];
        }
    cell.imagev.highlightedImage = [UIImage imageNamed:item.imageName_p];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    _selectedIndex = indexPath.row;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(APKTabBar:didSelectedItemWithIndex:)]) {
        
        [self.delegate APKTabBar:self didSelectedItemWithIndex:indexPath.row];
    }
}

#pragma mark - setter

- (void)setSelectedIndex:(NSInteger)selectedIndex{
    
    if (selectedIndex >= self.dataSource.count)
        return;
    
    _selectedIndex = selectedIndex;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:selectedIndex inSection:0];
    [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

#pragma mark - getter

- (NSMutableArray *)dataSource{
    
    if (!_dataSource) {
        
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

@end
