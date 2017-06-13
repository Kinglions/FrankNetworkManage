//
//  FrankActivityHUD.m
//  BarberProject
//
//  Created by Frank on 2017/6/6.
//  Copyright © 2017年 Frank. All rights reserved.
//

#import "FrankActivityHUD.h"

#define Current_Screen                    [UIScreen mainScreen]

#define FrameFor(view)            (view).bounds
#define Frame_SizeFor(view)        (view).bounds.size
#define Frame_WidthFor(view)       (view).bounds.size.width
#define Frame_HeightFor(view)      (view).bounds.size.height
#define Frame_OriginFor(view)      (view).frame.origin
#define Frame_OriginX(view)        (view).frame.origin.x
#define Frame_OriginY(view)        (view).frame.origin.y
#define Frame_CenterFor(view)      (view).frame.center
#define Frame_CenterXFor(view)     (view).frame.center.x
#define Frame_CenterYFor(view)     (view).frame.center.y


#define DURATION_BASE 0.7
#define TEXT_WIDTH Frame_WidthFor(Current_Screen)/2.8
#define TEXT_FONT_SIZE 14




@interface FrankActivityHUD ()<CAAnimationDelegate>

/**
 遮照层视图
 */
@property (strong, nonatomic) UIView *overlay;
/**
 图片顶部
 */
@property (strong, nonatomic) UIImageView *imageView;
/**
 图片底部
 */
@property (strong, nonatomic) UIImageView *shadowImageView;

/// 配置 layer 动画层
@property (strong, nonatomic) CAReplicatorLayer *replicatorLayer;
/**
 动画layer
 */
@property (strong, nonatomic) CAShapeLayer *indicatorCAShapeLayer;
/**
 提示文字 layer
 */
@property (strong, nonatomic) CATextLayer *indicatorTextLayer;
/**
 指示器样式
 */
@property FrankActivityHUDShowIndicatorType currentTpye;
/**
 是否显示 加载提示文字
 */
@property (nonatomic,assign)BOOL isShowLoadingTitle;
/**
 *  展示进度条 HUD
 */
@property (nonatomic) CGFloat progress;

@property BOOL useProvidedIndicator;
@property BOOL useProgress;
/**
 设置当显示 hud 时，界面是否可交互，默认为 YES：可交互
 */
@property (nonatomic,assign) BOOL isTheOnlyActiveView;

/**
 当前图片的索引
 */
@property (nonatomic,assign)NSInteger count;

@end

@implementation FrankActivityHUD

@synthesize hudBackgroundColor = _hudBackgroundColor;


/**
 设置展示 HUD 样式
 */
+ (void)showWithType:(FrankActivityHUDShowIndicatorType)type{
    
    [FrankActivityHUD showWithType:type isShowLodingTitle:NO];
}
/**
 设置展示 HUD 样式，是否显示加载中文字
 */
+ (void)showWithType:(FrankActivityHUDShowIndicatorType)type isShowLodingTitle:(BOOL)isShow{
    
    FrankActivityHUD * hud = [[FrankActivityHUD alloc] init];
//    hud.isTheOnlyActiveView = NO;

    if (!hud.superview) {
        
        hud.isShowLoadingTitle = isShow;
        
        [hud initializeReplicatorLayer];
        [hud initializeIndicatoeLayerWithType:type];
        hud.currentTpye = type;
        hud.useProvidedIndicator = YES;
        hud.useProgress = NO;
        
        [hud communalShowTask];
    }
}
/**
 *  展示默认样式：FrankActivityHUDShowIndicatorType_ScalingDots
 */
+ (void)show{
    
    [FrankActivityHUD showWithType:FrankActivityHUDShowIndicatorType_ScalingDots];
}
/**
 *  展示提示文字，是否需要闪动效果
 */
+ (void)showWithText:(NSString *)text shimmering:(BOOL)shimmering{
    
    if (!text) {
        text = @"";
    }
    
    FrankActivityHUD * hud = [[FrankActivityHUD alloc] init];
//    hud.isTheOnlyActiveView = NO;
    hud.overlayType = FrankActivityHUDOverlayType_None;
    if (!hud.superview) {
        CGFloat height = [hud heightForText:text]+16;
        hud.frame = CGRectMake(0, -height, TEXT_WIDTH, height);
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:hud.bounds];
        textLabel.numberOfLines = 0;
        textLabel.font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
        textLabel.textColor = [hud inverseColorFor:hud.backgroundColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.text = text;
        [hud addSubview:textLabel];
        
        if (shimmering) {
            [hud addShimmeringEffectForLabel:textLabel];
        }
        
        hud.useProvidedIndicator = NO;
        hud.useProgress = NO;
        
        [hud communalShowTask];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud removeFromSuperview];
        
    });
}

/**
 *  显示进度
 */
+ (void)showWithProgress{
    
    FrankActivityHUD * hud = [[FrankActivityHUD alloc] init];
//    hud.isTheOnlyActiveView = NO;
    if (!hud.superview) {
        [hud initializeReplicatorLayer];
        [hud initializeMinorArc];
        
        hud.indicatorCAShapeLayer.path = [hud arcPathWithStartAngle:-M_PI/2 span:2*M_PI];
        hud.indicatorCAShapeLayer.strokeEnd = 0.0;
        
        hud.indicatorCAShapeLayer.strokeColor = hud.indicatorColor.CGColor;
        
        hud.progress = 0.0;
        hud.useProvidedIndicator = NO;
        hud.useProgress = YES;
        
        [hud communalShowTask];
    }
}


+ (FrankActivityHUD *)HUDForView:(UIView *)view {
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            return (FrankActivityHUD *)subview;
        }
    }
    return nil;
}
/**
 消失前展示的文字内容
 
 @param text 文字
 @param delay 停留时间
 @param success 显示成功或者失败
 */
+ (void)dismissWithText:(NSString *)text delay:(CGFloat)delay success:(BOOL)success{
    
    FrankActivityHUD * hud = [FrankActivityHUD HUDForView:[[UIApplication sharedApplication].windows lastObject]];
    
    if (!hud) {
        return;
    }
    
//    hud.isTheOnlyActiveView = NO;
    
    if (hud.superview) {
        
        
        [hud.imageView stopAnimating];
        
        // 1、移除信息
        [hud removeAllSubviews];
        
        if (hud.replicatorLayer) {
            
            [hud.replicatorLayer removeFromSuperlayer];
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            
            if (!hud.isShowLoadingTitle) {
                
                hud.frame = [hud originalFrame];
            }
            
            hud.center = CGPointMake(Frame_WidthFor(Current_Screen)/2, Frame_HeightFor(Current_Screen)/2);
        }];
        
        // 2、添加图片
        __block CGFloat length = Frame_WidthFor(Current_Screen)/10;
        UIImageView *tickCrossImageView = [[UIImageView alloc] initWithFrame:CGRectMake((Frame_WidthFor(hud)-length)/2, length/3, length, length)];
        
        NSString * name = success?[NSString stringWithFormat:@"FrankActivityHUD.bundle/tick"]:[NSString stringWithFormat:@"FrankActivityHUD.bundle/cross"];

        tickCrossImageView.image = [UIImage imageNamed:name];
        tickCrossImageView.image = [tickCrossImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        tickCrossImageView.tintColor = hud.indicatorColor;
        [hud addSubview:tickCrossImageView];
        
        [UIView transitionWithView:hud
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:nil
                        completion:nil];
        
        if (text || text.length > 0) {
            
            // 添加文字提示
            [UIView animateWithDuration:0.5 animations:^{
                
                hud.frame = CGRectMake(0, 0, TEXT_WIDTH, Frame_OriginY(tickCrossImageView)+Frame_HeightFor(tickCrossImageView) + 8 + [hud heightForText:text] + 4);
                hud.center = CGPointMake(Frame_WidthFor(Current_Screen)/2, Frame_HeightFor(Current_Screen)/2);
                tickCrossImageView.frame = CGRectMake(Frame_WidthFor(hud)/2-length/2, length/3, length, length);
                
                UILabel * textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, Frame_OriginY(tickCrossImageView) + Frame_HeightFor(tickCrossImageView) + 8, Frame_WidthFor(hud), [hud heightForText:text])];
                
                textLabel.numberOfLines = 0;
                textLabel.font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
                textLabel.textColor = hud.indicatorColor;
                textLabel.textAlignment = NSTextAlignmentCenter;
                textLabel.text = text;
                [hud addSubview:textLabel];
                
            }];
        }
        
        [hud addDisappearAnimationWithDelay:delay+0.7];
        
    }
}

