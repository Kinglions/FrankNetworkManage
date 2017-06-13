//
//  FrankUserDefaults.h
//  GraduationProject
//
//  Created by Frank on 16/2/26.
//  Copyright © 2016年 Frank. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface FrankUserDefaults : NSObject

/**
 写入本地数据类型

 - FrankWriteToFileType_Dictionary:
 - FrankWriteToFileType_Array:
 - FrankWriteToFileType_Data:
 - FrankWriteToFileType_String:
 */
typedef NS_ENUM(NSInteger,FrankWriteToFileType) {
    
    FrankWriteToFileType_Dictionary = 0,
    
    FrankWriteToFileType_Array,
    
    FrankWriteToFileType_Data,
    
    FrankWriteToFileType_String,
};


/**
 *  获取单例数据库对象
 */
+(instancetype)share;


/**
 *  轻量化存储
 *
 *  @param object 值
 *  @param key    键
 */
-(void)setFrankObject:(id)object forKey:(NSString *)key;

/**
 *  根据键值取值
 *
 *  @param key 键
 *
 *  @return 值
 */
-(id)FrankObjectForKey:(NSString *)key;

/**
 *  根据键值移除本地存储的数据
 *
 *  @param key 键值
 */
-(void)FrankRemoveObjectForKey:(NSString *)key;

/**
 *  写入本地 documents 中的文件
 *
 *  @param object     只能是满足存储读取类型的对象【dict,arr,data,string 四种类型】
 *  @param name       文件名字
 *  @param atomically 原子性
 */
-(void)FrankObject:(id)object writeToFileWithFileName:(NSString *)name atomically:(BOOL)atomically;
/**
 *  从本地 documents 读取数据
 *
 *  @param name 文件名字
 *  @param type 数据类型
 *
 *  @return 返回对应类型的数据
 */
-(id)FrankObjectForWriteFileName:(NSString *)name withType:(FrankWriteToFileType)type;

@end
