//
//  FrankFMDBManage.m
//  RefectoryProject
//
//  Created by Frank on 16/6/14.
//  Copyright © 2016年 Frank. All rights reserved.
//

#import "FrankFMDBManage.h"
#import <objc/runtime.h>

@interface FrankFMDBManage ()

@property(nonatomic,strong)FMDatabaseQueue * dbQueue;

@end

static FrankFMDBManage * _frankDB = nil;

@implementation FrankFMDBManage

/**
 *  获取单例数据库对象
 */
+(instancetype)shareInstance{
    
    if (_frankDB == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _frankDB = [[FrankFMDBManage alloc]init];
        });
    }
    
    return _frankDB;
}

/**
 懒加载
 */
-(FMDatabaseQueue *)dbQueue{
    
    if (!_dbQueue) {
        
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self cachePath]];
    }
    return _dbQueue;
}
-(NSString *)sqliteName{
    
    if (!_sqliteName) {
        
        return @"FrankDB.sqlite";
    }
    
    return _sqliteName;
}
/**
 *  查新数据库中是否存在表
 *
 *  @param name 表名
 *
 *  @return YES 存在
 */
+(BOOL)isExistWithTableName:(NSString *)name{
    
    if (!name) {
        NSLog(@"---查询表失败--表名不能为空");
        return NO;
    }
    __block BOOL result = NO;
    
    [[FrankFMDBManage shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        result = [db tableExists:name];
    }];
    
    return  result;
}
/**
 *  根据名字以及存放字段创建表 create table IF NOT EXISTS lanOuStudent(number integer primary key not NULL, name text not NULL, gender text not NULL, age integer not NULL)）
 *
 *  @param name 表名
 *  @param keys 表中需要存放的字段内容
 *
 *  @return YES 成功
 */
+(BOOL)creatTableWithTableName:(NSString *)name keys:(NSArray *)keys{
    if (!name) {
        NSLog(@"---%@ 创建表失败--表名不能为空",name);
        return NO;
    }else if (!keys || keys.count<=0){
        NSLog(@"---%@ 创建表失败--字段数组不能为空",name);
        return NO;
    }
    
    __block BOOL result = NO;
    [[FrankFMDBManage shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        NSString * header = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement",name];//,name text,age integer);
        NSMutableString* sql = [[NSMutableString alloc] init];
        [sql appendString:header];
        for(int i=0;i<keys.count;i++){
            [sql appendFormat:@",%@ text",keys[i]];
            if (i == (keys.count-1)) {
                [sql appendString:@");"];
            }
        }
        result = [db executeUpdate:sql];
    }];
    NSLog(@"----%@ 创建表成功",name);
    return result;
    
}

#pragma mark ------  根据数据对象进行的缓存处理  -----------


/** 根据 类名 及 属性 直接自动生成 表，
 
 *  根据名字以及存放字段创建表 create table IF NOT EXISTS lanOuStudent(number integer primary key not NULL, name text not NULL, gender text not NULL, age integer not NULL)）
 *
 *
 *  @return YES 成功
 */