/**
 *  消失移除
 */
+ (void)dismiss{
    
    [FrankActivityHUD dismissWithText:nil delay:2 success:YES];
}





#pragma mark - show
- (void)show {
    
    [self showWithType:FrankActivityHUDShowIndicatorType_ScalingDots];
}
- (void)showWithType:(FrankActivityHUDShowIndicatorType)type {
    
    [self showWithType:type isShowLodingTitle:NO];
}
/**
 设置展示 HUD 样式，是否显示加载中文字
 */
- (void)showWithType:(FrankActivityHUDShowIndicatorType)type isShowLodingTitle:(BOOL)isShow{
    
    if (!self.superview) {
        
        self.isShowLoadingTitle = isShow;
        
        [self initializeReplicatorLayer];
        [self initializeIndicatoeLayerWithType:type];
        self.currentTpye = type;
        self.useProvidedIndicator = YES;
        self.useProgress = NO;
        
        [self communalShowTask];
    }
}
- (void)showWithText:(NSString *)text shimmering:(BOOL)shimmering{
    
    if (!text) {
        text = @"";
    }
    if (!self.superview) {
        
        self.overlayType = FrankActivityHUDOverlayType_None;

        CGFloat height = [self heightForText:text]+16;
        self.frame = CGRectMake(0, -height, TEXT_WIDTH, height);
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:self.bounds];
        textLabel.numberOfLines = 0;
        textLabel.font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
        textLabel.textColor = [self inverseColorFor:self.backgroundColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.text = text;
        [self addSubview:textLabel];
        
        if (shimmering) {
            [self addShimmeringEffectForLabel:textLabel];
        }
        
        self.useProvidedIndicator = NO;
        self.useProgress = NO;
        
        [self communalShowTask];
    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
        
    });
}
- (void)showWithProgress {
    if (!self.superview) {
        [self initializeReplicatorLayer];
        [self initializeMinorArc];
        
        self.indicatorCAShapeLayer.path = [self arcPathWithStartAngle:-M_PI/2 span:2*M_PI];
        self.indicatorCAShapeLayer.strokeEnd = 0.0;
        
        self.indicatorCAShapeLayer.strokeColor = self.indicatorColor.CGColor;
        
        self.progress = 0.0;
        self.useProvidedIndicator = NO;
        self.useProgress = YES;
        
        [self communalShowTask];
    }
}

#pragma mark - dismiss
/**
 视图消失

 @param text 提示文字
 @param delay 停留时间
 */
-(void)dismissWithText:(NSString *)text delay:(CGFloat)delay success:(BOOL)success{
    
    if (self.superview) {
        
        
        [self.imageView stopAnimating];

        // 1、移除信息
        [self removeAllSubviews];
        
        if (self.replicatorLayer) {
            
            [self.replicatorLayer removeFromSuperlayer];
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            
            if (!self.isShowLoadingTitle) {
                
                self.frame = [self originalFrame];

            }
            
            self.center = CGPointMake(Frame_WidthFor(Current_Screen)/2, Frame_HeightFor(Current_Screen)/2);
        }];
        
        // 2、添加图片
        __block CGFloat length = Frame_WidthFor(Current_Screen)/10;
        UIImageView *tickCrossImageView = [[UIImageView alloc] initWithFrame:CGRectMake(Frame_WidthFor(self)/2-length/2, length/3, length, length)];
        
        NSString * name = success?[NSString stringWithFormat:@"FrankActivityHUD.bundle/tick"]:[NSString stringWithFormat:@"FrankActivityHUD.bundle/cross"];
        
        tickCrossImageView.image = [UIImage imageNamed:name];
        tickCrossImageView.image = [tickCrossImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        tickCrossImageView.tintColor = self.indicatorColor;
        [self addSubview:tickCrossImageView];
        
        [UIView transitionWithView:self
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:nil
                        completion:nil];
        
        if (text || text.length > 0) {
           
            // 添加文字提示
            [UIView animateWithDuration:0.5 animations:^{
                
                self.frame = CGRectMake(0, 0, TEXT_WIDTH, Frame_OriginY(tickCrossImageView)+Frame_HeightFor(tickCrossImageView) + 8 + [self heightForText:text] + 4);
                self.center = CGPointMake(Frame_WidthFor(Current_Screen)/2, Frame_HeightFor(Current_Screen)/2);
                tickCrossImageView.frame = CGRectMake(Frame_WidthFor(self)/2-length/2, length/3, length, length);
                
                UILabel * textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, Frame_OriginY(tickCrossImageView) + Frame_HeightFor(tickCrossImageView) + 8, Frame_WidthFor(self), [self heightForText:text])];
                
                textLabel.numberOfLines = 0;
                textLabel.font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
                textLabel.textColor = self.indicatorColor;
                textLabel.textAlignment = NSTextAlignmentCenter;
                textLabel.text = text;
                [self addSubview:textLabel];
                
            }];
        }
        
        [self addDisappearAnimationWithDelay:delay+0.7];
        
    }
}
-(void)dismiss{
    
    [self dismissWithText:nil delay:0 success:YES];
}


#pragma mark - life cycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)removeFromSuperview{
    
    // 1、移除所有子视图
    [self removeAllSubviews];
    // 2、重置子图层
    self.layer.sublayers = nil;
    // 3、重置核心动画
    self.transform = CGAffineTransformIdentity;
    // 4、重置 frame
    self.frame = [self originalFrame];
    
    [super removeFromSuperview];
    
}
/**
 移除所有子视图
 */
