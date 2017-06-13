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

        return;
        
    }
  
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    if (headerParams)
    {
        for (NSString * key in headerParams.allKeys)
        {
            [[FrankAPIClicent sharedClient].requestSerializer setValue:[NSString stringWithFormat:@"%@",headerParams[key]] forHTTPHeaderField:key];
        }
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
            NSLog(@"[FrankNetworkManage shareManager].judgeResponseSuccess 为实现请求的判断方法，请在AppDelegate中实现，否则回调结果可能存在差异");
            
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

+ (void)uploadWithImage:(UIImage *)image
                                   url:(NSString *)urlString
                              filename:(NSString *)filename
                                  name:(NSString *)name
                              mimeType:(NSString *)mimeType
                            parameters:(NSDictionary *)parameters
                              progress:(ReplyUploadProgress)progress
                               success:(ReplySucess)success
                                  fail:(ReplyError)fail {
    
    if (!urlString) {
        NSLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
        return;
    }
    
    urlString = [self absoluteUrlWithPath:urlString];
    
    if ([self shouldEncode]) {
        urlString = [self encodeUrl:urlString];
    }
    
    NSURLSessionTask * session =[[FrankAPIClicent sharedClient] POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        
        NSString *imageFileName = filename;
        if (filename == nil || ![filename isKindOfClass:[NSString class]] || filename.length == 0) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            imageFileName = [NSString stringWithFormat:@"%@.jpg", str];
        }
        
        // 上传图片，以文件流的格式
        [formData appendPartWithFileData:imageData name:name fileName:imageFileName mimeType:mimeType];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success)
        {
            success(task,responseObject,nil);
        }
       
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (fail)
        {
            fail(error,task,nil);
        }
        
    }];
    
    [session resume];
}
+ (void)uploadFileWithUrl:(NSString *)urlString
            uploadingFile:(NSString *)uploadingFile
                 progress:(ReplyUploadProgress)progress
                  success:(ReplySucess)success
                     fail:(ReplyError)fail {
    
    if (!urlString) {
        NSLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
        return;
    }
    
    urlString = [self absoluteUrlWithPath:urlString];
    
    if ([self shouldEncode]) {
        urlString = [self encodeUrl:urlString];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
     __block NSURLSessionDataTask *session = [[FrankAPIClicent sharedClient] uploadTaskWithRequest:request fromFile:[NSURL URLWithString:uploadingFile] progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        
        if (error) {
            
            if (fail)
            {
                fail(error,session,nil);
            }
            
        } else {
            
            if (success)
            {
                success(session,responseObject,nil);
            }
        }
    }];
    
}

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


