//
//  XRSDataBase.m
//  JiaZhangHui
//
//  Created by zuoweijie on 14-10-11.
//  Copyright (c) 2014年 学而思. All rights reserved.
//

#import "XRSDataBase.h"
#import "NSString+Extension.h"

@implementation XRSDataBase

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
    BOOL ifSuccess = [XRSDataBase	openDataBase:@"XRSDataBase.db"];
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
        [XRSDataBase closeDataBase];
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

/*
 * 获取年级日期时间
 */
+(NSString *)getGradeData
{    
    if([XRSDataBase checkGradeHavaData])
    {
        NSString *SQLStr = @"SELECT *FROM GRADE_TABLE";
        
        sqlite3_stmt *statement = NULL;
        
        if(sqlite3_prepare_v2(mainDataBase, [SQLStr UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                const char *c_data = (const char *)sqlite3_column_text(statement, 2);
                
                NSString *data = [NSString stringWithUTF8String:c_data];
                
                sqlite3_finalize(statement);
                
                return data;
            }
        }
    }
    
    return nil;
}

/*
 * 获取学期时间
 */
+(NSString *)getTermData
{
    if([XRSDataBase checkTermHaveData])
    {
        NSString *SQLStr = @"SELECT *FROM TERM_TABLE";
        
        sqlite3_stmt *statement = NULL;
        
        if(sqlite3_prepare_v2(mainDataBase, [SQLStr UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                const char *c_data = (const char *)sqlite3_column_text(statement, 3);
                
                NSString *data = [NSString stringWithUTF8String:c_data];
                
                sqlite3_finalize(statement);
                
                return data;
            }
        }
    }
    
    return nil;
}

/*
 * 获取学科下的时间
 */
+(NSString *)getSubjectData:(NSString *)gradeID
{
    if([XRSDataBase checkSubjectHaveData:gradeID])
    {
        NSString *SQLStr = @"SELECT *FROM SUBJECT_TABLE";
        
        sqlite3_stmt *statement = NULL;
        
        if(sqlite3_prepare_v2(mainDataBase, [SQLStr UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                const char *c_data = (const char *)sqlite3_column_text(statement, 6);
                
                NSString *data = [NSString stringWithUTF8String:c_data];
                
                sqlite3_finalize(statement);
                
                return data;
            }
        }
    }
    
    return nil;
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

+(void)clearGradeData
{
    NSString *sql_str = @"DELETE FROM GRADE_TABLE";
    
    char *errMsg = NULL;
    
    if(sqlite3_exec(mainDataBase, [sql_str UTF8String], NULL, NULL, &errMsg) != SQLITE_OK)
    {
        NSLog(@"GRADE_TABLE 表格清空失败! 失败原因:%s",errMsg);
    }
}

+(void)clearTermData
{
    NSString *sql_str = @"DELETE FROM TERM_TABLE";
    
    char *errMsg = NULL;
    
    if(sqlite3_exec(mainDataBase, [sql_str UTF8String], NULL, NULL, &errMsg) != SQLITE_OK)
    {
        NSLog(@"TERM_TABLE 表格清空失败! 失败原因:%s",errMsg);
    }
}

+(void)clearSubjectData:(NSString *)gradeid
{
    NSString *sql_str = [NSString stringWithFormat:@"DELETE FROM SUBJECT_TABLE WHERE GRADE_ID='%@'",gradeid];

    char *errMsg = NULL;
    
    if(sqlite3_exec(mainDataBase, [sql_str UTF8String], NULL, NULL, &errMsg) != SQLITE_OK)
    {
        NSLog(@"TERM_TABLE 表格清空失败! 失败原因:%s",errMsg);
    }
}

/***************** 查 *******************/

//查年级列表是否有数据
+(BOOL)checkGradeHavaData
{
    sqlite3_stmt *statement = NULL;
    
    if(sqlite3_prepare_v2(mainDataBase, "select count (*) from GRADE_TABLE", -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSInteger count = sqlite3_column_int(statement,0);
            
            sqlite3_finalize(statement);
        
            return count == 0 ? NO : YES;
        }
    }
    
    sqlite3_finalize(statement);
    
    return NO;
}

//查学期列表是否有数据
+(BOOL)checkTermHaveData
{
    sqlite3_stmt *statement = NULL;
    
    if(sqlite3_prepare_v2(mainDataBase, "select count (*) from TERM_TABLE", -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSInteger count = sqlite3_column_int(statement,0);
            sqlite3_finalize(statement);
            return count == 0 ? NO : YES;
        }
    }
    
    sqlite3_finalize(statement);
    
    return NO;
}

//查指定年级下是否有学科列表
+(BOOL)checkSubjectHaveData:(NSString *)gradeid
{
    sqlite3_stmt *statement = NULL;
    
    NSString *selectStr = [NSString stringWithFormat:@"select count (*) from SUBJECT_TABLE where GRADE_ID = '%@'",gradeid];
    
    if(sqlite3_prepare_v2(mainDataBase, [selectStr UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSInteger count = sqlite3_column_int(statement,0);
            
            sqlite3_finalize(statement);
            
            return count == 0 ? NO : YES;
        }
    }
    
    sqlite3_finalize(statement);
    
    return NO;
}

/***************** 取数据 *******************/

//年级列表
+(NSMutableArray *)getGradelist
{
    sqlite3_stmt *statement = NULL;
    
    NSMutableArray *arr = [NSMutableArray array];
    
    NSString *sql_str = @"SELECT *FROM GRADE_TABLE";
    
    if (sqlite3_prepare_v2(mainDataBase, [sql_str UTF8String], -1, &statement, nil) ==
        SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            const char *c_grd_id = (const char *)sqlite3_column_text(statement, 0);
            NSString *grd_id = [NSString stringWithUTF8String:c_grd_id];
            
            const char *c_grd_name = (const char *)sqlite3_column_text(statement, 1);
            NSString *grd_name = [NSString stringWithUTF8String:c_grd_name];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:grd_id,@"grd_id",grd_name,@"grd_name", nil];
            [arr addObject:dict];
        }
    }
    
    sqlite3_finalize(statement);
    
    return arr;
}

//获取学期列表
+(NSMutableArray *)getTermlist
{
    sqlite3_stmt *statement = NULL;
    
    NSMutableArray *arr = [NSMutableArray array];
    
    NSString *sql_str = @"SELECT *FROM TERM_TABLE";
    
    //TERM_ID, TERM_NAME, TERM_YEAR
    
    if (sqlite3_prepare_v2(mainDataBase, [sql_str UTF8String], -1, &statement, nil) ==
        SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            const char *c_term_id = (const char *)sqlite3_column_text(statement, 0);
            NSString *term_id = [NSString stringWithUTF8String:c_term_id];
            
            const char *c_term_name = (const char *)sqlite3_column_text(statement, 1);
            NSString *term_name = [NSString stringWithUTF8String:c_term_name];
            
            const char *c_year = (const char *)sqlite3_column_text(statement, 2);
            NSString *year = [NSString stringWithUTF8String:c_year];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:term_id,@"cla_term_id",term_name,@"cla_term_name",year,@"cla_year", nil];
            [arr addObject:dict];
        }
    }
    
    sqlite3_finalize(statement);
    
    return arr;
}

//获取学科列表
+(NSMutableArray *)getSubjectlist:(NSString *)gradeID
{
    sqlite3_stmt *statement = NULL;
    NSMutableArray *arr = [NSMutableArray array];
    NSString *sql_str = [NSString stringWithFormat:@"SELECT *FROM SUBJECT_TABLE WHERE GRADE_ID = '%@'",gradeID];
    if (sqlite3_prepare_v2(mainDataBase, [sql_str UTF8String], -1, &statement, nil) ==
        SQLITE_OK)
    {
        NSString *curSubjectID = nil;
        
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            const char *c_subject_id = (const char *)sqlite3_column_text(statement, 2);
            NSString *subject_id = [NSString stringWithUTF8String:c_subject_id];
        
            if(!curSubjectID || ![curSubjectID isEqualToString:subject_id])
            {
                curSubjectID = subject_id;
                
                const char *c_subject_name = (const char *)sqlite3_column_text(statement, 3);
                NSString *subject_name = [NSString stringWithUTF8String:c_subject_name];
                
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:subject_id,@"cla_subject_ids",subject_name,@"cla_subject_names", nil];
                [arr addObject:dict];
            }            
        }
    }
    
    sqlite3_finalize(statement);
    
    return arr;
}

