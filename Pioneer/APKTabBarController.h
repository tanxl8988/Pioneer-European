//
//  APKTabBarController.h
//  Pioneer
//
//  Created by Mac on 17/9/12.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKBaseTabBarController.h"
#import "APKTabBar.h"

@interface APKTabBarController : APKBaseTabBarController

@property (assign,nonatomic) BOOL hideCustomTabBar;
@property (assign,nonatomic) CGFloat tabBarHeight;
@property (strong,nonatomic) APKTabBar *customTabBar;

@end
