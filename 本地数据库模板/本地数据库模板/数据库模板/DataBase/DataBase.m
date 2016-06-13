//
//  DataBase.m
//  JiaZhangHui
//
//  Created by zuoweijie on 14-10-11.
//  Copyright (c) 2014年 学而思. All rights reserved.
//

#import "DataBase.h"
#import "NSString+Extension.h"
#import <UIKit/UIKit.h>

@implementation DataBase

static sqlite3*	mainDataBase = nil;
static bool dataBaseIsOpening;

#pragma mark -
#pragma mark -----Open & Close-----
NSString* documentsDirectoryWithFileName(NSString*	fileName)
{
//    NSArray*	paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString*	documentsDirectory = [paths objectAtIndex:0];
//    NSString*	directoryString = [documentsDirectory stringByAppendingPathComponent:fileName];
//    
//    return	directoryString;
    
    
    if ([[[UIDevice currentDevice] systemName] floatValue] <= 5.0)
    {
        return [NSString stringWithFormat:@"%@/Library/Caches/%@",
                  NSHomeDirectory(),fileName];
    }
    

     return  [NSString stringWithFormat:@"%@/Library/%@/%@",
                  NSHomeDirectory(),
                  [[NSBundle mainBundle] bundleIdentifier],fileName];
}

/**
 *打开数据库封装
 **/
+(void)openDataBase
{
    /**
     *打开数据库
     */
    BOOL ifSuccess = [DataBase	openDataBase:@"DataBase.db"];
    if(ifSuccess)
    {
        //NSLog(@"成功打开数据库");
    }
    else
    {
        //NSLog(@"数据库打开失败");
        /**
         *打不开，关闭
         */
        [DataBase closeDataBase];
    }
}

/**
 *打开数据库
 **/
+(BOOL)openDataBase:(NSString*)databaseName
{
    NSString*	databasePath = documentsDirectoryWithFileName(databaseName);
    
    if(sqlite3_open([databasePath UTF8String], &mainDataBase))
    {
        sqlite3_close(mainDataBase);
        mainDataBase = nil;
        //NSLog(@"Data Base Open Failed")
        dataBaseIsOpening=NO;
        return	NO;
    }
    
    dataBaseIsOpening = YES;
    
    return	YES;
}


/**
 *关闭数据库
 **/
+(void)closeDataBase
{
    if(mainDataBase != nil)
    {
        sqlite3_close(mainDataBase);
        mainDataBase = nil;
    }
}



/**
 *数据库是不是正在被打开着
 **/
+(BOOL)dataBaseIsOpening;
{
    return dataBaseIsOpening;
}