-(BOOL)creatTableWithModelClass:(Class)clazz {
    
    __block BOOL result = NO;
    [[FrankFMDBManage shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        
        // 1、获取类名
        const char *tableName = class_getName(clazz);
        // 2、转化为字符串
        NSString * name = [[NSString alloc] initWithUTF8String:tableName];
        // 3、构建成 sql 语句
        NSString * sql = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement",name];//,name text,age integer);
        
        // 4、通过 runtime获取属性列表
        unsigned int count = 0;
        Ivar * ivarlist = class_copyIvarList(clazz, &count);
        
        for (int i = 0; i < count; i++) {
            
            Ivar ivar = ivarlist[i];
            NSString *key = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
            NSString * type = [NSString stringWithCString:ivar_getTypeEncoding(ivar) encoding:NSUTF8StringEncoding];
            
            NSLog(@"------%@-->%@",type,key);
            
            // 5、将 _name 的前缀 “_” 替换成 name
            if ([key hasPrefix:@"_"]) {
                key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
            }
            
            type = [self getSQLKeyTypeStringWithSystemKey:type];
            
            // 6、拼接组合 sql
            sql = [sql stringByAppendingString:[NSString stringWithFormat:@",%@ %@",key,type]];
            
        }
        
        if (ivarlist) {
            
            free(ivarlist);
        }
        
        sql = [sql stringByAppendingString:@");"];

        NSLog(@" create sql --> %@",sql);

        result = [db executeUpdate:sql];
        
        NSLog(@"--- 创建表--%d",result);
        
    }];
    
    return result;
    
}
-(NSString *)getSQLKeyTypeStringWithSystemKey:(NSString *)key{
    
    /*
     2017-06-09 14:51:07.121 BarberProject[58915:38392858] ------q-->aaa
     
     2017-06-09 14:51:07.121 BarberProject[58915:38392858] ------f-->floatttt
     2017-06-09 14:51:07.121 BarberProject[58915:38392858] ------d-->cgfloat
     
     2017-06-09 14:51:07.121 BarberProject[58915:38392858] ------B-->_iswwwww
     2017-06-09 14:51:07.122 BarberProject[58915:38392858] ------c-->_charDefault
     2017-06-09 14:51:07.122 BarberProject[58915:38392858] ------s-->_shortsss
     2017-06-09 14:51:07.122 BarberProject[58915:38392858] ------i-->_aint

     2017-06-09 14:51:07.122 BarberProject[58915:38392858] ------@"NSString"-->_name
     2017-06-09 14:51:07.122 BarberProject[58915:38392858] ------@"NSArray"-->_books
     2017-06-09 14:51:07.123 BarberProject[58915:38392858] ------q-->_age
     
     2017-06-09 14:51:07.123 BarberProject[58915:38392858] ------q-->_aBool
     2017-06-09 14:51:07.123 BarberProject[58915:38392858] ------q-->_longwww
     
     2017-06-09 14:51:07.123 BarberProject[58915:38392858] ------d-->_adouble
     
     2017-06-09 14:51:07.123 BarberProject[58915:38392858] ------@"NSData"-->_data
     2017-06-09 14:51:07.147 BarberProject[58915:38392858] ------@"NSArray"-->_arr
     2017-06-09 14:51:07.148 BarberProject[58915:38392858] ------@"NSNumber"-->_number
     2017-06-09 14:51:07.148 BarberProject[58915:38392858] ------@-->_anId
     2017-06-09 14:51:07.148 BarberProject[58915:38392858] ------@"BaseObject"-->_stu
     2017-06-09 14:51:07.148 BarberProject[58915:38392858] ------@?-->_block
     2017-06-09 14:51:07.148 BarberProject[58915:38392858] ------@"NSDate"-->_date
     */
    
//    if ([key isEqualToString:@"@?"] || [key isEqualToString:@"@"]) {
//        
//        return nil;
//    }
    
    NSArray * integerArr = @[@"q",@"i"];
    
    NSString * sqlKey = @"text";
    
    if ([integerArr containsObject:key]) {
        sqlKey = @"integer";
    }else if ([key isEqualToString:@"B"]){
        sqlKey = @"boolean";
    }else if ([key isEqualToString:@"c"]){
        sqlKey = @"varchar";
    }else if ([key isEqualToString:@"f"]){
        sqlKey = @"float";
    }else if ([key isEqualToString:@"s"]){
        sqlKey = @"smallint";
    }else if ([key isEqualToString:@"d"]){
        sqlKey = @"double";
    }else if ([key isEqualToString:@"@\"NSDate\""]){
        sqlKey = @"date";
    }else if ([key isEqualToString:@"@\"NSData\""]){
        sqlKey = @"binary";
    }else{
        sqlKey = @"text";
    }
    
    return sqlKey;
}
/**
 *  根据对象检测表是否存在
 *
 *  @param obj 对象
 *
 *  @return YES 存在
 */
-(BOOL)isExistWithObject:(id)obj{
    
    if (!obj) {
        NSLog(@"---查询表失败--表名不能为空");
        return NO;
    }
    __block BOOL result = NO;
    
    // 2、获取对象的类名，作为表明
    const char * tableName = class_getName([obj class]);
    NSString * name = [[NSString alloc] initWithUTF8String:tableName];
    
    [[FrankFMDBManage shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        

        result = [db tableExists:name];
        
    }];
    
    return  result;
}
/**
 *  删除表
 *
 *  @param clazz 实体类class
 */
