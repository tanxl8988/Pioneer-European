//
//  APKDVR.m
//  Pioneer
//
//  Created by Mac on 17/9/15.
//  Copyright © 2017年 APK. All rights reserved.


#import "APKDVR.h"
#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "APKDVRMessageDataHandler.h"
#import "APKDVRCommandFactory.h"
#import "APKDVRInterface.h"
#import "APKInitializeConnect.h"
#import "APKAlertTool.h"
#import "APKWifiTool.h"

#define DISCONNECT_TAG 404

@interface APKDVR ()<GCDAsyncSocketDelegate>

@property (strong,nonatomic) GCDAsyncSocket *socket;
@property (strong,nonatomic) APKInitializeConnect *initializeConnect;
@property (assign,nonatomic) NSInteger numberOfConnectTimes;
@property (strong,nonatomic) APKDVRMessageDataHandler *messageDataHandler;
@property (strong,nonatomic) NSMutableArray *commandQueue;
@property (strong,nonatomic) dispatch_queue_t updateCommandQueue;
@property (strong,nonatomic) dispatch_queue_t delegateQueue;
@property (strong,nonatomic) dispatch_source_t heartBeatTimer;

@end

@implementation APKDVR

#pragma mark - life circle

- (instancetype)init{
    
    if (self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationState:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationState:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
    }
    return self;
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark - private method

- (void)destroyAllCommands{
    
    dispatch_async(self.updateCommandQueue, ^{
       
        for (APKDVRCommand *commnad in self.commandQueue) {
            
            commnad.failureHandler(AMBA_ERROR_UNKNOWN_ERROR);
        }
        [self.commandQueue removeAllObjects];
    });
}



- (void)handleApplicationState:(NSNotification *)notification{
    
    if ([notification.name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
        
        if (self.connectState == APKDVRConnectStateDisconnected) {
            
            NSString *aitWifiAddress = @"192.168.42.1";
            NSString *wifiAddress = [APKWifiTool getWifiAddress];
            if (![aitWifiAddress isEqualToString:wifiAddress]) return;
            
            self.connectState = APKDVRConnectStateConnecting;
            self.numberOfConnectTimes = 0;
            [self connect];

        }
        
    }else if([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]){
        
        if (self.connectState == APKDVRConnectStateConnected) {

            self.connectState = APKDVRConnectStateDisconnecting;
            [self disConnect];
        }
        exit(0);
//        self.connectState = APKDVRConnectStateDisconnected;
//        [self.socket disconnect];
    }
}

#pragma mark - public method

- (void)executeCommand:(APKDVRCommand *)command{
    
    dispatch_async(self.updateCommandQueue, ^{
       
        NSString *cmdStr = [[NSString alloc] initWithData:command.commandData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",cmdStr);
        
        //心跳命令直接发送，不做任何额外处理
        if (command.commandId == APK_AMBA_HEART_NOTIFY) {
            
            [self.socket writeData:command.commandData withTimeout:-1 tag:0];
            return;
        }

        //不允许发送命令队列中已有的命令
        for (APKDVRCommand *cmd in self.commandQueue) {
            
            if (cmd.commandId == command.commandId) {
                
                command.failureHandler(APK_ERROR_DVR_BUSY);
                return;
            }
        }
        [self.commandQueue addObject:command];//queue添加命令
        
        //发送命令
        [self.socket writeData:command.commandData withTimeout:-1 tag:0];
        
        //超时机制。如果在timeout时间内，该command还没有被销毁，则自动销毁该command
        __weak APKDVRCommand *weakCommand = command;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(command.timeout * NSEC_PER_SEC)), self.updateCommandQueue, ^{
            
            if (weakCommand){
                
                for (APKDVRCommand *cmd in self.commandQueue) {
                    
                    if (cmd.commandId == weakCommand.commandId) {
                        
                        if (cmd.commandId == APK_AMBA_GET_FILE_LIST)
                            [self.messageDataHandler resetBuf];
                        
                        weakCommand.failureHandler(APK_ERROR_TIME_OUT);
                        [self.commandQueue removeObject:weakCommand];
                        break;
                    }
                }
            }
        });
    });
}

- (void)disConnect{
    //发送断开连接指令
    APKDVRCommand *command = [APKDVRCommandFactory stopSessionCommandWithSuccess:nil failure:nil];
    [self.socket writeData:command.commandData withTimeout:-1 tag:DISCONNECT_TAG];
    
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    
    if (tag == DISCONNECT_TAG) {
        
        NSLog(@"已发送断开命令。");
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), self.delegateQueue, ^{//延时一秒断开
            
            [self.socket disconnect];
        });
    }
}


