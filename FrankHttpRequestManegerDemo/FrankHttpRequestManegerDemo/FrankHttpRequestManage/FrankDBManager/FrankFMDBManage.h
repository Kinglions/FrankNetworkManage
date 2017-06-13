//
//  FrankFMDBManage.h
//  RefectoryProject
//
//  Created by Frank on 16/6/14.
//  Copyright © 2016年 Frank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>



// http://www.1keydata.com/cn/sql/sql-like.php SQL使用介绍

@interface FrankFMDBManage : NSObject


/**
 自定义数据库名字
 */
@property (nonatomic,strong)NSString * sqliteName;

/**
 *  获取单例数据库对象
 */
+(instancetype)shareInstance;
/**
 *  根据名字以及存放字段创建表 create table IF NOT EXISTS lanOuStudent(number integer primary key not NULL, name text not NULL, gender text not NULL, age integer not NULL)）
 *
 *  @param name 表名
 *  @param keys 表中需要存放的字段内容
 *
 *  @return YES 成功
 */
+(BOOL)creatTableWithTableName:(NSString *)name keys:(NSArray *)keys;

/**
 *  查新数据库中是否存在表
 *
 *  @param name 表名
 *
 *  @return YES 存在
 */
+(BOOL)isExistWithTableName:(NSString *)name;

#pragma mark ------  根据数据对象进行的缓存处理  -----------


/** 根据 类名 及 属性 直接自动生成 表，
 
 *  根据名字以及存放字段创建表 create table IF NOT EXISTS lanOuStudent(number integer primary key not NULL, name text not NULL, gender text not NULL, age integer not NULL)）
 *
 *
 *  @return YES 成功
 */
-(BOOL)creatTableWithModelClass:(Class)clazz;
/**
 *  根据对象检测表是否存在
 *
 *  @return YES 存在
 */
-(BOOL)isExistWithObject:(id)obj;

/**
 根据 对象插入数据
 
 @param obj 实例对象
 @return YES ：表示插入成功
 */
-(BOOL)insertObject:(id)obj;


/**
 *  删除表
 *
 *  @param clazz 实体类class
 */
-(BOOL)dropTableWithClass:(Class)clazz;
/**
 *  删除全部记录
 *
 *  @param clazz 实体类class
 */
-(BOOL)deleteRecordAllWithClass:(Class)clazz;
/**
 *  删除记录(相等)
 *
 *  @param clazz   实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应值
 */
-(BOOL)deleteRecordWithClass:(Class)clazz andKey:(NSString*)keyName isEqualValue:(NSString*)value;
/**
 *  删除记录(大于)
 *
 *  @param clazz   实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应值
 */
-(BOOL)deleteRecordWithClass:(Class)clazz andKey:(NSString*)keyName isGreaterValue:(NSString*)value;
/**
 *  删除记录(大于等于)
 *
 *  @param clazz   实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应值
 */
-(BOOL)deleteRecordWithClass:(Class)clazz andKey:(NSString*)keyName isGreaterEqualValue:(NSString*)value;
/**
 *  删除记录(小于)
 *
 *  @param clazz   实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应值
 */
-(BOOL)deleteRecordWithClass:(Class)clazz andKey:(NSString*)keyName isLessValue:(NSString*)value;
/**
 *  删除记录(小于等于)
 *
 *  @param clazz   实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应值
 */
-(BOOL)deleteRecordWithClass:(Class)clazz andKey:(NSString*)keyName isLessEqualValue:(NSString*)value;

/**  SELECT key FROM table WHERE valueKey LIKE 'N%'; // 查询 table 中 valueKey 值 以 N 开头的数据，返回 key 对应的值
 *
 *  删除记录(like)
 *
 *  @param clazz   实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应的样式值(自己加对应%)
 */
-(BOOL)deleteRecordWithClass:(Class)clazz andKey:(NSString*)keyName isLikeValue:(NSString*)value;
/**
 *  删除记录
 *
 *  @param clazz  实体类class
 *  @param params 条件
 */
