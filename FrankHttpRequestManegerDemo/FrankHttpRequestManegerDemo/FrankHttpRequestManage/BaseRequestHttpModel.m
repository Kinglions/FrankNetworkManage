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
            
//            NSString * value = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];
            
            NSString * errStr = [[error userInfo] objectForKey:@"NSDebugDescription"];
            
            [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {

                NSString *noteStr = nil;
                if ((status == AFNetworkReachabilityStatusUnknown) || (status == AFNetworkReachabilityStatusNotReachable)) {
                    noteStr = @"当前网络不可用，请检查您的网络设置";
                } else {
                    noteStr = @"连接服务器失败，请稍后重试";
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [FrankActivityHUD showWithText:errStr?errStr:noteStr shimmering:NO];
                });

            }];
            
        };
        
        
        self.failureBlock = ^(NSURLSessionDataTask *task, id responseObject, NSDictionary *requestParams) {
            

//            处理请求失败时，显示服务器返回的失败原因
            FrankLog(@"%@",responseObject);
            NSString * msg = responseObject[@"errMsg"];
            
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
    
#error ------ 根据自己服务器要求配置请求头信息  ------------

    [_headerParams setValue:@"value" forKey:@"key"];

    return _headerParams;
}
/**
 @return 类方法获取去求头数据
 */
+ (NSDictionary *)headerParams{
    
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]initWithCapacity:0];
    
#error ------ 根据自己服务器要求配置请求头信息  ------------

    [dic setValue:@"value" forKey:@"key"];
    
    return dic;
}

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
