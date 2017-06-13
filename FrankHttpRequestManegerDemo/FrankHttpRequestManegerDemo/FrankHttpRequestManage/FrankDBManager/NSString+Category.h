//
//  NSString+Category.h
//  FrankAFNetWorking
//
//  Created by 武玉宝 on 16/1/20.
//  Copyright © 2016年 Frank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Category)

/** 字符串的 base64 编码，解码*/
+ (NSString *)stringWithBase64EncodedString:(NSString *)string;
- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)base64EncodedString;
- (NSString *)base64DecodedString;
- (NSData *)base64DecodedData;

/** MD5 加密*/
- (id)MD5;

/**
 *  读取本地文件资源
 *
 *  @param name 资源名称
 *  @param type 资源后缀类型
 *
 *  @return 返回资源路径地址
 */
+(NSString *)readLocalResourceWithName:(NSString *)name ofType:(NSString *)type;

/** 获取沙盒中的文件  1,本地存储文件夹名字（documents或下层文件夹） 2,文件名字*/
+(NSString *)getFilePathWithDirectoryPath:(NSString *)aDirectoryPath FileName:(NSString *)aFileName;

/** 分割字符串*/
-(NSArray *)separableStringByString:(NSString *)aString;

/** 去空格 （头尾空格）*/
-(NSString *)removeSpaceString;

/**
 *  替换字符串中的特殊字符
 *
 *  @param oldStrArr 特殊字符数组
 *  @param newStr    要替换成的字符
 *
 *  @return 返回替换后得结果
 */
-(NSString *)replaceStrWithChatStrArr:(NSArray *)oldStrArr toTheStr:(NSString *)newStr;

/**
 *  判断是否为中文
 *
 *  @return YES 表示是
 */
-(BOOL)isChinese;

/**
 *  字符串版本对比
 *
 *  @param appStoreVersion 苹果商店上的版本号
 *
 *  @return YES 表示需要更新版本
 */
-(BOOL)compareVersionWithAppStoreVersion:(NSString *)appStoreVersion;

/**
 *  为字符串添加属性
 *
 *  @param str                 目的字符
 *  @param Alignment           字符位置（枚举）
 *  @param lineSpacing         行高
 *  @param firstLineHeadindent 首行缩进字符个数
 *
 *  @return 返回为属性，可以用label或者textView调用 attributedString 进行接收
 */
+(NSMutableAttributedString *)getContent:(NSString *)str withParagrahStyleAlignment:(NSTextAlignment)Alignment withLineSpacing:(CGFloat)lineSpacing withFirstLingHeadIndent:(CGFloat)firstLineHeadindent;

/**
 *  ios 9.0 之后，使用该方法对字符串进行编码
 */
- (NSString *)encodeStrWithUTF8;

/**
 * @discussion 判断手机号码的合法性
 * @return 手机号码合法性
 */
-(BOOL)checkTelNumber;
///**
// *  手机号正则 匹配国际手机号
// */
//-(BOOL)checkTelNumber;

/**
 * @discussion 判断电话号码的合法性
 * @return 电话号码合法性
 */
- (BOOL)isValidTelephoneNumber;

/**
 * @discussion 判断电子邮件地址的合法性
 * @return 电子邮件地址合法性
 */
- (BOOL)isValidEmail;

/**
 * @discussion 判断输入串是否为中文(简体,繁体)
 */
- (BOOL)isValidChinese;

/**
 * @discussion 判断是否是有效URL串
 */
- (BOOL)isValidURL;

/**
 * @discussion 判断是否是有效IP地址
 */
- (BOOL)isValidIPAddress;

/**
 * @discussion 判断是否是有效qq号码
 */
- (BOOL)isValidQQ;

/**
 * @discussion 判断是否是有效邮政编码
 */
- (BOOL)isValidPostalCode;

/**
 * @discussion 判断是否是有效短信校验码,一般是4到6位数字
 */
- (BOOL)isValidAuthCode;

/**
 * @discussion 判断是否是有效身份证号码
 */
- (BOOL)isValidIdCardNumber;

/**
 * @discussion 判断是否是像帐号的数字
 */
- (BOOL)isAccountLikeNumber;

/**
 * @discussion 判断是否是有效的密码
 */
- (BOOL)isValidPassword;

/**
 * @discussion 判断是否是有效的密码, 6-12位数字或字母
 */
- (BOOL)isValidEasyPassword;

/**
 * @discussion 判断是否是有效的vcard数据
 */
- (BOOL)isValidVCard;

/**
 * @discussion 判断是否是有效的银行卡号
 *
 */
- (BOOL) isValidateBankCardNumber;

/**
 *  获取本地化资源文件
 */
+(NSString*)getFromResource:(NSString*)strKey;
/**
 *  拼接字符串
 *
 *
 *  @return 拼接之后的字符串
 */
+(NSString*)safeGetValue:(id)string;

/**
 *  获取汉字首字母
 *
 *  @param strHangZI 汉字
 *  @param nIndex    汉字所在索引
 *
 *  @return 返回汉字首字母
 */
+ (NSString*)changeHangziToABC:(NSString *)strHangZI atIndex:(NSInteger)nIndex;
/**
 将字符串转化成对应的 拼音，首字母大写
 
 @return 对应的拼音 如：Hangzhou
 */
-(NSString *)changeStringToPinyin;
/**
 *  判断两个汉字首字母是否相等
 *
 *  @param strHangzi 要对比的汉字
 *
 *  @return YES 相同
 */
- (BOOL)isEqualHangziABC:(NSString*)strHangzi;
/**
 *  获取属性字符串的高度
 *
 *  @param font      字号
 *  @param width     最大宽度
 *  @param bTextView 是否为 UITextView
 *
 *  @return 返回size
 */
- (CGSize)getSizeWithFont:(UIFont*)font maxWidth:(NSInteger)width textview:(BOOL)bTextView;
- (CGSize)getSizeWithFont:(UIFont*)font textview:(BOOL)bTextView;


@end


@interface NSData (Base64)

/** NSData 的 base64 编码解码 */
+ (NSData *)dataWithBase64EncodedString:(NSString *)string;
- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)base64EncodedString;

@end

