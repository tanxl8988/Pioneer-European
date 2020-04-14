//
//  APKDVRSocketDataHandler.m
//  Pioneer
//
//  Created by Mac on 17/9/15.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKDVRMessageDataHandler.h"

@interface APKDVRMessageDataHandler ()

@property (strong,nonatomic) NSMutableData *store;

@end

@implementation APKDVRMessageDataHandler

#pragma mark - private method

- (nullable NSDictionary *)serializeTheJsonData:(NSData *)data{
    
    NSError *error;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (!jsonDictionary || error) {
        
        return nil;
    }
    
    return jsonDictionary;
}

//粘包处理
- (void)segmentStickPackageWithString:(NSString *)str completionHandler:(void (^)(NSDictionary *))completionHandler{
    
    NSArray *arr = [str componentsSeparatedByString:@"}{"];
    NSUInteger lastIndex = arr.count - 1;
    for (NSUInteger i = 0; i < arr.count; i++) {
        
        NSString *info = nil;
        if (i == 0) {
            info = [arr[i] stringByAppendingString:@"}"];
        }else if (i == lastIndex){
            info = [@"{" stringByAppendingString:arr[i]];
        }else{
            info = [@"{" stringByAppendingString:arr[i]];
            info = [info stringByAppendingString:@"}"];
        }
        
        NSData *data = [info dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonData = [self serializeTheJsonData:data];
        if (jsonData) {
            completionHandler(jsonData);
        }
        else if (i == lastIndex){
            self.store = nil;
            [self.store appendData:data];
        }
    }
}

- (void)handleErrorJsonData:(NSData *)data completionHandler:(void (^)(NSDictionary *))completionHandler{
    
    [self.store appendData:data];
    
    NSString *str = [[NSString alloc] initWithData:self.store encoding:NSUTF8StringEncoding];
    if ([str containsString:@"}{"]) {
        [self segmentStickPackageWithString:str completionHandler:completionHandler];
    }
    else if(self.store.length != data.length){
        
        NSDictionary *jsonData = [self serializeTheJsonData:self.store];
        if (jsonData) {
            self.store = nil;
            completionHandler(jsonData);
        }
    }
}

#pragma mark - public method

- (void)resetBuf{

    self.store = nil;
}

- (void)handleData:(NSData *)data completionHandler:(void (^)(NSDictionary *))completionHandler{
    
    if (data == nil || data.length == 0)
        return;
    
    NSDictionary *jsonData = [self serializeTheJsonData:data];
    if (jsonData) {
        
        completionHandler(jsonData);//解析成功
    }
    else{
        
        [self handleErrorJsonData:data completionHandler:completionHandler];
    }
}

#pragma mark - getter

- (NSMutableData *)store{
    
    if (!_store) {
        
        _store = [[NSMutableData alloc] init];
    }
    return _store;
}

@end