-(BOOL)dropTableWithClass:(Class)clazz
{
    __block BOOL result = NO;
    [[FrankFMDBManage shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        
        const char *tableName = class_getName(clazz);
        NSString *tableNameStr =[[NSString alloc] initWithUTF8String:tableName];
        NSString*sql = [NSString stringWithFormat:@"drop table '%@'",tableNameStr];
        
        result = [db executeUpdate:sql];

        NSLog(@"drop sql ->%@",sql);
    }];
    
    return result;
}
/**
 *  删除全部记录
 *
 *  @param clazz 实体类class
 */
-(BOOL)deleteRecordAllWithClass:(Class)clazz
{
    return [self deleteRecordWithClass:clazz params:nil];
}
/**
 *  删除记录(相等)
 *
 *  @param clazz   实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应值
 */
-(BOOL)deleteRecordWithClass:(Class)clazz andKey:(NSString*)keyName isEqualValue:(NSString*)value
{
    NSString *params =@"";
    if (keyName!=nil){
        
        params = [NSString stringWithFormat:@" %@='%@' ",keyName,value];
    }else{
        
        params = @" 1=1 ";
    }
    return [self deleteRecordWithClass:clazz params:params];
}
/**
 *  删除记录(大于)
 *
 *  @param clazz   实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应值
 */
-(BOOL)deleteRecordWithClass:(Class)clazz andKey:(NSString*)keyName isGreaterValue:(NSString*)value
{
    NSString *params =@"";
    if (keyName!=nil)
    {
        params = [NSString stringWithFormat:@" %@ >'%@' ",keyName,value];
    }
    else
    {
        params = @" 1=1 ";
    }
    return [self deleteRecordWithClass:clazz params:params];
}
/**
 *  删除记录(大于等于)
 *
 *  @param clazz   实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应值
 */
-(BOOL)deleteRecordWithClass:(Class)clazz andKey:(NSString*)keyName isGreaterEqualValue:(NSString*)value
{
    NSString *params =@"";
    if (keyName!=nil)
    {
        params = [NSString stringWithFormat:@" %@ >= '%@' ",keyName,value];
    }
    else
    {
        params = @" 1=1 ";
    }
    return [self deleteRecordWithClass:clazz params:params];
}
/**
 *  删除记录(小于)
 *
 *  @param clazz   实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应值
 */
-(BOOL)deleteRecordWithClass:(Class)clazz andKey:(NSString*)keyName isLessValue:(NSString*)value
{
    NSString *params =@"";
    if (keyName!=nil)
    {
        params = [NSString stringWithFormat:@" %@ <'%@' ",keyName,value];
    }
    else
    {
        params = @" 1=1 ";
    }
    return [self deleteRecordWithClass:clazz params:params];
}
/**
 *  删除记录(小于等于)
 *
 *  @param clazz   实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应值
 */
-(BOOL)deleteRecordWithClass:(Class)clazz andKey:(NSString*)keyName isLessEqualValue:(NSString*)value
{
    NSString *params =@"";
    if (keyName!=nil)
    {
        params = [NSString stringWithFormat:@" %@ <='%@' ",keyName,value];
    }
    else
    {
        params = @" 1=1 ";
    }
    return [self deleteRecordWithClass:clazz params:params];
}
/**  SELECT key FROM table WHERE valueKey LIKE 'N%'; // 查询 table 中 valueKey 值 以 N 开头的数据，返回 key 对应的值
 *
 *  删除记录(like)
 *
 *  @param clazz   实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应的样式值(自己加对应%)
 */
-(BOOL)deleteRecordWithClass:(Class)clazz andKey:(NSString*)keyName isLikeValue:(NSString*)value
{
    NSString *params =@"";
    if (keyName!=nil)
    {
        params = [NSString stringWithFormat:@" %@ like '%@' ",keyName,value];
    }
    else
    {
        params = @" 1=1 ";
    }
    return [self deleteRecordWithClass:clazz params:params];
}
/**
 *  删除记录
 *
 *  @param clazz  实体类class
 *  @param params 条件
 */
