//
//  KHDataCache.m
//  RNTemplat
//
//  Created by User on 2018/12/4.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "KHDataCache.h"
#import "KHData.h"
#import "DatabaseManager.h"

#define EventClearEvent @"EventClearEvent"
typedef NS_ENUM(NSInteger, QueryType) {
  QueryTypeOld = 0,//查询利旧数据
  QueryTypeYwqqid//根据业务申请id查询影像数据
};


@interface KHDataCache ()
@property (nonatomic,assign) int timeout;
@property (nonatomic,assign,getter=isSetUp) BOOL setUp;
@end

@implementation KHDataCache

RCT_EXPORT_MODULE()

- (NSDictionary *)constantsToExport
{
  return @{
           @"QueryTypeOld": @(QueryTypeOld),
            @"QueryTypeYwqqid":@(QueryTypeYwqqid),
           @"EventClearEvent":EventClearEvent
         };
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[EventClearEvent];
}

- (dispatch_queue_t)methodQueue{
  return dispatch_queue_create("com.apex.khData", DISPATCH_QUEUE_SERIAL);
}

RCT_REMAP_METHOD(setUp,
                 timeout:(int)timeout
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject){
  self.setUp = YES;
  self.timeout = timeout;
  KHData *khData = [KHData new];
  DatabaseManager *manager = [DatabaseManager databaseManager];
  if(![manager isExistCurrentTableInDatabaseWithTableName:NSStringFromClass([KHData class])]){
    if([manager createTableInDatabaseWithObject:khData]){
      resolve(@{@"code":@(1),@"note":@"创建数据库表成功"});
    }else{
      reject(@"-1",@"创建数据库表失败",nil);
    }
    return;
  }
  resolve(@{@"code":@(1),@"note":@"创建数据库表成功"});
}

RCT_REMAP_METHOD(saveData,
                 imageData:(NSString *)data
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject){
  if(!self.isSetUp){
    reject(@"-1",@"请先执行setUp初始化",nil);
    return;
  }
  if(![self isBlankString:data]){
    NSDictionary *dict = [self dictionaryWithJsonString:data];
    if(!dict){
      reject(@"-1",@"json转换失败",nil);
      return;
    }
    KHData *khData = [KHData new];
    NSDate *date = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyyMMdd"];
    khData.rq = [format stringFromDate:date];
    NSTimeInterval currentTime= [date timeIntervalSince1970];
    khData.saveTime = [NSString stringWithFormat :@"%lld",[[NSString stringWithFormat:@"%f",currentTime] longLongValue]];
    NSArray *keys = [dict allKeys];
    __block BOOL isSuccess = YES;
    [keys enumerateObjectsUsingBlock:^(NSString  * key, NSUInteger idx, BOOL *  stop) {
      if([@"images" isEqualToString:key]){
        NSArray *imagesArr = dict[key];
        NSDictionary *imagesDict = @{@"images":imagesArr};
        NSString *images = [self convertToJsonData:imagesDict];
        if(!images){
          *stop = YES;
          isSuccess = NO;
        }else{
          [khData setValue:images forKey:key];
        }
      }else if([@"ext" isEqualToString:key]){
        id ext = dict[key];
        NSDictionary *extDict = @{@"ext":ext};
        NSString *extStr = [self convertToJsonData:extDict];
        if(!extStr){
          *stop = YES;
          isSuccess = NO;
        }else{
          [khData setValue:extStr forKey:key];
        }
      }else{
        [khData setValue:dict[key] forKey:key];
      }

    }];
    if(!isSuccess){
       reject(@"-1",@"图像对象转换json失败",nil);
      return;
    }
     DatabaseManager *manager = [DatabaseManager databaseManager];
    if([manager deleteObjectsFromDatabaseWithTableName:NSStringFromClass([KHData class]) condition:@{@"ywqqid":khData.ywqqid,@"yxlx":khData.yxlx,@"gyh":khData.gyh}]&&[manager insertObjectToDatabaseWithObejct:khData]){
      resolve(@{@"code":@(1),@"note":@"数据保存成功"});
      return;
    }
    reject(@"-1",@"写入数据失败",nil);
  }else{
    reject(@"-1",@"数据为空",nil);
  }
}

/**
 查询利旧信息

 @param khh 客户号
 @return 返回数组
 */
