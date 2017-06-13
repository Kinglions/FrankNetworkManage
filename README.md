# FrankNetworkManage


<a href="#">注意：使用该框架前，需要集成 AFNetworking 和 FMDB，因为该框架是基于这两者进行的二次封装</a>
<h4>一：框架特点</h4><h6>1：基于`AFNetworking`封装处理，简化了对`AFNetworking`的直接操作，使调用更加方便简洁；
2：将`AFNetworking`原有的两种回调方式拓展为了三种回调，并且支持用户根据服务器数据格式进行配置，功能细化，操作简单；
3：结合`FMDB`封装了数据库，可以根据需要进行缓存网络数据；
4：集成了`Delegate`和`Block`两种网络回调方式，用户可以根据自己的喜好进行选择使用任意一种回调方式；</h6>
<a href="https://github.com/Kinglions/FrankNetworkManage">Demo链接：https://github.com/Kinglions/FrankNetworkManage</a>
<h4>二：框架解析</h4>

![框架截图.png](http://upload-images.jianshu.io/upload_images/1616138-661d9664e3eaa65c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
<h6>（1）网络请求框架：</h6>

```
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
 *    图片上传接口，若不指定baseurl，可传完整的url
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

```
其中需要注意的是`@property (nonatomic,copy) BOOL (^judgeResponseIsSuccess)(id responseSuccess) `属性，这个是根据后台的数据格式配置请求结果判断的回调，只需要在`AppDelegate`中进行配置一次就行。例如：
![配置示例.png](http://upload-images.jianshu.io/upload_images/1616138-cf1410326cdc0f45.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
<h6>（2）网络下载框架：</h6>

```
#import "FrankNetworkManage.h"

/**
 断点下载

 - DownloadStatus_ResumingDown: 开始下载
 - DownloadStatus_SuspendDown: 暂停下载
 */

typedef NS_ENUM(NSInteger ,DownloadStatus) {
    
    DownloadStatus_ResumingDown = 0,
    DownloadStatus_SuspendDown = 1,

};

@interface FrankHttpDownloadManage : FrankNetworkManage

/** AFNetworking断点下载（支持离线）需用到的属性 **********/
/** 
 文件的总长度
 */

@property (nonatomic,assign,readonly) NSInteger fileLength;

/** 
 当前下载长度
 */

@property (nonatomic,assign,readonly) NSInteger currentLength;

/**
 下载文件保存路径
 */

@property (nonatomic,copy,readonly)NSString * downSavePath;


/**
 *	下载文件操作
 *
 *	@param url						下载地址
 *	@param saveName               保存文件名字
 *	@param progressBlock			下载进度
 *	@param success                  下载成功回调
 *	@param failure					下载失败回调
 */

- (instancetype)initWithDownloadUrl:(NSString *)url
             saveName:(NSString *)saveName
               progress:(ReplyUploadProgress)progressBlock
                success:(ReplySucess)success
                failure:(ReplyError)failure;
/**
 下载状态
 
 - DownloadStatus_SuspendDown: 暂停下载
 - DownloadStatus_ResumingDown: 开始下载
 
 */

-(void)setDownloadStatus:(DownloadStatus)status;

@end
```

<h6>（3）请求类BaseModel类 ：</h6>
这个类是为了方便使用，而创建的一个基类框架，相当于在`ViewController`和`FrankNetworkManage`中间添加的一层，用于处理数据交互相关逻辑，所以后期创建具体请求类只需要集成该`BaseRequestHttpModel`类，重写父类方法即可。
代码解析：

```
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
 网络请求失败回调
 */

@property (nonatomic,copy)ReplyFailure failureBlock;

/**
 网络错误回调
 */

@property (nonatomic,copy)ReplyError networkerrBlock;

#pragma mark -------- 通过 代理 方式处理请求回调  ---------
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

```
<h6>注意点：</h6>
（1）当使用代理方式进行处理网络回调时，需要设置 `delegate`，调用请求方法

```
/**
 供子类调用 【  代理方式请求调用方法  】

 @param method 请求方式
 @param params 请求参数数据
 @param isNeedHeader 是否需要 请求头数据
 */

-(void)doRequestWithHttpMethod:(HTTP_REQUEST_METHOD)method
                        params:(id)params
            isNeedHeaderParams:(BOOL)isNeedHeader;
```
并且实现代理方法即可，后续的处理逻辑可以统一放在代理方法中进行处理

```
/**
 *  为了降低耦合性，通过这个协议方法可以在对请求状态进行判断
 *
 *  @param type      判断是哪一类发送的请求
 *  @param retStatus 请求成功失败的状态
 */

- (void)DoneBusiness:(enum BusinessHttpType)type status:(ResponseHttpType)retStatus
```
（2）当使用`block`回调进行处理网络回调时，只需要调用请求方法，对于每一个请求结果的处理都可以单独进行处理

```
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
```
但是不管是用那种方式，如果想要实现字典转模型，那都需要在子类中重写实现具体方法逻辑

```
/**
 之类需要根据自己的需求进行重写
 处理请求成功时，字典转模型的具体实现，并返回字典模型

 @param responseObject 响应数据
 @param requestParams 请求数据
 */

-(id)changeDateForModelWithResponseObject:(id)responseObject requestParams:(NSDictionary *)requestParams;
```
两种方式虽然方式不同，但是效果相同，所以只需要根据自己的喜好及业务需求进行选择使用即可。
<h6>（4）加载动画HUD展示：</h6>
这部分是加载动画hud，具体内容可移步 [FrankActivityHUD 动画](http://www.jianshu.com/p/e8399a35c7fb) 进行查看</br>
<h6>（5）设备信息加载工具 `DeviceManager`：</h6>
这部分主要是为了方便查看、获取一些设备信息而集成的一个工具单例类，功能如下：

```
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

//获取当前设备对应的height
#define Screen_height (MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width))
//获取当前设备对应的width
#define Screen_width (MIN([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width))
//用于判断设备是否为长屏幕iphone，比如iphone5，iphone6，iphone6plus
#define IS_4inchIPHONE ( !IS_IPHONE4 )
//用于判断设备是否为iphone4
#define IS_IPHONE4 ( fabs( ( double )Screen_height - ( double )480 ) < DBL_EPSILON )
//用于判断设备是否为iphone5
#define IS_IPHONE5s_SE ( fabs( ( double )Screen_height - ( double )568 ) < DBL_EPSILON )
//用于判断设备是否为iphone6\iphone6plus
#define IS_IPHONE6_7 ( fabs( ( double )Screen_height - ( double )667 ) < DBL_EPSILON )
//用于判断设备是否为iphone6plus
#define IS_IPHONE6_PLUS ( fabs( ( double )Screen_height - ( double )736 ) < DBL_EPSILON)
//用于判断设备是否为iphone6之后
#define IS_IPHONE6_OR_LATER (((double)Screen_height - (double )568) > DBL_EPSILON)

// 比当前版本大
#define NOT_LESS_THAN_IOSVERSION(version) ([[[UIDevice currentDevice] systemVersion] floatValue] >= version)
// ios7 之后
#define IOS7_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)
// ios8 之后
#define IOS8_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending)
// ios9 之后
#define IOS9_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"9.0" options:NSNumericSearch] != NSOrderedAscending)
// ios10 之后
#define IOS10_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"10.0" options:NSNumericSearch] != NSOrderedAscending)


@interface DeviceManage : NSObject


/**
 *  网络状态
 */

@property(nonatomic,copy)NSString * netWorkStatus;

/**
 *  设备系统版本
 */

@property (nonatomic, copy) NSString *systemVersion;

/**
 *   设备系统名
 */

@property (nonatomic,  copy) NSString *systemName;

/**
 *  机型
 */

@property (nonatomic,  copy) NSString *deviceModel;

/**
 *  设备名称（别名）
 */

@property (nonatomic,  copy) NSString *deviceName;

/**
 *  设备型号
 */

@property (nonatomic,  copy) NSString *deviceType;

/**
 *  手机总存储容量
 */

@property (nonatomic,  strong)NSString * totalDSB;

/**
 *  手机空闲存储容量
 */

@property (nonatomic,  strong)NSString * freeDSB;

/**
 *  手机总内存容量
 */

@property (nonatomic,  strong)NSString * totalMB;

/**
 *  手机空闲内存容量
 */

@property (nonatomic,  strong)NSString * freeMB;

/**
 *  cpu类型
 */

@property(nonatomic,strong)NSString * cpuType;

/**
 *  屏幕宽度
 */

@property (nonatomic, assign) CGFloat screenWidth;

/**
 *  屏幕高度
 */

@property (nonatomic, assign) CGFloat screenHeight;

/**
 *  分辨率
 */

@property (nonatomic, assign) CGFloat screenScale;

/**
 *  处理器（多核）
 */

@property (nonatomic, assign) NSInteger cpuCoreCount;

/**
 *  应用版本 【version】
 */

@property (nonatomic, strong) NSString *applicationMajorVersion;

/**
 *  最小版本 【build version】
 */

@property (nonatomic, strong) NSString *applicationMinorVersion;

/**
 *  当前应用名
 */

@property (nonatomic, strong) NSString *applicationDisplayName;

/**
 *  应用标识符
 */

@property (nonatomic, strong) NSString *applicationIdentifier;

/**
 *  启动状态
 */

@property (nonatomic, assign) NSInteger fetchLocationErrorCode;//-2--not started or OK, -1--in progress, >=0----failed

/**
 *  获取手机 IP 地址
 */

@property (nonatomic, strong) NSString * phoneIPAdress;

/**
 *   获取手机 Mac 地址
 */

@property (nonatomic, strong) NSString * phoneMacAddress;

/**
 *  获取单例对象
 */

+(DeviceManage *)shareDeviceManage;

@end

```
<h6>（6）数据库存储框架：</h6>
文件中包含三个类文件：
`（1）FrankFMDBManage：`是基于`FMDB`集成的数据库工具，隔离了`SQL语句`繁琐的操作，并且结合`runtime`实现了对象的直接存储操作，支持增、删、改、查、支持原始网络数据的存储
`（2）FrankUserDefaults：`是对 `NSUserDefaults`进行的一个简单封装，并且提供了不同类型数据的本地读写功能
`（3）NSString+Category：`是对`NSString`的一个分类，将一些常用的`NSString`功能方法进行封装，以便调用

具体的使用详情可参见  [Demo链接：  https://github.com/Kinglions/FrankNetworkManage](https://github.com/Kinglions/FrankNetworkManage)</br> 如有发现存在问题，希望可以及时提出，相互交流，共同进步