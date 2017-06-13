//
//  FrankHttpDownloadManage.m
//  PlaceHolderView
//
//  Created by Frank on 2017/5/27.
//  Copyright © 2017年 Frank. All rights reserved.
//

#import "FrankHttpDownloadManage.h"

@interface FrankHttpDownloadManage ()


/** AFNetworking断点下载（支持离线）需用到的属性 **********/
/**
 文件的总长度
 */
@property (nonatomic,assign) NSInteger fileLength;
/**
 当前下载长度
 */
@property (nonatomic,assign) NSInteger currentLength;
/**
 下载地址
 */
@property (nonatomic,copy)NSString * urlStr;
/**
 下载文件名字
 */
@property (nonatomic,copy)NSString * saveName;
/**
 下载进度
 */
@property (nonatomic,copy)ReplyUploadProgress progressBlock;

/**
 文件句柄对象
 */
@property (nonatomic,strong) NSFileHandle *fileHandle;
/**
 下载状态
 */
@property (nonatomic,assign)DownloadStatus downStatus;
/**
 会话管理者
 */
@property (nonatomic,strong)AFHTTPSessionManager * manager;

/**
 下载任务
 */
@property (nonatomic, strong) NSURLSessionDownloadTask * downloadTask;

@end

@implementation FrankHttpDownloadManage

/**
 * manager的懒加载
 */
- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        // 1. 创建会话管理者
        _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/json", @"text/html", @"text/javascript",@"application/octet-stream", nil];
        
        _manager.requestSerializer.HTTPShouldHandleCookies = YES;
        
        [_manager.operationQueue setMaxConcurrentOperationCount:1];
        
        /// 移除服务器返回的  Null 值，保证系统数据值的安全 ；同样可以使用 NullSafe 库进行处理
//        ((AFJSONResponseSerializer *)_manager.responseSerializer).removesKeysWithNullValues = YES;
        
    }
    return _manager;
}
/**
 * manager的懒加载
 */
