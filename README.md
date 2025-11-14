# TearEffectDemo - iOS撕裂效果演示

一个使用Objective-C实现的iOS应用，展示三种不同的撕裂动画效果。

## 功能特性

### 主界面
- 全屏渐变背景图片展示
- "撕裂动效"按钮，点击后弹出效果选择菜单

### 三种撕裂效果

#### 1. Perlin噪声撕裂
使用多个正弦波叠加模拟自然撕裂效果。

**UE可调参数：**
- `waveAmplitude`: 波浪振幅（锯齿高度），建议范围：5-30
- `waveCount`: 波浪数量（锯齿密度），建议范围：20-100
- `noiseScale`: 噪声缩放因子，建议范围：0.5-2.0
- 动画持续时间：0.5-2.0秒
- 撕裂速度：每帧进度增量 0.01-0.03

**实现原理：**
- 使用三层正弦波叠加创建自然的撕裂边缘
- 从中心向左右两侧撕裂
- 通过CAShapeLayer的mask实现撕裂效果

#### 2. 分层撕裂
通过两张相同的图片，设置锯齿形状，实现撕裂效果。

**UE可调参数：**
- `jaggedHeight`: 锯齿高度（深度），建议范围：10-40
- `jaggedWidth`: 锯齿宽度，建议范围：10-40
- `jaggedCount`: 锯齿数量，建议范围：10-30
- `maxOffset`: 最大移动距离，建议范围：屏幕宽度的 0.4-0.6
- 动画持续时间：0.5-2.0秒
- 撕裂速度：每帧进度增量 0.01-0.03

**实现原理：**
- 将图片分为左右两部分
- 左右两部分分别设置互补的锯齿形mask
- 通过移动左右两部分实现撕裂动画

#### 3. ShapeLayer遮罩撕裂
通过绘制不规则撕裂路径作为mask，创建更自然的撕裂效果。

**UE可调参数：**
- `irregularityFactor`: 不规则程度因子，建议范围：0.3-1.5
- `controlPointCount`: 控制点数量（路径复杂度），建议范围：15-50
- `maxDeviation`: 最大偏离距离，建议范围：20-60
- `controlPointOffset`: 曲线平滑度，控制贝塞尔曲线的弯曲程度
- 动画持续时间：0.5-2.0秒
- 撕裂速度：每帧进度增量 0.01-0.03

**实现原理：**
- 使用随机因子生成不规则的控制点
- 通过贝塞尔曲线连接控制点，创建平滑的撕裂边缘
- 左右两侧使用不同的随机种子，创建不同的撕裂效果
- 首尾偏移较小，使撕裂更自然

## 项目结构

```
TearEffectDemo/
├── main.m                              # 应用入口
├── AppDelegate.h/m                     # 应用代理
├── ViewController.h/m                  # 主视图控制器
├── PerlinNoiseTearViewController.h/m   # Perlin噪声撕裂
├── LayeredTearViewController.h/m       # 分层撕裂
├── ShapeLayerTearViewController.h/m    # ShapeLayer遮罩撕裂
├── Info.plist                          # 应用配置
└── TearEffectDemo.xcodeproj/          # Xcode项目文件
```

## 构建要求

- iOS 13.0+
- Xcode 14.0+
- Objective-C

## 使用说明

1. 在Xcode中打开 `TearEffectDemo.xcodeproj`
2. 选择目标设备或模拟器
3. 点击运行按钮
4. 在应用中点击"撕裂动效"按钮
5. 选择想要查看的撕裂效果
6. 在效果页面点击"开始撕裂"查看动画

## 代码说明

所有UE可调参数都在代码中用注释标记为 `【UE参数】`，方便设计师查找和调整。

每种撕裂效果都有详细的实现注释，说明了：
- 参数的作用和建议范围
- 实现原理
- 关键算法说明

## 技术要点

- 使用 `CAShapeLayer` 和 `UIBezierPath` 创建复杂的撕裂路径
- 使用 `CADisplayLink` 实现流畅的逐帧动画
- 使用正弦波叠加模拟自然的撕裂效果
- 使用贝塞尔曲线创建平滑的撕裂边缘
- 使用随机因子增加撕裂的自然感

## 自定义说明

如需自定义图片：
1. 替换各ViewController中的 `createGradientImageWithSize:startColor:endColor:` 方法
2. 或者添加图片资源到项目，使用 `[UIImage imageNamed:@"your_image"]` 加载

## 许可

本项目仅供演示和学习使用。