//获取班次列表
+(NSMutableArray *)getClasseslist:(NSString *)gradeID subjectID:(NSString *)subjectID
{
    sqlite3_stmt *statement = NULL;
    
    NSMutableArray *arr = [NSMutableArray array];
    
    NSString *sql_str = [NSString stringWithFormat:@"SELECT *FROM SUBJECT_TABLE WHERE GRADE_ID = '%@' AND SUBJECT_NAME = '%@'",gradeID,subjectID];
    
    if (sqlite3_prepare_v2(mainDataBase, [sql_str UTF8String], -1, &statement, nil) ==
        SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            const char *c_classes_id = (const char *)sqlite3_column_text(statement, 4);
            NSString *classes_id = [NSString stringWithUTF8String:c_classes_id];
            
            const char *c_classes_name = (const char *)sqlite3_column_text(statement, 5);
            NSString *classes_name = [NSString stringWithUTF8String:c_classes_name];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:classes_id,@"lev_degree",classes_name,@"lev_name", nil];
            
            [arr addObject:dict];
        }
    }
    
    sqlite3_finalize(statement);
    
    return arr;
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

//获取最后一次记录
+(NSMutableDictionary *)getRecordAtLasTime:(NSString *)tablename
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSString *selectSQL = NULL;
    if([tablename isEqualToString:@"GRADE_TABLE"])
    {
        selectSQL = @"select count (*) from GRADE_TABLE WHERE GRADE_SELECTED='1'";
        if([self executeCaseGetCount:selectSQL])
        {
            selectSQL = @"SELECT *FROM GRADE_TABLE WHERE GRADE_SELECTED='1'";
        }
        else
        {
            return dict;
        }
    }
    else if([tablename isEqualToString:@"TERM_TABLE"])
    {
        selectSQL = @"select count (*) from TERM_TABLE WHERE TERM_SELECTED='1'";
        if([self executeCaseGetCount:selectSQL])
        {
            selectSQL = @"SELECT *FROM TERM_TABLE WHERE TERM_SELECTED='1'";
        }
        else
        {
            return dict;
        }
    }
    else if([tablename isEqualToString:@"SUBJECT_TABLE"])
    {
        //1代表选中了学科和年级 2表示上一次仅选中了学科并没有选中班次,即为班次不限
        //如果1、2同时存在那么优先1
        selectSQL = @"select count (*) from SUBJECT_TABLE WHERE SUBJECT_SELECTED='1'";
        if([self executeCaseGetCount:selectSQL])
        {
            selectSQL = @"SELECT *FROM SUBJECT_TABLE WHERE SUBJECT_SELECTED='1'";
        }
        else
        {
            selectSQL = @"select count (*) from SUBJECT_TABLE WHERE SUBJECT_SELECTED='2'";
            if([self executeCaseGetCount:selectSQL])
            {
                selectSQL = @"SELECT *FROM SUBJECT_TABLE WHERE SUBJECT_SELECTED='2'";
            }
            else
            {
                return dict;
            }
        }
    }
    else if([tablename isEqualToString:@"classlevel"])
    {
        //这里是获取班次
        selectSQL = @"select count (*) from SUBJECT_TABLE WHERE SUBJECT_SELECTED='1'";
        if([self executeCaseGetCount:selectSQL])
        {
            selectSQL = @"SELECT *FROM SUBJECT_TABLE WHERE SUBJECT_SELECTED='1'";
        }
        else
        {
            return dict;
        }
    }
    
    sqlite3_stmt *stmt = NULL;
    
    if(sqlite3_prepare_v2(mainDataBase, [selectSQL UTF8String], -1, &stmt, nil) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            int idIndex = 0;
            if([tablename isEqualToString:@"SUBJECT_TABLE"])
                idIndex = 2;
            else if([tablename isEqualToString:@"classlevel"])
                idIndex = 4;
            else
                idIndex = 0;
            const char *c_grade_id = (const char *)sqlite3_column_text(stmt, idIndex);
            NSString *grade_id = [NSString stringWithUTF8String:c_grade_id];
            [dict setObject:grade_id forKey:@"id"];
            
            
            int nameIndex = 0;
            if([tablename isEqualToString:@"SUBJECT_TABLE"])
                nameIndex = 3;
            else if([tablename isEqualToString:@"classlevel"])
                nameIndex = 5;
            else
                nameIndex = 1;
            const char *c_grade_name = (const char *)sqlite3_column_text(stmt, nameIndex);
            NSString *grade_name = [NSString stringWithUTF8String:c_grade_name];
            [dict setObject:grade_name forKey:@"name"];
            
            if([tablename isEqualToString:@"TERM_TABLE"])
            {
                const char *c_term_year = (const char *)sqlite3_column_text(stmt, 2);
                NSString *term_year = [NSString stringWithUTF8String:c_term_year];
                [dict setObject:term_year forKey:@"year"];
            }
            
            sqlite3_finalize(stmt);
            return dict;
        }
    }
    sqlite3_finalize(stmt);
    
    return dict;
}

