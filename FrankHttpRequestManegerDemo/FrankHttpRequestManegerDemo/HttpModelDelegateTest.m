//
//  HttpModelDelegateTest.m
//  FrankHttpRequestManegerDemo
//
//  Created by 武玉宝 on 2017/6/12.
//  Copyright © 2017年 Frank. All rights reserved.
//

#import "HttpModelDelegateTest.h"

@implementation HttpModelDelegateTest

-(instancetype)init{
    
    if (self = [super init]) {
        
        self.urlStr = @"microservice/weather?citypinyin=beijing";
        self.businessType = BusinessHttpType_LoadWeather;
    }
    return self;
}

-(void)doBusinessHttp{
    
    // 此处可以进行处理参数，然后传入请求
    
    [self doRequestWithHttpMethod:HTTP_REQUEST_METHOD_GET
                           params:nil
               isNeedHeaderParams:NO];
}

-(id)changeDateForModelWithResponseObject:(id)responseObject requestParams:(NSDictionary *)requestParams{
    
    // 根据工程需要进行数据模型转换
    
    return responseObject;
}

@end
