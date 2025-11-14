//
//  ViewController.m
//  TearEffectDemo
//
//  Created on 2025-11-14.
//

#import "ViewController.h"
#import "PerlinNoiseTearViewController.h"
#import "LayeredTearViewController.h"
#import "ShapeLayerTearViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIButton *tearEffectButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"撕裂效果Demo";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
}

- (void)setupUI {
    // 背景图片视图 - 铺满全屏
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.clipsToBounds = YES;
    
    // 使用渐变色作为示例图片
    self.backgroundImageView.image = [self createGradientImageWithSize:self.view.bounds.size 
                                                             startColor:[UIColor colorWithRed:0.2 green:0.4 blue:0.8 alpha:1.0]
                                                               endColor:[UIColor colorWithRed:0.8 green:0.2 blue:0.4 alpha:1.0]];
    [self.view addSubview:self.backgroundImageView];
    
    // 撕裂动效按钮
    self.tearEffectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.tearEffectButton.frame = CGRectMake(0, 0, 200, 50);
    self.tearEffectButton.center = CGPointMake(self.view.bounds.size.width / 2, 
                                                self.view.bounds.size.height - 100);
    [self.tearEffectButton setTitle:@"撕裂动效" forState:UIControlStateNormal];
    self.tearEffectButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.tearEffectButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    self.tearEffectButton.layer.cornerRadius = 25;
    self.tearEffectButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.tearEffectButton.layer.shadowOffset = CGSizeMake(0, 2);
    self.tearEffectButton.layer.shadowOpacity = 0.3;
    self.tearEffectButton.layer.shadowRadius = 4;
    [self.tearEffectButton addTarget:self 
                              action:@selector(tearEffectButtonTapped:) 
                    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.tearEffectButton];
}

- (void)tearEffectButtonTapped:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择撕裂效果"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Perlin噪声撕裂
    UIAlertAction *perlinAction = [UIAlertAction actionWithTitle:@"Perlin噪声撕裂"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
        [self showPerlinNoiseTearEffect];
    }];
    [alertController addAction:perlinAction];
    
    // 分层撕裂
    UIAlertAction *layeredAction = [UIAlertAction actionWithTitle:@"分层撕裂"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
        [self showLayeredTearEffect];
    }];
    [alertController addAction:layeredAction];
    
    // ShapeLayer遮罩撕裂
    UIAlertAction *shapeLayerAction = [UIAlertAction actionWithTitle:@"ShapeLayer遮罩撕裂"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
        [self showShapeLayerTearEffect];
    }];
    [alertController addAction:shapeLayerAction];
    
    // 取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];
    
    // iPad适配
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        alertController.popoverPresentationController.sourceView = sender;
        alertController.popoverPresentationController.sourceRect = sender.bounds;
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showPerlinNoiseTearEffect {
    PerlinNoiseTearViewController *vc = [[PerlinNoiseTearViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showLayeredTearEffect {
    LayeredTearViewController *vc = [[LayeredTearViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showShapeLayerTearEffect {
    ShapeLayerTearViewController *vc = [[ShapeLayerTearViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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
