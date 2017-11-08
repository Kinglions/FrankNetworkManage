//
//  FrankNetworkManage.m
//  FrankAFNetWorking
//
//  Created by 武玉宝 on 16/1/24.
//  Copyright © 2016年 Frank. All rights reserved.
//

#import "FrankNetworkManage.h"
#import <AFNetworkActivityIndicatorManager.h>


static NSString * WYB_privateNetworkBaseUrl = nil;
static BOOL WYB_shouldAutoEncode = NO;
static NSDictionary * WYB_httpHeaders = nil;

static AFNetworkReachabilityStatus networkStatus;


@interface FrankNetworkManage ()

/**
 完整的 url
 */
@property (nonatomic,copy)NSString * abUrl;

@end

@implementation FrankNetworkManage

/**
 *  创建单例对象
 */
+(instancetype)shareManager{
    
    static dispatch_once_t onceToken;
    static FrankNetworkManage * manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[FrankNetworkManage alloc] init];
        
        [DeviceManage shareDeviceManage];
    });
    return manager;
}


- (void)doNotHUD{
    self.isShowHUD = YES;
}

+ (void)updateBaseUrl:(NSString *)baseUrl
{
    WYB_privateNetworkBaseUrl = baseUrl;
}

+ (NSString *)baseUrl
{
    return WYB_privateNetworkBaseUrl;
}

+ (void)shouldAutoEncodeUrl:(BOOL)shouldAutoEncode {
    WYB_shouldAutoEncode  = shouldAutoEncode;
}

+ (BOOL)shouldEncode {
    return WYB_shouldAutoEncode;
}

/**
 *  ios 9.0 之后，使用该方法对字符串进行编码
 */
+ (NSString *)encodeUrl:(NSString *)url {
    return [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

/**
 * 开启监测网络状态
 *
 * @param enabled - YES：开启监测；NO：关闭
 */
+ (void)monitoringNetworkReachability:(BOOL)enabled
{
    if (enabled) {
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            networkStatus = status;
            NSString *noteStr = nil;
            switch (status) {
                case AFNetworkReachabilityStatusNotReachable:
                {
                    noteStr = @"当前没有网络";
                }
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                {
                    noteStr = @"当前使用手机数据网络";
                }
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                {
                    noteStr = @"当前使用 WiFi 网络";
                }
                    break;
                case AFNetworkReachabilityStatusUnknown:
                    
                default:
                {
                    noteStr = @"未知网络连接";
                }
                    break;
            }
            
            [PopTipView showInView:nil wihtTipText:noteStr];

            
        }];
        
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    } else {
        [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    }
}

+ (void)showNetworkActivityIndication:(BOOL)enabled;
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:enabled];
}




+ (NSString *)stringWithMethod:(HTTP_REQUEST_METHOD)method {
    switch (method) {
        case HTTP_REQUEST_METHOD_GET:     return @"GET";      break;
        case HTTP_REQUEST_METHOD_HEAD:    return @"HEAD";     break;
        case HTTP_REQUEST_METHOD_POST:    return @"POST";     break;
        case HTTP_REQUEST_METHOD_PUT:     return @"PUT";      break;
        case HTTP_REQUEST_METHOD_PATCH:   return @"PATCH";    break;
        case HTTP_REQUEST_METHOD_DELETE:  return @"DELETE";   break;
        default:
            break;
    }
    return @"";
}

+(void)httpRequestWithHttpMethod:(HTTP_REQUEST_METHOD)method
                       urlString:(NSString *)urlString
                    headerParams:(NSDictionary *)headerParams
                          params:(id)params
                         finally:(RequestFinally)  finally
                          sucess:(ReplySucess)   sucess
                         failure:(ReplyFailure)  failure
                           error:(ReplyError)netError{
    
    [FrankNetworkManage httpRequestWithHttpMethod:method
                                 responseDataType:HTTP_RESPONSE_TYPE_JSON
                                        urlString:urlString
                                     headerParams:headerParams
                                           params:params
                                          finally:failure
                                           sucess:sucess
                                          failure:failure
                                            error:netError];
}

