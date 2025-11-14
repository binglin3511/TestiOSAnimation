//
//  PerlinNoiseTearViewController.m
//  TearEffectDemo
//
//  Perlin噪声撕裂效果 - 使用多个正弦波叠加模拟自然撕裂
//

#import "PerlinNoiseTearViewController.h"

@interface PerlinNoiseTearViewController ()

@property (nonatomic, strong) UIImageView *topImageView;
@property (nonatomic, strong) UIImageView *bottomImageView;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) UIButton *startButton;

// UE参数 - Perlin噪声撕裂参数
@property (nonatomic, assign) CGFloat tearProgress;  // 撕裂进度 0-1
@property (nonatomic, assign) CGFloat waveAmplitude; // 波浪振幅（锯齿高度）
@property (nonatomic, assign) NSInteger waveCount;   // 波浪数量（锯齿密度）
@property (nonatomic, assign) CGFloat noiseScale;    // 噪声缩放因子

@end

@implementation PerlinNoiseTearViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Perlin噪声撕裂";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // UE参数初始化
    // 【UE参数】波浪振幅 - 控制锯齿的高度，建议范围：5-30
    self.waveAmplitude = 15.0;
    
    // 【UE参数】波浪数量 - 控制锯齿的密度，建议范围：20-100
    self.waveCount = 50;
    
    // 【UE参数】噪声缩放 - 控制噪声的随机程度，建议范围：0.5-2.0
    self.noiseScale = 1.0;
    
    self.tearProgress = 0.0;
    
    [self setupUI];
}

- (void)setupUI {
    CGRect bounds = self.view.bounds;
    
    // 底层图片 - 撕裂后显示的图片
    self.bottomImageView = [[UIImageView alloc] initWithFrame:bounds];
    self.bottomImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.bottomImageView.clipsToBounds = YES;
    self.bottomImageView.image = [self createGradientImageWithSize:bounds.size
                                                        startColor:[UIColor colorWithRed:1.0 green:0.8 blue:0.2 alpha:1.0]
                                                          endColor:[UIColor colorWithRed:1.0 green:0.3 blue:0.5 alpha:1.0]];
    [self.view addSubview:self.bottomImageView];
    
    // 顶层图片 - 将被撕裂的图片
    self.topImageView = [[UIImageView alloc] initWithFrame:bounds];
    self.topImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.topImageView.clipsToBounds = YES;
    self.topImageView.image = [self createGradientImageWithSize:bounds.size
                                                     startColor:[UIColor colorWithRed:0.2 green:0.6 blue:0.9 alpha:1.0]
                                                       endColor:[UIColor colorWithRed:0.5 green:0.2 blue:0.8 alpha:1.0]];
    [self.view addSubview:self.topImageView];
    
    // 创建遮罩层
    self.maskLayer = [CAShapeLayer layer];
    self.topImageView.layer.mask = self.maskLayer;
    
    // 开始按钮
    self.startButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.startButton.frame = CGRectMake(0, 0, 200, 50);
    self.startButton.center = CGPointMake(bounds.size.width / 2, bounds.size.height - 100);
    [self.startButton setTitle:@"开始撕裂" forState:UIControlStateNormal];
    self.startButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.startButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    self.startButton.layer.cornerRadius = 25;
    self.startButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.startButton.layer.shadowOffset = CGSizeMake(0, 2);
    self.startButton.layer.shadowOpacity = 0.3;
    self.startButton.layer.shadowRadius = 4;
    [self.startButton addTarget:self action:@selector(startTearAnimation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startButton];
    
    // 初始化遮罩
    [self updateMask];
}

- (void)startTearAnimation {
    self.startButton.enabled = NO;
    self.tearProgress = 0.0;
    
    // 使用CADisplayLink实现平滑动画
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateAnimation)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    // 【UE参数】动画持续时间 - 建议范围：0.5-2.0秒
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [displayLink invalidate];
        self.startButton.enabled = YES;
    });
}

- (void)updateAnimation {
    // 【UE参数】撕裂速度 - 控制每帧的进度增量，建议范围：0.01-0.03
    self.tearProgress += 0.015;
    
    if (self.tearProgress >= 1.0) {
        self.tearProgress = 1.0;
    }
    
    [self updateMask];
}

- (void)updateMask {
    CGRect bounds = self.topImageView.bounds;
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height;
    CGFloat centerY = height / 2.0;
    
    // 创建路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // 计算左侧撕裂宽度（从中心向左）
    CGFloat leftTearWidth = width / 2.0 * self.tearProgress;
    
    // 计算右侧撕裂宽度（从中心向右）
    CGFloat rightTearWidth = width / 2.0 * self.tearProgress;
    
    // 左侧撕裂边缘（使用Perlin噪声模拟）
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(width / 2.0 - leftTearWidth, 0)];
    
    // 绘制左侧锯齿边缘 - 使用多个正弦波叠加
    for (int i = 0; i <= self.waveCount; i++) {
        CGFloat t = (CGFloat)i / self.waveCount;
        CGFloat y = t * height;
        
        // 使用多个正弦波叠加模拟Perlin噪声
        CGFloat offset = 0;
        
        // 【UE参数】正弦波参数 - 可以调整频率和振幅来改变撕裂效果
        // 第一层波：主要波动
        offset += sin(t * M_PI * 4 * self.noiseScale) * self.waveAmplitude * 0.5;
        // 第二层波：中等波动
        offset += sin(t * M_PI * 8 * self.noiseScale + 1.5) * self.waveAmplitude * 0.3;
        // 第三层波：细节波动
        offset += sin(t * M_PI * 16 * self.noiseScale + 3.0) * self.waveAmplitude * 0.2;
        
        CGFloat x = width / 2.0 - leftTearWidth + offset;
        [path addLineToPoint:CGPointMake(x, y)];
    }
    
    // 绘制右侧锯齿边缘
    for (int i = self.waveCount; i >= 0; i--) {
        CGFloat t = (CGFloat)i / self.waveCount;
        CGFloat y = t * height;
        
        // 使用多个正弦波叠加（右侧使用不同的相位）
        CGFloat offset = 0;
        
        // 【UE参数】正弦波参数 - 右侧的波动参数，可以与左侧不同
        offset += sin(t * M_PI * 4 * self.noiseScale + 0.5) * self.waveAmplitude * 0.5;
        offset += sin(t * M_PI * 8 * self.noiseScale + 2.0) * self.waveAmplitude * 0.3;
        offset += sin(t * M_PI * 16 * self.noiseScale + 4.0) * self.waveAmplitude * 0.2;
        
        CGFloat x = width / 2.0 + rightTearWidth + offset;
        [path addLineToPoint:CGPointMake(x, y)];
    }
    
    [path addLineToPoint:CGPointMake(width, 0)];
    [path closePath];
    
    self.maskLayer.path = path.CGPath;
}

// 创建渐变图片的辅助方法
- (UIImage *)createGradientImageWithSize:(CGSize)size startColor:(UIColor *)startColor endColor:(UIColor *)endColor {
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSArray *colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, NULL);
    
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(size.width, size.height), 0);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    
    return image;
}

@end
