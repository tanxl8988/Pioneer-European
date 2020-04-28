//
//  APKPrecificationViewController.m
//  Pioneer
//
//  Created by tanxl on 2018/4/26.
//  Copyright © 2018年 APK. All rights reserved.
//

#import "APKPrecificationViewController.h"
#import <WebKit/WebKit.h>

@interface APKPrecificationViewController ()

@property (nonatomic,retain) UIScrollView *scrollView;
@property (nonatomic,retain) WKWebView *webView;
@end

@implementation APKPrecificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.view.backgroundColor = [UIColor grayColor];
    self.title = NSLocalizedString(@"说明书", nil);
    [self setNavigationLeftBar];
    
    //初始化myWebView
    NSURL *filePath = [NSURL new];
    NSString *lan = [self getLanguageStr];
    if ([lan containsString:@"en"]) {

        filePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"html - iOS（UK）" ofType:@"pdf"]];
    }else if ([lan containsString:@"fr"]){
        filePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"html - iOS(FR)" ofType:@"pdf"]];
    }else if ([lan containsString:@"de"]){
        filePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"html - iOS(GER)" ofType:@"pdf"]];
    }else if ([lan containsString:@"ru"]){
        filePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"html - iOS(RU)" ofType:@"pdf"]];
    }else if ([lan containsString:@"it"]){
        filePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"html - iOS(IT)" ofType:@"pdf"]];
    }else if ([lan containsString:@"es"]){
        filePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"html - iOS(SP)" ofType:@"pdf"]];
    }else if ([lan containsString:@"nl"]){
        filePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"html - iOS(DU)" ofType:@"pdf"]];
    }else if ([lan containsString:@"pl"]){
        filePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"html - iOS（UK）" ofType:@"pdf"]];
    }else if([lan containsString:@"pt"]){
        filePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"html - iOS(POR)" ofType:@"pdf"]];
    }else if([lan containsString:@"ja"]){
        [self.view addSubview:self.scrollView];
        return;
    }else if([lan containsString:@"zh-Hans"]){
        filePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"html - iOS（UK）" ofType:@"pdf"]];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL: filePath];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    
    // Do any additional setup after loading the view.
}


-(NSString *) getLanguageStr
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [[NSString alloc] initWithString:[languages objectAtIndex:0]];
    return  currentLanguage;
}

#pragma mark - 设置返回按钮
- (void)setNavigationLeftBar
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [button setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    // 修改导航栏左边的item
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}
#pragma mark - 返回点击事件
- (void)back{
    [self dismissViewControllerAnimated:NO completion:^{
        nil;
    }];
}

-(WKWebView *)webView
{
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    }
    return _webView;
}

-(UIScrollView*)scrollView
{
    float imageHeight = 0;
    int width = [UIScreen mainScreen].bounds.size.width;
    int height = [UIScreen mainScreen].bounds.size.height;
    
    int scrollviewHeight = 0;
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        _scrollView.pagingEnabled = NO;
        _scrollView.bounces = NO;
        
        for (int i = 0;  i < 12; i++) {
            
            imageHeight = [UIImage imageNamed:[NSString stringWithFormat:@"080115345848_0html-iOS_%d",i]].size.height * width / [UIImage imageNamed:[NSString stringWithFormat:@"080115345848_0html-iOS_%d",i]].size.width;
            
            
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, scrollviewHeight, width, imageHeight)];
            image.image = [UIImage imageNamed:[NSString stringWithFormat:@"080115345848_0html-iOS_%d",i]];
            [_scrollView addSubview:image];
            
            scrollviewHeight += imageHeight + 120*width/375;
        }
        
        _scrollView.contentSize = CGSizeMake(width, scrollviewHeight - 80);
    }
    
    return _scrollView;
}

- (BOOL)shouldAutorotate{
    
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