+(void)httpRequestWithHttpMethod:(HTTP_REQUEST_METHOD)method
                responseDataType:(HTTP_RESPONSE_TYPE)responseDataType
                       urlString:(NSString *)urlString
                    headerParams:(NSDictionary *)headerParams
                          params:(id)params
                         finally:(RequestFinally)  finally
                          sucess:(ReplySucess)   sucess
                         failure:(ReplyFailure)  failure
                           error:(ReplyError)netError{
    

    [FrankNetworkManage shareManager].finally = finally;
    [FrankNetworkManage shareManager].sucess = sucess;
    [FrankNetworkManage shareManager].failure = failure;
    [FrankNetworkManage shareManager].error = netError;
    
    if (!urlString) {
        NSLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
        return;
    }    
    
    urlString = [self absoluteUrlWithPath:urlString];
    
    if ([self shouldEncode]) {
        urlString = [self encodeUrl:urlString];
    }
    
    
    [FrankNetworkManage shareManager].abUrl = urlString;
    
    if (![FrankNetworkManage shareManager].isShowHUD) {
        
        [FrankActivityHUD showWithType:FrankActivityHUDShowIndicatorType_LeadingDots isShowLodingTitle:YES];
    }
    // 预加载缓存数据
    if ([FrankNetworkManage shareManager].cacheType == NetworkCacheType_CacheAndLoad) {
        
        NSDictionary * dict = [[FrankFMDBManage shareInstance] loadNetWorkCacheDataWithTableName:urlString paramsKey:params];
        
        [[FrankNetworkManage shareManager] completionHandlerWithTask:nil responseData:dict requestParams:params error:nil];
        
    }
  
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

    
//    处理请求头数据
    if (headerParams)
    {
        for (NSString * key in headerParams.allKeys)
        {
            [[FrankAPIClicent sharedClient].requestSerializer setValue:[NSString stringWithFormat:@"%@",headerParams[key]] forHTTPHeaderField:key];
        }
    }
    
    if (responseDataType == HTTP_RESPONSE_TYPE_JSON) {
        
        [[FrankAPIClicent sharedClient] responseForJson];
    }else if (responseDataType == HTTP_RESPONSE_TYPE_XML){
        
        [[FrankAPIClicent sharedClient] responseForXML];
    }
    
    NSStringEncoding oldStringEncoding = [FrankAPIClicent sharedClient].requestSerializer.stringEncoding;
    [FrankAPIClicent sharedClient].requestSerializer.HTTPShouldHandleCookies = YES;
    [FrankAPIClicent sharedClient].requestSerializer.stringEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    NSError *serializationError = nil;
    //初始化请求
    NSString *urlStr = [[NSURL URLWithString:urlString relativeToURL:[FrankAPIClicent sharedClient].baseURL] absoluteString];
    NSString *methodStr = [FrankNetworkManage stringWithMethod:method];
    NSMutableURLRequest *request = [[FrankAPIClicent sharedClient].requestSerializer requestWithMethod:methodStr URLString:urlStr parameters:params error:&serializationError];
    
    
    if (serializationError) {
        if (netError) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async([FrankAPIClicent sharedClient].completionQueue ?: dispatch_get_main_queue(), ^{
                netError(serializationError,nil,params);
            });
#pragma clang diagnostic pop
        }
    }
    
    __block NSURLSessionDataTask *task = nil;
    task = [[FrankAPIClicent sharedClient] dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
       

        [[FrankNetworkManage shareManager] completionHandlerWithTask:task responseData:responseObject requestParams:params error:error];

    }];
    
    [FrankAPIClicent sharedClient].requestSerializer.stringEncoding = oldStringEncoding;
    [task resume];// 发起网络请求
    
}
-(void)completionHandlerWithTask:(NSURLSessionDataTask *)task responseData:(id  _Nullable )responseObject requestParams:(id  _Nullable )requestParams error:(NSError * _Nullable)error{

    FrankLog(@"\n请求地址：%@ \n请求参数：%@ \n\n返回数据：%@\n\n",self.abUrl,requestParams,responseObject);
    
    
    if ([FrankNetworkManage shareManager].isShowHUD) {
        [FrankNetworkManage shareManager].isShowHUD = NO;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [FrankActivityHUD dismiss];
    });
    
    
    if (error) {
        
        if (self.error)
        {
            self.error(error,task,requestParams);
        }
    }else{
        // 先检测是否实现了 成功判断的回调方法
        if (![FrankNetworkManage shareManager].judgeResponseIsSuccess || ![FrankNetworkManage shareManager].judgeResponseIsSuccess(responseObject))
        {
            if (self.failure)
            {
                self.failure(task,responseObject,requestParams);
            }
            
        }else
        {
            FrankLog(@"\n[FrankNetworkManage shareManager].judgeResponseSuccess 为实现请求的判断方法，请在AppDelegate中实现，不实现的话，block回调结果可能存在差异\n");
            
            if (self.sucess)
            {
                if (self.cacheType != NetworkCacheType_Never) {
                    [[FrankFMDBManage shareInstance] cacheNetWorkDataWithTableName:self.abUrl paramsKey:requestParams valueData:responseObject];
                }
                self.sucess(task,responseObject,requestParams);
            }
        }
    }
}