-(BOOL)deleteRecordWithClass:(Class)clazz  params:(NSString*)params
{
    if (params==nil)
    {
        params = @" 1=1";
    }
    
    
    __block BOOL result = NO;
    [[FrankFMDBManage shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        
        const char *tableName = class_getName(clazz);
        NSString *tableNameStr =[[NSString alloc] initWithUTF8String:tableName];
        
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@",tableNameStr,params];
        
        result = [db executeUpdate:sql];
        
        NSLog(@"delete sql ->%@",sql);
    }];
    
    return result;
}



/**
 根据 对象插入数据

 @param obj 实例对象
 @return YES ：表示插入成功
 */
-(BOOL)insertObject:(id)obj{
    
    // 1、判断对象是否为 空
    if (!obj) {
        NSLog(@"--- 插入数据失败----表名不能为空");
        return NO;
    }
    
    __block BOOL result = NO;
    
    // 2、获取对象的类名，作为表明
    const char * tableName = class_getName([obj class]);
    NSString * name = [[NSString alloc] initWithUTF8String:tableName];
    
    // 3、判断是否存在改表单，存在就直接插入数据，不存在就先创建表单，再插入数据
    if (![FrankFMDBManage isExistWithTableName:name]) {
        
        [self creatTableWithModelClass:[obj class]];
        
    }
    
    [[FrankFMDBManage shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        
        // 4、创建 sql 语句，SQLValues：属性值类型
        NSString * SQL = [NSString stringWithFormat:@"insert into %@(",name];
        NSString * SQLValues = @"(";
        
        // 5、获取属性值
        unsigned int count = 0;
        Ivar *ivarList = class_copyIvarList([obj class], &count);
        
        for (int i = 0; i < count; i++) {
            
            Ivar ivar = ivarList[i];
            NSString * key = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
            // 将 _name 的前缀 “_” 替换成 name
            if ([key hasPrefix:@"_"]) {
                key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
            }
            
            if (i == 0) {
                
                SQL = [SQL stringByAppendingString:[NSString stringWithFormat:@"%@",key]];
                SQLValues = [SQLValues stringByAppendingString:[NSString stringWithFormat:@"'%@'",[obj valueForKey:key]]];
                
            }else{
                
                SQL = [SQL stringByAppendingString:[NSString stringWithFormat:@",%@",key]];
                SQLValues = [SQLValues stringByAppendingString:[NSString stringWithFormat:@",'%@'",[obj valueForKey:key]]];
            }
            
        }
        
        if (ivarList) {
            
            free(ivarList);
        }

        SQL = [NSString stringWithFormat:@"%@) values %@)",SQL,SQLValues];
        
        result = [db executeUpdate:SQL];
        
        NSLog(@"---- 插入成功 ");

    }];

    return result;
}

/**
 根据指定属性条件 更新对象数据

 @param obj 对象
 @param keyName 属性名
 @param value 属性值
 @return YES：更新成功
 */
-(BOOL)updateWithObject:(id)obj withKeyName:(NSString *)keyName isEqualValue:(NSString *)value{
    
    // 1、判断对象是否为 空
    if (!obj) {
        NSLog(@"--- 刷新数据失败----表名不能为空");
        return NO;
    }
    
    __block BOOL result = NO;
    
    
    // 2、获取对象的类名，作为表明
    const char * tableName = class_getName([obj class]);
    NSString * name = [[NSString alloc] initWithUTF8String:tableName];
    
    // 3、判断是否存在改表单，存在对应数据就直接更新数据，不存在就先创建表单 返回 NO
    if (![FrankFMDBManage isExistWithTableName:name]) {
        
        [self creatTableWithModelClass:obj];
        
    }else{
     
        [[FrankFMDBManage shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
            
            
            // 4、创建 sql 语句，SQLValues：属性值类型
            NSString * SQL = [NSString stringWithFormat:@"update %@ set ",name];
            
            // 5、获取属性值
            unsigned int count = 0;
            Ivar *ivarList = class_copyIvarList([obj class], &count);
            
            for (int i = 0; i < count; i++) {
                
                Ivar ivar = ivarList[i];
                NSString * key = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
                // 将 _name 的前缀 “_” 替换成 name
                if ([key hasPrefix:@"_"]) {
                    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                }
                
                // 判断 key值 是否相同，更新不同的属性值
                if (![key isEqualToString:keyName]) {
                    
                    NSString * p = @"";
                    
                    if (i != 0) {
                        p = @",";
                    }
                    
                    SQL = [SQL stringByAppendingString:[NSString stringWithFormat:@"%@ = '%@'%@",key,[obj valueForKey:key],p]];
                }
            }
            
            if (ivarList) {
                
                free(ivarList);
            }
            
            
            SQL = [NSString stringWithFormat:@"%@ where %@='%@'",SQL,keyName,value];
            
            result = [db executeUpdate:SQL];
            
            NSLog(@"---- 更新成功 -- %@ ",SQL);
            
            
        }];
    }
    
    return result;
}
/**
 *  查询全部数据
 *  @param clazz 实体类class
 *  @return 查询列表
 */