//验证某个表格是否存在
+(BOOL)checkTableExists:(NSString *)name
{
    char *err;
    
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM sqlite_master where type='table' and name='%@'",name];
    
    const char *sql_stmt = [sql UTF8String];
    
    if(sqlite3_exec(mainDataBase, sql_stmt, NULL, NULL, &err) == 1)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

//创建表格,不存在就创建
+(void)createTable
{
    NSArray *tables = [NSArray arrayWithObjects:@"GRADE_TABLE",@"TERM_TABLE",@"SUBJECT_TABLE",@"DEFAULTPAGE_TABLE", nil];
    
    for (NSString *tablename in tables)
    {
        if(![self checkTableExists:tablename])
        {
            NSString *SQL = nil;
            
            if([tablename isEqualToString:@"GRADE_TABLE"])
            {
                SQL = @"CREATE TABLE IF NOT EXISTS GRADE_TABLE (GRADE_ID TEXT, GRADE_NAME TEXT, DATA TEXT,GRADE_SELECTED TEXT)";
            }
            else if([tablename isEqualToString:@"TERM_TABLE"])
            {
                SQL = @"CREATE TABLE IF NOT EXISTS TERM_TABLE (TERM_ID TEXT, TERM_NAME TEXT, TERM_YEAR TEXT,DATA TEXT,TERM_SELECTED TEXT)";
            }
            else if([tablename isEqualToString:@"SUBJECT_TABLE"])
            {
                SQL = @"CREATE TABLE IF NOT EXISTS SUBJECT_TABLE (GRADE_ID TEXT,GRADE_NAME TEXT, SUBJECT_ID TEXT, SUBJECT_NAME TEXT, CLASSES_ID TEXT,CLASSES_NAME TEXT,DATA TEXT,SUBJECT_SELECTED TEXT)";
            }
            else if([tablename isEqualToString:@"DEFAULTPAGE_TABLE"])
            {
                SQL = @"CREATE TABLE IF NOT EXISTS DEFAULTPAGE_TABLE (URL_PATH TEXT, FILE_NAME TEXT, START_TIME TEXT, END_TIME TEXT)";
            }
            
            char *errMsg = NULL;
            
            if(sqlite3_exec(mainDataBase, [SQL UTF8String], NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"%@ 表格创建失败! 失败原因:%s",tablename,errMsg);
            }
        }
    }
}

/***************** 增 *******************/
+(void)insertRecord:(DATABASE_TABLE_TYPE)type array:(id)recordArr
{    
    //获取现在的时间
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
    NSString *curTime = [NSString stringWithFormat:@"%lld",(long long)timeInMiliseconds*1000];
    NSArray *arr = nil;NSString *gradename = nil;NSString *gradeid = nil;
    
    //取有效的数据源
    if(type == GRADE_TABLE_TYPE || type == TERM_TABLE_TYPE)
        arr = (NSArray *)recordArr;
    else
    {
        NSDictionary *dict = (NSDictionary *)recordArr;
        gradename = [NSString safeString:[dict objectForKey:@"grd_name"]];
        gradeid = [NSString safeString:[dict objectForKey:@"grd_id"]];
        arr = [dict objectForKey:@"subject"];
    }
    
    
    for (NSDictionary *info in arr)
    {
        NSString *sql_str = nil;
        
        if(type == GRADE_TABLE_TYPE || type == TERM_TABLE_TYPE)
        {
            if(type == GRADE_TABLE_TYPE)
                sql_str = [NSString stringWithFormat:@"INSERT INTO GRADE_TABLE(GRADE_ID, GRADE_NAME, DATA)VALUES('%@','%@','%@')",[NSString safeString:[info objectForKey:@"grd_id"]],[NSString safeString:[info objectForKey:@"grd_name"]],curTime];
            else
                sql_str = [NSString stringWithFormat:@"INSERT INTO TERM_TABLE(TERM_ID, TERM_NAME, TERM_YEAR,DATA)VALUES('%@','%@','%@','%@')",[NSString safeString:[info objectForKey:@"cla_term_id"]],[NSString safeString:[info objectForKey:@"cla_term_name"]],[NSString safeString:[info objectForKey:@"cla_year"]],curTime];
            
            char *errMsg = NULL;
            
            if(sqlite3_exec(mainDataBase, [sql_str UTF8String], NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"插入数据失败! 失败原因:%s",errMsg);
            }
        }
        else
        {
            NSArray *levels = [info objectForKey:@"level"];
            
            if([levels isKindOfClass:[NSArray class]] && [levels count])
            {
                for (NSDictionary *levelDic in levels)
                {
                    sql_str = [NSString stringWithFormat:@"INSERT INTO SUBJECT_TABLE(GRADE_ID, GRADE_NAME, SUBJECT_ID, SUBJECT_NAME, CLASSES_ID,CLASSES_NAME,DATA)VALUES('%@','%@','%@','%@','%@','%@','%@')",gradeid,gradename,[NSString safeString:[info objectForKey:@"cla_subject_ids"]],[NSString safeString:[info objectForKey:@"cla_subject_names"]],[NSString safeString:[levelDic objectForKey:@"lev_degree"]],[NSString safeString:[levelDic objectForKey:@"lev_name"]],curTime];
                    
                    char *errMsg = NULL;
                    if(sqlite3_exec(mainDataBase, [sql_str UTF8String], NULL, NULL, &errMsg) != SQLITE_OK)
                    {
                        NSLog(@"插入数据失败! 失败原因:%s",errMsg);
                    }
                }
            }
            else
            {
                sql_str = [NSString stringWithFormat:@"INSERT INTO SUBJECT_TABLE(GRADE_ID,GRADE_NAME,SUBJECT_ID, SUBJECT_NAME, CLASSES_ID,CLASSES_NAME,DATA)VALUES('%@','%@','%@','%@','%@','%@','%@')",gradeid,gradename,[NSString safeString:[info objectForKey:@"cla_subject_ids"]],[NSString safeString:[info objectForKey:@"cla_subject_names"]],@"",@"",curTime];
                
                char *errMsg = NULL;
                
                if(sqlite3_exec(mainDataBase, [sql_str UTF8String], NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"插入数据失败! 失败原因:%s",errMsg);
                }
            }
        }
    }
}

/***************** 删 *******************/

+(void)clearAllContent
{
    NSArray *tables = [NSArray arrayWithObjects:@"GRADE_TABLE",@"TERM_TABLE",@"SUBJECT_TABLE", nil];
    
    for (NSString *tablename in tables)
    {
        NSString *sql_str = [NSString stringWithFormat:@"delete from '%@'",tablename];
        
        char *errMsg = NULL;
        
        if(sqlite3_exec(mainDataBase, [sql_str UTF8String], NULL, NULL, &errMsg) != SQLITE_OK)
        {
            NSLog(@"%@ 表格清空失败! 失败原因:%s",tablename,errMsg);
        }
    }
}


/*
 * 在XXtable中查找是否存在XX字段
 */
+(BOOL)checkTable:(NSString *)tableName isExistColumn:(NSString *)columName
{
    NSString *SQLString = [NSString stringWithFormat:@"PRAGMA TABLE_INFO('%@')",tableName];
    
    sqlite3_stmt *stmt = NULL;
    
    if(sqlite3_prepare_v2(mainDataBase, [SQLString UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            int index = 0;
            
            if([tableName isEqualToString:@"GRADE_TABLE"])
            {
                index = 3;
             }
            else if([tableName isEqualToString:@"TERM_TABLE"])
            {
                index = 4;
            }
            else if([tableName isEqualToString:@"SUBJECT_TABLE"])
            {
                index = 8;
            }
            else
            {
                sqlite3_finalize(stmt);
                return NO;
            }
            
            const char *c_name = (const char *)sqlite3_column_text(stmt, index);
            
            NSString *name = [NSString stringWithUTF8String:c_name];
            BOOL ret = [name isEqualToString:columName];
            sqlite3_finalize(stmt);
            return ret;
        }
    }
    
    sqlite3_finalize(stmt);
    
    return NO;
}

/*
 * 在XXTable中插入XX字段
 */
+(void)insertColumn:(NSString *)columName inTable:(NSString *)tableName
{
    NSString *SQLString = [NSString stringWithFormat:@"ALTER TABLE '%@' ADD '%@' TEXT(200)",tableName,columName];
    
    char *errMsg = NULL;
    
    if(sqlite3_exec(mainDataBase, [SQLString UTF8String], NULL, NULL, &errMsg) != SQLITE_OK)
    {
        NSLog(@"INSERT TABLE %@ COLUM %@ FAILED %s !",tableName,columName,errMsg);
    }
}


//执行指定的语句是否有数据
+(NSInteger)executeCaseGetCount:(NSString *)selectString
{
    sqlite3_stmt *statement = NULL;NSInteger total = 0;
    
    if(sqlite3_prepare_v2(mainDataBase, [selectString UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW) total = sqlite3_column_int(statement,0);
    }
    sqlite3_finalize(statement);
    
    return total;
}



//检查默认启动页
+(BOOL)checkDefaultPageHaveData
{
    NSString *selectSQL = @"SELECT COUNT(*) FROM DEFAULTPAGE_TABLE";
    NSInteger count = [DataBase executeCaseGetCount:selectSQL];
    return count == 0 ? NO : YES;
}

//获取数据
+(NSMutableArray *)getDefaultPageData
{
    NSMutableArray *dataArray = [NSMutableArray array];
    NSString *selectSQL = @"SELECT *FROM DEFAULTPAGE_TABLE";
    sqlite3_stmt *stmt = NULL;
    if(sqlite3_prepare_v2(mainDataBase, [selectSQL UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            const char *c_url_path = (const char *)sqlite3_column_text(stmt, 0);
            NSString *url_path = [NSString stringWithUTF8String:c_url_path];
            
            const char *c_file_name = (const char *)sqlite3_column_text(stmt, 1);
            NSString *file_name = [NSString stringWithUTF8String:c_file_name];
            
            const char *c_start_time = (const char *)sqlite3_column_text(stmt, 2);
            NSString *start_time = [NSString stringWithUTF8String:c_start_time];
            
            const char *c_end_time = (const char *)sqlite3_column_text(stmt, 3);
            NSString *end_time = [NSString stringWithUTF8String:c_end_time];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:url_path,@"url_path",file_name,@"file_name",start_time,@"start_time",end_time,@"end_time", nil];
            [dataArray addObject:dict];
        }
    }
    sqlite3_finalize(stmt);
    return dataArray;
}

//删除一条记录
+(void)deleteDefaultRecord:(NSString *)name
{
    NSString *sql_str = [NSString stringWithFormat:@"DELETE FROM DEFAULTPAGE_TABLE WHERE FILE_NAME='%@'",name];
    char *errMsg = NULL;
    if(sqlite3_exec(mainDataBase, [sql_str UTF8String], NULL, NULL, &errMsg) != SQLITE_OK)
    {
        NSLog(@"删除启动页信息数据失败!");
    }
}

//查询一条记录
+(NSMutableDictionary *)checkARecord:(NSString *)name
{
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
    NSString *sql_str = [NSString stringWithFormat:@"SELECT *FROM DEFAULTPAGE_TABLE WHERE FILE_NAME='%@'",name];
    
    sqlite3_stmt *stmt = NULL;
    if(sqlite3_prepare_v2(mainDataBase, [sql_str UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            const char *c_url_path = (const char *)sqlite3_column_text(stmt, 0);
            NSString *url_path = [NSString stringWithUTF8String:c_url_path];
            
            const char *c_file_name = (const char *)sqlite3_column_text(stmt, 1);
            NSString *file_name = [NSString stringWithUTF8String:c_file_name];
            
            const char *c_start_time = (const char *)sqlite3_column_text(stmt, 2);
            NSString *start_time = [NSString stringWithUTF8String:c_start_time];
            
            const char *c_end_time = (const char *)sqlite3_column_text(stmt, 3);
            NSString *end_time = [NSString stringWithUTF8String:c_end_time];
            
            infoDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:url_path,@"url_path",file_name,@"file_name",start_time,@"start_time",end_time,@"end_time", nil];
        }
    }
    
    sqlite3_finalize(stmt);
    
    return infoDict;
}

+(void)insertDefaultRecord:(NSDictionary *)dict
{
    NSString *selectString = [NSString stringWithFormat:@"INSERT INTO DEFAULTPAGE_TABLE(URL_PATH, FILE_NAME,START_TIME,END_TIME)VALUES('%@','%@','%@','%@')",[NSString safeString:[dict objectForKey:@"imagepath"]],[NSString safeString:[dict objectForKey:@"filename"]],[NSString safeString:[dict objectForKey:@"beginDate"]],[NSString safeString:[dict objectForKey:@"endDate"]]];
    
    char *errMsg = NULL;
    
    if(sqlite3_exec(mainDataBase, [selectString UTF8String], NULL, NULL, &errMsg) != SQLITE_OK)
    {
        NSLog(@"插入默认启动页信息失败====  errMsg:%s",errMsg);
    }
}

+(void)clearDefaultPageData
{
    NSString *sql_str = @"DELETE FROM DEFAULTPAGE_TABLE";
    
    char *errMsg = NULL;
    
    if(sqlite3_exec(mainDataBase, [sql_str UTF8String], NULL, NULL, &errMsg) != SQLITE_OK)
    {
        NSLog(@"DEFAULTPAGE_TABLE 表格清空失败! 失败原因:%s",errMsg);
    }
}


@end
