//
//  DatabaseManager.m
//  RNTemplat
//
//  Created by User on 2018/12/3.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "DatabaseManager.h"
#import "FMDB.h"
//导入头文件
#import <objc/runtime.h>

@interface DatabaseManager ()
{
  //数据库对象
  FMDatabaseQueue *_database;
}

@end

@implementation DatabaseManager

/*
 在iOS里面，数据就是sqlite.
 FMDB是对sqlite操作的封装，需要导入库：libsqlite3.0.tbd或者libsqlite3.tbd
 */
- (instancetype)init
{
  self = [super init];
  if (self) {
    
    //指定数据库路径
    _database = [FMDatabaseQueue databaseQueueWithPath:[self databasePath]];
#ifdef DEBUG
    NSLog(@"%@",[self databasePath]);
#endif
    
  }
  
  return self;
}

+ (instancetype)databaseManager
{
  static DatabaseManager *manager = nil;
  
  //只执行一次,线程安全。
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    manager = [[self alloc] init];
  });
  
  return manager;
}

#pragma mark - 数据库保存路径
- (NSString *)databasePath
{
  //获取cache目录
  NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
  
  //.db表示数据库文件
  return [cachePath stringByAppendingPathComponent:@"khdata.db"];
}

#pragma mark - 判断当前表是否存在
- (BOOL)isExistCurrentTableInDatabaseWithTableName:(NSString *)tableName
{
    __block BOOL success = NO;
    [_database inDatabase:^(FMDatabase *  db) {
       // [db open];
        //sqlite_master表是系统创建的，保存其他表的信息
        NSString *sql = [NSString stringWithFormat:@"select name from sqlite_master where type = 'table' and name = '%@'",tableName];
        //执行sql语句
        FMResultSet *results = [db executeQuery:sql];
        success = results.next;
        //[db close];
        
    }];
    return success;
  
}

#pragma mark - 动态获取指定类属性
- (NSArray *)propertiesFromClass:(Class)class
{
  //属性列表
  NSMutableArray *propertyArray = [NSMutableArray array];
  
  //属性个数
  unsigned int outCount;
  //获取属性的结构体指针
  objc_property_t *properties = class_copyPropertyList(class, &outCount);
  
  //遍历所有属性
  for (int i = 0; i < outCount; i++)
  {
    //获取属性的结构体
    objc_property_t property = properties[i];
    //获取属性名字
    const char *name = property_getName(property);
    
    [propertyArray addObject:[NSString stringWithUTF8String:name]];
  }
  
  return propertyArray;
}

#pragma mark - 创建表
- (BOOL)createTableInDatabaseWithObject:(id)object
{
    __block BOOL success = NO;
    [_database inDatabase:^(FMDatabase *  db) {
  //[db open];
  Class cls = [object class];
  //表名
  NSString *tableName = NSStringFromClass(cls);
  
  //动态获取属性
  NSArray *properties = [self propertiesFromClass:cls];
  
  //创建表
  __block NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement",tableName];
  
  //create table if not exists %@ (id integer primary key autoincrement,name text,age text, address text);
  //拼接sql语句
  [properties enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    sql = [sql stringByAppendingFormat:@",%@ text",obj];
  }];
  
  sql = [sql stringByAppendingString:@")"];
  
  //执行sql语句
  success = [db executeUpdate:sql];
  //[db close];
    }];
  return success;
  
}

#pragma mark - 插入到数据库
/**
 *  插入到数据库
 *
 *  @param object <#object description#>
 *
 *  @return <#return value description#>
 */
- (BOOL)insertObjectToDatabaseWithObejct:(id)object
{
  //1.先打开数据库
 
  
  //2.判断当前表是否存在，如果不存在，先创建表然后在插入数据，如果已经存在，直接插入数据
  /*
   表和模型建立一个映射关系：表名 = 类名   属性 = 表字段
   */
  Class class = [object class];
  
  NSString *tableName = NSStringFromClass(class);
  
  if (![self isExistCurrentTableInDatabaseWithTableName:tableName])
  {
    //如果当前数据库不存在当前表，就创建
    [self createTableInDatabaseWithObject:object];
  }
    __block BOOL insertSuccess = NO;
    [_database inDatabase:^(FMDatabase *  db) {
//  if (![db open])
//  {
//    return ;
//  }
  //获取所有的属性
  NSArray *properties = [self propertiesFromClass:class];
  
  //3.执行sql语句
  NSMutableString *keySql = [NSMutableString stringWithFormat:@"insert into %@ (", tableName];
  NSMutableString *valueSql = [NSMutableString stringWithString:@" values ("];
  
  //insert into XXX (key1,key2) values ('xx','xx')
  [properties enumerateObjectsUsingBlock:^(id  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
    
    if (idx == properties.count - 1)
    {
      [keySql appendFormat:@"%@)",key];
      [valueSql appendFormat:@"'%@')",[object valueForKey:key]];
    }
    else
    {
      [keySql appendFormat:@"%@,",key];
      [valueSql appendFormat:@"'%@',",[object valueForKey:key]];
    }
  }];
  [keySql appendString:valueSql];    //执行sql语句
  insertSuccess = [db executeUpdate:keySql];
  
  //4.关闭数据库
  //[_database close];
    }];
  
  return insertSuccess;
}

