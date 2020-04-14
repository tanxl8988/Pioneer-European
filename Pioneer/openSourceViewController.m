//
//  openSourceViewController.m
//  Pioneer
//
//  Created by apical on 2019/6/6.
//  Copyright © 2019年 APK. All rights reserved.
//

#import "openSourceViewController.h"

@interface openSourceViewController ()

@end

@implementation openSourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"开放源代码许可", nil);
    
    //初始化myWebView
    UIWebView *myWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    NSURL *filePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"license-jp_ios" ofType:@"pdf"]];
    NSURLRequest *request = [NSURLRequest requestWithURL: filePath];
    [myWebView loadRequest:request];
    //使文档的显示范围适合UIWebView的bounds
    [myWebView setScalesPageToFit:YES];
    [self.view addSubview:myWebView];
    // Do any additional setup after loading the view.
}
- (IBAction)backButtonClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
