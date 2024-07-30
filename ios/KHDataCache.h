//
//  KHDataCache.h
//  RNTemplat
//
//  Created by User on 2018/12/4.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTEventEmitter.h>
#else
#import "RCTBridgeModule.h"
#import "RCTEventDispatcher.h"
#import "RCTEventEmitter.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface KHDataCache : RCTEventEmitter<RCTBridgeModule>

@end

NS_ASSUME_NONNULL_END
