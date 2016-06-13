//
//  XesFileManager.h
//  XesSpeiyouSystemClient
//
//  Created by zhouyan on 13-3-1.
//  Copyright (c) 2013年 XueErSi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject
+(NSString *)appDocumentPath;
+(NSString *)appTmpPath;
+(NSString *)appCachePath;
+(NSString *)appSupportPath;
+(void)deleteFileWithPath:(NSString *)filePath;
+(NSInteger)getFileSizeWithPath:(NSString *)filePath;
+(BOOL)createDirectory:(NSString *)filePath;
+ (NSArray*)contentsOfDirectoryAtPath:(NSString*)path;
+ (BOOL)isFileExist:(NSString*)filePath;
+ (BOOL)createFile:(NSString*)filePath content:(NSData*)data;
+ (BOOL)renameFile:(NSString*)src toDest:(NSString*)dest;
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;
//保存城市相关的信息
+ (void)saveCityInfos:(NSDictionary*)cityInfos;
//读取城市相关的信息
+ (NSDictionary*)cityInfos;
@end
