//
//  DatabaseManager.h
//  RNTemplat
//
//  Created by User on 2018/12/3.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface DatabaseManager : NSObject

+ (instancetype)databaseManager;

- (BOOL)isExistCurrentTableInDatabaseWithTableName:(NSString *)tableName;

- (BOOL)createTableInDatabaseWithObject:(id)object;

#pragma mark - 插入到数据库
/**
 *  插入到数据库
 *
 *  @param object <#object description#>
 *
 *  @return <#return value description#>
 */
- (BOOL)insertObjectToDatabaseWithObejct:(id)object;

#pragma mark - 查询所有的数据
/**
 *  查询所有的数据
 *
 *  @param tableName <#talbeName description#>
 *
 *  @return <#return value description#>
 */
- (NSArray *)queryAllObjectsFromDatabaseWithTableName:(NSString *)tableName;

#pragma mark - 条件查询
/**
 *  条件查询
 *
 *  @param tableName 表名
 *  @param condition 查询条件
 *
 *  @return <#return value description#>
 */
- (NSArray *)queryObjectsFromDatabaseWithTableName:(NSString *)tableName condition:(NSDictionary *)condition;

-(NSArray *)queryObjectsFromDatabaseWithSql:(NSString *)sql tableName:(NSString *)tableName;

#pragma mark - 删除所有的数据
/**
 *  删除所有的数据
 *
 *  @param tableName <#tableName description#>
 *
 *  @return <#return value description#>
 */
- (BOOL)deleteAllObjectsFromDatabaseWithTableName:(NSString *)tableName;

#pragma mark - 条件删除
/**
 *  条件删除
 *
 *  @param tableName 表名
 *  @param condition 查询条件
 *
 */
- (BOOL)deleteObjectsFromDatabaseWithTableName:(NSString *)tableName condition:(NSDictionary *)condition;

@end

NS_ASSUME_NONNULL_END