- (void)connect{
    
    self.numberOfConnectTimes += 1;
    
    NSString *host = @"192.168.42.1";
    uint16_t port = 7878;
    NSError *error = nil;
    [self.socket connectToHost:host onPort:port error:&error];
//    if (![self.socket connectToHost:host onPort:port error:&error]) {//连接失败
//
//        if (self.numberOfConnectTimes < 3) {
//
//            [self connect];
//        }
//        else{
//
//            self.connectState = APKDVRConnectStateDisconnected;
//        }
//    }
}

static APKDVR *instance = nil;
+ (instancetype)sharedInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[APKDVR alloc] init];
    });
    
    return instance;
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    
    NSLog(@"%s%@",__func__,err.localizedDescription);
    
    if (self.connectState == APKDVRConnectStateConnecting && self.numberOfConnectTimes < 3) {//三次重连
        
        [self connect];
        NSLog(@"=======第%ld次重连=======",self.numberOfConnectTimes);
    }
    else{
        
        self.connectState = APKDVRConnectStateDisconnected;
    }
    self.connectState = APKDVRConnectStateDisconnected;

}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{

    [sock readDataWithTimeout:-1 tag:0];
    
    __weak typeof(self)weakSelf = self;
    [self.initializeConnect initializeConnect:^(BOOL success) {
        
        [[APKDVRCommandFactory getDeviceInfoCommandWithSuccess:^(id obj) {
            
            NSDictionary *dict = obj;
            if ([dict[@"brand"] containsString:@"700"])
                weakSelf.deviceNumber = APKDVRDeviceDZ700;
            else if ([dict[@"brand"] containsString:@"600"])
                weakSelf.deviceNumber = APKDVRDeviceDZ600;
            else
                weakSelf.deviceNumber = APKDVRDeviceDZ500;
            
            [[APKDVRCommandFactory getSettingInfoCommandWithSuccess:^(id obj) {
                
                NSArray *dictArr = obj[@"param"];
                NSDictionary *dict = dictArr[0];
                NSString *cameraStr = dict[@"Apk_streamSrc"];
                weakSelf.isRearCamera = [cameraStr isEqualToString:@"Apk_vin0"] ? YES : NO;
                weakSelf.connectState = APKDVRConnectStateConnected;
                weakSelf.numberOfConnectTimes = 0;
                weakSelf.deviceWIfiIsClose = NO;
            } failure:^(int rval) {
            }]execute];
            
        } failure:^(int rval) {
        }]execute];
       
//        if (!success || success)
//            weakSelf.connectState = APKDVRConnectStateConnected;
//        else
//            [weakSelf disConnect];
    }];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    [sock readDataWithTimeout:-1 tag:0];

    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",msg);
    __weak typeof(self)weakSelf = self;
    [self.messageDataHandler handleData:data completionHandler:^(NSDictionary *message) {
        
        [weakSelf handleDVRMessage:message];
    }];
}

