//
//  APKFlodersView.h
//  Pioneer
//
//  Created by Mac on 17/9/12.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APKFlodersView;
@protocol APKFlodersViewDelegate <NSObject>

- (void)APKFlodersView:(APKFlodersView *)flodersView didSelectedFloderAtIndex:(NSInteger)index;

@end

@interface APKFlodersView : UIView

@property (weak,nonatomic) id<APKFlodersViewDelegate> delegate;

@end