-(NSMutableArray *)selectAllWithClass:(Class)clazz
{
    return  [self selectWithClass:clazz params:nil];
}
/**
 *  查询数据
 *
 *  @param clazz   clazz 实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应值
 *
 *  @return 查询列表
 */
-(NSMutableArray *)selectWithClass:(Class)clazz andKey:(NSString*)keyName isEqualValue:(NSString*)value{

    return  [self selectWithClass:clazz params:[NSString stringWithFormat:@" %@ = '%@'",keyName,value]];

}
/**
 *  查询数据(大于)
 *
 *  @param clazz   clazz 实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应值
 *
 *  @return 查询列表
 */
-(NSMutableArray *)selectWithClass:(Class)clazz andKey:(NSString*)keyName isGreaterValue:(NSString*)value
{
    return  [self selectWithClass:clazz params:[NSString stringWithFormat:@" %@ > '%@'",keyName,value]];
}
/**
 *  查询数据(大于等于)
 *
 *  @param clazz   clazz 实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应值
 *
 *  @return 查询列表
 */
-(NSMutableArray *)selectWithClass:(Class)clazz andKey:(NSString*)keyName isGreaterEqualValue:(NSString*)value
{
    return  [self selectWithClass:clazz params:[NSString stringWithFormat:@" %@ >= '%@'",keyName,value]];
}
/**
 *  查询数据(小于)
 *
 *  @param clazz   clazz 实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应值
 *
 *  @return 查询列表
 */
-(NSMutableArray *)selectWithClass:(Class)clazz andKey:(NSString*)keyName isLessValue:(NSString*)value
{
    return  [self selectWithClass:clazz params:[NSString stringWithFormat:@" %@ < '%@'",keyName,value]];
}
/**
 *  查询数据(小于等于)
 *
 *  @param clazz   clazz 实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应值
 *
 *  @return 查询列表
 */
-(NSMutableArray *)selectWithClass:(Class)clazz andKey:(NSString*)keyName isLessEqualValue:(NSString*)value
{
    return  [self selectWithClass:clazz params:[NSString stringWithFormat:@" %@ <= '%@'",keyName,value]];
}
/**
 *  查询数据(Like)
 *
 *  @param clazz   clazz 实体类class
 *  @param keyName 实体对象属性名
 *  @param value   对应值(自己加%)
 *
 *  @return 查询列表
 */
-(NSMutableArray *)selectWithClass:(Class)clazz andKey:(NSString*)keyName isLikeValue:(NSString*)value
{
    return  [self selectWithClass:clazz params:[NSString stringWithFormat:@" %@ LIKE '%@'",keyName,value]];
}
/**
 *  查询数据 当params=nil时查询全部
 *
 *  @param clazz 实体类class
 *  @param params  条件
 *  @return 查询列表
 */