- (void)handleDVRMessage:(NSDictionary *)message{
    
    dispatch_async(self.updateCommandQueue, ^{
        
        NSInteger cmdId = [message[AMBAKeyMSGID] integerValue];
        
        NSLog(@"==========%ld===========",cmdId);
        
        //暂不处理广播和心跳命令
        if (cmdId == MSGID_AMBA_NOTIFICATION || cmdId == APK_AMBA_HEART_NOTIFY) {
            
            return;
        }
        
        if (cmdId == MSGID_AMBA_QUERY_SESSION_HOLDER) {
            
            [self exitApp];
//            return;
        }
        
        if (cmdId == 134217756) {
            
            self.deviceWIfiIsClose = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DEVICEWIFIISCLOSE" object:nil];
            return;
        }
        
        APKDVRCommand *command = nil;
        for (APKDVRCommand *cmd in self.commandQueue) {
            
            if (cmd.commandId == cmdId) {
                
                command = cmd;
                break;
            }
        }
        
        if (command) {
            
            int rval = [message[AMBAKeyReturnValue] intValue];
            if (rval == 0) {
                
                id obj = [command.resultHandler handleResult:message];
                command.successHandler(obj);
            }
            else{
                
                command.failureHandler(rval);
            }
            
            [self.commandQueue removeObject:command];
        }
    });
}


//退出app
-(void)exitApp
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimer *timer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(exitApplication) userInfo:nil repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];//解决定时器不工作
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"两台同时连接提示", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        __weak typeof (self) weakSelf = self;
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [weakSelf exitApplication];
            
        }];
        [alert addAction:okAction];
        [[self currentViewController] presentViewController:alert animated:YES completion:nil];
    });
}


- (void)exitApplication {

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [UIView animateWithDuration:2.0f animations:^{
        window.alpha = 0;
        window.frame = CGRectMake(0, window.bounds.size.width, 0, 0);
    } completion:^(BOOL finished) {
        exit(0);
    }];
    
}

//获取Window当前显示的ViewController
- (UIViewController*)currentViewController{
    //获得当前活动窗口的根视图
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1)
    {
        //根据不同的页面切换方式，逐步取得最上层的viewController
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
}


#pragma mark - setter

- (void)setConnectState:(APKDVRConnectState)connectState{
    
    if (_connectState == connectState)
        return;
    
    _connectState = connectState;
    
    if (connectState == APKDVRConnectStateDisconnected) {
        
        if (self.commandQueue.count > 0)
            [self destroyAllCommands];
        
        //停止发送心跳
        dispatch_suspend(self.heartBeatTimer);
    }
    else if (connectState == APKDVRConnectStateConnected){
        
        //开始发送心跳
        dispatch_resume(self.heartBeatTimer);
    }
}

#pragma mark - getter

- (dispatch_source_t)heartBeatTimer{
    
    if (_heartBeatTimer == nil) {
        
        //5秒定时器发送心跳包
        _heartBeatTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.updateCommandQueue);
        dispatch_source_set_timer(_heartBeatTimer, DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(_heartBeatTimer, ^{
            
            APKDVRCommand *cmd = [APKDVRCommandFactory sendHeartBeatCommandWithSuccess:^(id obj) {
            } failure:^(int rval) {
            }];
            [self executeCommand:cmd];
        });
    }
    return _heartBeatTimer;
}

- (APKInitializeConnect *)initializeConnect{
    
    if (!_initializeConnect) {
        
        _initializeConnect = [[APKInitializeConnect alloc] init];
    }
    return _initializeConnect;
}


- (dispatch_queue_t)delegateQueue{//socketQueue
    
    if (!_delegateQueue) {
        
        _delegateQueue = dispatch_queue_create("com.apical.socket", DISPATCH_QUEUE_SERIAL);
    }
    return _delegateQueue;
}

- (dispatch_queue_t)updateCommandQueue{
    
    if (!_updateCommandQueue) {//更新操作命令queue
        
        _updateCommandQueue = dispatch_queue_create("com.apical.updateCommandQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _updateCommandQueue;
}

- (NSMutableArray *)commandQueue{
    
    if (!_commandQueue) {
        
        _commandQueue = [[NSMutableArray alloc] init];
    }
    return _commandQueue;
}

- (APKDVRMessageDataHandler *)messageDataHandler{
    
    if (!_messageDataHandler) {
        
        _messageDataHandler = [[APKDVRMessageDataHandler alloc] init];
    }
    return _messageDataHandler;
}

- (GCDAsyncSocket *)socket{
    
    if (!_socket) {
        
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.delegateQueue];
    }
    return _socket;
}

@end
