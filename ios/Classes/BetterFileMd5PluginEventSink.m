//
//  BetterFileMd5PluginEventSink.m
//  Pods
//
//  Created by 汪洋 on 2021/11/8.
//

#import "BetterFileMd5PluginEventSink.h"

@implementation BetterFileMd5PluginEventSink

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.event = NULL;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    self.event = events;
    return nil;
}

@end
