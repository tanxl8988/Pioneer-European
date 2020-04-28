//
//  APKPromiseView.h
//  Pioneer
//
//  Created by apical on 2019/6/20.
//  Copyright © 2019年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface APKPromiseView : UIView<UIScrollViewDelegate,WKNavigationDelegate>
@property (weak, nonatomic) IBOutlet UIButton *refuseButton;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;
@property (nonatomic,copy) void(^clickActionButton)(NSInteger tag);
@property (weak, nonatomic) IBOutlet UIButton *setSureButton;
@property (nonatomic,retain) WKWebView *wkWebView;
@property (nonatomic,assign) BOOL isEULA;

-(void)setUpWebView;
@end

NS_ASSUME_NONNULL_END
