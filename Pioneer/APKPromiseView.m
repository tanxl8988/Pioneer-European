//
//  APKPromiseView.m
//  Pioneer
//
//  Created by apical on 2019/6/20.
//  Copyright © 2019年 APK. All rights reserved.
//

#import "APKPromiseView.h"
#import "APKDVR.h"

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
}

-(void)setUpWebView
{
    //初始化myWebView
    NSURL *filePath = [NSURL new];
    NSString *lan = [self getLanguageStr];
    APKDVR *dvr = [APKDVR sharedInstance];
    if ([lan containsString:@"en"]) {

        filePath = dvr.appIsInSettingVC ? [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Dash Camera Interface EULA(English)" ofType:@"docx"]] : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Dash Camera Interface Privacy Policy(English)" ofType:@"docx"]];
    }else if ([lan containsString:@"fr"]){
              filePath = dvr.appIsInSettingVC ? [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Dash Camera Interface EULA(French)" ofType:@"docx"]] : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Dash Camera Interface Privacy Policy(French)" ofType:@"docx"]];
    }else if ([lan containsString:@"de"]){
              filePath = dvr.appIsInSettingVC ? [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Dash Camera Interface EULA(German)" ofType:@"docx"]] : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Dash Camera Interface Privacy Policy(German)" ofType:@"docx"]];
    }else if ([lan containsString:@"ru"]){
              filePath = dvr.appIsInSettingVC ? [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Dash Camera Interface EULA(Russian)" ofType:@"docx"]] : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Dash Camera Intreface Privacy Policy(Russian)" ofType:@"docx"]];
    }else if ([lan containsString:@"it"]){
            filePath = dvr.appIsInSettingVC ? [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Dash Camera Interface EULA(English)" ofType:@"docx"]] : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Dash Camera Interface Privacy Policy(English)" ofType:@"docx"]];
    }else if ([lan containsString:@"es"]){
            filePath = dvr.appIsInSettingVC ? [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Dash Camera Interface EULA(Spanish)" ofType:@"docx"]] : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Dash Camera Interface Privacy Policy(Spanish)" ofType:@"docx"]];
    }else if ([lan containsString:@"nl"]){
            filePath = dvr.appIsInSettingVC ? [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Dash Camera Interface EULA(Dutch)" ofType:@"docx"]] : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Dash Camera Interface Privacy Policy(Dutch)" ofType:@"docx"]];
    }else if ([lan containsString:@"pl"]){
            filePath = dvr.appIsInSettingVC ? [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Dash Camera Interface EULA(English)" ofType:@"docx"]] : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Dash Camera Interface Privacy Policy(English)" ofType:@"docx"]];
    }else if([lan containsString:@"pt"]){
              filePath = dvr.appIsInSettingVC ? [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Dash Camera Interface EULA(Portuguese)" ofType:@"docx"]] : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Dash Camera Intreface Privacy Policy(Portuguese)" ofType:@"docx"]];
    }else if([lan containsString:@"ja"]){
             filePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"【修正履歴なし】20200414(ja)_「ドライブレコーダーインターフェース」アプリ利用規約ver2" ofType:@"docx"]];
    }else if([lan containsString:@"zh-Hans"]){
        
             filePath = dvr.appIsInSettingVC ? [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Dash Camera Interface EULA(English)" ofType:@"docx"]] : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Dash Camera Interface Privacy Policy(English)" ofType:@"docx"]];
    }

    self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 200)];
    NSURLRequest *request = [NSURLRequest requestWithURL:filePath];
    [self.wkWebView loadRequest:request];
    self.wkWebView.center = self.center;
    self.wkWebView.scrollView.delegate = self;
    [self.wkWebView sizeToFit];
    [self addSubview:self.wkWebView];
}

-(NSString *) getLanguageStr
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [[NSString alloc] initWithString:[languages objectAtIndex:0]];
    return  currentLanguage;
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
