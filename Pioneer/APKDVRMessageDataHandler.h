//
//  APKDVRSocketDataHandler.h
//  Pioneer
//
//  Created by Mac on 17/9/15.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APKDVRMessageDataHandler : NSObject

- (void)resetBuf;
- (void)handleData:(NSData *)data completionHandler:(void (^)(NSDictionary *message))completionHandler;

@end
