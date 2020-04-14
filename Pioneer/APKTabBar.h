//
//  APKTabBar.h
//  Pioneer
//
//  Created by Mac on 17/9/12.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APKTabBarItem : NSObject

@property (strong,nonatomic) NSString *imageName;
@property (strong,nonatomic) NSString *imageName_p;

@end

@class APKTabBar;

@protocol APKTabBarDelegate <NSObject>

- (void)APKTabBar:(APKTabBar *)tabBar didSelectedItemWithIndex:(NSInteger)index;

@end

@interface APKTabBar : UIView

@property (weak,nonatomic) id<APKTabBarDelegate> delegate;
@property (nonatomic) NSInteger selectedIndex;

- (void)setupWithItems:(NSArray<APKTabBarItem *> *)items;

@end