RCT_REMAP_METHOD(query,
                 queryParams:(NSDictionary *)params
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject){
  if(!self.isSetUp){
    reject(@"-1",@"请先执行setUp初始化",nil);
    return;
  }
  if(params){
    NSInteger key = [params[@"queryType"] integerValue];
    switch (key) {
      case QueryTypeOld:
        [self queryOldDatasWithQueryParams:params resolver:resolve rejecter:reject];
        break;
      case QueryTypeYwqqid:
        [self queryYwqqidDatasWithQueryParams:params resolver:resolve rejecter:reject];
        break;
      default:
        reject(@"-1",@"查询类型queryType不存在",nil);
        break;
    }
  }else{
        reject(@"-1",@"查询参数为空",nil);
  }

}

RCT_REMAP_METHOD(clearCache,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject){
  @autoreleasepool {
//    NSArray *tempArray = [[DatabaseManager databaseManager]
//                          queryAllObjectsFromDatabaseWithTableName:NSStringFromClass([KHData class])];
      NSString *date = [NSString stringWithFormat:@"%@-%d",@"strftime('%s','now')",self.timeout];
      NSString *sql = [NSString stringWithFormat:@"select a.* from KHData a where a.saveTime < %@",date];
      NSArray *tempArray = [[DatabaseManager databaseManager] queryObjectsFromDatabaseWithSql:sql
                                                                                  tableName:NSStringFromClass([KHData class])];
    if(tempArray){
      int total = 0;
      int current = 0;
      for (KHData *data in tempArray) {
        int size = [data.imageCount intValue];
        total += size;
      }
      for (KHData *data in tempArray) {
        NSMutableArray *images = [NSMutableArray array];
        if(data.images){
          NSDictionary *temp = [self dictionaryWithJsonString:data.images];
          if(!temp){
            continue;
          }
          images = temp[@"images"];
        }
          for (NSDictionary *dict in images) {
              NSArray *tempArray = [dict allKeys];
              for (NSString *key in tempArray) {
                  NSString *value = dict[key];
                  if ([self isBlankString:value]) {
                      continue;;
                  }
                  @try {
                      [[NSFileManager defaultManager] removeItemAtPath:value error:nil];
                  } @catch (NSException *exception) {
                      reject(@(-1),@"路径为nil",nil);
                  } @finally {

                  }
                  current++;
                  double progress =  [[NSString stringWithFormat:@"%d", current] doubleValue] / [[NSString stringWithFormat:@"%d", total] doubleValue];

                  [self sendEventWithName:EventClearEvent body:@{@"progress":[NSString stringWithFormat:@"%0.2f", progress]}];
              }

          }
        [[DatabaseManager databaseManager] deleteObjectsFromDatabaseWithTableName:NSStringFromClass([KHData class]) condition:@{@"ywqqid":data.ywqqid}];
      }
    }
    resolve(@{@"code":@(1),@"note":@"缓存清除成功"});
  }

}

-(void)queryOldDatasWithQueryParams:(NSDictionary *)params
                           resolver:(RCTPromiseResolveBlock)resolve
                           rejecter:(RCTPromiseRejectBlock)reject{
//  NSString *sql = @"select b.* from KHData b ,(select a.yxlx,max(a.id) id from KHData a where a.khh='010000036889' and a.saveTime > strftime('%s','now')-60*60*3 GROUP BY a.yxlx) c where c.id = b.id";
  NSString *key = @"khh";
  if(![self checkParamWithKey:key data:params]){
    reject(@"-1",@"查询数据的客户号不存在",nil);
    return;
  }
  NSString *khh = params[key];
  if([self isBlankString:khh]){
    reject(@"-1",@"查询数据的客户号为空",nil);
    return;
  }
  NSString *date = [NSString stringWithFormat:@"%@-%d",@"strftime('%s','now')",self.timeout];
  NSString *sql = [NSString stringWithFormat:@"select b.* from KHData b ,(select a.yxlx,max(a.id) id from KHData a where a.khh='%@' and a.saveTime > %@ GROUP BY a.yxlx) c where c.id = b.id",khh,date];
  NSArray *tempArr = [[DatabaseManager databaseManager] queryObjectsFromDatabaseWithSql:sql
                                                                              tableName:NSStringFromClass([KHData class])];
  if(!tempArr){
    reject(@"-1",@"查询数据失败",nil);
    return;
  }
  NSMutableArray *results = [NSMutableArray arrayWithCapacity:tempArr.count];
  for (KHData *data in tempArr) {
    NSMutableArray *images = [NSMutableArray array];
    if(data.images){
      NSDictionary *temp = [self dictionaryWithJsonString:data.images];
      if(!temp){
        reject(@"-1",[NSString stringWithFormat:@"影像类型:%@,images转json失败",data.yxlx],nil);
        return;
      }
      images = temp[@"images"];
    }
    id ext = @"";
    if(data.ext){
      NSDictionary *temp = [self dictionaryWithJsonString:data.ext];
      if(!temp){
        reject(@"-1",[NSString stringWithFormat:@"影像类型:%@,ext转json失败",data.yxlx],nil);
        return;
      }
      ext = temp[@"ext"];
    }
    [results addObject:@{
                         @"khh":data.khh,
                         @"gyh":data.gyh,
                         @"yxlx":data.yxlx,
                         @"images":images,
                         @"imageCount":data.imageCount,
                         @"ext":ext
                         }];
  }
  resolve(@{@"code":@(1),@"note":@"查询成功",@"records":results});

}

