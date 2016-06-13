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


@interface XRSDataBase : NSObject

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
 * 清理年级数据
 */
+(void)clearGradeData;

/*
 * 清理学期数据
 */
+(void)clearTermData;

/*
 * 清理学科
 */
+(void)clearSubjectData:(NSString *)gradeid;

/*
 * 获取年级记录时间
 */
+(NSString *)getGradeData;

/*
 * 获取学期记录时间
 */
+(NSString *)getTermData;

/*
 * 获取年级下的学科
 */
+(NSString *)getSubjectData:(NSString *)gradeID;

/*
 * 检查年级列表是否有数据
 */
+(BOOL)checkGradeHavaData;

/*
 * 检查学期列表是否有数据
 */
+(BOOL)checkTermHaveData;

/*
 * 根据学期ID获取学科
 */
+(BOOL)checkSubjectHaveData:(NSString *)gradeid;

/*
 * 获取年级列表
 */
+(NSMutableArray *)getGradelist;

/*
 * 获取学期列表
 */
+(NSMutableArray *)getTermlist;

/*
 * 根据年级ID获取学科列表
 */
+(NSMutableArray *)getSubjectlist:(NSString *)gradeID;

/*
 * 根据年级ID和学科名获取班次列表
 */
+(NSMutableArray *)getClasseslist:(NSString *)gradeID subjectID:(NSString *)subjectID;

/*
 * 在XXtable中查找是否存在XX字段
 */
+(BOOL)checkTable:(NSString *)tableName isExistColumn:(NSString *)columName;

/*
 * 在XXTable中插入XX字段
 */
+(void)insertColumn:(NSString *)columName inTable:(NSString *)tableName;

/*
 * 获取最后一次的记录
 */
+(NSMutableDictionary *)getRecordAtLasTime:(NSString *)tablename;

/*
 * 清空选中状态
 */
+(void)clearSelected:(NSString *)tablename;

/*
 * 置位某个年级为最后一次选中
 */
+(void)setSelected:(NSString *)ID classlevelID:(NSString *)classlevelID ideString:(NSString *)ideString tablename:(NSString *)tablename;

/*
 * 指定的表格是否有指定的ID
 */
+(BOOL)checkID:(NSString *)tableName aID:(NSString *)aID ideString:(NSString *)ideString;

/*
 * 指定学科和年级下选中类型
 */
+(NSMutableDictionary *)checkSelectClasslevelHaveData:(NSString *)subjectname gradeID:(NSString *)gradeID;

//根据学科名和年级ID获取班次列表
+(NSMutableArray *)getClasslevelsBySubjectname:(NSString *)subjectname gradeID:(NSString *)gradeID classlevelID:(NSString *)classlevelID;

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
