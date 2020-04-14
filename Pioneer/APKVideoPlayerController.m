//
//  APKVideoPlayerController.m
//  Pioneer
//
//  Created by Mac on 17/9/28.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKVideoPlayerController.h"
#import "CooAVPlayer.h"
#import <Photos/Photos.h>
#import "APKDVR.h"

typedef enum : NSUInteger {
    APKVideoPlayerSourceTypeURL,
    APKVideoPlayerSourceTypeAsset,
} APKVideoPlayerSourceType;

#define DURATION 5

@interface APKVideoPlayerController ()

@property (strong, nonatomic) IBOutlet CooAVPlayerView *playerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *replayButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *fullscreenButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *flower;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong,nonatomic) CooAVPlayer *player;
@property (nonatomic) APKVideoPlayerSourceType sourceType;
@property (strong,nonatomic) NSMutableArray *assets;
@property (strong,nonatomic) NSMutableArray *assetNames;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic) NSTimeInterval duration;
@property (weak,nonatomic) NSTimer *timer;

@end

@implementation APKVideoPlayerController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        [self.player addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
        [self.player addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:nil];
        [self.player addObserver:self forKeyPath:@"time" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.replayButton.hidden = YES;
    self.pauseButton.hidden = YES;
    
    [self.player setDisplayView:self.playerView];
    
    [self launchTimer];
    
    if ([APKDVR sharedInstance].deviceNumber == APKDVRDeviceDZ700) {
        [self.previousButton removeFromSuperview];
        [self.nextButton removeFromSuperview];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [self.player pause];
}

- (void)dealloc
{
    [self.player removeObserver:self forKeyPath:@"state"];
    [self.player removeObserver:self forKeyPath:@"duration"];
    [self.player removeObserver:self forKeyPath:@"time"];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"state"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CooAVPlayerState state = [change[@"new"] intValue];
            if (state == CooAVPlayerStateBuffering || state == CooAVPlayerStateOpening) {
                if (!self.flower.isAnimating)
                    [self.flower startAnimating];
            }
            else{
                if (self.flower.isAnimating)
                    [self.flower stopAnimating];
            }
            
            if (state == CooAVPlayerStateEnded || state == CooAVPlayerStateError || state == CooAVPlayerStatePaused) {
                self.replayButton.hidden = NO;
            }
            else{
                self.replayButton.hidden = YES;
            }
            
            if (state == CooAVPlayerStateOpening) {
                self.playButton.enabled = NO;
                self.pauseButton.enabled = NO;
            }
            else{
                self.playButton.enabled = YES;
                self.pauseButton.enabled = YES;
                
                if (state != CooAVPlayerStateBuffering) {
                    if (state == CooAVPlayerStatePlaying) {
                        self.playButton.hidden = YES;
                        self.pauseButton.hidden = NO;
                    }
                    else{
                        self.playButton.hidden = NO;
                        self.pauseButton.hidden = YES;
                    }
                }
            }
        });
    }
    else if ([keyPath isEqualToString:@"duration"]){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSTimeInterval duration = [change[@"new"] doubleValue];
            self.duration = duration;
            self.slider.maximumValue = duration;
            
            self.durationLabel.text = [self formatTimeWithSeconds:duration];
        });
    }
    else if ([keyPath isEqualToString:@"time"]){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSTimeInterval time = [change[@"new"] doubleValue];
            self.slider.value = time;
            
            self.timeLabel.text = [self formatTimeWithSeconds:time];
        });
    }
}

#pragma mark - private method

- (NSString *)formatTimeWithSeconds:(double)seconds{
    
    int wholeMinutes = (int)trunc(seconds / 60);
    int wholdSeconds = (int)trunc(seconds) - wholeMinutes * 60;
    NSString *formatTime = [NSString stringWithFormat:@"%02d:%02d", wholeMinutes, wholdSeconds];
    return formatTime;
}

- (void)launchTimer{
    
    if (self.timer) {
        
        [self.timer invalidate];
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:DURATION target:self selector:@selector(tapPlayerView:) userInfo:nil repeats:NO];
}

#pragma mark - public method

- (void)playWithAssets:(NSArray *)assets assetNames:(NSArray *)assetNames currentIndex:(NSInteger)currentIndex{
    
    NSAssert(currentIndex < assets.count, @"视频播放器传入的初始参数不对");
    
    [self.assets setArray:assets];
    [self.assetNames setArray:assetNames];
    self.currentIndex = currentIndex;
}

#pragma mark - event response

- (IBAction)tapPlayerView:(UITapGestureRecognizer *)sender {
    
    self.contentView.hidden = !self.contentView.hidden;
    
    if (self.contentView.hidden) {
        
        if (self.timer) {
            
            [self.timer invalidate];
        }
    }
    else{
        
        [self launchTimer];
    }
}

- (IBAction)touchUpSlider:(UISlider *)sender {
    
    [self launchTimer];
    
    [self.player play];
}

- (IBAction)slidSlider:(UISlider *)sender {
    
    NSTimeInterval time = sender.value;
    [self.player seekToTime:time];
    
    self.timeLabel.text = [self formatTimeWithSeconds:time];
}

- (IBAction)touchDownSlider:(UISlider *)sender {
    
    if (self.timer) {
        
        [self.timer invalidate];
    }
    
    [self.player pause];
}

- (IBAction)clickFullscreenButton:(UIButton *)sender {
    
    [self launchTimer];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(APKVideoPlayerController:didClickFullScreenButton:)]) {
        
        [self.delegate APKVideoPlayerController:self didClickFullScreenButton:sender];
    }
}

- (IBAction)clickPauseButton:(UIButton *)sender {
    
    [self launchTimer];
    [self.player pause];
}

- (IBAction)clickPlayButton:(UIButton *)sender {
    
    [self launchTimer];
    [self.player play];
}

- (IBAction)clickPreviousButton:(UIButton *)sender {
    
    [self launchTimer];
    self.currentIndex--;
}

- (IBAction)clickNextButton:(UIButton *)sender {
    
    [self launchTimer];
    self.currentIndex++;
}

- (IBAction)clickReplayButton:(UIButton *)sender {
    
    [self launchTimer];
    [self.player play];
}

#pragma mark - setter

- (void)setCurrentIndex:(NSInteger)currentIndex{
    
    _currentIndex = currentIndex;
    
    self.previousButton.hidden = currentIndex == 0;
    self.nextButton.hidden = currentIndex == self.assets.count - 1;
    
    NSString *name = self.assetNames[currentIndex];
    self.titleLabel.text = name;
    
    id asset = self.assets[currentIndex];
    [self.player updateAsset:asset];
}

#pragma mark - getter

- (NSMutableArray *)assetNames{
    
    if (!_assetNames) {
        
        _assetNames = [[NSMutableArray alloc] init];
    }
    return _assetNames;
}

- (NSMutableArray *)assets{
    
    if (!_assets) {
        
        _assets = [[NSMutableArray alloc] init];
    }
    return _assets;
}

- (CooAVPlayer *)player{
    
    if (!_player) {
        
        _player = [[CooAVPlayer alloc] init];
    }
    return _player;
}

@end
