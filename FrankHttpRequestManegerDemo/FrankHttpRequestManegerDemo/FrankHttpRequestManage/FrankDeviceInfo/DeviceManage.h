//
//  DeviceManage.h
//  YNYBZ
//
//  Created by Frank on 16/4/17.
//  Copyright © 2016年 Frank.HAJK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

#define LOCALSUCCESS_NOTIFICATION @"local_success_notification"// 定位成功之后的通知

//获取当前设备对应的height
#define Screen_height (MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width))
//获取当前设备对应的width
#define Screen_width (MIN([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width))
//用于判断设备是否为长屏幕iphone，比如iphone5，iphone6，iphone6plus
#define IS_4inchIPHONE ( !IS_IPHONE4 )
//用于判断设备是否为iphone4
#define IS_IPHONE4 ( fabs( ( double )Screen_height - ( double )480 ) < DBL_EPSILON )
//用于判断设备是否为iphone5
#define IS_IPHONE5s_SE ( fabs( ( double )Screen_height - ( double )568 ) < DBL_EPSILON )
//用于判断设备是否为iphone6\iphone6plus
#define IS_IPHONE6_7 ( fabs( ( double )Screen_height - ( double )667 ) < DBL_EPSILON )
//用于判断设备是否为iphone6plus
#define IS_IPHONE6_PLUS ( fabs( ( double )Screen_height - ( double )736 ) < DBL_EPSILON)
//用于判断设备是否为iphone6之后
#define IS_IPHONE6_OR_LATER (((double)Screen_height - (double )568) > DBL_EPSILON)

// 比当前版本大
#define NOT_LESS_THAN_IOSVERSION(version) ([[[UIDevice currentDevice] systemVersion] floatValue] >= version)
// ios7 之后
#define IOS7_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)
// ios8 之后
#define IOS8_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending)
// ios9 之后
#define IOS9_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"9.0" options:NSNumericSearch] != NSOrderedAscending)
// ios10 之后
#define IOS10_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"10.0" options:NSNumericSearch] != NSOrderedAscending)


//typedef void(^BaiduMapBlock)(NSString *str);


@interface DeviceManage : NSObject


/**
 *  网络状态
 */
@property(nonatomic,copy)NSString * netWorkStatus;

/**
 *  设备系统版本
 */
@property (nonatomic, copy) NSString *systemVersion;
/**
 *   设备系统名
 */
@property (nonatomic,  copy) NSString *systemName;
/**
 *  机型
 */
@property (nonatomic,  copy) NSString *deviceModel;
/**
 *  设备名称（别名）
 */
@property (nonatomic,  copy) NSString *deviceName;
/**
 *  设备型号
 */
@property (nonatomic,  copy) NSString *deviceType;


/**
 *  手机总存储容量
 */
@property (nonatomic,  strong)NSString * totalDSB;
/**
 *  手机空闲存储容量
 */
@property (nonatomic,  strong)NSString * freeDSB;
/**
 *  手机总内存容量
 */
@property (nonatomic,  strong)NSString * totalMB;
/**
 *  手机空闲内存容量
 */
@property (nonatomic,  strong)NSString * freeMB;
/**
 *  cpu类型
 */
@property(nonatomic,strong)NSString * cpuType;



/**
 *  屏幕宽度
 */
@property (nonatomic, assign) CGFloat screenWidth;
/**
 *  屏幕高度
 */
@property (nonatomic, assign) CGFloat screenHeight;
/**
 *  分辨率
 */
@property (nonatomic, assign) CGFloat screenScale;
/**
 *  处理器（多核）
 */
@property (nonatomic, assign) NSInteger cpuCoreCount;
/**
 *  应用版本 【version】
 */
@property (nonatomic, strong) NSString *applicationMajorVersion;
/**
 *  最小版本 【build version】
 */
@property (nonatomic, strong) NSString *applicationMinorVersion;
/**
 *  当前应用名
 */
@property (nonatomic, strong) NSString *applicationDisplayName;
/**
 *  应用标识符
 */
@property (nonatomic, strong) NSString *applicationIdentifier;
/**
 *  启动状态
 */
@property (nonatomic, assign) NSInteger fetchLocationErrorCode;//-2--not started or OK, -1--in progress, >=0----failed
/**
 *  获取手机 IP 地址
 */
@property (nonatomic, strong) NSString * phoneIPAdress;
/**
 *   获取手机 Mac 地址
 */
@property (nonatomic, strong) NSString * phoneMacAddress;
/**
 *  获取单例对象
 */
+(DeviceManage *)shareDeviceManage;


@end
