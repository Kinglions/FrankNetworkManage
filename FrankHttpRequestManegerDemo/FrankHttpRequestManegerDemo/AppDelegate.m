//
//  AppDelegate.m
//  FrankHttpRequestManegerDemo
//
//  Created by Frank on 2017/6/12.
//  Copyright © 2017年 Frank. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self setHttpBaseMessage];

    
    
    return YES;
}

#error ------ 根据自己服务器数据格式配置请求结果判断的回调  ------------

/**
 配置网络请求
 */
-(void)setHttpBaseMessage{
    
    // 配置网络请求 baseUrl
    [FrankNetworkManage updateBaseUrl:@"https://news-at.zhihu.com/"];
    
    // 配置网络数据缓存类型
    [FrankNetworkManage shareManager].cacheType = NetworkCacheType_OnlyCache;
    
    
#error -----   如果 服务器 返回的有 成功状态标识，可以根据状态进行 如下 配置，否则不需要配置 judgeResponseIsSuccess
    
//    // 配置网络请求成功判断逻辑
//    [FrankNetworkManage shareManager].judgeResponseIsSuccess = ^BOOL(id responseSuccess) {
//
//        BOOL loginSucess = NO;
//
//        if ( [responseSuccess isKindOfClass:[NSDictionary class]] ) {
//
//            // 根据服务器定制的成功状态进行配置，loginSucess = YES ：表示成功，否则表示失败
//            loginSucess =  [responseSuccess[@"code"] isEqualToNumber:@(200)];
//
//            // 根据自己项目需求，如果服务器定义字段，进行判断是否需要发出区分账号失效通知及相关处理
//            // 账号被登出，下次需要重新登录，并且发送通知
//            if ([responseSuccess[@"code"] isEqualToNumber:@(401)]) {
//
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"账号失效通知" object:nil userInfo:responseSuccess];// 发送重新登录的通知
//            }
//
//        }
//        return loginSucess;
//    };
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