-(NSMutableArray *)selectWithClass:(Class)clazz params:(NSString*)params
{
    if (!params) {
        params = @" 1=1";
    }
    
    // 1、创建模型数组
    NSMutableArray * modelArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    [[FrankFMDBManage shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        
        // 2、获取对象的类名，作为表明
        const char * tableName = class_getName(clazz);
        NSString * name = [[NSString alloc] initWithUTF8String:tableName];
        
        // 3、创建 sql 语句，
        NSString * SQL = [NSString stringWithFormat:@"select * from %@ where %@",name,params];

        // 4.遍历结果集
        FMResultSet * set = [db executeQuery:SQL];

        while ([set next]) {
            
            // 5、创建对象
            id obj = [[clazz alloc] init];
            
            NSMutableDictionary* dictM = [[NSMutableDictionary alloc] initWithCapacity:0];
            
            for (int i=0;i<[[[set columnNameToIndexMap] allKeys] count];i++) {
                
                [dictM setValue:[set stringForColumnIndex:i] forKey:[set columnNameForIndex:i]];
            }
            
            [obj setValuesForKeysWithDictionary:dictM];
            
            [modelArr addObject:obj];
        }
        
    }];
    
    return modelArr;
    
}

#pragma mark ------  一般用于网络数据的缓存处理  -----------

/**
 缓存网络数据
 
 @param tableName 表名：一般为 url
 @param paramsKey 数据库中的 key：一般为网络请求的参数字典
 @param valueData 数据库中的 key：一般为网络请求的参数字典
 @return YES 表示缓存成功，NO 表示缓存失败
 */
-(BOOL)cacheNetWorkDataWithTableName:(NSString *)tableName paramsKey:(NSDictionary *)paramsKey valueData:(NSDictionary *)valueData{
    
    if (!tableName) {
        NSLog(@"---%@ 创建表失败--表名不能为空",tableName);
        return NO;
    }else if (!paramsKey || paramsKey.count<=0){
        NSLog(@"---%@ 创建表失败--字段数组不能为空",paramsKey);
        return NO;
    }
    
    tableName = [FrankFMDBManage replaceStringForOriginStr:tableName replaceArray:@[@"/",@":",@"."] toString:@""];
    
    NSString * key = [FrankFMDBManage convertToJsonData:paramsKey];
    NSString * jsonValue = [FrankFMDBManage convertToJsonData:valueData];
    
    if (!jsonValue) {
        
        jsonValue = @"";
    }
    // 1、判断表是否存在
    if (![FrankFMDBManage isExistWithTableName:tableName]) {
        
        [FrankFMDBManage creatTableWithTableName:tableName keys:@[@"key",@"jsonValue"]];
    }
    
    return [_frankDB updateWithTableName:tableName value:jsonValue key:key];
    
}

/**
 读取缓存的网络数据
 
 @param tableName 表名：一般为 url
 @param paramsKey 数据库中的 key：一般为网络请求的参数字典 【解析成json字符串】
 @return 返回上次缓存的网络数据
 */
-(NSDictionary *)loadNetWorkCacheDataWithTableName:(NSString *)tableName paramsKey:(NSDictionary *)paramsKey{
    
    if (tableName==nil){
        NSLog(@"表名不能为空!");
        return nil;
    }
    
    tableName = [FrankFMDBManage replaceStringForOriginStr:tableName replaceArray:@[@"/",@":",@"."] toString:@""];
    NSString * key = [FrankFMDBManage convertToJsonData:paramsKey];

    __block NSString * jsonStr = nil;

    [[FrankFMDBManage shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString * SQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE key='%@'",tableName,key];
        
        NSLog(@"----sql is %@  ",SQL);

        // 1.查询数据
        FMResultSet * set = [db executeQuery:SQL];
        
        // 2.遍历结果集
        if ([set next]) {// 2、有数据，进行更新
            
            jsonStr = [set stringForColumn:@"jsonValue"];
        }
    }];
    
    
    
    NSDictionary * dict = [FrankFMDBManage dictionaryWithJsonString:jsonStr];
    
    return dict;
}

/**
 *  根据表名更新指定的内容 UPDATE orderTable SET key1 = '%@' WHERE key2 = %d
 *
 *  @param name      表名
 *  @param value 更新内容
 *
 *  @return YES 更新成功
 */
