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

//#error ------ 根据自己服务器要求配置请求头信息  ------------
/**
 配置网络请求
 */
-(void)setHttpBaseMessage{
    // 配置网络请求 baseUrl
    [FrankNetworkManage updateBaseUrl:@"http://apistore.baidu.com/"];
    [FrankNetworkManage shareManager].cacheType = NetworkCacheType_CacheAndLoad;
    
    // 配置网络请求成功判断逻辑
    [FrankNetworkManage shareManager].judgeResponseIsSuccess = ^BOOL(id responseSuccess) {
        
        BOOL loginSucess = NO;
        if ( [responseSuccess isKindOfClass:[NSDictionary class]] )
        {
            if (responseSuccess[@"errNum"] != nil)
            {
                loginSucess =  [responseSuccess[@"errNum"] isEqualToNumber:@(0)];
                
                if ([responseSuccess[@"errNum"] isEqualToNumber:@(4)]) {// 账号被登出，下次需要重新登录
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"账号失效通知" object:nil userInfo:responseSuccess];// 发送重新登录的通知
                }
            }
        }
        return loginSucess;
    };
    
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
