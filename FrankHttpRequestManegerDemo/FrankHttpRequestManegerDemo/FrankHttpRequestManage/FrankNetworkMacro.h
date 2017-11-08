//
//  FrankNetworkMacro.h
//  FrankHttpRequestManegerDemo
//
//  Created by Frank on 2017/6/12.
//  Copyright © 2017年 Frank. All rights reserved.
//

#ifndef FrankNetworkMacro_h
#define FrankNetworkMacro_h


// Debug 模式下输出打印
#ifdef DEBUG
#define FrankLog(s, ... ) NSLog( @"\n ------- Debug输出 --------\n[%@ in line %d] \n%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define FrankLog(s, ... )
#endif




#import "FrankAPIClicent.h"
#import "FrankNetworkManage.h"
#import "BaseRequestHttpModel.h"
#import "FrankActivityHUD.h"
#import "FrankFMDBManage.h"
#import "FrankUserDefaults.h"
#import "NSString+Category.h"
#import "DeviceManage.h"
#import "XMLDictionary.h"

#endif /* FrankNetworkMacro_h */
