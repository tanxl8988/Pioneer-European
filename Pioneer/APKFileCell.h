//
//  APKFileCell.h
//  Pioneer
//
//  Created by Mac on 17/9/13.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APKFileCell;

@protocol APKFileCellDelegate <NSObject>

- (void)didBeganLongPress:(APKFileCell *)cell;
- (void)didEndedLongPress:(APKFileCell *)cell;

@end

@interface APKFileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imagev;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *downloadedMark;

@property (weak, nonatomic) id<APKFileCellDelegate>delegate;
- (UIImage*) getVideoPreViewImage:(NSURL *)path;

@end
