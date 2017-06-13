//
//  FrankAPIClicent.h
//  YNYBZ
//
//  Created by Frank on 16/4/3.
//  Copyright © 2016年 Frank.HAJK. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <UIKit/UIKit.h>

@interface FrankAPIClicent : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end
