//
//  APKTabBarController.m
//  Pioneer
//
//  Created by Mac on 17/9/12.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKTabBarController.h"

@interface APKTabBarController ()<APKTabBarDelegate>

@property (nonatomic) CGRect tabBarFrame;
@property (strong,nonatomic) NSArray *tabBarItems;


@end

@implementation APKTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tabBarHeight = 70;
    
    self.hideCustomTabBar = NO;
    
    APKTabBarItem *item1 = [[APKTabBarItem alloc] init];
    item1.imageName = @"preview",item1.imageName_p = @"preview_p";
    APKTabBarItem *item2 = [[APKTabBarItem alloc] init];
    item2.imageName = @"list",item2.imageName_p = @"list_p";
    APKTabBarItem *item3 = [[APKTabBarItem alloc] init];
    item3.imageName = @"setting",item3.imageName_p = @"setting_p";
    
    self.customTabBar.delegate = self;
    [self.customTabBar setupWithItems:@[item1,item2,item3]];
    self.customTabBar.selectedIndex = 0;
    
    BOOL isDark = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark);
    if (isDark) {
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"DARKMODE"];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"DARKMODE"];
    }
    
    if (isDark) {
        self.customTabBar.backgroundColor = [UIColor blackColor];
        self.customTabBar.tintColor = [UIColor blackColor];
    }
    
    [self.view addSubview:self.customTabBar];
}

#pragma mark - APKTabBarDelegate

- (void)APKTabBar:(APKTabBar *)tabBar didSelectedItemWithIndex:(NSInteger)index{
    
    self.selectedIndex = index;
}

#pragma mark - setter

- (void)setHideCustomTabBar:(BOOL)hideCustomTabBar{
    
    _hideCustomTabBar = hideCustomTabBar;
    
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    CGRect frame;
    frame.size = CGSizeMake(screenWidth, self.tabBarHeight);
    if (_hideCustomTabBar) {
        frame.origin = CGPointMake(0, screenHeight);
    }
    else{
        frame.origin = CGPointMake(0, screenHeight - self.tabBarHeight);
    }
    self.customTabBar.frame = frame;
}

#pragma mark - getter

- (NSArray *)tabBarItems{
    
    APKTabBarItem *item1 = [[APKTabBarItem alloc] init];
    item1.imageName = @"preview",item1.imageName_p = @"preview_p";
    APKTabBarItem *item2 = [[APKTabBarItem alloc] init];
    item2.imageName = @"list",item2.imageName_p = @"list_p";
    APKTabBarItem *item3 = [[APKTabBarItem alloc] init];
    item3.imageName = @"setting",item3.imageName_p = @"setting_p";
    return @[item1,item2,item3];
}

- (CGRect)tabBarFrame{
    
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    CGRect frame = CGRectMake(0, screenHeight - self.tabBarHeight, screenWidth, self.tabBarHeight);
    return frame;
}

- (APKTabBar *)customTabBar{
    
    if (!_customTabBar) {
        
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"APKTabBar" owner:nil options:nil];
        for (id obj in arr) {
            if ([obj isKindOfClass:[APKTabBar class]]) {
                
                _customTabBar = obj;
                break;
            }
        }
    }
    return _customTabBar;
}

@end