+(void)clearSelected:(NSString *)tablename
{
    NSString *aSqlString = nil;char *errMsg = NULL;
    if([tablename isEqualToString:@"GRADE_TABLE"])
    {
        aSqlString = @"UPDATE GRADE_TABLE SET GRADE_SELECTED=0";
    }
    else if([tablename isEqualToString:@"TERM_TABLE"])
    {
        aSqlString = @"UPDATE TERM_TABLE SET TERM_SELECTED=0";
    }
    else if([tablename isEqualToString:@"SUBJECT_TABLE"])
    {
        aSqlString = @"UPDATE SUBJECT_TABLE SET SUBJECT_SELECTED=0";
    }
    
    if(sqlite3_exec(mainDataBase, [aSqlString UTF8String], NULL, NULL, &errMsg) != SQLITE_OK)
    {
        NSLog(@"置位老的选中状态失败!");
    }
}

//设置选中
+(void)setSelected:(NSString *)ID classlevelID:(NSString *)classlevelID ideString:(NSString *)ideString tablename:(NSString *)tablename
{
    NSString *bSqliteString = nil; char *errMsg = NULL;
    if([tablename isEqualToString:@"GRADE_TABLE"])
        bSqliteString = [NSString stringWithFormat:@"UPDATE GRADE_TABLE SET GRADE_SELECTED='1' WHERE GRADE_ID='%@'",ID];
    else if([tablename isEqualToString:@"TERM_TABLE"])
        bSqliteString = [NSString stringWithFormat:@"UPDATE TERM_TABLE SET TERM_SELECTED='1' WHERE TERM_ID='%@' AND TERM_YEAR='%@'",ID,ideString];
    else if([tablename isEqualToString:@"SUBJECT_TABLE"])
    {
        if(classlevelID)
            bSqliteString = [NSString stringWithFormat:@"UPDATE SUBJECT_TABLE SET SUBJECT_SELECTED='1' WHERE SUBJECT_NAME='%@' AND CLASSES_ID='%@' AND GRADE_ID='%@'",ID,classlevelID,ideString];
        else
            bSqliteString = [NSString stringWithFormat:@"UPDATE SUBJECT_TABLE SET SUBJECT_SELECTED='2' WHERE SUBJECT_NAME='%@' AND GRADE_ID='%@'",ID,ideString];
    }
    
    if(ID)
    {
        if(sqlite3_exec(mainDataBase, [bSqliteString UTF8String], NULL, NULL, &errMsg) != SQLITE_OK)
        {
            NSLog(@"置位新的选中状态失败!");
        }
    }
}

