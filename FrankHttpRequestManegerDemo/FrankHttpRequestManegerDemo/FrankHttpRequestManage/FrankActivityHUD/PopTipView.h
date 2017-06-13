//
//  PopTipView.h
//  Frank
//
//  Created by Frank on 15/11/27.
//  Copyright © 2015年 hexin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopTipView : UIView

@property (nonatomic,strong) NSString *tipText;

/**
 展示提示文字，默认停留两秒钟

 @param superView 父视图
 @param tipStr 内容
 */
+(instancetype)showInView:(UIView *)superView wihtTipText:(NSString *)tipStr;
/**
 展示网络错误提示，默认停留两秒钟

 @param superView 父视图
 @param tipStr 提示内容
 */
+(instancetype)showInView:(UIView *)superView wihtNetWorkErrorTipText:(NSString *)tipStr;
+(instancetype)showInView:(UIView *)superView wihtNetWorkExceptionTipText:(NSString *)tipStr;
/**
 提示内容，自定义大小及停留时间

 @param superView 父视图
 @param tipStr 提示内容
 @param bounds 大小
 @param size 字号大小
 @param interval 停留时间
 */
+(instancetype)showInView:(UIView *)superView wihtTipText:(NSString *)tipStr bounds:(CGSize)bounds fontSize:(CGFloat)size withTimeInterval:(float)interval;
/**
 修改文字字号
 */
-(void)setTipLabelFontSize:(CGFloat)size;

/**
 *  设置提示信息框
 *
 *  @param superView 显示在的view
 *  @param tipStr    内容
 *  @param interval  显示时间
 */
+(instancetype)showInView:(UIView *)superView wihtTipText:(NSString *)tipStr withTimeInterval:(float)interval;


@end