- (void)removeAllSubviews {
    if (self.subviews.count > 0) {
        for (UIView *sub in self.subviews) {
            [sub removeFromSuperview];
        }
    }
}
#pragma mark ---------懒加载信息 ---------
-(void)setHudBackgroundColor:(UIColor *)hudBackgroundColor{
    
    if (_hudBackgroundColor != hudBackgroundColor) {
        
        _hudBackgroundColor = hudBackgroundColor;
        
        self.backgroundColor = hudBackgroundColor;
    }
}
-(UIColor *)hudBackgroundColor{
    
    return _hudBackgroundColor?:[UIColor blackColor];
}
-(UIColor *)indicatorColor{
    

    if ([self.backgroundColor isEqual:[UIColor clearColor]]) {
        
        return [UIColor blackColor] ;
    }
    
    return _indicatorColor ? : [self inverseColorFor:self.backgroundColor];
}
-(NSArray *)imgBounceArr{
    
    if (!_imgBounceArr) {
        _imgBounceArr = @[[UIImage imageNamed:[NSString stringWithFormat:@"FrankActivityHUD.bundle/1"]],[UIImage imageNamed:[NSString stringWithFormat:@"FrankActivityHUD.bundle/01"]],[UIImage imageNamed:[NSString stringWithFormat:@"FrankActivityHUD.bundle/001"]]];
    }
    
    if ([[_imgBounceArr firstObject] isKindOfClass:[NSString class]]) {
        
        NSMutableArray * imgArr = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (NSString * name in _imgBounceArr) {
            
            UIImage * img = [UIImage imageNamed:name];
            
            if (img) {
                [imgArr addObject:img];
            }
        }
        
        _imgBounceArr = imgArr;
    }
    
    return _imgBounceArr;
}
- (void)setProgress:(CGFloat)progress {
    
    if (self.indicatorCAShapeLayer && self.useProgress) {
        if (progress >= 1) {
            self.indicatorCAShapeLayer.strokeEnd = 1;
        } else if (progress <= 0) {
            self.indicatorCAShapeLayer.strokeEnd = 0;
        } else {
            self.indicatorCAShapeLayer.strokeEnd = progress;
        }
    }
}
+ (void)setProgress:(CGFloat)progress{
    
    FrankActivityHUD * hud = [FrankActivityHUD HUDForView:[[UIApplication sharedApplication].windows lastObject]];
    
    if (!hud) {
        return;
    }
    
    if (hud.indicatorCAShapeLayer && hud.useProgress) {
        if (progress >= 1) {
            hud.indicatorCAShapeLayer.strokeEnd = 1;
        } else if (progress <= 0) {
            hud.indicatorCAShapeLayer.strokeEnd = 0;
        } else {
            hud.indicatorCAShapeLayer.strokeEnd = progress;
        }
    }
}
#pragma mark --------- 配置信息 ---------
-(instancetype)init{
    
    if (self = [super init]) {
        
        // 1、设置 frame 大小
        self.frame = [self originalFrame];
        // 2、配置 hud 显示信息
        self.backgroundColor = self.hudBackgroundColor;
        
        // 3、设置圆角
        [self.layer setCornerRadius:8.f];
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 0;
        // 4、指示器出现、消失方式
        self.appearAnimationType = FrankActivityHUDAppearAnimationType_ZoomIn;
        self.disAppearAnimationType = FrankActivityHUDDisappearAnimationType_ZoomOut;
        // 5、设置遮照层样式
        self.overlayType = FrankActivityHUDOverlayType_Shadow;
        // 6、添加通知监听者
        [self addNotificationObserver];
        
    }
    return self;
}

/**
 设置 self 的原始大小
 */
-(CGRect)originalFrame{
    
    CGFloat length = Frame_WidthFor(Current_Screen)/6;
    
    return CGRectMake(-2*length, -2*length, length, length);
}
/**
 监听应用进入前台的通知
 
 因为应用进入后台之后，动画将会停止，所以需要在应用再次进入前台时进行唤醒动画
 
 */
-(void)addNotificationObserver{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addAnimation) name:UIApplicationWillEnterForegroundNotification object:nil];
}

/**
 初始化指示器展示样式
 */
- (void)initializeIndicatoeLayerWithType:(FrankActivityHUDShowIndicatorType)type {
    
    if (self.isShowLoadingTitle) {
        
        self.frame = (CGRect){Frame_OriginX(self),Frame_OriginY(self),Frame_HeightFor(self)+30,Frame_HeightFor(self)+30};
        self.replicatorLayer.frame = CGRectMake(0, -5, Frame_WidthFor(self), Frame_HeightFor(self));
        
    }else{
        
        self.replicatorLayer.frame = CGRectMake(0, 0, Frame_WidthFor(self.replicatorLayer), Frame_HeightFor(self.replicatorLayer));
        
        self.frame = [self originalFrame];
    }
    
    switch (type) {
            case FrankActivityHUDShowIndicatorType_ScalingDots:
            [self initializeScalingDots];
            break;
            
            case FrankActivityHUDShowIndicatorType_LeadingDots:
            [self initializeLeadingDots];
            break;
            
            case FrankActivityHUDShowIndicatorType_MinorArc:
            [self initializeMinorArc];
            break;
            
            case FrankActivityHUDShowIndicatorType_DynamicArc:
            [self initializeDynamicArc];
            break;
            
            case FrankActivityHUDShowIndicatorType_ArcInCircle:
            [self initializeArcInCircle];
            break;
            
            case FrankActivityHUDShowIndicatorType_SpringBall:
            [self initializeSpringBall];
            break;
            
            case FrankActivityHUDShowIndicatorType_ScalingBars:
            [self initializeScalingBars];
            break;
            
            case FrankActivityHUDShowIndicatorType_TriangleCircle:
            [self initializeTriangleCircle];
            break;
            
            case FrankActivityHUDShowIndicatorType_ImageBounce:
            [self initializeImageBounce];
            break;
            
            default:
            break;
    }
    
}

-(CATextLayer *)indicatorTextLayer{

    _indicatorTextLayer = [[CATextLayer alloc] init];
    _indicatorTextLayer.fontSize = 15;
    _indicatorTextLayer.contentsScale = Current_Screen.scale;
    _indicatorTextLayer.alignmentMode = @"center";
    _indicatorTextLayer.foregroundColor = self.indicatorColor.CGColor;
    _indicatorTextLayer.frame = CGRectMake(0, 0, Frame_WidthFor(self), 30);
    _indicatorTextLayer.position = CGPointMake(Frame_WidthFor(self)/2, Frame_HeightFor(self)-10);
    _indicatorTextLayer.backgroundColor = self.backgroundColor.CGColor;
    [self.layer insertSublayer:_indicatorTextLayer atIndex:0];
    
    return _indicatorTextLayer;
}