-(BOOL)deleteRecordWithClass:(Class)clazz  params:(NSString*)params;


/**
 根据指定属性条件 更新对象数据
 
 @param obj 对象
 @param keyName 属性名
 @param value 属性值
 @return YES：更新成功
 */
-(BOOL)updateWithObject:(id)obj withKeyName:(NSString *)keyName isEqualValue:(NSString *)value;


/**
 *  查询全部数据
 *  @param clazz 实体类class
 *  @return 查询列表
 */
-(NSMutableArray *)selectAllWithClass:(Class)clazz;
/**
 *  查询数据(大于)
 *
 *  @param clazz   clazz 实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应值
 *
 *  @return 查询列表
 */
-(NSMutableArray *)selectWithClass:(Class)clazz andKey:(NSString*)keyName isEqualValue:(NSString*)value;
/**
 *  查询数据(大于)
 *
 *  @param clazz   clazz 实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应值
 *
 *  @return 查询列表
 */
-(NSMutableArray *)selectWithClass:(Class)clazz andKey:(NSString*)keyName isGreaterValue:(NSString*)value;
/**
 *  查询数据(大于等于)
 *
 *  @param clazz   clazz 实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应值
 *
 *  @return 查询列表
 */
-(NSMutableArray *)selectWithClass:(Class)clazz andKey:(NSString*)keyName isGreaterEqualValue:(NSString*)value;
/**
 *  查询数据(小于)
 *
 *  @param clazz   clazz 实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应值
 *
 *  @return 查询列表
 */
-(NSMutableArray *)selectWithClass:(Class)clazz andKey:(NSString*)keyName isLessValue:(NSString*)value;
/**
 *  查询数据(小于等于)
 *
 *  @param clazz   clazz 实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应值
 *
 *  @return 查询列表
 */
-(NSMutableArray *)selectWithClass:(Class)clazz andKey:(NSString*)keyName isLessEqualValue:(NSString*)value;
/**
 *  查询数据(Like)
 *
 *  @param clazz   clazz 实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应值(自己加%)
 *
 *  @return 查询列表
 */
-(NSMutableArray *)selectWithClass:(Class)clazz andKey:(NSString*)keyName isLikeValue:(NSString*)value;
/**
 *  查询数据 当params=nil时查询全部
 *
 *  @param clazz 实体类class
 *  @param params  条件
 *  @return 查询列表
 */
-(NSMutableArray *)selectWithClass:(Class)clazz params:(NSString*)params;


#pragma mark ------  一般用于网络数据的缓存处理  -----------

/**
 缓存网络数据

 @param tableName 表名：一般为 url
 @param paramsKey 数据库中的 key：一般为网络请求的参数字典
 @param valueData 数据库中的 key：一般为网络请求的参数字典
 @return YES 表示缓存成功，NO 表示缓存失败
 */
-(BOOL)cacheNetWorkDataWithTableName:(NSString *)tableName paramsKey:(NSDictionary *)paramsKey valueData:(NSDictionary *)valueData;
/**
 读取缓存的网络数据
 
 @param tableName 表名：一般为 url
 @param paramsKey 数据库中的 key：一般为网络请求的参数字典
 @return 返回上次缓存的网络数据
 */
-(NSDictionary *)loadNetWorkCacheDataWithTableName:(NSString *)tableName paramsKey:(NSDictionary *)paramsKey;




/**
 缓存路径
 */
-(NSString *)cachePath;
/**
 缓存大小
 */
- (float)cacheSize;
/**
 获取缓存大小，带单位
 */
-(NSString *)cacheSizeFormat;
/**
 清除缓存
 */
-(BOOL)clearAllCache;

/**
 字典转json字符串方法
 */
+(NSString *)convertToJsonData:(NSDictionary *)dict;
/**
 JSON字符串转化为字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;


@end
