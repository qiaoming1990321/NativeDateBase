//
//  XesFileManager.m
//  XesSpeiyouSystemClient
//
//  Created by zhouyan on 13-3-1.
//  Copyright (c) 2013年 XueErSi. All rights reserved.
//

#import "FileManager.h"
#import "NSString+Extension.h"

@implementation FileManager

+(NSString *)appDocumentPath{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return documentsDirectory;
}

+(NSString *)appTmpPath{
	NSString *tempPath = NSTemporaryDirectory();
	return tempPath;
}

+(NSString *)appCachePath{
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, //NSDocumentDirectory or NSCachesDirectory
												NSUserDomainMask, //NSUserDomainMask
												YES)	// YES
			objectAtIndex: 0];
}

+(NSString *)appSupportPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *supportDirectory = [paths objectAtIndex:0];
	return supportDirectory;
}

+(void)deleteFileWithPath:(NSString *)filePath{
	if ([NSString isBlankString:filePath]) {
		return;
	}
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:filePath]) {
		[fileManager removeItemAtPath:filePath error:nil];
	}
}

+(NSInteger)getFileSizeWithPath:(NSString *)filePath{
	NSFileManager *fileMgr = [NSFileManager defaultManager];
	if (![fileMgr fileExistsAtPath:filePath]) {
		return 0;
	}
	NSError *error = nil;
	NSDictionary *fileDict = [fileMgr attributesOfItemAtPath:filePath error:&error];
	return [[fileDict objectForKey:@"NSFileSize"] integerValue];
}

+(BOOL)createDirectory:(NSString *)filePath{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:filePath]) {
		return YES;
	}
    
    return [fileMgr createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
}

+(BOOL)moveFile:(NSString*)_src dest:(NSString*)_dest {
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    return [fileMgr moveItemAtPath:_src toPath:_dest error:&error];
}

+ (NSArray*)contentsOfDirectoryAtPath:(NSString*)path
{
    NSFileManager* fm = [NSFileManager defaultManager];
    NSArray *array = [fm contentsOfDirectoryAtPath:path error:nil];
    return array;
}

+ (BOOL)isFileExist:(NSString*)filePath
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
	return [fileMgr fileExistsAtPath:filePath];
}

+ (BOOL)createFile:(NSString*)filePath content:(NSData*)data
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    return [fileManager createFileAtPath:filePath contents:data attributes:nil];
}

+ (BOOL)renameFile:(NSString*)src toDest:(NSString*)dest
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *error;
    BOOL res = [fileManager moveItemAtPath:src toPath:dest error:&error];
    NSLog(@"%s res %d", __func__, res);
    return res;
}


#if defined(__IPHONE_5_1) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_1
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL

{
    
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                    
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    
    if(!success){
        
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        
    }
    
    return success;
    
}
#else
#import <sys/xattr.h>

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL

{
    
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    
    
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    
    
    const char* attrName = "com.apple.MobileBackup";
    
    u_int8_t attrValue = 1;
    
    
    
    NSInteger result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    
    return result == 0;
    
}
#endif

+ (void)saveCityInfos:(NSDictionary*)cityInfos
{
    NSLog(@"cityInfos :%@\n",cityInfos);
    
    NSString *path = [self appDocumentPath];
    NSString *plistPath = [path stringByAppendingPathComponent:@"cityInfo.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:plistPath]) {
        [fileManager createFileAtPath:plistPath contents:nil attributes:nil];
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:plistPath]];
    }
    [cityInfos writeToFile:plistPath atomically:YES];
}

+ (NSDictionary*)cityInfos
{
    NSString *path = [self appDocumentPath];
    NSString *plistPath = [path stringByAppendingPathComponent:@"cityInfo.plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    return dict;
}

@end