- (void)initializeScalingDots {
    
    CGFloat length = Frame_WidthFor(self)*18/200;
    
    self.indicatorCAShapeLayer = [[CAShapeLayer alloc] init];
    self.indicatorCAShapeLayer.backgroundColor = self.indicatorColor.CGColor;
    self.indicatorCAShapeLayer.frame = CGRectMake(0, 0, length, length);
    self.indicatorCAShapeLayer.position = CGPointMake(Frame_WidthFor(self)/2, Frame_HeightFor(self)/5);
    self.indicatorCAShapeLayer.cornerRadius = length/2;
    self.indicatorCAShapeLayer.transform = CATransform3DMakeScale(0.01, 0.01, 0.01);
    
    self.replicatorLayer.instanceCount = 15;
    self.replicatorLayer.instanceDelay = DURATION_BASE*1.2/self.replicatorLayer.instanceCount;
    CGFloat angle = 2*M_PI/self.replicatorLayer.instanceCount;
    self.replicatorLayer.instanceTransform = CATransform3DMakeRotation(angle, 0.0, 0.0, 0.1);
    
    [self.replicatorLayer addSublayer:self.indicatorCAShapeLayer];
    
}
-(void)initializeLeadingDots{
    
    CGFloat length = Frame_WidthFor(self)*18/200;
    self.indicatorCAShapeLayer = [[CAShapeLayer alloc] init];
    self.indicatorCAShapeLayer.backgroundColor = self.indicatorColor.CGColor;
    self.indicatorCAShapeLayer.frame = CGRectMake(0, 0, length, length);
    self.indicatorCAShapeLayer.position = CGPointMake(Frame_WidthFor(self)/2, Frame_HeightFor(self)/5);
    self.indicatorCAShapeLayer.cornerRadius = length/2;
    self.indicatorCAShapeLayer.shouldRasterize = YES;
    self.indicatorCAShapeLayer.rasterizationScale = Current_Screen.scale;
    
    self.replicatorLayer.instanceCount = 5;
    self.replicatorLayer.instanceDelay = 0.1;
    
    [self.replicatorLayer addSublayer:self.indicatorCAShapeLayer];
    
}
-(void)initializeMinorArc{
    
    self.indicatorCAShapeLayer = [[CAShapeLayer alloc]init];
    self.indicatorCAShapeLayer.strokeColor = self.indicatorColor.CGColor;// 绘制路径颜色
    self.indicatorCAShapeLayer.fillColor = [UIColor clearColor].CGColor;// 填充颜色
    self.indicatorCAShapeLayer.lineWidth = Frame_WidthFor(self)/24;
    
    CGFloat length = Frame_WidthFor(self)/5;
    self.indicatorCAShapeLayer.frame = CGRectMake(length, length, length*3, length*3);
    
    [self.replicatorLayer addSublayer:self.indicatorCAShapeLayer];
}
-(void)initializeDynamicArc{
    
    self.indicatorCAShapeLayer = [[CAShapeLayer alloc]init];
    self.indicatorCAShapeLayer.strokeColor = self.indicatorColor.CGColor;// 绘制路径颜色
    self.indicatorCAShapeLayer.fillColor = [UIColor clearColor].CGColor;// 填充颜色
    self.indicatorCAShapeLayer.lineWidth = Frame_WidthFor(self)/24;
    
    CGFloat length = Frame_WidthFor(self)/5;
    self.indicatorCAShapeLayer.frame = CGRectMake(length, length, length*3, length*3);
    
    [self.replicatorLayer addSublayer:self.indicatorCAShapeLayer];

}
-(void)initializeArcInCircle{
    
    [self initializeMinorArc];

}
-(void)initializeSpringBall{
    
    CGFloat length = Frame_WidthFor(self)*38/200;
    
    self.indicatorCAShapeLayer = [[CAShapeLayer alloc] init];
    self.indicatorCAShapeLayer.backgroundColor = self.indicatorColor.CGColor;
    self.indicatorCAShapeLayer.frame = CGRectMake(0, 0, length, length);
    self.indicatorCAShapeLayer.position = CGPointMake(Frame_WidthFor(self)/2, Frame_HeightFor(self)/5);
    self.indicatorCAShapeLayer.cornerRadius = length/2;
    
}
-(void)initializeScalingBars{
    
    self.replicatorLayer.instanceCount = 5;
    self.indicatorCAShapeLayer = [[CAShapeLayer alloc]init];
    self.indicatorCAShapeLayer.backgroundColor = self.indicatorColor.CGColor;
    CGFloat padding = 10;
    self.indicatorCAShapeLayer.frame = CGRectMake(padding, Frame_HeightFor(self)/4, (Frame_WidthFor(self)-padding*2)*2/3/self.replicatorLayer.instanceCount, Frame_HeightFor(self)/2);
    self.indicatorCAShapeLayer.cornerRadius = Frame_WidthFor(self.indicatorCAShapeLayer)/2;
    
    CGFloat distance = (Frame_WidthFor(self)-padding * 2)/3/(self.replicatorLayer.instanceCount - 1) + Frame_WidthFor(self.indicatorCAShapeLayer);
    self.replicatorLayer.instanceTransform = CATransform3DMakeTranslation(distance, 0.0, 0.0);
}
-(void)initializeTriangleCircle{
    
    CGFloat length = Frame_WidthFor(self)*25/200;
    
    self.indicatorCAShapeLayer = [[CAShapeLayer alloc] init];
    self.indicatorCAShapeLayer.backgroundColor = self.indicatorColor.CGColor;
    self.indicatorCAShapeLayer.frame = CGRectMake(0, 0, length, length);
    self.indicatorCAShapeLayer.position = CGPointMake( Frame_WidthFor(self)/2,  Frame_HeightFor(self)/5);
    self.indicatorCAShapeLayer.cornerRadius = length/2;
    self.indicatorCAShapeLayer.shouldRasterize = YES;
    self.indicatorCAShapeLayer.rasterizationScale = Current_Screen.scale;
}
/**
 自定义初始化 图片帧动画
 */
-(void)initializeImageBounce{
    
    self.overlayType = FrankActivityHUDOverlayType_Shadow;
    self.layer.masksToBounds = NO;

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(Frame_HeightFor(self)/10,0, Frame_HeightFor(self)*4/5, Frame_HeightFor(self)*4/5)];

    self.imageView.image = [self.imgBounceArr firstObject];
    self.hudBackgroundColor = [UIColor clearColor];
    
    self.shadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"FrankActivityHUD.bundle/02"]]];
    self.shadowImageView.bounds = (CGRect){0,0,Frame_WidthFor(self)/2,Frame_HeightFor(self)/6};
    self.shadowImageView.center = (CGPoint){self.imageView.center.x,Frame_HeightFor(self)};
    [self addSubview:self.shadowImageView];
    [self addSubview:self.imageView];
    self.count = 0;
//    CGFloat length = Frame_WidthFor(self)/5;
//    //  创建椭圆一个路径
//    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:(CGRect){Frame_WidthFor(self)/2, Frame_HeightFor(self)/2, length*2, length*2}];
//    self.indicatorCAShapeLayer = [CAShapeLayer layer];
//    self.indicatorCAShapeLayer.bounds = (CGRect){0,0, length*3, length};
//    self.indicatorCAShapeLayer.position = CGPointMake((Frame_WidthFor(self)-Frame_WidthFor(self.indicatorCAShapeLayer))/2,Frame_HeightFor(self)-Frame_HeightFor(self.indicatorCAShapeLayer));
//    self.indicatorCAShapeLayer.lineWidth = 2.0;
//    self.indicatorCAShapeLayer.strokeColor = [UIColor grayColor].CGColor;
//    self.indicatorCAShapeLayer.path = path.CGPath;
//    self.indicatorCAShapeLayer.fillColor = [UIColor grayColor].CGColor;  // 默认为blackColor
//    
//    [self.replicatorLayer addSublayer:self.indicatorCAShapeLayer];
    
}
#pragma mark --- 添加指示器展示样式 ----
/**
 处理指示器动画
 */
