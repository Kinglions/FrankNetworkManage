//
//  FrankUserDefaults.m
//  GraduationProject
//
//  Created by Frank on 16/2/26.
//  Copyright © 2016年 Frank. All rights reserved.
//

#import "FrankUserDefaults.h"
#import "NSString+Category.h"

@interface FrankUserDefaults ()


@end

@implementation FrankUserDefaults

/**
 *  获取单例数据库对象
 */
+(instancetype)share{
    
    static FrankUserDefaults * frank;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        frank = [[FrankUserDefaults alloc]init];
    });
    
    return frank;
}


-(void)setFrankObject:(id)object forKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
}

-(void)FrankRemoveObjectForKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];

}

-(id)FrankObjectForKey:(NSString *)key
{
    id object = [[NSUserDefaults standardUserDefaults]objectForKey:key];
    
    return object;
}


-(void)FrankObject:(id)object writeToFileWithFileName:(NSString *)name atomically:(BOOL)atomically{
    
    NSString * path = [NSString getFilePathWithDirectoryPath:nil FileName:name];
    
    if ([object isKindOfClass:[NSString class]]) {
        [(NSString *)object writeToFile:path atomically:atomically encoding:NSUTF8StringEncoding error:nil];
    }else{
        
        [object writeToFile:path atomically:atomically];
    }
    
}
-(id)FrankObjectForWriteFileName:(NSString *)name withType:(FrankWriteToFileType)type{
    
    id obj = nil;
    NSString * path = [NSString getFilePathWithDirectoryPath:nil FileName:name];
    
    switch (type) {
        case FrankWriteToFileType_Dictionary:
            
            obj = [NSDictionary dictionaryWithContentsOfFile:path];
            
            break;
        case FrankWriteToFileType_Array:
            
            obj = [NSArray arrayWithContentsOfFile:path];
            
            break;
        case FrankWriteToFileType_Data:
            
            obj = [NSData dataWithContentsOfFile:path];
            
            break;
        case FrankWriteToFileType_String:
            
            obj = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            
            break;
            
        default:
            break;
    }
    
    return obj;
}


@end