//查年级列表是否有数据
+(BOOL)checkID:(NSString *)tableName aID:(NSString *)aID ideString:(NSString *)ideString;
{
    NSString *selectSQL = NULL;
    if([tableName isEqualToString:@"GRADE_TABLE"])
    {
        selectSQL = [NSString stringWithFormat:@"select count (*) from GRADE_TABLE where GRADE_ID='%@'",aID];
    }
    else if([tableName isEqualToString:@"TERM_TABLE"])
    {
        selectSQL = [NSString stringWithFormat:@"select count (*) from TERM_TABLE where TERM_ID='%@' AND TERM_YEAR='%@'",aID,ideString];
    }
    else if([tableName isEqualToString:@"SUBJECT_TABLE"])
    {
        selectSQL = [NSString stringWithFormat:@"select count (*) from SUBJECT_TABLE where SUBJECT_NAME='%@' AND GRADE_ID='%@'",aID,ideString];
    }
    
    sqlite3_stmt *statement = NULL;
    if(sqlite3_prepare_v2(mainDataBase, [selectSQL UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSInteger count = sqlite3_column_int(statement,0);
            sqlite3_finalize(statement);
            return count == 0 ? NO : YES;
        }
    }
    
    sqlite3_finalize(statement);
    
    return NO;
}

//取选中班次的信息 0表示班次无选中 1表示班次有一个被选中了 2为学科下的班次都被选中了
+(NSMutableDictionary *)checkSelectClasslevelHaveData:(NSString *)subjectname gradeID:(NSString *)gradeID
{
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM SUBJECT_TABLE WHERE SUBJECT_NAME='%@' AND GRADE_ID='%@' AND SUBJECT_SELECTED='1'",subjectname,gradeID];
    if([XRSDataBase executeCaseGetCount:selectSQL])
    {
        sqlite3_stmt *stmt = NULL;
        if(sqlite3_prepare_v2(mainDataBase, [selectSQL UTF8String], -1, &stmt, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(stmt) == SQLITE_ROW)
            {
                const char *c_classlevel_id = (const char *)sqlite3_column_text(stmt, 4);
                NSString *classlevel_id = [NSString stringWithUTF8String:c_classlevel_id];
                
                const char *c_classlevel_name = (const char *)sqlite3_column_text(stmt, 5);
                NSString *classlevel_name = [NSString stringWithUTF8String:c_classlevel_name];
                
                NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1",@"type",subjectname,@"subject_name",gradeID,@"grade_id",classlevel_id,@"classlevel_id",classlevel_name,@"classlevel_name",nil];
                sqlite3_finalize(stmt);
                return dataDictionary;
            }
        }
    }
    else
    {
        selectSQL = [NSString stringWithFormat:@"SELECT * FROM SUBJECT_TABLE WHERE SUBJECT_NAME='%@' AND GRADE_ID='%@' AND SUBJECT_SELECTED='2'",subjectname,gradeID];
              
        if([XRSDataBase executeCaseGetCount:selectSQL])
        {
            return [NSMutableDictionary dictionaryWithObjectsAndKeys:@"2",@"type", nil];
        }
    }
    
    return [NSMutableDictionary dictionary];
}

//根据学科名和年级ID获取班次列表
+(NSMutableArray *)getClasslevelsBySubjectname:(NSString *)subjectname gradeID:(NSString *)gradeID classlevelID:(NSString *)classlevelID
{
    NSMutableArray *dataArray = [NSMutableArray array];
    
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM SUBJECT_TABLE WHERE SUBJECT_NAME='%@' AND GRADE_ID='%@'",subjectname,gradeID];
    sqlite3_stmt *stmt = NULL;
    if(sqlite3_prepare_v2(mainDataBase, [selectSQL UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            const char *c_classes_id = (const char *)sqlite3_column_text(stmt, 4);
            NSString *classes_id = [NSString stringWithUTF8String:c_classes_id];
            
            const char *c_classes_name = (const char *)sqlite3_column_text(stmt, 5);
            NSString *classes_name = [NSString stringWithUTF8String:c_classes_name];
            
            NSString *type =  @"0";
            if(classlevelID)
            {
                if([classes_id isEqualToString:classlevelID])
                    type = @"1";
                else
                    type = @"0";
            }
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:classes_id,@"id",classes_name,@"name",type,@"type", nil];
            [dataArray addObject:dict];
        }
    }
    
    sqlite3_finalize(stmt);
    
    return dataArray;
}


//检查默认启动页
+(BOOL)checkDefaultPageHaveData
{
    NSString *selectSQL = @"SELECT COUNT(*) FROM DEFAULTPAGE_TABLE";
    NSInteger count = [XRSDataBase executeCaseGetCount:selectSQL];
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
