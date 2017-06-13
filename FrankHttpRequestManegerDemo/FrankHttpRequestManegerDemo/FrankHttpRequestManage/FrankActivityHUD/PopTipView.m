//
//  PopTipView.m
//  Frank
//
//  Created by Frank on 15/11/27.
//  Copyright © 2015年 Frank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PopTipView.h"

#define TIPLABEL_XPADDING 4.5

#define TIPLABEL_YPADDING 5

#define FRANK_POPVIEW_WIDTH 85

#define FRANK_POPVIEW_HEIGHT 85

#define FRANK_POPVIEW_NETWORKERROR_WIDTH 100

#define FRANK_POPVIEW_NETWORKERROR_HEIGHT 95

#define FRANK_POPVIEW_NETWORKEXCEPTION_WIDTH 130

#define FRANK_POPVIEW_NETWORKEXCEPTION_HEIGHT 95

@interface PopTipView ()

@property (strong,nonatomic) UILabel *tipLabel;

@end

@implementation PopTipView

+(instancetype)sharePopTipView
{
    static PopTipView *popTipView;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        popTipView = [[PopTipView alloc] initWithFrame:CGRectMake(0, 0, FRANK_POPVIEW_WIDTH, FRANK_POPVIEW_HEIGHT)];
    });
    
    return popTipView;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setup];
    }
    
    return self;
}

-(void)setup
{
//    [self setBackgroundColor:[UIColor colorWithHexString:@"333333"]];
//    self.alpha = 0.9;
    self.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.7];
    
    self.layer.cornerRadius = 5.f;
    
    self.tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.tipLabel setBackgroundColor:[UIColor clearColor]];
    [self.tipLabel setFont:[UIFont systemFontOfSize:16.f]];
    [self.tipLabel setTextColor:[UIColor whiteColor]];
    [self.tipLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.tipLabel];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.tipLabel setFrame:CGRectMake(TIPLABEL_XPADDING, TIPLABEL_YPADDING, self.frame.size.width - TIPLABEL_XPADDING * 2, self.frame.size.height - TIPLABEL_YPADDING * 2)];
}

-(void)setTipText:(NSString *)tipText
{
    [self.tipLabel setText:tipText];
    
    [self setNeedsDisplay];
}

+(instancetype)showInView:(UIView *)superView wihtTipText:(NSString *)tipStr
{
   return [PopTipView showInView:superView wihtTipText:tipStr withTimeInterval:2];
}

+(instancetype)showInView:(UIView *)superView wihtTipText:(NSString *)tipStr withTimeInterval:(float)interval
{

    
    CGFloat width = 0.f;
    CGSize textSize = [PopTipView getSizeWithFont:[UIFont systemFontOfSize:16.f] textview:NO string:tipStr];
    if (textSize.width >= [UIScreen mainScreen].bounds.size.width - 16)
    {
        width = [UIScreen mainScreen].bounds.size.width - 16;
        
        textSize = [PopTipView getSizeWithFont:[UIFont systemFontOfSize:16.f] maxWidth:width-16 textview:NO string:tipStr];
        
        textSize = CGSizeMake( width, textSize.height+32);
    }
    else
    {
        textSize = CGSizeMake( textSize.width+20, textSize.height+32);
    }
    
    return [PopTipView showInView:superView wihtTipText:tipStr bounds:textSize fontSize:14 withTimeInterval:interval];
    
}

+(instancetype)showInView:(UIView *)superView wihtTipText:(NSString *)tipStr bounds:(CGSize)bounds fontSize:(CGFloat)size withTimeInterval:(float)interval
{
    
    if (!superView) {
        superView = [[[UIApplication sharedApplication] delegate]window];
    }
    
    PopTipView * pop = [PopTipView checkPopViewWithSuperView:superView];
    if (pop) {
        [pop removeFromSuperview];
    }
    
    
    PopTipView *popView = nil;
    
    if (superView && [superView isKindOfClass:[UIView class]])
    {
        popView = [[PopTipView alloc] initWithFrame:CGRectMake(0, 0, bounds.width, bounds.height)];
        
        popView.tipLabel.numberOfLines = 0;

        popView.tipLabel.font = [UIFont systemFontOfSize:size];
        
        popView.tipLabel.text = tipStr;
        
        [popView.tipLabel setBackgroundColor:[UIColor clearColor]];
        
        [popView.tipLabel setTextAlignment:NSTextAlignmentCenter];

        [popView.layer setCornerRadius:8.f];
        popView.layer.masksToBounds = YES;
        popView.layer.borderWidth = 0;
        UIColor *borderColor = [UIColor whiteColor];
        popView.layer.borderColor = borderColor.CGColor;
        
        
        
        [superView addSubview:popView];
        
        popView.center = CGPointMake(superView.center.x, superView.bounds.size.height-150);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [popView removeFromSuperview];
            
        });
    }
    
    return popView;
}

+(instancetype)showInView:(UIView *)superView wihtNetWorkErrorTipText:(NSString *)tipStr
{
    return [PopTipView showInView:superView wihtTipText:tipStr bounds:CGSizeMake(FRANK_POPVIEW_NETWORKERROR_WIDTH, FRANK_POPVIEW_NETWORKERROR_HEIGHT) fontSize:17 withTimeInterval:2];
}

+(instancetype)showInView:(UIView *)superView wihtNetWorkExceptionTipText:(NSString *)tipStr
{
        return [PopTipView showInView:superView wihtTipText:tipStr bounds:CGSizeMake(FRANK_POPVIEW_NETWORKEXCEPTION_WIDTH, FRANK_POPVIEW_NETWORKEXCEPTION_HEIGHT) fontSize:17 withTimeInterval:2];
}

-(void)setTipLabelFontSize:(CGFloat)size
{
    [self.tipLabel setFont:[UIFont systemFontOfSize:size]];
    [self setNeedsDisplay];
}

/**
 *  检测当前界面上是否含有 PopTipView，确保只有一个view存在
 *
 *  @param view 父视图
 *
 *  @return 实例
 */
+(instancetype)checkPopViewWithSuperView:(UIView *)view{
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            return (PopTipView *)subview;
        }
    }
    return nil;
}

+ (CGSize)getSizeWithFont:(UIFont*)font textview:(BOOL)bTextView string:(NSString *)str
{
    NSDictionary *attribute = @{NSFontAttributeName: font};
    CGSize titleSize = [str sizeWithAttributes:attribute];
    if(bTextView)
        titleSize.height += 16;
    return titleSize;
    
}

//textview上下有8px的padding
+ (CGSize)getSizeWithFont:(UIFont*)font maxWidth:(NSInteger)width textview:(BOOL)bTextView string:(NSString *)str
{
    if(bTextView)
    {
        width -= 16;
    }
    CGSize maxSize=CGSizeMake(width, 99999);
    
    NSDictionary *attribute = @{NSFontAttributeName: font};
    CGSize strSize = [str boundingRectWithSize:maxSize options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    if(bTextView)
        strSize.height += 16;
    return strSize;
}


@end
