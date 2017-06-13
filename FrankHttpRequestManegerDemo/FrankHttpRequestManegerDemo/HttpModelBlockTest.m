//
//  HttpModelBlockTest.m
//  FrankHttpRequestManegerDemo
//
//  Created by 武玉宝 on 2017/6/12.
//  Copyright © 2017年 Frank. All rights reserved.
//

#import "HttpModelBlockTest.h"

@implementation HttpModelBlockTest

-(instancetype)init{
    
    if (self = [super init]) {
        
        self.urlStr = @"microservice/weather?citypinyin=beijing";
        self.businessType = BusinessHttpType_LoadWeather;
    }
    return self;
}

-(id)changeDateForModelWithResponseObject:(id)responseObject requestParams:(NSDictionary *)requestParams{
    
    // 根据工程需要进行数据模型转换
    
    return responseObject;
}


@end