-(void)addAnimation{
    
    [self.indicatorCAShapeLayer removeAllAnimations];
    
    switch (self.currentTpye) {
            case FrankActivityHUDShowIndicatorType_ScalingDots:
            [self addScalingDotsAnimation];
            break;
            
            case FrankActivityHUDShowIndicatorType_LeadingDots:
            [self addLeadingDotsAnimation];
            break;
            
            case FrankActivityHUDShowIndicatorType_MinorArc:
            [self addMinorArcAnimation];
            break;
            
            case FrankActivityHUDShowIndicatorType_DynamicArc:
            [self addDynamicArcAnimation];
            break;
            
            case FrankActivityHUDShowIndicatorType_ArcInCircle:
            [self addArcInCircleAnimation];
            break;
            
            case FrankActivityHUDShowIndicatorType_SpringBall:
            [self addSpringBallAnimation];
            break;
            
            case FrankActivityHUDShowIndicatorType_ScalingBars:
            [self addScalingBarsAnimation];
            break;
            
            case FrankActivityHUDShowIndicatorType_TriangleCircle:
            [self addTriangleCircleAnimation];
            break;
            
            case FrankActivityHUDShowIndicatorType_ImageBounce:
            [self addImageBounceAnimation];
            break;
            
            default:
            break;
    }
    
    if (self.isShowLoadingTitle) {
        
        if (self.currentTpye != FrankActivityHUDShowIndicatorType_ImageBounce) {
            
            self.indicatorTextLayer.string = @"加载中...";
        }
    }
    
}
-(void)addScalingDotsAnimation{
    
    [self.indicatorCAShapeLayer addAnimation:[self scaleAnimationFrom:1.0 to:0.1 duration:DURATION_BASE*1.2 repeatTime:INFINITY] forKey:nil];
}
-(void)addLeadingDotsAnimation{
    
    CGFloat radius = Frame_WidthFor(self.replicatorLayer)/2 - Frame_WidthFor(self.replicatorLayer)/5;
    CGFloat x = CGRectGetMidX(self.replicatorLayer.frame);
    CGFloat y = CGRectGetMidY(self.replicatorLayer.frame);
    if (self.isShowLoadingTitle) {
        
         y = CGRectGetMidY(self.replicatorLayer.frame) + 5;

    }
    CGFloat startAngle = -M_PI_2;
    
    UIBezierPath * bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:CGPointMake(x, y) radius:radius startAngle:startAngle endAngle:startAngle+M_PI*2 clockwise:YES];
    // 转场动画
    CAKeyframeAnimation * leadingAnimation = [[CAKeyframeAnimation alloc]init];
    leadingAnimation.keyPath = @"position";
    leadingAnimation.path = bezierPath.CGPath;
    leadingAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    leadingAnimation.duration = DURATION_BASE + self.replicatorLayer.instanceCount * self.replicatorLayer.instanceDelay;
    // 缩小降下
    CABasicAnimation * scaleDownAnimation = [self scaleAnimationFrom:1.0 to:0.3 duration:leadingAnimation.duration*5/12 repeatTime:0];
    // 放大升起
    CABasicAnimation * scaleUpAnimation = [self scaleAnimationFrom:0.3 to:1.0 duration:leadingAnimation.duration - scaleDownAnimation.duration repeatTime:0];
    scaleUpAnimation.beginTime = scaleDownAnimation.duration;
    // 动画组
    CAAnimationGroup * animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = leadingAnimation.duration + self.replicatorLayer.instanceCount * self.replicatorLayer.instanceDelay;
    animationGroup.repeatCount = INFINITY;
    animationGroup.animations = @[leadingAnimation,scaleDownAnimation,scaleUpAnimation];
    
    [self.indicatorCAShapeLayer addAnimation:animationGroup forKey:nil];
}
-(void)addMinorArcAnimation{
    
    CAShapeLayer *oppositeArc = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.indicatorCAShapeLayer]];
    
    CGFloat length = Frame_WidthFor(self)/5;
    oppositeArc.frame = CGRectMake(length, length, length*3, length*3);
    [self.replicatorLayer addSublayer:oppositeArc];
    
    self.indicatorCAShapeLayer.path = [self arcPathWithStartAngle:-M_PI/4 span:M_PI/2];
    oppositeArc.path = [self arcPathWithStartAngle:M_PI*3/4 span:M_PI/2];
    
    CABasicAnimation *animation = [[CABasicAnimation alloc] init];
    animation.keyPath = @"transform.rotation.z";
    animation.fromValue = [NSNumber numberWithFloat:0.0];
    animation.toValue = [NSNumber numberWithFloat: 2*M_PI];
    animation.duration = DURATION_BASE*1.5;
    animation.repeatCount = INFINITY;
    
    [self.indicatorCAShapeLayer addAnimation:animation forKey:nil];
    [oppositeArc addAnimation:animation forKey:nil];
}
-(void)addDynamicArcAnimation{
    
    self.indicatorCAShapeLayer.path = [self arcPathWithStartAngle:-M_PI/2 span:2*M_PI];
    
    CABasicAnimation *strokeEndAnimation = [[CABasicAnimation alloc] init];
    strokeEndAnimation.keyPath = @"strokeEnd";
    strokeEndAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    strokeEndAnimation.toValue = [NSNumber numberWithFloat:1.0];
    strokeEndAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    strokeEndAnimation.duration = DURATION_BASE*2;
    
    CABasicAnimation *strokeStartAnimation = [[CABasicAnimation alloc] init];
    strokeStartAnimation.keyPath = @"strokeStart";
    strokeStartAnimation.beginTime =strokeEndAnimation.duration/4;
    strokeStartAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    strokeStartAnimation.toValue = [NSNumber numberWithFloat:1.0];
    strokeStartAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    strokeStartAnimation.duration = strokeEndAnimation.duration;
    
    CABasicAnimation *rotationAnimation = [[CABasicAnimation alloc] init];
    rotationAnimation.keyPath = @"transform.rotation.z";
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    rotationAnimation.toValue = [NSNumber numberWithFloat:2*M_PI];
    rotationAnimation.duration = 2*strokeEndAnimation.duration;
    rotationAnimation.repeatCount = INFINITY;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = strokeEndAnimation.duration+strokeStartAnimation.beginTime;
    animationGroup.repeatCount = INFINITY;
    animationGroup.animations = @[strokeEndAnimation, strokeStartAnimation];
    
    [self.indicatorCAShapeLayer addAnimation:animationGroup forKey:nil];
    [self.indicatorCAShapeLayer addAnimation:rotationAnimation forKey:nil];
    
}
-(void)addArcInCircleAnimation{
    
    CAShapeLayer * circleShapeLayer = [[CAShapeLayer alloc]init];
    circleShapeLayer.strokeColor = self.indicatorCAShapeLayer.strokeColor;
    circleShapeLayer.fillColor = [UIColor clearColor].CGColor;
    circleShapeLayer.opacity = self.indicatorCAShapeLayer.opacity - 0.8;
    circleShapeLayer.lineWidth = Frame_WidthFor(self)/24;
    circleShapeLayer.path = [self arcPathWithStartAngle:-M_PI span:2*M_PI];
    
    CGFloat length = Frame_WidthFor(self)/5;
    circleShapeLayer.frame = CGRectMake(length, length, length*3, length*3);
    [self.replicatorLayer insertSublayer:circleShapeLayer above:self.indicatorCAShapeLayer];
    
    self.indicatorCAShapeLayer.path = [self arcPathWithStartAngle:-M_PI_2 span:M_PI/3];
    
    CABasicAnimation * animation = [[CABasicAnimation alloc]init];
    animation.keyPath = @"transform.rotation.z";
    animation.fromValue = @(0.0);
    animation.toValue = @(2*M_PI);
    animation.duration = DURATION_BASE*1.5;
    animation.repeatCount = INFINITY;
    
    [self.indicatorCAShapeLayer addAnimation:animation forKey:nil];
    
}
-(void)addSpringBallAnimation{
    // 1、添加 layout 图层
    [self.replicatorLayer addSublayer:self.indicatorCAShapeLayer];
    
    // 2、创建降落动画
    CABasicAnimation * fallAnimation = [[CABasicAnimation alloc]init];
    fallAnimation.keyPath = @"position.y";
    fallAnimation.fromValue = @(Frame_HeightFor(self)/5);
    fallAnimation.toValue = @(Frame_HeightFor(self)*4/5);
    fallAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    fallAnimation.duration = DURATION_BASE;

    // 3、创建下落缩放动画
    CABasicAnimation * fallScaleAnimation = [self scaleAnimationFrom:1.0 to:0.5 duration:fallAnimation.duration repeatTime:0];
    
    // 4、创建弹起动画
    CABasicAnimation * springBackAnimation = [[CABasicAnimation alloc] init];
    springBackAnimation.keyPath = @"position.y";
    springBackAnimation.beginTime = fallScaleAnimation.duration;
    springBackAnimation.fromValue = @(Frame_HeightFor(self)*4/5);
    springBackAnimation.toValue = @(Frame_HeightFor(self)/5);
    springBackAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    springBackAnimation.duration = fallAnimation.duration;

    // 5、创建弹起缩放动画
    CABasicAnimation * springBackScaleAnimation = [self scaleAnimationFrom:0.5 to:1.0 duration:springBackAnimation.duration repeatTime:0];
    springBackScaleAnimation.beginTime = springBackAnimation.beginTime;
    
    // 6、创建动画组
    CAAnimationGroup * animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = fallAnimation.duration + springBackAnimation.duration;
    animationGroup.repeatCount = INFINITY;
    animationGroup.animations = @[fallAnimation,fallScaleAnimation,springBackAnimation,springBackScaleAnimation];
    [self.indicatorCAShapeLayer addAnimation:animationGroup forKey:nil];

    
}
-(void)addScalingBarsAnimation{
    
    // 1、加载图层
    [self.replicatorLayer addSublayer:self.indicatorCAShapeLayer];
    self.replicatorLayer.instanceDelay = DURATION_BASE/5;
    
    // 2、创建上升缩放动画
    CABasicAnimation * scaleUpAnimation = [self scaleAnimationFrom:1.0 to:1.3 duration:self.replicatorLayer.instanceDelay repeatTime:0];
    CABasicAnimation * scaleDownAnimation = [self scaleAnimationFrom:1.3 to:1.0 duration:self.replicatorLayer.instanceDelay repeatTime:0];
    scaleDownAnimation.beginTime = scaleUpAnimation.duration;
    
    // 3、创建动画组
    CAAnimationGroup * animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = (scaleUpAnimation.duration + scaleDownAnimation.duration) + (self.replicatorLayer.instanceCount - 1)*self.replicatorLayer.instanceDelay;
    animationGroup.repeatCount = INFINITY;
    animationGroup.animations = @[scaleUpAnimation,scaleDownAnimation];
    
    [self.indicatorCAShapeLayer addAnimation:animationGroup forKey:nil];
    
}
-(void)addTriangleCircleAnimation{
    
    CGPoint topPoint = self.indicatorCAShapeLayer.position;
    CGPoint leftPoint = CGPointMake(topPoint.x - Frame_HeightFor(self)*3*sqrt(3)/20, topPoint.y+Frame_HeightFor(self)*9/20);
    CGPoint rightPoint = CGPointMake(topPoint.x + Frame_HeightFor(self)*3*sqrt(3)/20, topPoint.y + Frame_HeightFor(self)*9/20);
    [self.replicatorLayer addSublayer:self.indicatorCAShapeLayer];
    
    CAShapeLayer * leftCircle = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.indicatorCAShapeLayer]];
    leftCircle.position = leftPoint;
    [self.replicatorLayer addSublayer:leftCircle];
    
    CAShapeLayer * rightCircle = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.indicatorCAShapeLayer]];
    rightCircle.position = rightPoint;
    [self.replicatorLayer addSublayer:rightCircle];
    
    NSArray * vertexs = @[
                          [NSValue valueWithCGPoint:topPoint],
                          [NSValue valueWithCGPoint:leftPoint],
                          [NSValue valueWithCGPoint:rightPoint]
                          ];
    
    [self.indicatorCAShapeLayer addAnimation:[self keyFrameAnimationWithPath:[self trianglePathWithStartPoint:topPoint vertexs:vertexs] duration:DURATION_BASE*2] forKey:nil];
    [rightCircle addAnimation:[self keyFrameAnimationWithPath:[self trianglePathWithStartPoint:leftPoint vertexs:vertexs] duration:DURATION_BASE*2] forKey:nil];
    [leftCircle addAnimation:[self keyFrameAnimationWithPath:[self trianglePathWithStartPoint:rightPoint vertexs:vertexs] duration:DURATION_BASE*2] forKey:nil];
    
    
}

