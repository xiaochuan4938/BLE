//
//  LightViewController.m
//  BLELight
//
//  Created by 姚小川 on 9/29/21.
//

#import "LightViewController.h"
#import "KZColorPicker.h"
#import "ASValueTrackingSlider.h"
#import "YXCMusicView.h"
#define KscreenWidht  ([UIScreen mainScreen].bounds.size.width)
#define KscreenHeight ([UIScreen mainScreen].bounds.size.height)
#define KmusicHeight   (150)
#define Kmargin       (40)

@interface LightViewController ()<KZColorPickerDelegate,YXCMusicViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *lightImageView;
@property (weak, nonatomic) IBOutlet UISwitch *powerSwitch;
@property (weak, nonatomic) IBOutlet KZColorPicker *colorView;
@property (weak, nonatomic) IBOutlet ASValueTrackingSlider *slider;

@property (strong, nonatomic) UIColor *selectedColor;
@property (assign, nonatomic) CGFloat btmBeginY;

@property (assign, nonatomic) int brightness;
@property (assign, nonatomic) int red;
@property (assign, nonatomic) int green;
@property (assign, nonatomic) int blue;
@property (assign, nonatomic) int white;

@property (strong, nonatomic) NSArray *colorArray;
@property (strong, nonatomic) NSTimer *musicTimer;
@property (weak, nonatomic) YXCMusicView *musicView;
@end

@implementation LightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *red = [UIColor redColor];
    UIColor *green = [UIColor greenColor];
    UIColor *blue = [UIColor blueColor];
    UIColor *yellow = [UIColor yellowColor];
    UIColor *cyan = [UIColor cyanColor];
    UIColor *orange = [UIColor orangeColor];
    UIColor *purple = [UIColor purpleColor];
    UIColor *brown = [UIColor brownColor];
    UIColor *magenta = [UIColor magentaColor];
    self.colorArray = @[red,green,blue,yellow,cyan,orange,purple,brown,magenta];
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    
    
    
    self.colorView.delegate = self;
    self.colorView.selectedColor = [UIColor whiteColor];
    self.selectedColor = self.colorView.selectedColor;
    
    
    self.slider.maximumValue =100.0;
    self.slider.popUpViewCornerRadius = 5.0;
    self.slider.continuous = NO;
    [self.slider setMaxFractionDigitsDisplayed:0];
    self.slider.popUpViewColor = [UIColor colorWithHue:0.55 saturation:0.8 brightness:0.9 alpha:0.7];
    self.slider.font = [UIFont fontWithName:@"GillSans-Bold" size:22];
    self.slider.textColor = [UIColor colorWithHue:0.55 saturation:1.0 brightness:0.5 alpha:1];
    self.slider.popUpViewWidthPaddingFactor = 1.7;
    [self.slider addTarget:self action:@selector(brightnessChanged:) forControlEvents:UIControlEventValueChanged];
   
    
    
    
    //musicView
    YXCMusicView *musicView =[YXCMusicView musicView];
    musicView.delegate = self;
    musicView.frame = CGRectMake(0, KscreenHeight-200, KscreenWidht, 150);
    musicView.backgroundColor =[UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1];
    // 滑动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [musicView addGestureRecognizer:panGestureRecognizer];
    [self.view addSubview:musicView];
     self.musicView = musicView;
    
    self.brightness = 100;
    [self.slider setValue:self.brightness];
}

-(void) handlePan:(UIPanGestureRecognizer*) pan{
   
    CGFloat y = [pan translationInView:self.musicView].y;
    if (pan.state == UIGestureRecognizerStateBegan) {
        //拿到此时的Y值
        self.btmBeginY = self.musicView.frame.origin.y;
        
    }else if (pan.state == UIGestureRecognizerStateChanged)
    {
        if (KscreenHeight-KmusicHeight <= self.btmBeginY + y && self.btmBeginY + y<=KscreenHeight-Kmargin)
        {
            //修改frame
            [self setView:self.musicView originY:self.btmBeginY + y];
        }
        
    }else if (pan.state == UIGestureRecognizerStateEnded)
    {
        
    }

}