-(NSString *)downSavePath{
    
    return [self getPathWithName:self.saveName];
}
-(NSString *)getPathWithName:(NSString *)name{
    
    NSFileManager *fm =[NSFileManager defaultManager];
    //文件夹路径
    NSString *directoryPath =[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Download"];
    //判断有没有文件夹
    if (![fm fileExistsAtPath:directoryPath])
    {
        [fm createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //文件路径
    NSString *filePath =[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",name]];
    
    //文件
    if (![fm fileExistsAtPath:filePath])
    {
        // 如果没有下载文件的话，就创建一个文件。如果有下载文件的话，则不用重新创建(不然会覆盖掉之前的文件)
        [fm createFileAtPath:filePath contents:nil attributes:nil];
        
    }
    return filePath;
}
/**
 * downloadTask的懒加载
 */
- (NSURLSessionDownloadTask *)downloadTask {
    
    if (!_downloadTask) {
        // 1、创建下载URL
        NSURL *url = [NSURL URLWithString:self.urlStr];
        
        // 2.创建request请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        // 3、设置HTTP请求头中的Range
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-", self.currentLength];
        [request setValue:range forHTTPHeaderField:@"Range"];
        
        __weak typeof(self) weakSelf = self;
        /// 4、处理请求
        _downloadTask = (NSURLSessionDownloadTask *)[self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            NSLog(@"dataTaskWithRequest");
            
            if (error) {
                
                if (weakSelf.error) {
                    weakSelf.error(error, nil, @{@"url":self.urlStr});
                }
                
            }else{
                
                // 清空长度
                _currentLength = 0;
                _fileLength = 0;
                
                // 关闭fileHandle
                [weakSelf.fileHandle closeFile];
                _fileHandle = nil;
                
                if (weakSelf.sucess) {
                    weakSelf.sucess(nil, response, @{@"url":self.urlStr});
                }
            }
            
        }];
        
        /// 5、接收响应
        [self.manager setDataTaskDidReceiveResponseBlock:^NSURLSessionResponseDisposition(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSURLResponse * _Nonnull response) {
            NSLog(@"NSURLSessionResponseDisposition");
            
            //1、 获得下载文件的总长度：请求下载的文件长度 + 当前已经下载的文件长度
            weakSelf.fileLength = response.expectedContentLength + weakSelf.currentLength;
            //2、转化为存储
            NSString * totalLegth = [NSString stringWithFormat:@"%ld",(long)weakSelf.fileLength];
            //3、保存路径
            NSString * path = [weakSelf getPathWithName:[NSString stringWithFormat:@"%@.txt",weakSelf.saveName]];
            //4、存储
            BOOL bResult=[totalLegth writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];

//            
//            if (weakSelf.fileLength == weakSelf.currentLength) {
//                
//                return NSURLSessionResponseCancel;
//            }
            
            // 沙盒文件路径
            NSLog(@"File downloaded to: %@",weakSelf.downSavePath);
            
            // 创建文件句柄
            weakSelf.fileHandle = [NSFileHandle fileHandleForWritingAtPath:weakSelf.downSavePath];
            
            // 允许处理服务器的响应，才会继续接收服务器返回的数据
            return NSURLSessionResponseAllow;
        }];
        
        /// 6、接收处理数据
        [self.manager setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
            NSLog(@"setDataTaskDidReceiveDataBlock");
            
            // 指定数据的写入位置 -- 文件内容的最后面
            [weakSelf.fileHandle seekToEndOfFile];
            
            // 向沙盒写入数据
            [weakSelf.fileHandle writeData:data];
            
            // 拼接文件总长度
            weakSelf.currentLength += data.length;
            
            // 获取主线程，不然无法正确显示进度。
            NSOperationQueue* mainQueue = [NSOperationQueue mainQueue];
            [mainQueue addOperationWithBlock:^{
                // 下载进度
                
                if (weakSelf.progressBlock) {
                    weakSelf.progressBlock(weakSelf.currentLength, weakSelf.fileLength);
                }
            }];
        }];
        
    }
    return _downloadTask;
}

/**
 * 获取已下载的文件大小
 */
- (NSInteger)fileLengthForPath:(NSString *)path {
    NSInteger fileLength = 0;
    NSFileManager *fileManager = [[NSFileManager alloc] init]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileLength = [fileDict fileSize];
        }
    }
    return fileLength;
}
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
                failure:(ReplyError)failure{
    
    if (self = [super init]) {
        
        self.saveName = saveName;
        
        self.urlStr = url;
        
        self.progressBlock = progressBlock;
        
        self.sucess = success;
        
        self.error = failure;
        
        url = [FrankNetworkManage absoluteUrlWithPath:url];
        
        self.downStatus = -1;
    }
    
    return self;
}
/**
 下载状态
 
 @param status
 
 - DownloadStatus_SuspendDown: 暂停下载
 - DownloadStatus_ResumingDown: 开始下载
 
 */
-(void)setDownloadStatus:(DownloadStatus)status{
    
    if (status != _downStatus) {
        
        _downStatus = status;
        
        if (_downStatus == DownloadStatus_SuspendDown) {// 暂停
            
            [self.downloadTask suspend];
            self.downloadTask = nil;
            
        }else{// 重新开始
            
            if (self.currentLength > 0) {  // [继续下载]
                //3、保存路径
                NSString * path = [self getPathWithName:[NSString stringWithFormat:@"%@.txt",self.saveName]];
                NSString *readStr=[[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
                NSInteger totalLength = [readStr integerValue];
                if (self.currentLength < totalLength) {
                    
                    [self.downloadTask resume];
                    
                }else{
                    
                    if (self.sucess) {
                        self.sucess(nil, nil, @{@"url":self.urlStr});
                    }
                    NSLog(@"已下载完成");
                }

            }else{
                [self.downloadTask resume];
            }
        }
    }
}
-(NSInteger)currentLength{
    
    return [self fileLengthForPath:self.downSavePath];
}

@end
