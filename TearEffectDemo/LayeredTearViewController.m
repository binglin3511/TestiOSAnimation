//
//  LayeredTearViewController.m
//  TearEffectDemo
//
//  分层撕裂效果 - 通过两张相同的图片，设置锯齿，实现撕裂效果
//

#import "LayeredTearViewController.h"

@interface LayeredTearViewController ()

@property (nonatomic, strong) UIImageView *leftTopImageView;
@property (nonatomic, strong) UIImageView *leftBottomImageView;
@property (nonatomic, strong) UIImageView *rightTopImageView;
@property (nonatomic, strong) UIImageView *rightBottomImageView;
@property (nonatomic, strong) UIButton *startButton;

// UE参数 - 分层撕裂参数
@property (nonatomic, assign) CGFloat tearProgress;      // 撕裂进度 0-1
@property (nonatomic, assign) CGFloat jaggedHeight;      // 锯齿高度
@property (nonatomic, assign) CGFloat jaggedWidth;       // 锯齿宽度
@property (nonatomic, assign) NSInteger jaggedCount;     // 锯齿数量

@end

@implementation LayeredTearViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"分层撕裂";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // UE参数初始化
    // 【UE参数】锯齿高度 - 控制锯齿的深度，建议范围：10-40
    self.jaggedHeight = 25.0;
    
    // 【UE参数】锯齿宽度 - 控制单个锯齿的宽度，建议范围：10-40
    self.jaggedWidth = 20.0;
    
    // 【UE参数】锯齿数量 - 控制锯齿的数量，建议范围：10-30
    self.jaggedCount = 20;
    
    self.tearProgress = 0.0;
    
    [self setupUI];
}

- (void)setupUI {
    CGRect bounds = self.view.bounds;
    CGFloat halfWidth = bounds.size.width / 2.0;
    
    // 创建顶层图片（蓝紫渐变）
    UIImage *topImage = [self createGradientImageWithSize:bounds.size
                                               startColor:[UIColor colorWithRed:0.2 green:0.6 blue:0.9 alpha:1.0]
                                                 endColor:[UIColor colorWithRed:0.5 green:0.2 blue:0.8 alpha:1.0]];
    
    // 创建底层图片（黄粉渐变）
    UIImage *bottomImage = [self createGradientImageWithSize:bounds.size
                                                  startColor:[UIColor colorWithRed:1.0 green:0.8 blue:0.2 alpha:1.0]
                                                    endColor:[UIColor colorWithRed:1.0 green:0.3 blue:0.5 alpha:1.0]];
    
    // 左侧底层图片
    self.leftBottomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, halfWidth, bounds.size.height)];
    self.leftBottomImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.leftBottomImageView.clipsToBounds = YES;
    self.leftBottomImageView.image = bottomImage;
    [self.view addSubview:self.leftBottomImageView];
    
    // 右侧底层图片
    self.rightBottomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(halfWidth, 0, halfWidth, bounds.size.height)];
    self.rightBottomImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.rightBottomImageView.clipsToBounds = YES;
    self.rightBottomImageView.image = bottomImage;
    [self.view addSubview:self.rightBottomImageView];
    
    // 左侧顶层图片 - 向左移动撕裂
    self.leftTopImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, halfWidth, bounds.size.height)];
    self.leftTopImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.leftTopImageView.clipsToBounds = YES;
    self.leftTopImageView.image = topImage;
    [self.view addSubview:self.leftTopImageView];
    
    // 右侧顶层图片 - 向右移动撕裂
    self.rightTopImageView = [[UIImageView alloc] initWithFrame:CGRectMake(halfWidth, 0, halfWidth, bounds.size.height)];
    self.rightTopImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.rightTopImageView.clipsToBounds = YES;
    self.rightTopImageView.image = topImage;
    [self.view addSubview:self.rightTopImageView];
    
    // 创建锯齿遮罩
    [self updateMasks];
    
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
    
    CGRect bounds = self.view.bounds;
    CGFloat halfWidth = bounds.size.width / 2.0;
    
    // 【UE参数】最大移动距离 - 控制撕裂的最大距离，建议范围：屏幕宽度的 0.4-0.6
    CGFloat maxOffset = halfWidth * 0.5;
    CGFloat currentOffset = maxOffset * self.tearProgress;
    
    // 更新左侧位置
    CGRect leftFrame = self.leftTopImageView.frame;
    leftFrame.origin.x = -currentOffset;
    self.leftTopImageView.frame = leftFrame;
    
    // 更新右侧位置
    CGRect rightFrame = self.rightTopImageView.frame;
    rightFrame.origin.x = halfWidth + currentOffset;
    self.rightTopImageView.frame = rightFrame;
}

- (void)updateMasks {
    CGRect bounds = self.view.bounds;
    CGFloat halfWidth = bounds.size.width / 2.0;
    CGFloat height = bounds.size.height;
    
    // 创建左侧锯齿路径
    UIBezierPath *leftPath = [UIBezierPath bezierPath];
    [leftPath moveToPoint:CGPointMake(0, 0)];
    [leftPath addLineToPoint:CGPointMake(halfWidth, 0)];
    
    // 绘制右侧锯齿边缘（左图的右边缘）
    CGFloat segmentHeight = height / self.jaggedCount;
    for (int i = 0; i < self.jaggedCount; i++) {
        CGFloat y = i * segmentHeight;
        
        // 【UE参数】锯齿形状 - 可以调整这里的点来改变锯齿的形状
        // 当前使用三角形锯齿，也可以改为梯形或其他形状
        
        // 锯齿向右突出
        if (i % 2 == 0) {
            [leftPath addLineToPoint:CGPointMake(halfWidth + self.jaggedHeight, y + segmentHeight / 2)];
        } else {
            [leftPath addLineToPoint:CGPointMake(halfWidth - self.jaggedHeight, y + segmentHeight / 2)];
        }
    }
    
    [leftPath addLineToPoint:CGPointMake(halfWidth, height)];
    [leftPath addLineToPoint:CGPointMake(0, height)];
    [leftPath closePath];
    
    CAShapeLayer *leftMask = [CAShapeLayer layer];
    leftMask.path = leftPath.CGPath;
    self.leftTopImageView.layer.mask = leftMask;
    
    // 创建右侧锯齿路径（与左侧互补）
    UIBezierPath *rightPath = [UIBezierPath bezierPath];
    [rightPath moveToPoint:CGPointMake(0, 0)];
    
    // 绘制左侧锯齿边缘（右图的左边缘）
    for (int i = 0; i < self.jaggedCount; i++) {
        CGFloat y = i * segmentHeight;
        
        // 锯齿形状与左侧互补
        if (i % 2 == 0) {
            [rightPath addLineToPoint:CGPointMake(self.jaggedHeight, y + segmentHeight / 2)];
        } else {
            [rightPath addLineToPoint:CGPointMake(-self.jaggedHeight, y + segmentHeight / 2)];
        }
    }
    
    [rightPath addLineToPoint:CGPointMake(0, height)];
    [rightPath addLineToPoint:CGPointMake(halfWidth, height)];
    [rightPath addLineToPoint:CGPointMake(halfWidth, 0)];
    [rightPath closePath];
    
    CAShapeLayer *rightMask = [CAShapeLayer layer];
    rightMask.path = rightPath.CGPath;
    self.rightTopImageView.layer.mask = rightMask;
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
