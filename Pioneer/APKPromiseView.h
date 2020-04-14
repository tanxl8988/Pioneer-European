//
//  APKPromiseView.h
//  Pioneer
//
//  Created by apical on 2019/6/20.
//  Copyright © 2019年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface APKPromiseView : UIView<UIScrollViewDelegate,UIWebViewDelegate,QLPreviewControllerDataSource,WKNavigationDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *refuseButton;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;
@property (nonatomic,copy) void(^clickActionButton)(NSInteger tag);
@property (weak, nonatomic) IBOutlet UIButton *setSureButton;
@property (nonatomic,retain) WKWebView *wkWebView;
@end

NS_ASSUME_NONNULL_END