//************************************************************************************************//

- (NSString *)conditionStringFromCondition:(NSDictionary *)condition
{
  NSMutableString *conditionString = [NSMutableString string];
  
  NSArray *keys = condition.allKeys;
  
  for (int i = 0; i < keys.count; i++)
  {
    NSString *key = keys[i];
    
    if (i == condition.count - 1)
    {
      [conditionString appendFormat:@" %@='%@'",key,condition[key]];
    }
    else
    {
      [conditionString appendFormat:@" %@='%@' and",key,condition[key]];
    }
  }
  
  return conditionString;
}

#pragma mark - 条件查询
/**
 *  条件查询
 *
 *  @param tableName 表名
 *  @param condition 查询条件
 *
 *  @return <#return value description#>
 */
- (NSArray *)queryObjectsFromDatabaseWithTableName:(NSString *)tableName condition:(NSDictionary *)condition
{

  
  __block NSMutableArray *objectArray = [NSMutableArray array];
    [_database inDatabase:^(FMDatabase *  db) {
//          if (![db open])
//          {
//              objectArray = nil;
//            return;
//          }
        //获取属性的名字
        NSArray *properties = [self propertiesFromClass:NSClassFromString(tableName)];
        
        //sql
        NSString *sql = [NSString stringWithFormat:@"select * from %@",tableName];
        //条件查询
        if (condition)
        {
            NSString *conditionString = [self conditionStringFromCondition:condition];
            
            sql = [NSString stringWithFormat:@"select * from %@ where %@",tableName,conditionString];
        }
        
        
        //执行sql
        FMResultSet *results = [db executeQuery:sql];
        
        while (results.next)
        {
            //创建一个对象
            id object = [[NSClassFromString(tableName) alloc] init];
            
            for (NSString *property in properties)
            {
                //从数据库里面取值
                NSString *value = [results stringForColumn:property];
                
                //对象赋值
                [object setValue:value forKey:property];
                
            }
            
            [objectArray addObject:object];
        }
        
        //[db close];
    }];
  
  
  
  return objectArray;
}

#pragma mark - 查询所有的数据
/**
 *  查询所有的数据
 *
 *  @param tableName <#talbeName description#>
 *
 *  @return <#return value description#>
 */
- (NSArray *)queryAllObjectsFromDatabaseWithTableName:(NSString *)tableName
{
  return [self queryObjectsFromDatabaseWithTableName:tableName condition:nil];
}

-(NSArray *)queryObjectsFromDatabaseWithSql:(NSString *)sql tableName:(NSString *)tableName{
  __block NSMutableArray *objectArray = [NSMutableArray array];
    [_database inDatabase:^(FMDatabase *  db) {
//        if (![db open])
//        {
//            objectArray = nil;
//            return;
//        }
      
        //获取属性的名字
        NSArray *properties = [self propertiesFromClass:NSClassFromString(tableName)];
        
        //执行sql
        FMResultSet *results = [db executeQuery:sql];
        
        while (results.next)
        {
            //创建一个对象
            id object = [[NSClassFromString(tableName) alloc] init];
            
            for (NSString *property in properties)
            {
                //从数据库里面取值
                NSString *value = [results stringForColumn:property];
                
                //对象赋值
                [object setValue:value forKey:property];
                
            }
            
            [objectArray addObject:object];
        }
        
        //[db close];
    }];
    
  
  return objectArray;
}

#pragma mark - 删除所有的数据
/**
 *  删除所有的数据
 *
 *  @param tableName <#tableName description#>
 *
 *  @return <#return value description#>
 */
- (BOOL)deleteAllObjectsFromDatabaseWithTableName:(NSString *)tableName
{
    __block BOOL deleteSuccess = NO;
    [_database inDatabase:^(FMDatabase *  db) {
//        if (![db open])
//        {
//            return;
//        }
      
        NSString *sql = [NSString stringWithFormat:@"delete from %@",tableName];
        
        deleteSuccess = [db executeUpdate:sql];
        
        //[db close];
    }];
  
  
  return deleteSuccess;
}

#pragma mark - 条件删除
/**
 *  条件删除
 *
 *  @param tableName 表名
 *  @param condition 查询条件
 */
- (BOOL)deleteObjectsFromDatabaseWithTableName:(NSString *)tableName condition:(NSDictionary *)condition
{
    __block BOOL deleteSuccess = NO;
    [_database inDatabase:^(FMDatabase * db) {
//        if (![db open])
//        {
//            return;
//        }
      
        //sql
        NSString *sql = [NSString string];
        //条件查询
        if (condition)
        {
            NSString *conditionString = [self conditionStringFromCondition:condition];
            
            sql = [NSString stringWithFormat:@"delete from %@ where %@",tableName,conditionString];
        }
        
        deleteSuccess = [db executeUpdate:sql];
        
        //[db close];
    }];
  
  
  return deleteSuccess;
}

@end
