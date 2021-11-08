//
//  BetterFileMd5PluginEventSink.h
//  Pods
//
//  Created by 汪洋 on 2021/11/8.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@interface BetterFileMd5PluginEventSink : NSObject <FlutterStreamHandler>

@property (nonatomic, copy) FlutterEventSink event;

@end
