//
//  BetterFileMd5PluginApi.h
//  Pods
//
//  Created by 汪洋 on 2021/11/8.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "BetterFileMd5PluginEventSink.h"

@protocol BetterFileMd5PluginApiDelegate <NSObject>

- (void)setResultStream:(BetterFileMd5PluginEventSink *)resultStream;

- (void)fileMd5WithInstanceId:(NSInteger)instanceId filePath:(NSString *)filePath;

@end

@interface BetterFileMd5PluginApi : NSObject

+ (void)setup:(NSObject<FlutterPluginRegistrar> *)registrar api:(id<BetterFileMd5PluginApiDelegate>)api;

@end

