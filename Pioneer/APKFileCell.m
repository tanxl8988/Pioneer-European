//
//  APKFileCell.m
//  Pioneer
//
//  Created by Mac on 17/9/13.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKFileCell.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVTime.h>
@implementation APKFileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.downloadedMark.text = NSLocalizedString(@"已下载", nil);
    
    UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressCell:)];
    [self addGestureRecognizer:longpress];
}

- (void)didLongPressCell:(UILongPressGestureRecognizer *)sender{
    
    if (self.delegate) {
        
        if (sender.state == UIGestureRecognizerStateBegan) {
            if ([self.delegate respondsToSelector:@selector(didBeganLongPress:)]) {
                [self.delegate didBeganLongPress:self];
            }
        }
        else if(sender.state == UIGestureRecognizerStateEnded){
            if ([self.delegate respondsToSelector:@selector(didEndedLongPress:)]) {
                [self.delegate didEndedLongPress:self];
            }
        }
    }
}

- (UIImage*) getVideoPreViewImage:(NSURL *)path
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}

@end
