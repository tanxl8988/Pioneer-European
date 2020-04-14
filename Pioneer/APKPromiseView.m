//
//  APKPromiseView.m
//  Pioneer
//
//  Created by apical on 2019/6/20.
//  Copyright © 2019年 APK. All rights reserved.
//

#import "APKPromiseView.h"

@implementation APKPromiseView
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib{
    
    [super awakeFromNib];
    
    [self.refuseButton setTitle:NSLocalizedString(@"不同意", nil) forState:UIControlStateNormal];
    [self.sureButton setTitle:NSLocalizedString(@"同意", nil) forState:UIControlStateNormal];
    [self.setSureButton setTitle:NSLocalizedString(@"同意", nil) forState:UIControlStateNormal];
    [self setButtonsEnable:NO];
    
    //初始化myWebView
    NSURL *filePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"使用許諾書_Drive_Record_Interface_正式版 2" ofType:@"docx"]];
    NSURLRequest *request = [NSURLRequest requestWithURL: filePath];
    [self.webView loadRequest:request];
    //使文档的显示范围适合UIWebView的bounds
    [self.webView setScalesPageToFit:YES];
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    
    
//    NSString*jSString = [NSString stringWithFormat:@"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content','width=device-width','user-scalable=no'); document.getElementsByTagName('head')[0].appendChild(meta);"];
//    WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
//    WKUserContentController* userContent = [[WKUserContentController alloc]init];
//    [userContent addUserScript:wkUserScript];
//    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
//
//    wkWebConfig.userContentController= userContent;
//    self.wkWebView = [[WKWebView alloc] initWithFrame:self.webView.bounds configuration:wkWebConfig];
//    NSURL *filePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"使用許諾書_Drive_Record_Interface_正式版 2" ofType:@"docx"]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:filePath];
//    [self.wkWebView loadRequest:request];
//    self.wkWebView.frame = self.webView.frame;
//    self.wkWebView.center = self.center;
//    self.wkWebView.scrollView.delegate = self;
//    [self.wkWebView sizeToFit];
//    [self addSubview:self.wkWebView];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"页面加载完成");
}

-(void)setButtonsEnable:(BOOL)enable
{
    if (enable == YES) {
        self.refuseButton.backgroundColor = [UIColor colorWithRed:183/255.f green:23/255.f blue:66/255.f alpha:1];
        self.refuseButton.enabled = YES;
        
        self.sureButton.backgroundColor = [UIColor colorWithRed:183/255.f green:23/255.f blue:66/255.f alpha:1];
        self.sureButton.enabled = YES;
        
        self.setSureButton.backgroundColor = [UIColor colorWithRed:183/255.f green:23/255.f blue:66/255.f alpha:1];
        self.setSureButton.enabled = YES;
    }else{
        
        self.sureButton.backgroundColor = [UIColor grayColor];
        self.sureButton.enabled = NO;
        
        self.setSureButton.backgroundColor = [UIColor grayColor];
        self.setSureButton.enabled = NO;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSInteger height = scrollView.contentSize.height - scrollView.contentOffset.y;
    if (height == (int)scrollView.frame.size.height-2)
        [self setButtonsEnable:YES];
}


- (IBAction)refuseButtonClicked:(UIButton *)sender {
    
    self.clickActionButton(100);
}

- (IBAction)sureButtonClicked:(UIButton *)sender {
    self.clickActionButton(101);
    [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"promiseValue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



@end
