//
//  BetterFileMd5PluginPlugin.h
//  Pods
//
//  Created by 汪洋 on 2021/11/8.
//

#import <Flutter/Flutter.h>
#import "BetterFileMd5PluginApi.h"

@interface BetterFileMd5PluginPlugin : NSObject<BetterFileMd5PluginApiDelegate>

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;

@end
