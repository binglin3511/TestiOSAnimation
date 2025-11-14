//
//  ShapeLayerTearViewController.m
//  TearEffectDemo
//
//  ShapeLayer遮罩撕裂效果 - 通过绘制不规则撕裂路径作为mask，创建撕裂路径
//

#import "ShapeLayerTearViewController.h"

@interface ShapeLayerTearViewController ()

@property (nonatomic, strong) UIImageView *topImageView;
@property (nonatomic, strong) UIImageView *bottomImageView;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) UIButton *startButton;

// UE参数 - ShapeLayer遮罩撕裂参数
@property (nonatomic, assign) CGFloat tearProgress;          // 撕裂进度 0-1
@property (nonatomic, assign) CGFloat irregularityFactor;    // 不规则程度因子
@property (nonatomic, assign) NSInteger controlPointCount;   // 控制点数量
@property (nonatomic, assign) CGFloat maxDeviation;          // 最大偏离距离

@end

@implementation ShapeLayerTearViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ShapeLayer遮罩撕裂";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // UE参数初始化
    // 【UE参数】不规则程度 - 控制撕裂边缘的随机程度，建议范围：0.3-1.5
    self.irregularityFactor = 0.8;
    
    // 【UE参数】控制点数量 - 控制撕裂路径的复杂度，建议范围：15-50
    self.controlPointCount = 30;
    
    // 【UE参数】最大偏离距离 - 控制撕裂边缘的最大偏离，建议范围：20-60
    self.maxDeviation = 40.0;
    
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
                                                        startColor:[UIColor colorWithRed:0.9 green:0.3 blue:0.4 alpha:1.0]
                                                          endColor:[UIColor colorWithRed:0.3 green:0.8 blue:0.6 alpha:1.0]];
    [self.view addSubview:self.bottomImageView];
    
    // 顶层图片 - 将被撕裂的图片
    self.topImageView = [[UIImageView alloc] initWithFrame:bounds];
    self.topImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.topImageView.clipsToBounds = YES;
    self.topImageView.image = [self createGradientImageWithSize:bounds.size
                                                     startColor:[UIColor colorWithRed:0.3 green:0.5 blue:0.9 alpha:1.0]
                                                       endColor:[UIColor colorWithRed:0.7 green:0.2 blue:0.7 alpha:1.0]];
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
    CGFloat centerX = width / 2.0;
    
    // 创建不规则撕裂路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // 计算左右撕裂宽度
    CGFloat leftTearWidth = width / 2.0 * self.tearProgress;
    CGFloat rightTearWidth = width / 2.0 * self.tearProgress;
    
    // 开始构建路径 - 从左上角开始
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(centerX - leftTearWidth, 0)];
    
    // 使用随机种子确保每次动画的撕裂路径一致
    srand(12345);
    
    // 生成左侧不规则撕裂边缘的控制点
    NSMutableArray *leftControlPoints = [NSMutableArray array];
    for (int i = 0; i <= self.controlPointCount; i++) {
        CGFloat t = (CGFloat)i / self.controlPointCount;
        CGFloat y = t * height;
        
        // 【UE参数】随机偏移计算
        // 使用多层随机来创建更自然的撕裂效果
        CGFloat randomFactor1 = ((CGFloat)rand() / RAND_MAX) * 2.0 - 1.0; // -1 到 1
        CGFloat randomFactor2 = ((CGFloat)rand() / RAND_MAX) * 2.0 - 1.0;
        
        // 混合多个随机因子创建更自然的偏移
        CGFloat deviation = (randomFactor1 * 0.7 + randomFactor2 * 0.3) * self.maxDeviation * self.irregularityFactor;
        
        // 【UE参数】边缘平滑度 - 可以在首尾减少偏移，使撕裂更自然
        if (i == 0 || i == self.controlPointCount) {
            deviation *= 0.3; // 首尾偏移较小
        }
        
        CGFloat x = centerX - leftTearWidth + deviation;
        [leftControlPoints addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }
    
    // 使用贝塞尔曲线连接控制点，创建平滑的撕裂边缘
    for (int i = 0; i < leftControlPoints.count; i++) {
        CGPoint point = [leftControlPoints[i] CGPointValue];
        
        if (i == 0) {
            [path addLineToPoint:point];
        } else if (i < leftControlPoints.count - 1) {
            // 【UE参数】曲线平滑度 - 通过调整控制点来改变曲线的平滑程度
            CGPoint prevPoint = [leftControlPoints[i - 1] CGPointValue];
            CGPoint nextPoint = [leftControlPoints[i + 1] CGPointValue];
            
            // 计算控制点，使曲线更平滑
            CGFloat controlPointOffset = 0.3; // 控制曲线的弯曲程度
            CGPoint controlPoint1 = CGPointMake(
                prevPoint.x + (point.x - prevPoint.x) * controlPointOffset,
                prevPoint.y + (point.y - prevPoint.y) * controlPointOffset
            );
            CGPoint controlPoint2 = CGPointMake(
                point.x - (nextPoint.x - point.x) * controlPointOffset,
                point.y - (nextPoint.y - point.y) * controlPointOffset
            );
            
            [path addCurveToPoint:point controlPoint1:controlPoint1 controlPoint2:controlPoint2];
        } else {
            [path addLineToPoint:point];
        }
    }
    
    // 重置随机种子，为右侧生成不同但一致的撕裂边缘
    srand(54321);
    
    // 生成右侧不规则撕裂边缘的控制点（从下往上）
    NSMutableArray *rightControlPoints = [NSMutableArray array];
    for (int i = self.controlPointCount; i >= 0; i--) {
        CGFloat t = (CGFloat)i / self.controlPointCount;
        CGFloat y = t * height;
        
        CGFloat randomFactor1 = ((CGFloat)rand() / RAND_MAX) * 2.0 - 1.0;
        CGFloat randomFactor2 = ((CGFloat)rand() / RAND_MAX) * 2.0 - 1.0;
        
        CGFloat deviation = (randomFactor1 * 0.7 + randomFactor2 * 0.3) * self.maxDeviation * self.irregularityFactor;
        
        if (i == 0 || i == self.controlPointCount) {
            deviation *= 0.3;
        }
        
        CGFloat x = centerX + rightTearWidth + deviation;
        [rightControlPoints addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }
    
    // 使用贝塞尔曲线连接右侧控制点
    for (int i = 0; i < rightControlPoints.count; i++) {
        CGPoint point = [rightControlPoints[i] CGPointValue];
        
        if (i == 0) {
            [path addLineToPoint:point];
        } else if (i < rightControlPoints.count - 1) {
            CGPoint prevPoint = [rightControlPoints[i - 1] CGPointValue];
            CGPoint nextPoint = [rightControlPoints[i + 1] CGPointValue];
            
            CGFloat controlPointOffset = 0.3;
            CGPoint controlPoint1 = CGPointMake(
                prevPoint.x + (point.x - prevPoint.x) * controlPointOffset,
                prevPoint.y + (point.y - prevPoint.y) * controlPointOffset
            );
            CGPoint controlPoint2 = CGPointMake(
                point.x - (nextPoint.x - point.x) * controlPointOffset,
                point.y - (nextPoint.y - point.y) * controlPointOffset
            );
            
            [path addCurveToPoint:point controlPoint1:controlPoint1 controlPoint2:controlPoint2];
        } else {
            [path addLineToPoint:point];
        }
    }
    
    // 完成路径
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
