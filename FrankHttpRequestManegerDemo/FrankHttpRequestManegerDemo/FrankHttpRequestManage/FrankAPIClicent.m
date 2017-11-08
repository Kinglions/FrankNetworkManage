//
//  FrankAPIClicent.m
//  YNYBZ
//
//  Created by Frank on 16/4/3.
//  Copyright © 2016年 Frank.HAJK. All rights reserved.
//

#import "FrankAPIClicent.h"

@implementation FrankAPIClicent

+ (instancetype)sharedClient
{
    static FrankAPIClicent *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:nil];
                
        _sharedClient.requestSerializer.HTTPShouldHandleCookies = YES;
        [_sharedClient.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        _sharedClient.requestSerializer.timeoutInterval = 30.f;
        [_sharedClient.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        
        [_sharedClient.operationQueue setMaxConcurrentOperationCount:1];
        

        
    });
    return _sharedClient;
}

- (void)responseForJson{
    
    self.responseSerializer = [AFJSONResponseSerializer serializer];

    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/json", @"text/html", @"text/javascript", nil];
    
    /// 移除服务器返回的  Null 值，保证系统数据值的安全 ；同样可以使用 NullSafe 库进行处理
    ((AFJSONResponseSerializer *)self.responseSerializer).removesKeysWithNullValues = YES;
}
- (void)responseForXML{
    
    self.responseSerializer = [AFXMLParserResponseSerializer serializer];
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/xml", @"text/xml", @"text/javascript", @"text/html", nil];
}

@end
