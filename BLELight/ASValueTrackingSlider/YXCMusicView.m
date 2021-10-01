//
//  YXCMusicView.m
//  SmartRGBLight
//
//  Created by 李兰芳 on 16/2/21.
//  Copyright © 2016年 YaoXiaochuan. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "YXCMusicView.h"

@interface YXCMusicView ()<AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *playTime;
@property (weak, nonatomic) IBOutlet UILabel *totalTime;
@property (weak, nonatomic) IBOutlet UISlider *progressView;
@property (weak, nonatomic) IBOutlet UIButton *play;
@property (nonatomic, strong) NSTimer *timer;
//是否正在播放标记
@property (assign,nonatomic) BOOL isPlaying;
@end

@implementation YXCMusicView

+(instancetype)musicView
{
    return [[[NSBundle mainBundle]loadNibNamed:@"YXCMusicView" owner:nil options:nil] lastObject];
}
-(void)awakeFromNib
{
    self.isPlaying = NO;
    NSString *mp3Str = [[NSBundle mainBundle] pathForResource:@"Only Girl - Rihanna" ofType:@"mp3"];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:mp3Str] error:nil];
    self.audioPlayer.delegate = self;
    
    [self.progressView setThumbImage:[UIImage imageNamed:@"dot_music"] forState:UIControlStateNormal];
}

- (IBAction)play:(UIButton* )button
{
    if (self.isPlaying == NO)
    {
        if (self.audioPlayer.prepareToPlay && !self.audioPlayer.isPlaying)
        {
            self.isPlaying = YES;
            self.audioPlayer.currentTime = 0;
            [self.audioPlayer play];
            //改变图标
            [button setBackgroundImage:[UIImage imageNamed:@"btn_play_nor"] forState:UIControlStateNormal];
            
            self.totalTime.text =[NSString stringWithFormat:@"%02d:%02d", (int)self.audioPlayer.duration/60, (int)self.audioPlayer.duration%60];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
            
        }

    }else
    {
        self.isPlaying = NO;
        [self.audioPlayer pause];
        [self.timer invalidate];
        [button setBackgroundImage:[UIImage imageNamed:@"btn_pause_nor"] forState:UIControlStateNormal];
        
    }
        //执行代理
    if ([self.delegate respondsToSelector:@selector(playButtonDidSelected:)])
    {
        [self.delegate playButtonDidSelected:self.play];
    }
}

- (void)updateTime
{
    NSString *timeStr = [NSString stringWithFormat:@"%02d:%02d", (int)_audioPlayer.currentTime/60, (int)_audioPlayer.currentTime%60];
    self.playTime.text = timeStr;
    self.progressView.value = _audioPlayer.currentTime / _audioPlayer.duration;
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{   // 播放完毕
    [self.timer invalidate];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    // 解码失败
    [self.timer invalidate];

}



@end