-(BOOL)updateWithTableName:(NSString*)name value:(NSString *)value key:(NSString *)key{
    if (name == nil) {
        NSLog(@"----%@ 更新失败 ---表名不能为空!",name);
        return NO;
    }else if (value == nil){
        NSLog(@"----%@ 更新失败 ---更新值数组不能为空!",name);
        return NO;
    }else;
    
    __block BOOL result = NO;
    [[FrankFMDBManage shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString * SQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE key='%@'",name,key];
        
        // 1、查询数据库中数据
        FMResultSet * set = [db executeQuery:SQL];
        
        if ([set next]) {// 2、有数据，进行更新
            
            SQL = [NSString stringWithFormat:@"update %@ set jsonValue='%@' where key='%@'",name,value,key];
            
        }else{// 3、没有数据，插入数据
            
            SQL = [NSString stringWithFormat:@"insert into %@ (key,jsonValue) values('%@','%@')",name,key,value];
            
        }
        NSLog(@"----sql is %@  ",SQL);

        result = [db executeUpdate:SQL];
    }];
    NSLog(@"----%@ 更新成功 ",name);
    
    return result;
    
}

/**
 替换字符串

 @param originStr 原始字符
 @param replaceArray 需要替换掉的字符数组
 @param toStr 替换成的字符
 @return 最终的字符
 */
+(NSString *)replaceStringForOriginStr:(NSString *)originStr replaceArray:(NSArray *)replaceArray toString:(NSString *)toStr{
    
    for (NSString * str  in replaceArray) {
        
       originStr = [originStr stringByReplacingOccurrencesOfString:str withString:toStr];
    }
    
    return originStr;
}
/**
 字典转json字符串方法
 */
+(NSString *)convertToJsonData:(NSDictionary *)dict{
    
    if (!dict) {
        return @"";
    }
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
//    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
//    
//    NSRange range = {0,jsonString.length};
//    
//    //去掉字符串中的空格
//    
//    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
//    
//    NSRange range2 = {0,mutStr.length};
//    
//    //去掉字符串中的换行符
//    
//    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return jsonString;
    
}


/**
 JSON字符串转化为字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
-(NSString *)cachePath
{
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:self.sqliteName];
    
    return path;
}
- (float)cacheSize{
    
    NSString *directoryPath = [self cachePath];
    
    directoryPath = [FrankFMDBManage replaceStringForOriginStr:directoryPath replaceArray:@[self.sqliteName] toString:@""];
    
    BOOL isDir = NO;
    unsigned long long total = 0;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDir]) {
        if (isDir) {
            NSError *error = nil;
            NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
            
            if (error == nil) {
                for (NSString *subpath in array) {
                    NSString *path = [directoryPath stringByAppendingPathComponent:subpath];
                    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path
                                                                                          error:&error];
                    if (!error) {
                        total += [dict[NSFileSize] unsignedIntegerValue];
                    }
                }
            }
        }
    }
    return total/(1024.0*1024.0);
}
-(NSString *)cacheSizeFormat
{
    NSString *sizeUnitString;
    float size = [self cacheSize];
    if(size < 1)
    {
        size *= 1024.0;//小于1M转化为kb
        sizeUnitString = [NSString stringWithFormat:@"%.1fkb",size];
    }
    else{
        
        sizeUnitString = [NSString stringWithFormat:@"%.1fM",size];
    }
    
    return sizeUnitString;
}
-(BOOL)clearAllCache
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *pathOfDocument = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    BOOL result = [fileManager removeItemAtPath:pathOfLibrary error:nil];
    result = [fileManager removeItemAtPath:pathOfDocument error:nil];
    
    [self checkDirectory:pathOfLibrary];
    [self checkDirectory:pathOfDocument];
    
    return result;
}
-(void)checkDirectory:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createBaseDirectoryAtPath:path];
    } else {
        
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}

- (void)createBaseDirectoryAtPath:(NSString *)path {
    __autoreleasing NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                               attributes:nil error:&error];
    if (error) {
        NSLog(@"create cache directory failed, error = %@", error);
    } else {
        
        NSLog(@"path = %@",path);
        [self addDoNotBackupAttribute:path];
    }
}
- (void)addDoNotBackupAttribute:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (error) {
        NSLog(@"error to set do not backup attribute, error = %@", error);
    }
}


@end
