//
//  FrankNetworkManage.h
//  FrankAFNetWorking
//
//  Created by 武玉宝 on 16/1/24.
//  Copyright © 2016年 Frank. All rights reserved.
//


/**
 *  网络请求封装
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AFNetworking.h>
#import <AFNetworking/AFURLSessionManager.h>
#import "FrankNetworkMacro.h"

typedef void (^RequestPrepare)();
typedef void (^RequestFinally)();

/**
 请求成功回调

 @param task 请求对象
 @param responseObject 响应数据
 @param requestParams 请求参数
 */

typedef void (^ReplySucess)(NSURLSessionDataTask *task, id responseObject, NSDictionary* requestParams);

/**
 请求失败回调
 */

typedef void (^ReplyFailure)(NSURLSessionDataTask *task, id responseObject, NSDictionary* requestParams);

/**
 请求错误回调
 */

typedef void (^ReplyError)(NSError *error, NSURLSessionDataTask *task, NSDictionary* requestParams);

/*  上传进度
 *
 *  @param bytesWritten              已上传的大小
 *  @param totalBytesWritten         总上传大小
 */

typedef void (^ReplyUploadProgress)(int64_t bytesWritten,int64_t totalBytesWritten);



typedef void (^MultipartData)(id <AFMultipartFormData> formData);

/**
 基础网络请求 其他的请求统一由此类发出

 - HTTP_REQUEST_METHOD_GET:
 - HTTP_REQUEST_METHOD_HEAD:
 - HTTP_REQUEST_METHOD_POST:
 - HTTP_REQUEST_METHOD_PUT:
 - HTTP_REQUEST_METHOD_PATCH:
 - HTTP_REQUEST_METHOD_DELETE:
 */

typedef NS_ENUM(NSUInteger, HTTP_REQUEST_METHOD) {
    
    HTTP_REQUEST_METHOD_GET = 0,
    HTTP_REQUEST_METHOD_HEAD,
    HTTP_REQUEST_METHOD_POST,
    HTTP_REQUEST_METHOD_PUT,
    HTTP_REQUEST_METHOD_PATCH,
    HTTP_REQUEST_METHOD_DELETE,
};

/**
 网络请求缓存处理

 - NetworkCacheType_Never: 重不进行缓存处理
 - NetworkCacheType_OnlyCache: 只进行缓存，但是不读取
 - NetworkCacheType_CacheAndLoad: 进行缓存，并且请求数据时先进行加载缓存，本次请求数据，下次加载
 */

typedef NS_ENUM(NSUInteger, NetworkCacheType) {
    
    NetworkCacheType_Never = 0,
    NetworkCacheType_OnlyCache,
    NetworkCacheType_CacheAndLoad,

};


@interface FrankNetworkManage : NSObject

/**
 *  创建单例对象
 */

+(instancetype)shareManager;

/**
 网络数据的缓存处理类型
 */

@property (nonatomic,assign)NetworkCacheType cacheType;

/**
 *  判断请求时是否需要 hud
 */

@property (nonatomic, assign) BOOL isShowHUD;

/**
 *  请求之前的准备，可直接调用本类对象的 prepare
 */

@property (nonatomic, copy) RequestPrepare prepare;

/**
 *  一个网络请求返回后做清理。
 */
@property (nonatomic,copy) RequestFinally finally;
/**
 *  网络请求返回成功
 */
@property (nonatomic, copy) ReplySucess sucess;

/**
 *  失败
 */
@property (nonatomic, copy) ReplyFailure failure;
/**
 *  请求出错
 */
@property (nonatomic, copy) ReplyError error;

/**
 共外界调用配置 判断逻辑【根据服务器返回值进行配置，可以在 Appdelegate 中进行设置】
 *
 *  @return YES 表示数据正确，NO 表示后台的错误提示，证明返回有误
 */
@property (nonatomic,copy) BOOL (^judgeResponseIsSuccess)(id responseSuccess);
/*
 *
 *  用于指定网络请求接口的基础url，如：
 *  http://www.baudu.com
 *  通常在AppDelegate中启动时就设置一次就可以了。
    如果接口有来源于多个服务器，可以调用更新
 *
 *
 *  @param baseUrl 网络接口的基础url
 */
+ (void)updateBaseUrl:(NSString *)baseUrl;
/*
 *  对外公开可获取当前所设置的网络接口基础url
 *
 *  @return 当前基础url
 */
+ (NSString *)baseUrl;
/**
 进行编码
 */
+ (NSString *)encodeUrl:(NSString *)url;
/**
 自动判断 baseurl 并进行组合 url
 */
+ (NSString *)absoluteUrlWithPath:(NSString *)path;


/**
 *  统一网络请求
 *
 *  @param method      请求类型（直接调用 枚举）
 *  @param urlString    请求URLString
 *  @param headerParams 请求头添加的参数
 *  @param params       请求参数
 *  @param finally      请求结束，进行清理（直接调用）
 *  @param sucess       请求成功，数据正常
 *  @param failure      请求失败
 *  @param netError      请求连接错误
 */
+(void)httpRequestWithHttpMethod:(HTTP_REQUEST_METHOD)method
                       urlString:(NSString *)urlString
                    headerParams:(NSDictionary *)headerParams
                          params:(id)params
                         finally:(RequestFinally)  finally
                          sucess:(ReplySucess)   sucess
                         failure:(ReplyFailure)  failure
                           error:(ReplyError)netError;




/*
 *
 *  开启或关闭是否自动将URL使用UTF8编码，用于处理链接中有中文时无法请求的问题
 *
 *  @param shouldAutoEncode YES or NO,默认为NO
 */
+ (void)shouldAutoEncodeUrl:(BOOL)shouldAutoEncode;


/*
 *	图片上传接口，若不指定baseurl，可传完整的url
 *
 *	@param image			图片对象
 *	@param url				上传图片的接口路径，如/path/images/
 *	@param filename		给图片起一个名字，默认为当前日期时间,格式为"yyyyMMddHHmmss"，后缀为`jpg`
 *	@param name				与指定的图片相关联的名称，这是由后端写接口的人指定的，如imagefiles
 *	@param mimeType		默认为image/jpeg
 *	@param parameters	参数
 *	@param progress		上传进度
 *	@param success		上传成功回调
 *	@param fail				上传失败回调
 *
 *	@return
 */

+ (void)uploadWithImage:(UIImage *)image
                    url:(NSString *)url
               filename:(NSString *)filename
                   name:(NSString *)name
               mimeType:(NSString *)mimeType
             parameters:(NSDictionary *)parameters
               progress:(ReplyUploadProgress)progress
                success:(ReplySucess)success
                   fail:(ReplyError)fail;

/**
 *	上传文件操作
 *
 *	@param url						上传路径
 *	@param uploadingFile	待上传文件的路径
 *	@param progress			上传进度
 *	@param success				上传成功回调
 *	@param fail					上传失败回调
 *
 */
+ (void)uploadFileWithUrl:(NSString *)url
            uploadingFile:(NSString *)uploadingFile
                 progress:(ReplyUploadProgress)progress
                  success:(ReplySucess)success
                     fail:(ReplyError)fail;




@end


