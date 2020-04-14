//
//  APKFloderButton.m
//  Pioneer
//
//  Created by Mac on 17/9/13.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKFloderButton.h"

@implementation APKFloderButton

- (void)setHighlighted:(BOOL)highlighted{
    
    [super setHighlighted:highlighted];
    
    self.backgroundColor = highlighted ? self.highLightColor : self.normalColor;
}


#pragma mark - setter

- (void)setNormalColor:(UIColor *)normalColor{
    
    _normalColor = normalColor;
    
    self.backgroundColor = normalColor;
}

@end
