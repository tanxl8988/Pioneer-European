//
//  APKBaseTabBarController.m
//  保时捷项目
//
//  Created by Mac on 16/5/9.
//
//

#import "APKBaseTabBarController.h"

@interface APKBaseTabBarController ()

@end

@implementation APKBaseTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)dealloc{
    
}

#pragma mark - system

-(BOOL)shouldAutorotate{
    
    return [self.selectedViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return [self.selectedViewController supportedInterfaceOrientations];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    
    return [self.selectedViewController preferredStatusBarStyle];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    
    return [self.selectedViewController preferredStatusBarUpdateAnimation];
}

- (BOOL)prefersStatusBarHidden{
    
    return [self.selectedViewController prefersStatusBarHidden];
}

@end
