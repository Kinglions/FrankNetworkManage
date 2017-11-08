//
//  BaseRequestHttpModel.h
//  BarberProject
//
//  Created by 武玉宝 on 2017/6/1.
//  Copyright © 2017年 Frank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FrankNetworkMacro.h"



/**
 请求成功时返回的数据

 @param models 数据模型
 */
typedef void(^SuccessModel)(id models);


/**
 代理方式下的 网络请求结果状态

 - ResponseHttpType_Success: 请求成功
 - ResponseHttpType_Failure: 请求失败
 - ResponseHttpType_NetworkError: 网络异常
 */
typedef NS_ENUM(NSInteger,ResponseHttpType) {
    ResponseHttpType_Success,
    ResponseHttpType_Failure,
    ResponseHttpType_NetworkError,
};
/**
 代理方式下的 网络请求类型，枚举回调区分
 */
typedef NS_ENUM(NSInteger,BusinessHttpType) {
    
    BusinessHttpType_None = 0,// 默认状态
    BusinessHttpType_LoadWeather ,// 请求天气
    
    // 此处可以根据自己的工程需求进行添加枚举分类。。。
};

#pragma mark -------- 通过 代理 方式处理请求回调，当使用 block 方式处理时，可以忽略代理  ---------
@protocol BaseRequestHttpModelDelegate <NSObject>

@optional
/**
 *  为了降低耦合性，通过这个协议方法可以在对请求状态进行判断
 *
 *  @param type      判断是哪一类发送的请求
 *  @param retStatus 请求成功失败的状态
 */
- (void)DoneBusiness:(enum BusinessHttpType)type status:(ResponseHttpType)retStatus;

@end


@interface BaseRequestHttpModel : NSObject


/**
 请求地址
 */
@property (nonatomic,strong)NSString * urlStr;

/**
 请求头数据字典
 */
@property (nonatomic,strong)NSMutableDictionary * headerParams;
/**
 @return 类方法获取去求头数据
 */
+ (NSDictionary *)headerParams;

/**
 网络请求失败回调
 */
@property (nonatomic,copy)ReplyFailure failureBlock;
/**
 网络错误回调
 */
@property (nonatomic,copy)ReplyError networkerrBlock;

#pragma mark -------- 通过 代理 方式处理请求回调  ---------

/**
 设置网络请求代理【当使用 block 方式处理时，可以忽略代理】
 */
@property (nonatomic,weak)id <BaseRequestHttpModelDelegate>delegate;
/**
 网络请求API类型
 */
@property (nonatomic,assign) BusinessHttpType businessType;
/**
 告知当前网络处理状态
 */
-(void)doneBusiness:(ResponseHttpType)returnStatus;



/**
 供子类调用 【  代理方式请求调用方法  】
 
 @param method 请求方式
 @param params 请求参数数据
 @param isNeedHeader 是否需要 请求头数据
 */
-(void)doRequestWithHttpMethod:(HTTP_REQUEST_METHOD)method
                        params:(id)params
            isNeedHeaderParams:(BOOL)isNeedHeader;

#pragma mark -------- 通过 block 方式处理请求回调  ---------

/**
 供子类调用 【  代理方式请求调用方法  】
 
 @param method 请求方式
 @param params 请求参数数据
 @param isNeedHeader 是否需要 请求头数据
 @param success 成功回调数据模型
 @param fail 失败回调
 @param errorBlock 链接错误回调
 */
-(void)doRequestWithHttpMethod:(HTTP_REQUEST_METHOD)method
                        params:(id)params
        isNeedHeaderParams:(BOOL)isNeedHeader
                   success:(SuccessModel)success
                   failure:(ReplyFailure)fail
                  netError:(ReplyError)errorBlock;

#pragma mark -------- 根据自己的需求进行重写，数据转模型  ---------

/**
 之类需要根据自己的需求进行重写
 处理请求成功时，字典转模型的具体实现，并返回字典模型

 @param responseObject 响应数据
 @param requestParams 请求数据
 */
-(id)changeDateForModelWithResponseObject:(id)responseObject requestParams:(NSDictionary *)requestParams;

@end
