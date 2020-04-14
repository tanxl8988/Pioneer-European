//
//  APKPreviewViewController.h
//  Pioneer
//
//  Created by Mac on 17/9/12.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKBaseViewController.h"

@interface APKLiveStateMathine : NSObject

@property (assign,nonatomic) BOOL isShouldLive;
@property (assign,nonatomic) BOOL isAPPInBackground;
@property (assign,nonatomic) BOOL isConnectedDVR;
@property (assign,nonatomic) BOOL isInPreviewPage;

@end

@interface APKPreviewViewController : APKBaseViewController
@property (nonatomic,assign) BOOL isRecordEvent;

@end
