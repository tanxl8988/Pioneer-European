//
//  APKPlayBackViewController.h
//  Pioneer
//
//  Created by Mac on 17/9/28.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKBaseViewController.h"
#import "APKVideoPlayerController.h"

@interface APKPlayBackViewController : APKBaseViewController

@property (strong,nonatomic) NSMutableArray *dataSource;
@property (nonatomic) NSInteger currentIndex;

@end