/**
 自定义添加 图片弹跳 动画效果
 */
-(void)addImageBounceAnimation{
    
    // 1、添加 layout 图层
    [self.replicatorLayer addSublayer:self.indicatorCAShapeLayer];
    
    // 2、创建降落动画
    CABasicAnimation * fallAnimation = [[CABasicAnimation alloc]init];
    fallAnimation.keyPath = @"position.y";
    fallAnimation.fromValue = @(Frame_HeightFor(self)/5);
    fallAnimation.toValue = @(Frame_HeightFor(self)*4/5);
    fallAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    fallAnimation.duration = DURATION_BASE;
    
    // 3、创建下落缩放动画
    CABasicAnimation * fallScaleAnimation = [self scaleAnimationFrom:1.0 to:0.5 duration:fallAnimation.duration repeatTime:0];
    
    // 4、创建弹起动画
    CABasicAnimation * springBackAnimation = [[CABasicAnimation alloc] init];
    springBackAnimation.keyPath = @"position.y";
    springBackAnimation.beginTime = fallScaleAnimation.duration;
    springBackAnimation.fromValue = @(Frame_HeightFor(self)*4/5);
    springBackAnimation.toValue = @(Frame_HeightFor(self)/5);
    springBackAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    springBackAnimation.duration = fallAnimation.duration;
    
    // 5、创建弹起缩放动画
    CABasicAnimation * springBackScaleAnimation = [self scaleAnimationFrom:0.5 to:1.0 duration:springBackAnimation.duration repeatTime:0];
    springBackScaleAnimation.beginTime = springBackAnimation.beginTime;
    
    // 6、创建动画组
    CAAnimationGroup * animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = fallAnimation.duration + springBackAnimation.duration;
    animationGroup.repeatCount = INFINITY;
    animationGroup.animations = @[fallAnimation,fallScaleAnimation,springBackAnimation,springBackScaleAnimation];
    
    // 6、创建动画组
    CAAnimationGroup * animationGroup1 = [CAAnimationGroup animation];
    animationGroup1.duration = fallAnimation.duration + springBackAnimation.duration;
    animationGroup1.repeatCount = INFINITY;
    animationGroup1.animations = @[springBackScaleAnimation,fallScaleAnimation];
    
    animationGroup.delegate = self;
    
    [self.shadowImageView.layer addAnimation:animationGroup1 forKey:nil];
    [self.imageView.layer addAnimation:animationGroup forKey:nil];
    
    self.imageView.animationDuration = DURATION_BASE*3;
    self.imageView.animationImages = self.imgBounceArr;
    self.imageView.animationRepeatCount = 0;
    [self.imageView startAnimating];
    
}
///**
// 监听动画结束代理方法方法
//
// @param anim 动画对象
// @param flag 是否正常移除
// */
//-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
//    
//    FrankLog(@"-----%@----%d",anim,flag);
//    
//    self.count ++;
//    
//    if (self.count >= self.imgBounceArr.count) {
//        self.count = 0;
//    }
//    
//    self.imageView.image = [UIImage imageNamed:self.imgBounceArr[self.count]];
//    
//    
//}
#pragma mark --- 配置指示器消失样式 ----
/**
 hud 视图消失动画
 
 @param delay 延迟时间
 */
