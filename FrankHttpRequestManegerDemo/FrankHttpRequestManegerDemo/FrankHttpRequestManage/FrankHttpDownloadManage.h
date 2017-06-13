//
//  FrankHttpDownloadManage.h
//  PlaceHolderView
//
//  Created by Frank on 2017/5/27.
//  Copyright © 2017年 Frank. All rights reserved.
//

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