- (IBAction)turnOnOff:(UISwitch* )aSwitch{
    if (aSwitch.on) {
        self.brightness = 100;
    }else{
        self.brightness = 0;
    }
    
    [self.slider setValue:self.brightness];
    [self sendColor:self.selectedColor];
    
}


-(void)brightnessChanged:(UISlider *)sender{
    self.brightness = sender.value;
    [self sendColor:self.selectedColor];
}

- (void)setView:(UIView *)view originY:(CGFloat)y{
    CGRect rect = view.frame;
    rect.origin.y = y;
    view.frame = rect;
}

-(void)playButtonDidSelected:(UIButton*)button{
    if (self.musicTimer == nil){
        self.musicTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playProgress) userInfo:nil repeats:YES];
    }else{
        [self.musicTimer invalidate];
        self.musicTimer = nil;
    }
    
    
}
#pragma mark -音乐主函数
//播放进度条
int m = 0;
int lastVm = 0;//纪录上次的明暗度
- (void)playProgress
{
    AVAudioPlayer *player =self.musicView.audioPlayer;
    //通过音频播放时长的百分比,给progressview进行赋值;
    if (player.duration == 0)
    {
        return;
    }
    //许可
    [player setMeteringEnabled:YES];
    //更新仪表读数
    //读取每个声道的平均电平和峰值电平，代表每个声道的分贝数,范围在-160～0之间。
    [player updateMeters];
    CGFloat total = 0;
    for (int i =0; i<player.numberOfChannels; i++)
    {
        CGFloat power =(-1)*[player averagePowerForChannel:i];
        NSLog(@"power %f",power);
        total +=power;
    }
   int avg =0.5*160 - total*0.5;
    
    //比如把0作为最低分贝
    
    int minValue = 0;
    
    //把160作为获取分配的范围
    
    int range = 160;
    
    //把100作为输出分贝范围
    
    int outRange = 100;
    
    //确保在最小值范围内
    
    if (avg < minValue)
        
    {
        
        avg = minValue;
        
    }
    
    //计算显示分贝
    
    int decibels = (avg*1.0) / range * outRange;
    NSLog(@"%d",  decibels);
  
    //自定义颜色组
    if(self.colorArray > 0)
    {
            self.brightness = decibels;
        [self.slider setValue:self.brightness];
            [self modePlay];
    }
    
}

int cIndex = 0;
- (void)modePlay
{
    UIColor *color = [self.colorArray objectAtIndex:cIndex % self.colorArray.count];
    cIndex ++;
    [self sendColor:color];
}

#pragma mark - KZColorPickerDelegate

- (void)colorPicker:(KZColorPicker*)picker didChanged:(UIColor *)color{
    self.selectedColor = color;
    [self sendColor:color];
}

-(void) sendColor:(UIColor *)color{
    if (color != nil) {
        CGFloat red,green,blue,alpha;
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
        
        Byte mRed   =  (Byte) (red*255 * self.brightness/100);
        Byte mGreen = (Byte) (green*255* self.brightness/100);
        Byte mBlue  =  (Byte) (blue*255* self.brightness/100);
        Byte mAlpha = (Byte) (alpha*255* self.brightness/100);
        
        NSMutableData * colorDatas = [[NSMutableData alloc] init];
        [colorDatas appendBytes:&mRed length:1];
        [colorDatas appendBytes:&mGreen length:1];
        [colorDatas appendBytes:&mBlue length:1];
        [colorDatas appendBytes:&mAlpha length:1];
        
        [self.rwCharacteristic.service.peripheral writeValue:colorDatas
                                           forCharacteristic:self.rwCharacteristic
                                                        type:0];
        
    }
    
}

@end
