//
//  XRSDataBase.h
//  JiaZhangHui
//
//  Created by zuoweijie on 14-10-11.
//  Copyright (c) 2014年 学而思. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

typedef enum
{
    GRADE_TABLE_TYPE,
    TERM_TABLE_TYPE,
    SUBJECT_TABLE_TYPE
}DATABASE_TABLE_TYPE;


@interface DataBase : NSObject

/**
 *打开数据库封装
 **/
+(void)openDataBase;


/**
 *打开数据库
 **/
+(BOOL)openDataBase:(NSString*)databaseName;

/**
 *关闭数据库
 **/
+(void)closeDataBase;

/**
 *数据库是不是正在被打开着
 **/
+(BOOL)dataBaseIsOpening;

/*
 * 检查表格是否存在
 */
+(BOOL)checkTableExists:(NSString *)name;

/*
 * 创建表格
 */
+(void)createTable;

/*
 *  插入记录
 */
+(void)insertRecord:(DATABASE_TABLE_TYPE)type array:(id)recordArr;

/*
 * 清理数据
 */
+(void)clearAllContent;

/*
 * 在XXtable中查找是否存在XX字段
 */
+(BOOL)checkTable:(NSString *)tableName isExistColumn:(NSString *)columName;

/*
 * 在XXTable中插入XX字段
 */
+(void)insertColumn:(NSString *)columName inTable:(NSString *)tableName;



//检查默认启动信息是否有数据
+(BOOL)checkDefaultPageHaveData;

//获取数据
+(NSMutableArray *)getDefaultPageData;

//删除一条记录
+(void)deleteDefaultRecord:(NSString *)name;

//查询一条记录
+(NSMutableDictionary *)checkARecord:(NSString *)name;

//插入一条数据
+(void)insertDefaultRecord:(NSDictionary *)dict;

//清空启动页数据库数据
+(void)clearDefaultPageData;

@end