-(void)queryYwqqidDatasWithQueryParams:(NSDictionary *)params
                           resolver:(RCTPromiseResolveBlock)resolve
                           rejecter:(RCTPromiseRejectBlock)reject{
  NSString *key = @"ywqqid";
  if(![self checkParamWithKey:key data:params]){
    reject(@"-1",@"查询数据的业务申请ID不存在",nil);
    return;
  }
  NSString *ywqqid = params[key];
  if([self isBlankString:ywqqid]){
    reject(@"-1",@"查询数据的业务申请ID为空",nil);
    return;
  }


  NSArray *tempArr = [[DatabaseManager databaseManager] queryObjectsFromDatabaseWithTableName: NSStringFromClass([KHData class]) condition:@{@"ywqqid":ywqqid}];
  if(!tempArr){
    reject(@"-1",@"查询数据失败",nil);
    return;
  }
  NSMutableArray *results = [NSMutableArray arrayWithCapacity:tempArr.count];
  for (KHData *data in tempArr) {
    NSMutableArray *images = [NSMutableArray array];
    if(data.images){
      NSDictionary *temp = [self dictionaryWithJsonString:data.images];
      if(!temp){
        reject(@"-1",[NSString stringWithFormat:@"影像类型:%@,images转json失败",data.yxlx],nil);
        return;
      }
      images = temp[@"images"];
    }
    id ext = @"";
    if(data.ext){
      NSDictionary *temp = [self dictionaryWithJsonString:data.ext];
      if(!temp){
        reject(@"-1",[NSString stringWithFormat:@"影像类型:%@,ext转json失败",data.yxlx],nil);
        return;
      }
      ext = temp[@"ext"];
    }
    [results addObject:@{
                         @"ywqqid":data.ywqqid,
                         @"khh":data.khh,
                         @"gyh":data.gyh,
                         @"yxlx":data.yxlx,
                         @"images":images,
                         @"imageCount":data.imageCount,
                         @"ext":ext
                         }];
  }
  resolve(@{@"code":@(1),@"note":@"查询成功",@"records":results});

}
-(BOOL)checkParamWithKey:(NSString *)key data:(NSDictionary *)data{
  @autoreleasepool {
    NSArray *tempArray = [data allKeys];
    if(![tempArray containsObject:key]){
      return NO;
    }
  }
  return YES;
}
- (BOOL)isBlankString:(NSString *)aStr {
    if (!aStr) {
        return YES;
    }
    if ([aStr isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (!aStr.length) {
        return YES;
    }
   if(aStr == nil){
       return YES;
   }
  NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  NSString *trimmedStr = [aStr stringByTrimmingCharactersInSet:set];
  if (!trimmedStr.length) {
    return YES;
  }
  return NO;
}

-(NSString *)convertToJsonData:(NSDictionary *)dict
{

  NSError *error;

  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];

  NSString *jsonString;

  if (!jsonData) {
#ifdef DEBUG
    NSLog(@"%@",error);
#endif
    return nil;

  }else{

    jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];

  }

  NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];

  NSRange range = {0,jsonString.length};

  //去掉字符串中的空格

  [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];

  NSRange range2 = {0,mutStr.length};

  //去掉字符串中的换行符

  [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];

  return mutStr;

}
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
  if (jsonString == nil) {
    return nil;
  }

  NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
  NSError *err;
  NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                      options:NSJSONReadingMutableContainers
                                                        error:&err];
  if(err)
  {
#ifdef DEBUG
    NSLog(@"json解析失败：%@",err);
#endif
    return nil;
  }
  return dic;
}
@end