- (void)addDisappearAnimationWithDelay:(CGFloat)delay {
    switch (self.disAppearAnimationType) {
            case FrankActivityHUDDisappearAnimationType_SlideFromTop:
            [self addSlideToTopDissappearAnimationWithDelay:delay];
            break;
            
            case FrankActivityHUDDisappearAnimationType_SlideFromBottom:
            [self addSlideToBottomDissappearAnimationWithDelay:delay];
            break;
            
            case FrankActivityHUDDisappearAnimationType_SlideFromLeft:
            [self addSlideToLeftDissappearAnimationWithDelay:delay];
            break;
            
            case FrankActivityHUDDisappearAnimationType_SlideFromRight:
            [self addSlideToRightDissappearAnimationWithDelay:delay];
            break;
            
            case FrankActivityHUDDisappearAnimationType_ZoomOut:
            [self addZoomOutDisappearAnimationWithDelay:delay];
            break;
            
            case FrankActivityHUDDisappearAnimationType_FadeOut:
            [self addFadeOutDisappearAnimationWithDelay:delay];
            break;
    }
}
- (void)addSlideToTopDissappearAnimationWithDelay:(CGFloat)delay {
    
    [UIView animateWithDuration:0.25 delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.center = CGPointMake(Frame_WidthFor(Current_Screen)/2, -Frame_HeightFor(self));
        
    } completion:^(BOOL finished) {
        
        if (self.overlay) {
            
            [self.overlay removeFromSuperview];
        }
        
        [self removeFromSuperview];
        
    }];
}
- (void)addSlideToBottomDissappearAnimationWithDelay:(CGFloat)delay {
    
    [UIView animateWithDuration:0.25 delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.center = CGPointMake(Frame_WidthFor(Current_Screen)/2, Frame_HeightFor(Current_Screen)+Frame_HeightFor(self));
        
    } completion:^(BOOL finished) {
        
        if (self.overlay) {
            
            [self.overlay removeFromSuperview];
        }
        [self removeFromSuperview];
        
    }];
}
- (void)addSlideToLeftDissappearAnimationWithDelay:(CGFloat)delay{
    
    [UIView animateWithDuration:0.25 delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.center = CGPointMake( -Frame_HeightFor(self), Frame_HeightFor(Current_Screen)/2);
        
    } completion:^(BOOL finished) {
        
        if (self.overlay) {
            
            [self.overlay removeFromSuperview];
        }
        [self removeFromSuperview];
        
    }];
}
- (void)addSlideToRightDissappearAnimationWithDelay:(CGFloat)delay{
    
    [UIView animateWithDuration:0.25 delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.center = CGPointMake(Frame_WidthFor(Current_Screen)+Frame_WidthFor(self), Frame_HeightFor(Current_Screen)/2);
        
    } completion:^(BOOL finished) {
        
        if (self.overlay) {
            
            [self.overlay removeFromSuperview];
        }
        [self removeFromSuperview];
        
    }];
}
- (void)addZoomOutDisappearAnimationWithDelay:(CGFloat)delay{
    
    [UIView animateWithDuration:0.15 delay:delay options:kNilOptions animations:^{
        
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.1 animations:^{
            self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
            
            if (self.overlay) {
                
                [self.overlay removeFromSuperview];
            }
            [self removeFromSuperview];
        }];
    }];
    
}
- (void)addFadeOutDisappearAnimationWithDelay:(CGFloat)delay{
    
    CGFloat originalAlpha = self.alpha;
    
    [UIView animateWithDuration:0.35 delay:delay options:kNilOptions  animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.alpha = originalAlpha;
        if (self.overlay) {
            
            [self.overlay removeFromSuperview];
        }
        [self removeFromSuperview];
    }];
}
#pragma mark - appear animation
/**
 视图出现是的动画效果
 */
- (void)addAppearAnimation {
    switch (self.appearAnimationType) {
            case FrankActivityHUDAppearAnimationType_SlideFromTop:
            [self addSlideFromTopAppearAnimation];
            break;
            
            case FrankActivityHUDAppearAnimationType_SlideFromBottom:
            [self addSlideFromBottomAppearAnimation];
            break;
            
            case FrankActivityHUDAppearAnimationType_SlideFromLeft:
            [self addSlideFromLeftAppearAnimation];
            break;
            
            case FrankActivityHUDAppearAnimationType_SlideFromRight:
            [self addSlideFromRightAppearAnimation];
            break;
            
            case FrankActivityHUDAppearAnimationType_ZoomIn:
            [self addZoomInAppearAnimation];
            break;
            
            case FrankActivityHUDAppearAnimationType_FadeIn:
            [self addFadeInAppearAnimation];
            break;
    }
}
- (void)addSlideFromTopAppearAnimation {
    
    self.center = CGPointMake(Frame_WidthFor(Current_Screen)/2, -Frame_HeightFor(self));
    
    [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.center = CGPointMake(Frame_WidthFor(Current_Screen)/2, Frame_HeightFor(Current_Screen)/2);
    } completion:^(BOOL finished) {
        if (finished && self.useProvidedIndicator) {
            [self addAnimation];
        }
    }];
}
-(void)addSlideFromBottomAppearAnimation{
    self.center = CGPointMake(Frame_WidthFor(Current_Screen)/2, Frame_HeightFor(self) + Frame_HeightFor(Current_Screen));
    
    [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.center = CGPointMake(Frame_WidthFor(Current_Screen)/2, Frame_HeightFor(Current_Screen)/2);
    } completion:^(BOOL finished) {
        if (finished && self.useProvidedIndicator) {
            [self addAnimation];
        }
    }];
}
-(void)addSlideFromLeftAppearAnimation{
    
    self.center = CGPointMake(-Frame_WidthFor(self)/2, Frame_HeightFor(Current_Screen)/2);
    
    [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.center = CGPointMake(Frame_WidthFor(Current_Screen)/2, Frame_HeightFor(Current_Screen)/2);
    } completion:^(BOOL finished) {
        if (finished && self.useProvidedIndicator) {
            [self addAnimation];
        }
    }];
}
-(void)addSlideFromRightAppearAnimation{
    
    self.center = CGPointMake(Frame_WidthFor(Current_Screen) + Frame_WidthFor(self), Frame_HeightFor(Current_Screen)/2);
    
    [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.center = CGPointMake(Frame_WidthFor(Current_Screen)/2, Frame_HeightFor(Current_Screen)/2);
    } completion:^(BOOL finished) {
        if (finished && self.useProvidedIndicator) {
            [self addAnimation];
        }
    }];
}
-(void)addZoomInAppearAnimation{
    
    self.center = CGPointMake(Frame_WidthFor(Current_Screen)/2, Frame_HeightFor(Current_Screen)/2);

    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    
    [UIView animateWithDuration:0.15 animations:^{
        
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.1 animations:^{
            
            self.transform = CGAffineTransformIdentity;
            
            if (finished && self.useProvidedIndicator) {
                [self addAnimation];
            }
        }];
    }];
    
}
-(void)addFadeInAppearAnimation{
    
    CGFloat originalAlpha = self.alpha;
    self.alpha = 0.0;
    
    self.center = CGPointMake(Frame_WidthFor(Current_Screen)/2, Frame_HeightFor(Current_Screen)/2);
    
    [UIView animateWithDuration:0.35 animations:^{
        self.alpha = originalAlpha;
    } completion:^(BOOL finished) {
        if (finished && self.useProvidedIndicator) {
            [self addAnimation];
        }
    }];
}
/**
 获取 核心动画  -- 放大

 @param fromValue 初始值
 @param toValue 目的值
 @param duration 时间
 @param repeat 重复次数
 @return 核心动画图层
 */
