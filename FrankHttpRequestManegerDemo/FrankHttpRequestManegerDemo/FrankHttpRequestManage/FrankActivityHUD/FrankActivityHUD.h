//
//  FrankActivityHUD.h
//  BarberProject
//
//  Created by Frank on 2017/6/6.
//  Copyright © 2017年 Frank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopTipView.h"

/**
 指示器展示的样式
 */
typedef NS_ENUM(NSInteger,FrankActivityHUDShowIndicatorType) {
    
    FrankActivityHUDShowIndicatorType_ScalingDots,
    FrankActivityHUDShowIndicatorType_LeadingDots,
    FrankActivityHUDShowIndicatorType_MinorArc,
    FrankActivityHUDShowIndicatorType_DynamicArc,
    FrankActivityHUDShowIndicatorType_ArcInCircle,
    FrankActivityHUDShowIndicatorType_SpringBall,
    FrankActivityHUDShowIndicatorType_ScalingBars,
    FrankActivityHUDShowIndicatorType_TriangleCircle,
    FrankActivityHUDShowIndicatorType_ImageBounce,// 图片弹跳动画，用户可以进行配置图片资源

};

/**
 指示器出现方式

 - FrankActivityHUDAppearAnimationTypeZoomIn: 中心放大弹出
 - FrankActivityHUDAppearAnimationTypeFadeIn: 中心淡入
 - FrankActivityHUDAppearAnimationTypeSlideFromTop: 从顶部进入
 - FrankActivityHUDAppearAnimationTypeSlideFromBottom: 从底部进入
 - FrankActivityHUDAppearAnimationTypeSlideFromLeft: 从左侧进入
 - FrankActivityHUDAppearAnimationTypeSlideFromRight: 从右侧进入
 */
typedef NS_ENUM(NSInteger,FrankActivityHUDAppearAnimationType) {
    
    FrankActivityHUDAppearAnimationType_ZoomIn = 0,
    FrankActivityHUDAppearAnimationType_FadeIn,
    FrankActivityHUDAppearAnimationType_SlideFromTop,
    FrankActivityHUDAppearAnimationType_SlideFromBottom,
    FrankActivityHUDAppearAnimationType_SlideFromLeft,
    FrankActivityHUDAppearAnimationType_SlideFromRight,
};

/**
 指示器消失方式

 - FrankActivityHUDDisappearAnimationTypeZoomOut: 中心弹性放大
 - FrankActivityHUDDisappearAnimationTypeFadeOut: 中心淡出
 - FrankActivityHUDDisappearAnimationTypeSlideFromTop: 从顶部滑出
 - FrankActivityHUDDisappearAnimationTypeSlideFromBottom: 从底部滑出
 - FrankActivityHUDDisappearAnimationTypeSlideFromLeft: 从左侧滑出
 - FrankActivityHUDDisappearAnimationTypeSlideFromRight: 从右侧滑出
 */
typedef NS_ENUM(NSInteger,FrankActivityHUDDisappearAnimationType) {
    
    FrankActivityHUDDisappearAnimationType_ZoomOut = 0,
    FrankActivityHUDDisappearAnimationType_FadeOut,
    FrankActivityHUDDisappearAnimationType_SlideFromTop,
    FrankActivityHUDDisappearAnimationType_SlideFromBottom,
    FrankActivityHUDDisappearAnimationType_SlideFromLeft,
    FrankActivityHUDDisappearAnimationType_SlideFromRight,
};
/**
 遮照层样式

 - FrankActivityHUDOverlayType_None: 没有遮罩层，默认状态
 - FrankActivityHUDOverlayType_Blur: 高斯遮照层
 - FrankActivityHUDOverlayType_Transparent: 透明灰度遮照层
 - FrankActivityHUDOverlayType_Shadow: 阴影遮罩层
 */
typedef NS_ENUM(NSInteger,FrankActivityHUDOverlayType) {
    FrankActivityHUDOverlayType_None = 0,
    FrankActivityHUDOverlayType_Blur,
    FrankActivityHUDOverlayType_Transparent,
    FrankActivityHUDOverlayType_Shadow,
};

@interface FrankActivityHUD : UIView

/**
 设置 hud 背景色，默认为 blackColor
 */
@property (nonatomic,strong) UIColor * hudBackgroundColor;

/**
 指示器颜色，默认为 whiteColor
 */
@property (nonatomic,strong) UIColor *indicatorColor;
/**
 指示器出现方式
 */
@property (nonatomic,assign)FrankActivityHUDAppearAnimationType appearAnimationType;
/**
 指示器消失方式
 */
@property (nonatomic,assign)FrankActivityHUDDisappearAnimationType disAppearAnimationType;
/**
 遮照层样式
 */
@property FrankActivityHUDOverlayType overlayType;

/**
 图片弹跳样式的资源数组，供用户进行自定义
 */
@property (nonatomic,strong)NSArray * imgBounceArr;


/**
 设置展示 HUD 样式
 */
- (void)showWithType:(FrankActivityHUDShowIndicatorType)type;
/**
 设置展示 HUD 样式，是否显示加载中文字
 */
- (void)showWithType:(FrankActivityHUDShowIndicatorType)type isShowLodingTitle:(BOOL)isShow;
/**
 *  展示默认样式：FrankActivityHUDShowIndicatorType_ScalingDots
 */
- (void)show;
/**
 *  展示提示文字，是否需要闪动效果 自动停留两秒钟
 */
- (void)showWithText:(NSString *)text shimmering:(BOOL)shimmering;

/**
 *  显示进度
 */
- (void)showWithProgress;
/**
 消失前展示的文字内容

 @param text 文字
 @param delay 停留时间
 @param success 显示成功或者失败
 */
- (void)dismissWithText:(NSString *)text delay:(CGFloat)delay success:(BOOL)success;

/**
 *  消失移除
 */
- (void)dismiss;
/**
 更新进度
 */
- (void)setProgress:(CGFloat)progress;
#pragma mark -----------------

/**
 设置展示 HUD 样式
 */
+ (void)showWithType:(FrankActivityHUDShowIndicatorType)type;
/**
 设置展示 HUD 样式，是否显示加载中文字
 */
+ (void)showWithType:(FrankActivityHUDShowIndicatorType)type isShowLodingTitle:(BOOL)isShow;
/**
 *  展示默认样式：FrankActivityHUDShowIndicatorType_ScalingDots
 */
+ (void)show;
/**
 *  展示提示文字，是否需要闪动效果 自动停留两秒钟
 */
+ (void)showWithText:(NSString *)text shimmering:(BOOL)shimmering;

/**
 *  显示进度
 */
+ (void)showWithProgress;
/**
 更新进度
 */
+ (void)setProgress:(CGFloat)progress;
/**
 消失前展示的文字内容
 
 @param text 文字
 @param delay 停留时间
 @param success 显示成功或者失败
 */
+ (void)dismissWithText:(NSString *)text delay:(CGFloat)delay success:(BOOL)success;

/**
 *  消失移除
 */
+ (void)dismiss;




@end
