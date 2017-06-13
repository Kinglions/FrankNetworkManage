//
//  ViewController.m
//  FrankHttpRequestManegerDemo
//
//  Created by Frank on 2017/6/12.
//  Copyright © 2017年 Frank. All rights reserved.
//

#import "ViewController.h"
#import "HttpModelDelegateTest.h"
#import "HttpModelBlockTest.h"

@interface ViewController ()<BaseRequestHttpModelDelegate>

@property (nonatomic,strong)HttpModelBlockTest * httpBlock;

@property (nonatomic,strong)HttpModelDelegateTest * httpDelegate;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
}

-(HttpModelDelegateTest *)httpDelegate{
    if (!_httpDelegate) {
        _httpDelegate = [[HttpModelDelegateTest alloc] init];
        _httpDelegate.delegate = self;
    }
    return _httpDelegate;
}
-(HttpModelBlockTest *)httpBlock{
    if (!_httpBlock) {
        _httpBlock = [[HttpModelBlockTest alloc] init];
    }
    return _httpBlock;
}
#pragma mark -----  通过代理方法进行处理网络请求回调  ----------
- (IBAction)delegateBtnClick:(id)sender {
    
    [self.httpDelegate doBusinessHttp];
    
}
/// 代理方法
-(void)DoneBusiness:(enum BusinessHttpType)type status:(ResponseHttpType)retStatus{
    if (type == BusinessHttpType_LoadWeather) {
        
        switch (retStatus) {
            case ResponseHttpType_Success:
            {
                FrankLog(@"delegate --- 成功");
            }
                break;
            case ResponseHttpType_Failure:
            {
                FrankLog(@"delegate --- 失败");
            }
                break;
            case ResponseHttpType_NetworkError:
            {
                FrankLog(@"delegate --- 错误");
            }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark -----  通过 Block 方法进行处理网络请求回调  ----------

- (IBAction)blockBtnClick:(id)sender {
    
    [self.httpBlock doRequestWithHttpMethod:HTTP_REQUEST_METHOD_GET
                                     params:nil
                         isNeedHeaderParams:NO
                                    success:^(id models) {
                                        FrankLog(@"block --- 成功");

                                    } failure:^(NSURLSessionDataTask *task, id responseObject, NSDictionary *requestParams) {
                                        FrankLog(@"block --- 失败");

                                    } netError:^(NSError *error, NSURLSessionDataTask *task, NSDictionary *requestParams) {
                                        FrankLog(@"block --- 错误");

                                    }];
}

@end
