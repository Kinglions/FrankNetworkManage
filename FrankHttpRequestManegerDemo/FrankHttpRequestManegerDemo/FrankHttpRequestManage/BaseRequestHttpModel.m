//
//  BaseRequestHttpModel.m
//  BarberProject
//
//  Created by 武玉宝 on 2017/6/1.
//  Copyright © 2017年 Frank. All rights reserved.
//

#import "BaseRequestHttpModel.h"

@implementation BaseRequestHttpModel


-(instancetype)init
{
    self = [super init];
    
    if(self)
    {
        _businessType = BusinessHttpType_None;
        
        self.networkerrBlock = ^(NSError *error, NSURLSessionDataTask *task, NSDictionary *requestParams) {
            
            FrankLog(@"error");
            
            //#error ------ 根据自己服务器返回的数据结构进行解析处理  ------------

            NSString * value = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];
            
            NSString * errStr = [[error userInfo] objectForKey:@"NSDebugDescription"];
            
            if (value)
            {
                [FrankActivityHUD showWithText:errStr?errStr:@"网络异常，请稍后再试" shimmering:NO];
                
            }else{
                [FrankActivityHUD showWithText:@"服务器异常,请稍后再试" shimmering:NO];
                
            }
        };
        
        
        self.failureBlock = ^(NSURLSessionDataTask *task, id responseObject, NSDictionary *requestParams) {
            
            //#error ------ 根据自己服务器返回的数据结构进行解析处理  ------------

            FrankLog(@"%@",responseObject);
            NSString * msg = responseObject[@"errMsg"];
            if ([msg isEqualToString:@"token or code fail"]) {
                msg = @"该账号验证信息失效，需重新登录验证";
            }
            
            if (msg) {
                
                [FrankActivityHUD showWithText:msg shimmering:NO];
            }
            
        };
    }
    
    return self;
}
/**
 *  加载header
 */
-(NSMutableDictionary *)headerParams
{
    if (!_headerParams)
    {
        _headerParams = [[NSMutableDictionary alloc]initWithCapacity:0];
        
    }
    [_headerParams removeAllObjects];// 移除所有数据
    
//#error ------ 根据自己服务器要求配置请求头信息  ------------

    NSString * token = [[FrankUserDefaults share] FrankObjectForKey:@"token"];
    
    NSString * code = [[FrankUserDefaults share] FrankObjectForKey:@"code"];
    
    if (token) {
        [_headerParams setObject:token forKey:@"token"];
    }
    if (code) {
        [_headerParams setObject:code forKey:@"code"];
    }
    
    if (_headerParams.count == 2) {
        
        return _headerParams;
    }
    
    return nil;
}
#pragma mark -------- 通过 代理 方式处理请求回调  ---------
#pragma mark -------- 通过 代理 方式处理请求回调  ---------

-(void)doneBusiness:(ResponseHttpType)returnStatus
{
    if (_businessType != BusinessHttpType_None)
    {
        
        if (_delegate != nil) { // 代理没有被释放
            
            if([_delegate respondsToSelector:@selector(DoneBusiness:status:)])
            {
                [self.delegate DoneBusiness:_businessType status:returnStatus];
            }
        }
    }
}


-(void)doRequestWithHttpMethod:(HTTP_REQUEST_METHOD)method params:(id)params isNeedHeaderParams:(BOOL)isNeedHeader{
    
    [self doRequestWithHttpMethod:method params:params isNeedHeaderParams:isNeedHeader success:nil failure:nil netError:nil];
}
#pragma mark -------- 通过 block 方式处理请求回调  ---------
#pragma mark -------- 通过 block 方式处理请求回调  ---------
/**
 供子类调用
 
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
                  netError:(ReplyError)errorBlock{
    
    [FrankNetworkManage httpRequestWithHttpMethod:method
                                            urlString:self.urlStr
                                         headerParams:isNeedHeader?self.headerParams:nil
                                               params:params
                                              finally:nil
                                               sucess:^(NSURLSessionDataTask *task, id responseObject, NSDictionary *requestParams) {
                                                   
                                                   FrankLog(@"%@",responseObject);
                                                   NSDictionary * item = [self changeDateForModelWithResponseObject:responseObject requestParams:requestParams];
                                                   // block 回调通知
                                                   if (success) {
                                                       success(item);
                                                   }
                                                   // 代理通知
                                                   [self doneBusiness:ResponseHttpType_Success];
                                                   
                                               } failure:^(NSURLSessionDataTask *task, id responseObject, NSDictionary *requestParams) {
                                                   
                                                   // 处理响应提示
                                                   self.failureBlock(task, responseObject, requestParams);
                                                   
                                                   // block 回调通知
                                                   if (fail) {
                                                       fail(task,responseObject,requestParams);
                                                   }
                                                   // 代理通知
                                                   [self doneBusiness:ResponseHttpType_Failure];
                                                   
                                               } error:^(NSError *error, NSURLSessionDataTask *task, NSDictionary *requestParams) {
                                                   
                                                // 处理响应提示
                                                   self.networkerrBlock(error, task, requestParams);
                                                   // block 回调通知
                                                   if (errorBlock) {
                                                       errorBlock(error,task,requestParams);
                                                   }
                                                   // 代理通知
                                                   [self doneBusiness:ResponseHttpType_NetworkError];

                                               }];
    
}

-(id)changeDateForModelWithResponseObject:(id)responseObject requestParams:(NSDictionary *)requestParams{
    
    return responseObject;
}

@end
