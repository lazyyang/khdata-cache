//
//  KHData.h
//  RNTemplat
//
//  Created by User on 2018/12/4.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KHData : NSObject
//业务申请号
@property (nonatomic,copy) NSString *ywqqid;
//客户号
@property (nonatomic,copy) NSString *khh;
//员工userid
@property (nonatomic,copy) NSString *gyh;
//影像类型
@property (nonatomic,copy) NSString *yxlx;
//文件路径
@property (nonatomic,copy) NSString *images;
@property (nonatomic,copy) NSString *imageCount;
//文件保存时间，用于计算超时时间
@property (nonatomic,copy) NSString *saveTime;
//日期，用于根据日期删除记录
@property (nonatomic,copy) NSString *rq;
//扩展数据
@property (nonatomic,copy) NSString *ext;

@end

NS_ASSUME_NONNULL_END
