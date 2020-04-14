//
//  APKPrecificationViewController.m
//  Pioneer
//
//  Created by tanxl on 2018/4/26.
//  Copyright © 2018年 APK. All rights reserved.
//

#import "APKPrecificationViewController.h"

@interface APKPrecificationViewController ()

@property (nonatomic,retain) UIScrollView *scrollView;
@end

@implementation APKPrecificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.view.backgroundColor = [UIColor grayColor];
    self.title = NSLocalizedString(@"说明书", nil);
    [self setNavigationLeftBar];
    [self.view addSubview:self.scrollView];
    
    // Do any additional setup after loading the view.
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
