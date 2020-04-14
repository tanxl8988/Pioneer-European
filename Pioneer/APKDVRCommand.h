//
//  APKDVRCommand.h
//  Pioneer
//
//  Created by Mac on 17/9/18.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APKDVRCommandResultHandler.h"

typedef void(^APKDVRCommandSuccessHandler)(id obj);
typedef void(^APKDVRCommandFailureHandler)(int rval);

@interface APKDVRCommand : NSObject

@property (strong,nonatomic) NSData *commandData;
@property (nonatomic) NSInteger commandId;
@property (nonatomic) NSInteger timeout;
@property (strong,nonatomic) APKDVRCommandResultHandler *resultHandler;
@property (copy,nonatomic) APKDVRCommandSuccessHandler successHandler;
@property (copy,nonatomic) APKDVRCommandFailureHandler failureHandler;

- (void)execute;

@end