+ (void)uploadWithImage:(id)imageData
                    url:(NSString *)urlString
               filename:(NSString *)fileName
                   name:(NSString *)name
               mimeType:(NSString *)mimeType
             parameters:(NSDictionary *)params
               progress:(ReplyUploadProgress)progress
                 sucess:(ReplySucess)sucess
                failure:(ReplyFailure)failure
                  error:(ReplyError)netError{

    [FrankNetworkManage shareManager].sucess = sucess;
    [FrankNetworkManage shareManager].failure = failure;
    [FrankNetworkManage shareManager].error = netError;
    
    if (!urlString) {
        FrankLog(@"URLString无效，无法生成URL。");
        return;
    }
    
    urlString = [self absoluteUrlWithPath:urlString];
    
    if ([self shouldEncode]) {
        urlString = [self encodeUrl:urlString];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString * placeName  = [formatter stringFromDate:[NSDate date]];
    
    if (fileName == nil || ![fileName isKindOfClass:[NSString class]] || fileName.length == 0) {
        fileName = placeName;
    }
    if (name == nil || ![name isKindOfClass:[NSString class]] || name.length == 0) {
        name = placeName;
    }
    
    NSURLSessionTask * session =[[FrankAPIClicent sharedClient] POST:urlString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
       
        
        if ([imageData isKindOfClass:[NSData class]]) {
            
            [formData appendPartWithFileData:imageData name:name fileName:fileName mimeType:mimeType];
            
        } else if ([imageData isKindOfClass:[UIImage class]]) {
            
            NSData *data = [UIImagePNGRepresentation(imageData) length]>102400?UIImageJPEGRepresentation(imageData, 0.7):UIImagePNGRepresentation(imageData);
            
            [formData appendPartWithFileData:data name:name fileName:[NSString stringWithFormat:@"%@.png",fileName] mimeType:@"image/png"];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[FrankNetworkManage shareManager] completionHandlerWithTask:task responseData:responseObject requestParams:params error:nil];

       
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [[FrankNetworkManage shareManager] completionHandlerWithTask:task responseData:nil requestParams:params error:error];
        
    }];
    
    [session resume];
}


//+ (void)uploadFileWithUrl:(NSString *)urlString
//            uploadingFile:(NSString *)uploadingFile
//                 progress:(ReplyUploadProgress)progress
//                  success:(ReplySucess)success
//                     fail:(ReplyError)fail {
//    
//    if (!urlString) {
//        FrankLog(@"URLString无效，无法生成URL");
//        return;
//    }
//    
//    urlString = [self absoluteUrlWithPath:urlString];
//    
//    if ([self shouldEncode]) {
//        urlString = [self encodeUrl:urlString];
//    }
//    
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//    
//     __block NSURLSessionDataTask *session = [[FrankAPIClicent sharedClient] uploadTaskWithRequest:request fromFile:[NSURL URLWithString:uploadingFile] progress:^(NSProgress * _Nonnull uploadProgress) {
//        if (progress) {
//            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
//        }
//    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//        
//        
//        if (error) {
//            
//            if (fail)
//            {
//                fail(error,session,nil);
//            }
//            
//        } else {
//            
//            if (success)
//            {
//                success(session,responseObject,nil);
//            }
//        }
//    }];
//    
//}

/**
 自动判断 baseurl 并进行组合 url
 */
+ (NSString *)absoluteUrlWithPath:(NSString *)path {
    if (path == nil || path.length == 0) {
        return @"";
    }
    
    if ([self baseUrl] == nil || [[self baseUrl] length] == 0) {
        return path;
    }
    
    NSString *absoluteUrl = path;
    
    if (![path hasPrefix:@"http://"] && ![path hasPrefix:@"https://"]) {
        if ([[self baseUrl] hasSuffix:@"/"]) {
            if ([path hasPrefix:@"/"]) {
                NSMutableString * mutablePath = [NSMutableString stringWithString:path];
                [mutablePath deleteCharactersInRange:NSMakeRange(0, 1)];
                absoluteUrl = [NSString stringWithFormat:@"%@%@",
                               [self baseUrl], mutablePath];
            } else {
                absoluteUrl = [NSString stringWithFormat:@"%@%@",[self baseUrl], path];
            }
        } else {
            if ([path hasPrefix:@"/"]) {
                absoluteUrl = [NSString stringWithFormat:@"%@%@",[self baseUrl], path];
            } else {
                absoluteUrl = [NSString stringWithFormat:@"%@/%@",
                               [self baseUrl], path];
            }
        }
    }
    
    return absoluteUrl;
}


@end


