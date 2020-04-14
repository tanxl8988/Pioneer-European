//
//  APKDVRCommandResultHandler.h
//  Pioneer
//
//  Created by Mac on 17/9/18.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APKDVRInterface.h"

@interface APKDVRCommandResultHandler : NSObject

- (id)handleResult:(NSDictionary *)result;

@end
