//
//  YXCMusicView.h
//  SmartRGBLight
//
//  Created by 李兰芳 on 16/2/21.
//  Copyright © 2016年 YaoXiaochuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class YXCMusicView;
@protocol YXCMusicViewDelegate <NSObject>
-(void)playButtonDidSelected:(UIButton *)button;
@end

@interface YXCMusicView : UIView
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (weak, nonatomic) id<YXCMusicViewDelegate> delegate;
+(instancetype)musicView;
@end