- (CABasicAnimation *)scaleAnimationFrom:(CGFloat)fromValue to:(CGFloat)toValue  duration:(CFTimeInterval)duration repeatTime:(CGFloat)repeat {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = @(fromValue);
    animation.toValue = @(toValue);
    animation.duration = duration;
    animation.repeatCount = repeat;
    
    return animation;
}
/**
 获取指定颜色的相反色值

 @param color 指定颜色
 @return 相反颜色
 */
- (UIColor *)inverseColorFor:(UIColor *)color {
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [UIColor colorWithRed:1.-r green:1.-g blue:1.-b alpha:a];
}
/**
 根据给定文字，获取对应高度

 @param text 文字
 @return 高度
 */
- (CGFloat)heightForText:(NSString *)text{
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:TEXT_FONT_SIZE]}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){TEXT_WIDTH, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    return ceil(rect.size.height);
}
/**
 实例化动画图层
 */
- (void)initializeReplicatorLayer {
    self.replicatorLayer = [[CAReplicatorLayer alloc] init];
    self.replicatorLayer.frame = CGRectMake(0, 0, Frame_WidthFor(self), Frame_HeightFor(self));
    self.replicatorLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    [self.layer addSublayer:self.replicatorLayer];
}
- (void)communalShowTask {
    [self addOverlay];
    
    [[[UIApplication sharedApplication].windows lastObject] addSubview:self];
    [self.superview bringSubviewToFront:self];
    
    [self addAppearAnimation];
    
//    if (self.isTheOnlyActiveView) {
//        for (UIView *view in self.superview.subviews) {
//            view.userInteractionEnabled = NO;
//        }
//    }
}
/**
 绘制弧形路径

 @param startAngle 开始角度
 @param span 跨度
 @return 路径
 */
- (CGPathRef)arcPathWithStartAngle:(CGFloat)startAngle span:(CGFloat)span {
    CGFloat radius = Frame_WidthFor(self)/2 - Frame_HeightFor(self)/5;
    CGFloat x = Frame_WidthFor(self.indicatorCAShapeLayer)/2;
    CGFloat y = Frame_HeightFor(self.indicatorCAShapeLayer)/2;
    
    UIBezierPath *arcPath = [UIBezierPath bezierPath];
    [arcPath addArcWithCenter:CGPointMake(x, y) radius:radius startAngle:startAngle endAngle:startAngle+span clockwise:YES];
    return arcPath.CGPath;
}

/**
 创建核心动画

 @param path 路径
 @param duration 时间
 @return 动画对象
 */
- (CAKeyframeAnimation *)keyFrameAnimationWithPath:(UIBezierPath *)path duration:(NSTimeInterval)duration {
    CAKeyframeAnimation *animation = [[CAKeyframeAnimation alloc] init];
    animation.keyPath = @"position";
    animation.path = path.CGPath;
    animation.duration = duration;
    animation.repeatCount = INFINITY;
    
    return animation;
}
/**
 绘制贝塞尔路径

 @param startPoint 起始点
 @param vertexs 关键点
 @return 路径
 */
- (UIBezierPath *)trianglePathWithStartPoint:(CGPoint)startPoint vertexs:(NSArray *)vertexs {
    CGPoint topPoint  = [[vertexs objectAtIndex:0] CGPointValue];
    CGPoint leftPoint  = [[vertexs objectAtIndex:1] CGPointValue];
    CGPoint rightPoint  = [[vertexs objectAtIndex:2] CGPointValue];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    if (CGPointEqualToPoint(startPoint, topPoint) ) {
        [path moveToPoint:startPoint];
        [path addLineToPoint:rightPoint];
        [path addLineToPoint:leftPoint];
    } else if (CGPointEqualToPoint(startPoint, leftPoint)) {
        [path moveToPoint:startPoint];
        [path addLineToPoint:topPoint];
        [path addLineToPoint:rightPoint];
    } else {
        [path moveToPoint:startPoint];
        [path addLineToPoint:leftPoint];
        [path addLineToPoint:topPoint];
    }
    
    [path closePath];
    
    return path;
}
#pragma mark - background view
- (void)addOverlay {
    switch (self.overlayType) {
            case FrankActivityHUDOverlayType_None:
            // do nothing
            break;
            
            case FrankActivityHUDOverlayType_Blur:
            [self addBlurOverlay];
            break;
            
            case FrankActivityHUDOverlayType_Transparent:
            [self addTransparentOverlay];
            break;
            
            case FrankActivityHUDOverlayType_Shadow:
            [self addShadowOverlay];
            break;
    }
}

- (void)addBlurOverlay {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *overlayView = [[UIVisualEffectView alloc] initWithFrame:FrameFor(Current_Screen)];
    overlayView.effect = blurEffect;
    self.overlay = overlayView;
    
    [[[UIApplication sharedApplication].windows lastObject] addSubview:self.overlay];
}

- (void)addTransparentOverlay {
    self.overlay = [[UIView alloc] initWithFrame:FrameFor(Current_Screen)];
    self.overlay.backgroundColor = [UIColor clearColor];
//    self.overlay.alpha = self.alpha-.25>0?self.alpha-.2:0.15;

    
    [[[UIApplication sharedApplication].windows lastObject] addSubview:self.overlay];
}

- (void)addShadowOverlay {
    
    self.overlay = [[UIView alloc] initWithFrame:FrameFor(Current_Screen)];
    self.overlay.backgroundColor = [UIColor blueColor];
    self.overlay.alpha = 0.5;
    self.overlay.layer.shadowColor = [UIColor blackColor].CGColor;
    self.overlay.layer.shadowOffset = CGSizeMake(-2.0, -2.0);
    self.overlay.layer.shadowOpacity = 0.5;
    
    [[[UIApplication sharedApplication].windows lastObject] addSubview:self.overlay];
    
}
- (void)addShimmeringEffectForLabel:(UILabel *)label {
    CAGradientLayer *gradientMask = [CAGradientLayer layer];
    gradientMask.frame = label.bounds;
    CGFloat gradientSize = Frame_WidthFor(label)/6 / Frame_WidthFor(label);
    UIColor *gradient = [UIColor colorWithWhite:1.0f alpha:0.4];
    NSArray *startLocations = @[[NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:(gradientSize / 2)], [NSNumber numberWithFloat:gradientSize]];
    NSArray *endLocations = @[[NSNumber numberWithFloat:(1.0f - gradientSize)], [NSNumber numberWithFloat:(1.0f -(gradientSize / 2))], [NSNumber numberWithFloat:1.0f]];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"locations"];
    
    gradientMask.colors = @[(id)gradient.CGColor, (id)[UIColor whiteColor].CGColor, (id)gradient.CGColor];
    gradientMask.locations = startLocations;
    gradientMask.startPoint = CGPointMake(0 - (gradientSize * 2), .5);
    gradientMask.endPoint = CGPointMake(1 + gradientSize, .5);
    
    label.layer.mask = gradientMask;
    
    animation.fromValue = startLocations;
    animation.toValue = endLocations;
    animation.repeatCount = INFINITY;
    animation.duration  = 0.007*TEXT_WIDTH;
    
    [gradientMask addAnimation:animation forKey:nil];
}

@end
